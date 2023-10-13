// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/fund/IRethinkFundGovernor.sol";
import "../interfaces/token/IWrappedTokenFactory.sol";
import "../interfaces/external/safe/ISafeProxyFactory.sol";
import "./InitSafeRolesModule.sol";

//https://wizard.openzeppelin.com/#governor

contract GovernableFundFactory is Initializable {
	address _governor;
	address _fund;
	address _safeProxyFactory;
	address _safeSingleton;
	address _safeFallbackHandler;
	address _wrappedTokenFactory;
	address _navCalculatorAddress;
	address _zodiacRolesModifierModule;//TODO: do we need to deploy our own roles contract? https://github.com/gnosis/zodiac-modifier-roles-v1/raw/main/packages/evm/contracts/Roles.sol
	address _fundDelgateCallFlowSingletonAddress;
	address[] _registeredFunds;

	mapping(address => address) baseTokenOracleMapping;//TODO: NOT IMP FOR STORAGE

	/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

	// keccak256(toUtf8Bytes('Safe Account Abstraction'))
	uint256 PREDETERMINED_SALT_NONCE = 0xb1073742015cbcf5a3a4d9d1ae33ecf619439710b89475f92e2abd2117e90f90;

	/*
	Goerli:
		safeProxyFactory -> https://goerli.etherscan.io/address/0xa6b71e26c5e0845f74c812102ca7114b6a896ab2#code
		safeSingleton -> https://goerli.etherscan.io/address/0x3E5c63644E683549055b9Be8653de26E0B4CD36E#code
		safeFallbackHandler -> "https://goerli.etherscan.io/address/0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4"
	*/
	function initialize(address governor, address fund, address safeProxyFactory, address safeSingleton, address safeFallbackHandler, address wrappedTokenFactory, address navCalculatorAddress, address zodiacRolesModifierModule, address fundDelgateCallFlowSingletonAddress) external initializer {
		_governor = governor;
		_fund = fund;
		_safeProxyFactory = safeProxyFactory;
		_safeSingleton = safeSingleton;
		_safeFallbackHandler = safeFallbackHandler;
		_wrappedTokenFactory = wrappedTokenFactory;
		_navCalculatorAddress = navCalculatorAddress;
		_zodiacRolesModifierModule = zodiacRolesModifierModule;
		_fundDelgateCallFlowSingletonAddress = fundDelgateCallFlowSingletonAddress;
	}

	function registeredFundsLength() public view returns (uint256) {
		return _registeredFunds.length;
	}

	function registeredFunds(uint256 start, uint256 end) public view returns (address[] memory) {
		address[] memory subRegisterdFunds = new address[](end-start);
		for(uint i=start; i<end;i++) {
			subRegisterdFunds[i-start] = _registeredFunds[i];
		}
		return subRegisterdFunds;
	}

	function registeredFundsData(uint256 start, uint256 end) public view returns (address[] memory, IGovernableFund.Settings[] memory) {
		address[] memory subRegisterdFunds = new address[](end-start);
		IGovernableFund.Settings[] memory settings = new IGovernableFund.Settings[](end-start);

		for(uint i=start; i<end;i++) {
			subRegisterdFunds[i-start] = _registeredFunds[i];
			settings[i-start] = IGovernableFund(_registeredFunds[i]).getFundSettings();
		}
		return (subRegisterdFunds, settings);
	}

    function createFund(IGovernableFund.Settings memory fundSettings) external returns (address) {
	    //create erc20 wrapper if needed
	    if ((fundSettings.isExternalGovTokenInUse == true) && (fundSettings.governanceToken != address(0))) {
	    	try IVotes(fundSettings.governanceToken).getVotes(msg.sender) returns (uint256) {
            	//compatable, can use address directly in RethinkFundGovernor
	        } catch (bytes memory /*lowLevelData*/) {
            	//not compatable, can not use address directly in RethinkFundGovernor, create wrapper
            	address govToken = IWrappedTokenFactory(_wrappedTokenFactory).createWrappedToken(fundSettings.governanceToken);
            	fundSettings.governanceToken = govToken;
	        }
	    }

	    //create proxy around governor
	    address govContractAddr = address(new BeaconProxy(_governor, ""));

	    /*
	    	NOTE: enabling zodiac role modifier enable modules from data field, but can be and external contract that can run any priveleged functions on safe state.because this is doing a delegatecall
	    */

	    //create proxy around zodiac roles modifier making governance contract owner of role
	    address rolesModifier = address(new BeaconProxy(_zodiacRolesModifierModule, ""));
	    address rolesModuleInitializer = address(new InitSafeRolesModule(govContractAddr, rolesModifier));

	    bytes memory enableZodiacModule = abi.encodeWithSelector(
            bytes4(keccak256("enableRoleMod()"))
        );

        address[] memory safeOwners = new address[](1);
        safeOwners[0] = govContractAddr;

	    bytes memory initializer = abi.encodeWithSelector(
	    	bytes4(keccak256("setup(address[],uint256,address,bytes,address,address,uint256,address)")),
	    	safeOwners,
	    	1,
	    	rolesModuleInitializer,//to for setupModules, otherwise, should be null if data is null
	    	enableZodiacModule,//data setupModules
	    	address(0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4),//_safeFallbackHandler,
	    	address(0),
	    	0,
	    	address(0)
	    );

	    //create safe proxy w/ gov token + govener
	    address safeProxyAddr = address(ISafeProxyFactory(_safeProxyFactory).createProxyWithNonce(_safeSingleton, initializer, PREDETERMINED_SALT_NONCE));
	    fundSettings.safe = safeProxyAddr;

	    /*

	    TODO: need to figure out how to setup roles mod contract after everything is done
	    bytes memory initParams = abi.encode(govContractAddr, safeProxyAddr, address(0));
        IRolesV1(rolesModifier).setUp(initParams);

        */

	    
	    //create proxy around fund
	    address fundContractAddr = address(new BeaconProxy(_fund, ""));

	    _registeredFunds.push(fundContractAddr);

	    if (fundSettings.governanceToken == address(0)){
	    	fundSettings.governanceToken = fundContractAddr;
	    }
	    fundSettings.fundAddress = fundContractAddr;

	    //initialize governor w/ gov token
	    IRethinkFundGovernor(govContractAddr).initialize(fundSettings.governanceToken, fundSettings.fundName);

	    //initialize fund proxy
	    IGovernableFund(fundContractAddr).initialize(fundSettings.fundName, fundSettings.fundSymbol, fundSettings, _navCalculatorAddress, _fundDelgateCallFlowSingletonAddress);
	    return fundContractAddr;
    }
}