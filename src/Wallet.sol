// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Wallet {
    event SubmitTransaction(
        address indexed leader, uint256 indexed txIndex, address indexed to, uint256 value, bytes data
    );
    event ConfirmTransaction(address indexed leader, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed leader, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed leader, uint256 indexed txIndex);

    struct Transaction {
        address target;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) private isConfirmed;

    // Custom Errors
    error TransactionDoesNotExist();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyConfirmed();
    error TransactionNotConfirmed();
    error TransactionFailed();

    modifier txExists(uint256 _txIndex) {
        if (_txIndex >= transactions.length) revert TransactionDoesNotExist();
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        if (transactions[_txIndex].executed) revert TransactionAlreadyExecuted();
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        if (isConfirmed[_txIndex][msg.sender]) revert TransactionAlreadyConfirmed();
        _;
    }

    function _submitTransaction(address _target, uint256 _value, bytes memory _data) internal {
        uint256 txIndex = transactions.length;

        transactions.push(Transaction({target: _target, value: _value, data: _data, executed: false, numConfirmations: 0}));

        emit SubmitTransaction(msg.sender, txIndex, _target, _value, _data);
    }

    function _confirmTransaction(uint256 _txIndex)
        internal
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function _revokeConfirmation(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
        if (!isConfirmed[_txIndex][msg.sender]) revert TransactionNotConfirmed();

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function _executeTransaction(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success,) = transaction.target.call{value: transaction.value}(transaction.data);
        if (!success) revert TransactionFailed();

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    /// @notice Returns the total number of transactions
    /// @return The total number of transactions
    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    /// @notice Returns the details of a specific transaction
    /// @param txIndex The index of the transaction to retrieve
    /// @return The Transaction struct containing the transaction details
    function getTransaction(uint256 txIndex) public view returns (Transaction memory) {
        Transaction storage transaction = transactions[txIndex];

        return Transaction({
            target: transaction.target,
            value: transaction.value,
            data: transaction.data,
            executed: transaction.executed,
            numConfirmations: transaction.numConfirmations
        });
    }

    /// @notice Checks if a transaction is confirmed by a specific director
    /// @param txIndex The index of the transaction to check
    /// @param director The address of the director to check confirmation for
    /// @return True if the transaction is confirmed by the director, false otherwise
    function getConfirmation(uint256 txIndex, address director) public view returns (bool) {
        return isConfirmed[txIndex][director];
    }
}
