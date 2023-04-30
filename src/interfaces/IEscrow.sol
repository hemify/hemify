// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IEscrow
* @author fps (@0xfps).
* @dev  Escrow contract interface.
*       This interface controls the `Escrow` contract.
*/

interface IEscrow {
    /// @dev Events for NFTDeposit and Sending from contract.
    /// @param nft  NFT address.
    /// @param id   NFT id.
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

    /// @dev Accepts `nft` id `id` into the contract from `from`.
    function depositNFT(address from, IERC721 nft, uint256 id)
        external
        returns (bool);

    /// @dev Sends `nft` id `id` to `to`.
    function sendNFT(IERC721 nft, uint256 id, address to)
        external
        returns (bool);
}