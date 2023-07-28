// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

contract Addresses is Test {
    /// @notice MAINNET ADDRESSES.
    address internal constant M_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant M_USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant M_WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice GOERLI ADDRESSES.
    address internal constant G_USDC = 0xd35CCeEAD182dcee0F148EbaC9447DA2c4D449c4;
    address internal constant G_USDT = 0x509Ee0d083DdF8AC028f2a56731412edD63223B9;
    address internal constant G_WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

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