// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IHemifyEscrow
* @author fps (@0xfps).
* @custom:version 1.0.0
* @dev  HemifyEscrow contract interface.
*       This interface controls the `HemifyEscrow` contract.
*/

interface IHemifyEscrow {
    /// @dev Events for NFT deposits and sendings from contract.
    /// @param nft  NFT address.
    /// @param id   NFT ID.
    event NFTDeposit(IERC721 indexed nft, uint256 indexed id);
    /// @param to   Address receiving NFT.
    event NFTSent(
        IERC721 indexed nft,
        uint256 indexed id,
        address indexed to
    );

    error NotOwnerOrAuthorized();
    error TokenNotOwned();
    error TokenAlreadyOwned();

    /// @dev Accepts `nft` ID `id` into the contract from `from`.
    /// @notice View [src/contracts/HemifyEscrow.sol] for details.
    function depositNFT(address from, IERC721 nft, uint256 id)
        external
        returns (bool);

    /// @dev Sends `nft` ID `id` to `to`.
    /// @notice View [src/contracts/HemifyEscrow.sol](http://rb.gy/3w8pe) for details.
    function sendNFT(IERC721 nft, uint256 id, address to)
        external
        returns (bool);
}