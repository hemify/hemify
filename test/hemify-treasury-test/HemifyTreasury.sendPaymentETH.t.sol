// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasurySendPaymentETHTest is HemifyTreasuryTest {
    address internal receiver = vm.addr(0x12345678);

    function _deposit() internal {
        vm.startPrank(alice);
        hemifyTreasury.deposit{value: alice.balance}();
        vm.stopPrank();

        vm.startPrank(ian);
        hemifyTreasury.deposit{value: ian.balance}();
        vm.stopPrank();

        assertEq(address(hemifyTreasury).balance, 20 ether);
    }

    function testSendPaymentETHFromNonAllowedAddress(address _addr) public {
        vm.assume(_addr != ian);
        vm.assume(_addr != alice);
        vm.assume(_addr != address(0));

        _deposit();

        uint256 hemifyBalance = address(hemifyTreasury).balance;

        vm.expectRevert();
        vm.prank(_addr);
        hemifyTreasury.sendPayment(receiver, hemifyBalance);

        assertEq(receiver.balance, 0);
        assertEq(address(hemifyTreasury).balance, hemifyBalance);
    }

    function testSendPaymentETHToZeroAddresss() public {
        _deposit();

        uint256 hemifyBalance = address(hemifyTreasury).balance;

        vm.prank(alice);
        vm.expectRevert();
        hemifyTreasury.sendPayment(address(0), hemifyBalance);

        assertEq(receiver.balance, 0);
        assertEq(address(hemifyTreasury).balance, hemifyBalance);
    }

    function testSendPaymentETHGTHemifyBalance() public {
        _deposit();

        uint256 hemifyBalance = address(hemifyTreasury).balance;

        vm.prank(alice);
        vm.expectRevert();
        hemifyTreasury.sendPayment(receiver, hemifyBalance + 1);

        assertEq(receiver.balance, 0);
        assertEq(address(hemifyTreasury).balance, hemifyBalance);
    }

    function testSendPaymentETHToValidAddress() public {
        _deposit();

        uint256 hemifyBalance = address(hemifyTreasury).balance;

        vm.prank(alice);
        hemifyTreasury.sendPayment(chris, hemifyBalance);

        assertEq(chris.balance, hemifyBalance);
        assertEq(address(hemifyTreasury).balance, 0);
    }
}