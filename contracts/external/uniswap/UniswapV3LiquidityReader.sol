// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@uniswap/v3-periphery/contracts/libraries/PositionValue.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract UniswapV3LiquidityReader {
    

    // @notice Returns the total amounts of token0 and token1, i.e. the sum of fees and principal
    // that a given nonfungible position manager token is worth
    // @param positionManager The Uniswap V3 NonfungiblePositionManager
    // @param tokenId The tokenId of the token for which to get the total value
    // @param sqrtRatioX96 The square root price X96 for which to calculate the principal amounts
    // @return amount0 The total amount of token0 including principal and fees
    // @return amount1 The total amount of token1 including principal and fees


    function getLiquidityValue(address pool, address pMaddr, address account, address lpToken, uint256 tokenId) external view returns (uint256 amount0, uint256 amount1) {
        require(IERC1155(lpToken).balanceOf(account, tokenId) > 0, "no liq");
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(pool).slot0();
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(pMaddr);
        (amount0, amount1) = PositionValue.total(positionManager, tokenId, sqrtRatioX96);
    }

}