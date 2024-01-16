// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "../../contracts/token/ERC20Mock.sol";

contract Agent {
	/*
		Agent memory bob = new Agent();
        bob.requestDeposit(fund, 10e18);
        bob.deposit(fund);
        bob.delegate(fund, address(bob));
	*/

	function requestDeposit(address mockToken, address fund, uint256 amount) public {
		//mint tokens to self
		ERC20Mock(mockToken).issue(address(this), amount);
		//approve fund and request deposit
		ERC20Mock(mockToken).approve(fund, amount);

		bytes memory depositRequest = abi.encodeWithSelector(
            bytes4(keccak256("requestDeposit(uint256)")),
            amount
        );
        (bool success,) = fund.call(depositRequest);
        require(success == true, "fail depositRequest");
	}

	function revokeDeposit(address fund) public {
		bytes memory revoke = abi.encodeWithSelector(
            bytes4(keccak256("revokeDepositWithrawal(bool)")),
            true
        );
        (bool success,) = fund.call(revoke);
        require(success == true, "fail revokeDeposit");
	}

	function deposit(address fund) public {
		//deposit into fund
		bytes memory deposit = abi.encodeWithSelector(
            bytes4(keccak256("deposit"))
        );
        (bool success,) = fund.call(deposit);
        require(success == true, "fail deposit");
	}

	function delegate(address fund, address delegatee) public {
		//delegate gov token to delegatee
		bytes memory delegation = abi.encodeWithSelector(
            bytes4(keccak256("delegate(address)")),
            delegatee
        );
        (bool success,) = fund.call(delegation);
        require(success == true, "fail delegation");
	}
}