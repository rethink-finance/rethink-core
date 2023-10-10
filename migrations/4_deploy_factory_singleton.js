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
const proxy = "0x29680E257ff42d2d57Bb13A90FDc45019b771217";
//time truffle migrate --reset -f 4 --to 4 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gff = await deployer.deploy(GovernableFundFactory);
	setTimeout(function(){},delay);
	console.log("GovernableFundFactory singleton is at: "+ GovernableFundFactory.address);

	let p = await ITransparentUpgradeableProxy.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(GovernableFundFactory.address);
	//console.log(p);
}