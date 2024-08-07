// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "./NAVLiquid.sol";
import "./NAVIlliquid.sol";
import "./NAVComposable.sol";
import "./NAVNft.sol";

contract NAVCalculator is NAVLiquid, NAVIlliquid, NAVComposable, NAVNft {
	
	struct NAVInternalCacheType {
		uint256 baseAssetOIVBal;
		uint256 baseAssetSafeBal;
		uint256 feeBal;
		uint256 totalNAV;
	}
	
	mapping(address => mapping(uint256 => uint256[])) liquidCache;
	mapping(address => mapping(uint256 => int256[])) composableCache;
	mapping(address => mapping(uint256 => int256[])) NFTCache;
	mapping(address => mapping(uint256 => uint256[])) illiquidCache;
	mapping(address => mapping(uint256 => NAVInternalCacheType)) NAVInternalCache;
	
	function cacheIlliquidCalculation(uint256[] memory data, address fund, uint256 navEntryIndex) override internal {
		require(msg.sender == fund, "not fund");
		illiquidCache[fund][navEntryIndex] = data;
	}
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

	function cacheNAVParts(uint256[] calldata data, address fund, uint256 navEntryIndex) external {
		require(msg.sender == fund, "not fund");
		require(data.length == 4, "bad dims");
		NAVInternalCache[fund][navEntryIndex] = NAVInternalCacheType(data[0], data[1], data[2], data[3]);
	}

	function getNAVIlliquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] memory) {
		return illiquidCache[fund][navEntryIndex];
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

	function getNAVParts(address fund, uint256 navEntryIndex) external view returns (NAVInternalCacheType memory) {
		return NAVInternalCache[fund][navEntryIndex];
	}
}