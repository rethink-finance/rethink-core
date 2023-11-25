// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorage.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";

abstract contract NAVLiquid {
	function liquidCalculation(IGovernableFundStorage.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFundStorage.NAVLiquidUpdate[] calldata pastLiquid) external returns (uint256) {
		//TODO: need to make sure it returns in nav base token denomination
		//TODO: need to make sure this can support the popular dex/aggregators abis
		uint256 liquidSum = 0;
		uint256[] memory cachedIndexValue = new uint256[](liquid.length);
		for(uint i=0;i<liquid.length;i++) {

			IGovernableFundStorage.NAVLiquidUpdate memory liquidVal = liquid[i];
			if (isPastNAVUpdate == true){
				liquidVal  = pastLiquid[liquid[i].pastNAVUpdateIndex];
			}

			//querying swap price;
			uint256 price  = querySwapPriceData(liquidVal);			
			uint256 normedRetVal = price * IERC20(liquidVal.assetTokenAddress).balanceOf(safe) / (10 ** IERC20Metadata(liquidVal.assetTokenAddress).decimals());
			liquidSum += normedRetVal;
			cachedIndexValue[i] = normedRetVal;
		}
        cacheLiquidCalculation(cachedIndexValue, fund, navEntryIndex);
		return liquidSum;
	}

	function querySwapPriceData(IGovernableFundStorage.NAVLiquidUpdate memory liquidVal) private view returns (uint256 price) {
		//querying swap price;
		bytes memory swapPriceData;
		bool success;
		if (liquidVal.tokenPair != address(0)) {
			//(success, swapPriceData) = liquidVal.tokenPair.staticcall(liquidVal.functionSignatureWithEncodedInputs);
			IUniswapV2Pair _pair = IUniswapV2Pair(liquidVal.tokenPair);
        	(address token0, ) = (_pair.token0(), _pair.token1());
        	uint16 _index = liquidVal.assetTokenAddress == token0 ? 0 : 1;
        	(uint256 price0Cumulative, uint256 price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(liquidVal.tokenPair);
        	uint256 priceCumulative = _index == 0 ? price0Cumulative : price1Cumulative;
        	price = (priceCumulative * 1e8) / 2**112;
        	success = true;

		} else {
			(success, swapPriceData) = liquidVal.aggregatorAddress.staticcall(liquidVal.functionSignatureWithEncodedInputs);
		}
		require(success == true, "remote call failed");

		if (liquidVal.isReturnArray == false) {
			//price = abi.decode(swapPriceData, (uint256));
		} else {
			uint256[] memory priceDataDecoded = abi.decode(swapPriceData, (uint256[]));
			price = priceDataDecoded[liquidVal.returnIndex];
		}
	}

	function cacheLiquidCalculation(uint256[] memory data, address fund, uint256 navEntryIndex) virtual internal;
}