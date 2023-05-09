// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title ISwap
* @author fps (@0xfps).
* @dev  Swap contract interface.
*       This interface controls the `Swap` contract.
*/

interface ISwap {
    enum OrderState {
        NULL,
        LISTED,
        COMPLETED
    }

    struct Order {
        OrderState state;
        address orderOwner;
        IERC721 fromSwap;
        uint256 fromId;
        IERC721 toSwap;
        uint256 toId;
    }

    event OrderCancelled(bytes32 indexed orderId);
    event OrderCompleted(bytes32 indexed orderId, address indexed completer);
    event OrderPlaced(bytes32 indexed orderId);

    error InsufficientFees();
    error NotOwnerOrAuthorized();
    error NotOrderOwner();
    error NotSent();
    error OrderExists();
    error OrderClosed();
    error OrderNotExistent();
    error ZeroAddress();

    function placeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        external
        payable
        returns (bytes32, bool);

    function completeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        external
        payable
        returns (bool);

    function cancelSwapOrder(bytes32 _orderId) external returns (bool);

    function getSwapOrder(bytes32 _orderId) external view returns (Order memory);
}