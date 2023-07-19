// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasuryDepositETHTest is HemifyTreasuryTest {
    function testDepositETHByNonAllowedAddress(address _addr) public {
        vm.assume(_addr != ian);
        vm.assume(_addr != alice);

        vm.deal(_addr, 0.1 ether);

        vm.expectRevert();
        vm.prank(_addr);
        hemifyTreasury.deposit{value: 10 ether}();
    }

    function testDepositETHByNonAddress() public {
        vm.prank(alice);
        hemifyTreasury.deposit{value: alice.balance}();

        vm.prank(ian);
        hemifyTreasury.deposit{value: ian.balance}();

        assertEq(address(hemifyTreasury).balance, 20 ether);
        assertEq(alice.balance, 0);
        assertEq(ian.balance, 0);
    }

    function testFallbackAndReceive(address _addr) public {
        vm.assume(_addr != address(0));
        vm.deal(_addr, 1 ether);
        vm.prank(_addr);
        (bool success, ) =
            address(hemifyTreasury).call{value: 1 ether}(abi.encodeWithSignature("input()"));

        assertEq(success, true);
        assertEq(address(hemifyTreasury).balance, 1 ether);
    }
}