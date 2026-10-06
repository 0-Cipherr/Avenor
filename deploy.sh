#!/bin/bash

source .env

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv

forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --broadcast \
  --etherscan-api-key "$ETHERSCAN_API" \
  --verify \
  -vvvv


echo "Both deployments finished"


: <<'Comment'
== Logs Base  ==
  STEP ONE: Strategy Adapter deployed: 
  0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141
  STEP TWO: Facotry Deployed: 
  0xdaE97900D4B184c5D2012dcdB658c008966466DD
  STEP THREE: Messenger Deployed: 
  0x238213078DbD09f2D15F4c14c02300FA1b2A81BB
  STEP ONE: Strategy Adapter deployed: 
  0x807183e1a54cDC36cab90E89432A6b1fB44979f0
  STEP TWO: Facotry Deployed: 
  0x28f4033eBE5E8c02BDD7D23519c740888fcbC7Cb
  STEP THREE: Messenger Deployed: 
  0x63704aC979c22b430D4D3F6bB60D77c873673FaC
