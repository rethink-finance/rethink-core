// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IWrappedTokenFactory {
	function createWrappedToken(address governanceToken) external returns (address wrappedToken);
}