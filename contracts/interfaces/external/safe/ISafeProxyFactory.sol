pragma solidity ^0.8.0;

import "../../../external/safe/SafeProxy.sol";

interface ISafeProxyFactory {
	function createProxyWithNonce(address _singleton, bytes memory initializer, uint256 saltNonce) external returns (SafeProxy proxy);
}