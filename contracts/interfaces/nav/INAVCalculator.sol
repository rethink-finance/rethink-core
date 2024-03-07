// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../fund/IGovernableFundStorage.sol";


interface INAVCalculator {
	function liquidCalculation(IGovernableFundStorage.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex) external returns (uint256);
	function composableCalculation(IGovernableFundStorage.NAVComposableUpdate[] calldata composable, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex) external returns (int256);
	function nftCalculation(IGovernableFundStorage.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex) external returns (int256);
	function illiquidCalculation(IGovernableFundStorage.NAVIlliquidUpdate[] calldata illiquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex) external returns (uint256);
	function getNAVIlliquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] calldata);
	function getNAVLiquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] calldata);
	function getNAVComposableCache(address fund, uint256 navEntryIndex) external view returns (int256[]  calldata);
	function getNAVNFTCache(address fund, uint256 navEntryIndex) external view returns (int256[] calldata);
}