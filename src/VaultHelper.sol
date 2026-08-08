// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library VaultHelper {
    function addrToBytes32(address addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function bytes32ToAddr(bytes32 bytes32Value) public pure returns (address) {
        return address(uint160(uint256(bytes32Value)));
    }
}
