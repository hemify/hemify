// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IEscrow
* @author fps (@0xfps).
* @dev Escrow contract interface.
*/

interface IEscrow {
    function depositNFT(
        IERC721 token,
        uint256 id
    ) external returns (bool);

    function sendNFT(
        IERC721 token,
        uint256 id,
        address to
    ) external returns (bool);
}