// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IHemifyControl} from "../../interfaces/IHemifyControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IHemifyEscrow} from "../../interfaces/IHemifyEscrow.sol";
import {IHemifyAuctionV1} from "../../interfaces/IHemifyAuctionV1.sol";
import {IHemifyTreasury} from "../../interfaces/IHemifyTreasury.sol";

import {PriceChecker} from "../utils/PriceChecker.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Taxes} from "../utils/Taxes.sol";

/**
* @title HemifyAuctionV1.
* @author fps (@0xfps).
* @dev  Core Auction Contract.
* @custom:owner     BotBuddyz.
* @custom:version   0.0.1.
* @notice   NFT Auction contract. NFTs are listed by the owner or an approved
*           personnel via the `list()` function. This will return the `id` of the
*           auction. The NFT is sent to the `HemifyEscrow` contract for the duration
*           of the auction.
*
*           Auctions can be closed at any time on the condition that there have been
*           no bids on it.
*
*           Interested buyers make bids using the overloaded function `bid()` for
*           ETH and Token (only supported tokens) bids, and is only possible if the
*           auction is live.
*
*           Highest bidder takes the `_auction.auctionWinner` spot for a particular
*           `auctionId` sent by the bidder.
*
*           Token bids are converted into their ETH equivalent via formula specified
*           in the `PriceChecker` contract and bidder can only take the `_auction.auctionWinner`
*           spot if the equivalence of their token bid is > the current highest bid ETH
*           for that `auctionId`.
*
*           Bids can be cancelled by the bidder and their funds restored to them.
*
*           Auction owner can resolve the auction after the auction time has passed. The winning
*           bid is sent to the auction owner after 1% taxes have been deducted. The NFT is
*           then claimable by the winner of the auction. Any bid made after the auction end
*           date has passed is reverted.
*
*           After auction resolution, bidders can reclaim the bids they lost and bids cannot
*           be cancelled, rather, reclaimed.
*/

