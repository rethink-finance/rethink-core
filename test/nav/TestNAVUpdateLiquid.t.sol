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
	uint256 TS_OFFSET = 171774987;

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
		//lv.tp = address(new MockUniV2Pair(lv.t1, lv.t2));

		lv.tp = this.deployUNIV2Pool(lv.t1, lv.t2);

		/*
			struct NAVLiquidUpdate {
			address tokenPair;
			address aggregatorAddress;
			bytes functionSignatureWithEncodedInputs;
			address assetTokenAddress;
			address nonAssetTokenAddress;
			bool isReturnArray;
			uint256 returnLength;
			uint256 returnIndex;
			uint256 pastNAVUpdateIndex;
		}
		*/

		liquid[0] = IGovernableFundStorage.NAVLiquidUpdate(
			lv.tp,
			address(0),
			"0x",//functionSignatureWithEncodedInputs
			lv.t1,
			lv.t2,
			false,
			0,
			0,
			0
		);

		//function liquidCalculationReadOnly(IGovernableFundStorage.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex, address pastNAVUpdateEntryFundAddress) external view returns (uint256);


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


		navEntries[0].entryType = IGovernableFundStorage.NavUpdateType.NAVLiquidUpdateType;
		navEntries[0].liquid  = liquid;
		navEntries[0].isPastNAVUpdate = false;
		navEntries[0].pastNAVUpdateIndex = 0;
		navEntries[0].pastNAVUpdateEntryIndex = 0;
		navEntries[0].description = "Mock Token Pair Price";

		uint256 lc = INAVCalculator(bv.navcalcbp).liquidCalculation(
			navEntries[0].liquid,
			settings.safe,
			fundAddr,
			0,
			navEntries[0].isPastNAVUpdate,
			navEntries[0].pastNAVUpdateIndex,
			navEntries[0].pastNAVUpdateEntryIndex,
			fundAddr
		);

		/*
			    │   │   ├─ [197] MockUniV2Pair::getReserves() [staticcall]
    │   │   │   └─ ← [Return] 10000000000000000000 [1e19], 3000000000000000000 [3e18], 1
    │   │   ├─ [203] MockUniV2Pair::price0CumulativeLast() [staticcall]
    │   │   │   └─ ← [Return] 1000000000000000000 [1e18]
    │   │   ├─ [236] MockUniV2Pair::price1CumulativeLast() [staticcall]
    │   │   │   └─ ← [Return] 10000000000000000001000000000000000000 [1e37]
    │   │   ├─ [320] MockUniV2Pair::token0() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0xDA5A5ADC64C8013d334A0DA9e711B364Af7A4C2d]
    │   │   ├─ [397] MockUniV2Pair::token1() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0x886D6d1eB8D415b00052828CD6d5B321f072073d]
    │   │   ├─ [203] MockUniV2Pair::price0CumulativeLast() [staticcall]
    │   │   │   └─ ← [Return] 1000000000000000000 [1e18]
    │   │   ├─ [236] MockUniV2Pair::price1CumulativeLast() [staticcall]
    │   │   │   └─ ← [Return] 10000000000000000001000000000000000000 [1e37]
    │   │   ├─ [197] MockUniV2Pair::getReserves() [staticcall]
    │   │   │   └─ ← [Return] 10000000000000000000 [1e19], 3000000000000000000 [3e18], 1
    │   │   └─ ← [Revert] panic: division or modulo by zero (0x12)
    │   └─ ← [Revert] panic: division or modulo by zero (0x12)
    └─ ← [Revert] panic: division or modulo by zero (0x12)


		*/

		console.logUint(lc);

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries,
            lv.targets,
            true
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
		vm.warp(block.timestamp + TS_OFFSET + 2);
        vm.roll(block.number + TS_OFFSET + 2);
        a.voteYay(gov, proposalId);
        vm.warp(block.timestamp + TS_OFFSET + 85000);
        vm.roll(block.number + TS_OFFSET + 85000);
	}
}