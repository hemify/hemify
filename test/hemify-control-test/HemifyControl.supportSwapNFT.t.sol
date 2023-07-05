// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface}
from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IHemifyControl} from "../../src/interfaces/IHemifyControl.sol";

import {HemifyControlTest} from "./HemifyControl.t.sol";

contract SupportSwapNFTTest is HemifyControlTest {
    function testSupportSwapNFTByNonOwner(
        address _addr,
        address _token
    )
        public
    {
        vm.assume(_addr != cOwner);
        vm.assume(_token != address(0));

        IERC721 token = IERC721(_token);

        vm.prank(_addr);
        vm.expectRevert();
        hemifyControl.supportSwapNFT(token);
    }

    function testSupportSwapNFTByOwnerZeroAddress() public {
        IERC721 token = IERC721(address(0));

        vm.prank(cOwner);
        vm.expectRevert();
        hemifyControl.supportSwapNFT(token);
    }

    function testSupportSwapNFTExpectSuccess(address _token) public {
        vm.assume(_token != address(0));
        IERC721 token = IERC721(_token);

        vm.prank(cOwner);
        hemifyControl.supportSwapNFT(token);
        assertTrue(hemifyControl.isSupportedForSwap(token));
    }
}