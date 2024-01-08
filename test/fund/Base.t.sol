// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../contracts/fund/GovernableFundFactory.sol";
//import "../../contracts/fund/RethinkFundGovernor.sol";
import "../../contracts/token/WrappedTokenFactory.sol";
import "../../contracts/nav/NAVCalculator.sol";
import "../../contracts/external/OpenZeppelin/UpgradeableBeacon.sol";

contract Base {
    BeaconProxy gff;
    UpgradeableBeacon gffub;
    function setUp() public {
        gffub = new UpgradeableBeacon(address(new GovernableFundFactory()));
        gff = new BeaconProxy(address(gffub), "0x0");
        address wtfub = address(new UpgradeableBeacon(address(new WrappedTokenFactory())));

        address navcalcub = address(new UpgradeableBeacon(address(new NAVCalculator())));
        address navcalcbp = address(new BeaconProxy(navcalcub, "0x0"));

        address rfgub = address(0);//address(new UpgradeableBeacon(address(new RethinkFundGovernor())));
        /* 
            TODO:  
                deploy governor b
                deploy fund b
                deploy zodaicroles b
                deploy fundflows b
                deploy fundnav b
                deploy gcf b
        */

        bytes memory gffinit = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address,address,address,address,address,address wrappedTokenFactory,address,address,address,address,address)")),
            rfgub,//governor b
            "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4",//fund b
            "0x0000000000000000000000000000000000000000",//safeProxyFactory ex
            "0x0000000000000000000000000000000000000000",//safeSingleton ex
            "0x0000000000000000000000000000000000000000",//safeFallbackHandler ex
            "0x0000000000000000000000000000000000000000", //safeMultisendAddress ex
            wtfub, //wrappedTokenFactory, b
            navcalcbp,//navCalculatorAddress bp
            "0xdf587D859e76B0a6cE2254f1c0bf64C4aE0eD37f",//zodiacRolesModifierModule b 
            "0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B",//fundDelgateCallFlowSingletonAddress b
            "0x89254d6FF377a21aC0b99BD2e456e75b6C76E505",//fundDelgateCallNavSingletonAddress b
            "0x89483Dc199F70268e3aB79D08301456Fb6aF75f4"//governableContractFactorySingletonAddress b
        );
        (bool success,) = address(gff).call(gffinit);
        require(success == true, "fail gff init");
    }
}