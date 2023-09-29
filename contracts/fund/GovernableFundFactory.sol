pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/fund/IRethinkFundGoverner.sol";
import "../token/WrappedToken.sol";
import "../interfaces/external/safe/ISafeProxyFactory.sol";
import "../external/safe/SafeProxy.sol";


contract UnderlyingCreditProviderFactory {
	address _governer;
	address _fund;
	address _safeProxyFactory;
	address _safeSingleton;
	address _safeFallbackHandler;

	// keccak256(toUtf8Bytes('Safe Account Abstraction'))
	uint256 PREDETERMINED_SALT_NONCE = 0xb1073742015cbcf5a3a4d9d1ae33ecf619439710b89475f92e2abd2117e90f90;

	constructor(address governer, address fund, address safeProxyFactory, address safeSingleton, address safeFallbackHandler) {
		_governer = governer;
		_fund = fund;
		_safeProxyFactory = safeProxyFactory;
		_safeSingleton = safeSingleton;
		_safeFallbackHandler = safeFallbackHandler;
	}

    function createFund(IGovernableFund.Settings memory fundSettings) external returns (address) {
    	/*
    	TODO: 
	    	initialize fund proxy


	    struct Settings {
			uint256 depositFee;
			uint256 withdrawFee;
			uint256 performanceFee;
			uint256 managementFee;
			uint256 performaceHurdleRateBps;
			address baseToken;
			address safe; //TODO: needs to be set after safe creation
			bool isExternalGovTokenInUse;
			bool isWhitelistedDeposits;
			address[] allowedDepositAddrs;
			address[] allowedManagers;
			address governanceToken;
			address governor;
			string fundName;
			string fundSymbol;
		}
	    */

	    //create erc20 wrapper if needed
	    if ((fundSettings.isExternalGovTokenInUse == true) && (fundSettings.governanceToken != address(0))) {
	    	try IVotes(fundSettings.governanceToken).getVotes(msg.sender) returns (uint256) {
            	//compatable, can use address directly in RethinkFundGoverner
	        } catch (bytes memory /*lowLevelData*/) {
            	//not compatable, can not use address directly in RethinkFundGoverner, create wrapper
            	address govToken = address(new WrappedToken(fundSettings.governanceToken));
            	fundSettings.governanceToken = govToken;
	        }
	    }

	    //create proxy around governer
	    address govContractAddr = address(new ERC1967Proxy(_governer, ""));

	    bytes memory initializer = abi.encodeWithSelector(
	    	bytes4(keccak256("setup(address[],uint256,address,bytes,address,address,uint256,address)")),
	    	[govContractAddr],
	    	1,
	    	address(0),
	    	"",
	    	_safeFallbackHandler,
	    	address(0),
	    	0,
	    	address(0)
	    );
	    
	    //create safe proxy w/ gov token + govener
	    address safeProxyAddr = address(ISafeProxyFactory(_safeProxyFactory).createProxyWithNonce(_safeSingleton, initializer, PREDETERMINED_SALT_NONCE));
	    fundSettings.safe = safeProxyAddr;

	    //create proxy around fund
	    address fundContractAddr = address(new ERC1967Proxy(_fund, ""));

	    if (fundSettings.governanceToken == address(0)){
	    	fundSettings.governanceToken = fundContractAddr;
	    }

	    //initialize governer w/ gov token
	    IRethinkFundGoverner(govContractAddr).initialize(fundSettings.governanceToken, fundSettings.fundName);
	    
	    //initialize fund proxy
	    IGovernableFund(fundContractAddr).initialize(fundSettings.fundName, fundSettings.fundSymbol, fundSettings);
    }
}