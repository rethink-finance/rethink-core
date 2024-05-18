// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;


import "../interfaces/fund/IGovernableFundFactory.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "../interfaces/fund/IGovernableFundStorageFunctions.sol";

contract RethinkReader {
	address _governableFundFactory;
	address _navCalculator;

	struct FundMetaData {
		uint256[] startTime;
		uint256[] totalNav;
		uint256[] totalDepositBal;

		uint256[] illiquidLen;
		uint256[] liquidLen;
		uint256[] nftLen;
		uint256[] composableLen;
		uint256[] fundBaseTokenDecimals;

		string[] fundMetadata;
		string[] fundName;
		string[] fundBaseTokenSymbol;
	}

	struct FundNavData {
		uint256[][] illiquid;
		uint256[][] liquid;
		int256[][] nft;
		int256[][] composable;
		bytes[] encodedNavUpdate;
	}

	bytes4[] functionSigs = [
		bytes4(keccak256("_navUpdateLatestIndex()")), 
		bytes4(keccak256("fundMetadata()")), 
		bytes4(keccak256("symbol()")), 
		bytes4(keccak256("decimals()"))
	];

	constructor(address governableFundFactory, address navCalculator) {
		_governableFundFactory = governableFundFactory;
		_navCalculator = navCalculator;
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
		fd.fundMetadata = new string[](arrayLen);
		fd.fundName = new string[](arrayLen);
		fd.fundBaseTokenSymbol = new string[](arrayLen);
		fd.fundBaseTokenDecimals = new uint256[](arrayLen);

		for(uint i=0; i<arrayLen;i++) {
	        address fundBaseToken = IGovernableFund(funds[i]).getFundSettings().baseToken;

	        bytes memory data0 = addressStaticCall(funds[i], functionSigs[0]);//_navEntryIndex
	        bytes memory data1 = addressStaticCall(funds[i], functionSigs[1]);//fundMetadata
	        bytes memory data2 = addressStaticCall(fundBaseToken, functionSigs[2]);//symbol
	        bytes memory data3 = addressStaticCall(fundBaseToken, functionSigs[3]);//decimals
	        
	        uint256 lnIdx = abi.decode(data0, (uint256));

			fd.startTime[i] = IGovernableFundStorageFunctions(funds[i]).getFundStartTime();
			fd.totalNav[i] = IGovernableFundStorageFunctions(funds[i]).totalNAV();
			fd.totalDepositBal[i] = IGovernableFundStorageFunctions(funds[i])._totalDepositBal();
			fd.fundMetadata[i] = abi.decode(data1, (string));
			fd.fundName[i] = IGovernableFund(funds[i]).getFundSettings().fundName;

			fd.fundBaseTokenSymbol[i] = abi.decode(data2, (string));
			fd.fundBaseTokenDecimals[i] = abi.decode(data3, (uint256));

			fd.illiquidLen[i] = INAVCalculator(_navCalculator).getNAVIlliquidCache(funds[i], lnIdx).length;
			fd.liquidLen[i] = INAVCalculator(_navCalculator).getNAVLiquidCache(funds[i], lnIdx).length;
			fd.nftLen[i] = INAVCalculator(_navCalculator).getNAVNFTCache(funds[i], lnIdx).length;
			fd.composableLen[i] = INAVCalculator(_navCalculator).getNAVComposableCache(funds[i], lnIdx).length;
		}

		return fd;
	}

	function addressStaticCall(address addr, bytes4 functionSig) private view returns (bytes memory) {
		bytes memory gfcall = abi.encodeWithSelector(
            functionSig
        );
        (bool success0, bytes memory data0) = addr.staticcall(gfcall);
        require(success0 == true, "fail addr static call");
        return data0;
	}

	function bulkGetNavData(address[] calldata funds) external view returns (FundNavData[] memory) {
		FundNavData[] memory fds = new FundNavData[](funds.length);
		for(uint i=0; i< funds.length; i++){
			fds[i] = getNAVDataForFund(funds[i]);
		}

		return fds;
	}

	function getNAVDataForFund(address fund) public view returns (FundNavData memory) {
		bytes memory data0 = addressStaticCall(fund, functionSigs[0]);//_navEntryIndex
        uint256 navUpdateLatestIndex = abi.decode(data0, (uint256));

        FundNavData memory fd;

		fd.illiquid = new uint256[][](navUpdateLatestIndex);
		fd.liquid = new uint256[][](navUpdateLatestIndex);
		fd.nft = new int256[][](navUpdateLatestIndex);
		fd.composable = new int256[][](navUpdateLatestIndex);
		fd.encodedNavUpdate = new bytes[](navUpdateLatestIndex);//NOTE: WILL NEED TO BE DECODED BY CLIENT SIDE ABI

        for(uint i=0; i<navUpdateLatestIndex;i++) {
			fd.illiquid[i] = INAVCalculator(_navCalculator).getNAVIlliquidCache(fund, i);
			fd.liquid[i] = INAVCalculator(_navCalculator).getNAVLiquidCache(fund, i);
			fd.nft[i] = INAVCalculator(_navCalculator).getNAVNFTCache(fund, i);
			fd.composable[i] = INAVCalculator(_navCalculator).getNAVComposableCache(fund, i);
			bytes memory gfcall = abi.encodeWithSelector(
				bytes4(keccak256("getNavEntry(uint256)")),
				i
			);
			(, bytes memory data1) = fund.staticcall(gfcall);
			fd.encodedNavUpdate[i] = data1;
		}

		return fd;
	}
}