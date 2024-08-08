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
        address fundAddr = this.createTestFund(address(this), allowedDepositAddrs, address(0));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));

		address[] memory targets = new address[](1);
        targets[0] = fundAddr;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
		
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries = new IGovernableFundStorage.NavUpdateEntry[](1);

		IGovernableFundStorage.NAVIlliquidUpdate[] memory illiquid = new IGovernableFundStorage.NAVIlliquidUpdate[](1);
		string[] memory otcTxHashes;

		illiquid[0] = IGovernableFundStorage.NAVIlliquidUpdate(
			1e8,
			1e18,
			address(new ERC20Mock(18,"FakeA")),
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

		//	function updateNav(NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, bool processWithdraw) public {


		address[] memory pastNAVUpdateEntryFundAddress = new address[](1);
		pastNAVUpdateEntryFundAddress[0] = fundAddr;

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries,
            pastNAVUpdateEntryFundAddress,
            true
        );

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = computeNavUpdate;
        string memory description = "testIlliquidCalculation";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        vm.warp(block.timestamp + 2);
        vm.roll(block.number + 2);

        bob.voteYay(settings.governor, proposalId);

        vm.warp(block.timestamp + 65);
        vm.roll(block.number + 65);
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );
	}	
}