contract HemifyAuctionV1 is IHemifyAuctionV1, PriceChecker, Taxes {
    IHemifyControl internal control;
    IHemifyEscrow internal escrow;
    IHemifyTreasury internal treasury;

    /// @dev Auction index count.
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

        control = IHemifyControl(_control);
        escrow = IHemifyEscrow(_escrow);
        treasury = IHemifyTreasury(_treasury);
    }

    /// @dev Handle incoming funds by sending them to treasury.
    receive() external payable {
        treasury.deposit{value: msg.value}();
    }

    /// @dev Handle incoming funds by sending them to treasury.
    fallback() external payable {
        treasury.deposit{value: msg.value}();
    }

    /**
    * @dev  Allows an NFT owner or an approved person to list an NFT
    *       for auction.
    * @notice   Auctioneers are allowed to list any NFT that they own or are
    *           approved to spend by the owner. Of course, before NFTs are listed
    *           for auction, the `HemifyEscrow` contract must be first approved via a
    *           `setApprovalForAll()` in the `ERC721` NFT contract.
    *
    *           Auction min prices cannot be `0`.
    *
    *           Auction start times and end times must be in the future with the end
    *           time being further than the start time.
    * @param _nft           NFT address.
    * @param _id            NFT id.
    * @param _minPrice      Minimum price for auction bids.
    * @param _auctionStart  Auction start time.
    * @param _auctionEnd    Auction end time.
    * @return uint256       Auction id.
    * @return bool          Auction creation status.
    */
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

    /**
    * @dev Allows `msg.sender` to make an ETH bid on an existing auction.
    * @notice   Allows anyone to make an ETH bid on an existing auction.
    *           Auction must exist and will be LIVE.
    *           Bids must be higher than `minPrice` (for first bid) and
    *           `highestBid` (for subsequent bids).
    *           Auction owners cannot bid on their auctions.
    *           If the current ETH is > the highest bid, it will set
    *           `highestBidIsInETH` to true and set the `highestBidToken` to `address(0)`,
    *           and delete the `highestBidTokenAmount`.
    *           It doesn't delete or refund the previous highest bid from the mapping.
    *           The bidder of the previous highest bid can always cancel their bid as long as
    *           auction is LIVE.
    * @param auctionId  ID of the auction to bid on.
    * @return bool Bid status.
    */
    function bid(uint256 auctionId) public payable returns (bool) {
        /// @dev    Inexistent auctions will have `auctionOwner` as address(0), which
        ///         will return `false` by
        ///         `else if (_auction.auctionOwner == address(0)) return false;`.
        ///         Check out function for other checks.
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

    /**
    * @dev Allows `msg.sender` to make a token bid on an existing auction.
    * @notice   Allows anyone to make a token bid on an existing auction.
    *           Auction must exist and will be LIVE.
    *           Tokens will only be approved tokens in `HemifyControl`.
    *           All token amount sent will be evaluated to their ETH worth at
    *           the time of bidding (and `bid()` logic runs).
    *           Bids must be higher than `minPrice` (for first bid) and
    *           `highestBid` (for subsequent bids).
    *           If the current ETH is > the highest bid, it will set
    *           `highestBidIsInETH` to false and set the `highestBidToken` to token,
    *           and set the `highestBidTokenAmount` to the amount of tokens sent.
    *           It doesn't delete or refund the previous highest bid from the mapping.
    *           The bidder of the previous highest bid can always cancel their bid as long as
    *           auction is LIVE.
    * @param auctionId  ID of the auction to bid on.
    * @param token      IERC20 token to bid with.
    * @param amount     Amount of tokens to send.
    * @return bool Bid status.
    */
    function bid(uint256 auctionId, IERC20 token, uint256 amount)
        public
        returns (bool)
    {
        /// @dev    Inexistent auctions will have `auctionOwner` as address(0), which
        ///         will return `false` by
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

    /**
    * @dev Allows `msg.sender` to cancel bid made with ETH.
    * @notice   Allows caller to cancel and reclaim all their bid funds.
    *           Caller must not be the current highest bidder, and auction must
    *           be LIVE.
    * @param auctionId ID of auction.
    * @return bool State of cancel.
    */
    function cancelBid(uint256 auctionId) public returns (bool) {
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

    /**
    * @dev Allows `msg.sender` to cancel bid made with ETH.
    * @notice   Allows caller to cancel and reclaim all their bid token funds.
    *           Caller must not be the current highest bidder, and auction must
    *           be LIVE.
    * @param auctionId ID of auction.
    * @return bool State of cancel.
    */
    function cancelBid(uint256 auctionId, IERC20 token) public returns (bool) {
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

    /**
    * @dev Allows auction owner to resolve auction and stop subsequent bids.
    * @notice   If the auction winner is the zero address, i.e. there have been
    *           no bids, it is advised to use `removeAuction()` instead.
    *           This function will send the token or ETH highest bid to the
    *           auction owner and set the auction state to RESOLVED.
    * @param auctionId ID of auction.
    * @return bool Resolution state.
    */
    function resolve(uint256 auctionId) public returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (msg.sender != _auction.auctionOwner) revert NotAuctionOwner();
        if (_auction.state != AuctionState.LIVE) revert AuctionNotLive();
        if (block.timestamp < _auction.auctionEnd) revert AuctionStillLive();

        address _auctionOwner = _auction.auctionOwner;
        address _auctionWinner = _auction.auctionWinner;

        if (_auctionWinner == address(0)) revert ZeroAddress();

        _auction.state = AuctionState.RESOLVED;
        auctions[auctionId] = _auction;

        bool sent;

        /// @dev `highestBidIsInETH` is `true`.
        if (_auction.highestBidIsInETH) {
            uint256 payment = _auction.highestBid;

            ethBids[auctionId][_auctionWinner] -= payment;

            sent = treasury.sendPayment(_auctionOwner, afterTax(payment));
            if (!sent) revert NotSent();
        }

        /// @dev `highestBidIsInETH` is `false`.
        if (!_auction.highestBidIsInETH) {
            IERC20 paymentToken = _auction.highestBidToken;
            uint256 payment = _auction.highestBidTokenAmount;

            tokenBids[auctionId][_auctionWinner][paymentToken] -= payment;

            sent = treasury.sendPayment(paymentToken, _auctionOwner, afterTax(payment));
            if (!sent) revert NotSent();
        }

        emit Resolved(auctionId);

        return sent;
    }

    /**
    * @dev Allows the auction winner to claim their NFT.
    * @notice   Auction rewards can be claimed only when they're RESOLVED,
    *           after which, it's set to CLAIMED.
    * @param auctionId ID of auction.
    * @return bool Claim state.
    */
    function claim(uint256 auctionId) public returns (bool) {
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

    /**
    * @dev Lets the auction owner remove an auction.
    * @notice For this to be possible, there has to be no submitted bid.
    * @param auctionId ID of auction.
    * @return bool Removal state.
    */
    function removeAuction(uint256 auctionId) public returns (bool) {
        Auction memory _auction = auctions[auctionId];
        if (msg.sender != _auction.auctionOwner) revert NotAuctionOwner();
        if (
            (_auction.state == AuctionState.RESOLVED) ||
            (_auction.state == AuctionState.CLAIMED)
        ) revert AuctionNotLiveOrDormant();

        if (_auction.auctionWinner != address(0)) revert BiddingStarted();

        IERC721 _nft = _auction.nft;
        uint256 _id = _auction.id;

        delete auctions[auctionId];

        bool sent = escrow.sendNFT(_nft, _id, msg.sender);
        if (!sent) revert NotSent();

        return sent;
    }

    /**
    * @dev Allows caller to recover their lost non-highest bids on `auctionId`.
    * @notice Taxes aren't taken for losers.
    * @param auctionId ID of auction.
    * @return bool Recovery state.
    */
    function recoverLostBid(uint256 auctionId) public returns (bool) {
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

    /**
    * @dev Allows caller to recover their lost non-highest bids on `auctionId`.
    * @notice Taxes aren't taken for losers.
    * @param auctionId  ID of auction.
    * @param token      Token address caller bid with on `auctionId`.
    * @return bool Recovery state.
    */
    function recoverLostBid(uint256 auctionId, IERC20 token) public returns (bool) {
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

    /**
    * @dev Returns the highest bid for `auctionId`.
    * @param auctionId ID of auction.
    * @return highestBidIsInETH     True if the current highest bid is in ETH,
    *                               false otherwise.
    * @return highestBidToken       Address of highest bid token, address(0) if
    *                               above is true, valid if false.
    * @return highestBid            ETH value or ETH equivalent (for tokens) of
    *                               the highest bid.
    * @return highestBidTokenAmount Actual amount of token bid if `highestBidIsInETH`
    *                               is false.
    */
    function getHighestBid(uint256 auctionId) public view returns (
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

    /// @dev Returns the auction data for `auctionId`.
    /// @param auctionId ID of auction.
    /// @return Auction Auction `auctionId`'s data.
    function getAuction(uint256 auctionId) public view returns (Auction memory) {
        // For all auctions, no matter what.
        Auction memory _auction = auctions[auctionId];
        return _auction;
    }

    /**
    * @dev Checks to verify if `auctionId` can be bid on.
    * @param _auctionId ID of auction.
    * @return bool True if the auction can be bid on, false if otherwise.
    */
    function _canBid(uint256 _auctionId) private returns (bool) {
        Auction memory _auction = auctions[_auctionId];

        if (
            (_auction.state == AuctionState.RESOLVED) ||
            (_auction.state == AuctionState.CLAIMED)
        ) return false;
        else if (_auction.auctionOwner == address(0)) return false;
        else if (block.timestamp >= _auction.auctionEnd) return false;
        else if (_auction.state == AuctionState.LIVE) return true;
        else if (block.timestamp >= _auction.auctionStart) {
            auctions[_auctionId].state = AuctionState.LIVE;
            return true;
        } else return false;
    }
}