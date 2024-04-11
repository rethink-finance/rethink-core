
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./IGovernableFundStorage.sol";

interface IGovernableFundFactory {
	struct GovernorParams {
		uint256 quorumFraction;
		uint256 lateQuorum;
		uint256 votingDelay;
		uint256 votingPeriod;
		uint256 proposalThreshold;
	}
	function registeredFundsData(uint256 start, uint256 end) external view returns (address[] memory, IGovernableFundStorage.Settings[] memory);
	function createFund(IGovernableFundStorage.Settings memory fundSettings, GovernorParams memory governorSettings, string memory _fundMetadata, uint256 _feePerformancePeriod, uint256 _feeManagePeriod) external returns (address);
}