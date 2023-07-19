// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TestToken} from "../tokens/ERC20Test.t.sol";
import {HemifyTreasury} from "../../src/contracts/HemifyTreasury.sol";

contract HemifyTreasuryTest is Test, Addresses {
    HemifyTreasury internal hemifyTreasury;
    IERC20 internal testToken;
    uint256 internal _amount = 10 ether;

    function setUp() public {
        address[] memory _addresses = _setupAddresses(7);

        vm.startPrank(cOwner);
        hemifyTreasury = HemifyTreasury(new HemifyTreasury(_addresses));
        vm.stopPrank();

        TestToken _testToken = new TestToken();
        vm.deal(alice, 10 ether);
        vm.deal(ian, 10 ether);

        _testToken.mint(alice, 100 ether);
        _testToken.mint(ian, 100 ether);

        vm.prank(alice);
        _testToken.approve(address(hemifyTreasury), _amount);

        vm.prank(ian);
        _testToken.approve(address(hemifyTreasury), _amount);

        _allow(alice, 7);
        _allow(ian, 7);

        testToken = IERC20(_testToken);
    }

    function testSetUp() public {
        assertTrue(address(hemifyTreasury) != address(0));
        assertTrue(address(testToken) != address(0));
        assertTrue(alice.balance == 10 ether);
        assertTrue(ian.balance == 10 ether);
    }

    function testRedeployWithMultipleAddresses() public {
        address[] memory _addresses = _setupAddresses(7);
        address[] memory _newAddresses = new address[](8);
        for (uint i; i != 7; ) {
            if (i == 6) _newAddresses[7] = _addresses[0];
            else _newAddresses[i] = _addresses[i];
            unchecked { ++i; }
        }

        vm.expectRevert();
        vm.prank(cOwner);
        hemifyTreasury = new HemifyTreasury(_newAddresses);
    }

    function _allow(address _address, uint8 _num) internal {
        for (uint i; i != _num; ) {
            vm.startPrank(addresses_[i]);
            hemifyTreasury.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        if (_num == 7) {
            vm.prank(cOwner);
            hemifyTreasury.allow(_address);
        }
    }

    function _disAllow(address _address, uint8 _num) internal {
        for (uint i; i != _num; ) {
            vm.startPrank(addresses_[i]);
            hemifyTreasury.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        if (_num == 7) {
            vm.prank(cOwner);
            hemifyTreasury.disAllow(_address);
        }
    }
}