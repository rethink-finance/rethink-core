// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


abstract contract NAVIlliquid {
	function illiquidCalculation(IGovernableFundStorage.NAVIlliquidUpdate[] calldata illiquid, address safe, bool isPastNAVUpdate, IGovernableFundStorage.NAVIlliquidUpdate[] calldata pastIlliquid) external view returns (uint256) {
		//TODO: need to handle decimals and conversion to base currency
		uint256 illiquidSum = 0;
		for(uint i=0;i<illiquid.length;i++) {
			IGovernableFundStorage.NAVIlliquidUpdate memory illiquidVal = illiquid[i];

			if (isPastNAVUpdate == true){
				illiquidVal  = pastIlliquid[illiquid[i].pastNAVUpdateIndex];
			}
			if (illiquidVal.isNFT == true) {
				if (illiquidVal.nftType == IGovernableFundStorage.NAVNFTType.ERC1155){
		        	illiquidSum += illiquidVal.baseCurrencySpent * IERC721(illiquidVal.tokenAddress).balanceOf(safe);
		        } else if (illiquidVal.nftType == IGovernableFundStorage.NAVNFTType.ERC721){
		        	illiquidSum += illiquidVal.baseCurrencySpent * IERC1155(illiquidVal.tokenAddress).balanceOf(safe,illiquidVal.nftIndex);
		        }
			} else {
				illiquidSum += illiquidVal.baseCurrencySpent * IERC20(illiquidVal.tokenAddress).balanceOf(safe);
			}
		}

		return illiquidSum;
	}
}