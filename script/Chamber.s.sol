// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {Chamber} from "src/Chamber.sol";

contract DeployChamber is Script {
    address token;
    address nft;

    function run() external {
        vm.startBroadcast();

        if (block.chainid == 11155111) {
            token = 0xedf2e61ADD8976AC08Df4AFB69faDCD1428555f7;
            nft = 0xe02A8f23c19280dd828Eb5CA5EC89d64345f06d8;
        }

        new Chamber(token, nft, 5);
        vm.stopBroadcast();
    }
}
