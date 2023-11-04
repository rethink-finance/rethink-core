// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/fund/IGovernableFund.sol";
import "../interfaces/fund/IRethinkFundGovernor.sol";
import "../interfaces/fund/IGovernableContractFactory.sol";
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
	address _fundDelgateCallNavSingletonAddress;
	address[] _registeredFunds;

	mapping(address => address) baseTokenOracleMapping;//TODO: NOT IMP FOR STORAGE
	address _governableContractFactory;
	address _safeMultisendAddress;

	struct GovernorParams {
		uint256 quorumFraction;
		uint256 lateQuorum;
		uint256 votingDelay;
		uint256 votingPeriod;
	}

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
	
	//function initialize(address governor, address fund, address safeProxyFactory, address safeSingleton, address safeFallbackHandler, address wrappedTokenFactory, address navCalculatorAddress, address zodiacRolesModifierModule, address fundDelgateCallFlowSingletonAddress, address fundDelgateCallNavSingletonAddress, governableContractFactorySingletonAddress) external initializer {

	function initialize(address governor, address fund, address safeProxyFactory, address safeSingleton, address safeFallbackHandler, address safeMultisendAddress, address wrappedTokenFactory, address navCalculatorAddress, address zodiacRolesModifierModule, address fundDelgateCallFlowSingletonAddress, address fundDelgateCallNavSingletonAddress, address governableContractFactorySingletonAddress) external {
		_governor = governor;
		_fund = fund;
		_safeProxyFactory = safeProxyFactory;
		_safeSingleton = safeSingleton;
		_safeFallbackHandler = safeFallbackHandler;
		_safeMultisendAddress = safeMultisendAddress;
		_wrappedTokenFactory = wrappedTokenFactory;
		_navCalculatorAddress = navCalculatorAddress;
		_zodiacRolesModifierModule = zodiacRolesModifierModule;
		_fundDelgateCallFlowSingletonAddress = fundDelgateCallFlowSingletonAddress;
		_fundDelgateCallNavSingletonAddress = fundDelgateCallNavSingletonAddress;
		_governableContractFactory = governableContractFactorySingletonAddress;
	}

	function registeredFundsLength() public view returns (uint256) {
		return _registeredFunds.length;
	}

	function registeredFundsData(uint256 start, uint256 end) public view returns (address[] memory, IGovernableFundStorage.Settings[] memory) {
		address[] memory subRegisterdFunds = new address[](end-start);
		IGovernableFundStorage.Settings[] memory settings = new IGovernableFundStorage.Settings[](end-start);

		for(uint i=start; i<end;i++) {
			subRegisterdFunds[i-start] = _registeredFunds[i];
			settings[i-start] = IGovernableFund(_registeredFunds[i]).getFundSettings();
		}
		return (subRegisterdFunds, settings);
	}

    function createFund(IGovernableFundStorage.Settings memory fundSettings, GovernorParams memory governorSettings) external returns (address) {
	    //create erc20 wrapper if needed
	    if (fundSettings.governanceToken != address(0)) {
	    	try IVotes(fundSettings.governanceToken).getVotes(msg.sender) returns (uint256) {
            	//compatable, can use address directly in RethinkFundGovernor
	        } catch (bytes memory /*lowLevelData*/) {
            	//not compatable, can not use address directly in RethinkFundGovernor, create wrapper
            	address govToken = IWrappedTokenFactory(
            		IBeacon(_wrappedTokenFactory).implementation()
            		).createWrappedToken(fundSettings.governanceToken);
            	fundSettings.governanceToken = govToken;
	        }
            fundSettings.isExternalGovTokenInUse = true;
	    }

	    //create proxy around governor
	    address govContractAddr = address(new BeaconProxy(_governor, ""));

	    /*
	    	NOTE: enabling zodiac role modifier enable modules from data field, but can be and external contract that can run any priveleged functions on safe state.because this is doing a delegatecall
	    */

	    //create proxy around zodiac roles modifier making governance contract owner of role
	    address rolesModifier = address(new BeaconProxy(_zodiacRolesModifierModule, ""));

	    //create proxy around fund
	    address fundContractAddr = IGovernableContractFactory(
	    	IBeacon(_governableContractFactory).implementation()
	    ).createFundBeaconProxy(_fund);

	    address rolesModuleInitializer = IGovernableContractFactory(
	    	IBeacon(_governableContractFactory).implementation()
	    ).createRolesMod(govContractAddr, rolesModifier, fundContractAddr);

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
	    
	    _registeredFunds.push(fundContractAddr);

	    if (fundSettings.governanceToken == address(0)){
	    	fundSettings.governanceToken = fundContractAddr;
	    }
	    fundSettings.fundAddress = fundContractAddr;
	    fundSettings.governor = govContractAddr;

	    //initialize governor w/ gov token
	    initGovernor(govContractAddr, fundSettings, governorSettings);

	    if (fundSettings.allowedDepositAddrs.length > 0) {
	    	fundSettings.isWhitelistedDeposits = true;
	    }

	    //initialize fund proxy
	    IGovernableFund(fundContractAddr).initialize(fundSettings.fundName, fundSettings.fundSymbol, fundSettings, _navCalculatorAddress, _fundDelgateCallFlowSingletonAddress, _fundDelgateCallNavSingletonAddress);

	    IGovernableFundStorage.Settings memory settings = IGovernableFund(fundContractAddr).getFundSettings();
	    require(settings.governor != address(0), "fail fund init");

	    //init role mod
	    initRoleMod(safeProxyAddr, rolesModifier, govContractAddr);

	    return fundContractAddr;
    }

    function initGovernor(address govContractAddr, IGovernableFundStorage.Settings memory fundSettings, GovernorParams memory governorSettings) internal {
    	IRethinkFundGovernor(govContractAddr).initialize(
	    	fundSettings.governanceToken,
	    	fundSettings.fundName,
	    	governorSettings.quorumFraction,
	    	governorSettings.lateQuorum,
	    	governorSettings.votingDelay,
	    	governorSettings.votingPeriod
	    );
    }

    function initRoleMod(address safeProxyAddr, address rolesModifier, address govContractAddr) internal {
    	bool success;
	    //setup roles modifier with init owner of fund contract
	    bytes memory rolesModifierInitParams = abi.encode(address(this), safeProxyAddr, address(0));
	    bytes memory rolesModifierSetup = abi.encodeWithSelector(
            bytes4(keccak256("setUp(bytes)")),
            rolesModifierInitParams
        );
	    (success,) = rolesModifier.call(rolesModifierSetup);
	    require(success == true, "fail roles mod setup");

	    //set multisend addr on roles modifier
	    bytes memory rolesSetMultisend = abi.encodeWithSelector(
            bytes4(keccak256("setMultisend(address)")),
            _safeMultisendAddress
        );
        (success,) = rolesModifier.call(rolesSetMultisend);
	    require(success == true, "fail roles mod setMultisend");


	    //transfer ownership on roles modifier to govenor
	    bytes memory rolesTransferOwnership = abi.encodeWithSelector(
            bytes4(keccak256("transferOwnership(address)")),
            govContractAddr
        );
        (success,) = rolesModifier.call(rolesTransferOwnership);
	    require(success == true, "fail roles mod transferOwnership");
    }
}