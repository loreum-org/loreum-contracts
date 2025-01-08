// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Board} from "src/Board.sol";

contract MockBoard is Board {

    function exposed_delegate(uint256 tokenId, uint256 amount) public {
        _delegate(tokenId, amount);
    }

    function exposed_undelegate(uint256 tokenId, uint256 amount) public {
        _undelegate(tokenId, amount);
    }

    function insert(uint256 tokenId, uint256 amount) public {
        _insert(tokenId, amount);
    }

    function remove(uint256 tokenId) public {
        _remove(tokenId);
    }

    function reposition(uint256 tokenId) public {
        _reposition(tokenId);
    }

    function getNode(uint256 tokenId) public view returns (Node memory) {
        return _getNode(tokenId);
    }

    function getSize() public view returns (uint256) {
        return size;
    }

    function getHead() public view returns (uint256) {
        return head;
    }

    function getTop(uint256 count) public view returns (uint256[] memory, uint256[] memory) {
        return _getTop(count);
    }
}
