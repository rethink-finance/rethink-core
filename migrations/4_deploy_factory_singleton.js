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
const proxy = "0xf0cAe108823b80F37cfAA5E8aEc8190D66ED0d62";
//time truffle migrate --reset -f 4 --to 4 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gff = await deployer.deploy(GovernableFundFactory);
	setTimeout(function(){},delay);
	console.log("GovernableFundFactory singleton is at: "+ GovernableFundFactory.address);

	
	let ub = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	ub.upgradeTo(GovernableFundFactory.address);
	
	/*
  	let gffub = await deployer.deploy(UpgradeableBeacon, GovernableFundFactory.address);
  	setTimeout(function(){},delay);
  	console.log("GovernableFundFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  	let gffubprox = await deployer.deploy(BeaconProxy, UpgradeableBeacon.address, execData);
  	setTimeout(function(){},delay);
  	console.log("GovernableFundFactoryBeaconProxy is at: "+ BeaconProxy.address);
  	*/
}