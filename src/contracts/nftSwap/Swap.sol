// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IEscrow} from "../../interfaces/IEscrow.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ISwap} from "../../interfaces/ISwap.sol";
import {ITreasury} from "../../interfaces/ITreasury.sol";

/**
* @title ISwap
* @author fps (@0xfps).
* @dev  Swap contract interface.
*       This interface controls the `Swap` contract.
*/

contract Swap is ISwap {
    IEscrow escrow;
    ITreasury treasury;

    uint256 public fee = 0.05 ether;
    mapping(bytes32 => Order) private orders;

    constructor(address _escrow, address _treasury) {
        if (_escrow == address(0)) revert ZeroAddress();
        if (_treasury == address(0)) revert ZeroAddress();

        escrow = IEscrow(_escrow);
        treasury = ITreasury(_treasury);
    }

    function placeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        external
        payable
        returns (bytes32, bool)
    {
        if (!_isOwnerOrAuthorized(_fromSwap, _fromId, msg.sender))
            revert NotOwnerOrAuthorized();

        bytes32 orderId = _getOrderId(
            _fromSwap,
            _fromId,
            _toSwap,
            _toId
        );

        if (_orderExists(orderId)) revert OrderExists();
        if (msg.value < fee) revert InsufficientFees();

        Order memory _order;
        _order.state = OrderState.LISTED;
        _order.orderOwner = msg.sender;
        _order.fromSwap = _fromSwap;
        _order.fromId = _fromId;
        _order.toSwap = _toSwap;
        _order.toId = _toId;

        orders[orderId] = _order;

        bool paid = treasury.deposit{value: msg.value}();
        if (!paid) revert NotSent();

        bool sent = escrow.depositNFT(msg.sender, _fromSwap, _fromId);
        if (!sent) revert NotSent();

        emit OrderPlaced(orderId);

        return (orderId, sent);
    }

    function completeSwapOrder(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        external
        payable
        returns (bool)
    {
        if (!_isOwnerOrAuthorized(_fromSwap, _fromId, msg.sender))
            revert NotOwnerOrAuthorized();

        bytes32 orderId = _getOrderId(
            _toSwap,
            _toId,
            _fromSwap,
            _fromId
        );

        if (orders[orderId].state != OrderState.LISTED)
            revert OrderClosed();

        if (_orderExists(orderId)) revert OrderExists();
        if (msg.value < fee) revert InsufficientFees();

        address _orderOwner = orders[orderId].orderOwner;
        orders[orderId].state = OrderState.COMPLETED;

        delete orders[orderId];

        bool paid = treasury.deposit{value: msg.value}();
        if (!paid) revert NotSent();

        bool sent = escrow.depositNFT(msg.sender, _fromSwap, _fromId);
        if (!sent) revert NotSent();

        // Swap.
        bool swapToOwner = escrow.sendNFT(_fromSwap, _fromId, _orderOwner);
        if (!swapToOwner) revert NotSent();

        bool swapToReceiver = escrow.sendNFT(_toSwap, _toId, msg.sender);
        if (!swapToReceiver) revert NotSent();

        emit OrderCompleted(orderId, msg.sender);

        return ((sent == swapToOwner) == swapToReceiver);
    }

    function cancelSwapOrder(bytes32 _orderId) external returns (bool) {
        if (_orderExists(_orderId)) revert OrderExists();

        if (orders[_orderId].orderOwner != msg.sender) revert NotOrderOwner();
        if (orders[_orderId].state != OrderState.LISTED)
            revert OrderClosed();

        IERC721 _nft = orders[_orderId].fromSwap;
        uint256 _id = orders[_orderId].fromId;

        delete orders[_orderId];

        bool sent = escrow.sendNFT(_nft, _id, msg.sender);
        if (!sent) revert NotSent();

        emit OrderCancelled(_orderId);

        return sent;
    }

    function getSwapOrder(bytes32 _orderId) external view returns (Order memory) {
        if (!_orderExists(_orderId)) revert OrderNotExistent();

        Order memory order = orders[_orderId];
        return order;
    }

    function _isOwnerOrAuthorized(
        IERC721 _nft,
        uint256 _id,
        address _owner
    )
        internal
        view
        returns (bool)
    {
        address nftOwner = _nft.ownerOf(_id);
        if (
            (nftOwner != _owner) &&
            (_nft.getApproved(_id) != _owner) &&
            (!_nft.isApprovedForAll(nftOwner, _owner))
        ) return false;

        return true;
    }

    function _getOrderId(
        IERC721 _fromSwap,
        uint256 _fromId,
        IERC721 _toSwap,
        uint256 _toId
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                _fromSwap,
                _fromId,
                _toSwap,
                _toId
            )
        );
    }

    function _orderExists(bytes32 _orderId) private view returns (bool) {
        return orders[_orderId].state != OrderState.NULL;
    }
}