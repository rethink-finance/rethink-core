pragma solidity ^0.8.17;

import "../fund/IGovernableFund.sol";


interface INAVCalculator {
	function liquidCalculation(IGovernableFund.NAVLiquidUpdate[] calldata liquid, address safe) external view returns (uint256);
	function composableCalculation(IGovernableFund.NAVComposableUpdate[] calldata composable) external view returns (uint256);
	function nftCalculation(IGovernableFund.NAVNFTUpdate[] calldata nft, address safe) external view returns (uint256);
	function illiquidCalculation(IGovernableFund.NAVIlliquidUpdate[] calldata illiquid, address safe) external view returns (uint256);
}