// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title IHemifyWager
* @author fps (@0xfps).
* @dev  HemifyWager contract interface.
*       This interface controls the `HemifyWager` contract.
*       HemifyWager is a simple contract that only sends `USDT` to the
*       `HemifyTreasury` and sends `USDT` from `HemifyTreasury` to addresses.
*/

interface IHemifyWager {
    error NotAllowedToken();
    error NotDeposited();
    error NotPaid();
    error ZeroAddress();
    function makeWager(address from, IERC20 token, uint256 amount) external returns (bool);
    function payWager(IERC20 token, address to, uint256 amount) external returns (bool);
}