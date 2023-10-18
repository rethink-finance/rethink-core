// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/nav/INAVCalculator.sol";
import "./GovernableFundStorage.sol";

contract GovernableFundNav is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;
	uint256 private fractionBase = 1e9; //NOTE: assumes lp token is 18 decimals

	function initialize(string memory _name_, string memory _symbol_, IGovernableFund.Settings calldata _fundSettings, address _navCalculatorAddress, address _fundDelgateCallFlowAddres, address fundDelgateCallNavAddress) external {}

	function processNav(NavUpdateEntry[] calldata navUpdateData) public returns (uint256) {
		//NOTE: may need to happen over multiple transactions?
		uint256 updateedNav = 0;
		for(uint256 i=0; i< navUpdateData.length; i++) {
			if (navUpdateData[i].entryType == NavUpdateType.NAVLiquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).liquidCalculation(
					navUpdateData[i].liquid,
					FundSettings.safe,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].liquid
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVIlliquidUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).illiquidCalculation(
					navUpdateData[i].illiquid,
					FundSettings.safe,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].illiquid
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVNFTUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).nftCalculation(
					navUpdateData[i].nft,
					FundSettings.safe,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].nft
				);
			} else if (navUpdateData[i].entryType == NavUpdateType.NAVComposableUpdateType) {
				updateedNav += INAVCalculator(_navCalculatorAddress).composableCalculation(
					navUpdateData[i].composable,
					address(this),
					i,
					navUpdateData[i].isPastNAVUpdate,
					navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex].composable
				);
			}

			if (navUpdateData[i].isPastNAVUpdate == true){
				navUpdate[_navUpdateLatestIndex].push(navUpdate[navUpdateData[i].pastNAVUpdateIndex][navUpdateData[i].pastNAVUpdateEntryIndex]);
			} else {
				navUpdate[_navUpdateLatestIndex].push(navUpdateData[i]);
			}
 		}

		return updateedNav;
	}
}