// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorageFunctions.sol";

abstract contract NAVComposable {
	function composableCalculation(IGovernableFundStorage.NAVComposableUpdate[] calldata composable, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex, address pastNAVUpdateEntryFundAddress) external returns (int256) {

		int256 composableSum = 0;
		int256[] memory cachedIndexValue = new int256[](composable.length);
		for(uint i=0;i<composable.length;i++) {
			IGovernableFundStorage.NAVComposableUpdate memory composableVal = composable[i];

			if (isPastNAVUpdate == true){
				composableVal = IGovernableFundStorageFunctions(pastNAVUpdateEntryFundAddress).getNavEntry(pastNAVUpdateIndex)[pastNAVUpdateEntryIndex].composable[composable[i].pastNAVUpdateIndex];
				//pastComposable[composable[i].pastNAVUpdateIndex];
			}

			//querying swap price;
			(bool success, bytes memory rawProtcolData) = composableVal.remoteContractAddress.staticcall(composableVal.encodedFunctionSignatureWithInputs);

			require(success == true, "remote call failed");
			require(rawProtcolData.length > 0, "bad return data");
			
			int256 retVal;
			if (composableVal.isReturnArray == false) {
				if (composableVal.returnValType == IGovernableFundStorage.NAVComposableUpdateReturnType.UINT256) {
					retVal = int256(abi.decode(rawProtcolData, (uint256))) * ((composableVal.isNegative == true) ? -1 : int256(1)) ;
				} else if (composableVal.returnValType == IGovernableFundStorage.NAVComposableUpdateReturnType.INT256) {
					retVal = abi.decode(rawProtcolData, (int256)) * ((composableVal.isNegative == true) ? -1 : int256(1));
				}
			} else {
				if (composableVal.returnValType == IGovernableFundStorage.NAVComposableUpdateReturnType.UINT256) {
					uint256[] memory retValDataDecoded = abi.decode(rawProtcolData, (uint256[]));
					retVal = int256(retValDataDecoded[composableVal.returnValIndex]) * ((composableVal.isNegative == true) ? -1 : int256(1));
				} else if (composableVal.returnValType == IGovernableFundStorage.NAVComposableUpdateReturnType.INT256) {
					int256[] memory retValDataDecoded = abi.decode(rawProtcolData, (int256[]));
					retVal = retValDataDecoded[composableVal.returnValIndex] * ((composableVal.isNegative == true) ? -1 : int256(1));
				}
			}
			uint256 fundDecimals = IERC20Metadata(IGovernableFundStorageFunctions(fund).getFundSettings().baseToken).decimals();
			int256 normedRetVal;
			if (composableVal.normalizationDecimals >= fundDecimals) {
				normedRetVal = retVal / int256(10 ** (composableVal.normalizationDecimals - fundDecimals));
			} else {
				normedRetVal = retVal * int256(10 ** (fundDecimals - composableVal.normalizationDecimals));

			}
			cachedIndexValue[i] = normedRetVal;
			composableSum += normedRetVal;
		}

		cacheComposableCache(cachedIndexValue,fund,navEntryIndex);
		return composableSum;
	}

	function cacheComposableCache(int256[] memory data, address fund, uint256 navEntryIndex) virtual internal;

}