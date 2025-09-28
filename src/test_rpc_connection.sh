#!/bin/bash
# test_rpc_connections.sh
# Usage: ./test_rcp_connection.sh

BITCOIN_CLI="bitcoin-cli -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcconnect=$RPC_HOST:$RPC_PORT"

# test connection
$BITCOIN_CLI getrpcinfo >/dev/null

result=$?

if [[ $result == 0 ]]; then
    echo "✅ Connection successful"
else
    echo " ❌ Connection error"
fi