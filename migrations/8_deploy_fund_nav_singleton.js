const GovernableFundNav = artifacts.require("GovernableFundNav");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0x6cb326b573ad0CeFC742d35bC713f8766fb5e027";

//time truffle migrate --reset -f 8 --to 8 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	/*
	  await deployer.deploy(GovernableFundNav);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundNav singleton is at: "+ GovernableFundNav.address);

	  let p = await UpgradeableBeacon.at(proxy);
	  setTimeout(function(){},delay);
	  p.upgradeTo(GovernableFundNav.address);
	  let gfnavub = await deployer.deploy(UpgradeableBeacon, GovernableFundNav.address);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundNavUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
*/
}