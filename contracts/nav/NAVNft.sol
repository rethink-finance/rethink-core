// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

abstract contract NAVNft {
	function nftCalculation(IGovernableFundStorage.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex, bool isPastNAVUpdate, IGovernableFundStorage.NAVNFTUpdate[] calldata pastNft) external returns (int256) {
		//TODO: need to handle decimals and conversion to base currency
		//TODO: assumes chainlink

		int256 nftSum = 0;
		int256[] memory cachedIndexValue = new int256[](nft.length);
		for(uint i=0;i<nft.length;i++) {

			IGovernableFundStorage.NAVNFTUpdate memory nftVal = nft[i];
			if (isPastNAVUpdate == true){
				nftVal = pastNft[nft[i].pastNAVUpdateIndex];
			}

			AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(nftVal.oracleAddress);

			(
	            /*uint80 roundID*/,
	            int nftFloorPrice,
	            /*uint startedAt*/,
	            /*uint timeStamp*/,
	            /*uint80 answeredInRound*/
	        ) = nftFloorPriceFeed.latestRoundData();

	        int256 normedRetVal;
	        if (nftVal.nftType == IGovernableFundStorage.NAVNFTType.ERC1155){
	        	normedRetVal = nftFloorPrice * int256(IERC721(nftVal.nftAddress).balanceOf(safe));
	        	nftSum += normedRetVal;
	        } else if (nftVal.nftType == IGovernableFundStorage.NAVNFTType.ERC721){
	        	normedRetVal = nftFloorPrice * int256(IERC1155(nftVal.nftAddress).balanceOf(safe, nftVal.nftIndex));
	        	nftSum += normedRetVal;
	        }
			cachedIndexValue[i] = normedRetVal;
	    }
	    bytes memory cacheNFTCalculation = abi.encodeWithSelector(
            bytes4(keccak256("cacheNFTCalculation(int256[],address,uint256)")),
            cachedIndexValue,
            fund,
            navEntryIndex
        );
        (bool passed,) = address(this).delegatecall(cacheNFTCalculation);
        require(passed == true, "failed nav cache");
	    return nftSum;
	}
}
