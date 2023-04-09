// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IControl
* @author fps (@0xfps).
* @dev  Control contract interface.
*       This interface controls the `Control` contract.
*/

interface IControl {
    /// @dev    Events for different supports and revokes.
    /// @notice nft NFT address supported or revoked.
    /// @notice token IERC20 token address supported or revoked.
    event NFTSupportedForAuction(IERC721 indexed nft);
    event NFTRevokedForAuction(IERC721 indexed nft);

    event TokenSupportedForAuction(IERC20 indexed token);
    event TokenRevokedForAuction(IERC20 indexed token);

    event NFTSupportedForSwap(IERC721 indexed nft);
    event NFTRevokedForSwap(IERC721 indexed nft);

    error ZeroAddress();

    function supportAuctionNFT(IERC721 nft) external;
    function revokeAuctionNFT(IERC721 nft) external;

    function supportToken(IERC20 token) external;
    function revokeToken(IERC20 token) external;

    function supportSwapNFT(IERC721 nft) external;
    function revokeSwapNFT(IERC721 nft) external;
}