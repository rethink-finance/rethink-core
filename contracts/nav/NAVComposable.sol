pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVComposable {
	/*
		Calculation logic will:
					Do something like `address(_settings).staticcall(BYTES)`
					Where BYTES for a function with 3 inputs:
					-BYTES == abi.encodeWithSelector(
					 bytes4(keccak256("FUNCTION_SIGNATURE")),
					FUNCTION_INPUT_1,
					FUNCTION_INPUT_2,
					FUNCTION_INPUT_3
					)
					BYTES needs to be decoded with `abi.decode(BYTES, (TYPE)) or abi.decode(BYTES, (TYPE[])) or abi.decode(BYTES, (TYPE, TYPE, etc)) or abi.decode(BYTES, (TYPE[], TYPE[], etc))`
					Should return an integers that represents the value of the position
	*/
	function composableCalculation() external view returns (uint256) {

	}
}