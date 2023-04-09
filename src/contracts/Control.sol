// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IControl} from "../interfaces/IControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title Control
* @author fps (@0xfps).
* @dev  Control contract.
*       A contract for setting and revoking support for a particular NFT collection,
*       allowing NFTs from that collection to be listable for auctions, and also,
*       for setting and revoking support for a particular IERC20 tokens, making them
*       acceptable as a means of making bids for listed auctions.
*/

contract Control is IControl, Ownable2Step {
    mapping(IERC20 => bool) public supportedTokens;
    mapping(IERC721 => bool) public supportedAuctionNFTs;
    mapping(IERC721 => bool) public supportedSwapNFTs;

    function supportAuctionNFT(IERC721 nft) public onlyOwner {
        if (address(nft) == address(0)) revert ZeroAddress();

        if (!supportedAuctionNFTs[nft]) supportedAuctionNFTs[nft] = true;

        emit NFTSupportedForAuction(nft);
    }

    function revokeAuctionNFT(IERC721 nft) public onlyOwner {
        if (supportedAuctionNFTs[nft]) supportedAuctionNFTs[nft] = false;

        emit NFTRevokedForAuction(nft);
    }

    function supportToken(IERC20 token) public onlyOwner {
        if (address(token) == address(0)) revert ZeroAddress();

        if (!supportedTokens[token]) supportedTokens[token] = true;

        emit TokenSupportedForAuction(token);
    }

    function revokeToken(IERC20 token) public onlyOwner {
        if (supportedTokens[token]) supportedTokens[token] = false;

        emit TokenRevokedForAuction(token);
    }

    function supportSwapNFT(IERC721 nft) public onlyOwner {
        if (address(nft) == address(0)) revert ZeroAddress();

        if (!supportedSwapNFTs[nft]) supportedSwapNFTs[nft] = true;

        emit NFTSupportedForSwap(nft);
    }

    function revokeSwapNFT(IERC721 nft) public onlyOwner {
        if (supportedSwapNFTs[nft]) supportedSwapNFTs[nft] = false;

        emit NFTRevokedForSwap(nft);
    }

    function isSupported(IERC20 token) public view returns (bool) {
        return supportedTokens[token];
    }

    function isSupportedForAuction(IERC721 nft) public view returns (bool) {
        return supportedAuctionNFTs[nft];
    }

    function isSupportedForSwap(IERC721 nft) public view returns (bool) {
        return supportedSwapNFTs[nft];
    }
}