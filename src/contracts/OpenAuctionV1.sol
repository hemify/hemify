// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IControl} from "../interfaces/IControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IEscrow} from "../interfaces/IEscrow.sol";
import {IOpenAuctionV1} from "../interfaces/IOpenAuctionV1.sol";
import {ITreasury} from "../interfaces/ITreasury.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
* @title OpenAuctionV1.
* @author fps (@0xfps).
* @dev  Core auction contract.
*/

abstract contract OpenAuctionV1 is IOpenAuctionV1 {
    IControl control;
    IEscrow escrow;
    ITreasury treasury;

    uint256 private _index;
    // mapping(auctionId => Auction) internal auctions;
    mapping(uint256 => Auction) internal auctions;
    // mapping(auctionId => bidder => bid) internal ethBids;
    mapping(uint256 => mapping(address => uint256 )) internal ethBids;
    // mapping(auctionId => bidder => bidToken => bid) internal tokenBids;
    mapping(uint256 => mapping(address => mapping(IERC20 => uint256))) internal tokenBids;

    constructor(
        address _control,
        address _escrow,
        address _treasury
    ) {
        if (
            _control == address(0) ||
            _escrow == address(0) ||
            _treasury == address(0)
        ) revert ZeroAddress();

        control = IControl(_control);
        escrow = IEscrow(_escrow);
        treasury = ITreasury(_treasury);
    }

    receive() external payable {
        treasury.deposit{value: msg.value}();
    }

    fallback() external payable {
        treasury.deposit{value: msg.value}();
    }

    // Start here.
    function list(
        IERC721 _nft,
        uint256 _id,
        uint256 _minPrice,
        uint128 _auctionStart,
        uint128 _auctionEnd
    ) public returns (uint256, bool) {
        address nftOwner = _nft.ownerOf(_id);
        if (
            (nftOwner != msg.sender) &&
            (_nft.getApproved(_id) != msg.sender) &&
            (!_nft.isApprovedForAll(nftOwner, msg.sender))
        ) revert NotOwnerOrAuthorized();

        if (_minPrice == 0) revert ZeroPrice();

        if (block.timestamp > _auctionStart) revert StartTimeInThePast();
        if (_auctionStart > _auctionEnd) revert EndTimeLesserThanStartTime();

        if (!control.isSupportedForAuction(_nft)) revert NFTNotSupported();

        // Starting with index 0.
        uint256 index = _index;
        ++_index;

        Auction memory auction;

        auction.nft = _nft;
        auction.minPrice = _minPrice;
        auction.auctionStart = _auctionStart;
        auction.auctionEnd = _auctionEnd;

        auctions[index] = auction;

        bool success = escrow.depositNFT(msg.sender, _nft, _id);
        if (!success) revert NotSent();

        return(index, success);
    }

    function bid(uint256 auctionId) public payable returns (bool) {
        if (!_canBid(auctionId)) revert BidRejcted();

        Auction memory _auction = auctions[auctionId];
        if (msg.value < _auction.minPrice) revert BidLowerThanMinPrice();

        // Start!

        return(_canBid(auctionId));
    }

    function _canBid(uint256 _auctionId) private view returns (bool) {
        Auction memory _auction = auctions[_auctionId];

        if (_auction.state == AuctionState.RESOLVED) return false;
        else if (_auction.state == AuctionState.LIVE) return true;
        else if (_auction.auctionStart <= block.timestamp) {
            auctions[_auctionId].state == AuctionState.LIVE;
            return true;
        } else return false;
    }
}