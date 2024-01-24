// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract MockUniV2Pair {
	//NOTE: for nav liquid
	
	function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = 1;
        _reserve1 = 1;
        _blockTimestampLast = uint32(block.timestamp);
    }

	function price0CumulativeLast() external view returns (uint256) {
		return 0;
	}

	function price1CumulativeLast() external view returns (uint256) {
		return 0;
	}

	function token0() external view returns (address) {
		return address(0);
	}

	function token1() external view returns (address) {
		return address(0);		
	}
}