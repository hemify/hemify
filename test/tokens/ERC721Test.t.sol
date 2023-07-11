// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNFT is ERC721("TestNFT", "TNFT") {
    uint256 index;

    function mint(address to) public {
        _mint(to, index);
        ++index;
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        return owner;
    }
}