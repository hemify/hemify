// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
* @title IHemifySwap
* @author fps (@0xfps).
* @custom:version 1.0.0
* @dev  HemifySwap contract interface.
*       This interface controls the `HemifySwap` contract.
*/

interface IHemifySwap {
    /**
    * @dev  Swap status.
    *       `NULL`: No swap or swap completed.
    *       `LISTED`: Swap in progress.
    */
    enum OrderState {
        NULL,
        LISTED
    }

    /**
    * @dev    This is the basic structure of a swap order as
    *         configured by the `orderOwner` and the "orderCompleter".
    * @param state      Current state of the order.
    * @param orderOwner Order submitter.
    * @param fromSwap   NFT address owned by submitter to be swapped.
    * @param fromId     NFT ID owned by submitter to be swapped.
    * @param toSwap     NFT address wanted by the submitter.
    * @param toId       NFT ID wanted by the submitter.
    * @param markUp     Amount of ETH `orderOwner` wants + `toSwap`as a
    *                   counter balance.
    */
    struct Order {
        OrderState state;
        address orderOwner;
        IERC721 fromSwap;
        uint256 fromId;
        IERC721 toSwap;
        uint256 toId;
        uint256 markUp;
    }

    /// @dev    Emitted when an order is cancelled, completed and placed,
    ///         respectively.
    /// @param orderId Order ID.
    event OrderCancelled(bytes32 indexed orderId);
    /// @param orderId      Order ID.
    /// @param completer    Order completer.
    event OrderCompleted(bytes32 indexed orderId, address indexed completer);
    /// @param orderId      Order ID.
    event OrderPlaced(bytes32 indexed orderId);

    /// @dev Errors.
    error HighMarkUp();
    error InsufficientFees();
    error NFTNotSupported();
    error NotOrderOwner();
    error NotOwnerOrAuthorized();
    error NotSent();
    error OrderClosed();
    error OrderExists();
    error OrderNotExistent();
    error OrderOwnerCannotSwap();
    error SwapNFTNonExistent();
    error ZeroAddress();

    /**
    * @dev Allows `msg.sender` to submit a new swap order.
    * @param _fromSwap  NFT address owned by submitter to be swapped.
    * @param _fromId    NFT ID owned by submitter to be swapped.
    * @param _toSwap    NFT address wanted by the submitter.
    * @param _toId      NFT address wanted by the submitter.
    * @param _markUp    Extra money to be added by the 'completer' to make swap.
    * @return bytes32   Order ID.
    * @return bool      Submission status.
    */
    function placeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId,
        uint256 _markUp
    )
        external
        payable
        returns (bytes32, bool);

    /**
    * @dev Allows `msg.sender` to complete a `LISTED` swap order.
    * @notice `msg.sender` will not be the `orderOwner`.
    * @param _fromSwap  NFT address owned by submitter to be swapped.
    * @param _fromId    NFT ID owned by submitter to be swapped.
    * @param _toSwap    NFT address wanted by the submitter.
    * @param _toId      NFT address wanted by the submitter.
    * @return bool      Completion status.
    */
    function completeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        external
        payable
        returns (bool);

    /// @dev Allows `msg.sender` to cancel an existing swap order they own.
    /// @param _orderId Order ID.
    /// @return bool Cancellation status.
    function cancelSwapOrder(bytes32 _orderId) external returns (bool);

    /// @dev Allows anyone to see the details of a `LISTED` order.
    /// @param _orderId Order ID.
    /// @return struct Order struct.
    function getSwapOrder(bytes32 _orderId) external view returns (Order memory);
}