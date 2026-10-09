#!/bin/bash

set -e
source .env

echo "=== Deploying to Base Sepolia ==="

forge script script/VaultRegistryTest.s.sol:VaultRegistryTest \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --password-file .password \
  --broadcast \
  -vvvv



forge script script/VaultRegistryTest.s.sol:VaultRegistryTest \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --password-file .password \
  --broadcast \
  -vvvv

echo "=== Both interactions done  ==="





