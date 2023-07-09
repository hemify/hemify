// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {HemifyEscrow} from "../../src/contracts/HemifyEscrow.sol";

contract HemifyEscrowTest is Test, Addresses {
    HemifyEscrow hemifyEscrow;

    function setUp() public {
        address[] memory _addresses = _setupAddresses(7);

        vm.prank(cOwner);
        hemifyEscrow = HemifyEscrow(new HemifyEscrow(_addresses));
    }

    function testSetUp() public {
        assertTrue(address(hemifyEscrow) != address(0));
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
        hemifyEscrow = HemifyEscrow(new HemifyEscrow(_newAddresses));
    }
}