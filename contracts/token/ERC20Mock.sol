// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    string private constant _name = "ERC20Mock";
    string private _symbol;

    uint8 private _decimals;
    uint256 private _totalSupply;


    constructor(uint8 _d, string memory _s) ERC20(_name, _s) public {

        _decimals = _d;
        _symbol = _s;
    }

    function name() override public view returns (string memory) {

        return string(abi.encodePacked(_name, "-",_symbol));
    }

    function symbol() override public view returns (string memory) {

        return _symbol;
    }

    function decimals() override public view returns (uint8) {

        return _decimals;
    }

    function reset() external {

        _totalSupply = 0;
    }

    function reset(address addr) external {
        _burn(addr, balanceOf(addr));
    }

    function issue(address to, uint value) external {
        _mint(to, value);
    }
}