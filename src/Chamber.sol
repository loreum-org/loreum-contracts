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

    // Mapping to track delegated amounts per user per tokenId
    mapping(address => mapping(uint256 => uint256)) private _userDelegations;

    event Received(address indexed sender, uint256 amount);
    event Delegate(address indexed sender, uint256 tokenId, uint256 amount);
    event Undelegate(address indexed sender, uint256 tokenId, uint256 amount);
    event UpdateSeats(bytes[] signedData, uint256 numOfSeats);

    constructor(address erc20Token, address erc721Token, uint256 seats) {
        token = IERC20(erc20Token);
        nft = IERC721(erc721Token);
        _setSeats(seats);
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

    /// BOARD ///

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

    function getQuorum() public view returns (uint256) {
        return _getQuorum();
    }

    function getSeats() public view returns (uint256) {
        return _getSeats();
    }

    function getDirectors() public view returns (address[] memory) {
        (uint256[] memory topTokenIds, ) = getTop(_getSeats());
        address[] memory topOwners = new address[](topTokenIds.length);

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            topOwners[i] = nft.ownerOf(topTokenIds[i]);
        }

        return topOwners;
    }

    function getSeatUpdateList() public view onlyDirector returns (address[] memory) {
        return _getSeatUpdateList();
    }

    function updateNumSeats(uint256 numOfSeats) public onlyDirector {
        _setSeats(numOfSeats);
    }

    modifier onlyDirector() {
        (uint256[] memory topTokenIds, ) = getTop(_getSeats());

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            if (nft.ownerOf(topTokenIds[i]) == msg.sender) {
                _;
                return;
            }
        }

        revert("Caller is not a director");
    }

    /// WALLET ///

    function submitTransaction(
        address to,
        uint256 value,
        bytes memory data
    ) public onlyDirector {
        _submitTransaction(to, value, data);
    }

    function confirmTransaction(uint256 transactionId) public onlyDirector {
        _confirmTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public onlyDirector {
        require(
            getTransaction(transactionId).numConfirmations >= getQuorum(),
            "Cannot execute transaction: not enough confirmations"
        );
        _executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId) public onlyDirector {
        _revokeConfirmation(transactionId);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
