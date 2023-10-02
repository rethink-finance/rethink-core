pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/nav/INAVCalculator.sol";
//import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract GovernableFund is IGovernableFund, ERC20VotesUpgradeable {
	using SafeERC20 for IERC20;

	uint256 _nav; //TODO: NEEDS TO BE IN BASE TOKEN?
	uint256 _depositBal;
	uint256 _withdrawalBal;
	uint256 _feeBal;
	uint256 _totalDepositBal;
	uint256 _navUpdateLatestIndex;
	uint256 _navUpdateLatestTime;
    uint256 _lastClaimedManagementFees;
    uint256 _fundStartTime;

	address _navCalculatorAddress;
	
	mapping(address => bool) allowedFundMannagers;
	mapping(address => bool) whitelistedDepositors;
	mapping(address => uint256) _userDepositBal;//USED TO KEEP TRACK OF PERFORMANCE FROM DEPOSITS
	mapping(uint256 => uint256) navUpdatedTime;
	mapping(uint256 => NavUpdateEntry[]) navUpdate;//nav update index -> nav entries for update
	bool isRequestedWithdrawals;

	Settings FundSettings;
	mapping(address => WithdrawalRequestEntry) userWithdrawRequest;
	mapping(address => DepositRequestEntry) userDepositRequest;
	uint256 MAX_BPS = 10000;
	uint256 private fractionBase = 1e9;


	//TODO: NEEDS TO BE A CHAINLINK ORACLE FOR BASE TOKEN?

	function initialize(string memory _name_, string memory _symbol_, IGovernableFund.Settings calldata _fundSettings) override external initializer {
		__ERC20_init(_name_, _symbol_);
		__ERC20Permit_init(_name_);
		//TODO: need to do validation of imputs
		FundSettings = _fundSettings;
		_fundStartTime = block.timestamp;
	}

	function updateSettings(IGovernableFund.Settings calldata _fundSettings) external {
		//TODO: only allow updates on changable settings
		onlyGovernanceOrManagers();
		FundSettings = _fundSettings;
	}

	function navUpdateLatestIndex() external view returns (uint256) {
		return _navUpdateLatestIndex;
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData) external {
		onlyGovernanceOrManagers();
		
		_navUpdateLatestIndex++;
		_navUpdateLatestTime = block.timestamp;

		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage
		_nav = processNav(navUpdateData);

		//NOTE: could be some logic to better handle deposit/withdrawal flows
		require(((_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe) - _depositBal) * _withdrawalBal / totalSupply()) <= IERC20(FundSettings.baseToken).balanceOf(address(this)), 'not enough for withdrawals');
		isRequestedWithdrawals = false;
	}

	function processNav(NavUpdateEntry[] calldata navUpdateData) private returns (uint256) {
		//NOTE: may need to happen over multiple transactions?
		uint256 updateedNav = 0;
		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).liquidCalculation(navUpdateData[i].liquid, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).illiquidCalculation(navUpdateData[i].illiquid, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).nftCalculation(navUpdateData[i].nft, FundSettings.safe);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).composableCalculation(navUpdateData[i].composable) ;
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
				historicalNav += INAVCalculator(_navCalculatorAddress).composableCalculation(navUpdate[navUpdateIndex][i].composable) ;
			}
 		}

		return historicalNav;
	}

	function requestDeposit(uint256 amount) external {
		if (FundSettings.isWhitelistedDeposits == true) {
			require(whitelistedDepositors[msg.sender] == true, "not allowed");
		}

		require(userDepositRequest[msg.sender].amount == 0 && userDepositRequest[msg.sender].requestTime == 0, "already requested");


		userDepositRequest[msg.sender] = DepositRequestEntry(amount, block.timestamp);

		

		_depositBal += amount;
		_totalDepositBal += amount;
		_userDepositBal[msg.sender] += amount;
	}

	function deposit() external {

		uint bal = IERC20(FundSettings.baseToken).balanceOf(msg.sender);

		require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");

		require(userDepositRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex], "not allowed yet");
        require(userDepositRequest[msg.sender].amount != 0 && userDepositRequest[msg.sender].requestTime != 0, "deposit not requested");

		uint b0 = _nav;
		
		//transfer tokens to fund
        IERC20(FundSettings.baseToken).safeTransferFrom(msg.sender, address(this), userDepositRequest[msg.sender].amount);
        uint feeAmount = userDepositRequest[msg.sender].amount * FundSettings.depositFee / MAX_BPS;
        uint discountedAmount = userDepositRequest[msg.sender].amount - feeAmount;
        _feeBal += feeAmount;

        uint b1 = _nav + discountedAmount;
        uint p = (b1 - b0) * (fractionBase / b1);
        uint b = 1e3;
        uint v = totalSupply() > 0 ? totalSupply() * p * b / (fractionBase - p) : b1 * b;
        v = _round(v, b);

        _mint(msg.sender, v);


        IERC20(FundSettings.baseToken).transfer(FundSettings.safe, discountedAmount);
		_depositBal -= userDepositRequest[msg.sender].amount;
		_userDepositBal[msg.sender] = 0;
        userDepositRequest[msg.sender] = DepositRequestEntry(0, 0);

	}

	function totalWithrawalBalance() public view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(address(this)) - _depositBal - _feeBal;
	}

	function flowFeesCollected() public view returns (uint256) {
		return _feeBal;
	}
	
	function requestWithdraw(uint256 amount) external {
		require(balanceOf(msg.sender) > 0, "nothing to withdraw");
		isRequestedWithdrawals = true;

		if (FundSettings.isWhitelistedDeposits == true) {
			require(whitelistedDepositors[msg.sender] == true, "not allowed");
		}

		require(userWithdrawRequest[msg.sender].amount == 0 && userWithdrawRequest[msg.sender].requestTime == 0, "already requested");

		userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(amount, block.timestamp);
		_withdrawalBal += amount;
	}
	
	function withdraw() external {
		//NOTE:  should just be map to avoid array usage?

        uint bal = balanceOf(msg.sender);
        require(userWithdrawRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex], "not allowed yet");
        require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");
        require(userWithdrawRequest[msg.sender].amount != 0 && userWithdrawRequest[msg.sender].requestTime != 0, "withdrawal not requested");


        uint val = valueOf(msg.sender) * userWithdrawRequest[msg.sender].amount / bal;
        uint feeVal = val * FundSettings.withdrawFee / MAX_BPS;
        uint discountedValue = val - feeVal;
        _feeBal += feeVal;


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
        
        _burn(msg.sender, userWithdrawRequest[msg.sender].amount);
        _withdrawalBal -= userWithdrawRequest[msg.sender].amount;
        userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);

    }

    function collectFees() external {
    	onlyManagers();
    	IERC20(FundSettings.baseToken).transfer(msg.sender, _feeBal);
    	_feeBal = 0;
    }

    function getManagementFeesAccruingPeriod() internal view returns (uint256) {
        uint256 startTime = (_lastClaimedManagementFees == 0) ? _fundStartTime: _lastClaimedManagementFees;
        return (block.timestamp - startTime);
    }

    function calculateAccruedManagementFees() public view returns (uint256 accruedFees) {
        //add require to only valid token
        uint256 accruingPeriod = getManagementFeesAccruingPeriod();
        uint256 managmentFeeLevel = FundSettings.managementFee;
        uint256 feeBase = totalSupply();
        uint256 feePerSecond = (feeBase * managmentFeeLevel) /
            (365 * 86400 * 10000);
        accruedFees = feePerSecond * accruingPeriod;
    }

    function claimManagementFees() public returns (bool) {
        onlyManagers();

        uint256 _accruedFees = calculateAccruedManagementFees();
        _mint(msg.sender, _accruedFees);
        _lastClaimedManagementFees = block.timestamp;
        return true;
    }

	function valueOf(address ownr) public view returns (uint256) {
        return (_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe)) * balanceOf(ownr) / totalSupply();
    }

    // rounds "v" considering a base "b"
    function _round(uint v, uint b) internal pure returns (uint) {
        return (v / b) + ((v % b) >= (b / 2) ? 1 : 0);
    }

    function onlyGovernanceOrManagers() private view {
    	require(allowedFundMannagers[msg.sender] == true || msg.sender == FundSettings.governor, "not allowed");
    }

    function onlyManagers() private view {
    	require(allowedFundMannagers[msg.sender] == true, "not allowed");
    }
}