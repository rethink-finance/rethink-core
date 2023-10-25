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
const proxy = "0xB227079f5c5b700E99afC1715A799DD008fCDD22";
//time truffle migrate --reset -f 3 --to 3 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gf = await deployer.deploy(GovernableFund);
	setTimeout(function(){},delay);
	console.log("GovernableFund singleton is at: "+ GovernableFund.address);

	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(GovernableFund.address);
}