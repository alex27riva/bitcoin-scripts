#!/bin/bash
# find_opreturn_rpc.sh
# Usage: ./find_opreturn_rpc.sh <start_height> <end_height> [--testnet]

START=${1:-0}
END=${2:-$(bitcoin-cli getblockcount)}
NETFLAG="$3"   # flag for using testnet

CLI="bitcoin-cli"
if [ "$NETFLAG" = "--testnet" ]; then
  CLI="bitcoin-cli -testnet4"
fi

OUTFILE="opreturns.jsonl"
> "$OUTFILE"                # truncate file at start

echo "Scanning blocks $START..$END for OP_RETURN (writing to $OUTFILE)..."

for ((h=START; h<=END; h++)); do
  bh=$($CLI getblockhash "$h") || { echo "failed getblockhash $h"; continue; }
  blk=$($CLI getblock "$bh" 2) || { echo "failed getblock $bh"; continue; }

  echo "$blk" | jq -r \
    --argjson height "$h" \
    --arg blockhash "$bh" '
    .tx[]
    | {txid: .txid, vout: .vout}
    | .vout[]
    | select(.scriptPubKey.type=="nulldata" or (.scriptPubKey.asm | test("OP_RETURN")))
    | {
        height: $height,
        blockhash: $blockhash,
        txid: .txid?,
        vout_index: .n,
        asm: .scriptPubKey.asm,
        hex: .scriptPubKey.hex
      }
  ' >> "$OUTFILE"
done

echo "Done. Results written to $OUTFILE"
