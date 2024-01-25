// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract MockAggregatorV3Interface {
	//NOTE: for nft

	function latestRoundData()
        external
        view
        returns
    (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
    	roundId = 1;
        answer = 1e18;
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = 1;
    }
}