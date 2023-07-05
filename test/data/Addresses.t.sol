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
    address cOwner = vm.addr(0x0b);
    // A random address if you do not remember any of the above addresses.
    address hacker = vm.addr(0x0c);

    address[] internal addresses_;

    function _setupAddresses(uint8 limit) internal returns (address[] memory) {
        address[] memory _addresses = new address[](limit);

        for (uint8 i; i != limit; ) {
            _addresses[i] = vm.addr(block.timestamp * (i + 1));
            unchecked { ++i; }
        }

        addresses_ = _addresses;
        return addresses_;
    }
}