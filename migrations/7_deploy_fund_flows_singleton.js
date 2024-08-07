const GovernableFundFlows = artifacts.require("GovernableFundFlows");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
//const proxy = "0xa052A48F26ba43E8A3d111298471319a8d5E7496";//goerli
//const proxy = "0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B";//matic
const proxy = "0x463F9eE917F71B7DB1c81fbFe44A95a4f5B540a6";//eth

//time truffle migrate --reset -f 7 --to 7 --skip-dry-run --compile-none --network=eth

module.exports = async function (deployer) {
	/**/
	  await deployer.deploy(GovernableFundFlows);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundFlows singleton is at: "+ GovernableFundFlows.address);
	 /* */
	  /*
	  let p = await UpgradeableBeacon.at(proxy);
	  setTimeout(function(){},delay);
	  //p.upgradeTo("0x5618892Df220778478810049Dc03432f68459654");
	  p.upgradeTo(GovernableFundFlows.address);
	  */

	  /*
	  let gfflowub = await deployer.deploy(UpgradeableBeacon, GovernableFundFlows.address);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundFlowsUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
	  */

}