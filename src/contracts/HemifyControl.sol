// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IHemifyControl} from "../interfaces/IHemifyControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title HemifyControl
* @author fps (@0xfps).
* @dev  HemifyControl contract.
*       A contract for setting and revoking support for a particular IERC20 tokens,
*       making them acceptable as a means of making bids for listed auctions.
*/

contract HemifyControl is IHemifyControl, Ownable2Step {
    mapping(IERC20 => AggregatorV3Interface) private supportedTokens;
    mapping(IERC721 => bool) public supportedSwapNFTs;

    /**
    * @inheritdoc IHemifyControl
    * @notice   `token` and `agg` cannot be zero addresses and function is only
    *           callable by the owner.
    */
    function supportToken(IERC20 token, AggregatorV3Interface agg) public onlyOwner {
        if (address(token) == address(0)) revert ZeroAddress();
        if (address(agg) == address(0)) revert ZeroAddress();

        if (address(supportedTokens[token]) == address(0)) supportedTokens[token] = agg;

        emit TokenSupportedForAuction(token);
    }

    /**
    * @inheritdoc IHemifyControl
    * @notice Function is only callable by the owner.
    */
    function revokeToken(IERC20 token) public onlyOwner {
        if (address(supportedTokens[token]) != address(0)) delete supportedTokens[token];

        emit TokenRevokedForAuction(token);
    }

    /**
    * @inheritdoc IHemifyControl
    * @notice   `nft` cannot be zero addresses and function is only callable
    *           by the owner.
    */
    function supportSwapNFT(IERC721 nft) public onlyOwner {
        if (address(nft) == address(0)) revert ZeroAddress();
        if (!supportedSwapNFTs[nft]) supportedSwapNFTs[nft] = true;
        emit NFTSupportedForSwap(nft);
    }

    /**
    * @inheritdoc IHemifyControl
    * @notice Function is only callable by the owner.
    */
    function revokeSwapNFT(IERC721 nft) public onlyOwner {
        if (supportedSwapNFTs[nft]) supportedSwapNFTs[nft] = false;
        emit NFTRevokedForSwap(nft);
    }

    /**
    * @inheritdoc IHemifyControl
    */
    function isSupported(IERC20 token) public view returns (bool) {
        return address(supportedTokens[token]) != address(0);
    }

    /**
    * @inheritdoc IHemifyControl
    */
    function isSupportedForSwap(IERC721 nft) public view returns (bool) {
        return supportedSwapNFTs[nft];
    }

    /**
    * @inheritdoc IHemifyControl
    */
    function getTokenAggregator(IERC20 token) external view returns (AggregatorV3Interface) {
        if (!isSupported(token)) revert NotSupported();
        return supportedTokens[token];
    }
}