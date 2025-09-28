#!/bin/bash
# get_genesis_block.sh
# Usage: ./get_genesis_block.sh


BITCOIN_CLI="bitcoin-cli"

if [[ -n $RPC_USER && -n $RPC_PASSWORD && -n $RPC_HOST && -n $RPC_PORT ]]; then
BITCOIN_CLI="bitcoin-cli -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcconnect=$RPC_HOST:$RPC_PORT"
fi

# Get first block hash
# shellcheck disable=SC2206
genesis_hash=$($BITCOIN_CLI getblockhash 0)

echo -e "Genesis hash: $genesis_hash \n"

# Get genesis block from hash
raw_genesis=$($BITCOIN_CLI getblock "$genesis_hash" 0)


echo "$raw_genesis" | xxd -p -r | hexdump -C
