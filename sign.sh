#!/usr/bin/env bash
set -euo pipefail

JSON_PATH="pohw/verify/index.json"
CJSON_PATH="pohw/verify/index.cjson"
SIG_B64_PATH="pohw/verify/index.sig.b64"
SIG_BIN_PATH="pohw/verify/index.sig.bin"
HASH_PATH="HASH.txt"
INDEX_PATH="index.html"
KEY_PATH="${SIGNING_KEY_PATH:-$HOME/.ssh/id_signer.pem}"

echo "== Canonicalizing JSON =="
jq -cS . "$JSON_PATH" > "$CJSON_PATH"

echo "== Hashing canonical JSON =="
HASH=$(openssl dgst -sha256 "$CJSON_PATH" | awk '{print $2}')
echo "Hash: $HASH"

echo "== Signing canonical JSON with OpenSSL =="
# write base64 signature
openssl dgst -sha256 -sign "$KEY_PATH" "$CJSON_PATH" | base64 > "$SIG_B64_PATH"
# also write binary signature for the verify command on the site
base64 -d < "$SIG_B64_PATH" > "$SIG_BIN_PATH"
echo "Signature written to $SIG_B64_PATH and $SIG_BIN_PATH"

echo "== Recording hash =="
printf "canonical JSON : %s\n" "$HASH" > "$HASH_PATH"
printf "timestamp : %s\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> "$HASH_PATH"

echo "== Updating homepage hash & verified-on =="
NOW_UTC="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
# hash line
sed -i "s|^hash : 0x[0-9a-f]*|hash : 0x$HASH|" "$INDEX_PATH"
# verified-on line (keep exact spacing you used)
sed -i "s|^verified-on        : .*|verified-on        : $NOW_UTC|" "$INDEX_PATH"

echo "== Committing =="
git add "$JSON_PATH" "$CJSON_PATH" "$SIG_B64_PATH" "$SIG_BIN_PATH" "$HASH_PATH" "$INDEX_PATH"
git commit -m "Auto-sign and update homepage hash ($(date -u +'%Y-%m-%d'))" || true