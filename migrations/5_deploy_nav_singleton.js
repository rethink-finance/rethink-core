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
const proxy = "0xE1855889FD9E2c0793c1fB8FFF558648e9EE7e4f";

//time truffle migrate --reset -f 5 --to 5 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	let nc = await deployer.deploy(NAVCalculator);
	setTimeout(function(){},delay);
	console.log("NAVCalculator singleton is at: "+ NAVCalculator.address);

	let p = await ITransparentUpgradeableProxy.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(NAVCalculator.address);
	//console.log(p);
}