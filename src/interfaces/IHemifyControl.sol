// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IHemifyControl
* @author fps (@0xfps).
* @dev  HemifyControl contract interface.
*       This interface controls the `HemifyControl` contract.
*/

interface IHemifyControl {
    /// @dev    Events for different supports and revokes of tokens for payments.
    /// @notice token IERC20 token address supported or revoked.
    event TokenSupportedForAuction(IERC20 indexed token);
    event TokenRevokedForAuction(IERC20 indexed token);

    /// @dev    Events for different supports and revokes of tokens for swaps.
    /// @notice nft IERC721 token address supported or revoked.
    event NFTSupportedForSwap(IERC721 indexed nft);
    event NFTRevokedForSwap(IERC721 indexed nft);

    error NotSupported();
    error ZeroAddress();

    /// @dev Adds support for a `token` and its Chainlink aggregator, `agg`.
    /// @param token    IERC20 token.
    /// @param agg      Chainlink aggregator address on mainnet.
    function supportToken(IERC20 token, AggregatorV3Interface agg) external;
    /// @dev Removes support for a `token`.
    /// @param token    IERC20 token.
    function revokeToken(IERC20 token) external;

    /// @dev Approves NFTs from address `nft` to be legible for swaps.
    /// @param nft NFT address.
    function supportSwapNFT(IERC721 nft) external;
    /// @dev Removes NFTs `nft` from being legible for swaps.
    /// @param nft NFT address.
    function revokeSwapNFT(IERC721 nft) external;

    /// @dev Returns `true` if `token` has a registered aggregator and `false` if otherwise.
    /// @param token    IERC20 token.
    /// @return bool    True or false.
    function isSupported(IERC20 token) external view returns (bool);
    /// @dev Returns `true` if `nft` is approved for swaps and `false` if otherwise.
    /// @param nft      IERC721 token address.
    /// @return bool    True or false.
    function isSupportedForSwap(IERC721 nft) external view returns (bool);
    /// @dev Returns `AggregatorV3Interface` address registered for `token`.
    /// @param token    IERC20 token.
    function getTokenAggregator(IERC20 token) external view returns (AggregatorV3Interface);
}