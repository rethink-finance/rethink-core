// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGovernableFundStorage {
	struct Settings {
		uint256 depositFee;
		uint256 withdrawFee;
		uint256 performanceFee;
		uint256 managementFee;
		uint256 performaceHurdleRateBps;
		address baseToken;
		address safe; //TODO: needs to be set after safe creation
		bool isExternalGovTokenInUse;
		bool isWhitelistedDeposits;
		address[] allowedDepositAddrs;
		address[] allowedManagers;
		address governanceToken;
		address fundAddress;//TODO: this may not be needed if delegatecall has balance refs to callee addr
		address governor;
		string fundName;
		string fundSymbol;
	}

	struct NAVLiquidUpdate {
		address tokenPair;
		address aggregatorAddress;
		bytes functionSignatureWithEncodedInputs;
		address assetTokenAddress;
		address nonAssetTokenAddress;
		bool isReturnArray;
		uint256 returnLength;
		uint256 returnIndex;
		uint256 pastNAVUpdateIndex;
		string description;
	}

	struct NAVIlliquidUpdate {
		uint256 baseCurrencySpent;
		uint256 amountAquiredTokens;
		address tokenAddress;
		bool isNFT;
		string[] otcTxHashes;
		NAVNFTType nftType;
		uint256 nftIndex;
		uint256 pastNAVUpdateIndex;
	}

	enum NAVNFTType {
		ERC1155,
		ERC721,
		NONE
	}

	struct NAVNFTUpdate {
		address oracleAddress;
		address nftAddress;
		NAVNFTType nftType;
		uint256 nftIndex;
		uint256 pastNAVUpdateIndex;
	}

	enum NAVComposableUpdateReturnType {
		UINT256,
		INT256
	}

	struct NAVComposableUpdate {
		address remoteContractAddress;
		string functionSignatures;
		bytes encodedFunctionSignatureWithInputs;
		uint256 normalizationDecimals;
		bool isReturnArray;
		uint256 returnValIndex;
		uint256 returnArraySize;
		NAVComposableUpdateReturnType returnValType;
		uint256 pastNAVUpdateIndex;
		bool isNegative;
	}

	enum NavUpdateType {
		NAVLiquidUpdateType,
		NAVIlliquidUpdateType,
		NAVNFTUpdateType,
		NAVComposableUpdateType
	}

	struct NavUpdateEntry {
		NavUpdateType entryType;
		NAVLiquidUpdate[] liquid;
		NAVIlliquidUpdate[] illiquid;
		NAVNFTUpdate[] nft;
		NAVComposableUpdate[] composable;
		bool isPastNAVUpdate;
		uint256 pastNAVUpdateIndex;
		uint256 pastNAVUpdateEntryIndex;
	}

	struct WithdrawalRequestEntry {
		uint256 amount;
		uint256 requestTime;
	}

	struct DepositRequestEntry {
		uint256 amount;
		uint256 requestTime;
	}
}