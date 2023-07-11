// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {TestNFT} from "../tokens/ERC721Test.t.sol";
import {HemifyEscrow} from "../../src/contracts/HemifyEscrow.sol";

contract HemifyEscrowTest is Test, Addresses {
    HemifyEscrow internal hemifyEscrow;
    IERC721 internal testNFT;

    function setUp() public {
        address[] memory _addresses = _setupAddresses(7);

        vm.startPrank(cOwner);
        hemifyEscrow = HemifyEscrow(new HemifyEscrow(_addresses));

        TestNFT _testNFT = new TestNFT();

        for (uint256 i; i != 50; ) {
            _testNFT.mint(alice);
            _testNFT.mint(ian);

            unchecked { ++i; }
        }

        testNFT = IERC721(_testNFT);

        vm.stopPrank();
    }

    function testSetUp() public {
        assertTrue(address(hemifyEscrow) != address(0));
        assertTrue(address(testNFT) != address(0));
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

    function _allow(address _address, uint8 _num) internal {
        for (uint i; i != _num; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        if (_num == 7) {
            vm.prank(cOwner);
            hemifyEscrow.allow(_address);
        }
    }

    function _disAllow(address _address, uint8 _num) internal {
        for (uint i; i != _num; ) {
            vm.startPrank(addresses_[i]);
            hemifyEscrow.sign();
            vm.stopPrank();

            unchecked { ++i; }
        }

        if (_num == 7) {
            vm.prank(cOwner);
            hemifyEscrow.disAllow(_address);
        }
    }
}