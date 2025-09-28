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

OUTFILE="opreturns.jsonl"   # change path/name as you wish
> "$OUTFILE"                # truncate file at start

echo "Scanning blocks $START..$END for OP_RETURN (writing to $OUTFILE)..."

for ((h=START; h<=END; h++)); do
  bh=$($CLI getblockhash "$h") || { echo "failed getblockhash $h"; continue; }
  blk=$($CLI getblock "$bh" 2) || { echo "failed getblock $bh"; continue; }

  # Grab relevant fields (height, blockhash, txid, vout index, asm, hex)
  # Output as tab-separated: height \t blockhash \t txid \t vout \t asm \t hex
  echo "$blk" | jq -r \
    --argjson height "$h" \
    --arg blockhash "$bh" '
    .tx[]
    | {txid: .txid, vout: .vout}
    | .vout[]
    | select(.scriptPubKey.type=="nulldata" or (.scriptPubKey.asm | test("OP_RETURN")))
    | [
        $height,
        $blockhash,
        .txid?,
        .n,
        .scriptPubKey.asm,
        .scriptPubKey.hex
      ]
    | @tsv
  ' | while IFS=$'\t' read height blockhash txid vout asm hex; do
      # decode hex payload after the OP_RETURN opcode (0x6a)
      # This just strips leading '6a...' and decodes the remainder as UTF-8 if printable.
      payload_hex="${hex#6a}"   # strip leading '6a' (OP_RETURN)
      # For OP_PUSHDATA, the length byte(s) come next; try to skip them heuristically:
      # remove first 2 chars (length) if payload length > 0:
      if [[ ${#payload_hex} -gt 2 ]]; then
        # simple skip of first length byte
        len_hex=${payload_hex:0:2}
        payload_hex=${payload_hex:2}
      fi
      decoded=""
      if [[ -n "$payload_hex" ]]; then
        # attempt to decode hex to string safely
        decoded=$(echo "$payload_hex" | xxd -r -p 2>/dev/null | LC_ALL=C tr -cd '\11\12\15\40-\176')
      fi
      jq -n --arg height "$height" \
            --arg blockhash "$blockhash" \
            --arg txid "$txid" \
            --arg vout "$vout" \
            --arg asm "$asm" \
            --arg hex "$hex" \
            --arg decoded "$decoded" \
            '{height:($height|tonumber),
              blockhash:$blockhash,
              txid:$txid,
              vout_index:($vout|tonumber),
              asm:$asm,
              hex:$hex,
              decoded:$decoded}' >> "$OUTFILE"
    done
done

echo "Done. Results written to $OUTFILE"