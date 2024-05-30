// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "../common/mock/MockAggregatorV3Interface.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestNAVUpdateNFT is Base {
	function testNAVNftCalculation() public {
		address[] memory allowedDepositAddrs;
        address fundAddr = this.createTestFund(address(this), allowedDepositAddrs, address(0));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));

		address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;
		
		address nftOracle = address(new MockAggregatorV3Interface());		
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries;

		IGovernableFundStorage.NAVNFTUpdate[] memory nft;
		//NOTE: may want to create a fake nft?

		nft[0] = IGovernableFundStorage.NAVNFTUpdate(
			nftOracle,
			address(0),
			IGovernableFundStorage.NAVNFTType.NONE,
			0,
			0
		);

		navEntries[0].entryType = IGovernableFundStorage.NavUpdateType.NAVNFTUpdateType;
		navEntries[0].nft  = nft;
		navEntries[0].isPastNAVUpdate = false;
		navEntries[0].pastNAVUpdateIndex = 0;
		navEntries[0].pastNAVUpdateEntryIndex = 0;

        vm.warp(block.timestamp + 85000);

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries
        );

        bytes[] memory calldatas;
        calldatas[0] = computeNavUpdate;
        string memory description = "testNftCalculation";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );
	}
}