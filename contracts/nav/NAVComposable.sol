pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVComposable {
	function composableCalculation(IGovernableFund.NAVComposableUpdate[] calldata composable) external view returns (int256) {
		//TODO: need to handle decimals and conversion to base currency

		int256 composableSum = 0;
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
			composableSum += retVal / int256(10 ** composable[i].normalizationDecimals);
		}

		return composableSum;

	}
}