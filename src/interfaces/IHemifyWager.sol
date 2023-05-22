// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title IHemifyWager
* @author fps (@0xfps).
* @custom:version 1.0.0
* @dev  HemifyWager contract interface.
*       This interface controls the `HemifyWager` contract.
*       `HemifyWager` is a simple contract that only sends `USDT` to the
*       `HemifyTreasury` and sends `USDT` from `HemifyTreasury` to specified
*       addresses.
*/

interface IHemifyWager {
    error NotAllowedToken();
    error NotDeposited();
    error NotPaid();
    error ZeroAddress();

    /**
    * @dev Makes a new wager from `from`.
    * @param from   Address making wager.
    * @param token  `USDC` or `USDT`.
    * @param amount Amount of tokens to wager with.
    * @return bool Wagering status.
    */
    function makeWager(address from, IERC20 token, uint256 amount) external returns (bool);

    /**
    * @dev Makes payment to winning wager address, `to`.
    * @param token  `USDC` or `USDT`.
    * @param to     Address receiving wager payment.
    * @param amount Amount of token payment.
    * @return bool Payment status.
    */
    function payWager(IERC20 token, address to, uint256 amount) external returns (bool);
}