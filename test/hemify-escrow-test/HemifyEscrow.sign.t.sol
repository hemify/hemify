// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyEscrowTest} from "./HemifyEscrow.t.sol";

contract HemifyEscrowSignTest is HemifyEscrowTest {
    function testSignByAddressNotInSignerList() public {
        vm.expectRevert();
        vm.prank(hacker);
        hemifyEscrow.sign();
    }

    function testSignByAddressInSignerList(uint8 i) public {
        vm.assume(i < 7);
        vm.prank(addresses_[i]);
        hemifyEscrow.sign();
    }
}