// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IControl} from "../interfaces/IControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title Control
* @author fps (@0xfps).
* @dev  Control contract.
*       A contract for setting and revoking support for a particular IERC20 tokens,
*       making them acceptable as a means of making bids for listed auctions.
*/

contract Control is IControl, Ownable2Step {
    mapping(IERC20 => AggregatorV3Interface) public supportedTokens;

    function supportToken(IERC20 token, AggregatorV3Interface agg) public onlyOwner {
        if (address(token) == address(0)) revert ZeroAddress();
        if (address(agg) == address(0)) revert ZeroAddress();

        if (address(supportedTokens[token]) == address(0)) supportedTokens[token] = agg;

        emit TokenSupportedForAuction(token);
    }

    function revokeToken(IERC20 token) public onlyOwner {
        if (address(supportedTokens[token]) != address(0)) delete supportedTokens[token];

        emit TokenRevokedForAuction(token);
    }

    function isSupported(IERC20 token) public view returns (bool) {
        return address(supportedTokens[token]) != address(0);
    }
}