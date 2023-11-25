const NAVCalculator = artifacts.require("NAVCalculator");
//const UniswapV2OracleLibrary = artifacts.require("UniswapV2OracleLibrary");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "0xCcbAEE52f73e52c3DC7859289ba13Ce93A84dbED";//goerli
//const proxy = "0xe0D8ca6d6b67E39dfADC137B675455Bc1ee5bCdd";//matic

//time truffle migrate --reset -f 5 --to 5 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	/*
	  let univ2olib = await deployer.deploy(UniswapV2OracleLibrary);
	  setTimeout(function(){},delay);
	  await deployer.link(UniswapV2OracleLibrary, NAVCalculator);

	*/

	/*
	let nc = await deployer.deploy(NAVCalculator);
	setTimeout(function(){},delay);
	console.log("NAVCalculator singleton is at: "+ NAVCalculator.address);
	*/

	let p = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	//p.upgradeTo(NAVCalculator.address);
	p.upgradeTo("0xe7c525a5efaf393b73b0881f97e76e59d48652b4");
	//console.log(p);
}