// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title AuctionContractInfo
* @author fps (@0xfps).
* @dev  AuctionContractInfo contract.
*       Stores the data for the auction contract.
*/

abstract contract AuctionContractInfo {
    address private auctionContract;

    error ZeroAddress();
    error NotAuctionContract();

    constructor(address _auctionContract) {
        if (_auctionContract == address(0)) revert ZeroAddress();
        auctionContract = _auctionContract;
    }

    modifier calledByAuction() {
        if (msg.sender != auctionContract) revert NotAuctionContract();
        _;
    }
}
