// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";

contract TestFundFees is Base {
	/*
		enum FundFeeType {
				DepositFee,
				WithdrawFee,
				ManagementFee,
				PerformanceFee
			}
	*/
	function testFlowFeeCollectionDAODisabled() public {}
	function testDepositFeeCollectionDAODisabled() public {}
	function testWithdrawFeeCollectionDAODisabled() public {}
	function testManagementFeeCollectionDAODisabled() public {}
	function testPerformanceFeeCollectionDAODisabled() public {}
	function testFlowFeeCollectionDAOEnabled() public {}
	function testDepositFeeCollectionDAOEnabled() public {}
	function testWithdrawFeeCollectionDAOEnabled() public {}
	function testManagementFeeCollectionDAOEnabled() public {}
	function testPerformanceFeeCollectionDAOEnabled() public {}
}