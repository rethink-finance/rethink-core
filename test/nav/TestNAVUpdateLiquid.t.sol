// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "../common/mock/MockUniV2Pair.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestNAVUpdateLiquid is Base {

	function testNAVLiquidCalculation() public {
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

		address tokenPair = address(new MockUniV2Pair());
		bytes memory functionSignatureWithEncodedInputs;
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries;
		IGovernableFundStorage.NAVLiquidUpdate[] memory liquid;

		liquid[0] = IGovernableFundStorage.NAVLiquidUpdate(
			tokenPair,
			address(0),
			functionSignatureWithEncodedInputs,
			address(0),
			address(0),
			false,
			0,
			0,
			0
		);

		navEntries[0].entryType = IGovernableFundStorage.NavUpdateType.NAVLiquidUpdateType;
		navEntries[0].liquid  = liquid;
		navEntries[0].isPastNAVUpdate = false;
		navEntries[0].pastNAVUpdateIndex = 0;
		navEntries[0].pastNAVUpdateEntryIndex = 0;
		navEntries[0].description = "Mock Token Pair Price";

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries
        );

        bytes[] memory calldatas;
        calldatas[0] = computeNavUpdate;
        string memory description = "testLiquidCalculation";
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