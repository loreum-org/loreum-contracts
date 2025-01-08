// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import {Chamber} from "src/Chamber.sol";

library DeployChamber {
    function deploy(
        address implementation,
        address erc20Token,
        address erc721Token,
        uint256 seats,
        string memory name,
        string memory symbol
    ) internal returns (Chamber) {
        address proxy = Clones.clone(implementation);
        Chamber(proxy).initialize(erc20Token, erc721Token, seats, name, symbol);
        return Chamber(proxy);
    }
} 