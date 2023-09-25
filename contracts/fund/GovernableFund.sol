pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract GovernableFund is ERC20, ERC20Burnable {
	constructor(string memory _name_, string memory _symbol_) ERC20(_name_, _symbol_) {}

	mapping(address => uint256) allowedFundMannagers;
	uint256 _nav;
	uint256 _navUpdateLatestIndex;
	uint256 _navUpdateLatestTime;
	mapping(uint256 => uint256) navUpdatedTime;
	bool isRequestedWithdrawals;


	struct Settings {
		uint256 depositFee;
		uint256 withdrawlFee;
		address baseToken;
	}

	enum NavUpdateType {
		NAVLiquidUpdate,
		NAVIlliquidUpdate,
		NAVNftUpdate,
		NAVComposableUpdate
	}

	struct NavUpdateEntry {
		NavUpdateType entryType;
	}

	function deposit(uint256  amount) external {

	}
	
	function requestWithdraw(uint256 amount) external {
		isRequestedWithdrawals = true;

	}
	
	function withdraw(uint256  amount) external {

	}


	function valueOf(address ownr) public view returns (uint256) {
        return _nav * balanceOf(ownr) / totalSupply();
    }
}