// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {AuctionTaxImplementer} from "./AuctionTaxImplementer.sol";

contract AuctionTaxTest is Test, Addresses {
    AuctionTaxImplementer internal implementer;

    function setUp() public {
        vm.prank(cOwner);
        implementer = new AuctionTaxImplementer();
    }

    function testSetUp() public {
        assertTrue(address(implementer) != address(0));
    }

    function testSetAuctionTaxByNonOwner(address _addr, uint256 i) public {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        implementer.setAuctionTax(i);
    }

    function testSetAuctionTaxByOwner(uint256 i) public {
        vm.prank(cOwner);
        implementer.setAuctionTax(i);
    }

    function testAfterAuctionTax(uint256 i, uint256 amount) public {
        vm.assume(i <= 100);
        vm.assume(amount < (type(uint256).max / 100));

        vm.prank(cOwner);
        implementer.setAuctionTax(i);

        uint256 perc = percent(i, amount);
        uint256 afterTax = implementer.afterAuctionTax(amount);

        assertEq(afterTax, (amount - perc));
    }

    function percent(uint256 perc, uint256 amount) internal pure returns (uint256) {
        return (perc * amount) / 100;
    }
}