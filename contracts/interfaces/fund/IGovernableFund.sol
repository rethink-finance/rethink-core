// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./IGovernableFundStorage.sol";

interface IGovernableFund {
	function initialize(string memory _name_, string memory _symbol_, IGovernableFundStorage.Settings calldata _fundSettings, address _navCalculatorAddress, address _fundDelgateCallFlowAddr, address fundDelgateCallNavAddress, string memory _fundMetadata) external;

	function getFundSettings() external view returns (IGovernableFundStorage.Settings memory);
}