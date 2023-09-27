pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVIlliquid {

	/*
		Calculation logic will:
					Check that balance at safe address of aquired token matches what fund manager inputs

	*/
	
	function illiquidCalculation() external view returns (uint256) {

	}
}