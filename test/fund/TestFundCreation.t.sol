// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";

contract TestFundCreation is Base {
	
	function testFundCreationDefault() public {}

	function testFundCreationExternalERC20VotesCompatGov() public {}

	function testFundCreationExternalNonERC20VotesCompatGov() public {}

	function testFundCreationWhitelistDepositors() {}
}