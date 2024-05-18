const GovernableContractFactory = artifacts.require("GovernableContractFactory");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");


const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
//const proxy = "0xcd1e65B55cd73860FC80778C8398ae2f4C9222e8"; //goerli
const proxy = "0x89483Dc199F70268e3aB79D08301456Fb6aF75f4";//polygon
//time truffle migrate --reset -f 13 --to 13 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	let gff = await deployer.deploy(GovernableContractFactory);
	setTimeout(function(){},delay);
	console.log("GovernableContractFactory singleton is at: "+ GovernableContractFactory.address);

	/*
	let ub = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	//ub.upgradeTo("0xd6d86a6B9207AdB6BFf1949aa440cdE23AdC1e77");
	ub.upgradeTo(GovernableContractFactory.address);
	*/
	
	/*
  	let gffub = await deployer.deploy(UpgradeableBeacon, GovernableContractFactory.address);
  	setTimeout(function(){},delay);
  	console.log("GovernableContractFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
  	*/
}