// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {HemifyEscrowTest} from "./HemifyEscrow.t.sol";

contract HemifyEscrowDepositNFTTest is HemifyEscrowTest {
    function testDepositNFTWithCallByUnAllowedAddress(address _addr) public {
        vm.prank(_addr);
        vm.expectRevert();
        hemifyEscrow.depositNFT(alice, testNFT, 0);
    }

    function testDepositNFTWithCallByAllowedAddressButNonOwner(uint256 index) public {
        vm.assume(IERC721(testNFT).ownerOf(index) != alice);
        _allow(address(this), 7);

        vm.expectRevert();
        hemifyEscrow.depositNFT(alice, testNFT, index);
    }

    function testDepositNFTWithCallByAllowedAddressWithOwnerButNotApproved(uint256 index)
    public
    {
        vm.assume(IERC721(testNFT).ownerOf(index) == alice);
        _allow(address(this), 7);

        vm.expectRevert();
        hemifyEscrow.depositNFT(alice, testNFT, index);
    }

    function testDepositNFTWithCallByAllowedAddressWithOwnerAndApproved(uint256 index)
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
}