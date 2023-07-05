// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyEscrowTest} from "./HemifyEscrow.t.sol";

contract HemifyEscrowUnSignTest is HemifyEscrowTest {
    function testUnSignByAddressNotInSignerList() public {
        vm.expectRevert();
        vm.prank(hacker);
        hemifyEscrow.unSign();
    }

    function testUnSignByAddressInSignerList(uint8 i) public {
        vm.assume(i < 7);
        vm.prank(addresses_[i]);
        hemifyEscrow.unSign();
    }
}