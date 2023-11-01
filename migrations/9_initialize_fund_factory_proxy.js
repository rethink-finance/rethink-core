const GovernableFundFactory = artifacts.require("GovernableFundFactory");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "";

//time truffle migrate --reset -f 9 --to 9 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  let gff = await GovernableFundFactory.at("0x2e71Eef0AE6C82902B6458655A36BfD7B76E6B2D");

	  /*
	  function initialize(
	  	address governor//b
	  	address fund,//b
	  	address safeProxyFactory,
	  	address safeSingleton,
	  	address safeFallbackHandler,
	  	address wrappedTokenFactory, //b
	  	address navCalculatorAddress,//bp
	  	address zodiacRolesModifierModule,//b
	  	address fundDelgateCallFlowSingletonAddress //b
	  	address fundDelgateCallNavSingletonAddress //b
	  	address governableContractFactorySingletonAddress //b
	  )

	  */
	  await gff.initialize(
	  	"0x30DB0Ca15AfB8a9D6ec6e3e377207B9E995E1901",
	  	"0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166", 
	  	"0xa6b71e26c5e0845f74c812102ca7114b6a896ab2",
	  	"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
	  	"0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",
	  	"0x4132F5D58a2F7F73c95Fa7B1D100F24969E6c78b", //wrappedTokenFactory
	  	"0x26d70661664Fc2b4a1519Fa5766ccFF7E384a12F",
	  	"0xb3aec0e144e46ee4290ad93cc05609c160413087", 
	  	"0xa052A48F26ba43E8A3d111298471319a8d5E7496",
	  	"0x6cb326b573ad0CeFC742d35bC713f8766fb5e027",
	  	"0xcd1e65B55cd73860FC80778C8398ae2f4C9222e8"
	  );
}