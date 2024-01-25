// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract MockMetavaultReader {
	//NOTE: for composable
	function getPositions(address _vault, address _account, address[] calldata _collateralTokens, address[] calldata _indexTokens, bool[] calldata _isLong) external view returns(uint256[] memory) {
		uint256[9] memory output = [uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18),uint256(1e18)];
	}
}