// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title WagerTax
* @author fps (@0xfps).
* @dev A contract for tax fee calculation.
*/

abstract contract WagerTax {
    uint256 internal wagerTax = 45;
    address internal taxer;

    constructor() {
        taxer = msg.sender;
    }
    
    function setWagerTax(uint256 amount) public {
        if (msg.sender != taxer) revert("NOT_TAXER");
        wagerTax = amount;
    }

    /// @dev 4.5% tax (45/1000).
    function afterWagerTax(uint256 amount) public view returns (uint256) {
        return amount - _tax(amount);
    }

    /// @dev 4.5% tax (45/1000).
    function _tax(uint256 amount) private view returns (uint256) {
        return (wagerTax * amount) / 1000;
    }
}