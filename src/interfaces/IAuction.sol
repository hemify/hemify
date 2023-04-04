// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IAuction
* @author fps (@0xfps).
* @dev  Auction contract interface.
*       U N F I N I S H E D !
*/

interface IAuction {
    enum AuctionState {
        DORMANT,
        LIVE,
        RESOLVED
    }

    struct Auction {
        IERC721 nft;
        uint256 id;
        uint256 price;
        uint256 highestBid;
        uint128 auctionStart;
        uint128 auctionEnd;
        mapping(address => uint256) ethBids;
        mapping(address => mapping(IERC20 => uint256)) tokenBids;
        address winner;
        AuctionState state;
    }

    event ETHBid(uint256 indexed auctionId, uint256 indexed amount);
    event NewListing(IERC721 indexed nft, uint256 indexed endDate);
    event Resolved(IERC721 indexed nft);
    event TokenBid(
        uint256 indexed auctionId,
        IERC20 indexed token,
        uint256 indexed amount
    );

    function list(
        IERC721 nft,
        uint256 id,
        uint256 minPrice,
        uint128 auctionStart,
        uint128 auctionEnd
    ) external returns (uint256, bool);

    function bidWithETH(uint256 auctionId) external payable returns (bool);

    function bidWithToken(
        uint256 auctionId,
        IERC20 token,
        uint256 amount
    ) external returns (bool);

    function cancelBid(uint256 auctionId) external returns (bool);

    function resolve(uint256 auctionId) external returns (bool);

    function claim(uint256 auctionId) external returns (bool);

    function getAuction(uint256 auctionId) external view returns (
        IERC721 nft,
        uint256 id,
        uint256 price,
        uint256 highestBid,
        uint128 auctionStart,
        uint128 auctionEnd,
        address winner,
        AuctionState state
    );
}