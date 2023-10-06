pragma solidity ^0.8.17;

import "./NAVLiquid.sol";
import "./NAVIlliquid.sol";
import "./NAVComposable.sol";
import "./NAVNft.sol";

contract NAVCalculator is NAVLiquid, NAVIlliquid, NAVComposable, NAVNft {
	mapping(address => mapping(uint256 => uint256[])) liquidCache;
	mapping(address => mapping(uint256 => int256[])) composableCache;
	mapping(address => mapping(uint256 => int256[])) NFTCache;
	function cacheLiquidCalculation(uint256[] memory data, address fund, uint256 navEntryIndex) internal {
		liquidCache[fund][navEntryIndex] = data;
	}

	function cacheComposableCache(int256[] memory data, address fund, uint256 navEntryIndex) internal {
		composableCache[fund][navEntryIndex] = data;
	}

	function cacheNFTCalculation(int256[] memory data, address fund, uint256 navEntryIndex) internal {
		NFTCache[fund][navEntryIndex] = data;
	}
}