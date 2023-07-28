// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHemifyExchange} from "../../interfaces/IHemifyExchange.sol";
import {IUniswapV2Router02} from "../../interfaces/uniswap/IUniswapV2Router02.sol";

/**
* @title HemifyExchange
* @author fps (@0xfps).
* @custom:version 1.0.0
* @dev  HemifyExchange, a small exchange contract that swaps `USDC` and `USDT` to
*       `ETH` via `WETH`. This contract will allow anyone to use it for swaps. It
*       is not restricted to only `Hemify` contracts.
*       Swappers approve this contract and deposit their tokens to it for the swap,
*       of course, some tax (undecided) is to be taken.
*/

contract HemifyExchange is IHemifyExchange {
    address internal constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    /// @notice MAINNET ADDRESSES.
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice GOERLI ADDRESSES.
    /// address internal constant USDC = 0xd35CCeEAD182dcee0F148EbaC9447DA2c4D449c4;
    /// address internal constant USDT = 0x509Ee0d083DdF8AC028f2a56731412edD63223B9;
    /// address internal constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    IUniswapV2Router02 internal router;

    address[] internal USDC_TO_WETH_PATH = [USDC, WETH];
    address[] internal USDT_TO_WETH_PATH = [USDT, WETH];

    /// @dev Initialize Uniswap's `Router` at its address.
    constructor() {
        router = IUniswapV2Router02(ROUTER);
    }

    /**
    * @dev Swaps token(`USDC` or `USDT`) for ETH. Any resulting ETH is sent to `from`.
    * @param from   Swapper.
    * @param token  Token(`USDC` or `USDT`).
    * @param amount Amount of tokens to be swapped.
    * @return bool Swap status.
    */
    function swapToETH(address from, IERC20 token, uint256 amount) public returns (bool) {
        if ((token != IERC20(USDC)) && (token != IERC20(USDT))) revert NotAllowedToken();
        uint256 prevBal = token.balanceOf(address(this));

        /// @dev `from` must approve this contract to handle `amount` amount of tokens.
        token.transferFrom(from, address(this), amount);

        assert((token.balanceOf(address(this)) - prevBal) >= amount);

        token.approve(ROUTER, amount);

        bool swapped;

        if (token == IERC20(USDC)) swapped = _swap(USDC_TO_WETH_PATH, amount, from);
        else swapped = _swap(USDT_TO_WETH_PATH, amount, from);

        if (!swapped) revert NotSwapped();

        return swapped;
    }

    /**
    * @dev Utilizes Uniswap's interface to make swap calls from `USDC` to `ETH` or `USDT` to `ETH`.
    * @notice Swap deadlines are put at an hour.
    * @param _path      Swap path, last index, `_path[_path.length - 1]` must be `WETH`.
    * @param _amount    Amount of `_path[0]` sent in.
    * @param _to        Address receiving `ETH`.
    * @return bool Status ensuring that length of amounts returned by Uniswap is not 0.
    */
    function _swap(address[] memory _path, uint256 _amount, address _to)
        internal
        returns (bool)
    {
        uint256[] memory _amounts = router.swapExactTokensForETH(
            _amount,
            0,
            _path,
            _to,
            block.timestamp + 60 minutes
        );

        return _amounts.length != 0;
    }
}