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
*/

contract HemifyWager is IHemifyWager, Ownable2Step {
    IHemifyTreasury internal treasury;

    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    constructor(address _treasury) {
        if (_treasury == address(0)) revert ZeroAddress();

        treasury = IHemifyTreasury(_treasury);
    }

    function makeWager(address from, IERC20 token, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        if ((token != USDC) && (token != USDT)) revert NotAllowedToken();

        /// @dev `msg.sender` will approve HemifyTreasury.
        bool wagerMade = treasury.deposit(from, token, amount);
        if (!wagerMade) revert NotDeposited();

        return wagerMade;
    }

    function payWager(IERC20 token, address to, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        if ((token != USDC) && (token != USDT)) revert NotAllowedToken();

        bool wagerPaid = treasury.sendPayment(token, to, amount);
        if (!wagerPaid) revert NotPaid();

        return wagerPaid;
    }
}
