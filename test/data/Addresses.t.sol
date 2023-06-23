// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

contract Addresses is Test {
    address alice = vm.addr(0x01);
    address bob = vm.addr(0x02);
    address chris = vm.addr(0x03);
    address dre = vm.addr(0x04);
    address esther = vm.addr(0x05);
    address finn = vm.addr(0x06);
    address gasper = vm.addr(0x07);
    address herbert = vm.addr(0x08);
    address ian = vm.addr(0x09);
    address john = vm.addr(0x0a);

    // For ease of ownership.
    address owner = vm.addr(0x0b);
}