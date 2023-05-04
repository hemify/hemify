// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IOpenAuctionV1
* @author fps (@0xfps).
* @dev  Open Auction V1 contract interface.
*       This interface controls the basic functionalities on the `OpenAuction` contract.
*/

interface IOpenAuctionV1 {
    /**
    * @dev  Specifies the current state of the auction.
    *       DORMANT:   Auction has not yet begun.
    *       LIVE:      Auction has started.
    *       RESOLED:   Auction has ended and is resolved.
    *       CLAIMED:   Winner has taken their owned NFT.
    */
    enum AuctionState {
        DORMANT,
        LIVE,
        RESOLVED,
        CLAIMED
    }

    /**
    * @dev Auction data. Each auction will have these.
    * @param state                  Auction state.
    * @param highestBidIsInETH      `true` if the current highest bid is in ETH.
    *                               `false` if the current highest bid is in
    *                               IERC20 token.
    * @param nft                    Listed NFT.
    * @param id                     NFT id.
    * @param minPrice               Least price acceptable for the NFT in ETH.
    * @param highestBid             Current highest bid amount in ETH (Token bids are converted to ETH).
    * @param auctionStart           Start time of auction.
    * @param auctionEnd             End time of auction.
    * @param auctionOwner           Auction lister.
    * @param auctionWinner          Current auction winner.
    * @param highestBidToken        IERC20 token bid currently as the highest bid.
    * @param highestBidTokenAmount  Literal token amount sent as bid.
    *
    * @notice `highestBidIsInETH` and `highestBidToken` must be set together.
    */
    struct Auction {
        AuctionState state;
        bool highestBidIsInETH;
        IERC721 nft;
        uint256 id;
        uint256 minPrice;
        uint256 highestBid; // Always an ETH value.
        uint128 auctionStart;
        uint128 auctionEnd;
        address auctionOwner;
        address auctionWinner;
        IERC20 highestBidToken;
        uint256 highestBidTokenAmount;
    }

    /**
    * @dev Emitted when a new bid is made with ETH.
    * @param auctionId  Id of auction.
    * @param amount     Amount of ETH bid.
    */
    event Bid(uint256 indexed auctionId, uint256 indexed amount);

    /**
    * @dev Emitted when a new bid is made with a token.
    * @param auctionId  Id of auction.
    * @param token      IERC20 token.
    * @param amount     Amount of ETH bid.
    */
    event Bid(
        uint256 indexed auctionId,
        IERC20 indexed token,
        uint256 indexed amount
    );

    /**
    * @dev Emitted when a new NFT is listed for auction.
    * @param lister     Address listing NFT for auction.
    * @param nft        NFT address.
    * @param id         NFT id.
    * @param endDate    End date of auction.
    */
    event Listed(
        address indexed lister,
        IERC721 indexed nft,
        uint256 indexed id,
        uint256 endDate
    );

    /**
    * @dev Emitted when an auction is resolved.
    * @param id         NFT id.
    */
    event Resolved(uint256 indexed id);

    error AuctionNotLiveOrDormant();
    error AuctionStillLive();
    error AuctionStillLiveOrClaimed();
    error BidRejcted();
    error BiddingStarted();
    error CantCancel();
    error CantCancelHighestBid();
    error EndTimeLesserThanStartTime();
    error LowBid();
    error NotLive();
    error NotAuctionOwner();
    error NotAuctionWinner();
    error NotOwnerOrAuthorized();
    error NotSent();
    error OwnerBid();
    error StartTimeInThePast();
    error TokenNotSupported();
    error ZeroAddress();
    error ZeroPrice();
    error ZeroRefund();

    /**
    * @notice All functions here are documented in the `Auction` contract.
    */
    function list(
        IERC721 _nft,
        uint256 _id,
        uint256 _minPrice,
        uint128 _auctionStart,
        uint128 _auctionEnd
    )
        external
        returns (uint256, bool);

    function bid(uint256 auctionId) external payable returns (bool);

    function bid(uint256 auctionId, IERC20 token, uint256 amount)
        external
        returns (bool);

    function cancelBid(uint256 auctionId) external returns (bool);

    function cancelBid(uint256 auctionId, IERC20 token) external returns (bool);

    function resolve(uint256 auctionId) external returns (bool);

    function claim(uint256 auctionId) external returns (bool);

    function removeAuction(uint256 auctionId) external returns (bool);

    function recoverLostBid(uint256 auctionId) external returns (bool);

    function recoverLostBid(uint256 auctionId, IERC20 token) external returns (bool);

    function getHighestBid(uint256 auctionId) external view returns (
        bool highestBidIsInETH,
        IERC20 highestBidToken,
        uint256 highestBid,
        uint256 highestBidTokenAmount
    );

    function getAuction(uint256 auctionId) external view returns (Auction memory);
}