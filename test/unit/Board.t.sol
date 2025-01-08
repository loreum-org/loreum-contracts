// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {MockBoard} from "test/mock/MockBoard.sol";
import {Board} from "src/Board.sol";

contract BoardTest is Test {
    MockBoard board;

    uint256 constant MAX_NODES = 100;

    function setUp() public {
        board = new MockBoard();
    }

    function test_Board_Insert() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        board.insert(tokenId, amount);

        MockBoard.Node memory node = board.getNode(tokenId);
        assertEq(node.tokenId, tokenId);
        assertEq(node.amount, amount);
    }

    function test_Board_Remove() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        board.insert(tokenId, amount);
        board.remove(tokenId);

        MockBoard.Node memory node = board.getNode(tokenId);
        assertEq(node.tokenId, 0);
        assertEq(node.amount, 0);
    }

    function test_Board_Reposition() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        board.insert(tokenId, amount);
        board.reposition(tokenId);

        MockBoard.Node memory node = board.getNode(tokenId);
        assertEq(node.tokenId, tokenId);
        assertEq(node.amount, amount);
    }

    function test_Board_GetNode() public {
        uint256 tokenId = 1;
        uint256 amount = 100;

        board.insert(tokenId, amount);

        MockBoard.Node memory node = board.getNode(tokenId);
        assertEq(node.tokenId, tokenId);
        assertEq(node.amount, amount);
    }

    function test_Board_GetTop() public {
        uint256 count = 3;
        uint256[] memory tokenIds = new uint256[](count);
        uint256[] memory amounts = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = i + 1;
            amounts[i] = (i + 1) * 100;
            board.insert(tokenIds[i], amounts[i]);
        }

        (uint256[] memory topTokenIds, uint256[] memory topAmounts) = board.getTop(count);

        for (uint256 i = 0; i < count; i++) {
            assertEq(topTokenIds[i], tokenIds[(count - 1) - i]);
            assertEq(topAmounts[i], amounts[(count - 1) - i]);
        }
    }

    function test_Board_DelegateMaxNodes() public {
        uint256 maxNodes = 100;
        uint256 amount = 100;

        for (uint256 i = 1; i <= maxNodes; i++) {
            board.insert(i, amount);
        }

        assertEq(board.getSize(), maxNodes);

        for (uint256 i = maxNodes + 1; i <= maxNodes; i++) {
            board.insert(i, amount);
        }

        vm.expectRevert(Board.MaxNodesReached.selector);
        board.insert(maxNodes + 1, 1);

        assertEq(board.getSize(), maxNodes);
    }
}
