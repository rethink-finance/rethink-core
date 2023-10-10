const GovernableFund = artifacts.require("GovernableFund");
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

//time truffle migrate --reset -f 6 --to 6 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  //await deployer.deploy(Permissions);
	  //setTimeout(function(){},delay);
	  let perms = await Permissions.at("0x73f6018958118b17645f1641a20dc339777923e0");
	  await deployer.link(perms, ZodiacRolesV1Modifier);
	  let zrv1 = await deployer.deploy(ZodiacRolesV1Modifier);//, "0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000");
	  setTimeout(function(){},delay);
	  console.log("ZodiacRolesV1Modifier singleton is at: "+ zrv1.address);

	  let zrv1prox = await deployer.deploy(TransparentUpgradeableProxy, zrv1.address, owner, execData);
	  setTimeout(function(){},delay);
	  console.log("ZodiacRolesV1ModifierTransparentUpgradeableProxy singleton is at: "+ zrv1prox.address);

	  //let p = await ITransparentUpgradeableProxy.at(proxy);
	  //setTimeout(function(){},delay);
	  //p.upgradeTo();
}