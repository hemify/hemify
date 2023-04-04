// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title ITreasury
* @author fps (@0xfps).
* @dev Treasury contract interface.
*/

interface ITreasury {
    event ETHDeposit(uint256 indexed amount);
    event ETHTransfer(address indexed to, uint256 indexed amount);
    event TokenDeposit(IERC20 indexed token, uint256 indexed amount);
    event TokenTransfer(
        IERC20 indexed token,
        address indexed to,
        uint256 indexed amount
    );

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