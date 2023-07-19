// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasurySendTokenTest is HemifyTreasuryTest {
    address internal receiver = vm.addr(0x12345678);

    modifier _deposit() {
        vm.prank(alice);
        hemifyTreasury.deposit(alice, testToken, _amount);

        vm.prank(ian);
        hemifyTreasury.deposit(ian, testToken, _amount);

        _;
    }

    function testSendPaymentByNonAllowedAddress(address _addr) public _deposit {
        vm.assume((_addr != alice) && (_addr != ian));

        vm.prank(_addr);
        vm.expectRevert();
        hemifyTreasury.sendPayment(testToken, receiver, _amount);

        assertEq(testToken.balanceOf(receiver), 0);
        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testSendPaymentToZeroAddress() public _deposit {
        vm.prank(alice);
        vm.expectRevert();
        hemifyTreasury.sendPayment(testToken, address(0), _amount);

        assertEq(testToken.balanceOf(receiver), 0);
        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testSendPaymentBackToHemifyTreasury() public _deposit {
        vm.prank(alice);
        vm.expectRevert();
        hemifyTreasury.sendPayment(testToken, address(hemifyTreasury), _amount);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testSendPaymentOfAmountGTHemifyTreasuryBalance() public _deposit {
        vm.prank(alice);
        vm.expectRevert();
        hemifyTreasury.sendPayment(testToken, address(hemifyTreasury), _amount + 1);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testSendPaymentToValidAddress(address _addr) public _deposit {
        vm.assume(_addr != address(0));
        vm.assume((_addr != alice) && (_addr != ian));
        vm.assume(_addr != address(hemifyTreasury));

        vm.prank(alice);
        hemifyTreasury.sendPayment(testToken, _addr, _amount);

        assertEq(testToken.balanceOf(_addr), 10 ether);
        assertEq(testToken.balanceOf(address(hemifyTreasury)), 10 ether);
    }
}