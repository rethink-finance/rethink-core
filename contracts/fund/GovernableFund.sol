// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "./GovernableFundStorage.sol";

contract GovernableFund is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;

	//TODO: NEEDS TO BE A ORACLE FOR BASE TOKEN

	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

	function initialize(string memory _name_, string memory _symbol_, IGovernableFundStorage.Settings calldata _fundSettings, address navCalculatorAddress, address fundDelgateCallFlowAddress, address fundDelgateCallNavAddress, string memory _fundMetadata) external initializer {
		__ERC20_init(_name_, _symbol_);
		__ERC20Permit_init(_name_);
		//TODO: need to do validation of inputs?
		FundSettings = _fundSettings;
		_fundStartTime = block.timestamp;
		_navCalculatorAddress = navCalculatorAddress;
		_fundDelgateCallFlowAddress = fundDelgateCallFlowAddress;
		_fundDelgateCallNavAddress = fundDelgateCallNavAddress;

		_fundSettings.allowedDepositAddrs;
		_fundSettings.allowedManagers;

		fundMetadata = _fundMetadata;

		uint i;
		for (i=0; i<_fundSettings.allowedManagers.length; i++){
			allowedFundMannagers[_fundSettings.allowedManagers[i]] = true;
		}
		for (i=0; i<_fundSettings.allowedDepositAddrs.length; i++){
			whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = true;
		}
		for (i=0; i<_fundSettings.feeCollectors.length; i++){
			feeCollectorAddress[FundFeeType(i)] = _fundSettings.feeCollectors[i];
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

	function updateSettings(IGovernableFundStorage.Settings calldata _fundSettings, string memory _fundMetadata) external {
		onlyGovernance();
		FundSettings = _fundSettings;
		fundMetadata = _fundMetadata;

		uint i;
		//TODO: should work like a toggle if already set to true
		for (i=0; i<_fundSettings.allowedManagers.length; i++){
			allowedFundMannagers[_fundSettings.allowedManagers[i]] = true;
		}
		//TODO: should work like a toggle if already set to true
		for (i=0; i<_fundSettings.allowedDepositAddrs.length; i++){
			whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = true;
		}
		for (i=0; i<_fundSettings.feeCollectors.length; i++){
			feeCollectorAddress[FundFeeType(i)] = _fundSettings.feeCollectors[i];
		}
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData) external {
		onlyGovernance();

		_navUpdateLatestIndex++;
		_navUpdateLatestTime = block.timestamp;
		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage

		//processNav((uint8,(address,address,bytes,address,address,bool,uint256,uint256,uint256)[],(uint256,uint256,address,bool,string[],uint8,uint256,uint256)[],(address,address,uint8,uint256,uint256)[],(address,string,bytes,uint256,bool,uint256,uint256,uint8,uint256)[],bool,uint256,uint256)[]) -> 0x7a627c91

		(bool success, bytes memory navBytes) = IBeacon(_fundDelgateCallNavAddress).implementation().delegatecall(
			abi.encodeWithSelector(
				bytes4(0x7a627c91),
				navUpdateData
			)
		);
		require(success == true, "failed processNav");

		_nav = abi.decode(navBytes, (uint256));

		//NOTE: could be some logic to better handle deposit/withdrawal flows
		require((((_nav + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe) - _depositBal) * _withdrawalBal) / totalSupply()) <= IERC20(FundSettings.baseToken).balanceOf(address(this)), 'not enough for withdrawals');
		isRequestedWithdrawals = false;
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

    function calculateAccruedManagementFees() public view returns (uint256 accruedFees) {
        uint256 startTime = (_lastClaimedManagementFees == 0) ? _fundStartTime: _lastClaimedManagementFees;
        uint256 accruingPeriod = (block.timestamp - startTime);
        uint256 feeBase = totalSupply();
        uint256 feePerSecond = (feeBase * FundSettings.managementFee) /
            (365 * 86400 * 10000);
        accruedFees = feePerSecond * accruingPeriod;
    }

    function calculateAccruedPerformanceFees() public view returns (uint256 accruedFees) {
    	uint256 nav = totalNAV();
    	int256 returnOverDeposits = int256(nav) - int256(_totalDepositBal);
    	uint256 performanceTake = 0;
    	if(returnOverDeposits > 0) {
    		uint256 hurdleReturn = (nav * FundSettings.performaceHurdleRateBps) / MAX_BPS;
    		if (hurdleReturn < uint256(returnOverDeposits)) {
    			performanceTake = ((uint256(returnOverDeposits) - hurdleReturn) * FundSettings.performanceFee) / MAX_BPS;
    			/*
			        //mintmount = totalSupply * (performanceTake / totalNAV);
    			*/
    		}
    	}

        uint256 startTime = (_lastClaimedPerformanceFees == 0) ? _fundStartTime: _lastClaimedPerformanceFees;
        uint256 accruingPeriod = (block.timestamp - startTime);
        uint256 feeBase = totalSupply();
        uint256 feePerSecond = ((feeBase * performanceTake) / _totalDepositBal) /
            (365 * 86400 * 10000);
        accruedFees = feePerSecond * accruingPeriod;
    }

    function collectFees(FundFeeType feeType) external {
    	/*
    		enum FundFeeType {
				DepositFee,
				WithdrawFee,
				ManagementFee,
				PerformanceFee
			}
		*/
		//NOTE: deposit and withdrawal fees are combined, collector should be same addr

		if(feeCollectorAddress[feeType] == address(0)){
			return;
		}

		uint feeVal;
        uint discountedValue;

		if (feeType == FundFeeType.DepositFee || feeType == FundFeeType.WithdrawFee) {
			feeVal = (_feeBal * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _feeBal - feeVal;

	    	IERC20(FundSettings.baseToken).transfer(feeCollectorAddress[feeType], discountedValue);
	    	if (feeVal > 0) {
		    	IERC20(FundSettings.baseToken).transfer(daoFeeAddr, feeVal);
	    	}

	    	_feeBal = 0;
		} else if (feeType == FundFeeType.ManagementFee) {
			uint256 _accruedFees = calculateAccruedManagementFees();
			feeVal = (_accruedFees * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _accruedFees - feeVal;
			_mint(feeCollectorAddress[feeType], discountedValue);
			if (feeVal > 0) {
				_mint(daoFeeAddr, feeVal);
	    	}
			_lastClaimedManagementFees = block.timestamp;
		} else if (feeType == FundFeeType.PerformanceFee) {
			uint256 _accruedFees = calculateAccruedPerformanceFees();
			feeVal = (_accruedFees * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _accruedFees - feeVal;
			_mint(feeCollectorAddress[feeType], discountedValue);
			if (feeVal > 0) {
				_mint(daoFeeAddr, feeVal);
	    	}
			_lastClaimedPerformanceFees = block.timestamp;
		}
    }

    function toggleDaoFee() external {
    	onlyOwner();

		if (isDAOFeeEnabled == true) {
			isDAOFeeEnabled = false;
		} else {
			isDAOFeeEnabled = true;
		}
	}

	function setDaoFeeBps(uint256 bps) external {
    	onlyOwner();
    	require(bps <= MAX_BPS, "bad bps");
    	daoFeeBps = bps;
	}

	function setDaoFeeAddr(address addr) external {
    	onlyOwner();
    	daoFeeAddr = addr;
	}

	function valueOf(address ownr) public view returns (uint256) {
        return (totalNAV() * balanceOf(ownr)) / totalSupply();
    }

    function totalNAV() public view returns (uint256) {
    	return (_nav + IERC20(FundSettings.baseToken).balanceOf(address(this)) + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe)  - _feeBal);
    }

    function onlyGovernance() private view {
    	require(msg.sender == FundSettings.governor, "only gov");
    }

    function onlyManagers() private view {
    	require(allowedFundMannagers[msg.sender] == true, "only manager");
    }

    function onlyOwner() private view {
    	bytes memory ownerCheck = abi.encodeWithSelector(
            bytes4(keccak256("owner()"))
        );
        (bool success, bytes memory data) = _fundDelgateCallNavAddress.staticcall(ownerCheck);
	    require(success == true, "fail ownerCheck");
    	require(msg.sender == abi.decode(data, (address)), "only owner");
    }
}