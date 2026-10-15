#!/usr/bin/env bash

set -Eeuo pipefail

# Always resolve project files relative to this script, not the caller's cwd.
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

if [[ ! -f .env ]]; then
  echo "Error: .env not found in the project directory." >&2
  exit 1
fi
source .env

if [[ -z "${BASE_SEPOLIA_RPC:-}" ]]; then
  echo "Error: BASE_SEPOLIA_RPC is missing from .env." >&2
  exit 1
fi
if [[ -z "${ARB_SEPOLIA_RPC:-}" ]]; then
  echo "Error: ARB_SEPOLIA_RPC is missing from .env." >&2
  exit 1
fi

# Accept the variable already referenced in this script, plus Foundry's usual name.
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-${ETHERSCAN_API:-}}"
if [[ -z "$ETHERSCAN_API_KEY" ]]; then
  echo "Error: set ETHERSCAN_API_KEY (or ETHERSCAN_API) in .env to enable verification." >&2
  exit 1
fi
if [[ ! -f .password ]]; then
  echo "Error: .password not found in the project directory." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to read Foundry's deployment records." >&2
  exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to check BaseScan/Etherscan verification status." >&2
  exit 1
fi

check_rpc() {
  local network_name="$1"
  local expected_chain_id="$2"
  local rpc_url="$3"
  local actual_chain_id

  echo "=== Checking $network_name RPC connection ==="
  if ! actual_chain_id="$(cast chain-id --rpc-url "$rpc_url")"; then
    echo "Error: could not connect to the $network_name RPC. Check its URL/provider in .env." >&2
    return 1
  fi
  if [[ "$actual_chain_id" != "$expected_chain_id" ]]; then
    echo "Error: $network_name RPC returned chain ID $actual_chain_id; expected $expected_chain_id." >&2
    return 1
  fi
}

registry_is_verified() {
  local address="$1"
  local chain_id="$2"
  local response

  response="$(curl -fsS --get 'https://api.etherscan.io/v2/api' \
    --data-urlencode "chainid=$chain_id" \
    --data-urlencode 'module=contract' \
    --data-urlencode 'action=getsourcecode' \
    --data-urlencode "address=$address" \
    --data-urlencode "apikey=$ETHERSCAN_API_KEY")" || return 1

  jq -e --arg name "VaultRegistry" \
    '.status == "1" and .result[0].ContractName == $name and .result[0].ABI != "Contract source code not verified"' \
    <<<"$response" >/dev/null
}

verify_deployments() {
  local network_name="$1"
  local chain_id="$2"
  local rpc_url="$3"
  local broadcast_file="broadcast/VaultInteractionScript.s.sol/$chain_id/run-latest.json"
  local contract_address

  if [[ ! -f "$broadcast_file" ]]; then
    echo "Error: no Foundry deployment record found at $broadcast_file." >&2
    return 1
  fi
  contract_address="$(jq -r '.transactions[] | select(.contractName == "VaultRegistry" and (.transactionType == "CREATE" or .transactionType == "CREATE2")) | .contractAddress' "$broadcast_file" | tail -n 1)"
  if [[ -z "$contract_address" || "$contract_address" == "null" ]]; then
    echo "Error: no VaultRegistry deployment found in $broadcast_file." >&2
    return 1
  fi
  if ! jq -e --arg address "$contract_address" \
    '[.transactions[] | select(.contractName == "VaultRegistry" and .contractAddress == $address and (.transactionType == "CREATE" or .transactionType == "CREATE2"))] | length == 1' \
    "$broadcast_file" >/dev/null; then
    echo "Error: could not identify a unique VaultRegistry deployment in $broadcast_file." >&2
    return 1
  fi

  if registry_is_verified "$contract_address" "$chain_id"; then
    echo "=== VaultRegistry at $contract_address is already verified on $network_name ==="
    return 0
  fi

  echo "=== Verifying only VaultRegistry at $contract_address on $network_name ==="
  if forge verify-contract "$contract_address" "src/VaultRegistry.sol:VaultRegistry" \
      --rpc-url "$rpc_url" \
      --chain "$chain_id" \
      --verifier etherscan \
      --etherscan-api-key "$ETHERSCAN_API_KEY" \
      --guess-constructor-args \
      --watch \
      -vvv; then
    return 0
  fi

  # Foundry also submits to Sourcify; its "contract not found" response can
  # occur even when Etherscan/BaseScan has accepted and published the source.
  if registry_is_verified "$contract_address" "$chain_id"; then
    echo "=== Etherscan/BaseScan confirms VaultRegistry verification; ignoring Sourcify lookup failure ==="
    return 0
  fi

  echo "Error: VaultRegistry verification was not confirmed by Etherscan/BaseScan." >&2
  return 1
}

deploy_and_verify() {
  local network_name="$1"
  local expected_chain_id="$2"
  local rpc_url="$3"

  check_rpc "$network_name" "$expected_chain_id" "$rpc_url"

  echo "=== Deploying on $network_name ==="
  forge script script/VaultInteractionScript.s.sol:VaultInteractionScript \
    --rpc-url "$rpc_url" \
    --chain-id "$expected_chain_id" \
    --account Avenor_Multi \
    --password-file .password \
    --broadcast \
    -vvv

  verify_deployments "$network_name" "$expected_chain_id" "$rpc_url"
  echo "=== $network_name deployment and verification complete ==="
}

verify_existing() {
  local network_name="$1"
  local chain_id="$2"
  local rpc_url="$3"

  check_rpc "$network_name" "$chain_id" "$rpc_url"
  verify_deployments "$network_name" "$chain_id" "$rpc_url"
}

case "${1:-}" in
  "")
    deploy_and_verify "Base Sepolia" 84532 "$BASE_SEPOLIA_RPC"
    deploy_and_verify "Arbitrum Sepolia" 421614 "$ARB_SEPOLIA_RPC"
    ;;
  --verify-existing)
    verify_existing "Base Sepolia" 84532 "$BASE_SEPOLIA_RPC"
    verify_existing "Arbitrum Sepolia" 421614 "$ARB_SEPOLIA_RPC"
    ;;
  *)
    echo "Usage: $0 [--verify-existing]" >&2
    exit 2
    ;;
esac

echo "=== Both networks finished successfully; verification results were awaited ==="




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

