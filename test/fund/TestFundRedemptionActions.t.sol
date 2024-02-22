// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";


contract TestFundRedemptionActions is Base {
	function testFundRedemptionRequest() public {
		//deposit

		address[] memory allowedDepositAddrs;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (bool success, bytes memory data) = gff.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
		//withdraw request
		bob.requestWithdraw(fundAddr, 10e18);

	}
	function testFundRedemptionRevoke() public {
		//deposit

		address[] memory allowedDepositAddrs;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (bool success, bytes memory data) = gff.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);

		//withdraw request
		//withdraw revoke

		bob.requestWithdraw(fundAddr, 10e18);
        bob.revokeWithdraw(fundAddr);
	}
	function testFundRedemption() public {
		//deposit

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
		
		//withdraw request
        bob.requestWithdraw(fundAddr, 5e18);


		address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        /*


        struct NavUpdateEntry {
			NavUpdateType entryType;
			NAVLiquidUpdate[] liquid;
			NAVIlliquidUpdate[] illiquid;
			NAVNFTUpdate[] nft;
			NAVComposableUpdate[] composable;
			bool isPastNAVUpdate;
			uint256 pastNAVUpdateIndex;
			uint256 pastNAVUpdateEntryIndex;
			string description;
		}


        */
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries;

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries
        );

        bytes[] memory calldatas;
        calldatas[0] = computeNavUpdate;
        string memory description = "testFundRedemption";
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

		//withdraw
        bob.withdraw(fundAddr);

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "zero bob balance after withdraw");
	}
}