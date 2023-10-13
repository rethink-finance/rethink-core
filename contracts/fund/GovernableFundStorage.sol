// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "../interfaces/fund/IGovernableFund.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract GovernableFundStorage is IGovernableFund {
	uint256 _nav; //TODO: NEEDS TO BE IN BASE TOKEN?
	uint256 public _feeBal;
	uint256 _depositBal;
	uint256 _withdrawalBal;
    uint256 _fundStartTime;
    uint256 MAX_BPS = 10000;
	uint256 _totalDepositBal;
	uint256 public _navUpdateLatestTime;
	uint256 public _navUpdateLatestIndex;
    uint256 _lastClaimedManagementFees;
	address _navCalculatorAddress;
	address _fundDelgateCallFlowAddress;
	mapping(address => bool) allowedFundMannagers;
	mapping(address => bool) whitelistedDepositors;
	mapping(address => uint256) _userDepositBal;//USED TO KEEP TRACK OF PERFORMANCE FROM DEPOSITS
	mapping(uint256 => uint256) navUpdatedTime;
	mapping(uint256 => NavUpdateEntry[]) navUpdate;//nav update index -> nav entries for update
	bool isRequestedWithdrawals;
	mapping(address => DepositRequestEntry) userDepositRequest;
	mapping(address => WithdrawalRequestEntry) userWithdrawRequest;	
	Settings public FundSettings;

	function getFundSettings() external view returns (Settings memory) {
		return FundSettings;
	}
}