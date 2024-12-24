// SPDX-License-Identifier: MIT
pragma solidity =0.8.24 ^0.8.0 ^0.8.24;

// lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// src/Board.sol

/// @title Board
/// @notice Manages a sorted linked list of nodes representing token delegations and board seats
/// @dev Abstract contract that implements core board functionality including delegation tracking
///      and seat management. Uses a doubly linked list to maintain sorted order of delegations.
abstract contract Board {
    /// @notice Emitted when the number of seats is set
    /// @param numOfSeats The new number of seats
    event SetSeats(uint256 numOfSeats);

    /// @notice Emitted when a call to set the number of seats is made
    /// @param caller The address of the caller
    event SetSeatsCall(address caller);

    /// @notice Emitted when a user delegates tokens to a tokenId
    /// @param sender The address of the user delegating tokens
    /// @param tokenId The tokenId to which tokens are delegated
    /// @param amount The amount of tokens delegated
    event Delegate(address indexed sender, uint256 tokenId, uint256 amount);

    /// @notice Emitted when a user undelegates tokens from a tokenId
    /// @param sender The address of the user undelegating tokens
    /// @param tokenId The tokenId from which tokens are undelegated
    /// @param amount The amount of tokens undelegated
    event Undelegate(address indexed sender, uint256 tokenId, uint256 amount);

    /// @notice Thrown when an update request has already been sent by the caller
    error AlreadySentUpdateRequest();

    /// @notice Thrown when the number of seats provided is invalid
    error InvalidNumSeats();

    /// @notice Thrown when the node does not exist
    error NodeDoesNotExist();

    /// @notice Thrown when the amount exceeds the delegation
    error AmountExceedsDelegation();

    /// @notice Node structure for the doubly linked list
    /// @dev Each node represents a token delegation with links to maintain sorted order
    /// @param tokenId Unique identifier for the token
    /// @param amount Total amount of tokens delegated to this node
    /// @param next TokenId of the next node in the sorted list (0 if none)
    /// @param prev TokenId of the previous node in the sorted list (0 if none)
    struct Node {
        uint256 tokenId;
        uint256 amount;
        uint256 next;
        uint256 prev;
    }

    /// @notice Number of board seats
    uint256 private seats;

    /// @notice Mapping from tokenId to Node data
    mapping(uint256 => Node) internal nodes;

    /// @notice List of addresses that have requested a seat update
    address[] private updateSeatList;

    /// @notice TokenId of the first node (highest amount)
    uint256 internal head;
    /// @notice TokenId of the last node (lowest amount)
    uint256 internal tail;
    /// @notice Total number of nodes in the list
    uint256 internal size;

    /// @notice Retrieves node information for a given tokenId
    /// @param tokenId The token ID to query
    /// @return Node struct containing the node's data
    function _getNode(uint256 tokenId) internal view returns (Node memory) {
        return nodes[tokenId];
    }

    /// @notice Handles token delegation to a specific tokenId
    /// @dev Updates or creates a node and maintains sorted order
    /// @param tokenId The token ID to delegate to
    /// @param amount The amount of tokens to delegate
    function _delegate(uint256 tokenId, uint256 amount) internal {
        Node storage node = nodes[tokenId];
        if (node.tokenId == tokenId) {
            // Update existing node
            node.amount += amount;
            _reposition(tokenId);
        } else {
            // Create new node
            _insert(tokenId, amount);
        }
        emit Delegate(msg.sender, tokenId, amount);
    }

    /// @notice Handles token undelegation from a specific tokenId
    /// @dev Reduces delegation amount or removes node if amount becomes zero
    /// @param tokenId The token ID to undelegate from
    /// @param amount The amount of tokens to undelegate
    function _undelegate(uint256 tokenId, uint256 amount) internal {
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

    function _insert(uint256 tokenId, uint256 amount) internal {
        if (head == 0) {
            _initializeFirstNode(tokenId, amount);
        } else {
            _insertNodeInOrder(tokenId, amount);
        }
        _incrementSize();
    }

    function _initializeFirstNode(uint256 tokenId, uint256 amount) private {
        nodes[tokenId] = Node({tokenId: tokenId, amount: amount, next: 0, prev: 0});
        head = tokenId;
        tail = tokenId;
    }

    function _insertNodeInOrder(uint256 tokenId, uint256 amount) private {
        uint256 current = head;
        uint256 previous = 0;

        while (current != 0 && amount <= nodes[current].amount) {
            previous = current;
            current = nodes[current].next;
        }

        nodes[tokenId] = Node({tokenId: tokenId, amount: amount, next: current, prev: previous});

        if (current == 0) {
            nodes[tail].next = tokenId;
            tail = tokenId;
        } else {
            nodes[current].prev = tokenId;
            if (previous != 0) {
                nodes[previous].next = tokenId;
            } else {
                head = tokenId;
            }
        }
    }

    function _incrementSize() private {
        unchecked {
            size++;
        }
    }

    function _remove(uint256 tokenId) internal {
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
        }
    }

    function _reposition(uint256 tokenId) internal {
        uint256 amount = nodes[tokenId].amount;
        _remove(tokenId);
        _insert(tokenId, amount);
    }

    // View functions for the leaderboard
    function _getTop(uint256 count) internal view returns (uint256[] memory, uint256[] memory) {
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

    function _getQuorum() internal view returns (uint256) {
        return 1 + (seats * 51) / 100;
    }

    function _getSeats() internal view returns (uint256) {
        return seats;
    }

    function _setSeats(uint256 numOfSeats) internal {
        if (numOfSeats <= 0) revert InvalidNumSeats();

        if (seats == 0) {
            seats = numOfSeats;
            emit SetSeats(numOfSeats);
            return;
        }

        uint256 _quorum = _getQuorum();

        if (updateSeatList.length == 0 || !_hasRequestedUpdate(msg.sender)) {
            updateSeatList.push(msg.sender);
            emit SetSeatsCall(msg.sender);
        } else {
            revert AlreadySentUpdateRequest();
        }

        if (updateSeatList.length >= _quorum) {
            seats = numOfSeats;
            emit SetSeats(numOfSeats);
            delete updateSeatList;
        }
    }

    function _hasRequestedUpdate(address sender) internal view returns (bool) {
        for (uint256 i = 0; i < updateSeatList.length; i++) {
            if (updateSeatList[i] == sender) {
                return true;
            }
        }
        return false;
    }

    function _getSeatUpdateList() internal view returns (address[] memory) {
        return updateSeatList;
    }
}

// src/Wallet.sol

abstract contract Wallet {
    event SubmitTransaction(
        address indexed leader, uint256 indexed txIndex, address indexed to, uint256 value, bytes data
    );
    event ConfirmTransaction(address indexed leader, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed leader, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed leader, uint256 indexed txIndex);

    struct Transaction {
        address target;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) private isConfirmed;

    // Custom Errors
    error TransactionDoesNotExist();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyConfirmed();
    error TransactionNotConfirmed();
    error TransactionFailed();

    modifier txExists(uint256 _txIndex) {
        if (_txIndex >= transactions.length) revert TransactionDoesNotExist();
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        if (transactions[_txIndex].executed) revert TransactionAlreadyExecuted();
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        if (isConfirmed[_txIndex][msg.sender]) revert TransactionAlreadyConfirmed();
        _;
    }

    function _submitTransaction(address _target, uint256 _value, bytes memory _data) internal {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({target: _target, value: _value, data: _data, executed: false, numConfirmations: 0})
        );

        emit SubmitTransaction(msg.sender, txIndex, _target, _value, _data);
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
        if (!isConfirmed[_txIndex][msg.sender]) revert TransactionNotConfirmed();

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function _executeTransaction(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success,) = transaction.target.call{value: transaction.value}(transaction.data);
        if (!success) revert TransactionFailed();

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
            target: transaction.target,
            value: transaction.value,
            data: transaction.data,
            executed: transaction.executed,
            numConfirmations: transaction.numConfirmations
        });
    }

    /// @notice Checks if a transaction is confirmed by a specific director
    /// @param txIndex The index of the transaction to check
    /// @param director The address of the director to check confirmation for
    /// @return True if the transaction is confirmed by the director, false otherwise
    function getConfirmation(uint256 txIndex, address director) public view returns (bool) {
        return isConfirmed[txIndex][director];
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

// src/Chamber.sol

// Loreum Chamber v1

/// @title Chamber Contract
/// @notice This contract manages a multisig wallet with governance and delegation features using ERC20 and ERC721 tokens.
contract Chamber is Board, Wallet, ReentrancyGuard {
    /// @notice ERC20 governance token
    IERC20 public token;
    /// @notice ERC721 membership token
    IERC721 public nft;

    /// @notice Mapping to track delegated amounts per user per tokenId
    mapping(address => mapping(uint256 => uint256)) private _userDelegations;

    /// @notice Emitted when the contract receives Ether
    /// @param sender The address that sent the Ether
    /// @param amount The amount of Ether received
    event Received(address indexed sender, uint256 amount);

    /// Custom Errors
    error InsufficientDelegatedAmount();
    error TransferFailed();
    error ArrayLengthsMustMatch();
    error NotEnoughConfirmations();
    error CallerIsNotADirector();
    error ZeroAddress();
    error ZeroAmount();
    error ArrayIndexOutOfBounds();

    /// @notice Initializes the Chamber contract with the given ERC20 and ERC721 tokens and sets the number of seats
    /// @param erc20Token The address of the ERC20 token
    /// @param erc721Token The address of the ERC721 token
    /// @param seats The initial number of seats
    constructor(address erc20Token, address erc721Token, uint256 seats) {
        if (erc20Token == address(0) || erc721Token == address(0)) {
            revert ZeroAddress();
        }
        token = IERC20(erc20Token);
        nft = IERC721(erc721Token);
        _setSeats(seats);
    }

    /// @notice Delegates a specified amount of tokens to a tokenId
    /// @param tokenId The tokenId to which tokens are delegated
    /// @param amount The amount of tokens to delegate
    function delegate(uint256 tokenId, uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Cache the current delegation amount to minimize storage reads
        uint256 currentDelegation = _userDelegations[msg.sender][tokenId];
        uint256 newDelegation = currentDelegation + amount;

        // Update user delegation amount
        _userDelegations[msg.sender][tokenId] = newDelegation;

        _delegate(tokenId, amount);

        // Transfer tokens from user
        if (!token.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
    }

    /// @notice Undelegates a specified amount of tokens from a tokenId
    /// @param tokenId The tokenId from which tokens are undelegated
    /// @param amount The amount of tokens to undelegate
    function undelegate(uint256 tokenId, uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Cache the current delegation amount to minimize storage reads
        uint256 currentDelegation = _userDelegations[msg.sender][tokenId];
        if (currentDelegation < amount) revert InsufficientDelegatedAmount();

        uint256 newDelegation = currentDelegation - amount;

        // Update user delegation amount
        _userDelegations[msg.sender][tokenId] = newDelegation;

        _undelegate(tokenId, amount);

        // Transfer tokens back to user
        if (!token.transfer(msg.sender, amount)) revert TransferFailed();
    }

    /// BOARD ///

    /// @notice Retrieves the node information for a given tokenId
    /// @param tokenId The tokenId to retrieve information for
    /// @return The Node struct containing the node information
    function getMember(uint256 tokenId) public view returns (Node memory) {
        return _getNode(tokenId);
    }

    /// @notice Retrieves the top tokenIds and their amounts
    /// @param count The number of top tokenIds to retrieve
    /// @return An array of top tokenIds and their corresponding amounts
    function getTop(uint256 count) public view returns (uint256[] memory, uint256[] memory) {
        return _getTop(count);
    }

    /// @notice Retrieves the delegation amount for a user and tokenId
    /// @param user The address of the user
    /// @param tokenId The tokenId to check
    /// @return The amount of tokens delegated by the user to the tokenId
    function getDelegation(address user, uint256 tokenId) public view returns (uint256) {
        return _userDelegations[user][tokenId];
    }

    /// @notice Retrieves the current quorum
    /// @return The current quorum value
    function getQuorum() public view returns (uint256) {
        return _getQuorum();
    }

    /// @notice Retrieves the current number of seats
    /// @return The current number of seats
    function getSeats() public view returns (uint256) {
        return _getSeats();
    }

    /// @notice Retrieves the addresses of the current directors
    /// @return An array of addresses representing the current directors
    function getDirectors() public view returns (address[] memory) {
        (uint256[] memory topTokenIds,) = getTop(_getSeats());
        address[] memory topOwners = new address[](topTokenIds.length);

        for (uint256 i = 0; i < topTokenIds.length; i++) {
            try nft.ownerOf(topTokenIds[i]) returns (address owner) {
                topOwners[i] = owner;
            } catch {
                topOwners[i] = address(0); // Default to address(0) if the call fails
            }
        }

        return topOwners;
    }

    /// @notice Returns the list of tokenIds to which the user has delegated tokens and the corresponding amounts
    /// @param user The address of the user
    /// @return tokenIds The list of tokenIds
    /// @return amounts The list of amounts delegated to each tokenId
    function getDelegations(address user) external view returns (uint256[] memory tokenIds, uint256[] memory amounts) {
        uint256 count = 0;
        uint256 tokenId = head;

        // First pass: count the number of delegations
        while (tokenId != 0) {
            if (_userDelegations[user][tokenId] > 0) {
                count++;
            }
            tokenId = nodes[tokenId].next;
        }

        // Allocate arrays with the correct size
        tokenIds = new uint256[](count);
        amounts = new uint256[](count);

        // Second pass: populate the arrays
        count = 0;
        tokenId = head;
        while (tokenId != 0) {
            if (_userDelegations[user][tokenId] > 0) {
                tokenIds[count] = tokenId;
                amounts[count] = _userDelegations[user][tokenId];
                count++;
            }
            tokenId = nodes[tokenId].next;
        }
    }

    /// @notice Retrieves the list of addresses that have requested a seat update
    /// @return An array of addresses that have requested a seat update
    function getSeatUpdate() public view returns (address[] memory) {
        return _getSeatUpdateList();
    }

    /// @notice Updates the number of seats
    /// @param numOfSeats The new number of seats
    function updateNumSeats(uint256 numOfSeats) public onlyDirector {
        _setSeats(numOfSeats);
    }

    /// WALLET ///

    /// @notice Submits a new transaction for approval
    /// @param target The address to send the transaction to
    /// @param value The amount of Ether to send
    /// @param data The data to include in the transaction
    function submitTransaction(address target, uint256 value, bytes memory data) public onlyDirector {
        _submitTransaction(target, value, data);
    }

    /// @notice Confirms a transaction
    /// @param transactionId The ID of the transaction to confirm
    function confirmTransaction(uint256 transactionId) public onlyDirector {
        _confirmTransaction(transactionId);
    }

    /// @notice Executes a transaction if it has enough confirmations
    /// @param transactionId The ID of the transaction to execute
    function executeTransaction(uint256 transactionId) public onlyDirector {
        if (getTransaction(transactionId).numConfirmations < getQuorum()) revert NotEnoughConfirmations();
        _executeTransaction(transactionId);
    }

    /// @notice Revokes a confirmation for a transaction
    /// @param transactionId The ID of the transaction to revoke confirmation for
    function revokeConfirmation(uint256 transactionId) public onlyDirector {
        _revokeConfirmation(transactionId);
    }

    /// @notice Submits multiple transactions for approval in a single call
    /// @param targets The array of addresses to send the transactions to
    /// @param values The array of amounts of Ether to send
    /// @param data The array of data to include in each transaction
    function submitBatchTransactions(address[] memory targets, uint256[] memory values, bytes[] memory data)
        public
        onlyDirector
    {
        if (targets.length != values.length || values.length != data.length) revert ArrayLengthsMustMatch();

        for (uint256 i = 0; i < targets.length; i++) {
            _submitTransaction(targets[i], values[i], data[i]);
        }
    }

    /// @notice Confirms multiple transactions in a single call
    /// @param transactionIds The array of transaction IDs to confirm
    function confirmBatchTransactions(uint256[] memory transactionIds) public onlyDirector {
        for (uint256 i = 0; i < transactionIds.length; i++) {
            _confirmTransaction(transactionIds[i]);
        }
    }

    /// @notice Executes multiple transactions in a single call if they have enough confirmations
    /// @param transactionIds The array of transaction IDs to execute
    function executeBatchTransactions(uint256[] memory transactionIds) public onlyDirector {
        for (uint256 i = 0; i < transactionIds.length; i++) {
            uint256 transactionId = transactionIds[i];
            if (getTransaction(transactionId).numConfirmations < getQuorum()) revert NotEnoughConfirmations();
            _executeTransaction(transactionId);
        }
    }

    /// @notice Fallback function to receive Ether
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @notice Modifier to restrict access to only directors
    modifier onlyDirector() {
        uint256 seats = _getSeats();
        uint256 current = head;

        // Iterate through linked list directly rather than creating array
        for (uint256 i; i < seats;) {
            if (current == 0) break; // Exit if we reach end of list

            if (nft.ownerOf(current) == msg.sender) {
                _;
                return;
            }

            current = nodes[current].next;
            unchecked {
                ++i;
            }
        }

        revert CallerIsNotADirector();
    }
}

