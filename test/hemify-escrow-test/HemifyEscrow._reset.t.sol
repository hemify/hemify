// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Addresses} from "../data/Addresses.t.sol";

import {SimpleMultiSig} from "../../src/contracts/utils/SimpleMultiSig.sol";


contract HemifyResetMasker is SimpleMultiSig, Addresses {
    constructor(address[] memory _addresses)
        SimpleMultiSig(_addresses) {}

    function reset() public {
        _reset();
    }
}

contract HemifyEscrowResetTest is Test, Addresses {
    HemifyResetMasker internal resetMasker;

    function setUp() public {
        address[] memory _addresses = _setupAddresses(7);

        vm.prank(cOwner);
        resetMasker = new HemifyResetMasker(_addresses);
    }

    function testSignByAddressInSignerList(uint8 i) public {
        vm.assume(i < 7);
        vm.prank(addresses_[i]);
        resetMasker.sign();
    }

    function testReset() public {
        resetMasker.reset();
    }
}