// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import {Chamber} from "src/Chamber.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

library DeployChamber {
    function deploy(
        address erc20Token,
        address erc721Token,
        uint256 seats,
        string memory name,
        string memory symbol
    ) internal returns (Chamber) {
        // Deploy implementation
        Chamber implementation = new Chamber();
        
        // Deploy proxy
        address payable proxy = payable(Clones.clone(address(implementation)));
        Chamber(proxy).initialize(erc20Token, erc721Token, seats, name, symbol);
        
        return Chamber(proxy);
    }
} 