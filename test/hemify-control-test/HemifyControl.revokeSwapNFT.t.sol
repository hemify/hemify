// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface}
from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IHemifyControl} from "../../src/interfaces/IHemifyControl.sol";

import {HemifyControlTest} from "./HemifyControl.t.sol";

contract RevokeSwapNFTTest is HemifyControlTest {
    IERC721 private existentToken = IERC721(vm.addr(0x6789));
    IERC721 private inexistentToken = IERC721(vm.addr(0x2468));

    modifier ownerSupport() {
        vm.startPrank(cOwner);
        hemifyControl.supportSwapNFT(existentToken);
        vm.stopPrank();
        assertTrue(hemifyControl.isSupportedForSwap(existentToken));

        _;
    }

    function testRevokeExistentNFTByNonOwner(address _addr) public ownerSupport {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        hemifyControl.revokeSwapNFT(existentToken);
    }

    function testRevokeInexistentNFTByNonOwner(address _addr) public ownerSupport {
        vm.assume(_addr != cOwner);
        vm.prank(_addr);
        vm.expectRevert();
        hemifyControl.revokeSwapNFT(inexistentToken);
    }

    function testRevokeInexistentNFTByOwner() public ownerSupport {
        vm.prank(cOwner);
        hemifyControl.revokeSwapNFT(inexistentToken);
        assertFalse(hemifyControl.isSupportedForSwap(inexistentToken));
    }

    function testRevokeExistentNFTByOwner() public ownerSupport {
        vm.prank(cOwner);
        hemifyControl.revokeSwapNFT(existentToken);
        assertFalse(hemifyControl.isSupportedForSwap(existentToken));
    }
}