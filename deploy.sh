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
  # 0xD4B4dAeCBf901E7B78d24Fd02097A8Fe59A42C9F
  # STEP TWO: Facotry Deployed: 
  # 0x7823C895293Cd33d80eb815b88DA9B34e4D3B0a4
  # STEP THREE: Messenger Deployed: 
  # 0x3EE75F1f777b734375Bb7055dC8cB2C85Af8941b
  # REGISTRY DEPLOYED:
  # 0x5Ba11c7E633de457AE596bff7BAE9Eb763Cf37e7





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
  # 0x802873508817eC51dFAAd7a19fA9fF59548bd19a
  # STEP TWO: Facotry Deployed: 
  # 0x458cfd1e0BBf02d01d14100ffF566835e14786aF
  # STEP THREE: Messenger Deployed: 
  # 0x7BA1Ee123EBFf5310Ebd607b17229Baa86Ece196
  # REGISTRY DEPLOYED:
  # 0x51f79Da3f0556E4Dc317558D2671518151537ba9

