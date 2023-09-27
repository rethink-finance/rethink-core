pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVLiquid {
	
	/*

		Calculation logic will:
					Check that tokens represented in swap match base currency token and holding token
					Query the token pair function or aggregator function for swap price (denominated in base token?)

		struct NAVLiquidUpdate {
			address tokenPair;
			address aggregatorAddress;
			bytes functionSignatureWithEncodedInputes;
			address assetTokenAddress;
			address nonAssetTokenAddress;
			bool isReturnArray;
			uint256 returnLength;
			uint256 returnIndex;
		}
	*/

	function liquidCalculation(IGovernableFund.NAVLiquidUpdate[] calldata liquid, address safe) external view returns (uint256) {
		//TODO: need to make sure it returns in nav base token denomination
		//TODO: need to make sure this can support the popular dex/aggregators abis
		uint256 liquidSum = 0;
		for(uint i=0;i<liquid.length;i++) {
			//querying swap price;
			bytes memory swapPriceData;

			if (liquid[i].tokenPair != address(0)) {
				(, swapPriceData) = liquid[i].tokenPair.staticcall(liquid[i].functionSignatureWithEncodedInputes);
			} else {
				(, swapPriceData) = liquid[i].aggregatorAddress.staticcall(liquid[i].functionSignatureWithEncodedInputes);
			}

			uint256 price;
			if (liquid[i].isReturnArray == false) {
				price = abi.decode(swapPriceData, (uint256));
			} else {
				uint256[] memory priceDataDecoded = abi.decode(swapPriceData, (uint256[]));
				price = priceDataDecoded[liquid[i].returnIndex];
			}
			liquidSum += price * IERC20(liquid[i].assetTokenAddress).balanceOf(safe) / (10 ** IERC20Metadata(liquid[i].assetTokenAddress).decimals());
		}

		return liquidSum;
	}
}