// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {Chamber} from "src/Chamber.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import {MockERC20} from "test/mock/MockERC20.sol";
import {MockERC721} from "test/mock/MockERC721.sol";
import {Board} from "src/Board.sol";
import {Wallet} from "src/Wallet.sol";

contract ChamberTest is Test {
    Chamber public chamber;
    IERC20 public token;
    IERC721 public nft;
    uint256 public seats;

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    function setUp() public {
        token = new MockERC20();
        nft = new MockERC721();
        seats = 5;
        chamber = new Chamber(address(token), address(nft), seats);
    }

    function test_Chamber_delegate_success() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        // Mint tokens to user1
        MockERC20(address(token)).mint(user1, amount);

        // Approve and delegate tokens
        vm.startPrank(user1);
        token.approve(address(chamber), amount);
        chamber.delegate(tokenId, amount);
        vm.stopPrank();

        // Check user delegation amount
        assertEq(chamber.getDelegation(user1, tokenId), amount);

        // Check node amount
        Board.Node memory node = chamber.getMember(tokenId);
        assertEq(node.tokenId, tokenId);
        assertEq(node.amount, amount);
    }

    function test_Chamber_Undelegate_success(uint256 tokenId, uint256 amount) public {
        if (tokenId == 0) return;
        if (amount < 1 || amount > 1_000_000_000 ether) return;
        // Mint tokens to user1
        MockERC20(address(token)).mint(user1, amount);

        // Approve and delegate tokens
        vm.startPrank(user1);
        token.approve(address(chamber), amount);
        chamber.delegate(tokenId, amount);
        vm.stopPrank();

        // Undelegate tokens
        vm.startPrank(user1);
        chamber.undelegate(tokenId, amount);
        vm.stopPrank();

        // Check user delegation amount
        assertEq(chamber.getDelegation(user1, tokenId), 0);

        // Check node amount
        Board.Node memory node = chamber.getMember(tokenId);
        assertEq(node.amount, 0);
    }

    function test_Chamber_getLeaderboard_success() public {

        uint256 num = 5000;
        uint256[] memory tokenIds = new uint256[](num);
        uint256[] memory amounts = new uint256[](num);
        address[] memory users = new address[](num);

        // Initialize tokenIds, amounts, and users
        for (uint256 i = 0; i < num; i++) {
            tokenIds[i] = i + 1;
            amounts[i] = (i + 1) * 100;
            users[i] = address(uint160(i + 1));
        }

        // Mint tokens to users
        for (uint256 i = 0; i < num; i++) {
            MockERC20(address(token)).mint(users[i], amounts[i]);
        }

        // Approve and delegate tokens
        for (uint256 i = 0; i < num; i++) {
            vm.startPrank(users[i]);
            token.approve(address(chamber), amounts[i]);
            chamber.delegate(tokenIds[i], amounts[i]);
            vm.stopPrank();
        }

        // Get top num nodes
        (uint256[] memory topTokenIds, uint256[] memory topAmounts) = chamber.getTop(num);

        // Check top nodes
        for (uint256 i = 0; i < num; i++) {
            assertEq(topTokenIds[i], tokenIds[(num - 1) - i]);
            assertEq(topAmounts[i], amounts[(num - 1) - i]);
        }
    }

    function test_Chamber_SubmitTransaction() public {
        address to = address(0x3);
        uint256 value = 0;
        bytes memory data = "";
        // Mint an NFT to user1

        uint256 tokenId = 1;
        uint256 amount = 1 ether;
        MockERC721(address(nft)).mint(user1, tokenId);
        MockERC20(address(token)).mint(user1, amount);


        vm.startPrank(user1);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId, 1);

        chamber.submitTransaction(to, value, data);
        vm.stopPrank();

        Wallet.Transaction memory trx = chamber.getTransaction(0);

        assertEq(to, trx.to);
        assertEq(value, trx.value);
        assertEq(data, trx.data);
        assertEq(false, trx.executed);
        assertEq(0, trx.numConfirmations);
    }

    function test_Chamber_ConfirmTransaction() public {
        address to = address(0x3);
        uint256 value = 0;
        bytes memory data = "";

        uint256 tokenId = 1;
        uint256 amount = 1 ether;
        MockERC721(address(nft)).mint(user1, tokenId);
        MockERC20(address(token)).mint(user1, amount);


        vm.startPrank(user1);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId, 1);

        chamber.submitTransaction(to, value, data);
        chamber.confirmTransaction(0);
        vm.stopPrank();

        assertEq(chamber.getTransaction(0).numConfirmations, 1);
    }

    function test_Chamber_RevokeConfirmation() public {
        address to = address(0x3);
        uint256 value = 0;
        bytes memory data = "";

        uint256 tokenId = 1;
        uint256 amount = 1 ether;
        MockERC721(address(nft)).mint(user1, tokenId);
        MockERC20(address(token)).mint(user1, amount);


        vm.startPrank(user1);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId, 1);

        chamber.submitTransaction(to, value, data);
        chamber.confirmTransaction(0);
        chamber.revokeConfirmation(0);
        vm.stopPrank();

        assertEq(chamber.getTransaction(0).numConfirmations, 0);
    }

    function test_Chamber_ExecuteTransaction() public {
        address to = address(0x3);
        uint256 value = 1 ether;
        bytes memory data = "";

        deal(address(chamber), value);

        uint256 tokenId = 1;
        uint256 amount = 1 ether;

        MockERC721(address(nft)).mint(user1, tokenId);
        MockERC20(address(token)).mint(user1, amount);

        MockERC721(address(nft)).mint(user2, tokenId + 2);
        MockERC20(address(token)).mint(user2, amount);

        MockERC721(address(nft)).mint(user3, tokenId + 3);
        MockERC20(address(token)).mint(user3, amount);


        vm.startPrank(user1);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId, 1);
        chamber.submitTransaction(to, value, data);
        vm.stopPrank();

        vm.startPrank(user2);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId + 2, 1);
        chamber.confirmTransaction(0);
        vm.stopPrank();

        vm.startPrank(user3);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId + 3, 1);
        chamber.confirmTransaction(0);
        vm.stopPrank();

        vm.startPrank(user1);
        chamber.confirmTransaction(0);
        chamber.executeTransaction(0);
        vm.stopPrank();

        assertEq(chamber.getTransaction(0).executed, true);
        assertEq(address(0x3).balance, 1 ether);
        assertEq(address(chamber).balance, 0);
    }

    function test_Chamber_GetTransactionCount() public {
        address to = address(0x3);
        uint256 value = 0;
        bytes memory data = "";

        uint256 tokenId = 1;
        uint256 amount = 1 ether;
        MockERC721(address(nft)).mint(user1, tokenId);
        MockERC20(address(token)).mint(user1, amount);


        vm.startPrank(user1);
        MockERC20(address(token)).approve(address(chamber), amount);
        chamber.delegate(tokenId, 1);

        chamber.submitTransaction(to, value, data);
        vm.stopPrank();

        uint256 count = chamber.getTransactionCount();

        assertEq(count, 1);
    }
}

