// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVLiquid {
	function liquidCalculation(IGovernableFund.NAVLiquidUpdate[] calldata liquid, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFund.NAVLiquidUpdate[] calldata pastLiquid) external returns (uint256) {
		//TODO: need to make sure it returns in nav base token denomination
		//TODO: need to make sure this can support the popular dex/aggregators abis
		uint256 liquidSum = 0;
		uint256[] memory cachedIndexValue = new uint256[](liquid.length);
		for(uint i=0;i<liquid.length;i++) {

			IGovernableFund.NAVLiquidUpdate memory liquidVal = liquid[i];
			if (isPastNAVUpdate == true){
				liquidVal  = pastLiquid[liquid[i].pastNAVUpdateIndex];
			}

			//querying swap price;
			uint256 price  = querySwapPriceData(liquidVal);			
			uint256 normedRetVal = price * IERC20(liquidVal.assetTokenAddress).balanceOf(safe) / (10 ** IERC20Metadata(liquidVal.assetTokenAddress).decimals());
			liquidSum += normedRetVal;
			cachedIndexValue[i] = normedRetVal;
		}
		bytes memory cacheLiquidCalculation = abi.encodeWithSelector(
            bytes4(keccak256("cacheLiquidCalculation(uint256[],address,uint256)")),
            cachedIndexValue,
            fund,
            navEntryIndex
        );
        (bool passed,) = address(this).delegatecall(cacheLiquidCalculation);
        require(passed == true, "failed nav cache");
		return liquidSum;
	}

	function querySwapPriceData(IGovernableFund.NAVLiquidUpdate memory liquidVal) private view returns (uint256 price) {
		//querying swap price;
		bytes memory swapPriceData;
		bool success;
		if (liquidVal.tokenPair != address(0)) {
			(success, swapPriceData) = liquidVal.tokenPair.staticcall(liquidVal.functionSignatureWithEncodedInputs);
		} else {
			(success, swapPriceData) = liquidVal.aggregatorAddress.staticcall(liquidVal.functionSignatureWithEncodedInputs);
		}
		require(success == true, "remote call failed");

		if (liquidVal.isReturnArray == false) {
			price = abi.decode(swapPriceData, (uint256));
		} else {
			uint256[] memory priceDataDecoded = abi.decode(swapPriceData, (uint256[]));
			price = priceDataDecoded[liquidVal.returnIndex];
		}
	}
}