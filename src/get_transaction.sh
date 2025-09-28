#!/bin/bash
# get_transaction.sh
# Usage: ./get_transaction.sh <txid>

BITCOIN_CLI="bitcoin-cli"
txid=$1

source src/connection.sh

BITCOIN_CLI=$(configure_bitcoin_cli)

raw=$($BITCOIN_CLI getrawtransaction "$txid")

decoded_tx=$($BITCOIN_CLI decoderawtransaction "$raw")

echo "$decoded_tx" | jq .