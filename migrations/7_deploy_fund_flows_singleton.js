const GovernableFundFlows = artifacts.require("GovernableFundFlows");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const ZodiacRolesV1Modifier = artifacts.require("RolesV1");
const Permissions = artifacts.require("Permissions");
const TransparentUpgradeableProxy = artifacts.require("TransparentUpgradeableProxy");
const ITransparentUpgradeableProxy = artifacts.require("ITransparentUpgradeableProxy");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "";

//time truffle migrate --reset -f 7 --to 7 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  await deployer.deploy(GovernableFundFlows);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundFlows singleton is at: "+ GovernableFundFlows.address);

	  let gfflowprox = await deployer.deploy(TransparentUpgradeableProxy, GovernableFundFlows.address, owner, execData);
	  setTimeout(function(){},delay);
	  console.log("GovernableFundFlowsTransparentUpgradeableProxy singleton is at: "+ gfflowprox.address);

	  //let p = await ITransparentUpgradeableProxy.at(proxy);
	  //setTimeout(function(){},delay);
	  //p.upgradeTo();
}