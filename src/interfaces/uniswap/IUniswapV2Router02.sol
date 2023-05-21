// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title IUniswapV2Router02
* @author Uniswap (https://uniswap.org).
* @dev Culled from Uniswap's `IUniswapV2Router02` interface contract, (http://rb.gy/7t9er).
*/

interface IUniswapV2Router02 {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        returns (uint[] memory amounts);
}