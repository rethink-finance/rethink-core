// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;


import "../interfaces/fund/IGovernableFundFactory.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "../interfaces/fund/IGovernableFundStorageFunctions.sol";

contract RethinkReader {
	address _governableFundFactory;
	address _nftCalculator;

	struct FundMetaData {
		uint256[] startTime;
		uint256[] totalNav;
		uint256[] totalDepositBal;

		uint256[] illiquidLen;
		uint256[] liquidLen;
		uint256[] nftLen;
		uint256[] composableLen;
	}

	struct FundNavData {
		uint256[][] illiquid;
		uint256[][] liquid;
		int256[][] nft;
		int256[][] composable;
	}

	constructor(address governableFundFactory, address nftCalculator) {
		_governableFundFactory = governableFundFactory;
		_nftCalculator = nftCalculator;
	}


	function getFundNavMetaData(address[] memory funds, uint256 navEntryIndex) external view returns (FundMetaData memory) {
		FundMetaData memory fd;

		uint256 arrayLen = funds.length;

		fd.startTime = new uint256[](arrayLen);
		fd.totalNav = new uint256[](arrayLen);
		fd.totalDepositBal = new uint256[](arrayLen);
		fd.illiquidLen  = new uint256[](arrayLen);
		fd.liquidLen  = new uint256[](arrayLen);
		fd.nftLen  = new uint256[](arrayLen);
		fd.composableLen  = new uint256[](arrayLen);

		for(uint i=0; i<arrayLen;i++) {
			bytes memory gfcall = abi.encodeWithSelector(
	            bytes4(keccak256("_navUpdateLatestIndex()"))
	        );
	        (bool success0, bytes memory data0) = funds[i].staticcall(gfcall);
	        require(success0 == true, "fail gf nav entry length");

	        uint256 lnIdx = abi.decode(data0, (uint256));

			fd.startTime[i] = IGovernableFundStorageFunctions(funds[i]).getFundStartTime();
			fd.totalNav[i] = IGovernableFundStorageFunctions(funds[i]).totalNAV();
			fd.totalDepositBal[i] = IGovernableFundStorageFunctions(funds[i])._totalDepositBal();
			fd.illiquidLen[i] = INAVCalculator(_nftCalculator).getNAVIlliquidCache(funds[i], lnIdx).length;
			fd.liquidLen[i] = INAVCalculator(_nftCalculator).getNAVLiquidCache(funds[i], lnIdx).length;
			fd.nftLen[i] = INAVCalculator(_nftCalculator).getNAVNFTCache(funds[i], lnIdx).length;
			fd.composableLen[i] = INAVCalculator(_nftCalculator).getNAVComposableCache(funds[i], lnIdx).length;
		}

		return fd;
	}

	function getNAVDataForFund(address fund) external view returns (FundNavData memory) {
		bytes memory gfcall = abi.encodeWithSelector(
            bytes4(keccak256("_navUpdateLatestIndex()"))
        );
        (bool success0, bytes memory data0) = fund.staticcall(gfcall);
        require(success0 == true, "fail gf nav entry length");

        uint256 navUpdateLatestIndex = abi.decode(data0, (uint256));

        FundNavData memory fd;

		fd.illiquid  = new uint256[][](navUpdateLatestIndex);
		fd.liquid  = new uint256[][](navUpdateLatestIndex);
		fd.nft  = new int256[][](navUpdateLatestIndex);
		fd.composable  = new int256[][](navUpdateLatestIndex);

        for(uint i=0; i<navUpdateLatestIndex;i++) {
			fd.illiquid[i] = INAVCalculator(_nftCalculator).getNAVIlliquidCache(fund, i);
			fd.liquid[i] = INAVCalculator(_nftCalculator).getNAVLiquidCache(fund, i);
			fd.nft[i] = INAVCalculator(_nftCalculator).getNAVNFTCache(fund, i);
			fd.composable[i] = INAVCalculator(_nftCalculator).getNAVComposableCache(fund, i);
		}

		return fd;
	}
}