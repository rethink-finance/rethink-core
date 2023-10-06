// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


abstract contract NAVIlliquid {
	function illiquidCalculation(IGovernableFund.NAVIlliquidUpdate[] calldata illiquid, address safe) external view returns (uint256) {
		//TODO: need to handle decimals and conversion to base currency
		uint256 illiquidSum = 0;
		for(uint i=0;i<illiquid.length;i++) {

			if (illiquid[i].isNFT == true) {
				if (illiquid[i].nftType == IGovernableFund.NAVNFTType.ERC1155){
		        	illiquidSum += illiquid[i].baseCurrencySpent * IERC721(illiquid[i].tokenAddress).balanceOf(safe);
		        } else if (illiquid[i].nftType == IGovernableFund.NAVNFTType.ERC721){
		        	illiquidSum += illiquid[i].baseCurrencySpent * IERC1155(illiquid[i].tokenAddress).balanceOf(safe, illiquid[i].nftIndex);
		        }
			} else {
				illiquidSum += illiquid[i].baseCurrencySpent * IERC20(illiquid[i].tokenAddress).balanceOf(safe);
			}
		}

		return illiquidSum;
	}
}