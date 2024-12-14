pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {MockBoard} from "test/mock/MockBoard.sol";

contract BoardTest is Test {
    MockBoard board;

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
}
