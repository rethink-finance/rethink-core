// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "../../contracts/token/ERC20Mock.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

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

        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            depositRequest
        );

        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail depositRequest");
	}

	function revokeDeposit(address fund) public {
		bytes memory revoke = abi.encodeWithSelector(
            bytes4(keccak256("revokeDepositWithrawal(bool)")),
            true
        );

        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            revoke
        );
        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail revokeDeposit");
	}

	function deposit(address fund) public {
		//deposit into fund
		bytes memory deposit = abi.encodeWithSelector(
            bytes4(keccak256("deposit()"))
        );

        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            deposit
        );
        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail deposit");
	}

	function requestWithdraw(address fund, uint256 amount) public {
		bytes memory withdrawRequest = abi.encodeWithSelector(
            bytes4(keccak256("requestWithdraw(uint256)")),
            amount
        );
        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            withdrawRequest
        );
        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail withdrawRequest");
	}

	function revokeWithdraw(address fund) public {
		bytes memory revoke = abi.encodeWithSelector(
            bytes4(keccak256("revokeDepositWithrawal(bool)")),
            false
        );
        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            revoke
        );
        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail revokeWithdraw");
	}

	function withdraw(address fund) public {
		//withdraw from fund
		bytes memory withdraw = abi.encodeWithSelector(
            bytes4(keccak256("withdraw()"))
        );
        bytes memory fundFlowsCall = abi.encodeWithSelector(
            bytes4(keccak256("fundFlowsCall(bytes)")),
            withdraw
        );
        (bool success,) = fund.call(fundFlowsCall);
        require(success == true, "fail withdraw");
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

	function voteYay(address gov, uint256 proposalId) public {
		IGovernor(gov).castVote(proposalId, 1);
	}
}