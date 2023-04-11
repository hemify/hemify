// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title ITreasury
* @author fps (@0xfps).
* @dev  Treasury contract interface.
*       This interface controls the `Treasury` contract.
*/

interface ITreasury {
    /// @dev Events for different actions.
    /// @notice amount  Amount deposited or transferred.
    /// @notice token   IERC20 token deposited or transferred.
    event ETHDeposit(uint256 indexed amount);
    event ETHTransfer(address indexed to, uint256 indexed amount);

    event TokenDeposit(IERC20 indexed token, uint256 indexed amount);
    event TokenTransfer(
        IERC20 indexed token,
        address indexed to,
        uint256 indexed amount
    );

    event ETHWithdraw(uint256 indexed amount);
    event TokenWithdraw(
        IERC20 indexed token,
        uint256 indexed amount
    );

    error LowBalance();
    error NotSent();
    error TokenAlreadyOwned();

    function deposit() external payable returns (bool);

    function sendPayment(address to, uint256 amount) external returns (bool);

    function withdraw() external returns (bool);

    function deposit(
        address from,
        IERC20 token,
        uint256 amount
    ) external returns (bool);

    function sendPayment(
        IERC20 token,
        address to,
        uint256 amount
    ) external returns (bool);

    function withdraw(
        IERC20 token,
        uint256 amount
    ) external returns (bool);
}