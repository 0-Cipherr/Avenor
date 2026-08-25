// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// dpeloy with avenor multi use with fresh wallets with fresh nonce
//check wallet nonce: cast nonce 0x123456... \
// --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com

// cast nonce 0x123456... \
// --rpc-url wss://base-sepolia-rpc.publicnode.com

//to dpeloy :
/**
 * @title 
 * forge create src/AvenorBootstrap.sol:AvenorBootstrap \
  --rpc-url wss://base-sepolia-rpc.publicnode.com \
  --account Avenor_Multi \
  --broadcast

  forge create src/AvenorBootstrap.sol:AvenorBootstrap \
  --rpc-url wss://arbitrum-sepolia-rpc.publicnode.com \
  --account Avenor_Multi \
  --broadcast

  to deploy deterministic factory: 
  # Base
cast send 0x5CE1c405A905dF362715aC90E39e29d21C727C60 \
"deploy(bytes32,bytes)(address)" \
"$SALT" \
"$CODE" \
--rpc-url wss://base-sepolia-rpc.publicnode.com \
--account universal

# Arbitrum
cast send 0x38b13dB989770Df6b33d0f699C55c67f87E6674F \
"deploy(bytes32,bytes)(address)" \
"$SALT" \
"$CODE" \
--rpc-url wss://arbitrum-sepolia-rpc.publicnode.com \
--account universal
 * @author 
 * @notice 
 */

// account used to do : universal
contract AvenorBootstrap {
    function deploy(
        bytes32 salt,
        bytes memory creationCode
    ) external returns (address deployed) {
        assembly {
            deployed := create2(
                0,
                add(creationCode, 0x20),
                mload(creationCode),
                salt
            )
        }

        require(deployed != address(0), "CREATE2_FAILED");
    }

    function predict(
        bytes32 salt,
        bytes32 initCodeHash
    ) external view returns (address predicted) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, initCodeHash)
        );

        predicted = address(uint160(uint256(hash)));
    }
}
//
//base factory eployed:@0x657919810120b68a50F0957fE53D0Eac6805F7B4
//arb factory:
///calling wllet: 0x2d9fd35ECc5C04701fCB9fF7e7d7563b57EE08e3
