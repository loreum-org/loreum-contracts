// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Chamber} from "src/Chamber.sol";
import {MockERC20} from "test/mock/MockERC20.sol";
import {MockERC721} from "test/mock/MockERC721.sol";
import {DeployChamber} from "test/utils/DeployChamber.sol";

contract ChamberTest is Test {
    // using DeployProxy for address;

    Chamber public implementation;
    Chamber public chamber;
    MockERC20 public token;
    MockERC721 public nft;
    address public user = makeAddr("user");
    uint256 public constant INITIAL_SEATS = 5;

    function setUp() public {
        token = new MockERC20("Test Token", "TEST", 1000000e18);
        nft = new MockERC721();
        
        // Deploy implementation
        implementation = new Chamber(token, nft);
        
        // Deploy proxy
        chamber = DeployChamber.deploy(
            address(implementation),
            address(token),
            address(nft),
            INITIAL_SEATS,
            "Chamber Token",
            "CHMB"
        );

        // Setup initial state
        vm.startPrank(user);
        token.approve(address(chamber), type(uint256).max);
        vm.stopPrank();
    }

    function test_Initialize() public {
        assertEq(address(chamber.membership()), address(nft));
        assertEq(address(chamber.asset()), address(token));
        assertEq(chamber.getSeats(), INITIAL_SEATS);
        assertEq(chamber.name(), "Chamber Token");
        assertEq(chamber.symbol(), "CHMB");
    }

    function test_RevertWhen_ReinitializingProxy() public {
        vm.expectRevert("Initializable: contract is already initialized");
        chamber.initialize(
            address(token),
            address(nft),
            INITIAL_SEATS,
            "Chamber Token",
            "CHMB"
        );
    }

    function test_RevertWhen_InitializingImplementation() public {
        vm.expectRevert("Initializable: contract is already initialized");
        implementation.initialize(
            address(token),
            address(nft),
            INITIAL_SEATS,
            "Chamber Token",
            "CHMB"
        );
    }
}
