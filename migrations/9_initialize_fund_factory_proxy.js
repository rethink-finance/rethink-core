const GovernableFundFactory = artifacts.require("GovernableFundFactory");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "";
const isTest = false;
const network = "arb1";

//time truffle migrate --reset -f 9 --to 9 --skip-dry-run --network=goerli

module.exports = async function (deployer) {

	  var gff;
		  /*
		  function initialize(
		  	address governor//b
		  	address fund,//b
		  	address safeProxyFactory,
		  	address safeSingleton,
		  	address safeFallbackHandler,
		  	address safeMultisendAddress,
		  	address wrappedTokenFactory, //b
		  	address navCalculatorAddress,//bp
		  	address zodiacRolesModifierModule,//b
		  	address fundDelgateCallFlowSingletonAddress //b
		  	address fundDelgateCallNavSingletonAddress //b
		  	address governableContractFactorySingletonAddress //b
		  )

		  */
	  if (isTest == true) {
	  	gff = await GovernableFundFactory.at("0x2e71Eef0AE6C82902B6458655A36BfD7B76E6B2D");
		await gff.initialize(
			"0x30DB0Ca15AfB8a9D6ec6e3e377207B9E995E1901",
			"0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166", 
			"0xa6b71e26c5e0845f74c812102ca7114b6a896ab2",
			"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
			"0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",
			"0x40A2aCCbd92BCA938b02010E17A5b8929b49130D", //safeMultisendAddress goerli-> 0x40A2aCCbd92BCA938b02010E17A5b8929b49130D
			"0x4132F5D58a2F7F73c95Fa7B1D100F24969E6c78b", //wrappedTokenFactory
			"0x26d70661664Fc2b4a1519Fa5766ccFF7E384a12F",
			"0xb3aec0e144e46ee4290ad93cc05609c160413087", 
			"0xa052A48F26ba43E8A3d111298471319a8d5E7496",
			"0x6cb326b573ad0CeFC742d35bC713f8766fb5e027",
			"0xcd1e65B55cd73860FC80778C8398ae2f4C9222e8"
		);
	  } else {

	  	if (network == "matic") {
		  	gff = await GovernableFundFactory.at("0x4C342E583A7Aa2840e07B4a3afB71533FBE37726");
			await gff.initialize(
		  	"0xB4c232f0cF194E530c39174F617Ec4ee9d69398C",//governor b
		  	"0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4",//fund b
		  	"0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
		  	"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
		  	"0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",
		  	"0x40A2aCCbd92BCA938b02010E17A5b8929b49130D", //safeMultisendAddress polygon-> 0x40A2aCCbd92BCA938b02010E17A5b8929b49130D
		  	"0xB9Ca0051232F773Bd3C6A7823E02449783a2B53F", //wrappedTokenFactory, b
		  	"0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008",//navCalculatorAddress bp
		  	"0xdf587D859e76B0a6cE2254f1c0bf64C4aE0eD37f",//zodiacRolesModifierModule b 
		  	"0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B",//fundDelgateCallFlowSingletonAddress b
		  	"0x89254d6FF377a21aC0b99BD2e456e75b6C76E505",//fundDelgateCallNavSingletonAddress b
		  	"0x89483Dc199F70268e3aB79D08301456Fb6aF75f4"//governableContractFactorySingletonAddress b
		  );
		} else if (network == 'arb1') {
			gff = await GovernableFundFactory.at("0x4C342E583A7Aa2840e07B4a3afB71533FBE37726");
			await gff.initialize(
		  	"",//governor b
		  	"",//fund b
		  	"0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",//safeProxyFactory
		  	"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",//safeSingleton
		  	"0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",//safeFallbackHandler
		  	"0x40A2aCCbd92BCA938b02010E17A5b8929b49130D", //safeMultisendAddress arb1
		  	"", //wrappedTokenFactory, b
		  	"",//navCalculatorAddress bp
		  	"",//zodiacRolesModifierModule b 
		  	"",//fundDelgateCallFlowSingletonAddress b
		  	"",//fundDelgateCallNavSingletonAddress b
		  	""//governableContractFactorySingletonAddress b
		  );
		}
	}
}