// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./IGovernableFundStorage.sol";

interface IGovernableFund {
	function initialize(string memory _name_, string memory _symbol_, IGovernableFundStorage.Settings calldata _fundSettings, address _navCalculatorAddress, address _fundDelgateCallFlowAddr, address fundDelgateCallNavAddress, string memory _fundMetadata, uint256 _feePerformancePeriod, uint256 _feeManagePeriod) external;
	function updateNav(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, bool processWithdraw) external;
	function getFundSettings() external view returns (IGovernableFundStorage.Settings memory);
	function valueOf(address ownr) external view returns (uint256);
    function totalNAV() external view returns (uint256);
}