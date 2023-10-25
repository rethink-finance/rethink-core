// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../fund/IGovernableFundStorage.sol";


interface INAVCalculator {
	function liquidCalculation(IGovernableFundStorage.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFundStorage.NAVLiquidUpdate[] calldata pastLiquid) external view returns (uint256);
	function composableCalculation(IGovernableFundStorage.NAVComposableUpdate[] calldata composable, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFundStorage.NAVComposableUpdate[] calldata pastComposable) external view returns (uint256);
	function nftCalculation(IGovernableFundStorage.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFundStorage.NAVNFTUpdate[] calldata pastNft) external view returns (uint256);
	function illiquidCalculation(IGovernableFundStorage.NAVIlliquidUpdate[] calldata illiquid, address safe, bool isPastNAVUpdate, IGovernableFundStorage.NAVIlliquidUpdate[] calldata pastIlliquid) external view returns (uint256);
	function getNAVLiquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] calldata);
	function getNAVComposableCache(address fund, uint256 navEntryIndex) external view returns (int256[]  calldata);
	function getNAVNFTCache(address fund, uint256 navEntryIndex) external view returns (int256[] calldata);
}