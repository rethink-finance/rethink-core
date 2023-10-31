// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorPreventLateQuorumUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";


contract RethinkFundGovernor is 
	GovernorUpgradeable,
	GovernorCountingSimpleUpgradeable,
	GovernorVotesUpgradeable,
	GovernorVotesQuorumFractionUpgradeable,
	GovernorPreventLateQuorumUpgradeable,
	GovernorTimelockControlUpgradeable
{
	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
	function initialize(IVotesUpgradeable _token, string calldata _govName) external initializer {
		__GovernorVotes_init(_token);
		__Governor_init(string(abi.encodePacked("Rethink Governor: ", _govName)));
		__GovernorVotesQuorumFraction_init(10);//10 percent quorum
		__GovernorPreventLateQuorum_init(86400); //1 day in seconds
	}

	function votingDelay() public pure override returns (uint256) {
        return 7200; // 1 day
    }

    function votingPeriod() public pure override returns (uint256) {
        return 50400; // 1 week
    }

    // The functions below are overrides required by Solidity.

    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason,
        bytes memory params
    ) internal override(GovernorUpgradeable, GovernorPreventLateQuorumUpgradeable) returns (uint256) {
        return super._castVote(proposalId, account, support, reason, params);
    }

    function proposalDeadline(uint256 proposalId) public view override(GovernorUpgradeable, GovernorPreventLateQuorumUpgradeable, IGovernorUpgradeable) returns (uint256) {
        return super.proposalDeadline(proposalId);
    }

    function state(
        uint256 proposalId
    ) public view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (ProposalState) {
        return super.state(proposalId);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (address) {
        return super._executor();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(GovernorTimelockControlUpgradeable, GovernorUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
