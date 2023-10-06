const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const ZodiacRolesV1Modifier = artifacts.require("RolesV1");
const TransparentUpgradeableProxy = artifacts.require("TransparentUpgradeableProxy");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
module.exports = async function (deployer) {
  let wtf = await deployer.deploy(WrappedTokenFactory);
  setTimeout(function(){},delay);
  console.log("WrappedTokenFactory is at: "+ WrappedTokenFactory.address);

  let gff = await deployer.deploy(GovernableFundFactory);
  setTimeout(function(){},delay);
  console.log("GovernableFundFactory singleton is at: "+ gff.address);

  let gffprox = await deployer.deploy(TransparentUpgradeableProxy, gff.address, owner, execData);
  setTimeout(function(){},delay);
  console.log("GovernableFundFactoryTransparentUpgradeableProxy singleton is at: "+ gffprox.address);

  let nc = await deployer.deploy(NAVCalculator);
  setTimeout(function(){},delay);
  console.log("NAVCalculator singleton is at: "+ nc.address);

  let ncprox = await deployer.deploy(TransparentUpgradeableProxy, nc.address, owner, execData);
  setTimeout(function(){},delay);
  console.log("NAVCalculatorTransparentUpgradeableProxy singleton is at: "+ ncprox.address);

  let rtfg = await deployer.deploy(RethinkFundGoverner);
  setTimeout(function(){},delay);
  console.log("RethinkFundGoverner singleton is at: "+ rtfg.address);

  let rtfgprox = await deployer.deploy(TransparentUpgradeableProxy, rtfg.address, owner, execData);
  setTimeout(function(){},delay);
  console.log("RethinkFundGovernerTransparentUpgradeableProxy singleton is at: "+ rtfgprox.address);

  let gf = await deployer.deploy(GovernableFund);
  setTimeout(function(){},delay);
  console.log("GovernableFund singleton is at: "+ gf.address);

  let gfprox = await deployer.deploy(TransparentUpgradeableProxy, gf.address, owner, execData);
  setTimeout(function(){},delay);
  console.log("GovernableFundTransparentUpgradeableProxy singleton is at: "+ gfprox.address);

  let zrv1 = await deployer.deploy(ZodiacRolesV1Modifier);
  setTimeout(function(){},delay);
  console.log("ZodiacRolesV1Modifier singleton is at: "+ zrv1.address);

  let zrv1prox = await deployer.deploy(TransparentUpgradeableProxy, zrv1.address, owner, execData);
  setTimeout(function(){},delay);
  console.log("ZodiacRolesV1ModifierTransparentUpgradeableProxy singleton is at: "+ zrv1prox.address);
};
