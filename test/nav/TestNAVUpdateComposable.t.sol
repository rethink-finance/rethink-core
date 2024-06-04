// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "../common/mock/MockMetavaultReader.t.sol";

import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestNAVUpdateComposable is Base {

	function testNAVComposableCalculation() public {
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

		address mvreader = address(new MockMetavaultReader());		
		IGovernableFundStorage.NavUpdateEntry[] memory navEntries;
		bytes memory encodedFunctionSignatureWithInputs = generateProtocolEncodedBytes();

		IGovernableFundStorage.NAVComposableUpdate[] memory composable;

		composable[0] = IGovernableFundStorage.NAVComposableUpdate(
			mvreader,
			"getPositions(address,address,address[],address[],bool[])",
			encodedFunctionSignatureWithInputs,
			0,
			true,
			0,
			9,
			IGovernableFundStorage.NAVComposableUpdateReturnType.UINT256,
			0,
			false
		);

		navEntries[0].entryType = IGovernableFundStorage.NavUpdateType.NAVComposableUpdateType;
		navEntries[0].composable  = composable;
		navEntries[0].isPastNAVUpdate = false;
		navEntries[0].pastNAVUpdateIndex = 0;
		navEntries[0].pastNAVUpdateEntryIndex = 0;
		navEntries[0].description = "Mock Metavault Position";

        bytes memory computeNavUpdate = abi.encodeWithSelector(
            IGovernableFund.updateNav.selector,
            navEntries
        );

        bytes[] memory calldatas;
        calldatas[0] = computeNavUpdate;
        string memory description = "testComposableCalculation";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        bob.voteYay(settings.governor, proposalId);

        vm.warp(block.timestamp + 85000);
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );
	}

	function generateProtocolEncodedBytes() internal view returns (bytes memory) {
		address[] memory allowedTokens = new address[](1);
        address[] memory _collateralTokens = new address[](1);
        address[] memory _indexTokens = new address[](1);
        bool[] memory _isLong = new bool[](1);

		allowedTokens[0] = address(0);
		_collateralTokens[0] = address(0);
		_indexTokens[0] = address(0);
		_isLong[0] = true;

		bytes memory encodedFunctionSignatureWithInputs = abi.encodeWithSelector(
            MockMetavaultReader.getPositions.selector,
            address(0),
            address(this),
            _collateralTokens,
            _indexTokens,
            _isLong
        );

        return encodedFunctionSignatureWithInputs;
	}
}