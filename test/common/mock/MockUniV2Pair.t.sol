// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract MockUniV2Pair {
	//NOTE: for nav liquid
	address _t1;
	address _t0;

	constructor(address t0, address t1){
		_t0 = t0;
		_t1 = t1;		
	}
	
	function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = 10000000000000000000;
        _reserve1 = 3000000000000000000;
        _blockTimestampLast = uint32(block.timestamp);
    }

	function price0CumulativeLast() external view returns (uint256) {
		return 1000000000000000000;
	}

	function price1CumulativeLast() external view returns (uint256) {
		return 10000000000000000001000000000000000000;
	}

	function token0() external view returns (address) {
		return _t0;
	}

	function token1() external view returns (address) {
		return _t1;		
	}
}