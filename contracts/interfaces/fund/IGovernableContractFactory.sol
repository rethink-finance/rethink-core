// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IGovernableContractFactory {
	function createFundBeaconProxy(address _fund) external returns (address);
	function createRolesMod(address govContractAddr, address rolesModifier, address rolesModifier1) external returns (address);
}