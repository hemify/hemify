// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title SwapTax
* @author fps (@0xfps).
* @dev A contract for tax fee calculation.
*/

abstract contract SwapTax {
    // Set now, variable later.
    uint256 public fee = 0.005 ether;

    uint256 internal swapTax = 5;
    address internal taxer;

    constructor() {
        taxer = msg.sender;
    }

    function setSwapTax(uint256 amount) public {
        if (msg.sender != taxer) revert("NOT_TAXER");
        swapTax = amount;
    }

    function setFee(uint256 amount) public {
        if (msg.sender != taxer) revert("NOT_TAXER");
        fee = amount;
    }

    /// @dev 0.5% tax (5/1000).
    function afterSwapTax(uint256 amount) public view returns (uint256) {
        return amount - _tax(amount);
    }

    /// @dev 0.5% tax (5/1000).
    function _tax(uint256 amount) private view returns (uint256) {
        return (swapTax * amount) / 1000;
    }
}