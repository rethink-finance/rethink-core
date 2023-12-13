// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorageFunctions.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


abstract contract NAVIlliquid {
	function illiquidCalculation(IGovernableFundStorage.NAVIlliquidUpdate[] calldata illiquid, address safe, address fund, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex) external view returns (uint256) {
		//TODO: need to handle decimals and conversion to base currency
		uint256 illiquidSum = 0;

		uint256 fundDecimals = IERC20Metadata(IGovernableFundStorageFunctions(fund).getFundSettings().baseToken).decimals();
		
		for(uint i=0;i<illiquid.length;i++) {
			IGovernableFundStorage.NAVIlliquidUpdate memory illiquidVal = illiquid[i];

			if (isPastNAVUpdate == true){
				illiquidVal  = IGovernableFundStorageFunctions(fund).getNavEntry(pastNAVUpdateIndex)[pastNAVUpdateEntryIndex].illiquid[illiquid[i].pastNAVUpdateIndex];
				//pastIlliquid[illiquid[i].pastNAVUpdateIndex];
			}
			if (illiquidVal.isNFT == true) {
				if (illiquidVal.nftType == IGovernableFundStorage.NAVNFTType.ERC1155){
		        	illiquidSum += (illiquidVal.baseCurrencySpent * IERC721(illiquidVal.tokenAddress).balanceOf(safe)) / (10**fundDecimals);
		        } else if (illiquidVal.nftType == IGovernableFundStorage.NAVNFTType.ERC721){
		        	illiquidSum += (illiquidVal.baseCurrencySpent * IERC1155(illiquidVal.tokenAddress).balanceOf(safe,illiquidVal.nftIndex)) / (10**fundDecimals);
		        }
			} else {
				illiquidSum += (illiquidVal.baseCurrencySpent * IERC20(illiquidVal.tokenAddress).balanceOf(safe)) / (10**fundDecimals);
			}
		}

		return illiquidSum;
	}
}