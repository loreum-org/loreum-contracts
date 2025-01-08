// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Board
 * @notice Manages a sorted linked list of nodes representing token delegations and board seats
 * @dev Abstract contract that implements core board functionality including delegation tracking
 *      and seat management. Uses a doubly linked list to maintain sorted order of delegations.
 */
abstract contract Board {
    /**
     * @notice Node structure for the doubly linked list
     * @dev Each node represents a token delegation with links to maintain sorted order
     * @param tokenId Unique identifier for the token
     * @param amount Total amount of tokens delegated to this node
     * @param next TokenId of the next node in the sorted list (0 if none)
     * @param prev TokenId of the previous node in the sorted list (0 if none)
     */
    struct Node {
        uint256 tokenId;
        uint256 amount;
        uint256 next;
        uint256 prev;
    }

    /// @notice Maximum number of nodes allowed in the linked list
    uint256 internal constant MAX_NODES = 100;

    /// @notice Number of board seats
    uint256 private seats;

    /// @notice Mapping from tokenId to Node data
    mapping(uint256 => Node) internal nodes;

    /// @notice TokenId of the first node (highest amount)
    uint256 internal head;

    /// @notice TokenId of the last node (lowest amount)
    uint256 internal tail;

    /// @notice Total number of nodes in the list
    uint256 internal size;

    /// circuit breaker
    bool private locked;

    /**
     * @notice Structure representing a proposal to update the number of board seats
     * @param proposedSeats The proposed new number of seats
     * @param timestamp When the proposal was created
     * @param supporters Array of tokenIds that have supported this proposal
     */
    struct SeatUpdate {
        uint256 proposedSeats;
        uint256 timestamp;
        uint256[] supporters;
    }

    /// @notice Seat update proposal
    SeatUpdate internal seatUpdate;

    /// EVENTS ///

    /**
     * @notice Emitted when the number of seats is set
     * @param tokenId The tokenId that called the function\
     * @param numOfSeats The new number of seats
     */
    event SetSeats(uint256 tokenId, uint256 numOfSeats);

    /**
     * @notice Emitted when a seat update proposal is cancelled
     * @param tokenId The tokenId who cancelled the proposal
     */
    event SeatUpdateCancelled(uint256 tokenId);

    /**
     * @notice Emitted when a call to set the number of seats is made
     * @param tokenId The tokenId that called the function
     * @param seats The number of seats
     */
    event ExecuteSetSeats(uint256 tokenId, uint256 seats);

    /**
     * @notice Emitted when a user delegates tokens to a tokenId
     * @param sender The address of the user delegating tokens
     * @param tokenId The tokenId to which tokens are delegated
     * @param amount The amount of tokens delegated
     */
    event Delegate(address indexed sender, uint256 tokenId, uint256 amount);

    /**
     * @notice Emitted when a user undelegates tokens from a tokenId
     * @param sender The address of the user undelegating tokens
     * @param tokenId The tokenId from which tokens are undelegated
     * @param amount The amount of tokens undelegated
     */
    event Undelegate(address indexed sender, uint256 tokenId, uint256 amount);

    /// ERRORS ///

    /// @notice Thrown when an update request has already been sent by the caller
    error AlreadySentUpdateRequest();

    /// @notice Thrown when the number of seats provided is invalid
    error InvalidNumSeats();

    /// @notice Thrown when the node does not exist
    error NodeDoesNotExist();

    /// @notice Thrown when the amount exceeds the delegation
    error AmountExceedsDelegation();

    /// @notice Thrown when the proposal ID is invalid or does not exist
    error InvalidProposal();

    /// @notice Thrown when attempting to execute a proposal before its timelock period has expired
    error TimelockNotExpired();

    /// @notice Thrown if updateSeates execution call hasn't got enough votes.
    error InsufficientVotes();

    /// @notice Thrown when a supporter is not found on the leaderboard
    /// @param supporter The address of the supporter
    error SupporterNotOnLeaderboard(address supporter);

    /// @notice Thrown when the linked list has reached its maximum size
    error MaxNodesReached();

    /// MODIFIERS ///

    /**
     * @notice Modifier that implements a circuit breaker pattern to pause functionality
     * @dev Sets a locked state during execution and releases after completion
     * @custom:throws "Circuit breaker active" if the contract is already locked
     */
    modifier circuitBreaker() {
        require(!locked, "Circuit breaker active");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @notice Modifier that prevents reentrancy and contract calls
     * @dev Checks if caller is an EOA or if circuit breaker is not active
     * @custom:throws "No contract calls" if caller is a contract and circuit breaker is active
     */
    modifier preventReentry() {
        require(msg.sender.code.length == 0 || !locked, "No contract calls");
        _;
    }

    /// FUNCTIONS ///

    /**
     * @notice Retrieves node information for a given tokenId
     * @param tokenId The token ID to query
     * @return Node struct containing the node's data
     */
    function _getNode(uint256 tokenId) internal view returns (Node memory) {
        return nodes[tokenId];
    }

    /**
     * @notice Handles token delegation to a specific tokenId
     * @dev Updates or creates a node and maintains sorted order
     * @param tokenId The token ID to delegate to
     * @param amount The amount of tokens to delegate
     */
    function _delegate(uint256 tokenId, uint256 amount) internal preventReentry {
        Node storage node = nodes[tokenId];
        if (node.tokenId == tokenId) {
            // Update existing node
            node.amount += amount;
            _reposition(tokenId);
        } else {
            // Check size limit before creating new node
            if (size >= MAX_NODES) {
                // If amount is greater than the tail, remove the tail
                if (amount > nodes[tail].amount) {
                    _remove(tail);
                } else {
                    revert MaxNodesReached();
                }
            }
            // Create new node
            _insert(tokenId, amount);
        }
        emit Delegate(msg.sender, tokenId, amount);
    }

    /**
     * @notice Handles token undelegation from a specific tokenId
     * @dev Reduces delegation amount or removes node if amount becomes zero
     * @param tokenId The token ID to undelegate from
     * @param amount The amount of tokens to undelegate
     */
    function _undelegate(uint256 tokenId, uint256 amount) internal preventReentry {
        Node storage node = nodes[tokenId];
        if (node.tokenId != tokenId) revert NodeDoesNotExist();
        if (amount > node.amount) revert AmountExceedsDelegation();

        node.amount -= amount;

        if (node.amount == 0) {
            _remove(tokenId);
        } else {
            _reposition(tokenId);
        }
        emit Undelegate(msg.sender, tokenId, amount);
    }

    function _reposition(uint256 tokenId) internal circuitBreaker {
        Node memory node = nodes[tokenId];
        require(node.tokenId == tokenId, "Invalid node");
        
        bool success = _remove(tokenId);
        require(success, "Remove failed");
        
        _insert(tokenId, node.amount);
    }    

    function _insert(uint256 tokenId, uint256 amount) internal {
        if (head == 0) {
            _initializeFirstNode(tokenId, amount);
        } else {
            _insertNodeInOrder(tokenId, amount);
        }
        unchecked {
            size++;
        }
    }

    function _initializeFirstNode(uint256 tokenId, uint256 amount) private {
        nodes[tokenId] = Node({tokenId: tokenId, amount: amount, next: 0, prev: 0});
        head = tokenId;
        tail = tokenId;
    }

    function _insertNodeInOrder(uint256 tokenId, uint256 amount) private {
        // Cache head value
        uint256 _head = head;
        uint256 current = _head;
        uint256 previous;
        
        // Use unchecked for gas savings since we control node linking
        unchecked {
            // Find insertion point
            while (current != 0) {
                // Cache node amount to avoid multiple SLOADs
                uint256 currentAmount = nodes[current].amount;
                if (amount > currentAmount) break;
                previous = current;
                current = nodes[current].next;
            }

            // Create new node
            nodes[tokenId].tokenId = tokenId;
            nodes[tokenId].amount = amount;
            nodes[tokenId].next = current;
            nodes[tokenId].prev = previous;

            // Update links
            if (current == 0) {
                // Insert at tail
                nodes[tail].next = tokenId;
                tail = tokenId;
            } else {
                // Insert in middle/front
                nodes[current].prev = tokenId;
                if (previous != 0) {
                    nodes[previous].next = tokenId;
                } else {
                    // New head
                    head = tokenId;
                }
            }
        }
    }

    function _remove(uint256 tokenId) internal returns (bool) {
        Node storage node = nodes[tokenId];
        uint256 prev = node.prev;
        uint256 next = node.next;

        if (prev != 0) {
            nodes[prev].next = next;
        } else {
            head = next;
        }

        if (next != 0) {
            nodes[next].prev = prev;
        } else {
            tail = prev;
        }

        delete nodes[tokenId];
        unchecked {
            size--;
            return true;            
        }

    }

    // View functions for the leaderboard
    function _getTop(uint256 count) internal view returns (uint256[] memory, uint256[] memory) {
        uint256 _size = size;

        uint256 resultCount = count > _size ? _size : count;
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

    function _getQuorum() internal view returns (uint256) {
        return 1 + (seats * 51) / 100;
    }

    function _getSeats() internal view returns (uint256) {
        return seats;
    }

    function _setSeats(uint256 tokenId, uint256 numOfSeats) internal {
        if (numOfSeats <= 0) revert InvalidNumSeats();

        // Initial setup case
        if (seats == 0) {
            seats = numOfSeats;
            emit ExecuteSetSeats(tokenId, numOfSeats);
            return;
        }

        SeatUpdate storage proposal = seatUpdate;

        // New proposal
        if (proposal.timestamp == 0) {
            proposal.proposedSeats = numOfSeats;
            proposal.timestamp = block.timestamp;
        } else {
            // Delete the proposal if numOfSeats doesn't match
            if (proposal.proposedSeats != numOfSeats) {
                delete seatUpdate;
                emit SeatUpdateCancelled(tokenId);
                return;
            }

            // Check if caller already voted on seat update
            for (uint256 i; i < proposal.supporters.length;) {
                if (proposal.supporters[i] == tokenId) {
                    revert AlreadySentUpdateRequest();
                }
                unchecked {
                    ++i;
                }
            }
        }

        // Add support
        proposal.supporters.push(tokenId);
        emit SetSeats(tokenId, numOfSeats);
    }

    function _executeSeatsUpdate(uint256 tokenId) internal {
        SeatUpdate storage proposal = seatUpdate;

        // Require proposal exists and delay has passed
        if (proposal.timestamp == 0) revert InvalidProposal();
        if (block.timestamp < proposal.timestamp + 7 days) revert TimelockNotExpired();

        // Verify quorum is still maintained
        if (proposal.supporters.length < _getQuorum()) {
            revert InsufficientVotes();
        }

        seats = proposal.proposedSeats;
        delete seatUpdate;
        emit ExecuteSetSeats(tokenId, proposal.proposedSeats);
    }
}
