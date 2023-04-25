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

import {PriceChecker} from "./utils/PriceChecker.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Taxes} from "./utils/Taxes.sol";

/**
* @title OpenAuctionV1.
* @author fps (@0xfps).
* @dev  Core Auction Contract.
* @custom:owner     BotBuddyz.
* @custom:version   0.0.1.
*/

abstract contract OpenAuctionV1 is IOpenAuctionV1, PriceChecker, Taxes {
    IControl control;
    IEscrow escrow;
    ITreasury treasury;

    uint256 private _index;
    // mapping(auctionId => Auction) internal auctions;
    mapping(uint256 => Auction) internal auctions;
    // mapping(auctionId => bidder => bid) internal ethBids;
    mapping(uint256 => mapping(address => uint256)) internal ethBids;
    // mapping(auctionId => bidder => bidToken => bid) internal tokenBids;
    mapping(uint256 => mapping(address => mapping(IERC20 => uint256))) internal tokenBids;

    constructor(
        address _control,
        address _escrow,
        address _treasury
    )
    {
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

    function list(
        IERC721 _nft,
        uint256 _id,
        uint256 _minPrice,
        uint128 _auctionStart,
        uint128 _auctionEnd
    )
        public
        returns (uint256, bool)
    {
        address nftOwner = _nft.ownerOf(_id);
        if (
            (nftOwner != msg.sender) &&
            (_nft.getApproved(_id) != msg.sender) &&
            (!_nft.isApprovedForAll(nftOwner, msg.sender))
        ) revert NotOwnerOrAuthorized();

        if (_minPrice == 0) revert ZeroPrice();

        if (block.timestamp > _auctionStart) revert StartTimeInThePast();
        if (_auctionStart > _auctionEnd) revert EndTimeLesserThanStartTime();

        // Starting with index 0.
        uint256 index = _index;
        ++_index;

        Auction memory _auction;

        _auction.nft = _nft;
        _auction.minPrice = _minPrice;
        _auction.auctionStart = _auctionStart;
        _auction.auctionEnd = _auctionEnd;
        _auction.auctionOwner = msg.sender;

        auctions[index] = _auction;

        bool success = escrow.depositNFT(msg.sender, _nft, _id);
        if (!success) revert NotSent();

        emit Listed(msg.sender, _nft, _id, _auctionEnd);

        return(index, success);
    }

    /// @notice Allows anyone to make an ETH bid on an existing auction.
    ///         Auction must exist and will be LIVE.
    ///         Bids must be higher than `minPrice` (for first bid) and
    ///         `highestBid` (for subsequent bids).
    ///         If the current ETH is > the highest bid, it will set
    ///         `highestBidIsInETH` to true and set the `highestBidToken` to (0),
    ///         and delete the `highestBidTokenAmount`.
    ///         It doesn't delete or refund the previous highest bid from the mapping.
    ///         The bidder of the previous highest bid can always cancel their bid.
    function bid(uint256 auctionId) external payable returns (bool) {
        /// @dev    Inexistent auctions will have `auctionEnd` as 0, which will return
        ///         `false` by
        ///         `else if (_auction.auctionOwner == address(0)) return false;`.
        if (!_canBid(auctionId)) revert BidRejcted();

        Auction memory _auction = auctions[auctionId];

        if (msg.sender == _auction.auctionOwner) revert OwnerBid();
        if ((msg.value < _auction.minPrice) || (msg.value <= _auction.highestBid))
            revert LowBid();

        /// @dev At this point, the `msg.value` is > the highest bid, and minPrice, and is in ETH.
        _auction.highestBidIsInETH = true;
        _auction.highestBid = msg.value;
        _auction.auctionWinner = msg.sender;
        delete _auction.highestBidToken;
        delete _auction.highestBidTokenAmount;

        auctions[auctionId] = _auction;

        ethBids[auctionId][msg.sender] += msg.value;

        bool sent = treasury.deposit{value: msg.value}();
        if (!sent) revert NotSent();

        emit Bid(auctionId, msg.value);

        return sent;
    }

    /// @notice Allows anyone to make a token bid on an existing auction.
    ///         Auction must exist and will be LIVE.
    ///         Tokens will only be approved tokens in `Control`.
    ///         All token amount sent will be evaluated to their ETH worth at
    ///         the time of bidding (and `bid()` logic runs).
    ///         Bids must be higher than `minPrice` (for first bid) and
    ///         `highestBid` (for subsequent bids).
    ///         If the current ETH is > the highest bid, it will set
    ///         `highestBidIsInETH` to false and set the `highestBidToken` to token,
    ///         and set the `highestBidTokenAmount` to the amount of tokens sent.
    ///         It doesn't delete or refund the previous highest bid from the mapping.
    ///         The bidder of the previous highest bid can always cancel their bid.
    function bid(uint256 auctionId, IERC20 token, uint256 amount)
        external
        returns (bool)
    {
        /// @dev    Inexistent auctions will have `auctionEnd` as 0, which will return
        ///         `false` by
        ///         `else if (_auction.auctionOwner == address(0)) return false;`.
        if (!_canBid(auctionId)) revert BidRejcted();
        if (!control.isSupported(token)) revert TokenNotSupported();

        Auction memory _auction = auctions[auctionId];
        if (msg.sender == _auction.auctionOwner) revert OwnerBid();

        AggregatorV3Interface _agg = control.getTokenAggregator(token);

        uint256 ethEquivalent = convertToETH(_agg, token, amount);
        if ((ethEquivalent < _auction.minPrice) || (ethEquivalent <= _auction.highestBid))
            revert LowBid();

        /// @dev    At this point, the `ethEquivalent` is > the highest bid, and minPrice,
        ///         and is in a known token.
        _auction.highestBidIsInETH = false;
        _auction.highestBid = ethEquivalent;
        _auction.auctionWinner = msg.sender;
        _auction.highestBidToken = token;
        _auction.highestBidTokenAmount = amount;

        auctions[auctionId] = _auction;

        tokenBids[auctionId][msg.sender][token] += amount;

        bool sent = treasury.deposit(msg.sender, token, amount);
        if (!sent) revert NotSent();

        emit Bid(auctionId, token, amount);

        return sent;
    }

    /// @notice Allows caller to cancel and reclaim his bid funds.
    ///         Caller must not be the current highest bidder, and auction must
    ///         be LIVE.
    function cancelBid(uint256 auctionId) external returns (bool) {
        if (!_canBid(auctionId)) revert CantCancel();

        Auction memory _auction = auctions[auctionId];
        if (_auction.auctionWinner == msg.sender) revert CantCancelHighestBid();

        uint256 refund = ethBids[auctionId][msg.sender];
        if (refund == 0) revert ZeroRefund();

        delete ethBids[auctionId][msg.sender];

        bool sent = treasury.sendPayment(msg.sender, refund);
        if (!sent) revert NotSent();

        return sent;
    }

    /// @notice Allows caller to cancel and reclaim his bid token funds.
    ///         Caller must not be the current highest bidder, and auction must
    ///         be LIVE.
    function cancelBid(uint256 auctionId, IERC20 token) external returns (bool) {
        if (!_canBid(auctionId)) revert CantCancel();

        Auction memory _auction = auctions[auctionId];
        if (_auction.auctionWinner == msg.sender) revert CantCancelHighestBid();

        uint256 refund = tokenBids[auctionId][msg.sender][token];
        if (refund == 0) revert ZeroRefund();

        delete tokenBids[auctionId][msg.sender][token];

        bool sent = treasury.sendPayment(token, msg.sender, refund);
        if (!sent) revert NotSent();

        return sent;
    }

    function resolve(uint256 auctionId) external returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (msg.sender != _auction.auctionOwner) revert NotAuctionOwner();
        if (_auction.state != AuctionState.LIVE) revert AuctionNotLive();

        _auction.state = AuctionState.RESOLVED;
        bool sent;

        /// @dev `highestBidIsInETH` is `true`.
        if (_auction.highestBidIsInETH) {
            uint256 payment = _auction.highestBid;
            address _auctionOwner = _auction.auctionOwner;
            address _auctionWinner = _auction.auctionWinner;

            auctions[auctionId] = _auction;

            ethBids[auctionId][_auctionWinner] -= payment;

            sent = treasury.sendPayment(_auctionOwner, afterTax(payment));
            if (!sent) revert NotSent();

            emit Resolved(auctionId);
        }

        /// @dev `highestBidIsInETH` is `false`.
        if (!_auction.highestBidIsInETH) {
            IERC20 paymentToken = _auction.highestBidToken;
            uint256 payment = _auction.highestBidTokenAmount;
            address _auctionOwner = _auction.auctionOwner;
            address _auctionWinner = _auction.auctionWinner;

            auctions[auctionId] = _auction;

            tokenBids[auctionId][_auctionWinner][paymentToken] -= payment;

            sent = treasury.sendPayment(paymentToken, _auctionOwner, afterTax(payment));
            if (!sent) revert NotSent();

            emit Resolved(auctionId);
        }

        return sent;
    }

    function claim(uint256 auctionId) external returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (msg.sender != _auction.auctionWinner) revert NotAuctionWinner();
        if (_auction.state != AuctionState.RESOLVED) revert AuctionStillLiveOrClaimed();

        _auction.state = AuctionState.CLAIMED;

        IERC721 _nft = _auction.nft;
        uint256 _id = _auction.id;

        auctions[auctionId] = _auction;

        bool sent = escrow.sendNFT(_nft, _id, msg.sender);
        if (!sent) revert NotSent();

        return sent;
    }

    /// @notice Taxes aren't taken for losers.
    function recoverLostBid(uint256 auctionId) external returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (
            _auction.state == AuctionState.DORMANT ||
            _auction.state == AuctionState.LIVE
        ) revert AuctionStillLive();

        uint256 recovery = ethBids[auctionId][msg.sender];
        if (recovery == 0) revert ZeroRefund();

        delete ethBids[auctionId][msg.sender];

        bool sent = treasury.sendPayment(msg.sender, recovery);
        if (!sent) revert NotSent();

        return sent;
    }

    function recoverLostBid(uint256 auctionId, IERC20 token) external returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (
            _auction.state == AuctionState.DORMANT ||
            _auction.state == AuctionState.LIVE
        ) revert AuctionStillLive();

        uint256 recovery = tokenBids[auctionId][msg.sender][token];
        if (recovery == 0) revert ZeroRefund();

        delete tokenBids[auctionId][msg.sender][token];

        bool sent = treasury.sendPayment(token, msg.sender, recovery);
        if (!sent) revert NotSent();

        return sent;
    }

    function getHighestBid(uint256 auctionId) external view returns (
        bool highestBidIsInETH,
        IERC20 highestBidToken,
        uint256 highestBid,
        uint256 highestBidTokenAmount
    )
    {
        /// @dev Allowed for all live auctions.
        Auction memory _auction = auctions[auctionId];
        if (_auction.state != AuctionState.LIVE) revert NotLive();

        (highestBidIsInETH, highestBidToken, highestBid, highestBidTokenAmount) =
        (
            _auction.highestBidIsInETH,
            _auction.highestBidToken,
            _auction.highestBid,
            _auction.highestBidTokenAmount
        );
    }

    function getAuction(uint256 auctionId) external view returns (Auction memory) {
        // For all auctions, no matter what.
        Auction memory _auction = auctions[auctionId];
        return _auction;
    }

    function _canBid(uint256 _auctionId) private returns (bool) {
        Auction memory _auction = auctions[_auctionId];

        if (_auction.state == AuctionState.RESOLVED) return false;
        else if (_auction.auctionOwner == address(0)) return false;
        else if (block.timestamp >= _auction.auctionEnd) return false;
        else if (_auction.state == AuctionState.LIVE) return true;
        else if (block.timestamp >= _auction.auctionStart) {
            auctions[_auctionId].state = AuctionState.LIVE;
            return true;
        } else return false;
    }
}