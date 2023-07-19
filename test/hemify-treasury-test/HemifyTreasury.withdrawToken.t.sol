// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasuryWithdraTokenTest is HemifyTreasuryTest {
    modifier _deposit() {
        vm.prank(alice);
        hemifyTreasury.deposit(alice, testToken, _amount);

        vm.prank(ian);
        hemifyTreasury.deposit(ian, testToken, _amount);

        _;
    }

    function testWithdrawByNonOwner(address _addr) public _deposit {
        vm.assume(_addr != cOwner);
        _allow(cOwner, 7);

        vm.prank(_addr);
        vm.expectRevert();
        hemifyTreasury.withdraw(testToken, _amount);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testWithdrawAmountGTHemiftTreasuryBalanceByOwner() public _deposit {
        _allow(cOwner, 7);

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyTreasury.withdraw(testToken, (_amount * 2) + 1);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
    }

    function testWithdrawAmountByOwner() public _deposit {
        _allow(cOwner, 7);

        vm.prank(cOwner);
        hemifyTreasury.withdraw(testToken, _amount);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 10 ether);
    }

    function testWithdrawTwiceByOwner() public _deposit {
        _allow(cOwner, 7);

        vm.prank(cOwner);
        hemifyTreasury.withdraw(testToken, _amount);

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyTreasury.withdraw(testToken, _amount);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 10 ether);
    }
}