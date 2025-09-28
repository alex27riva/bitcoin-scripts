#!/bin/bash
# get_transaction.sh
# Usage: ./get_transaction.sh <txid>

txid=$1

# shellcheck disable=SC1091
source src/connection.sh

BITCOIN_CLI=$(configure_bitcoin_cli)

raw=$($BITCOIN_CLI getrawtransaction "$txid")

decoded_tx=$($BITCOIN_CLI decoderawtransaction "$raw")

output_value=$(echo "$decoded_tx" | jq -r '.vout | map(.value) | add')

echo

for key in txid hash version size vsize weight locktime; do
  echo "$key: $( echo "$decoded_tx" | jq -r ".$key")"
done

echo -e "\nOutputs value $output_value ₿" 
