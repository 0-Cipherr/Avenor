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
  # 0xFAadF66A152ade8Ba77724e06057B6e56b800a2E
  # STEP TWO: Facotry Deployed: 
  # 0x15Dc25680D1735BdaC186f22544B9E06047b0025
  # STEP THREE: Messenger Deployed: 
  # 0x9bb210026DC2D7358957Ac6126525D93F94AB2AA
  # REGISTRY DEPLOYED:
  # 0x704fc210072E90E6f3e9742c0b9a3635Dd195086



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
  # 0x95Bcd67C0Da583797D6191DAcD9624F22d252C24
  # STEP TWO: Facotry Deployed: 
  # 0x484e62580350F745a93Ce0B92A4159B21AF8994d
  # STEP THREE: Messenger Deployed: 
  # 0x023510b8f092e5155386240e6a160214a4208430
  # REGISTRY DEPLOYED:
  # 0x1eaFFC69302E8402B4052ccbe1a7F2D239A3f5f4

