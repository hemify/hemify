// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyEscrowSignTest} from "./HemifyEscrow.sign.t.sol";

contract HemifyEscrowAllowTest is HemifyEscrowSignTest {
    function testAllowWhenNonOwner(address _addr, address _allow) public {
        vm.assume(_addr != cOwner);
        vm.assume(_allow != address(0));

        vm.expectRevert();
        vm.prank(_addr);
        hemifyEscrow.allow(_allow);
    }

    function testAllowByOwnerWhenAllNotSigned(address _allow, uint8 j) public {
        vm.assume(_allow != address(0));
        vm.assume(j < 6);

        for (uint i; i != j; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyEscrow.allow(_allow);
    }

    function testAllowZeroAddressByOwnerWhenAllSigned() public {
        for (uint i; i != 7; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyEscrow.allow(address(0));
    }

    function testAllowByOwnerWhenAllSigned(address _allow) public {
        vm.assume(_allow != address(0));

        for (uint i; i != 7; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        vm.prank(cOwner);
        hemifyEscrow.allow(_allow);
    }
}