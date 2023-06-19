// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title AuctionTax
* @author fps (@0xfps).
* @dev A contract for tax fee calculation.
*/

abstract contract AuctionTax {
    uint256 internal auctionTax = 1;
    address internal taxer;

    constructor() {
        taxer = msg.sender;
    }

    function setAuctionTax(uint256 amount) public {
        if (msg.sender != taxer) revert("NOT_TAXER");
        auctionTax = amount;
    }

    function afterAuctionTax(uint256 amount) public view returns (uint256) {
        return amount - _tax(amount);
    }

    /// @dev 1% tax.
    function _tax(uint256 amount) private view returns (uint256) {
        return (auctionTax * amount) / 100;
    }
}