// SPDX-License-Identifier: MIT
// Loreum Chamber v1

pragma solidity 0.8.24;

import {Board} from "src/Board.sol";
import {Wallet} from "src/Wallet.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";

contract Chamber is Board, Wallet {
    IERC20 public token;
    IERC721 public nft;

    uint256 public seats;

    // Mapping to track delegated amounts per user per tokenId
    mapping(address => mapping(uint256 => uint256)) private _userDelegations;

    event Received(address indexed sender, uint256 amount);
    event Delegate(address indexed sender, uint256 tokenId, uint256 amount);
    event Undelegate(address indexed sender, uint256 tokenId, uint256 amount);

    constructor(address _token, address _nft, uint256 _seats) {
        token = IERC20(_token);
        nft = IERC721(_nft);
        seats = _seats;
    }

    function delegate(uint256 tokenId, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Update user delegation amount
        _userDelegations[msg.sender][tokenId] += amount;

        // Update or insert node
        if (nodes[tokenId].tokenId == tokenId) {
            // Node exists, update amount and reposition
            nodes[tokenId].amount += amount;
            _reposition(tokenId);
        } else {
            // Create new node
            _insert(tokenId, amount);
        }

        // Transfer tokens from user
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Emit Delegate event
        emit Delegate(msg.sender, tokenId, amount);
    }

    function undelegate(uint256 tokenId, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            _userDelegations[msg.sender][tokenId] >= amount,
            "Insufficient delegated amount"
        );

        // Update user delegation amount
        _userDelegations[msg.sender][tokenId] -= amount;

        // Update node
        nodes[tokenId].amount -= amount;

        if (nodes[tokenId].amount == 0) {
            // Remove node if amount is 0
            _remove(tokenId);
        } else {
            // Reposition node based on new amount
            _reposition(tokenId);
        }

        // Transfer tokens back to user
        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Undelegate(msg.sender, tokenId, amount);
    }

    function getMember(uint256 tokenId) public view returns (Node memory) {
        return _getNode(tokenId);
    }

    function getTop(
        uint256 count
    ) public view returns (uint256[] memory, uint256[] memory) {
        return _getTop(count);
    }

    function getDelegation(
        address user,
        uint256 tokenId
    ) public view returns (uint256) {
        return _userDelegations[user][tokenId];
    }

    /// WALLET ///
    modifier isDirector() {
        uint256[] memory topTokenIds;
        (topTokenIds, ) = getTop(5);
        bool isTop5 = false;

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            if (nft.ownerOf(topTokenIds[i]) == msg.sender) {
                isTop5 = true;
                break;
            }
        }

        require(isTop5, "Caller is not a director");
        _;
    }

    function submitTransaction(
        address to,
        uint256 value,
        bytes memory data
    ) public isDirector {
        _submitTransaction(to, value, data);
    }

    function confirmTransaction(uint256 transactionId) public isDirector {
        _confirmTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public isDirector {
        require(getTransaction(transactionId).numConfirmations >= 3, "Cannot execute transaction: not enough confirmations");
        _executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId) public isDirector {
        _revokeConfirmation(transactionId);
    }
}
