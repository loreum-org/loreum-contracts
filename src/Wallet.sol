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
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) private isConfirmed;

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "Tx already confirmed");
        _;
    }

    function _submitTransaction(address _to, uint256 _value, bytes memory _data) internal {
        uint256 txIndex = transactions.length;

        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, numConfirmations: 0}));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
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
        require(isConfirmed[_txIndex][msg.sender], "Tx not confirmed");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function _executeTransaction(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Tx failed");

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
            to: transaction.to,
            value: transaction.value,
            data: transaction.data,
            executed: transaction.executed,
            numConfirmations: transaction.numConfirmations
        });
    }
}
