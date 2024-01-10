// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";

contract TestFundCreation is Base {
	
	struct GovernorParams {
		uint256 quorumFraction;
		uint256 lateQuorum;
		uint256 votingDelay;
		uint256 votingPeriod;
		uint256 proposalThreshold;
	}
	
	function testFundCreationDefault() public {
		//function createFund(IGovernableFundStorage.Settings memory fundSettings, GovernorParams memory governorSettings, string memory _fundMetadata)

		IGovernableFundStorage.Settings memory fundSettings;
		GovernorParams memory governorSettings;
		string memory _fundMetadata = "{}";

		bytes memory gffCreateFund = abi.encodeWithSelector(
            bytes4(keccak256("createFund(IGovernableFundStorage.Settings, GovernorParams, string)")),
            fundSettings,
            governorSettings,
            _fundMetadata
        );
        (bool success,) = gffub.call(gffCreateFund);
        require(success == true, "fail gff createFund");
	}

	function testFundCreationExternalERC20VotesCompatGov() public {}

	function testFundCreationExternalNonERC20VotesCompatGov() public {}

	function testFundCreationWhitelistDepositors() public {}
}