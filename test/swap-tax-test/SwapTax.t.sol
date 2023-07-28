// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {SwapTaxImplementer} from "./SwapTaxImplementer.sol";

contract SwapTaxTest is Test, Addresses {
    SwapTaxImplementer internal implementer;

    function setUp() public {
        vm.prank(cOwner);
        implementer = new SwapTaxImplementer();
    }

    function testSetUp() public {
        assertTrue(address(implementer) != address(0));
    }

    function testSetSwapTaxByNonOwner(address _addr, uint256 i) public {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        implementer.setSwapTax(i);
    }

    function testSetSwapTaxByOwner(uint256 i) public {
        vm.prank(cOwner);
        implementer.setSwapTax(i);
    }

    function testSetFeeByNonOwner(address _addr, uint256 fee) public {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        implementer.setFee(fee);

        assertEq(implementer.fee(), 0.005 ether);
    }

    function testSetFeeByOwner(uint256 fee) public {
        vm.prank(cOwner);
        implementer.setFee(fee);

        assertEq(implementer.fee(), fee);
    }

    function testAfterSwapTax(uint256 i, uint256 amount) public {
        vm.assume(i <= 1000);
        vm.assume(amount < (type(uint256).max / 1000));

        vm.prank(cOwner);
        implementer.setSwapTax(i);

        uint256 perc = percent(i, amount);
        uint256 afterTax = implementer.afterSwapTax(amount);

        assertEq(afterTax, (amount - perc));
    }

    function percent(uint256 perc, uint256 amount) internal pure returns (uint256) {
        return (perc * amount) / 1000;
    }
}