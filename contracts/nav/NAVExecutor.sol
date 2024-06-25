// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

import "../interfaces/fund/IGovernableFundStorageFunctions.sol";

contract NAVExecutor {
	mapping(address => bytes) private encodedNAVUpdate;

	function storeNAVData(address oiv, bytes calldata data) external {
		//NOTE: should be called every time nav is updated from a governance proposal from within the same proposal
		address gov = IGovernableFundStorageFunctions(oiv).getFundSettings().governor;
		require(msg.sender == gov, "not authorized");
		encodedNAVUpdate[oiv] = data;
	}

	function getNAVData(address oiv) public view returns (bytes memory) {
		return encodedNAVUpdate[oiv];
	}
}