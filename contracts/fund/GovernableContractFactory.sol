// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../external/OpenZeppelin/GovernableFundBeaconProxy.sol";
import "./InitSafeRolesModule.sol";


contract GovernableContractFactory {
	/// @custom:oz-upgrades-unsafe-allow constructor
	
	function createFundBeaconProxy(address _fund)  external returns (address) {
		//create proxy around fund
	    address fundContractAddr = address(new GovernableFundBeaconProxy(_fund, ""));
	    return fundContractAddr;
	}

	function createRolesMod(address govContractAddr, address rolesModifier)  external returns (address) {
		address rolesModuleInitializer = address(new InitSafeRolesModule(govContractAddr, rolesModifier));
		return rolesModuleInitializer;
	}
}