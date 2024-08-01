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
			_userDepositBal[msg.sender] = 0;
        	userDepositRequest[msg.sender] = DepositRequestEntry(0, 0);
		} else {
			require(userWithdrawRequest[msg.sender].amount != 0 && userWithdrawRequest[msg.sender].requestTime != 0, "withdrawal not requested");
			_withdrawalBal -= userWithdrawRequest[msg.sender].amount;
        	userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);
		}
	}

	function requestDeposit(uint256 amount) external {
		require(amount > 0, "bad request");
		require(IERC20(FundSettings.baseToken).balanceOf(msg.sender) >= amount, "Insufficient balance");

		if (FundSettings.isWhitelistedDeposits == true) {
			require(whitelistedDepositors[msg.sender] == true, "not allowed");
		}

		require(userDepositRequest[msg.sender].amount == 0 && userDepositRequest[msg.sender].requestTime == 0, "already requested");
		userDepositRequest[msg.sender] = DepositRequestEntry(amount, block.timestamp);
		_depositBal += amount;
		_userDepositBal[msg.sender] += amount;
	}

	function deposit() external {

		uint bal = IERC20(FundSettings.baseToken).balanceOf(msg.sender);
		//NOTE: this is to mitigte in the case that a manager starts swapping base assets before a nav update has calculated the value of the fund
		uint safeBal = (navUpdatedTime[_navUpdateLatestIndex] == 0) ? _totalDepositBal : IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe);

		require(bal >= userDepositRequest[msg.sender].amount, "low bal");

		require((userDepositRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex]) || (navUpdatedTime[_navUpdateLatestIndex] == 0), "not allowed yet");
        require(userDepositRequest[msg.sender].amount != 0 && userDepositRequest[msg.sender].requestTime != 0, "deposit not requested");

		uint b0 = safeBal+_nav;

		//transfer tokens to fund
        IERC20(FundSettings.baseToken).safeTransferFrom(msg.sender, FundSettings.fundAddress, userDepositRequest[msg.sender].amount);
        uint feeAmount = userDepositRequest[msg.sender].amount * FundSettings.depositFee / MAX_BPS;
        uint daoFeeAmount = (userDepositRequest[msg.sender].amount * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
        uint discountedAmount = userDepositRequest[msg.sender].amount - feeAmount - daoFeeAmount;
        _feeBal += feeAmount;

        uint b1 = safeBal +_nav + discountedAmount;
        uint p = ((b1 - b0) * fractionBase) / b1;
        uint b = 1e3;
        uint v = totalSupply() > 0 ? (totalSupply() * p * b) / (fractionBase - p) : b1 * b;
        v = _round(v, b);

        _mint(msg.sender, v);

        IERC20(FundSettings.baseToken).safeTransfer(FundSettings.safe, discountedAmount);
    	if (daoFeeAmount > 0) {
	    	IERC20(FundSettings.baseToken).safeTransfer(daoFeeAddr, daoFeeAmount);
    	}

		_depositBal -= userDepositRequest[msg.sender].amount;
		_totalDepositBal += discountedAmount;

		_userDepositBal[msg.sender] = 0;
        userDepositRequest[msg.sender] = DepositRequestEntry(0, 0);

        //delegate to self first always to avoid having to do it in frontend when issued fund tokens
        //NOTE: does not work as intended, although msg.sender is right, the caller is the fund contract
        if(FundSettings.governanceToken != address(0)) {
        	(bool success,) = FundSettings.governanceToken.call(
				abi.encodeWithSignature("delegate(address)", msg.sender)
			);
			require(success == true, "failed ext delegate");
        } else {
        	delegate(msg.sender);
        }
	}

	function requestWithdraw(uint256 amount) external {
		require(amount > 0, "bad request");
		require(balanceOf(msg.sender) >= amount, "Insufficient balance");
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
        require(userWithdrawRequest[msg.sender].requestTime < navUpdatedTime[_navUpdateLatestIndex] || (navUpdatedTime[_navUpdateLatestIndex] == 0), "not allowed yet");
        require(bal >= userWithdrawRequest[msg.sender].amount, "low bal");
        require(userWithdrawRequest[msg.sender].amount != 0 && userWithdrawRequest[msg.sender].requestTime != 0, "withdrawal not requested");

        uint val = (valueOf(msg.sender) * userWithdrawRequest[msg.sender].amount) / bal;
        uint feeVal = (val * FundSettings.withdrawFee) / MAX_BPS;
        uint daoFeeAmount = (val * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
        uint discountedValue = val - feeVal - daoFeeAmount;

        require(totalWithrawalBalance() > discountedValue, "low withdraw bal");
        _feeBal += feeVal;

        if (discountedValue > _totalDepositBal) {
        	_totalDepositBal = 0;
        } else {
        	_totalDepositBal -= discountedValue;        	
        }

        IERC20(FundSettings.baseToken).safeTransfer(msg.sender, discountedValue);

        if (daoFeeAmount > 0) {
	    	IERC20(FundSettings.baseToken).safeTransfer(daoFeeAddr, daoFeeAmount);
    	}
        
        _burn(msg.sender, userWithdrawRequest[msg.sender].amount);
        _withdrawalBal -= userWithdrawRequest[msg.sender].amount;
        userWithdrawRequest[msg.sender] = WithdrawalRequestEntry(0, 0);

    }

    function valueOf(address ownr) public view returns (uint256) {
        return (totalNAV() * balanceOf(ownr)) / totalSupply();
    }

    function totalNAV() public view returns (uint256) {
    	return (_nav + IERC20(FundSettings.baseToken).balanceOf(address(this)) + IERC20(FundSettings.baseToken).balanceOf(FundSettings.safe)  - _feeBal);
    }

    // rounds "v" considering a base "b"
    function _round(uint v, uint b) internal pure returns (uint) {
        return (v / b) + ((v % b) >= (b / 2) ? 1 : 0);
    }

    function totalWithrawalBalance() private view returns (uint256) {
		return IERC20(FundSettings.baseToken).balanceOf(FundSettings.fundAddress) - _feeBal;
	}

	function calculateAccruedManagementFees() public view returns (uint256 accruedFees) {
        uint256 startTime = (_lastClaimedManagementFees == 0) ? _fundStartTime: _lastClaimedManagementFees;
        uint256 accruingPeriod = (block.timestamp - startTime);
        uint256 feeBase = totalSupply();
        uint256 feePerSecond = (feeBase * FundSettings.managementFee) /
            ( ((feeManagePeriod > 0) ? feeManagePeriod : feePeriodDefault) * 10000);
        accruedFees = feePerSecond * accruingPeriod;
    }

    function calculateAccruedPerformanceFees() public view returns (uint256 accruedFees) {
    	if (_totalDepositBal > 0) {
	    	uint256 nav = totalNAV();
	    	int256 returnOverDeposits = int256(nav) - int256(_totalDepositBal);
	    	uint256 performanceTake = 0;
	    	if(returnOverDeposits > 0) {
	    		uint256 hurdleReturn = (nav * FundSettings.performaceHurdleRateBps) / MAX_BPS;
	    		if (hurdleReturn < uint256(returnOverDeposits)) {
	    			performanceTake = ((uint256(returnOverDeposits) - hurdleReturn) * FundSettings.performanceFee) / MAX_BPS;
	    			/*
				        //mintmount = totalSupply * (performanceTake / totalNAV);
	    			*/
	    		}
	    	}

	        uint256 startTime = (_lastClaimedPerformanceFees == 0) ? _fundStartTime: _lastClaimedPerformanceFees;
	        uint256 accruingPeriod = (block.timestamp - startTime);
	        uint256 feeBase = totalSupply();
	        uint256 feePerSecond = ((feeBase * performanceTake) / _totalDepositBal) /
	            (((feePerformancePeriod > 0) ? feePerformancePeriod : feePeriodDefault)  * 10000);
	        accruedFees = feePerSecond * accruingPeriod;
        }
    }

    //NOTE: NEEDS TO BE CALLED FROM OIV, AND ONLY GOV/SAFE
    function mintPerformanceFee(uint256 amountInOIVTokens) external {
		uint256 feeVal = (amountInOIVTokens * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
		uint256 discountedValue = amountInOIVTokens - feeVal;
		_mint(feeCollectorAddress[FundFeeType.PerformanceFee], discountedValue);
		if (feeVal > 0) {
			_mint(daoFeeAddr, feeVal);
    	}
		_lastClaimedPerformanceFees = block.timestamp;
    }

    //NOTE: NEEDS TO BE CALLED FROM OIV, AND ONLY GOV/SAFE
    function mintToMany(uint256[] calldata amountInOIVTokens, address[] calldata recipients) external {
    	require(amountInOIVTokens.length == recipients.length, "mismatch dims");
    	uint256 feeVal;
    	uint256 discountedValue;

    	for(uint i=0; i<amountInOIVTokens.length; i++){ 
			feeVal = (amountInOIVTokens[i] * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = amountInOIVTokens[i] - feeVal;

			_mint(recipients[i], discountedValue);
			
			if (feeVal > 0) {
				_mint(daoFeeAddr, feeVal);
	    	}
    	}
		_lastClaimedPerformanceFees = block.timestamp;
    }

    //sweep funds back into custody contract if they exceed pending withdrawal requests
	function sweepTokens() external {
		uint256 ts = totalSupply();
		uint256 tn = totalNAV();
		uint256 twb = totalWithrawalBalance();
		uint256 diffTokens;
		if (ts > 0) {
			require(((tn * _withdrawalBal) / ts) <= twb, 'not enough for withdrawals');
			diffTokens = twb - ((tn * _withdrawalBal) / ts);
			
		} else {
			diffTokens = twb;
		}

		if (diffTokens > 0) {
			IERC20(FundSettings.baseToken).safeTransfer(FundSettings.safe, diffTokens);
		}
	}

	function collectFees(FundFeeType feeType) external {
    	/*
    		enum FundFeeType {
				DepositFee,
				WithdrawFee,
				ManagementFee,
				PerformanceFee
			}
		*/
		//NOTE: deposit and withdrawal fees are combined, collector should be same addr

		if(feeCollectorAddress[feeType] == address(0)){
			return;
		}

		uint feeVal;
        uint discountedValue;

		if (feeType == FundFeeType.DepositFee || feeType == FundFeeType.WithdrawFee) {
			feeVal = (_feeBal * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _feeBal - feeVal;

	    	IERC20(FundSettings.baseToken).transfer(feeCollectorAddress[feeType], discountedValue);
	    	if (feeVal > 0) {
		    	IERC20(FundSettings.baseToken).transfer(daoFeeAddr, feeVal);
	    	}

	    	_feeBal = 0;
		} else if (feeType == FundFeeType.ManagementFee) {
			uint256 _accruedFees = calculateAccruedManagementFees();
			feeVal = (_accruedFees * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _accruedFees - feeVal;
			_mint(feeCollectorAddress[feeType], discountedValue);
			if (feeVal > 0) {
				_mint(daoFeeAddr, feeVal);
	    	}
			_lastClaimedManagementFees = block.timestamp;
		} else if (feeType == FundFeeType.PerformanceFee) {
			uint256 _accruedFees = calculateAccruedPerformanceFees();
			feeVal = (_accruedFees * ((isDAOFeeEnabled == true) ? daoFeeBps : 0)) / MAX_BPS;
			discountedValue = _accruedFees - feeVal;
			_mint(feeCollectorAddress[feeType], discountedValue);
			if (feeVal > 0) {
				_mint(daoFeeAddr, feeVal);
	    	}
			_lastClaimedPerformanceFees = block.timestamp;
		}
    }
}