// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IAuction
* @author fps (@0xfps).
* @dev  Auction contract interface.
*/

interface IAuction {
    enum AuctionState {
        DORMANT,
        LIVE,
        RESOLVED
    }

    struct Auction {
        AuctionState state;
        bool highestBidIsInETH;
        IERC721 nft;
        uint256 id;
        uint256 minPrice;
        uint256 highestBid;
        uint128 auctionStart;
        uint128 auctionEnd;
        mapping(address => uint256) ethBids;
        mapping(address => mapping(IERC20 => uint256)) tokenBids;
        address winner;
        IERC20 highestBidToken;
    }

    event Bid(uint256 indexed auctionId, uint256 indexed amount);
    event Bid(
        uint256 indexed auctionId,
        IERC20 indexed token,
        uint256 indexed amount
    );
    event Listed(
        address indexed lister,
        IERC721 indexed nft,
        uint256 indexed endDate
    );
    event Resolved(IERC721 indexed nft);

    function list(
        IERC721 nft,
        uint256 id,
        uint256 minPrice,
        uint128 auctionStart,
        uint128 auctionEnd
    ) external returns (uint256, bool);

    function bid(uint256 auctionId) external payable returns (bool);

    function bid(
        uint256 auctionId,
        IERC20 token,
        uint256 amount
    ) external returns (bool);

    function cancelBid(uint256 auctionId) external returns (bool);

    function cancelBid(uint256 auctionId, IERC20 token) external returns (bool);

    function claim(uint256 auctionId) external returns (bool);

    function resolve(uint256 auctionId) external returns (bool);

    function recoverLostBid(uint256 auctionId) external returns (bool);

    function recoverLostBid(uint256 auctionId, IERC20 token) external returns (bool);

    function getHighestBid(uint256 auctionId) external view returns (
        bool highestBidIsInETH,
        IERC20 highestBidToken,
        uint256 highestBid
    );

    function getAuction(uint256 auctionId) external view returns (
        AuctionState state,
        IERC721 nft,
        uint256 id,
        uint256 minPrice,
        uint128 auctionStart,
        uint128 auctionEnd
    );
}