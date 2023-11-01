const GovernableFund = artifacts.require("GovernableFund");
const GovernableFundFactory = artifacts.require("GovernableFundFactory");
const RethinkFundGoverner = artifacts.require("RethinkFundGovernor");
const WrappedTokenFactory = artifacts.require("WrappedTokenFactory");
const NAVCalculator = artifacts.require("NAVCalculator");
const GovernableFundFlows = artifacts.require("GovernableFundFlows");
const GovernableFundNav = artifacts.require("GovernableFundNav");
const UpgradeableBeacon = artifacts.require("UpgradeableBeacon");
const BeaconProxy = artifacts.require("BeaconProxy");
const GovernableContractFactory = artifacts.require("GovernableContractFactory");

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
module.exports = async function (deployer) {

  /*
  let wtf = await deployer.deploy(WrappedTokenFactory);
  setTimeout(function(){},delay);
  console.log("WrappedTokenFactory is at: "+ WrappedTokenFactory.address);

  let wtfub = await deployer.deploy(UpgradeableBeacon, WrappedTokenFactory.address);
  setTimeout(function(){},delay);
  console.log("WrappedTokenFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);



  let gff = await deployer.deploy(GovernableFundFactory);
  setTimeout(function(){},delay);
  console.log("GovernableFundFactory singleton is at: "+ gff.address);

  let gffub = await deployer.deploy(UpgradeableBeacon, "0xA2bD864fd4B7f9c245a014cDCCFFBb142432725A");
  setTimeout(function(){},delay);
  console.log("GovernableFundFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  let gffbprox = await deployer.deploy(BeaconProxy, UpgradeableBeacon.address, execData);
  setTimeout(function(){},delay);
  console.log("GovernableFundFactoryBeaconProxy is at: "+ BeaconProxy.address);

  let nc = await deployer.deploy(NAVCalculator);
  setTimeout(function(){},delay);
  console.log("NAVCalculator singleton is at: "+ nc.address);

  let ncub = await deployer.deploy(UpgradeableBeacon, nc.address);
  setTimeout(function(){},delay);
  console.log("NAVCalculatorUpgradeableBeacon is at: "+ ncub.address);

  let ncbprox = await deployer.deploy(BeaconProxy, ncub.address, execData);
  setTimeout(function(){},delay);
  console.log("NAVCalculatorBeaconProxy is at: "+ ncbprox.address);



  let rtfg = await deployer.deploy(RethinkFundGoverner);
  setTimeout(function(){},delay);
  console.log("RethinkFundGoverner singleton is at: "+ rtfg.address);

  let rtfgub = await deployer.deploy(UpgradeableBeacon, rtfg.address);
  setTimeout(function(){},delay);
  console.log("RethinkFundGovernerUpgradeableBeacon is at: "+ rtfgub.address);
  

  let gf = await deployer.deploy(GovernableFund);
  setTimeout(function(){},delay);
  console.log("GovernableFund singleton is at: "+ gf.address);

  let gfub = await deployer.deploy(UpgradeableBeacon, "0xF914f02f658E2849405340b2Da9aDD19A303f82A");
  setTimeout(function(){},delay);
  console.log("GovernableFundUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  
  let zrv1 = await deployer.deploy(ZodiacRolesV1Modifier);
  setTimeout(function(){},delay);
  console.log("ZodiacRolesV1Modifier singleton is at: "+ ZodiacRolesV1Modifier.address);

  let zrv1ub = await deployer.deploy(UpgradeableBeacon, ZodiacRolesV1Modifier.address);
  setTimeout(function(){},delay);
  console.log("ZodiacRolesV1ModifierUpgradeableBeacon is at: "+ UpgradeableBeacon.address);


  let gfflow = await deployer.deploy(GovernableFundFlows);
  setTimeout(function(){},delay);
  console.log("GovernableFundFlows singleton is at: "+ GovernableFundFlows.address);

  let gfflowub = await deployer.deploy(UpgradeableBeacon, GovernableFundFlows.address);
  setTimeout(function(){},delay);
  console.log("GovernableFundFlowsUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  let gfnav = await deployer.deploy(GovernableFundNav);
  setTimeout(function(){},delay);
  console.log("GovernableFundNav singleton is at: "+ GovernableFundNav.address);

  let gfnavub = await deployer.deploy(UpgradeableBeacon, GovernableFundNav.address);
  setTimeout(function(){},delay);
  console.log("GovernableFundNavUpgradeableBeacon is at: "+ UpgradeableBeacon.address);

  let gcf = await deployer.deploy(GovernableContractFactory);
  setTimeout(function(){},delay);
  console.log("GovernableContractFactory singleton is at: "+ GovernableContractFactory.address);
  
  let gcfub = await deployer.deploy(UpgradeableBeacon, GovernableContractFactory.address);
  setTimeout(function(){},delay);
  console.log("GovernableContractFactoryUpgradeableBeacon is at: "+ UpgradeableBeacon.address);
  */
};
