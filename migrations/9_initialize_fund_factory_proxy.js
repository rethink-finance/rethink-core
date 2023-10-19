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
	  	address governor, bp
	  	address fund,//b
	  	address safeProxyFactory,
	  	address safeSingleton,
	  	address safeFallbackHandler,
	  	address wrappedTokenFactory,
	  	address navCalculatorAddress,//bp
	  	address zodiacRolesModifierModule,//b
	  	address fundDelgateCallFlowSingletonAddress //bp
	  	address fundDelgateCallNavSingletonAddress //bp
	  )

	  */
	  await gff.initialize(
	  	"0x30DB0Ca15AfB8a9D6ec6e3e377207B9E995E1901",
	  	"0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166", 
	  	"0xa6b71e26c5e0845f74c812102ca7114b6a896ab2",
	  	"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
	  	"0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",
	  	"0xe6EAa086198EDBd2E3b8F736256F9871A9f60511",
	  	"0x26d70661664Fc2b4a1519Fa5766ccFF7E384a12F",
	  	"0xb3aec0e144e46ee4290ad93cc05609c160413087", 
	  	"0x2C22E878Fd7aD631FFf5369C2ef239237926cDaF",
	  	"0x81b504b3b20a6B0fDDA0d990E68cf20C526Ae699"
	  );
}