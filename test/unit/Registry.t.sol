// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Registry} from "src/Registry.sol";
import {Chamber} from "src/Chamber.sol";
import {MockERC20} from "test/mock/MockERC20.sol";
import {MockERC721} from "test/mock/MockERC721.sol";
import {DeployRegistry} from "test/utils/DeployRegistry.sol";

contract RegistryTest is Test {
    Registry public registry;
    Chamber public implementation;
    MockERC20 public token;
    MockERC721 public nft;
    address public admin = makeAddr("admin");

    function setUp() public {
        token = new MockERC20("Test Token", "TEST", 1000000e18);
        nft = new MockERC721("Mock NFT", "MNFT");
        
        // Deploy implementation
        implementation = new Chamber();
        
        // Deploy and initialize registry
        registry = DeployRegistry.deploy(admin);
        vm.prank(admin);
    }

    function test_Registry_Initialize() public view {
        assertTrue(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(registry.hasRole(registry.ADMIN_ROLE(), admin));
    }

    function test_Registry_CreateChamber() public {
        address chamber = registry.createChamber(
            address(token),
            address(nft),
            5,
            "Chamber Token",
            "CHMB"
        );

        assertTrue(registry.isChamber(chamber));
        assertEq(registry.getChamberCount(), 1);
        
        address[] memory chambers = registry.getAllChambers();
        assertEq(chambers.length, 1);
        assertEq(chambers[0], chamber);
    }

    function test_Registry_GetChambers_Pagination() public {
        // Create 5 chambers
        for (uint256 i = 0; i < 5; i++) {
            registry.createChamber(
                address(token),
                address(nft),
                5,
                string.concat("Chamber Token ", vm.toString(i)),
                string.concat("CHMB", vm.toString(i))
            );
        }

        // Test pagination
        address[] memory chambers = registry.getChambers(2, 1);
        assertEq(chambers.length, 2);
        assertTrue(registry.isChamber(chambers[0]));
        assertTrue(registry.isChamber(chambers[1]));

        // Test with skip >= total
        chambers = registry.getChambers(2, 5);
        assertEq(chambers.length, 0);

        // Test with remaining < limit
        chambers = registry.getChambers(3, 3);
        assertEq(chambers.length, 2);
    }
} 