pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../utils/Arrays.sol";
import "../interfaces/nav/INAVCalculator.sol";

contract GovernableFund is ERC20Votes {
	constructor(string memory _name_, string memory _symbol_) ERC20(_name_, _symbol_)  ERC20Permit(_name_) {}

	using SafeERC20 for IERC20;

	uint256 _nav; //TODO: NEEDS TO BE IN BASE TOKEN?
	uint256 _depositBal;
	uint256 _totalDepositBal;
	uint256 _navUpdateLatestIndex;
	uint256 _navUpdateLatestTime;

	address _navCalculatorAddress;
	
	mapping(address => uint256) allowedFundMannagers;
	mapping(address => uint256) _userDepositBal;//USED TO KEEP TRACK OF PERFORMANCE FROM DEPOSITS
	mapping(uint256 => uint256) navUpdatedTime;
	mapping(uint256 => NavUpdateEntry[]) navUpdate;//nav update index -> nav entries for update
	bool isRequestedWithdrawals;

	Settings FundSettings;
	address[] withdrawalQueue;
	mapping(address => WithdrawalRequestEntry) userWithdrawRequest;

	uint256 MAX_BPS = 10000;
	uint256 private fractionBase = 1e9;


	//TODO: NEEDS TO BE A CHAINLINK ORACLE FOR BASE TOKEN?


	struct Settings {
		uint256 depositFee;
		uint256 withdrawFee;
		uint256 performanceFee;
		uint256 managementFee;
		uint256 performaceHurdleRateBps;
		address baseToken;
		address safe; //TODO: needs to be set after safe creation
		bool isExternalGovTokenInUse;
		address governaceToken;
	}

	/*
		TODO:
		Manager will input:
		Token pair address or aggregator address
		Function signature to query floor price
		Function # of inputs
		List of inputs
		Base currency token address
		Asset token address				
	*/

	struct NAVLiquidUpdate {
		address tokenPair;
		address aggregatorAddress;
		bytes functionSignatureWithEncodedInputes;
		address assetTokenAddress;
		address nonAssetTokenAddress;
	}

	/*
		Address of acquired token
		Amount of base currency used to acquire token
		List of txs hashes used to acquire token
		Amount of tokens acquired
	*/
	struct NAVIlliquidUpdate {
		uint256 baseCurrencySpent;
		uint256 amountAquiredTokens;
		address tokenAddress;
		string[] otcTxHashes;
	}

	/*
		TODO
		Chainlink https://docs.chain.link/data-feeds/nft-floor-price/addresses 

	*/
	struct NAVNFTUpdate {
		address oracleAddress;
		address nftAddress;
	}

	/*
		TODO:
		The address that implements some pricing function (can be found in a protocols documentation)
		Function Signature (i.e “transferFrom(address,address,uint256)”, can be found from verified smart contracts in explorer, the open source code for a project)
		Total amount of input values: (i.e “3”)
		Specific input values for the Function to get the required position value (i.e. “0x123,0x456,789)
		Decimals used to normalise position output (i.e “18”)

	*/
	struct NAVComposableUpdate {
		uint256 index;
		address remoteContractAddress;
		string functionSignatures;
		bytes encodedFunctionSignaturWithInputs;
		uint256 normalizationDecimals;
		bool isAdditionOperationOnPrevIndex;
	}

	enum NavUpdateType {
		NAVLiquidUpdateType,
		NAVIlliquidUpdateType,
		NAVNFTUpdateType,
		NAVComposableUpdateType
	}

	struct NavUpdateEntry {
		NavUpdateType entryType;
		NAVLiquidUpdate[] liquid;
		NAVIlliquidUpdate[] illiquid;
		NAVNFTUpdate[] nft;
		NAVComposableUpdate[] composable;
	}

	struct WithdrawalRequestEntry {
		uint256 amount;
		uint256 requestTime;
	}

	function updateSettings() external {
		//TODO: can be triggered by governance or fund manager if not already set?
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData) external {
		//TODO: can be triggered by governance or fund manager
		_navUpdateLatestIndex++;
		_navUpdateLatestTime = block.timestamp;

		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage
		_nav = processNav(navUpdateData);

		//TODO: make sure enough for current withdraw queue
		//TODO: sweep pending deposits to safe address
	}

	function processNav(NavUpdateEntry[] calldata navUpdateData) private returns (uint256) {
		//TODO: call proper interface for each type, may need to happen over multiple transactions?
		uint256 updateedNav = 0;
		for(uint256 i=0; i< navUpdate[_navUpdateLatestIndex].length; i++) {
			if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				//TODO
				//updateedNav += INAVCalculator(_navCalculatorAddress);
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				//TODO
				//updateedNav += INAVCalculator(_navCalculatorAddress);
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVNFTUpdateType) {
				//TODO
				//updateedNav += INAVCalculator(_navCalculatorAddress);
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVComposableUpdateType) {
				//TODO
				//updateedNav += INAVCalculator(_navCalculatorAddress);
			}
			navUpdate[_navUpdateLatestIndex].push(navUpdateData[i]);
 		}

		return updateedNav;
	}

	function computeLatestNav() public view returns (uint256) {
		//TODO: call proper interface for each type
		uint256 updateedNav = 0;
		for(uint256 i=0; i< navUpdate[_navUpdateLatestIndex].length; i++) {
			if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				//pass
				updateedNav += 0;
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				//pass
				updateedNav += 0;
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVNFTUpdateType) {
				//pass
				updateedNav += 0;
			} else if (navUpdate[_navUpdateLatestIndex][i].entryType == NavUpdateType.NAVComposableUpdateType) {
				//pass
				updateedNav += 0;
			}
 		}

		return updateedNav;
	}

	function computeNavAtIndex(uint256 navUpdateIndex) public view returns (uint) {}

	function deposit(uint256  amount) external {

		//TODO: need to send fee value somewhere
		uint feeAmount = amount * FundSettings.depositFee / MAX_BPS;
        uint discountedAmount = amount - feeAmount;

		_depositBal += discountedAmount; //TODO: gets de-incremented when deposits are swept into safe by fund manager during nav updates?
		_totalDepositBal += discountedAmount;
		_userDepositBal[msg.sender] += discountedAmount;

		uint b0 = _nav;
		//transfer tokens to fund
        IERC20(FundSettings.baseToken).safeTransferFrom(msg.sender, address(this), amount);
        uint b1 = _nav + discountedAmount;
        uint p = (b1 - b0) * (fractionBase / b1);
        uint b = 1e3;
        uint v = totalSupply() > 0 ? totalSupply() * p * b / (fractionBase - p) : b1 * b;
        v = _round(v, b);

        _mint(msg.sender, v);
	}

	function totalWithrawalBalance() public view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(address(this)) - _depositBal;
	}
	
	function requestWithdraw(uint256 amount) external {
		require(balanceOf(msg.sender) > 0, "nothing to withdraw");
		isRequestedWithdrawals = true;

		//TODO: check that withdraw request not already made
		withdrawalQueue.push(msg.sender);
		userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(amount, block.timestamp);
	}
	
	function withdraw() external {
		//TODO: need to check that nav update time is greate than withdrawl request time
		//TODO: check that user is in witdrawal queue
		//TODO: need to handle withdral fee, keep track of withdraw balance managers can withdraw?

        uint bal = balanceOf(msg.sender);
        require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");

        uint val = valueOf(msg.sender) * userWithdrawRequest[msg.sender].amount / bal;
        uint feeVal = val * FundSettings.withdrawFee / MAX_BPS;
        uint discountedValue = val - feeVal;


        if (_userDepositBal[msg.sender] >= val){
        	_userDepositBal[msg.sender] -= val;
        	_totalDepositBal -= val;
        } else {
        	_totalDepositBal -= _userDepositBal[msg.sender];
        	_userDepositBal[msg.sender] = 0;
        }


        if (totalWithrawalBalance() > discountedValue) {
           IERC20(FundSettings.baseToken).transfer(msg.sender, discountedValue);
        }

        Arrays.removeItem(withdrawalQueue, msg.sender);
        userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);

        
        _burn(msg.sender, userWithdrawRequest[msg.sender].amount);
    }

	function valueOf(address ownr) public view returns (uint256) {
        return (_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe)) * balanceOf(ownr) / totalSupply();
    }

    // rounds "v" considering a base "b"
    function _round(uint v, uint b) internal pure returns (uint) {
        return (v / b) + ((v % b) >= (b / 2) ? 1 : 0);
    }
}