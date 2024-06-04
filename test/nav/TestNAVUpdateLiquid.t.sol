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

	struct LocalVars {
		address t1;
		address t2;
		address tp;
		address[] allowedDepositAddrs;
		address[] targets;
		uint256[] values;
		string description;
        bytes32 descriptionHash;
	}

	function testNAVLiquidCalculation() public {
		LocalVars memory lv;
        address fundAddr = this.createTestFund(address(this), lv.allowedDepositAddrs, address(0));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));

		lv.targets = new address[](1);
        lv.targets[0] = fundAddr;
        lv.values = new uint256[](1);
        lv.values[0] = 0;

		bytes memory functionSignatureWithEncodedInputs;
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries = new IGovernableFundStorage.NavUpdateEntry[](1);
		IGovernableFundStorage.NAVLiquidUpdate[] memory liquid = new IGovernableFundStorage.NAVLiquidUpdate[](1);

		//TODO: need to properly mock this

		lv.t1 = address(new ERC20Mock(18,"FakeA"));
		lv.t2 = address(new ERC20Mock(18,"FakeB"));
		lv.tp = address(new MockUniV2Pair(lv.t1, lv.t2));

		liquid[0] = IGovernableFundStorage.NAVLiquidUpdate(
			lv.tp,
			address(0),
			functionSignatureWithEncodedInputs,
			lv.t1,
			lv.t2,
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

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = computeNavUpdate;
        lv.description = "testLiquidCalculation";
        lv.descriptionHash = keccak256(abi.encodePacked(lv.description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	lv.targets,
        	lv.values,
        	calldatas,
        	lv.description
        );

        simulateVoteYayCycle(bob, settings.governor, proposalId);

        IGovernor(settings.governor).execute(
	        lv.targets,
	        lv.values,
	        calldatas,
	        lv.descriptionHash
	    );
	}

	function simulateVoteYayCycle(Agent a, address gov, uint256 proposalId) private {
		vm.warp(block.timestamp + 2);
        vm.roll(block.number + 2);
        a.voteYay(gov, proposalId);
        vm.warp(block.timestamp + 85000);
        vm.roll(block.number + 85000);
	}
}