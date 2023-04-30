// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

/**
* @title SimpleMultiSig.
* @author fps (@0xfps).
* @dev  A small multisig to protect onlyOwner witdrawals
*       for ETH and IERC20 in Treasury.
*/

abstract contract SimpleMultiSig {
    uint8 private immutable SIZE;
    uint8 private signCount;
    mapping(address => bool) private signers;
    mapping(address => bool) private signed;

    error NotInSignerList();
    error MultiSigIncomplete();

    constructor(address[] memory _addresses) {
        uint8 len = uint8(_addresses.length);
        if ((len < 5)) revert();

        SIZE = len;

        for (uint8 i; i != len; ) {
            signers[_addresses[i]] = true;
            unchecked { ++i; }
        }
    }

    modifier allSigned() {
        if (signCount != SIZE) revert MultiSigIncomplete();
        _;
    }

    function sign() public {
        if (!signers[msg.sender]) revert NotInSignerList();

        if (!signed[msg.sender]) {
            signed[msg.sender] = true;
            ++signCount;
        }
    }

    function unSign() public {
        if (!signers[msg.sender]) revert NotInSignerList();

        if (signed[msg.sender]) {
            signed[msg.sender] = false;
            --signCount;
        }
    }
}