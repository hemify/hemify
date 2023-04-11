// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IEscrow} from "../interfaces/IEscrow.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";

import {Gated} from "./utils/Gated.sol";

/**
* @title Escrow
* @author fps (@0xfps).
* @dev  Escrow contract.
*       A contract to hold NFTs during auction duration.
*/

contract Escrow is IEscrow, IERC721Receiver, Gated {
    ITreasury private treasury;

    constructor(address _treasury) {
        if (_treasury == address(0)) revert ZeroAddress();
        treasury = ITreasury(_treasury);
    }

    receive() external payable {
        treasury.deposit{value: msg.value}();
    }

    fallback() external payable {
        treasury.deposit{value: msg.value}();
    }

    function depositNFT(
        address from,
        IERC721 nft,
        uint256 id
    ) external onlyAllowed returns (bool) {
        // Checks of IERC721 being supported are done in the Auction.
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

    function sendNFT(
        IERC721 nft,
        uint256 id,
        address to
    ) external onlyAllowed returns (bool) {
        if (nft.ownerOf(id) != address(this)) revert TokenNotOwned();
        if (to == address(0)) revert ZeroAddress();

        nft.safeTransferFrom(address(this), to, id);

        assert(nft.ownerOf(id) == to);

        emit NFTSent(nft, id, to);

        return true;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
