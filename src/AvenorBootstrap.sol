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
cast send <BOOTSTRAP_ADDRESS> \
"deploy(bytes32,bytes)(address)" \
$SALT \
$CODE \
--rpc-url wss://base-sepolia-rpc.publicnode.com \
--account universal

# Arbitrum
cast send <SAME_BOOTSTRAP_ADDRESS> \
"deploy(bytes32,bytes)(address)" \
$SALT \
$CODE \
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
