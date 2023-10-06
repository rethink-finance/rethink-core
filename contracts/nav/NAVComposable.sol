// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVComposable {
	function composableCalculation(IGovernableFund.NAVComposableUpdate[] calldata composable, address fund, uint256 navEntryIndex) external returns (int256) {
		//TODO: need to handle decimals and conversion to base currency

		int256 composableSum = 0;
		int256[] memory cachedIndexValue = new int256[](composable.length);
		for(uint i=0;i<composable.length;i++) {
			//querying swap price;
			(bool success, bytes memory rawProtcolData) = composable[i].remoteContractAddress.staticcall(composable[i].encodedFunctionSignatureWithInputs);

			require(success == true, "remote call failed");

			int256 retVal;
			if (composable[i].isReturnArray == false) {
				if (composable[i].returnValType == IGovernableFund.NAVComposableUpdateReturnType.UINT256) {
					retVal = int256(abi.decode(rawProtcolData, (uint256)));
				} else if (composable[i].returnValType == IGovernableFund.NAVComposableUpdateReturnType.INT256) {
					retVal = abi.decode(rawProtcolData, (int256));
				}
			} else {
				if (composable[i].returnValType == IGovernableFund.NAVComposableUpdateReturnType.UINT256) {
					uint256[] memory retValDataDecoded = abi.decode(rawProtcolData, (uint256[]));
					retVal = int256(retValDataDecoded[composable[i].returnValIndex]);
				} else if (composable[i].returnValType == IGovernableFund.NAVComposableUpdateReturnType.INT256) {
					int256[] memory retValDataDecoded = abi.decode(rawProtcolData, (int256[]));
					retVal = retValDataDecoded[composable[i].returnValIndex];
				}
			}
			int256 normedRetVal = retVal / int256(10 ** composable[i].normalizationDecimals);
			cachedIndexValue[i] = normedRetVal;
			composableSum += normedRetVal;
		}
		bytes memory cacheComposableCache = abi.encodeWithSelector(
            bytes4(keccak256("cacheComposableCache(int256[],address,uint256)")),
            cachedIndexValue,
            fund,
            navEntryIndex
        );
        (bool passed,) = address(this).delegatecall(cacheComposableCache);
        require(passed == true, "failed nav cache");
		return composableSum;
	}
}