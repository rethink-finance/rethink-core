const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const ZodiacRolesV1Modifier = artifacts.require("RolesV1");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0xB9Ca0051232F773Bd3C6A7823E02449783a2B53F"; //matic
//time truffle migrate --reset -f 12 --to 12 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	//let gff = await deployer.deploy(WrappedTokenFactory);
	//setTimeout(function(){},delay);
	//console.log("WrappedTokenFactory singleton is at: "+ WrappedTokenFactory.address);

	let ub = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	//ub.upgradeTo(WrappedTokenFactory.address);
	ub.upgradeTo("0x616FFa09771e270aeec04213aafE40309F5b0d6b");
	
	/*
  	let gffub = await deployer.deploy(UpgradeableBeacon, WrappedTokenFactory.address);
  	setTimeout(function(){},delay);
  	console.log("WrappedTokenFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
  	*/
}