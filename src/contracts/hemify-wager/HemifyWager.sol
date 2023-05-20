// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHemifyWager} from "../../interfaces/IHemifyWager.sol";
import {IHemifyTreasury} from "../../interfaces/IHemifyTreasury.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title HemifyWager
* @author fps (@0xfps).
* @dev  HemifyWager contract.
*       Consider this contract as the financial bank of a betting
*       frontend, this contract simply takes in wagers from addresses
*       with the tokens either being `USDC` or `USDT` and then sends it
*       to the `HemifyTreasury` and also sends winnings prizes to winning
*       addresses.
*       Fees are to be considered soon.
*/

contract HemifyWager is IHemifyWager, Ownable2Step {
    IHemifyTreasury internal treasury;

    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    constructor(address _treasury) {
        if (_treasury == address(0)) revert ZeroAddress();

        treasury = IHemifyTreasury(_treasury);
    }

    /**
    * @dev Makes a new wager from `from`.
    * @param from   Address making wager.
    * @param token  `USDC` or `USDT`.
    * @param amount Amount of tokens to wager with.
    * @return bool Wagering status.
    */
    function makeWager(address from, IERC20 token, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        if ((token != USDC) && (token != USDT)) revert NotAllowedToken();

        /// @dev `msg.sender` will approve HemifyTreasury.
        if (!treasury.deposit(from, token, amount)) revert NotDeposited();

        return true;
    }

    /**
    * @dev Makes payment to winning wager address `to`.
    * @param token  `USDC` or `USDT`.
    * @param to     Address receiving wager payment.
    * @param amount Amount of tokens to wager with.
    * @return bool Payment status.
    */
    function payWager(IERC20 token, address to, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        if ((token != USDC) && (token != USDT)) revert NotAllowedToken();

        if (!treasury.sendPayment(token, to, amount)) revert NotPaid();

        return true;
    }
}
