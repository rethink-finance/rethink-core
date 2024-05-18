const RethinkReader = artifacts.require("RethinkReader");


const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
//const proxy = "0xcd1e65B55cd73860FC80778C8398ae2f4C9222e8"; //goerli
const proxy = "0x89483Dc199F70268e3aB79D08301456Fb6aF75f4";//polygon
//time truffle migrate --reset -f 13 --to 13 --skip-dry-run --network=goerli
const network = "frax";
const isTest = false;

module.exports = async function (deployer) {
	
	//	constructor(address governableFundFactory, address nftCalculator) {

	if (isTest == true) {
		let rr = await deployer.deploy(RethinkReader, "0x2e71Eef0AE6C82902B6458655A36BfD7B76E6B2D", "0x26d70661664Fc2b4a1519Fa5766ccFF7E384a12F");
		setTimeout(function(){},delay);
		console.log("RethinkReader singleton is at: "+ RethinkReader.address);
	  } else {

	  	if (network == "matic") {
			let rr = await deployer.deploy(RethinkReader, "0x4C342E583A7Aa2840e07B4a3afB71533FBE37726", "0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008");
			setTimeout(function(){},delay);
			console.log("RethinkReader singleton is at: "+ RethinkReader.address);
		} else if (network == 'arb1') {
			let rr = await deployer.deploy(RethinkReader, "0x79b15F47640C4e3ac3A9c4B7f1B999a8cccEEeC7", "0x9825a09FbC727Bb671f08Fa66e3508a2e8938d45");
			setTimeout(function(){},delay);
			console.log("RethinkReader singleton is at: "+ RethinkReader.address);
		} else if (network == 'frax') {
			let rr = await deployer.deploy(RethinkReader, "", "");
			setTimeout(function(){},delay);
			console.log("RethinkReader singleton is at: "+ RethinkReader.address);
		}
	}
}