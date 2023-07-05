// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyEscrowSignTest} from "./HemifyEscrow.sign.t.sol";

contract HemifyEscrowDisAllowTest is HemifyEscrowSignTest {
    function testDisAllowWhenNonOwner(address _addr, address _disAllow) public {
        vm.assume(_addr != cOwner);
        vm.assume(_disAllow != address(0));

        vm.expectRevert();
        vm.prank(_addr);
        hemifyEscrow.disAllow(_disAllow);
    }

    function testDisAllowByOwnerWhenAllNotSigned(address _disAllow, uint8 j) public {
        vm.assume(_disAllow != address(0));
        vm.assume(j < 6);

        for (uint i; i != j; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyEscrow.disAllow(_disAllow);
    }

    function testDisAllowByOwnerWhenAllSigned(address _disAllow) public {
        vm.assume(_disAllow != address(0));

        for (uint i; i != 7; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        vm.prank(cOwner);
        hemifyEscrow.disAllow(_disAllow);
    }
}