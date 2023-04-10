// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
* @title Gated
* @author fps (@0xfps).
* @dev  Gated contract.
*       Controls which addresses can call which contracts.
*/

abstract contract Gated is Ownable2Step {
    mapping(address => bool) private allowed;

    error ZeroAddress();
    error NotAllowed();

    modifier onlyAllowed() {
        if (!allowed[msg.sender]) revert NotAllowed();
        _;
    }

    function allow(address _address) public onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        allowed[_address] = true;
    }

    function disAllow(address _address) public onlyOwner {
        allowed[_address] = false;
    }
}
