// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {WagerTaxImplementer} from "./WagerTaxImplementer.sol";

contract WagerTaxTest is Test, Addresses {
    WagerTaxImplementer internal implementer;

    function setUp() public {
        vm.prank(cOwner);
        implementer = new WagerTaxImplementer();
    }

    function testSetUp() public {
        assertTrue(address(implementer) != address(0));
    }

    function testSetWagerTaxByNonOwner(address _addr, uint256 i) public {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        implementer.setWagerTax(i);
    }

    function testSetWagerTaxByOwner(uint256 i) public {
        vm.prank(cOwner);
        implementer.setWagerTax(i);
    }

    function testAfterWagerTax(uint256 i, uint256 amount) public {
        vm.assume(i <= 100);
        vm.assume(amount < (type(uint256).max / 100));

        vm.prank(cOwner);
        implementer.setWagerTax(i);

        uint256 perc = percent(i, amount);
        uint256 afterTax = implementer.afterWagerTax(amount);

        assertEq(afterTax, (amount - perc));
    }

    function percent(uint256 perc, uint256 amount) internal pure returns (uint256) {
        return (perc * amount) / 1000;
    }
}