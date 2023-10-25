const GovernableFundFlows = artifacts.require("GovernableFundFlows");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0xa6b8e3aB971D9e5caF7081c1595F2f8790682eF3";

//time truffle migrate --reset -f 7 --to 7 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  await deployer.deploy(GovernableFundFlows);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundFlows singleton is at: "+ GovernableFundFlows.address);

	  //let gfflowprox = await deployer.deploy(TransparentUpgradeableProxy, GovernableFundFlows.address, owner, execData);
	  //setTimeout(function(){},delay);
	  //console.log("GovernableFundFlowsTransparentUpgradeableProxy singleton is at: "+ gfflowprox.address);

	  let p = await UpgradeableBeacon.at(proxy);
	  setTimeout(function(){},delay);
	  p.upgradeTo(GovernableFundFlows.address);
}