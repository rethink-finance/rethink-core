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
	GovernorPreventLateQuorumUpgradeable
{
    uint256 _votingDelay;
    uint256 _votingPeriod;
    uint256 _proposalThreshold;
	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    //function initialize(IVotesUpgradeable _token, string calldata _govName) external initializer {
    
    function initialize(IVotesUpgradeable _token, string calldata _govName, uint256 quorumFraction, uint256 lateQuorum, uint256 vDelay, uint256 vPeriod, uint256 proposalThreshold) external initializer {
		__GovernorVotes_init(_token);
		__Governor_init(string(abi.encodePacked("Rethink Governor: ", _govName)));
        //__GovernorVotesQuorumFraction_init(10);//10 percent quorum
        __GovernorVotesQuorumFraction_init(quorumFraction);//10 percent quorum
        //__GovernorPreventLateQuorum_init(86400); //1 day in seconds
        __GovernorPreventLateQuorum_init(uint64(lateQuorum)); //1 day in seconds
        _votingDelay = vDelay;
        _votingPeriod = vPeriod;
        _proposalThreshold = proposalThreshold;//The number of votes required in order for a voter to become a proposer"_.
	}

    /**
     * @dev Part of the Governor Bravo's interface: _"The number of votes required in order for a voter to become a proposer"_.
     */
    function proposalThreshold() public view override returns (uint256) {
        return _proposalThreshold;
    }

	function votingDelay() public view override returns (uint256) {
        //return 60;//1 min 7200; // 1 day
        return _votingDelay; //seconds
    }

    function votingPeriod() public view override returns (uint256) {
        //return 60*30;// 30 min 50400; // 1 week
        return _votingPeriod; //seconds
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

    function proposalDeadline(uint256 proposalId) public view override(GovernorUpgradeable, GovernorPreventLateQuorumUpgradeable) returns (uint256) {
        return super.proposalDeadline(proposalId);
    }

    function state(
        uint256 proposalId
    ) public view override(GovernorUpgradeable) returns (ProposalState) {
        return super.state(proposalId);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable) {
        string memory errorMessage = "Governor: call reverted without message";
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            AddressUpgradeable.verifyCallResult(success, returndata, errorMessage);
        }
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(GovernorUpgradeable) returns (address) {
        return address(this);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(GovernorUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
