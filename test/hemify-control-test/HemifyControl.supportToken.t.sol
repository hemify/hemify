// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface}
from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHemifyControl} from "../../src/interfaces/IHemifyControl.sol";

import {HemifyControlTest} from "./HemifyControl.t.sol";

contract SupportTokenTest is HemifyControlTest {
    function testSupportTokenByNonOwner(
        address _addr,
        address _token,
        address _agg
    )
        public
    {
        vm.assume(_addr != cOwner);
        vm.assume(_token != address(0));
        vm.assume(_agg != address(0));

        AggregatorV3Interface agg = AggregatorV3Interface(_agg);
        IERC20 token = IERC20(_token);

        vm.prank(_addr);
        vm.expectRevert();
        hemifyControl.supportToken(token, agg);
    }

    function testSupportTokenWithTokenAddress0(address _agg) public {
        vm.assume(_agg != address(0));

        AggregatorV3Interface agg = AggregatorV3Interface(_agg);
        IERC20 token = IERC20(address(0));

        vm.expectRevert();
        vm.prank(cOwner);
        hemifyControl.supportToken(token, agg);
    }

    function testSupportTokenWithAggregatorAddress0(address _token) public {
        vm.assume(_token != address(0));

        AggregatorV3Interface agg = AggregatorV3Interface(address(0));
        IERC20 token = IERC20(_token);

        vm.expectRevert();
        vm.prank(cOwner);
        hemifyControl.supportToken(token, agg);
    }

    function testSupportTokenExpectSuccess(
        address _token,
        address _agg
    )
        public
    {
        vm.assume(_token != address(0));
        vm.assume(_agg != address(0));

        AggregatorV3Interface agg = AggregatorV3Interface(_agg);
        IERC20 token = IERC20(_token);

        vm.prank(cOwner);
        hemifyControl.supportToken(token, agg);

        assertTrue(hemifyControl.isSupported(token));
        assert(hemifyControl.getTokenAggregator(token) == agg);
    }
}