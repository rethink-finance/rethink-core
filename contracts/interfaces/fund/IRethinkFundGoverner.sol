pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/utils/IVotes.sol";

interface IRethinkFundGoverner {
	function initialize(address _token, string calldata _govName) external;
}