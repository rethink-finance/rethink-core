// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "./GovernableFundStorage.sol";

contract GovernableFundFlows is ERC20VotesUpgradeable, GovernableFundStorage {
	using SafeERC20 for IERC20;
	//TODO: NEEDS TO BE A ORACLE FOR BASE TOKEN

	function revokeDepositWithrawal(bool isDeposit) external {
		if (isDeposit == true) {
	        require(userDepositRequest[msg.sender].amount != 0 && userDepositRequest[msg.sender].requestTime != 0, "deposit not requested");
	        _depositBal -= userDepositRequest[msg.sender].amount;
	        _totalDepositBal -= userDepositRequest[msg.sender].amount;
			_userDepositBal[msg.sender] = 0;
        	userDepositRequest[msg.sender] = DepositRequestEntry(0, 0);
		} else {
			require(userWithdrawRequest[msg.sender].amount != 0 && userWithdrawRequest[msg.sender].requestTime != 0, "withdrawal not requested");
			_withdrawalBal -= userWithdrawRequest[msg.sender].amount;
        	userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);
		}
	}

	function requestDeposit(uint256 amount) external {
		/**/
		if (FundSettings.isWhitelistedDeposits == true) {
			require(whitelistedDepositors[msg.sender] == true, "not allowed");
		}

		require(userDepositRequest[msg.sender].amount == 0 && userDepositRequest[msg.sender].requestTime == 0, "already requested");
		userDepositRequest[msg.sender] = DepositRequestEntry(amount, block.timestamp);
		_depositBal += amount;
		_totalDepositBal += amount;
		_userDepositBal[msg.sender] += amount;
		/**/
	}

	function deposit() external {

		uint bal = IERC20(FundSettings.baseToken).balanceOf(msg.sender);
		uint safeBal = IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe);

		require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");

		require((userDepositRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex]) || (navUpdatedTime[_navUpdateLatestIndex] == 0), "not allowed yet");
        require(userDepositRequest[msg.sender].amount != 0 && userDepositRequest[msg.sender].requestTime != 0, "deposit not requested");

		uint b0 = safeBal+_nav;

		//transfer tokens to fund
        IERC20(FundSettings.baseToken).safeTransferFrom(msg.sender, FundSettings.fundAddress, userDepositRequest[msg.sender].amount);
        uint feeAmount = userDepositRequest[msg.sender].amount * FundSettings.depositFee / MAX_BPS;
        uint discountedAmount = userDepositRequest[msg.sender].amount - feeAmount;
        _feeBal += feeAmount;

        uint b1 = safeBal +_nav + discountedAmount;
        uint p = ((b1 - b0) * fractionBase) / b1;
        uint b = 1e3;
        uint v = totalSupply() > 0 ? (totalSupply() * p * b) / (fractionBase - p) : b1 * b;
        v = _round(v, b);

        _mint(msg.sender, v);


        IERC20(FundSettings.baseToken).transfer(FundSettings.safe, discountedAmount);
		_depositBal -= userDepositRequest[msg.sender].amount;
		_userDepositBal[msg.sender] = 0;
        userDepositRequest[msg.sender] = DepositRequestEntry(0, 0);

	}

	function requestWithdraw(uint256 amount) external {
		require(balanceOf(msg.sender) > 0, "nothing to withdraw");
		isRequestedWithdrawals = true;

		if (FundSettings.isWhitelistedDeposits == true) {
			require(whitelistedDepositors[msg.sender] == true, "not allowed");
		}

		require(userWithdrawRequest[msg.sender].amount == 0 && userWithdrawRequest[msg.sender].requestTime == 0, "already requested");

		userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(amount, block.timestamp);
		_withdrawalBal += amount;
	}
	
	function withdraw() external {
        uint bal = balanceOf(msg.sender);
        require(userWithdrawRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex], "not allowed yet");
        require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");
        require(userWithdrawRequest[msg.sender].amount != 0 && userWithdrawRequest[msg.sender].requestTime != 0, "withdrawal not requested");


        uint val = valueOf(msg.sender) * userWithdrawRequest[msg.sender].amount / bal;
        uint feeVal = val * FundSettings.withdrawFee / MAX_BPS;
        uint discountedValue = val - feeVal;
        _feeBal += feeVal;


        if (_userDepositBal[msg.sender] >= val){
        	_userDepositBal[msg.sender] -= val;
        	_totalDepositBal -= val;
        } else {
        	_totalDepositBal -= _userDepositBal[msg.sender];
        	_userDepositBal[msg.sender] = 0;
        }


        if (totalWithrawalBalance() > discountedValue) {
           IERC20(FundSettings.baseToken).transfer(msg.sender, discountedValue);
        }
        
        _burn(msg.sender, userWithdrawRequest[msg.sender].amount);
        _withdrawalBal -= userWithdrawRequest[msg.sender].amount;
        userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);

    }

    function valueOf(address ownr) public view returns (uint256) {
        return (_nav + IERC20(FundSettings.baseToken).balanceOf(address(this)) + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe)  - _feeBal) * balanceOf(ownr) / totalSupply();
    }

    // rounds "v" considering a base "b"
    function _round(uint v, uint b) internal pure returns (uint) {
        return (v / b) + ((v % b) >= (b / 2) ? 1 : 0);
    }

    function totalWithrawalBalance() private view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(FundSettings.fundAddress) - _feeBal;
	}
}