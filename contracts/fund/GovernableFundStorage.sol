// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "../interfaces/fund/IGovernableFundStorage.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract GovernableFundStorage is IGovernableFundStorage {
	uint256 _nav; //TODO: NEEDS TO BE IN BASE TOKEN?
	uint256 public _feeBal;
	uint256 _depositBal;
	uint256 _withdrawalBal;
    uint256 _fundStartTime;
    uint256 MAX_BPS = 10000;
	uint256 public _totalDepositBal;
	uint256 public _navUpdateLatestTime;
	uint256 public _navUpdateLatestIndex;
    uint256 _lastClaimedManagementFees;
	address _navCalculatorAddress;
	address _fundDelgateCallFlowAddress;
	address	_fundDelgateCallNavAddress;
	mapping(address => bool) allowedFundMannagers;
	mapping(address => bool) whitelistedDepositors;
	mapping(address => uint256) _userDepositBal;
	mapping(uint256 => uint256) navUpdatedTime;
	mapping(uint256 => NavUpdateEntry[]) navUpdate;//nav update index -> nav entries for update
	bool isRequestedWithdrawals;
	mapping(address => DepositRequestEntry) userDepositRequest;
	mapping(address => WithdrawalRequestEntry) userWithdrawRequest;	
	Settings public FundSettings;

	/*

		TO AVOID STORAGE CONFLICT WITH FUND PROXY
	*/
	// This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 internal constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;


    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    uint256 internal constant fractionBase = 1e9; //NOTE: assumes lp token is 18 decimals

    bool isDAOFeeEnabled = false;
    uint256 daoFeeBps = 10;
    address daoFeeAddr;
    uint256 _lastClaimedPerformanceFees;

    mapping(FundFeeType => address) feeCollectorAddress;
    string public fundMetadata;

	function getFundSettings() external view returns (Settings memory) {
		return FundSettings;
	}

	function getNavEntry(uint256 index) external view returns (NavUpdateEntry[] memory) {
		return navUpdate[index];
	}

	function getFeeCollector(FundFeeType feeType) external view returns (address) {
		return feeCollectorAddress[feeType];
	}

	function getCurrentPendingWithdrawalBal() external view returns (uint256) {
		return _withdrawalBal;
	}

	function getCurrentPendingDepositBal() external view returns (uint256) {
		return _depositBal;
	}
}