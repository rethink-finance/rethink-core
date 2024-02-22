// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestNAVUpdateIlliquid is Base {
	function testNAVIlliquidCalculation() public {
		address[] memory allowedDepositAddrs;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (bool success, bytes memory data) = gff.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));

		address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;
		
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries;

		IGovernableFundStorage.NAVIlliquidUpdate[] memory illiquid;
		string[] memory otcTxHashes;

		illiquid[0] = IGovernableFundStorage.NAVIlliquidUpdate(
			1e8,
			1e18,
			address(0),
			false,
			otcTxHashes,
			IGovernableFundStorage.NAVNFTType.NONE,
			0,
			0
		);

		navEntries[0].entryType = IGovernableFundStorage.NavUpdateType.NAVLiquidUpdateType;
		navEntries[0].illiquid  = illiquid;
		navEntries[0].isPastNAVUpdate = false;
		navEntries[0].pastNAVUpdateIndex = 0;
		navEntries[0].pastNAVUpdateEntryIndex = 0;
		navEntries[0].description = "Mock OTC DEAL";

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries
        );

        bytes[] memory calldatas;
        calldatas[0] = computeNavUpdate;
        string memory description = "testIlliquidCalculation";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        vm.warp(block.timestamp + 85000);
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );
	}	
}