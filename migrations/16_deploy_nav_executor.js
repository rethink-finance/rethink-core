const NAVExecutor = artifacts.require("NAVExecutor");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");


const delay = 10000;
const execData = "0x";
//const proxy = "0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166";//goerli
//const proxy = "0x9252cb7DC49003b786251CA12E5f21Dba6600dbe";//matic
const proxy = "0xcC1f375aa10c5f6c5CBD5295f937D9aaF84427E0";//arb1
//time truffle migrate --reset -f 16 --to 16 --skip-dry-run --compile-none --network=matic

const multiSigs = {
	"arb1": "0xd8a5076Da13a2d95062de42dD26CB41B9Daa0B53",
	"matic": "0x83f2492DB796BF0692C90B65DeBB926bd688fAe5",
	"frax": "0x59Bc7266991376D75dfe892AA4D36fB0619775D9",
	"eth": "0x45Ea87fBF0f0D815d2B3969b904F6034e45B381b"
};

module.exports = async function (deployer) {
	/*
	let gf = await deployer.deploy(NAVExecutor);
	setTimeout(function(){},delay);
	console.log("NAVExecutor singleton is at: "+ NAVExecutor.address);
	*/


	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	//p.upgradeTo(NAVExecutor.address);



	setTimeout(function(){},delay);
	await p.transferOwnership("0xd8a5076Da13a2d95062de42dD26CB41B9Daa0B53");

	/*
  	let naveub = await deployer.deploy(UpgradeableBeacon, NAVExecutor.address);
  	setTimeout(function(){},delay);
  	console.log("NAVExecutorUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  	let naveubprox = await deployer.deploy(BeaconProxy, UpgradeableBeacon.address, execData);
  	setTimeout(function(){},delay);
  	console.log("NAVExecutorBeaconProxy is at: "+ BeaconProxy.address);
  	*/	
}
