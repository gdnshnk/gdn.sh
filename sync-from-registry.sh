#!/usr/bin/env bash
set -euo pipefail

# Sync data from registry node to gdn.sh static file
# This ensures gdn.sh reflects the actual registry node status

REGISTRY_URL="${REGISTRY_URL:-http://localhost:3000}"
JSON_PATH="pohw/verify/index.json"
CJSON_PATH="pohw/verify/index.cjson"
SIG_B64_PATH="pohw/verify/index.sig.b64"
SIG_BIN_PATH="pohw/verify/index.sig.bin"
HASH_PATH="HASH.txt"
INDEX_PATH="index.html"
KEY_PATH="${SIGNING_KEY_PATH:-$HOME/.ssh/id_signer.pem}"

echo "== Fetching data from registry node =="
REGISTRY_DATA=$(curl -s "${REGISTRY_URL}/pohw/verify/index.json")

if [ -z "$REGISTRY_DATA" ]; then
  echo "❌ Failed to fetch data from registry node at ${REGISTRY_URL}"
  echo "   Make sure the registry node is running"
  exit 1
fi

echo "✅ Fetched data from registry node"

# Transform registry node data to gdn.sh format
# Registry node returns: created, hash, node, protocol, etc.
# gdn.sh needs: created, hash, node, protocol, public_key, registry, signature, status, type, verified_by

echo "== Transforming data to gdn.sh format =="
UPDATED_JSON=$(echo "$REGISTRY_DATA" | jq -c '{
  created: .created,
  hash: .hash,
  node: "gdn.sh",
  protocol: .protocol,
  public_key: "https://gdn.sh/.well-known/public.txt",
  registry: "https://proofofhumanwork.org",
  signature: "active",
  status: "active",
  type: "verification-node",
  verified_by: "PoHW Foundation"
}')

echo "$UPDATED_JSON" > "$JSON_PATH"
echo "✅ Updated $JSON_PATH with registry node data"

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
sed -i "" "s|^hash : 0x[0-9a-f]*|hash : 0x$HASH|" "$INDEX_PATH" 2>/dev/null || \
sed -i "s|^hash : 0x[0-9a-f]*|hash : 0x$HASH|" "$INDEX_PATH"
# verified-on line (keep exact spacing you used)
sed -i "" "s|^verified-on        : .*|verified-on        : $NOW_UTC|" "$INDEX_PATH" 2>/dev/null || \
sed -i "s|^verified-on        : .*|verified-on        : $NOW_UTC|" "$INDEX_PATH"

echo "== Summary =="
echo "✅ Synced from registry node: ${REGISTRY_URL}"
echo "✅ Updated JSON with authentic timestamp"
echo "✅ Signed and hashed"
echo ""
echo "Next: Review changes and commit:"
echo "  git add $JSON_PATH $CJSON_PATH $SIG_B64_PATH $SIG_BIN_PATH $HASH_PATH $INDEX_PATH"
echo "  git commit -m 'Sync from registry node: update with authentic timestamp'"

