// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestFundFees is Base {
	/*
		enum FundFeeType {
				DepositFee,
				WithdrawFee,
				ManagementFee,
				PerformanceFee
			}


	toggleDaoFee()
	setDaoFeeBps(uint256 bps)
	setDaoFeeAddr(address addr)

	TODO: need to have
			- actor deposit to test deposit/flow fees/management fee,
			- mint baseToken to safe addr to test performance fee
	*/
	function testFlowFeeCollectionDAODisabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");
        success = false;
        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());

        bytes memory setFeeAddr = abi.encodeWithSelector(
            bytes4(keccak256("setDaoFeeAddr(address)")),
            daoAddr
        );
        (success,) = fundAddr.call(setFeeAddr);
        require(success == true, "fail setDaoFeeAddr");

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 10e18);
        bob.deposit(fundAddr);

        require(IERC20(settings.baseToken).balanceOf(daoAddr) == 0, "non zero dao balance");
	}
	function testDepositWithdrawFeeCollectionDAODisabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");
        success = false;
        address fundAddr = abi.decode(data, (address));

        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());

        bytes memory setFeeAddr = abi.encodeWithSelector(
            bytes4(keccak256("setDaoFeeAddr(address)")),
            daoAddr
        );
        (success,) = fundAddr.call(setFeeAddr);
        require(success == true, "fail setDaoFeeAddr");

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));


        address[] memory targets;
        uint256[] memory values;
        bytes[] memory calldatas;
        string memory description;

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        /*

        function propose(
	        address[] memory targets,
	        uint256[] memory values,
	        bytes[] memory calldatas,
	        string memory description
	    ) public virtual returns (uint256 proposalId);

	    function execute(
	        address[] memory targets,
	        uint256[] memory values,
	        bytes[] memory calldatas,
	        bytes32 descriptionHash
	    ) public payable virtual returns (uint256 proposalId);
	    */


        //TODO: gov proporsal to collect fees, execute proposal

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "non zero bob balance after fee collection");
	}
	function testManagementFeeCollectionDAODisabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
	function testPerformanceFeeCollectionDAODisabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
	function testFlowFeeCollectionDAOEnabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
	function testDepositWithdrawFeeCollectionDAOEnabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
	function testManagementFeeCollectionDAOEnabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
	function testPerformanceFeeCollectionDAOEnabled() public {
		address[] memory allowedDepositAddrs;
		bool success;
		bytes memory data;
		bytes memory gffCreateFund = this.createFund(address(this), allowedDepositAddrs, address(0));
        (success, data) = gffub.call(gffCreateFund);
        require(success == true, "fail createFund");

        address fundAddr = abi.decode(data, (address));
        IGovernableFundStorage.Settings memory settings = IGovernableFund(fundAddr).getFundSettings();
        address daoAddr = address(new Agent());
        Agent bob = new Agent();
	}
}