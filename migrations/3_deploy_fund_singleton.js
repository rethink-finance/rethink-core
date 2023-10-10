const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const ZodiacRolesV1Modifier = artifacts.require("RolesV1");
const TransparentUpgradeableProxy = artifacts.require("TransparentUpgradeableProxy");
const ITransparentUpgradeableProxy = artifacts.require("ITransparentUpgradeableProxy");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0x988c368be3ab87817A2503779e3757546765F73A";
//time truffle migrate --reset -f 3 --to 3 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gf = await deployer.deploy(GovernableFund);
	setTimeout(function(){},delay);
	console.log("GovernableFund singleton is at: "+ GovernableFund.address);

	let p = await ITransparentUpgradeableProxy.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(GovernableFund.address);
}