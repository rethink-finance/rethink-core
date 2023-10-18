const ERC20 = artifacts.require("ERC20Mock");
//time truffle migrate --reset -f 10 --to 10 --skip-dry-run --network=goerli
const delay = 10000;

module.exports = async function (deployer) {
  const FakeDAI = await deployer.deploy(ERC20, 18, "FakeDAI");
	  setTimeout(function(){},delay);
  console.log("FakeDAI is at: "+ ERC20.address);
  const FakeUSDC = await deployer.deploy(ERC20, 6, "FakeUSDC");
	  setTimeout(function(){},delay);
  console.log("FakeUSDC is at: "+ ERC20.address);
  const FakeBTC = await deployer.deploy(ERC20, 18, "FakeBTC");
	  setTimeout(function(){},delay);
  console.log("FakeBTC is at: "+ ERC20.address);
  const FakeETH = await deployer.deploy(ERC20, 18, "FakeETH");
	  setTimeout(function(){},delay);
  console.log("FakeETH is at: "+ ERC20.address);
  const FakeMATIC = await deployer.deploy(ERC20, 18, "FakeMATIC");
	  setTimeout(function(){},delay);
  console.log("FakeMATIC is at: "+ ERC20.address);
  const FakeAVAX = await deployer.deploy(ERC20, 18, "FakeAVAX");
	  setTimeout(function(){},delay);
  console.log("FakeAVAX is at: "+ ERC20.address);
}