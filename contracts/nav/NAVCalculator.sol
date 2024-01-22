// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "./NAVLiquid.sol";
import "./NAVIlliquid.sol";
import "./NAVComposable.sol";
import "./NAVNft.sol";

contract NAVCalculator is NAVLiquid, NAVIlliquid, NAVComposable, NAVNft {
	mapping(address => mapping(uint256 => uint256[])) liquidCache;
	mapping(address => mapping(uint256 => int256[])) composableCache;
	mapping(address => mapping(uint256 => int256[])) NFTCache;
	
	function cacheLiquidCalculation(uint256[] memory data, address fund, uint256 navEntryIndex) override internal {
		require(msg.sender == fund, "not fund");
		liquidCache[fund][navEntryIndex] = data;
	}

	function cacheComposableCache(int256[] memory data, address fund, uint256 navEntryIndex) override internal {
		require(msg.sender == fund, "not fund");
		composableCache[fund][navEntryIndex] = data;
	}

	function cacheNFTCalculation(int256[] memory data, address fund, uint256 navEntryIndex) override internal {
		require(msg.sender == fund, "not fund");
		NFTCache[fund][navEntryIndex] = data;
	}

	function getNAVLiquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] memory) {
		return liquidCache[fund][navEntryIndex];
	}

	function getNAVComposableCache(address fund, uint256 navEntryIndex) external view returns (int256[] memory) {
		return composableCache[fund][navEntryIndex];
	}

	function getNAVNFTCache(address fund, uint256 navEntryIndex) external view returns (int256[] memory) {
		return NFTCache[fund][navEntryIndex];
	}
}