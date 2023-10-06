pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

abstract contract NAVNft {
	function nftCalculation(IGovernableFund.NAVNFTUpdate[] calldata nft, address safe, address fund, uint256 navEntryIndex) external returns (int256) {
		//TODO: need to handle decimals and conversion to base currency

		int256 nftSum = 0;
		int256[] memory cachedIndexValue = new int256[](nft.length);
		for(uint i=0;i<nft.length;i++) {
			AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(nft[i].oracleAddress);

			(
	            /*uint80 roundID*/,
	            int nftFloorPrice,
	            /*uint startedAt*/,
	            /*uint timeStamp*/,
	            /*uint80 answeredInRound*/
	        ) = nftFloorPriceFeed.latestRoundData();

	        int256 normedRetVal;
	        if (nft[i].nftType == IGovernableFund.NAVNFTType.ERC1155){
	        	normedRetVal = nftFloorPrice * int256(IERC721(nft[i].nftAddress).balanceOf(safe));
	        	nftSum += normedRetVal;
	        } else if (nft[i].nftType == IGovernableFund.NAVNFTType.ERC721){
	        	normedRetVal = nftFloorPrice * int256(IERC1155(nft[i].nftAddress).balanceOf(safe, nft[i].nftIndex));
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
