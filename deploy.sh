#!/bin/bash

source .env

forge script script/VaultRegistryTest.s.sol:VaultRegistryTest \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv

forge script script/VaultRegistryTest.s.sol:VaultRegistryTest \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv

echo "Both deployments finished"
