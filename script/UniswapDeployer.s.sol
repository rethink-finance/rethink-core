// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >0.8.0;

import {Script} from "forge-std/Script.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract UniswapDeployer is Script, StdCheats {
	function run() public {
		deployCodeTo(
			"UniswapV2Factory.sol:UniswapV2Factory",
			abi.encode(address(0)),
			0x3c4293F66941eCA00f4950C10D4255D5c271Ba1f
		);

		deployCodeTo(
			"UniswapV2Router02.sol:UniswapV2Router02",
			abi.encode(0x3c4293F66941eCA00f4950C10D4255D5c271Ba1f, 0x3C4293F66941ECA00F4950C10d4255D5c271ba0F),
			0x3C4293F66941eCA00f4950c10d4255d5c271bA2f
		);
	}
}