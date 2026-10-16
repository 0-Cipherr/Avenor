#!/bin/bash

set -e
source .env
forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --password-file .password \
  --broadcast \
  -vvvv 2>&1 | grep -vE "Setting up|Estimated gas|Sending transactions|Estimated total gas|Nonce:|Hash:|Transaction:|Deployed to:|Receipt:|Base fee:|Gas used:"


forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
  --rpc-url "$ARB_SEPOLIA_RPC" \
  --account Avenor_Multi \
  --password-file .password \
  --broadcast \
  -vvvv 2>&1 | grep -vE "Setting up|Estimated gas|Sending transactions|Estimated total gas|Nonce:|Hash:|Transaction:|Deployed to:|Receipt:|Base fee:|Gas used:"


# > /dev/null ignores transaction hashes 

# grep -vE "" - ignores all outputs containg such i nthe stirng