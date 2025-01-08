// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Registry} from "src/Registry.sol";
import {Chamber} from "src/Chamber.sol";

contract DeployRegistry is Script {
    function run() external {
        address admin = vm.envAddress("ADMIN");

        // Deploy Chamber implementation
        Chamber implementation = new Chamber();

        // Deploy Registry
        Registry registry = new Registry();
        registry.initialize(address(implementation), admin);

        vm.stopBroadcast();

        // Log deployed addresses
        console.log("Registry deployed to:", address(registry));
        console.log("Chamber implementation deployed to:", address(implementation));
        console.log("Admin set to:", admin);
    }
} 