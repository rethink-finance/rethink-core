// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../contracts/fund/GovernableFundFactory.sol";
import "../../contracts/external/OpenZeppelin/UpgradeableBeacon.sol";

contract Base {
    BeaconProxy gff;
    UpgradeableBeacon gffub;
    function setUp() public {
        //create sample fund factory
        gffub = new UpgradeableBeacon(address(new GovernableFundFactory()));
        gff = new BeaconProxy(address(gffub), "0x0");

        //initalzize

        /*
          function initialize(
            address governor//b
            address fund,//b
            address safeProxyFactory,
            address safeSingleton,
            address safeFallbackHandler,
            address safeMultisendAddress,
            address wrappedTokenFactory, //b
            address navCalculatorAddress,//bp
            address zodiacRolesModifierModule,//b
            address fundDelgateCallFlowSingletonAddress //b
            address fundDelgateCallNavSingletonAddress //b
            address governableContractFactorySingletonAddress //b
          )

          */

        gff.initialize(
            "0xB4c232f0cF194E530c39174F617Ec4ee9d69398C",//governor b
            "0x5A7f717B91c998d5DE9764DEA78c2EF20027bDe4",//fund b
            "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
            "0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
            "0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4",
            "0x40A2aCCbd92BCA938b02010E17A5b8929b49130D", //safeMultisendAddress
            "0xB9Ca0051232F773Bd3C6A7823E02449783a2B53F", //wrappedTokenFactory, b
            "0x248a64e3EDd3F521ef2Aa6A3e804845B5A1C8008",//navCalculatorAddress bp
            "0xdf587D859e76B0a6cE2254f1c0bf64C4aE0eD37f",//zodiacRolesModifierModule b 
            "0x8fE2e9470ceA2E83e8B89502d636CCAb2D1Ca21B",//fundDelgateCallFlowSingletonAddress b
            "0x89254d6FF377a21aC0b99BD2e456e75b6C76E505",//fundDelgateCallNavSingletonAddress b
            "0x89483Dc199F70268e3aB79D08301456Fb6aF75f4"//governableContractFactorySingletonAddress b
        )
    }
}