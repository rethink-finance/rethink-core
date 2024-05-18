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
//const proxy = "0xB227079f5c5b700E99afC1715A799DD008fCDD22";//goerli
const proxy = "0xE16b6C9C2CB8aE15f0872A3A46d2Eb070c27f20D";//matic
//time truffle migrate --reset -f 4 --to 4 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gff = await deployer.deploy(GovernableFundFactory);
	setTimeout(function(){},delay);
	console.log("GovernableFundFactory singleton is at: "+ GovernableFundFactory.address);

	
	//let ub = await UpgradeableBeacon.at(proxy);
	//setTimeout(function(){},delay);
	//ub.upgradeTo(GovernableFundFactory.address);
	//ub.upgradeTo("0x4fd04f9a76e71debe1cff38436b9d5b742060248");

	/*
  	let gffub = await deployer.deploy(UpgradeableBeacon, GovernableFundFactory.address);
  	setTimeout(function(){},delay);
  	console.log("GovernableFundFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  	let gffubprox = await deployer.deploy(BeaconProxy, UpgradeableBeacon.address, execData);
  	setTimeout(function(){},delay);
  	console.log("GovernableFundFactoryBeaconProxy is at: "+ BeaconProxy.address);
  	*/
}