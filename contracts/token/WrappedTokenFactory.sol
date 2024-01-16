// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../token/WrappedToken.sol";
import "../token/veWrappedToken.sol";

contract WrappedTokenFactory {
    function createWrappedToken(address governanceToken) external returns (address wrappedToken) {
    	wrappedToken = address(new WrappedToken(governanceToken));
    }

    function createVeWrappedToken(address governanceToken) external returns (address wrappedToken) {
        wrappedToken = address(new veWrappedToken(governanceToken));
    }
}