// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";

contract TestFundDepositActions is Base {
	function testFundDepositRequest() public {
		address[] memory allowedDepositAddrs;
		address fundAddr = this.createTestFund(address(this), allowedDepositAddrs, address(0));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
	}
	function testFundDepositRevoke() public {
		address[] memory allowedDepositAddrs;
		address fundAddr = this.createTestFund(address(this), allowedDepositAddrs, address(0));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.revokeDeposit(fundAddr);
	}
	function testFundDepositOnly() public {
		address[] memory allowedDepositAddrs;
		address fundAddr = this.createTestFund(address(this), allowedDepositAddrs, address(0));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
	}
}