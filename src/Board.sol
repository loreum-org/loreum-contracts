// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Board {

    string public constant version = "1";

    struct Node {
        uint256 tokenId;
        uint256 amount;
        uint256 next;
        uint256 prev;
    }

    // Mapping from tokenId to Node
    mapping(uint256 => Node) internal nodes;

    // Head and tail of the list (0 represents null)
    uint256 public head;
    uint256 public tail;
    uint256 public size;

    function _getNode(uint256 tokenId) internal view returns (Node memory) {
        return nodes[tokenId];
    }

    function _insert(uint256 tokenId, uint256 amount) internal {
        Node storage newNode = nodes[tokenId];
        newNode.tokenId = tokenId;
        newNode.amount = amount;

        if (head == 0) {
            // First node
            head = tokenId;
            tail = tokenId;
        } else {
            // Find position and insert
            uint256 current = head;

            while (current != 0 && amount <= nodes[current].amount) {
                current = nodes[current].next;
            }

            if (current == 0) {
                // Insert at tail
                nodes[tail].next = tokenId;
                newNode.prev = tail;
                tail = tokenId;
            } else {
                // Insert before current node
                newNode.next = current;
                newNode.prev = nodes[current].prev;

                if (newNode.prev != 0) {
                    nodes[newNode.prev].next = tokenId;
                } else {
                    head = tokenId;
                }

                nodes[current].prev = tokenId;
            }
        }
        size++;
    }

    function _remove(uint256 tokenId) internal {
        Node storage node = nodes[tokenId];

        if (node.prev != 0) {
            nodes[node.prev].next = node.next;
        } else {
            head = node.next;
        }

        if (node.next != 0) {
            nodes[node.next].prev = node.prev;
        } else {
            tail = node.prev;
        }

        delete nodes[tokenId];
        size--;
    }

    function _reposition(uint256 tokenId) internal {
        uint256 amount = nodes[tokenId].amount;
        _remove(tokenId);
        _insert(tokenId, amount);
    }

    // View functions for the leaderboard
    function _getTop(
        uint256 count
    ) internal view returns (uint256[] memory, uint256[] memory) {
        uint256 resultCount = count > size ? size : count;
        uint256[] memory tokenIds = new uint256[](resultCount);
        uint256[] memory amounts = new uint256[](resultCount);

        uint256 current = head;
        for (uint256 i = 0; i < resultCount; i++) {
            tokenIds[i] = current;
            amounts[i] = nodes[current].amount;
            current = nodes[current].next;
        }

        return (tokenIds, amounts);
    }
}
