// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";

contract MockERC721 is IERC721 {
    mapping(uint256 => address) private _owners;

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _owners[tokenId];
    }

    function mint(address to, uint256 tokenId) external {
        _owners[tokenId] = to;
    }

    function balanceOf(address /*owner*/) external pure returns (uint256 /*balance*/) {
        revert("Not implemented");
    }

    function approve(address /*to*/, uint256 /*tokenId*/) external pure {
        revert("Not implemented");
    }

    function getApproved(uint256 /*tokenId*/) external pure returns (address /*operator*/) {
        revert("Not implemented");
    }

    function isApprovedForAll(address /*owner*/, address /*operator*/) external pure returns (bool) {
        revert("Not implemented");
    }

    function safeTransferFrom(address /*from*/, address /*to*/, uint256 /*tokenId*/) external pure {
        revert("Not implemented");
    }

    function safeTransferFrom(address /*from*/, address /*to*/, uint256 /*tokenId*/, bytes calldata /*data*/) external pure {
        revert("Not implemented");
    }

    function setApprovalForAll(address /*operator*/, bool /*approved*/) external pure {
        revert("Not implemented");
    }

    function supportsInterface(bytes4 /*interfaceId*/) external pure returns (bool) {
        revert("Not implemented");
    }

    function transferFrom(address /*from*/, address /*to*/, uint256 /*tokenId*/) external pure {
        revert("Not implemented");
    }
}