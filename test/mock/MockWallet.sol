// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Wallet} from "src/Wallet.sol";

contract MockWallet is Wallet {
    function submitTransaction(
        address to,
        uint256 value,
        bytes memory data
    ) public {
        _submitTransaction(to, value, data);
    }

    function confirmTransaction(uint256 transactionId) public {
        _confirmTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public {
        _executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId) public {
        _revokeConfirmation(transactionId);
    }
}
