// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {AggregatorV3Interface}
    from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {PriceCheckerImplementer} from "./PriceCheckerImplementer.sol";

contract PriceCheckerTest is Test, Addresses {
    PriceCheckerImplementer internal implementer;

    // Address of DAI on Mainnet.
    IERC20 internal token = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    uint256 internal amount = 50e18;
    AggregatorV3Interface internal aggDAI = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);
    AggregatorV3Interface internal fakeDAI = AggregatorV3Interface(address(10000));
    uint256 internal currentFork = 10;

    function setUp() public {
        currentFork = vm.createSelectFork("https://eth.meowrpc.com/");
        implementer = new PriceCheckerImplementer();
    }

    function testSetUp() public {
        assertTrue(address(implementer) != address(0));
        assertTrue(currentFork != 10);
    }

    function testConvertFakeToken() public {
        vm.expectRevert();
        uint256 ethValue = implementer.convertToETH(fakeDAI, token, amount);
        ethValue;
    }

    function testConvertToETHForValidDAI() public {
        uint256 ethValue = implementer.convertToETH(aggDAI, token, amount);
        ethValue;
    }
}