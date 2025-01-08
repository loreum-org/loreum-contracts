// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Registry} from "src/Registry.sol";
import {Chamber} from "src/Chamber.sol";
import {DeployRegistry} from "test/utils/DeployRegistry.sol";

contract RegistryScript is Script {
    function run() external {
        address admin = vm.envAddress("ADMIN");

        vm.startBroadcast();

        DeployRegistry.deploy(admin);

        vm.stopBroadcast();
    }
} 