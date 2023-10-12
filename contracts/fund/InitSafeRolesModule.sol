// SPDX-License-Identifier: GPL-3.0-only
/* solhint-disable one-contract-per-file */
pragma solidity ^0.8.0;

interface ISafe {
    function enableModule(address module) external;
}

interface IRolesV1 {
    function setUp(bytes memory initParams) external;
    function transferOwnership(address ownr) external;
}

contract InitSafeRolesModule {
    address public immutable RoleModAddr;
    address public immutable RoleOwner;
    
    constructor(address rolesModOwner, address rolesModAddr) {
        RoleModAddr = rolesModAddr;
        RoleOwner = rolesModOwner;
    }

    function enableRoleMod() public {
        ISafe(address(this)).enableModule(RoleModAddr);
    }
}