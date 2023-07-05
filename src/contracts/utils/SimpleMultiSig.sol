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
    address[] internal addresses;

    mapping(address => bool) private signers;
    mapping(address => bool) private signed;

    error MultipleAddresses();
    error MultiSigIncomplete();
    error NotInSignerList();

    /// @dev    Care should be taken using this constructor.
    ///         It is VITAL that `_addresses` must be <= 256 elements.
    ///         Else, it can underflow during `uint8()` cast.
    constructor(address[] memory _addresses) {
        uint8 len = uint8(_addresses.length);
        if ((len < 5) || (len > 10)) revert();

        uint8 j;

        for (uint8 i; i != len; ) {
            if (signers[_addresses[i]]) revert MultipleAddresses();
            signers[_addresses[i]] = true;
            addresses.push(_addresses[i]);
            unchecked { ++i; ++j; }
        }

        if ((j < 5) || (j > 10)) revert();
        SIZE = j;
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

    function _reset() internal {
        delete signCount;

        uint8 len = uint8(addresses.length);

        for (uint8 i; i != len; ) {
            signed[addresses[i]] = false;
            unchecked { ++i; }
        }
    }
}