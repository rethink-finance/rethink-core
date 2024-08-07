const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const execData = "0x";
const proxy = "";
const isTest = false;
const network = "eth";

//time truffle migrate --reset -f 14 --to 14 --compile-none --skip-dry-run --network=eth

const multiSigs = {
	"arb1": "0xd8a5076Da13a2d95062de42dD26CB41B9Daa0B53",
	"matic": "0x83f2492DB796BF0692C90B65DeBB926bd688fAe5",
	"frax": "0x59Bc7266991376D75dfe892AA4D36fB0619775D9",
	"eth": "0x45Ea87fBF0f0D815d2B3969b904F6034e45B381b"
};

const proxyTypes = [
	"GovernableFundFactoryUpgradeableBeacon",
	"RethinkFundGovernerUpgradeableBeacon",
	"GovernableFundUpgradeableBeacon",
	"WrappedTokenFactoryUpgradeableBeacon",
	"NAVCalculatorUpgradeableBeacon",
	"ZodiacRolesV1ModifierUpgradeableBeacon",
	"GovernableFundFlowsUpgradeableBeacon",
	"GovernableFundNavUpgradeableBeacon",
	"GovernableContractFactoryUpgradeableBeacon",
	"NAVExecutorUpgradeableBeacon"
];

const proxies = {
	"arb1": {
		"GovernableFundFactoryUpgradeableBeacon": "0xB9Ca0051232F773Bd3C6A7823E02449783a2B53F",
		"RethinkFundGovernerUpgradeableBeacon": "0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008",
		"GovernableFundUpgradeableBeacon": "0xB4c232f0cF194E530c39174F617Ec4ee9d69398C",
		"WrappedTokenFactoryUpgradeableBeacon": "0x4278a6b150628470F28Af2Df6B43518f372A59E4",
		"NAVCalculatorUpgradeableBeacon": "0x4C342E583A7Aa2840e07B4a3afB71533FBE37726",
		"ZodiacRolesV1ModifierUpgradeableBeacon": "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4",
		"GovernableFundFlowsUpgradeableBeacon": "0xdf587D859e76B0a6cE2254f1c0bf64C4aE0eD37f",
		"GovernableFundNavUpgradeableBeacon": "0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B",
		"GovernableContractFactoryUpgradeableBeacon": "0x89254d6FF377a21aC0b99BD2e456e75b6C76E505",
		"NAVExecutorUpgradeableBeacon": "0xcC1f375aa10c5f6c5CBD5295f937D9aaF84427E0"
	},
	"matic": {
		"GovernableFundFactoryUpgradeableBeacon": "0xE16b6C9C2CB8aE15f0872A3A46d2Eb070c27f20D",
		"RethinkFundGovernerUpgradeableBeacon": "0xB4c232f0cF194E530c39174F617Ec4ee9d69398C",
		"GovernableFundUpgradeableBeacon": "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4",
		"WrappedTokenFactoryUpgradeableBeacon": "0xB9Ca0051232F773Bd3C6A7823E02449783a2B53F",
		"NAVCalculatorUpgradeableBeacon": "0xe0D8ca6d6b67E39dfADC137B675455Bc1ee5bCdd",
		"ZodiacRolesV1ModifierUpgradeableBeacon": "0xdf587D859e76B0a6cE2254f1c0bf64C4aE0eD37f",
		"GovernableFundFlowsUpgradeableBeacon": "0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B",
		"GovernableFundNavUpgradeableBeacon": "0x89254d6FF377a21aC0b99BD2e456e75b6C76E505",
		"GovernableContractFactoryUpgradeableBeacon": "0x89483Dc199F70268e3aB79D08301456Fb6aF75f4",
		"NAVExecutorUpgradeableBeacon": "0x9252cb7DC49003b786251CA12E5f21Dba6600dbe"
	},
	"frax": {
		"GovernableFundFactoryUpgradeableBeacon": "0x4C342E583A7Aa2840e07B4a3afB71533FBE37726",
		"RethinkFundGovernerUpgradeableBeacon": "0xA2eC20a1D6139890962989d5F33DBF03BFbf0dD1",
		"GovernableFundUpgradeableBeacon": "0x296203D903178e17DEF9C3891A578278aA230754",
		"WrappedTokenFactoryUpgradeableBeacon": "0x79b15F47640C4e3ac3A9c4B7f1B999a8cccEEeC7",
		"NAVCalculatorUpgradeableBeacon": "0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008",
		"ZodiacRolesV1ModifierUpgradeableBeacon": "0x463F9eE917F71B7DB1c81fbFe44A95a4f5B540a6",
		"GovernableFundFlowsUpgradeableBeacon": "0x5b8137fC792f1d054099fb2B7EEb7e575Ee8403B",
		"GovernableFundNavUpgradeableBeacon": "0x26cEb3873ad8A3dee2e5d3d67d2d0800704B9fb5",
		"GovernableContractFactoryUpgradeableBeacon": "0x9C3bEa435Ed4100E67a962712D727F79853792a4",
		"NAVExecutorUpgradeableBeacon": ""
	},
	"eth": {
		"GovernableFundFactoryUpgradeableBeacon": "0x4C342E583A7Aa2840e07B4a3afB71533FBE37726",
		"RethinkFundGovernerUpgradeableBeacon": "0xA2eC20a1D6139890962989d5F33DBF03BFbf0dD1",
		"GovernableFundUpgradeableBeacon": "0x296203D903178e17DEF9C3891A578278aA230754",
		"WrappedTokenFactoryUpgradeableBeacon": "0x79b15F47640C4e3ac3A9c4B7f1B999a8cccEEeC7",
		"NAVCalculatorUpgradeableBeacon": "0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008",
		"ZodiacRolesV1ModifierUpgradeableBeacon": "0xbbf156CCc038b405001034573E77F3B2174B762a",
		"GovernableFundFlowsUpgradeableBeacon": "0x463F9eE917F71B7DB1c81fbFe44A95a4f5B540a6",
		"GovernableFundNavUpgradeableBeacon": "0x5b8137fC792f1d054099fb2B7EEb7e575Ee8403B",
		"GovernableContractFactoryUpgradeableBeacon": "0x26cEb3873ad8A3dee2e5d3d67d2d0800704B9fb5",
		"NAVExecutorUpgradeableBeacon": "0x9C3bEa435Ed4100E67a962712D727F79853792a4"
	},
	"arbsep": {
		"GovernableFundFactoryUpgradeableBeacon": "",
		"RethinkFundGovernerUpgradeableBeacon": "",
		"GovernableFundUpgradeableBeacon": "",
		"WrappedTokenFactoryUpgradeableBeacon": "",
		"NAVCalculatorUpgradeableBeacon": "",
		"ZodiacRolesV1ModifierUpgradeableBeacon": "",
		"GovernableFundFlowsUpgradeableBeacon": "",
		"GovernableFundNavUpgradeableBeacon": "",
		"GovernableContractFactoryUpgradeableBeacon": "",
		"NAVExecutorUpgradeableBeacon": "",
	}
};
module.exports = async function (deployer) {
	for (var i=0; i<proxyTypes.length;i++) {
		let ub = await UpgradeableBeacon.at(proxies[network][proxyTypes[i]]);
		setTimeout(function(){},delay);
		await ub.transferOwnership(multiSigs[network]);
		setTimeout(function(){},delay);
		console.log(proxyTypes[i] +" at " + proxies[network][proxyTypes[i]] + " ownership has transfered to: "+ multiSigs[network]);
	}
	throw '';
}