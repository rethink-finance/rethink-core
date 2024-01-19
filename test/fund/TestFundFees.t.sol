// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../common/utils/MoreAssert.t.sol";
import "./Base.t.sol";
import "../../contracts/interfaces/fund/IGovernableFund.sol";
import "../common/Agent.t.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

contract TestFundFees is Base {
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

        initDAO(daoAddr, fundAddr);

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

        initDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            0//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testDepositWithdrawFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "non zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) == 0, "non zero dao balance");
	}
	function testManagementFeeCollectionDAODisabled() public {
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

        initDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            2//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testManagementFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "non zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) == 0, "non zero dao balance");

	}
	function testPerformanceFeeCollectionDAODisabled() public {
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

        initDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));
		ERC20Mock(settings.baseToken).issue(settings.safe, 100000e18);


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            3//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testManagementFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "non zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) == 0, "non zero dao balance");

	}
	
	function testFlowFeeCollectionDAOEnabled() public {
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

        initDAO(daoAddr, fundAddr);
        setupDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);

        require(IERC20(settings.baseToken).balanceOf(daoAddr) > 0, " zero dao balance");
	}
	function testDepositWithdrawFeeCollectionDAOEnabled() public {
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

        initDAO(daoAddr, fundAddr);
        setupDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            0//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testDepositWithdrawFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) > 0, " zero dao balance");

	}
	function testManagementFeeCollectionDAOEnabled() public {
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

        initDAO(daoAddr, fundAddr);
        setupDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            2//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testManagementFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) > 0, "zero dao balance");
	}
	function testPerformanceFeeCollectionDAOEnabled() public {
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

        initDAO(daoAddr, fundAddr);
        setupDAO(daoAddr, fundAddr);

        Agent bob = new Agent();
        bob.requestDeposit(settings.baseToken, fundAddr, 100000e18);
        bob.deposit(fundAddr);
        bob.delegate(fundAddr, address(bob));
		ERC20Mock(settings.baseToken).issue(settings.safe, 100000e18);


        address[] memory targets;
        targets[0] = fundAddr;
        uint256[] memory values;
        values[0] = 0;

        bytes memory collectDepositWithdrwalFees = abi.encodeWithSelector(
            bytes4(keccak256("collectFees(uint8)")),
            3//0 -> deposit/withdrawl, 2 -> manager fees, 3 -> performance fees
        );

        bytes[] memory calldatas;
        calldatas[0] = collectDepositWithdrwalFees;
        string memory description = "testManagementFeeCollectionDAODisabled";
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        uint256 proposalId = IGovernor(settings.governor).propose(
        	targets,
        	values,
        	calldatas,
        	description
        );

        IGovernor(settings.governor).castVote(proposalId, 1);

        //TODO: need to figure how to speed up chain clock for testing here
        
        IGovernor(settings.governor).execute(
	        targets,
	        values,
	        calldatas,
	        descriptionHash
	    );

        require(IERC20(settings.baseToken).balanceOf(address(bob)) > 0, "zero bob balance after fee collection");
        require(IERC20(settings.baseToken).balanceOf(daoAddr) > 0, "zero dao balance");
	}


	function initDAO(address daoAddr, address fundAddr) internal {
		bytes memory setFeeAddr = abi.encodeWithSelector(
            bytes4(keccak256("setDaoFeeAddr(address)")),
            daoAddr
        );
        (bool success,) = fundAddr.call(setFeeAddr);
        require(success == true, "fail setDaoFeeAddr");
	}

	function setupDAO(address daoAddr, address fundAddr) internal {
		bool success;
		bytes memory toggleDaoFeeOn = abi.encodeWithSelector(
            bytes4(keccak256("toggleDaoFee()"))
        );
        (success,) = fundAddr.call(toggleDaoFeeOn);
        require(success == true, "fail toggleDaoFeeOn");

        bytes memory setDaoFee5Bps = abi.encodeWithSelector(
            bytes4(keccak256("setDaoFeeBps(uint256)")),
            5
        );
        (success,) = fundAddr.call(setDaoFee5Bps);
        require(success == true, "fail setDaoFee5Bps");
	}
}