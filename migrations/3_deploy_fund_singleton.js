const GovernableFund = artifacts.require("GovernableFund");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0xCEed8bA2ea5B30eDf31a4c022F51FF0FE4d30166";//goerli
//const proxy = "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4";//polygon
//time truffle migrate --reset -f 3 --to 3 --skip-dry-run --compile-none --network=goerli
module.exports = async function (deployer) {
	let gf = await deployer.deploy(GovernableFund);
	setTimeout(function(){},delay);
	console.log("GovernableFund singleton is at: "+ GovernableFund.address);

	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(GovernableFund.address);
}