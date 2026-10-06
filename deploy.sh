#!/bin/bash

set -e
source .env

echo "=== Deploying to Base Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv

echo "=== Base Sepolia deployment complete ==="
echo "=== Deploying to Arbitrum Sepolia ==="

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv

echo "=== Both deployments finished successfully ==="




# == Logs Base ==
#   STEP ONE: Strategy Adapter deployed: 
#   0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141
#   STEP TWO: Facotry Deployed: 
#   0xdaE97900D4B184c5D2012dcdB658c008966466DD
#   STEP THREE: Messenger Deployed: 
#   0x238213078DbD09f2D15F4c14c02300FA1b2A81BB
#   STEP ONE: Strategy Adapter deployed: 
#   0x81BC905d4Ba48c702Eb82B4cfE8726bBCE819Bad
#   STEP TWO: Facotry Deployed: 
#   0xdb595a4Aa2A760C32D8bfebeE44caE326818529C
#   STEP THREE: Messenger Deployed: 
#   0x3a2108DF84aa9c1d278533d762b3b2f9A6555331


# == Logs ARB ==
#   STEP ONE: Strategy Adapter deployed: 
#   0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141
#   STEP TWO: Facotry Deployed: 
#   0xdaE97900D4B184c5D2012dcdB658c008966466DD
#   STEP THREE: Messenger Deployed: 
#   0x238213078DbD09f2D15F4c14c02300FA1b2A81BB
#   STEP ONE: Strategy Adapter deployed: 
#   0x657D72c66aDbD11281fa4341B68C00b3bd589649
#   STEP TWO: Facotry Deployed: 
#   0x205FF79CAB7e110cDa60Cb23F2826Af6016CE2Bb
#   STEP THREE: Messenger Deployed: 
#   0xCd3A41143Fc01B30CaB00D55E6f45687dca7d480

# ## Setting up 1 EVM.

