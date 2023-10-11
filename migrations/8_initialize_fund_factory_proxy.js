const GovernableFundFactory = artifacts.require("GovernableFundFactory");

//import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

const delay = 10000;
const owner = "0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6";
const execData = "0x";
const proxy = "";

//time truffle migrate --reset -f 8 --to 8 --skip-dry-run --network=goerli

module.exports = async function (deployer) {
	  let gff = await GovernableFundFactory.at("0x400BE5414e3d0aDab7FB0B2848DA1F2087FdB2D6");

	  /*
	  function initialize(
	  	address governor,b
	  	address fund,//b
	  	address safeProxyFactory,
	  	address safeSingleton,
	  	address safeFallbackHandler,
	  	address wrappedTokenFactory,
	  	address navCalculatorAddress,//bp
	  	address zodiacRolesModifierModule,//b
	  	address fundDelgateCallFlowSingletonAddress //bp
	  )

	  */
	  await gff.initialize(
	  	"0x81b3d2E995a993Bb8CDa8bfF489eaabe7A976338",
	  	"0x7A0Ee2D6501678F2A9713112c35AE4651Bc037E0", 
	  	"0xa6b71e26c5e0845f74c812102ca7114b6a896ab2",
	  	"0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
	  	"0x0000000000000000000000000000000000000000",
	  	"0x0638cAb73aC3902E0B2E9BBC49BAfcDf18774Add",
	  	"0xA6e6677BeD07690135dB380e069725D25e7a7660",
	  	"0x66fDE41ecc9c6a7C7C42851dEedd8A456A6b1b2A", 
	  	"0xC8d9257Ef8fa4D28123faEf053a6D7F6AF6861E6"
	  );
}