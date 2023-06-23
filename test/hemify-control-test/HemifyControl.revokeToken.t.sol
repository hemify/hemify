// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface}
from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHemifyControl} from "../../src/interfaces/IHemifyControl.sol";

import {HemifyControlTest} from "./HemifyControl.t.sol";

contract RevokeTokenTest is HemifyControlTest {
    IERC20 private existentToken = IERC20(vm.addr(0x6789));
    AggregatorV3Interface private agg = AggregatorV3Interface(vm.addr(0x2343));
    IERC20 private inexistentToken = IERC20(vm.addr(0x2468));

    modifier ownerSupport() {
        vm.startPrank(owner);
        hemifyControl.supportToken(existentToken, agg);
        vm.stopPrank();
        assertTrue(hemifyControl.isSupported(existentToken));

        _;
    }

    function testRevokeTokenByNonOwner() public ownerSupport {
        vm.prank(alice);
        vm.expectRevert();
        hemifyControl.revokeToken(existentToken);
    }

    function testRevokeInexistentTokenByNonOwner(address _token) public ownerSupport {
        vm.prank(alice);
        vm.expectRevert();
        hemifyControl.revokeToken(inexistentToken);
    }

    function testRevokeInexistentToken(address _token) public ownerSupport {
        vm.prank(owner);
        hemifyControl.revokeToken(inexistentToken);
    }

    function testRevokeToken(address _token) public ownerSupport {
        vm.prank(owner);
        hemifyControl.revokeToken(existentToken);
        assertFalse(hemifyControl.isSupported(existentToken));
    }
}