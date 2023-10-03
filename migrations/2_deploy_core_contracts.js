const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const TransparentUpgradeableProxy = artifacts.require("TransparentUpgradeableProxy");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0x";
const execData = "0x";
module.exports = async function (deployer) {
  let gff = await deployer.deploy(GovernableFundFactory);
  console.log("GovernableFundFactory singleton is at: "+ gff.address);
  setTimeout(function(){},delay);

  let gffprox = await deployer.deploy(TransparentUpgradeableProxy, gff.address, owner, execData);
  console.log("GovernableFundFactoryTransparentUpgradeableProxy singleton is at: "+ gffprox.address);
  setTimeout(function(){},delay);

  let nc = await deployer.deploy(NAVCalculator);
  console.log("NAVCalculator singleton is at: "+ nc.address);
  setTimeout(function(){},delay);

  let ncprox = await deployer.deploy(TransparentUpgradeableProxy, nc.address, owner, execData);
  console.log("NAVCalculatorTransparentUpgradeableProxy singleton is at: "+ ncprox.address);
  setTimeout(function(){},delay);

  let gf = await deployer.deploy(GovernableFund);
  console.log("GovernableFund singleton is at: "+ gf.address);
  setTimeout(function(){},delay);

  let gfprox = await deployer.deploy(TransparentUpgradeableProxy, gf.address, owner, execData);
  console.log("GovernableFundTransparentUpgradeableProxy singleton is at: "+ gfprox.address);
  setTimeout(function(){},delay);

};
