#!/bin/bash
# get_genesis_block.sh
# Usage: ./get_genesis_block.sh

source src/connection.sh

BITCOIN_CLI=$(configure_bitcoin_cli)

# Get first block hash
# shellcheck disable=SC2206
genesis_hash=$($BITCOIN_CLI getblockhash 0)

echo -e "Genesis hash: $genesis_hash \n"

# Get genesis block from hash
raw_genesis=$($BITCOIN_CLI getblock "$genesis_hash" 0)


echo "$raw_genesis" | xxd -p -r | hexdump -C
