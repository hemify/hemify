// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHemifyTreasury} from "../interfaces/IHemifyTreasury.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Gated, SimpleMultiSig} from "./utils/Gated.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title HemifyTreasury
 * @author fps (@0xfps).
 * @dev  Treasury contract.
 *       A contract to hold all tokens and ETH.
 *       Any contract can interact with this contract as long as it's been
 *       `allow`ed by this contract.
 */

contract HemifyTreasury is IHemifyTreasury, Gated, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @dev Initialize protective multi-sig of at least 5 addresses.
    /// @param _addresses 5 or more addresses for multi-sig protection.
    constructor(address[] memory _addresses) 
        SimpleMultiSig(_addresses) {}

    receive() external payable {
        emit ETHDeposit(msg.value);
    }

    fallback() external payable {
        emit ETHDeposit(msg.value);
    }

    /// @inheritdoc IHemifyTreasury
    /// @return bool Status.
    function deposit() external payable onlyAllowed returns (bool) {
        emit ETHDeposit(msg.value);
        return true;
    }

    /**
    * @dev Sends an amount of ETH from this contract to `to`.
    * @notice   Only allowed address and can call this contract.
    *           Amount to send must be less than the amount in balance.
    *           Also, `to` must not be a zero address.
    * @param to     Receiver.
    * @param amount Amount to send.
    * @return bool  Status.
    */
    function sendPayment(
        address to,
        uint256 amount
    ) 
        external
        nonReentrant
        onlyAllowed
        returns (bool)
    {
        if (to == address(0)) revert ZeroAddress();
        if (amount > address(this).balance) revert LowBalance();

        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert NotSent();

        emit ETHTransfer(to, amount);

        return true;
    }

    /**
    * @dev Withdraws all funds in the contract.
    * @notice   All addresses in the multisig must sign for this function
    *           to succeed.
    *           OnlyOwner can call this contract.
    * @return bool  Status.
    */
    function withdraw() public allSigned onlyOwner returns (bool) {
        uint256 amount = address(this).balance;

        (bool success, ) = payable(owner()).call{value: amount}("");
        if (!success) revert NotSent();

        emit ETHWithdraw(amount);

        return true;
    }

    /**
    * @dev Deposits `amount` amount of `token` tokens from `from` to this contract.
    * @notice   This contract will be approved by `from` to allow easy deposits, but
    *           will only be callable by the HemifyAuction or any other added contract.
    *           Assertion that the difference between the token balance of the contract
    *           after deposit and before deposit is >= the amount deposited is made.
    * @param from   Sender.
    * @param token  Token.
    * @param amount Amount to send, which will always be <= `from`'s balance.
    * @return bool  Status.
    */
    function deposit(
        address from,
        IERC20 token,
        uint256 amount
    ) 
        external
        onlyAllowed
        returns (bool)
    {
        /// @dev Checks of IERC20 being supported are done in the Auction.
        uint256 prevBal = token.balanceOf(address(this));

        /// @dev    `from` must approve HemifyTreasury address to move funds
        ///         via approve().
        token.safeTransferFrom(from, address(this), amount);

        assert((token.balanceOf(address(this)) - prevBal) >= amount);

        emit TokenDeposit(token, amount);

        return true;
    }

    /**
    * @dev Sends `amount` amount of `token` tokens to `to` from this contract.
    * @notice Assertions as to balances are not made as function is non-reentrant.
    * @param token  Token.
    * @param to     Sender.
    * @param amount Amount to send, which will always be <= this contract's balance.
    * @return bool  Status.
    */
    function sendPayment(
        IERC20 token,
        address to,
        uint256 amount
    ) 
        external
        nonReentrant
        onlyAllowed
        returns (bool)
    {
        if (to == address(0)) revert ZeroAddress();
        if (to == address(this)) revert TokenAlreadyOwned();
        if (amount > token.balanceOf(address(this))) revert LowBalance();

        token.safeTransfer(to, amount);

        emit TokenTransfer(token, to, amount);

        return true;
    }

    /**
    * @dev Sends `amount` amount of `token` tokens to `owner()`.
    * @param token  Token.
    * @param amount Amount to send, which will always be <= this contract's balance.
    * @return bool  Status.
    */
    function withdraw(
        IERC20 token,
        uint256 amount
    ) 
        public
        allSigned
        onlyOwner
        returns (bool)
    {
        if (amount > token.balanceOf(address(this))) revert LowBalance();

        token.safeTransfer(owner(), amount);

        emit TokenWithdraw(token, amount);

        return true;
    }
}
