// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IControl
* @author fps (@0xfps).
* @dev  Control contract interface.
*       This interface controls the `Control` contract.
*/

interface IControl {
    /// @dev    Events for different supports and revokes of tokens for payments.
    /// @notice token IERC20 token address supported or revoked.
    event TokenSupportedForAuction(IERC20 indexed token);
    event TokenRevokedForAuction(IERC20 indexed token);

    event NFTSupportedForSwap(IERC721 indexed nft);
    event NFTRevokedForSwap(IERC721 indexed nft);

    error NotSupported();
    error ZeroAddress();

    function supportToken(IERC20 token, AggregatorV3Interface agg) external;
    function revokeToken(IERC20 token) external;

    function supportSwapNFT(IERC721 nft) external;
    function revokeSwapNFT(IERC721 nft) external;

    function isSupported(IERC20 token) external view returns (bool);
    function isSupportedForSwap(IERC721 nft) external view returns (bool);
    function getTokenAggregator(IERC20 token) external view returns (AggregatorV3Interface);
}