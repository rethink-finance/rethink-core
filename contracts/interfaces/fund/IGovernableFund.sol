pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IGovernableFund {
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
	}

	struct NAVIlliquidUpdate {
		uint256 baseCurrencySpent;
		uint256 amountAquiredTokens;
		address tokenAddress;
		bool isNFT;
		string[] otcTxHashes;
		NAVNFTType nftType;
		uint256 nftIndex;
	}

	enum NAVNFTType {
		ERC1155,
		ERC721
	}

	struct NAVNFTUpdate {
		address oracleAddress;
		address nftAddress;
		NAVNFTType nftType;
		uint256 nftIndex;
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
	}

	struct WithdrawalRequestEntry {
		uint256 amount;
		uint256 requestTime;
	}

	function initialize(string memory _name_, string memory _symbol_, IGovernableFund.Settings calldata _fundSettings) external;
}