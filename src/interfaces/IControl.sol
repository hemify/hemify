// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IControl
* @author fps (@0xfps).
* @dev  Control contract interface.
*/

interface IControl {
    function supportAuctionNFT(IERC721 nft) external;
    function revokeAuctionNFT(IERC721 nft) external;

    function supportToken(IERC20 token) external;
    function revokeToken(IERC20 token) external;

    function supportSwapNFT(IERC721 nft) external;
    function revokeSwapNFT(IERC721 nft) external;
}