// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "./GovernableFundStorage.sol";

contract GovernableFund is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;

	//TODO: NEEDS TO BE A ORACLE FOR BASE TOKEN

	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

	function initialize(string memory _name_, string memory _symbol_, IGovernableFundStorage.Settings calldata _fundSettings, address navCalculatorAddress, address fundDelgateCallFlowAddress, address fundDelgateCallNavAddress) external initializer {
		__ERC20_init(_name_, _symbol_);
		__ERC20Permit_init(_name_);
		//TODO: need to do validation of imputs
		FundSettings = _fundSettings;
		_fundStartTime = block.timestamp;
		_navCalculatorAddress = navCalculatorAddress;
		_fundDelgateCallFlowAddress = fundDelgateCallFlowAddress;
		_fundDelgateCallNavAddress = fundDelgateCallNavAddress;

		_fundSettings.allowedDepositAddrs;
		_fundSettings.allowedManagers;

		uint i;
		for (i=0; i<_fundSettings.allowedManagers.length; i++){
			allowedFundMannagers[_fundSettings.allowedManagers[i]] = true;
		}
		for (i=0; i<_fundSettings.allowedDepositAddrs.length; i++){
			whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = true;
		}
	}

	// Overrides IERC6372 functions to make the token & governor timestamp-based
    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

	function updateSettings(IGovernableFundStorage.Settings calldata _fundSettings) external {
		//TODO: only allow updates on changable settings
		onlyGovernance();
		FundSettings = _fundSettings;

		uint i;
		for (i=0; i<_fundSettings.allowedManagers.length; i++){
			allowedFundMannagers[_fundSettings.allowedManagers[i]] = true;
		}
		for (i=0; i<_fundSettings.allowedDepositAddrs.length; i++){
			whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = true;
		}
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData) external {
		onlyGovernance();
		
		_navUpdateLatestTime = block.timestamp;
		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage
		(bool success, bytes memory navBytes) = IBeacon(_fundDelgateCallNavAddress).implementation().delegatecall(
			abi.encodeWithSignature("processNav(NavUpdateEntry[])", navUpdateData)
		);
		require(success == true, "failed processNav");

		_nav = abi.decode(navBytes, (uint256));
		//_nav = processNav(navUpdateData);

		//NOTE: could be some logic to better handle deposit/withdrawal flows
		require(((_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe) - _depositBal) * _withdrawalBal / totalSupply()) <= IERC20(FundSettings.baseToken).balanceOf(address(this)), 'not enough for withdrawals');
		isRequestedWithdrawals = false;
		_navUpdateLatestIndex++;
	}

	function revokeDepositWithrawal(bool isDeposit) external {
		(bool success,) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			abi.encodeWithSignature("revokeDepositWithrawal(bool)", isDeposit)
		);
		require(success == true, "failed revoke");
	}

	function requestDeposit(uint256 amount) external {
		(bool success, ) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			abi.encodeWithSignature("requestDeposit(uint256)", amount)
		);
		require(success == true, "failed deposit request");
	}

	function deposit() external {
		(bool success,) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			abi.encodeWithSignature("deposit()")
		);
		require(success == true, "failed deposit");
	}

	function totalWithrawalBalance() public view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(address(this)) - _feeBal;
	}

	function requestWithdraw(uint256 amount) external {
		(bool success,) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			abi.encodeWithSignature("requestWithdraw(uint256)", amount)
		);
		require(success == true, "failed withrawal request");
	}
	
	function withdraw() external {
		(bool success, ) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
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

    function onlyGovernance() private view {
    	require(msg.sender == FundSettings.governor, "only gov");
    }

    function onlyManagers() private view {
    	require(allowedFundMannagers[msg.sender] == true, "only manager");
    }
}