// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {HemifyTreasuryTest} from "./HemifyTreasury.t.sol";

contract HemifyTreasuryWithdrawETHTest is HemifyTreasuryTest {
    function _deposit() internal {
        vm.startPrank(alice);
        hemifyTreasury.deposit{value: alice.balance}();
        vm.stopPrank();

        vm.startPrank(ian);
        hemifyTreasury.deposit{value: ian.balance}();
        vm.stopPrank();

        assertEq(address(hemifyTreasury).balance, 20 ether);
    }

    function testWithdrawByNonOwner(address _addr) public {
        vm.assume((_addr != cOwner) && (_addr != address(0)));

        _deposit();
        _allow(_addr, 7);

        uint256 addrBalance = _addr.balance;
        uint256 hemifyBalance = address(hemifyTreasury).balance;

        vm.prank(_addr);
        vm.expectRevert();
        hemifyTreasury.withdraw();

        assertEq(address(hemifyTreasury).balance, hemifyBalance);
        assertEq(_addr.balance, addrBalance);
    }

    function testWithdrawByOwner() public {
        _deposit();
        _allow(cOwner, 7);

        uint256 cOwnerBalance = cOwner.balance;

        vm.prank(cOwner);
        hemifyTreasury.withdraw();

        assertEq(address(hemifyTreasury).balance, 0);
        assertEq(cOwner.balance, (cOwnerBalance + 20 ether));
    }
}