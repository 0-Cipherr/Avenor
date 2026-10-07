#!/bin/bash

set -e
source .env

echo "=== Deploying to Base Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  # --etherscan-api-key "$ETHERSCAN_API" \
  # --verify \
  # -vvvv

echo "=== Base Sepolia deployment complete ==="
echo "=== Deploying to Arbitrum Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  # --etherscan-api-key "$ETHERSCAN_API" \
  # --verify \
  # -vvvv

echo "=== Both deployments finished successfully ==="




# == Logs Base ==
#   STEP ONE: Strategy Adapter deployed: 
#   0x5aAdFB43eF8dAF45DD80F4676345b7676f1D70e3
#   STEP TWO: Facotry Deployed: 
#   0xf13D09eD3cbdD1C930d4de74808de1f33B6b3D4f
#   STEP THREE: Messenger Deployed: 
#   0x5c4a3C2CD1ffE6aAfDF62b64bb3E620C696c832E
#   REGISTRY DEPLOYED:
#   0x6AE5E129054a5dBFCeBb9Dfcb1CE1AA229fB1Ddb
#   STEP ONE: Strategy Adapter deployed: 
#   0x4f643fa345f87ee1F192B1B2684c6414c68fE9b4
#   STEP TWO: Facotry Deployed: 
#   0xc33b474Cc440C330D72fda9C8498e1670138fdAb
#   STEP THREE: Messenger Deployed: 
#   0xAAE7b9Cb125f1888FD56Ff987E80d1E4AcA7c790
#   REGISTRY DEPLOYED:
#   0x1cE3733bE7CCeb28F091593f7371A937D65F6B26




# == Logs ARB ==
#   STEP ONE: Strategy Adapter deployed: 
#   0x5aAdFB43eF8dAF45DD80F4676345b7676f1D70e3
#   STEP TWO: Facotry Deployed: 
#   0xf13D09eD3cbdD1C930d4de74808de1f33B6b3D4f
#   STEP THREE: Messenger Deployed: 
#   0x5c4a3C2CD1ffE6aAfDF62b64bb3E620C696c832E
#   REGISTRY DEPLOYED:
#   0x6AE5E129054a5dBFCeBb9Dfcb1CE1AA229fB1Ddb
#   STEP ONE: Strategy Adapter deployed: 
#   0xFE9e97fD7deD0A1943fF354C449aD79A129551cA
#   STEP TWO: Facotry Deployed: 
#   0xbAC5C5D9Edf14D185F728C0cfDB353533873Ae0f
#   STEP THREE: Messenger Deployed: 
#   0x7F34F214551849D42402c5628159B4B928C8B9d5
#   REGISTRY DEPLOYED:
#   0xDFf11047a734D9ED88dD7DEDE3E2C98f2775458e

