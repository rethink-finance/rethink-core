// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";

interface IRethinkFundGovernor {
	function initialize(address _token, string calldata _govName, uint256 quorumFraction, uint256 lateQuorum, uint256 vDelay, uint256 vPeriod, uint256 proposalThreshold) external;
}