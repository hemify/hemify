// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title Taxes
* @author fps (@0xfps).
* @dev A contract for tax fee calculation on ETH or token bids.
*/

abstract contract Taxes {
    function tax(uint256 amount) public view returns (uint256) {
        return 0;
    }

    function tax(IERC20 token, uint256 amount) public view returns (uint256) {
        return 0;
    }
}