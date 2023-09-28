pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";



abstract contract NAVNft {
	function nftCalculation(IGovernableFund.NAVNFTUpdate[] calldata nft, address safe) external view returns (int256) {
		//TODO: need to handle decimals and conversion to base currency

		int256 nftSum = 0;
		for(uint i=0;i<nft.length;i++) {
			AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(nft[i].oracleAddress);

			(
	            /*uint80 roundID*/,
	            int nftFloorPrice,
	            /*uint startedAt*/,
	            /*uint timeStamp*/,
	            /*uint80 answeredInRound*/
	        ) = nftFloorPriceFeed.latestRoundData();

	        if (nft[i].nftType == IGovernableFund.NAVNFTType.ERC1155){
	        	nftSum += nftFloorPrice * int256(IERC721(nft[i].nftAddress).balanceOf(safe));
	        } else if (nft[i].nftType == IGovernableFund.NAVNFTType.ERC721){
	        	nftSum += nftFloorPrice * int256(IERC1155(nft[i].nftAddress).balanceOf(safe, nft[i].nftIndex));
	        }
	    }

	    return nftSum;
	}
}
