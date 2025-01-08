// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Board} from "src/Board.sol";
import {MockBoard} from "test/mock/MockBoard.sol";

contract BoardTest is Test {
    MockBoard board;
    address user = makeAddr("user");
    uint256 constant MAX_NODES = 50;

    function setUp() public {
        board = new MockBoard();
    }

    function test_MaxNodes() public {
        // Create MAX_NODES nodes
        for (uint256 i = 1; i <= MAX_NODES; i++) {
            board.exposed_delegate(i, 100 * (MAX_NODES - i + 1));
        }

        // Verify size
        assertEq(board.getSize(), MAX_NODES);

        // Try to add one more node
        vm.expectRevert(Board.MaxNodesReached.selector);
        board.exposed_delegate(MAX_NODES + 1, 100);

        // Verify we can still update existing nodes
        board.exposed_delegate(1, 100);
        assertEq(board.getSize(), MAX_NODES);

        // Remove a node and verify we can add a new one
        board.exposed_undelegate(1, board.getNode(1).amount);
        assertEq(board.getSize(), MAX_NODES - 1);
        board.exposed_delegate(MAX_NODES + 1, 100);
        assertEq(board.getSize(), MAX_NODES);
    }

    function test_MaxNodes_Ordering() public {
        // Create MAX_NODES nodes in reverse order
        for (uint256 i = MAX_NODES; i > 0; i--) {
            board.exposed_delegate(i, i * 100);
        }

        // Verify ordering
        uint256 current = board.getHead();
        uint256 expected = MAX_NODES;
        while (current != 0) {
            assertEq(current, expected);
            current = board.getNode(current).next;
            expected--;
        }
    }

    function test_MaxNodes_Reposition() public {
        // Fill up to MAX_NODES
        for (uint256 i = 1; i <= MAX_NODES; i++) {
            board.exposed_delegate(i, i * 100);
        }

        // Update middle node to highest amount
        uint256 middleNode = MAX_NODES / 2;
        board.exposed_delegate(middleNode, MAX_NODES * 200);

        // Verify it's now at the head
        assertEq(board.getHead(), middleNode);
    }
}
