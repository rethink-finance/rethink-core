// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "./GovernableFundStorage.sol";

contract GovernableFundNav is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;

	//TODO: able to ref remote nav entry with staticcall, basis for nav update lib

	function processNav(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress) public returns (uint256) {
		//NOTE: may need to happen over multiple transactions?
		uint256 updatedNav = 0;
		uint256 updatedNavResNeg = 0;

		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updatedNav += prepLiquid(navUpdateData, pastNAVUpdateEntryFundAddress, i);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updatedNav += prepIlliquid(navUpdateData, pastNAVUpdateEntryFundAddress, i);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				int256 nftCalc = prepNFT(navUpdateData, pastNAVUpdateEntryFundAddress, i);

				if (nftCalc < 0) {
					updatedNavResNeg += uint256(-nftCalc);
				} else {
					updatedNav += uint256(nftCalc);
				}

			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				int256 composableCalc = prepComposable(navUpdateData, pastNAVUpdateEntryFundAddress, i);

				if (composableCalc < 0) {
					updatedNavResNeg += uint256(-composableCalc);
				} else {
					updatedNav += uint256(composableCalc);
				}
			}

			if (navUpdateData[i].isPastNAVUpdate == true){
				navUpdate[_navUpdateLatestIndex].push(navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex]);
			} else {
				navUpdate[_navUpdateLatestIndex].push(navUpdateData[i]);
			}
 		}

 		require(updatedNavResNeg <= updatedNav, "updatedNav will overflow");
 		updatedNav -= updatedNavResNeg;

		return updatedNav;
	}

	function updateNAVPartsCache(uint256 _totalNAV) public {
		/*
				struct NAVInternalCacheType {
					uint256 baseAssetOIVBal;
					uint256 baseAssetSafeBal;
					uint256 feeBal;
					uint256 totalNAV;
				}
		*/
		uint256[] memory cacheData = new uint256[](4);
	 	cacheData[0] = IERC20(FundSettings.baseToken).balanceOf(address(this));
	 	cacheData[1] = IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe);
	 	cacheData[2] = _feeBal;
	 	cacheData[3] = _totalNAV;
		INAVCalculator(_navCalculatorAddress).cacheNAVParts(cacheData, address(this), _navUpdateLatestIndex);
	}

	function prepLiquid(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, uint256 i) internal returns (uint256) {
		return INAVCalculator(_navCalculatorAddress).liquidCalculation(
			navUpdateData[i].liquid,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			pastNAVUpdateEntryFundAddress[i]
		);
	}

	function prepIlliquid(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, uint256 i) internal returns (uint256) {
		return INAVCalculator(_navCalculatorAddress).illiquidCalculation(
			navUpdateData[i].illiquid,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			pastNAVUpdateEntryFundAddress[i]
		);
	}

	function prepNFT(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, uint256 i) internal returns (int256) {
		return INAVCalculator(_navCalculatorAddress).nftCalculation(
			navUpdateData[i].nft,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			pastNAVUpdateEntryFundAddress[i]
		);
	}

	function prepComposable(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, address[] calldata pastNAVUpdateEntryFundAddress, uint256 i) internal returns (int256) {
		return INAVCalculator(_navCalculatorAddress).composableCalculation(
			navUpdateData[i].composable,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			pastNAVUpdateEntryFundAddress[i]
		);
	}
}