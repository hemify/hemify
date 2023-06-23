// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

contract Fork is Test {
    uint256 forkId;

    modifier fork() {
        forkId = vm.createFork("https://eth.meowrpc.com");
        vm.selectFork(forkId);
        _;
    }
}