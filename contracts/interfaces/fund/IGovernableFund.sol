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
		address governaceToken;
	}

	/*
		TODO:
		Manager will input:
		Token pair address or aggregator address
		Function signature to query floor price
		Function # of inputs
		List of inputs
		Base currency token address
		Asset token address				
	*/

	struct NAVLiquidUpdate {
		address tokenPair;
		address aggregatorAddress;
		bytes functionSignatureWithEncodedInputes;
		address assetTokenAddress;
		address nonAssetTokenAddress;
		bool isReturnArray;
		uint256 returnLength;
		uint256 returnIndex;
	}

	/*
		Address of acquired token
		Amount of base currency used to acquire token
		List of txs hashes used to acquire token
		Amount of tokens acquired
	*/
	struct NAVIlliquidUpdate {
		uint256 baseCurrencySpent;
		uint256 amountAquiredTokens;
		address tokenAddress;
		string[] otcTxHashes;
	}

	/*
		TODO
		Chainlink https://docs.chain.link/data-feeds/nft-floor-price/addresses 

	*/
	struct NAVNFTUpdate {
		address oracleAddress;
		address nftAddress;
	}

	/*
		TODO:
		The address that implements some pricing function (can be found in a protocols documentation)
		Function Signature (i.e “transferFrom(address,address,uint256)”, can be found from verified smart contracts in explorer, the open source code for a project)
		Total amount of input values: (i.e “3”)
		Specific input values for the Function to get the required position value (i.e. “0x123,0x456,789)
		Decimals used to normalise position output (i.e “18”)

	*/

	enum NAVComposableUpdateReturnType {
		UINT256,
		INT256
	}

	struct NAVComposableUpdate {
		uint256 index;
		address remoteContractAddress;
		string functionSignatures;
		bytes encodedFunctionSignaturWithInputs;
		uint256 normalizationDecimals;
		bool isAdditionOperationOnPrevIndex;
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
}