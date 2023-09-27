pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../utils/Arrays.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/nav/INAVCalculator.sol";

contract GovernableFund is IGovernableFund, ERC20Votes {
	constructor(string memory _name_, string memory _symbol_) ERC20(_name_, _symbol_)  ERC20Permit(_name_) {}

	using SafeERC20 for IERC20;

	uint256 _nav; //TODO: NEEDS TO BE IN BASE TOKEN?
	uint256 _depositBal;
	uint256 _totalDepositBal;
	uint256 _navUpdateLatestIndex;
	uint256 _navUpdateLatestTime;

	address _navCalculatorAddress;
	
	mapping(address => uint256) allowedFundMannagers;
	mapping(address => uint256) whitelistedDepositors;
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

	function updateSettings() external {
		//TODO: can be triggered by governance or fund manager if not already set?
	}

	function navUpdateLatestIndex() external view returns (uint256) {
		return _navUpdateLatestIndex;
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
		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).liquidCalculation(navUpdateData[i].liquid, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).illiquidCalculation(navUpdateData[i].illiquid, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).nftCalculation(navUpdateData[i].nft, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).composableCalculation(navUpdateData[i].composable, FundSettings.safe) ;
			}
			navUpdate[_navUpdateLatestIndex].push(navUpdateData[i]);
 		}

		return updateedNav;
	}

	function computeNavAtIndex(uint256 navUpdateIndex) external view returns (uint) {
		uint256 historicalNav = 0;
		for(uint256 i=0; i< navUpdate[navUpdateIndex].length; i++) {
			if (navUpdate[navUpdateIndex][i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				historicalNav += INAVCalculator(_navCalculatorAddress).liquidCalculation(navUpdate[navUpdateIndex][i].liquid, FundSettings.safe);
			} else if (navUpdate[navUpdateIndex][i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				historicalNav += INAVCalculator(_navCalculatorAddress).illiquidCalculation(navUpdate[navUpdateIndex][i].illiquid, FundSettings.safe);
			} else if (navUpdate[navUpdateIndex][i].entryType == NavUpdateType.NAVNFTUpdateType) {
				historicalNav += INAVCalculator(_navCalculatorAddress).nftCalculation(navUpdate[navUpdateIndex][i].nft, FundSettings.safe);
			} else if (navUpdate[navUpdateIndex][i].entryType == NavUpdateType.NAVComposableUpdateType) {
				historicalNav += INAVCalculator(_navCalculatorAddress).composableCalculation(navUpdate[navUpdateIndex][i].composable, FundSettings.safe) ;
			}
 		}

		return historicalNav;
	}

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