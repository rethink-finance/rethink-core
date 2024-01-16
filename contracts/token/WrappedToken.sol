// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract WrappedToken is ERC20, ERC20Permit, ERC20Votes, ERC20Wrapper {
    constructor(
        address wrappedToken
    ) ERC20(string(abi.encodePacked("Wrapped ", IERC20Metadata(wrappedToken).name())), string(abi.encodePacked("w",IERC20Metadata(wrappedToken).symbol()))) ERC20Permit(string(abi.encodePacked("Wrapped ", IERC20Metadata(wrappedToken).name()))) ERC20Wrapper(IERC20(wrappedToken)) {}

    // The functions below are overrides required by Solidity.

    function decimals() public pure override(ERC20, ERC20Wrapper) returns (uint8) {
        return 18;
    }

    // Overrides IERC6372 functions to make the token & governor timestamp-based
    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}