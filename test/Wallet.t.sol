pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {MockWallet} from "test/mock/MockWallet.sol";

contract WalletTest is Test {
    MockWallet wallet;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        wallet = new MockWallet();
    }

    function test_Wallet_SubmitTransaction() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";

        wallet.submitTransaction(to, value, data);

        MockWallet.Transaction memory trx = wallet.getTransaction(0);

        assertEq(to, trx.to);
        assertEq(value, trx.value);
        assertEq(data, trx.data);
        assertEq(false, trx.executed);
        assertEq(0, trx.numConfirmations);
    }

    function test_Wallet_ConfirmTransaction() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";

        wallet.submitTransaction(to, value, data);
        wallet.confirmTransaction(0);

        assertEq(wallet.getTransaction(0).numConfirmations, 1);
    }

    function test_Wallet_RevokeConfirmation() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";

        wallet.submitTransaction(to, value, data);
        wallet.confirmTransaction(0);
        wallet.revokeConfirmation(0);

        assertEq(wallet.getTransaction(0).numConfirmations, 0);
    }

    function test_Wallet_ExecuteTransaction() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";
        deal(address(wallet), 1 ether);

        wallet.submitTransaction(to, value, data);
        wallet.confirmTransaction(0);
        wallet.executeTransaction(0);

        assertEq(wallet.getTransaction(0).executed, true);
        assertEq(address(0x3).balance, 1 ether);
        assertEq(address(wallet).balance, 0);
    }

    function test_Wallet_GetTransactionCount() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";

        wallet.submitTransaction(to, value, data);

        uint256 count = wallet.getTransactionCount();

        assertEq(count, 1);
    }
}
