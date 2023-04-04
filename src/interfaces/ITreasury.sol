// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title ITreasury
* @author fps (@0xfps).
* @dev Treasury contract interface.
*/

interface ITreasury {
    function depositETH() external payable returns (bool);
    function withdrawETH() external returns (bool);
    function sendETHPayment(address to, uint256 amount) external returns (bool);

    function depositToken(
        IERC20 token,
        uint256 amount
    ) external returns (bool);

    function sendTokenPayment(
        IERC20 token,
        address to,
        uint256 amount
    ) external returns (bool);

    function withdrawToken(
        IERC20 token,
        uint256 amount
    ) external returns (bool);
}