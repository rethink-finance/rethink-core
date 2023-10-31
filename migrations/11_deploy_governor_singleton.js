const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0x30DB0Ca15AfB8a9D6ec6e3e377207B9E995E1901";
//time truffle migrate --reset -f 11 --to 11 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gf = await deployer.deploy(RethinkFundGoverner);
	setTimeout(function(){},delay);
	console.log("RethinkFundGoverner singleton is at: "+ RethinkFundGoverner.address);

	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(RethinkFundGoverner.address);
}