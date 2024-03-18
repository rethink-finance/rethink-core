// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorageFunctions.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

abstract contract NAVNft {
	function nftCalculation(IGovernableFundStorage.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, uint256 pastNAVUpdateIndex, uint256 pastNAVUpdateEntryIndex, address pastNAVUpdateEntryFundAddress) external returns (int256) {
		//TODO: need to handle decimals and conversion to base currency
		//TODO: assumes chainlink

		int256 nftSum = 0;
		int256[] memory cachedIndexValue = new int256[](nft.length);
		for(uint i=0;i<nft.length;i++) {

			IGovernableFundStorage.NAVNFTUpdate memory nftVal = nft[i];
			if (isPastNAVUpdate == true){
				nftVal = IGovernableFundStorageFunctions(pastNAVUpdateEntryFundAddress).getNavEntry(pastNAVUpdateIndex)[pastNAVUpdateEntryIndex].nft[nft[i].pastNAVUpdateIndex];
				//pastNft[nft[i].pastNAVUpdateIndex];
			}

	        int256 normedRetVal = proccessFloorPrice(nftVal, safe);
	        nftSum += normedRetVal;

			cachedIndexValue[i] = normedRetVal;
	    }
	    cacheNFTCalculation(cachedIndexValue,fund,navEntryIndex);
	    return nftSum;
	}

	function proccessFloorPrice(IGovernableFundStorage.NAVNFTUpdate memory nftVal, address safe) private returns (int256) {
		AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(nftVal.oracleAddress);

		(
            /*uint80 roundID*/,
            int nftFloorPrice,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = nftFloorPriceFeed.latestRoundData();

		if (nftVal.nftType == IGovernableFundStorage.NAVNFTType.ERC721){
        	return nftFloorPrice * int256(IERC721(nftVal.nftAddress).balanceOf(safe));
        } else if (nftVal.nftType == IGovernableFundStorage.NAVNFTType.ERC1155){
        	return nftFloorPrice * int256(IERC1155(nftVal.nftAddress).balanceOf(safe, nftVal.nftIndex));
        }
	}

	function cacheNFTCalculation(int256[] memory data, address fund, uint256 navEntryIndex) virtual internal;
}
