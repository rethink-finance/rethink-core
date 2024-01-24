// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestNAVUpdateIlliquid is Base {
	function testIlliquidCalculation() public {
		address[] memory allowedDepositAddrs;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (bool success, bytes memory data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);

		address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        /*

        struct NAVIlliquidUpdate {
			uint256 baseCurrencySpent;
			uint256 amountAquiredTokens;
			address tokenAddress;
			bool isNFT;
			string[] otcTxHashes;
			NAVNFTType nftType;
			uint256 nftIndex;
			uint256 pastNAVUpdateIndex;
		}

		enum NAVNFTType {
			ERC1155,
			ERC721,
			NONE
		}

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

		//TODO: set up nav type with mock illiquid data

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

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );
	}	
}