pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFund.sol";

abstract contract NAVNft {
	/*
		Calcuation logic will:
					Check that token represented in swap holding token (in safe)
					Query floor price (denominated in base token?) against chainlink oracle


		Chainlink https://docs.chain.link/data-feeds/nft-floor-price/addresses 
	*/
	function nftCalculation(IGovernableFund.NAVNFTUpdate[] calldata nft, address safe) external view returns (uint256) {

	}
}