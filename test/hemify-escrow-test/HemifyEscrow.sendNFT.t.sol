// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {HemifyEscrowTest} from "./HemifyEscrow.t.sol";

contract HemifyEscrowSendNFTTest is Test, HemifyEscrowTest {
    function testSendNFTByUnAllowedAddress(address _addr) public {
        vm.prank(_addr);
        vm.expectRevert();
        hemifyEscrow.depositNFT(alice, testNFT, 0);
    }

    function _testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(uint256 index)
    public
    {
        vm.assume(IERC721(testNFT).ownerOf(index) == alice);
        _allow(address(this), 7);

        vm.startPrank(alice);
        IERC721(testNFT).approve(address(hemifyEscrow), index);
        vm.stopPrank();

        hemifyEscrow.depositNFT(alice, testNFT, index);
        assert(testNFT.ownerOf(index) == address(hemifyEscrow));
    }

    function testSendUnOwnedNFT(uint256 index, uint256 nonIndex) public {
        _testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(index);
        vm.assume(testNFT.ownerOf(nonIndex) != address(hemifyEscrow));
        _allow(address(this), 7);

        vm.expectRevert();
        hemifyEscrow.sendNFT(testNFT, nonIndex, chris);
    }

    function testSendNFTToZeroAddress(uint256 index) public {
        _testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(index);
        vm.assume(testNFT.ownerOf(index) == address(hemifyEscrow));
        _allow(address(this), 7);

        vm.expectRevert();
        hemifyEscrow.sendNFT(testNFT, index, address(0));
    }

    function testSendNFTToHemifyEscrow(uint256 index) public {
        _testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(index);
        vm.assume(testNFT.ownerOf(index) == address(hemifyEscrow));
        _allow(address(this), 7);

        vm.expectRevert();
        hemifyEscrow.sendNFT(testNFT, index, address(hemifyEscrow));
    }

    function testSendNFTToValidAddress(uint256 index) public {
        _testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(index);
        vm.assume(testNFT.ownerOf(index) == address(hemifyEscrow));
        _allow(address(this), 7);

        hemifyEscrow.sendNFT(testNFT, index, chris);
        assert(testNFT.ownerOf(index) == chris);
    }

    function testReEntrancy() public {
        _allow(address(this), 7);

        vm.startPrank(alice);
        testNFT.setApprovalForAll(address(hemifyEscrow), true);
        vm.stopPrank();

        for (uint8 i; i < 50; ) {
            hemifyEscrow.depositNFT(alice, testNFT, i);
            unchecked { i += 2; }
        }

        vm.expectRevert();
        hemifyEscrow.sendNFT(testNFT, 0, address(this));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {

        for (uint8 i = 2; i < 50; ) {
            hemifyEscrow.sendNFT(testNFT, i, address(this));
            unchecked { i += 2; }
        }

        return 0x150b7a02;
    }
}