// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {Chamber} from "src/Chamber.sol";

contract DeployChamber is Script {
    
    address token = address(1);
    address nft = address(2);

    function run() external {
        vm.startBroadcast();
        Chamber chamberImpl = new Chamber(token, nft, 5);
        vm.stopBroadcast();
    }
}
