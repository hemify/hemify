// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title PriceChecker
* @author fps (@0xfps).
* @dev  A contract for utilizing Chainlink Aggregator V3 to compare prices of
*       supported Tokens/ETH.
*       Formular:
*           1(T/USD) * X(T) * 1E26
*       --------------------------------
*       1E(decimals(T) + 8) * 1(ETH/USD)
*/

abstract contract PriceChecker {
    error BelowZero();

    AggregatorV3Interface constant ETH_TO_USD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    function convertToETH(
        AggregatorV3Interface agg,
        IERC20 token,
        uint256 amount
    )
        public
        view
        returns (uint256)
    {
        (, int price_, , , ) = agg.latestRoundData();
        if (price_ < 0) revert BelowZero();

        (, int _price, , , ) = ETH_TO_USD.latestRoundData();
        if (_price < 0) revert BelowZero();

        uint8 _decimals = ERC20(address(token)).decimals();

        uint256 tokenPrice = uint256(price_);
        uint256 ethPrice = uint256(_price);
        uint256 power = uint256(_decimals + 8);

        uint256 equivalent = (tokenPrice * amount * 1e26)/((10 ** power) * ethPrice);

        return equivalent;
    }
}