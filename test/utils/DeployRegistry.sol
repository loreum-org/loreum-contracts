// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import {Registry} from "src/Registry.sol";
import {Chamber} from "src/Chamber.sol";

library DeployRegistry {
    function deploy(address admin) internal returns (Registry) {
        // Deploy implementation
        Registry registryImplementation = new Registry();
        Chamber chamberImplementation = new Chamber();
        // Deploy proxy
        address payable proxy = payable(Clones.clone(address(registryImplementation)));
        Registry(proxy).initialize(address(chamberImplementation), admin);
        
        return Registry(proxy);
    }
}