// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../fund/IGovernableFund.sol";


interface INAVCalculator {
	function liquidCalculation(IGovernableFund.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFund.NAVLiquidUpdate[] calldata pastLiquid) external view returns (uint256);
	function composableCalculation(IGovernableFund.NAVComposableUpdate[] calldata composable, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFund.NAVComposableUpdate[] calldata pastComposable) external view returns (uint256);
	function nftCalculation(IGovernableFund.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFund.NAVNFTUpdate[] calldata pastNft) external view returns (uint256);
	function illiquidCalculation(IGovernableFund.NAVIlliquidUpdate[] calldata illiquid, address safe, bool isPastNAVUpdate, IGovernableFund.NAVIlliquidUpdate[] calldata pastIlliquid) external view returns (uint256);
	function getNAVLiquidCache(address fund, uint256 navEntryIndex) external view returns (uint256[] calldata);
	function getNAVComposableCache(address fund, uint256 navEntryIndex) external view returns (int256[]  calldata);
	function getNAVNFTCache(address fund, uint256 navEntryIndex) external view returns (int256[] calldata);
}