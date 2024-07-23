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

	function initialize(string memory _name_, string memory _symbol_, IGovernableFundStorage.Settings calldata _fundSettings, address navCalculatorAddress, address fundDelgateCallFlowAddress, address fundDelgateCallNavAddress, string memory _fundMetadata, uint256 _feePerformancePeriod, uint256 _feeManagePeriod) external initializer {
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
		feePerformancePeriod = _feePerformancePeriod;
		feeManagePeriod = _feeManagePeriod;

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

	function updateSettings(IGovernableFundStorage.Settings calldata _fundSettings, string memory _fundMetadata, uint256 _feePerformancePeriod, uint256 _feeManagePeriod) external {
		onlyGovernance();
		FundSettings = _fundSettings;
		fundMetadata = _fundMetadata;
		feePerformancePeriod = _feePerformancePeriod;
		feeManagePeriod = _feeManagePeriod;

		uint i;
		for (i=0; i<_fundSettings.allowedManagers.length; i++){
			if (allowedFundMannagers[_fundSettings.allowedManagers[i]] == true) {
				allowedFundMannagers[_fundSettings.allowedManagers[i]] = false;
			} else {
				allowedFundMannagers[_fundSettings.allowedManagers[i]] = true;
			}
		}
		for (i=0; i<_fundSettings.allowedDepositAddrs.length; i++){
			if (whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] == true) {
				whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = false;
			} else {
				whitelistedDepositors[_fundSettings.allowedDepositAddrs[i]] = true;
			}
		}
		for (i=0; i<_fundSettings.feeCollectors.length; i++){
			feeCollectorAddress[FundFeeType(i)] = _fundSettings.feeCollectors[i];
		}
	}

	function updateNav(NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, bool processWithdraw) public {
    	require(msg.sender == FundSettings.governor || msg.sender == FundSettings.safe || msg.sender == address(this), "only gov");

		_navUpdateLatestIndex++;
		_navUpdateLatestTime = block.timestamp;
		navUpdatedTime[_navUpdateLatestIndex] = block.timestamp;

		//process nav here, save to storage

		//cast sig "processNav((uint8,(address,address,bytes,address,address,bool,uint256,uint256,uint256)[],(uint256,uint256,address,bool,string[],uint8,uint256,uint256)[],(address,address,uint8,uint256,uint256)[],(address,string,bytes,uint256,bool,uint256,uint256,uint8,uint256,bool)[],bool,uint256,uint256,string)[],address[])" -> 0xb7ec3eda

		(bool success, bytes memory navBytes) = IBeacon(_fundDelgateCallNavAddress).implementation().delegatecall(
			abi.encodeWithSelector(
				bytes4(0xb7ec3eda),
				navUpdateData,
				pastNAVUpdateEntryFundAddress
			)
		);
		require(success == true, "failed processNav");

		_nav = abi.decode(navBytes, (uint256));

		uint256 ts = totalSupply();
		if (processWithdraw == true && (ts > 0)) {
			//NOTE: could be some logic to better handle deposit/withdrawal flows
			require(((totalNAV() * _withdrawalBal) / ts) <= totalWithrawalBalance(), 'not enough for withdrawals');
			isRequestedWithdrawals = false;
		}
	}

	function executeNAVUpdate(address navExecutor) external {
		onlyGovernanceOrSafe();
		(, bytes memory execData) = navExecutor.call(
			abi.encodeWithSignature("getNAVData(address)", address(this))
		);
		(bool success, ) = address(this).call(abi.decode(execData, (bytes)));
		require(success == true, "fail permissioned nav update");
	}

	function fundFlowsCall(bytes calldata flowCall) external {
		bytes4 matchSig = bytes4(flowCall);

		bool isFound = false;
		if (matchSig == bytes4(keccak256("revokeDepositWithrawal(bool)"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("requestDeposit(uint256)"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("deposit()"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("requestWithdraw(uint256)"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("withdraw()"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("sweepTokens()"))) {
			isFound = true;
		} else if (matchSig == bytes4(keccak256("collectFees(uint8)"))) {
			isFound = true;		
		} else if (matchSig == bytes4(keccak256("mintPerformanceFee(uint256)"))) {
			onlyGovernanceOrSafe();
			isFound = true;
		} else if (matchSig == bytes4(keccak256("mintToMany(uint256[],address[])"))) {
			onlyGovernanceOrSafe();
			isFound = true;
		}

		if (isFound == true) {
			(bool success,) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
				flowCall
			);
			require(success == true, "fail flowCall");
		}
	}

	function totalWithrawalBalance() public view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(address(this)) - _feeBal;
	}

    //NOTE: IS NOT STATE CHANGING FUNCTION, BUT DELEGATE CALLS CANNOT USE VIEW
    function calculateAccrued(uint8 feeKind) public returns (uint256) {
    	bytes memory _feeCall = (feeKind == 0) ? abi.encodeWithSignature("calculateAccruedManagementFees()") : abi.encodeWithSignature("calculateAccruedPerformanceFees()");
    	(bool success, bytes memory data) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			_feeCall
		);
		require(success == true, "fail calculateAccruedX");

		return abi.decode(data, (uint256));
    }

    //TODO: REPLACE WITH DYNAMIC FUND FLOW CALL WITH SIG CHECK, PASS IN ENCODED FUNCTION
    function collectFees(FundFeeType feeType) external {
		(bool success,) = IBeacon(_fundDelgateCallFlowAddress).implementation().delegatecall(
			abi.encodeWithSignature("collectFees(uint8)", feeType)
		);
		require(success == true, "fail collectFees");
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

    function onlyGovernanceOrSafe() private view {
    	require(msg.sender == FundSettings.governor || msg.sender == FundSettings.safe, "only gov");
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
	    require(data.length > 0, "bad return data");
    	require(msg.sender == abi.decode(data, (address)), "only owner");
    }
}