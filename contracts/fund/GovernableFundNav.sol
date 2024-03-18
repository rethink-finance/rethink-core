// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "./GovernableFundStorage.sol";

contract GovernableFundNav is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;

	//TODO: able to ref remote nav entry with staticcall, basis for nav update lib

	function processNav(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData) public returns (uint256) {
		//NOTE: may need to happen over multiple transactions?
		uint256 updatedNav = 0;
		uint256 updatedNavResNeg = 0;

		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updatedNav += prepLiquid(navUpdateData, i);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updatedNav += prepIlliquid(navUpdateData, i);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				int256 nftCalc = prepNFT(navUpdateData, i);

				if (nftCalc < 0) {
					updatedNavResNeg += uint256(-nftCalc);
				} else {
					updatedNav += uint256(nftCalc);
				}

			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				int256 composableCalc = prepComposable(navUpdateData, i);

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

 		require(updatedNavResNeg < updatedNav, "updatedNav will overflow");
 		updatedNav -= updatedNavResNeg;

		return updatedNav;
	}

	function prepLiquid(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, uint256 i) internal returns (uint256) {
		return INAVCalculator(_navCalculatorAddress).liquidCalculation(
			navUpdateData[i].liquid,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			navUpdateData[i].pastNAVUpdateEntryFundAddress
		);
	}

	function prepIlliquid(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, uint256 i) internal returns (uint256) {
		return INAVCalculator(_navCalculatorAddress).illiquidCalculation(
			navUpdateData[i].illiquid,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			navUpdateData[i].pastNAVUpdateEntryFundAddress
		);
	}

	function prepNFT(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, uint256 i) internal returns (int256) {
		return INAVCalculator(_navCalculatorAddress).nftCalculation(
			navUpdateData[i].nft,
			FundSettings.safe,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			navUpdateData[i].pastNAVUpdateEntryFundAddress
		);
	}

	function prepComposable(IGovernableFundStorage.NavUpdateEntry[] calldata navUpdateData, uint256 i) internal returns (int256) {
		return INAVCalculator(_navCalculatorAddress).composableCalculation(
			navUpdateData[i].composable,
			address(this),
			i,
			navUpdateData[i].isPastNAVUpdate,
			navUpdateData[i].pastNAVUpdateIndex,
			navUpdateData[i].pastNAVUpdateEntryIndex,
			navUpdateData[i].pastNAVUpdateEntryFundAddress
		);
	}
}