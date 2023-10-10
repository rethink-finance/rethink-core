// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "./GovernableFundStorage.sol";

contract GovernableFund is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;

	//TODO: NEEDS TO BE A ORACLE FOR BASE TOKEN

	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

	function initialize(string memory _name_, string memory _symbol_, IGovernableFund.Settings calldata _fundSettings, address navCalculatorAddress, address fundDelgateCallFlowAddress) override external initializer {
		__ERC20_init(_name_, _symbol_);
		__ERC20Permit_init(_name_);
		//TODO: need to do validation of imputs
		FundSettings = _fundSettings;
		_fundStartTime = block.timestamp;
		_navCalculatorAddress = navCalculatorAddress;
		_fundDelgateCallFlowAddress = fundDelgateCallFlowAddress;
	}

	function updateSettings(IGovernableFund.Settings calldata _fundSettings) external {
		//TODO: only allow updates on changable settings
		onlyGovernance();
		FundSettings = _fundSettings;
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData) external {
		onlyGovernance();
		
		_navUpdateLatestTime = block.timestamp;
		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage
		_nav = processNav(navUpdateData);

		//NOTE: could be some logic to better handle deposit/withdrawal flows
		require(((_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe) - _depositBal) * _withdrawalBal / totalSupply()) <= IERC20(FundSettings.baseToken).balanceOf(address(this)), 'not enough for withdrawals');
		isRequestedWithdrawals = false;
		_navUpdateLatestIndex++;
	}

	function processNav(NavUpdateEntry[] calldata navUpdateData) private returns (uint256) {
		//NOTE: may need to happen over multiple transactions?
		uint256 updateedNav = 0;
		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).liquidCalculation(
					navUpdateData[i].liquid,
					FundSettings.safe,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].liquid
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).illiquidCalculation(
					navUpdateData[i].illiquid,
					FundSettings.safe,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].illiquid
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).nftCalculation(
					navUpdateData[i].nft,
					FundSettings.safe,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].nft
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).composableCalculation(
					navUpdateData[i].composable,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].composable
				);
			}

			if (navUpdateData[i].isPastNAVUpdate == true){
				navUpdate[_navUpdateLatestIndex].push(navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex]);
			} else {
				navUpdate[_navUpdateLatestIndex].push(navUpdateData[i]);
			}
 		}

		return updateedNav;
	}

	function revokeDepositWithrawal(bool isDeposit) external {
		(bool success,) = address(this).delegatecall(
			abi.encodeWithSignature("revokeDepositWithrawal(bool)", isDeposit)
		);
		require(success == true, "failed revoke");
	}

	function requestDeposit(uint256 amount) external {
		(bool success, ) = address(this).delegatecall(
			abi.encodeWithSignature("requestDeposit(uint256)", amount)
		);
		require(success == true, "failed withrawal request");
	}

	function deposit() external {
		(bool success,) = address(this).delegatecall(
			abi.encodeWithSignature("deposit()")
		);
		require(success == true, "failed deposit");
	}

	function totalWithrawalBalance() public view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(address(this)) - _feeBal;
	}

	function requestWithdraw(uint256 amount) external {
		(bool success,) = address(this).delegatecall(
			abi.encodeWithSignature("requestWithdraw(uint256)", amount)
		);
		require(success == true, "failed withrawal request");
	}
	
	function withdraw() external {
		(bool success, ) = address(this).delegatecall(
			abi.encodeWithSignature("withdraw()")
		);
		require(success == true, "failed withrawal");
    }

    function collectFees() external {
    	onlyManagers();
    	IERC20(FundSettings.baseToken).transfer(msg.sender, _feeBal);
    	_feeBal = 0;
    }

    function calculateAccruedManagementFees() public view returns (uint256 accruedFees) {
        //add require to only valid token
        uint256 startTime = (_lastClaimedManagementFees == 0) ? _fundStartTime: _lastClaimedManagementFees;
        uint256 accruingPeriod = (block.timestamp - startTime);
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

    function onlyGovernance() private view {
    	require(msg.sender == FundSettings.governor, "only gov");
    }

    function onlyManagers() private view {
    	require(allowedFundMannagers[msg.sender] == true, "only manager");
    }
}