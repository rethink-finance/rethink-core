// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {UnsafeUpgrades} from "openzeppelin-foundry-upgrades/LegacyUpgrades.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "../../contracts/token/WrappedTokenFactory.sol";
import "../../contracts/nav/NAVCalculator.sol";
import "../../contracts/fund/GovernableFund.sol";
import "../../contracts/fund/GovernableFundNav.sol";
import "../../contracts/fund/GovernableFundFlows.sol";
import "../../contracts/fund/GovernableContractFactory.sol";
import "../../contracts/fund/RethinkFundGovernor.sol";
import "../../contracts/token/ERC20Mock.sol";

import "../../contracts/interfaces/fund/IGovernableFundFactory.sol";

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafeL2.sol";
import "@gnosis.pm/safe-contracts/contracts/libraries/MultiSendCallOnly.sol";


contract Base is Test {
    struct GovernorParams {
        uint256 quorumFraction;
        uint256 lateQuorum;
        uint256 votingDelay;
        uint256 votingPeriod;
        uint256 proposalThreshold;
    }

    struct ZodicCode {
        bytes createAndInitCode;
        bytes defaultHandlerCreationCode;
    }

    struct BaseVariables {
        address wtfub;
        address navcalcub;
        address navcalcbp;
        address rfgub;

        address gfub;
        address zrv1;
    }
    

    address gff;
    address gffub;

    function setUp() public {
        gffub = UnsafeUpgrades.deployBeacon("GovernableFundFactory.sol", address(this));
        gff = address(new BeaconProxy(gffub, ""));

        BaseVariables memory bv;
        bv.wtfub = address(new UpgradeableBeacon(address(new WrappedTokenFactory())));
        bv.navcalcub = address(new UpgradeableBeacon(address(new NAVCalculator())));
        bv.navcalcbp = address(new BeaconProxy(bv.navcalcub, ""));
        bv.rfgub = address(new UpgradeableBeacon(address(new RethinkFundGovernor())));

        string memory json = vm.readFile(
            string(
                abi.encodePacked(vm.projectRoot(),"/data/zodiac_roles_v1_createnoinit.json")
            )
        );

        /*
        bytes memory rolesInitCode = json.parseBytes("createAndInitCode");

        */
        bytes memory rolesInitCodeData = vm.parseJson(json);
        ZodicCode memory zc = abi.decode(rolesInitCodeData, (ZodicCode));
        bytes memory rolesInitCode = zc.createAndInitCode;

        //HACK IN ORDER TO AVOID WEIRD INITSLIAZATION WITH NULL ADDR
        //000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001";

        bytes memory rolesInitMod = abi.encode(rolesInitCode,gff,gff,gff);
        

        bv.gfub = address(new UpgradeableBeacon(address(new GovernableFund())));
        bv.zrv1 = generateBytecode(rolesInitMod);
        require(bv.zrv1 != address(0), "bad zodiac singleton");
        address zrv1ub = address(new UpgradeableBeacon(bv.zrv1));


        address gfflowub = address(new UpgradeableBeacon(address(new GovernableFundFlows())));
        address gfnavub = address(new UpgradeableBeacon(address(new GovernableFundNav())));
        address gcfub = address(new UpgradeableBeacon(address(new GovernableContractFactory())));

        address safeProxyFactory = address(new GnosisSafeProxyFactory());
        address safeSingleton = address(new GnosisSafeL2());
        bytes memory defaultHandlerCreationCode = zc.defaultHandlerCreationCode;
        address safeFallbackHandler = generateBytecode(defaultHandlerCreationCode);
        address safeMultisendAddress = address(new MultiSendCallOnly());

        address[] memory gffInitData = new address[](12);

            /*
                initAddrs[0] -> _governor;
                initAddrs[1] -> _fund;
                initAddrs[2] -> _safeProxyFactory;
                initAddrs[3] -> _safeSingleton;
                initAddrs[4] -> _safeFallbackHandler;
                initAddrs[5] -> _safeMultisendAddress;
                initAddrs[6] -> _wrappedTokenFactory;
                initAddrs[7] -> _navCalculatorAddress;
                initAddrs[8] -> _zodiacRolesModifierModule;//TODO: do we need to deploy our own roles contract? https://github.com/gnosis/zodiac-modifier-roles-v1/raw/main/packages/evm/contracts/Roles.sol
                initAddrs[9] -> _fundDelgateCallFlowSingletonAddress;
                initAddrs[10] -> _fundDelgateCallNavSingletonAddress;
                initAddrs[11] -> _governableContractFactory;
            */

        gffInitData[0] = bv.rfgub;//,//governor b
        gffInitData[1] = bv.gfub;//,//fund b
        gffInitData[2] = safeProxyFactory;//,//safeProxyFactory ex
        gffInitData[3] = safeSingleton;//,//safeSingleton ex
        gffInitData[4] = safeFallbackHandler;//,//safeFallbackHandler ex
        gffInitData[5] = safeMultisendAddress;//, //safeMultisendAddress ex
        gffInitData[6] = bv.wtfub;//, //wrappedTokenFactory, b
        gffInitData[7] = bv.navcalcbp;//,//navCalculatorAddress bp
        gffInitData[8] = zrv1ub;//,//zodiacRolesModifierModule b 
        gffInitData[9] = gfflowub;//,//fundDelgateCallFlowSingletonAddress b
        gffInitData[10] = gfnavub;//;//,//fundDelgateCallNavSingletonAddress b
        gffInitData[11] = gcfub;////governableContractFactorySingletonAddress b

        initFundFactory(gffInitData);
        //create sample fund

        /*
        set up fake protocols
            - fake uniswapv2 router contract -> nav liquid
            - fake metavault reader contract -> nav composable
            - fake token -> nav illiquid
            - fake chainlink floor price oracle -> nav nft
        */
    }

    function generateBytecode(bytes memory cc) public returns (address out) {
        //https://ethereum.stackexchange.com/questions/127940/deploy-contract-with-bytecode-from-smart-contract
        bytes memory code = abi.encodePacked(
            hex"63",
            uint32(cc.length),
            hex"80_60_0E_60_00_39_60_00_F3",
            cc
        );

        uint256 size;
        (out, size) = internalCreate(code);
        require(size == cc.length, "bad code storage");
    }

    function internalCreate(bytes memory code) private returns (address out, uint256 size) {
        assembly {
            out := create(0, add(code, 0x20), mload(code))
            size := extcodesize(out)
        }
    }

    function initFundFactory(
        address[] memory gffInitData
    ) internal {
        /**/
        bytes memory gffcall = abi.encodeWithSelector(
            bytes4(keccak256("registeredFundsLength()"))
        );
        (bool success0,) = gff.call(gffcall);
        require(success0 == true, "fail gff registeredFundsLength");

        /**/

        bytes memory gffinit = abi.encodeWithSelector(
            bytes4(keccak256("initialize(uint256,address[])")),
            0xb1073742015cbcf5a3a4d9d1ae33ecf619439710b89475f92e2abd2117e90f90,
            gffInitData
        );
        (bool success,) = gff.call(gffinit);
        require(success == true, "fail gff init");
    }

    function createTestFund(address manager, address[] memory allowedDepositAddrs, address governanceToken) public returns (address) {
        //createFund((uint256,uint256,uint256,uint256,uint256,address,address,bool,bool,address[],address[],address,address,address,string,string,address[4]),(uint256,uint256,uint256,uint256,uint256),string,uint256,uint256)

        address baseToken = address(new ERC20Mock(18,"FakeDAI"));
        address[4] memory feeCollectors = [manager, manager, manager, manager];
        string memory fundName = "Test Fund DAO";
        string memory fundSymbol = "TFD-TEST";
        address[] memory allowedManagers = new address[](1);
        allowedManagers[0] = manager;

        //TODO: need to have non zero fee params for all

        IGovernableFundStorage.Settings memory fundSettings = IGovernableFundStorage.Settings(
            10,
            10,
            0,
            10,
            0,
            baseToken,
            address(0),
            false,
            false,
            allowedDepositAddrs,//allowedDepositAddrs
            allowedManagers,//allowedManagers,
            governanceToken,
            address(0),
            address(0),
            fundName,
            fundSymbol,
            feeCollectors
        );
        IGovernableFundFactory.GovernorParams memory governorSettings = IGovernableFundFactory.GovernorParams(
            1,//quorumFraction,
            60,//lateQuorum,
            0,//votingDelay,
            60,//votingPeriod,
            0//proposalThreshold,
        );

        string memory _fundMetadata = "{}";

        /*

        bytes memory gffCreateFund = abi.encodeWithSelector(
            0xc852850c,
            fundSettings,
            governorSettings,
            _fundMetadata,
            60*60*24*365,
            60*60*24*365
        );


        (bool success0, bytes memory data0 ) = gff.call(gffCreateFund);
        require(success0 == true, "fail createFund");
        console.logBytes(data0);
        
        //return abi.decode(data0, (address)); //TODO: issue with data0 not containing an address, but initcode of governable fund factory??

        */

        //  function createFund(IGovernableFundStorage.Settings memory fundSettings, GovernorParams memory governorSettings, string memory _fundMetadata, uint256 _feePerformancePeriod, uint256 _feeManagePeriod) external returns (address);

        return IGovernableFundFactory(gff).createFund(fundSettings, governorSettings, _fundMetadata, 60*60*24*365, 60*60*24*365);
    }
}