// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IHemifyControl} from "../../src/interfaces/IHemifyControl.sol";

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";
import {Fork} from "../fork/MainnetFork.t.sol";

import {HemifyControl} from "../../src/contracts/HemifyControl.sol";

contract HemifyControlTest is Test, Addresses, Fork {
    IHemifyControl internal hemifyControl;

    function setUp() public {
        vm.prank(cOwner);
        hemifyControl = IHemifyControl(new HemifyControl());
    }

    function testSetUp() public {
        assertTrue(address(hemifyControl) != address(0));
    }
}