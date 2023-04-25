// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title Taxes
* @author fps (@0xfps).
* @dev A contract for tax fee calculation on ETH or token bids.
*/

abstract contract Taxes {
    function afterTax(uint256 amount) public pure returns (uint256) {
        /// @dev 1% tax.
        return amount - (amount / 100);
    }
}