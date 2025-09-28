#!/bin/bash

configure_bitcoin_cli() {
  local BITCOIN_CLI="bitcoin-cli"

  if [[ -n $RPC_USER && -n $RPC_PASSWORD && -n $RPC_HOST && -n $RPC_PORT ]]; then
    BITCOIN_CLI="bitcoin-cli -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcconnect=$RPC_HOST:$RPC_PORT"
  fi

  echo "$BITCOIN_CLI"
}