// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./IGovernableFundStorage.sol";

interface IGovernableFundStorageFunctions {
	function getFundSettings() external view returns (IGovernableFundStorage.Settings memory);
	function getNavEntry(uint256 index) external view returns (IGovernableFundStorage.NavUpdateEntry[] memory);
	function getCurrentPendingWithdrawalBal() external view returns (uint256);
	function getCurrentPendingDepositBal() external view returns (uint256);
	function getFundStartTime() external view returns (uint256);
	function totalNAV() external view returns (uint256);
}