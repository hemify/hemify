// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasuryDepositTokenTest is HemifyTreasuryTest {
    function testDepositTokenByNonAllowedAddress(address _addr) public {
        vm.assume(_addr != ian);
        vm.assume(_addr != alice);

        vm.expectRevert();
        vm.prank(_addr);
        hemifyTreasury.deposit(_addr, testToken, _amount);
    }

    function testDepositTokenByAddress() public {
        vm.prank(alice);
        hemifyTreasury.deposit(alice, testToken, _amount);

        vm.prank(ian);
        hemifyTreasury.deposit(ian, testToken, _amount);

        assertEq(testToken.balanceOf(address(hemifyTreasury)), 20 ether);
        assertEq(testToken.balanceOf(alice), 90 ether);
        assertEq(testToken.balanceOf(ian), 90 ether);
    }
}