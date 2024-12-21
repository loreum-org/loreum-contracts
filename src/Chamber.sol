// SPDX-License-Identifier: MIT
// Loreum Chamber v1

pragma solidity 0.8.24;

import {Board} from "src/Board.sol";
import {Wallet} from "src/Wallet.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";

/// @title Chamber Contract
/// @notice This contract manages a multisig wallet with governance and delegation features using ERC20 and ERC721 tokens.
contract Chamber is Board, Wallet {
    /// @notice ERC20 governance token
    IERC20 public token;
    /// @notice ERC721 membership token
    IERC721 public nft;

    /// @notice Mapping to track delegated amounts per user per tokenId
    mapping(address => mapping(uint256 => uint256)) private _userDelegations;

    /// @notice Emitted when the contract receives Ether
    /// @param sender The address that sent the Ether
    /// @param amount The amount of Ether received
    event Received(address indexed sender, uint256 amount);

    /// @notice Emitted when a user delegates tokens to a tokenId
    /// @param sender The address of the user delegating tokens
    /// @param tokenId The tokenId to which tokens are delegated
    /// @param amount The amount of tokens delegated
    event Delegate(address indexed sender, uint256 tokenId, uint256 amount);

    /// @notice Emitted when a user undelegates tokens from a tokenId
    /// @param sender The address of the user undelegating tokens
    /// @param tokenId The tokenId from which tokens are undelegated
    /// @param amount The amount of tokens undelegated
    event Undelegate(address indexed sender, uint256 tokenId, uint256 amount);

    /// @notice Emitted when the number of seats is updated
    /// @param signedData The signed data for the update
    /// @param numOfSeats The new number of seats
    event UpdateSeats(bytes[] signedData, uint256 numOfSeats);

    /// Custom Errors
    error AmountMustBeGreaterThanZero();
    error InsufficientDelegatedAmount();
    error TransferFailed();
    error ArrayLengthsMustMatch();
    error NotEnoughConfirmations();
    error CallerIsNotADirector();

    /// @notice Initializes the Chamber contract with the given ERC20 and ERC721 tokens and sets the number of seats
    /// @param erc20Token The address of the ERC20 token
    /// @param erc721Token The address of the ERC721 token
    /// @param seats The initial number of seats
    constructor(address erc20Token, address erc721Token, uint256 seats) {
        token = IERC20(erc20Token);
        nft = IERC721(erc721Token);
        _setSeats(seats);
    }

    /// @notice Delegates a specified amount of tokens to a tokenId
    /// @param tokenId The tokenId to which tokens are delegated
    /// @param amount The amount of tokens to delegate
    function delegate(uint256 tokenId, uint256 amount) external {
        if (amount == 0) revert AmountMustBeGreaterThanZero();

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
        if (!token.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        // Emit Delegate event
        emit Delegate(msg.sender, tokenId, amount);
    }

    /// @notice Undelegates a specified amount of tokens from a tokenId
    /// @param tokenId The tokenId from which tokens are undelegated
    /// @param amount The amount of tokens to undelegate
    function undelegate(uint256 tokenId, uint256 amount) external {
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        if (_userDelegations[msg.sender][tokenId] < amount) revert InsufficientDelegatedAmount();

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
        if (!token.transfer(msg.sender, amount)) revert TransferFailed();

        emit Undelegate(msg.sender, tokenId, amount);
    }

    /// BOARD ///

    /// @notice Retrieves the node information for a given tokenId
    /// @param tokenId The tokenId to retrieve information for
    /// @return The Node struct containing the node information
    function getMember(uint256 tokenId) public view returns (Node memory) {
        return _getNode(tokenId);
    }

    /// @notice Retrieves the top tokenIds and their amounts
    /// @param count The number of top tokenIds to retrieve
    /// @return An array of top tokenIds and their corresponding amounts
    function getTop(uint256 count) public view returns (uint256[] memory, uint256[] memory) {
        return _getTop(count);
    }

    /// @notice Retrieves the delegation amount for a user and tokenId
    /// @param user The address of the user
    /// @param tokenId The tokenId to check
    /// @return The amount of tokens delegated by the user to the tokenId
    function getDelegation(address user, uint256 tokenId) public view returns (uint256) {
        return _userDelegations[user][tokenId];
    }

    /// @notice Retrieves the current quorum
    /// @return The current quorum value
    function getQuorum() public view returns (uint256) {
        return _getQuorum();
    }

    /// @notice Retrieves the current number of seats
    /// @return The current number of seats
    function getSeats() public view returns (uint256) {
        return _getSeats();
    }

    /// @notice Retrieves the addresses of the current directors
    /// @return An array of addresses representing the current directors
    function getDirectors() public view returns (address[] memory) {
        (uint256[] memory topTokenIds,) = getTop(_getSeats());
        address[] memory topOwners = new address[](topTokenIds.length);

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            topOwners[i] = nft.ownerOf(topTokenIds[i]);
        }

        return topOwners;
    }

    /// @notice Returns the list of tokenIds to which the user has delegated tokens and the corresponding amounts
    /// @param user The address of the user
    /// @return tokenIds The list of tokenIds
    /// @return amounts The list of amounts delegated to each tokenId
    function getUserDelegations(address user)
        external
        view
        returns (uint256[] memory tokenIds, uint256[] memory amounts)
    {
        uint256 count = 0;
        uint256[] memory tempTokenIds = new uint256[](size);
        uint256[] memory tempAmounts = new uint256[](size);

        for (uint256 tokenId = head; tokenId != 0; tokenId = nodes[tokenId].next) {
            if (_userDelegations[user][tokenId] > 0) {
                tempTokenIds[count] = tokenId;
                tempAmounts[count] = _userDelegations[user][tokenId];
                count++;
            }
        }

        tokenIds = new uint256[](count);
        amounts = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = tempTokenIds[i];
            amounts[i] = tempAmounts[i];
        }
    }

    /// @notice Retrieves the list of addresses that have requested a seat update
    /// @return An array of addresses that have requested a seat update
    function getSeatUpdate() public view returns (address[] memory) {
        return _getSeatUpdateList();
    }

    /// @notice Updates the number of seats
    /// @param numOfSeats The new number of seats
    function updateNumSeats(uint256 numOfSeats) public onlyDirector {
        _setSeats(numOfSeats);
    }

    /// WALLET ///

    /// @notice Submits a new transaction for approval
    /// @param target The address to send the transaction to
    /// @param value The amount of Ether to send
    /// @param data The data to include in the transaction
    function submitTransaction(address target, uint256 value, bytes memory data) public onlyDirector {
        _submitTransaction(target, value, data);
    }

    /// @notice Confirms a transaction
    /// @param transactionId The ID of the transaction to confirm
    function confirmTransaction(uint256 transactionId) public onlyDirector {
        _confirmTransaction(transactionId);
    }

    /// @notice Executes a transaction if it has enough confirmations
    /// @param transactionId The ID of the transaction to execute
    function executeTransaction(uint256 transactionId) public onlyDirector {
        if (getTransaction(transactionId).numConfirmations < getQuorum()) revert NotEnoughConfirmations();
        _executeTransaction(transactionId);
    }

    /// @notice Revokes a confirmation for a transaction
    /// @param transactionId The ID of the transaction to revoke confirmation for
    function revokeConfirmation(uint256 transactionId) public onlyDirector {
        _revokeConfirmation(transactionId);
    }

    /// @notice Submits multiple transactions for approval in a single call
    /// @param targets The array of addresses to send the transactions to
    /// @param values The array of amounts of Ether to send
    /// @param data The array of data to include in each transaction
    function submitBatchTransactions(address[] memory targets, uint256[] memory values, bytes[] memory data)
        public
        onlyDirector
    {
        if (targets.length != values.length || values.length != data.length) revert ArrayLengthsMustMatch();

        for (uint256 i = 0; i < targets.length; i++) {
            _submitTransaction(targets[i], values[i], data[i]);
        }
    }

    /// @notice Confirms multiple transactions in a single call
    /// @param transactionIds The array of transaction IDs to confirm
    function confirmBatchTransactions(uint256[] memory transactionIds) public onlyDirector {
        for (uint256 i = 0; i < transactionIds.length; i++) {
            _confirmTransaction(transactionIds[i]);
        }
    }

    /// @notice Executes multiple transactions in a single call if they have enough confirmations
    /// @param transactionIds The array of transaction IDs to execute
    function executeBatchTransactions(uint256[] memory transactionIds) public onlyDirector {
        for (uint256 i = 0; i < transactionIds.length; i++) {
            uint256 transactionId = transactionIds[i];
            if (getTransaction(transactionId).numConfirmations < getQuorum()) revert NotEnoughConfirmations();
            _executeTransaction(transactionId);
        }
    }

    /// @notice Fallback function to receive Ether
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @notice Modifier to restrict access to only directors
    modifier onlyDirector() {
        (uint256[] memory topTokenIds,) = getTop(_getSeats());

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            if (nft.ownerOf(topTokenIds[i]) == msg.sender) {
                _;
                return;
            }
        }

        revert CallerIsNotADirector();
    }
}
