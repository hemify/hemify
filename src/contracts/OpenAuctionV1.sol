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

    uint256 private index;
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
        IERC721 nft,
        uint256 id,
        uint256 minPrice,
        uint128 auctionStart,
        uint128 auctionEnd
    ) public returns (uint256, bool) {
        Auction memory auction;
        return(0, true);
    }
}