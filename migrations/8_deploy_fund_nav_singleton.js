const GovernableFundNav = artifacts.require("GovernableFundNav");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0x13a2a952A21552B835E3403ef712707D6cEf359e";

//time truffle migrate --reset -f 8 --to 8 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  await deployer.deploy(GovernableFundNav);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundNav singleton is at: "+ GovernableFundNav.address);

	  /*let gfflowprox = await deployer.deploy(TransparentUpgradeableProxy, GovernableFundNav.address, owner, execData);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundNavTransparentUpgradeableProxy singleton is at: "+ gfflowprox.address);
	*/
	  let p = await UpgradeableBeacon.at(proxy);
	  setTimeout(function(){},delay);
	  p.upgradeTo(GovernableFundNav.address);
}