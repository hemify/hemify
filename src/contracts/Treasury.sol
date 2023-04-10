// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Gated} from "./utils/Gated.sol";

/**
* @title Treasury
* @author fps (@0xfps).
* @dev  Treasury contract.
*       A contract to hold all tokens and ETH.
*       Any contract can interact with this contract as long as it's been
*       `allow`ed by the contract.
*/

contract Treasury is ITreasury, Gated {
    using SafeERC20 for IERC20;

    error LowBalance();
    error NotSent();

    receive() external payable {
        emit ETHDeposit(msg.value);
    }
    fallback() external payable {
        emit ETHDeposit(msg.value);
    }

    function deposit() external payable onlyAllowed returns (bool) {
        emit ETHDeposit(msg.value);
        return true;
    }

    function sendPayment(address to, uint256 amount) external onlyAllowed returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        if (amount > address(this).balance) revert LowBalance();

        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert NotSent();

        emit ETHTransfer(to, amount);

        return true;
    }

    function withdraw() public onlyOwner returns (bool) {
        uint256 amount = address(this).balance;

        (bool success, ) = payable(owner()).call{value: amount}("");
        if (!success) revert NotSent();

        emit ETHWithdraw(amount);

        return true;
    }

    function deposit(
        address from,
        IERC20 token,
        uint256 amount
    ) external onlyAllowed returns (bool) {
        // Checks of IERC20 being supported are done in the Auction.
        uint256 prevBal = token.balanceOf(address(this));

        token.safeTransferFrom(from, address(this), amount);

        assert(token.balanceOf(address(this)) >= prevBal);

        emit TokenDeposit(token, amount);

        return true;
    }

    function sendPayment(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyAllowed returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        if (amount > token.balanceOf(address(this))) revert LowBalance();

        token.safeTransfer(to, amount);

        emit TokenTransfer(token, to, amount);

        return true;
    }

    function withdraw(
        IERC20 token,
        uint256 amount
    ) public onlyOwner returns (bool) {
        if (amount > token.balanceOf(address(this))) revert LowBalance();
        token.safeTransfer(owner(), amount);

        emit TokenWithdraw(token, amount);

        return true;
    }
}