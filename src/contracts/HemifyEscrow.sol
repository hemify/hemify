// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IHemifyEscrow} from "../interfaces/IHemifyEscrow.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {Gated, SimpleMultiSig} from "./utils/Gated.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title HemifyEscrow
 * @author fps (@0xfps).
 * @dev  HemifyEscrow contract.
 *       A contract to hold NFTs during auction duration.
 *       Any contract can interact with this contract as long as it's been
 *       `allow`ed by this contract via the `Gated` contract via multisig.
 */

contract Escrow is IHemifyEscrow, IERC721Receiver, Gated, ReentrancyGuard {
    /// @dev Initialize protective multi-sig of at least 5 addresses.
    /// @param _addresses 5 or more addresses for multi-sig protection.
    constructor(address[] memory _addresses) 
        SimpleMultiSig(_addresses) {}

    /**
     * @dev Accepts `nft` from `from`.
     * @notice   This function is callable by any address `allow`ed by this
     *           contract. To see how addresses can be `allow`ed, checkout
     *           utils/Gated.sol.
     *           NFTs are asserted to be owned by this contract after transfer.
     *           This contract will be approved by `from` to move NFTs via the
     *           `setApprovalForAll()` function in OpenZeppelin's ERC721 implementation.
     *           Also, `from` must be the owner, or is approved by the owner of the NFT
     *           for transfers.
     * @param from   NFT owner or approved spender.
     * @param nft    NFT address.
     * @param id     NFT id.
     * @return bool  Status of NFT transfer and ownership.
     */
    function depositNFT(
        address from,
        IERC721 nft,
        uint256 id
    ) 
        external 
        onlyAllowed
        returns (bool)
    {
        // All NFTs are supported for auctions.
        // NFTs for swap are gated on the swap contracts.
        address nftOwner = nft.ownerOf(id);

        if (
            (nftOwner != from) &&
            (nft.getApproved(id) != from) &&
            (!nft.isApprovedForAll(nftOwner, from))
        ) revert NotOwnerOrAuthorized();

        /// @dev    Caller must set isApprovedForAll() for this call
        ///         to be successful.
        nft.safeTransferFrom(from, address(this), id);

        assert(nft.ownerOf(id) == address(this));

        emit NFTDeposit(nft, id);

        return true;
    }

    /**
     * @dev Sends an `nft` to `to`.
     * @notice   This function sends nft id `id` from this contract
     *           to `to`. Grounds are that nft `id` must be owned by
     *           this contract and `to` is not a zero address and
     *           is also not this contract. Just like `depositNFT()`,
     *           it is only callable by addresses `allow`ed by this
     *           contract.
     * @param nft    NFT address.
     * @param id     NFT id.
     * @param to     Receiver.
     * @return bool  Status of NFT transfer and ownership.
     */
    function sendNFT(
        IERC721 nft,
        uint256 id,
        address to
    ) 
        external
        nonReentrant
        onlyAllowed
        returns (bool)
    {
        if (nft.ownerOf(id) != address(this)) revert TokenNotOwned();
        if (to == address(0)) revert ZeroAddress();
        if (to == address(this)) revert TokenAlreadyOwned();

        nft.transferFrom(address(this), to, id);

        assert(nft.ownerOf(id) == to);

        emit NFTSent(nft, id, to);

        return true;
    }

    /// @dev OpenZeppelin requirement for NFT receptions.
    /// @return bytes4  bytes4(keccak256(
    ///                     onERC721Received(address,address,uint256,bytes)
    ///                 )) => 0x150b7a02.
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return 0x150b7a02;
    }
}
