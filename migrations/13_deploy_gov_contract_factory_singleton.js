const GovernableContractFactory = artifacts.require("GovernableContractFactory");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");


const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "";
//time truffle migrate --reset -f 13 --to 13 --skip-dry-run --network=goerli
module.exports = async function (deployer) {
	/*
	let gff = await deployer.deploy(GovernableContractFactory);
	setTimeout(function(){},delay);
	console.log("GovernableContractFactory singleton is at: "+ GovernableContractFactory.address);

	let ub = await UpgradeableBeacon.at(proxy);
	setTimeout(function(){},delay);
	ub.upgradeTo(GovernableContractFactory.address);
	
	*/
  	let gffub = await deployer.deploy(UpgradeableBeacon, "0x787c2d74fbbc6beb91236271df09b71f99788453");
  	setTimeout(function(){},delay);
  	console.log("GovernableContractFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
  	/**/
}