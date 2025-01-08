// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Initializable} from "lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {Clones} from "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";


/**
 * @title Registry
 * @notice Central registry for deploying and managing Chamber instances
 * @dev Uses minimal proxy pattern for gas-efficient deployment
 */
contract Registry is AccessControl, Initializable {
    /// @notice Role for managing the registry configuration
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice The implementation contract to clone
    address public implementation;

    /// @notice Array to track all deployed chambers
    address[] private _chambers;

    /// @notice Mapping to check if an address is a deployed chamber
    mapping(address => bool) private _isChamber;

    /**
     * @notice Emitted when a new chamber is deployed
     * @param chamber The address of the newly deployed chamber
     * @param seats The initial number of board seats
     * @param name The name of the chamber's ERC20 token
     * @param symbol The symbol of the chamber's ERC20 token
     * @param erc20Token The ERC20 token used for governance
     * @param erc721Token The ERC721 token used for membership
     */
    event ChamberCreated(
        address indexed chamber,
        uint256 seats,
        string name,
        string symbol,
        address erc20Token,
        address erc721Token
    );

    error ZeroAddress();
    error InvalidSeats();

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the Registry contract
     * @param admin The address that will have admin role
     */
    function initialize(address _implementation, address admin) external initializer {
        if (admin == address(0) || _implementation == address(0)) revert ZeroAddress();
        implementation = _implementation;
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /**
     * @notice Deploys a new Chamber instance
     * @param erc20Token The ERC20 token to be used for assets
     * @param erc721Token The ERC721 token to be used for membership
     * @param seats The initial number of board seats
     * @param name The name of the chamber's ERC20 token
     * @param symbol The symbol of the chamber's ERC20 token
     * @return chamber The address of the newly deployed chamber
     */
    function createChamber(
        address erc20Token,
        address erc721Token,
        uint256 seats,
        string memory name,
        string memory symbol
    ) external returns (address payable chamber) {
        if (erc20Token == address(0) || erc721Token == address(0)) revert ZeroAddress();
        if (seats == 0 || seats > 20) revert InvalidSeats();
        
        chamber = payable(Clones.clone(implementation));
        IChamber(chamber).initialize(erc20Token, erc721Token, seats, name, symbol);
        
        _chambers.push(chamber);
        _isChamber[chamber] = true;
        
        emit ChamberCreated(
            chamber,
            seats,
            name,
            symbol,
            erc20Token,
            erc721Token
        );
    }

    /**
     * @notice Returns all deployed chambers
     * @return Array of chamber addresses
     */
    function getAllChambers() external view returns (address[] memory) {
        return _chambers;
    }

    /**
     * @notice Returns the total number of deployed chambers
     * @return The number of chambers
     */
    function getChamberCount() external view returns (uint256) {
        return _chambers.length;
    }

    /**
     * @notice Returns a subset of chambers for pagination
     * @param limit The maximum number of chambers to return
     * @param skip The number of chambers to skip
     * @return Array of chamber addresses
     */
    function getChambers(uint256 limit, uint256 skip) external view returns (address[] memory) {
        uint256 total = _chambers.length;
        if (skip >= total) {
            return new address[](0);
        }

        uint256 remaining = total - skip;
        uint256 count = remaining < limit ? remaining : limit;
        address[] memory result = new address[](count);

        for (uint256 i = 0; i < count;) {
            result[i] = _chambers[skip + i];
            unchecked { ++i; }
        }

        return result;
    }

    /**
     * @notice Checks if an address is a deployed chamber
     * @param chamber The address to check
     * @return bool True if the address is a deployed chamber
     */
    function isChamber(address chamber) external view returns (bool) {
        return _isChamber[chamber];
    }
}

interface IChamber {
    function initialize(
        address erc20Token,
        address erc721Token,
        uint256 seats,
        string memory name,
        string memory symbol
    ) external;
}


