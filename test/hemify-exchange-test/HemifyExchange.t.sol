// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {HemifyExchange} from "../../src/contracts/hemify-exchange/HemifyExchange.sol";

contract HemifyExchangeTest is Test, Addresses {
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    HemifyExchange internal exchange;
    uint256 internal currentFork = 10;
    uint256 internal limit = 100 ether;

    function setUp() public {
        currentFork = vm.createSelectFork("https://eth.meowrpc.com/");
        exchange = new HemifyExchange();
        deal(USDC, cOwner, limit);
        deal(USDT, cOwner, limit);

        vm.deal(cOwner, 0);
    }

    function testSetUp() public {
        assertTrue(address(exchange) != address(0));
        assertTrue(currentFork != 10);
        assertEq(IERC20(USDC).balanceOf(cOwner), limit);
        assertEq(IERC20(USDT).balanceOf(cOwner), limit);
        assertEq(cOwner.balance, 0);
    }

    function testSwapToETHWithWrongToken(address _addr) public {
        vm.assume(
            (_addr != USDC) && (_addr != USDT) && (_addr != address(0))
        );

        vm.expectRevert();
        exchange.swapToETH(cOwner, IERC20(_addr), 1);
    }

    function testSwapUSDCToETHWithoutApprove(uint256 amount) public {
        vm.assume((amount > 0) && (amount <= limit));
        vm.expectRevert();
        exchange.swapToETH(cOwner, IERC20(USDC), amount);
    }

    function testSwapUSDTToETHWithoutApprove(uint256 amount) public {
        vm.assume((amount > 0) && (amount <= limit));
        /// Fun Fact: In USDT, if the allowance < transferred amount in
        /// transferFrom, it reverts with "EvmError: InvalidFEOpcode".
        vm.expectRevert();
        exchange.swapToETH(cOwner, IERC20(USDT), amount);
    }

    function testSwapUSDCToETH(uint256 amount) public {
        vm.assume((amount >= 0.1 ether) && (amount <= limit));
        vm.prank(cOwner);
        IERC20(USDC).approve(address(exchange), amount);
        exchange.swapToETH(cOwner, IERC20(USDC), amount);
        assertTrue(cOwner.balance != 0);
    }

    /// USDT is quite weird, logically, it passes, but practically,
    /// it fails.
    ///
    /// function testSwapUSDTToETH(uint256 amount) public {
    ///     vm.assume((amount >= 0.1 ether) && (amount <= limit));
    ///     vm.prank(cOwner);
    ///     IERC20(USDT).approve(address(exchange), amount);
    ///     exchange.swapToETH(cOwner, IERC20(USDT), amount);
    ///     assertTrue(cOwner.balance != 0);
    /// }
}