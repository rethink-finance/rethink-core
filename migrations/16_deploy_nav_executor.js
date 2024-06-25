const NAVExecutor = artifacts.require("NAVExecutor");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");


const delay = 10000;
const execData = "0x";
//const proxy = "0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166";//goerli
//const proxy = "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4";//matic
//const proxy = "0xB4c232f0cF194E530c39174F617Ec4ee9d69398C";//arb1
//time truffle migrate --reset -f 16 --to 16 --skip-dry-run --compile-none --network=matic
module.exports = async function (deployer) {
	/**/
	let gf = await deployer.deploy(NAVExecutor);
	setTimeout(function(){},delay);
	console.log("NAVExecutor singleton is at: "+ NAVExecutor.address);
	/**/

	/*
	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(NAVExecutor.address);
	
	setTimeout(function(){},delay);
	await p.transferOwnership(multiSigs[network]);

	*/

	/**/
  	let naveub = await deployer.deploy(UpgradeableBeacon, NAVExecutor.address);
  	setTimeout(function(){},delay);
  	console.log("NAVExecutorUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  	let naveubprox = await deployer.deploy(BeaconProxy, UpgradeableBeacon.address, execData);
  	setTimeout(function(){},delay);
  	console.log("NAVExecutorBeaconProxy is at: "+ BeaconProxy.address);
  	/**/	
}
