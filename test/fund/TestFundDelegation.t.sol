// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";

contract TestFundDelegation is Base {
	function testFundDelegationAfterDeposit() public {
		 address[] memory allowedDepositAddrs;

		 vm.startPrank(0xe977757dA5fd73Ca3D2bA6b7B544bdF42bb2CBf6);
	     address fundAddr = createTestFund(address(this), allowedDepositAddrs, address(0));
		 vm.stopPrank();

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));
	}
}