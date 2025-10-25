#!/bin/bash
set -e

# === Proof of Human Work Auto-Signer ===
# Regenerates hashes, canonical JSON, signatures, and homepage hash line

JSON_PATH="pohw/verify/index.json"
SIG_PATH="pohw/verify/index.sig.b64"
HASH_PATH="HASH.txt"
INDEX_PATH="index.html"

echo "== Canonicalizing JSON =="
jq -S . "$JSON_PATH" > "$JSON_PATH.tmp" && mv "$JSON_PATH.tmp" "$JSON_PATH"

echo "== Hashing canonical JSON =="
HASH=$(sha256sum "$JSON_PATH" | awk '{print $1}')
echo "Hash: $HASH"

echo "== Signing canonical JSON with OpenSSL =="
openssl dgst -sha256 -sign ~/.ssh/id_signer.pem -out pohw/verify/index.sig.bin "$JSON_PATH"
openssl base64 -in pohw/verify/index.sig.bin -out "$SIG_PATH"
echo "Signature written to $SIG_PATH"

echo "== Recording hash =="
{
  echo "canonical JSON : $HASH"
  date "+timestamp : %Y-%m-%dT%H:%M:%SZ"
} > "$HASH_PATH"

echo "== Updating homepage hash =="
if grep -q "hash :" "$INDEX_PATH"; then
  sed -i "s|hash : [0-9a-fx]*|hash : 0x$HASH|g" "$INDEX_PATH"
else
  echo "No hash line found in index.html — skipped updating."
fi

echo "== Committing and pushing updates =="
git add "$JSON_PATH" "$SIG_PATH" "$HASH_PATH" "$INDEX_PATH"
git commit -m "Auto-sign and update homepage hash ($(date +%Y-%m-%d))" || true
git push

echo "== Done: new signature + homepage hash published =="