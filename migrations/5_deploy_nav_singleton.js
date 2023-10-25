const NAVCalculator = artifacts.require("NAVCalculator");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0xCcbAEE52f73e52c3DC7859289ba13Ce93A84dbED";

//time truffle migrate --reset -f 5 --to 5 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	let nc = await deployer.deploy(NAVCalculator);
	setTimeout(function(){},delay);
	console.log("NAVCalculator singleton is at: "+ NAVCalculator.address);

	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	p.upgradeTo(NAVCalculator.address);
	//console.log(p);
}