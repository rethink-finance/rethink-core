// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorageFunctions.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";

abstract contract NAVLiquid {

	function liquidCalculation(IGovernableFundStorage.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex, address pastNAVUpdateEntryFundAddress) external returns (uint256) {
		//TODO: need to make sure it returns in nav base token denomination
		//TODO: need to make sure this can support the popular dex/aggregators abis
		uint256 liquidSum = 0;
		uint256[] memory cachedIndexValue = new uint256[](liquid.length);
		for(uint i=0;i<liquid.length;i++) {

			IGovernableFundStorage.NAVLiquidUpdate memory liquidVal = liquid[i];
			if (isPastNAVUpdate == true){
				liquidVal  = IGovernableFundStorageFunctions(pastNAVUpdateEntryFundAddress).getNavEntry(pastNAVUpdateIndex)[pastNAVUpdateEntryIndex].liquid[liquid[i].pastNAVUpdateIndex];
				//pastLiquid[liquid[i].pastNAVUpdateIndex];
			}

			//querying swap price;
			uint256 normedRetVal = querySwapPriceData(liquidVal, safe);
			liquidSum += normedRetVal;
			cachedIndexValue[i] = normedRetVal;
		}
        cacheLiquidCalculation(cachedIndexValue, fund, navEntryIndex);
		return liquidSum;
	}

	function querySwapPriceData(IGovernableFundStorage.NAVLiquidUpdate memory liquidVal, address safe) private view returns (uint256) {
		//querying swap price;
		bytes memory swapPriceData;
		bool success;
		uint256 price;
		if (liquidVal.tokenPair != address(0)) {
			IUniswapV2Pair _pair = IUniswapV2Pair(liquidVal.tokenPair);

			(,,uint32 blockTimestampLast) = _pair.getReserves();
			uint256 price0CumulativeLast = _pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
       	 	uint256 price1CumulativeLast = _pair.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        	(address token0, ) = (_pair.token0(), _pair.token1());
        	
        	uint16 _index = liquidVal.assetTokenAddress == token0 ? 0 : 1;
        	(uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(liquidVal.tokenPair);
	        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        	uint256 priceCumulative = _index == 0 ? price0Cumulative : price1Cumulative;

        	price = ((priceCumulative - (_index == 0 ? price0CumulativeLast : price0CumulativeLast)) / timeElapsed) * 1e8 / 2**112;
        	success = true;
		} else {
			(success, swapPriceData) = liquidVal.aggregatorAddress.staticcall(liquidVal.functionSignatureWithEncodedInputs);
			require(swapPriceData.length > 0, "bad return data");

		}
		require(success == true, "remote call failed");

		if (liquidVal.isReturnArray == false) {
			//price = abi.decode(swapPriceData, (uint256));
		} else {
			uint256[] memory priceDataDecoded = abi.decode(swapPriceData, (uint256[]));
			price = priceDataDecoded[liquidVal.returnIndex];
		}

		return price * IERC20(liquidVal.assetTokenAddress).balanceOf(safe) / (10 ** IERC20Metadata(liquidVal.assetTokenAddress).decimals());
	}

	function cacheLiquidCalculation(uint256[] memory data, address fund, uint256 navEntryIndex) virtual internal;
}