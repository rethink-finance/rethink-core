const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const ZodiacRolesV1Modifier = artifacts.require("RolesV1");
const Permissions = artifacts.require("Permissions");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const fundFactoryProxy = "0x44145C066A0cafe98991DAE3604a2f2f47FED37c";
const execData = "0x";
const proxy = "0xb3aec0e144e46ee4290ad93cc05609c160413087";
const zeroAddr = "0x0000000000000000000000000000000000000000";

//time truffle migrate --reset -f 6 --to 6 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  //await deployer.deploy(Permissions);
	  //setTimeout(function(){},delay);
	  let perms = await Permissions.at("0x73f6018958118b17645f1641a20dc339777923e0");
	  await deployer.link(perms, ZodiacRolesV1Modifier);
	  let zrv1 = await deployer.deploy(ZodiacRolesV1Modifier, fundFactoryProxy, zeroAddr, zeroAddr);
	  setTimeout(function(){},delay);
	  console.log("ZodiacRolesV1Modifier singleton is at: "+ ZodiacRolesV1Modifier.address);

	  let p = await UpgradeableBeacon.at(proxy);
	  setTimeout(function(){},delay);
	  p.upgradeTo(ZodiacRolesV1Modifier.address);
}