// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {Gated, SimpleMultiSig} from "../../src/contracts/utils/Gated.sol";

contract GatedImplementer is Gated, Addresses {
    constructor(address[] memory _addresses)
        SimpleMultiSig (_addresses) {}

    uint256 public number;

    function updateNumber(uint256 newNumber) external onlyOwner allSigned {
        number = newNumber;
        _reset();
    }
}

contract GatedImplementerTest is Test, Addresses {
    GatedImplementer internal gated;

    function setUp() public {
        vm.prank(cOwner);
        gated = new GatedImplementer(_setupAddresses(6));
    }

    function testUpdateNumberByNonOwner(address _addr, uint256 _newNumber) public {
        vm.assume(_addr != cOwner);
        vm.expectRevert();
        gated.updateNumber(_newNumber);
    }

    function testUpdateNumberWhenAllNotSigned(uint8 _num, uint256 _newNumber) public {
        vm.assume(_num < 5);

        for (uint8 i; i != _num; ) {
            vm.prank(addresses_[i]);
            gated.sign();

            unchecked{ ++i; }
        }

        uint256 oldNumber = gated.number();

        vm.prank(cOwner);
        vm.expectRevert();
        gated.updateNumber(_newNumber);

        assertTrue(gated.number() == oldNumber);
    }

    function testUpdateNumberByNonOwnerWhenAllSigned(
        address _addr,
        uint8 _num,
        uint256 _newNumber
    )
        public
    {
        vm.assume(_addr != cOwner);
        vm.assume(_num == addresses_.length);
        vm.assume(_newNumber != gated.number());

        for (uint8 i; i != _num; ) {
            vm.prank(addresses_[i]);
            gated.sign();

            unchecked{ ++i; }
        }

        uint256 oldNumber = gated.number();

        vm.prank(_addr);
        vm.expectRevert();
        gated.updateNumber(_newNumber);

        assertTrue(gated.number() == oldNumber);
    }

    function testUpdateNumberByOwnerWhenAllSigned(uint8 _num, uint256 _newNumber) public {
        vm.assume(_num == addresses_.length);
        vm.assume(_newNumber != gated.number());

        for (uint8 i; i != _num; ) {
            vm.prank(addresses_[i]);
            gated.sign();

            unchecked{ ++i; }
        }

        uint256 oldNumber = gated.number();

        vm.prank(cOwner);
        gated.updateNumber(_newNumber);

        assertTrue(gated.number() != oldNumber);
        assertTrue(gated.number() == _newNumber);
    }

    function testReUpdateAfterReset(uint8 _num, uint256 _newNumber) public {
        vm.assume(_num == addresses_.length);
        vm.assume(_newNumber != gated.number());

        testUpdateNumberByOwnerWhenAllSigned(_num, _newNumber);

        uint256 oldNumber = gated.number();

        vm.prank(cOwner);
        vm.expectRevert();
        gated.updateNumber(_newNumber);

        assertTrue(gated.number() == oldNumber);
    }
}