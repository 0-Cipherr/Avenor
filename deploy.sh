#!/bin/bash

set -e
source .env

echo "=== Deploying to Base Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  -vv
  # --etherscan-api-key "$ETHERSCAN_API" \
  # --verify \

echo "=== Base Sepolia deployment complete ==="
echo "=== Deploying to Arbitrum Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  -vv

  # --etherscan-api-key "$ETHERSCAN_API" \
  # --verify \

echo "=== Both deployments finished successfully ==="




# == Logs Base==
  # STEP ONE: Strategy Adapter deployed: 
  # 0x5aAdFB43eF8dAF45DD80F4676345b7676f1D70e3
  # STEP TWO: Facotry Deployed: 
  # 0xf13D09eD3cbdD1C930d4de74808de1f33B6b3D4f
  # STEP THREE: Messenger Deployed: 
  # 0x5c4a3C2CD1ffE6aAfDF62b64bb3E620C696c832E
  # REGISTRY DEPLOYED:
  # 0x6AE5E129054a5dBFCeBb9Dfcb1CE1AA229fB1Ddb
  # STEP ONE: Strategy Adapter deployed: 
  # 0x36a92b70557fa56e195908214af4331Bf3c766eE
  # STEP TWO: Facotry Deployed: 
  # 0x06Fb7A9B82dA260D97433513140E5990b6CEC1B8
  # STEP THREE: Messenger Deployed: 
  # 0x8B0b4345B4123E1DCa26dF5Ae8793c9faF8C69dC
  # REGISTRY DEPLOYED:
  # 0xE55dE713dcB8027F0deeF02a68381BC3ca6a9a23




# == Logs ARB  ==
  # STEP ONE: Strategy Adapter deployed: 
  # 0x5aAdFB43eF8dAF45DD80F4676345b7676f1D70e3
  # STEP TWO: Facotry Deployed: 
  # 0xf13D09eD3cbdD1C930d4de74808de1f33B6b3D4f
  # STEP THREE: Messenger Deployed: 
  # 0x5c4a3C2CD1ffE6aAfDF62b64bb3E620C696c832E
  # REGISTRY DEPLOYED:
  # 0x6AE5E129054a5dBFCeBb9Dfcb1CE1AA229fB1Ddb
  # STEP ONE: Strategy Adapter deployed: 
  # 0x89CAEe525C62B106d1D201381FdAd5c9aF507325
  # STEP TWO: Facotry Deployed: 
  # 0x755C862aF99931880008273a8c41C8Bc86E0C464
  # STEP THREE: Messenger Deployed: 
  # 0xE5bd01d62962D96b351569c421Bfa1980F9c1dC6
  # REGISTRY DEPLOYED:
  # 0x889A6bFB5eFc76643AF1D4320d013f6D326a500b
