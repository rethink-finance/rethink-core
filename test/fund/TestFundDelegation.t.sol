// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "forge-std/console.sol";

contract TestFundDelegation is Base {
	function testFundDelegationAfterDeposit() public {
		address[] memory allowedDepositAddrs;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (bool success, bytes memory data) = gff.call(gffCreateFund);
        require(success == true, "fail createFund");

        console.logBytes(data);//TODO: note this is not addres but some kind of code for a contract that is returned here
        address fundAddr = abi.decode(data, (address));

        //IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        //Agent bob = new Agent();
        //bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        //bob.deposit(fundAddr);
        //bob.delegate(fundAddr, address(bob));
	}
}