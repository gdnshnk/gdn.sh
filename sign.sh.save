#!/bin/bash
set -e

# === Proof of Human Work Auto-Signer (Full Version) ===
# regenerates hashes, canonical JSON, signatures, and homepage hash line

JSON_PATH="pohw/verify/index.json"
CJSON_PATH="pohw/verify/index.cjson"
SIG_PATH="pohw/verify/index.cjson.sig"
HASH_PATH="HASH.txt"
INDEX_PATH="index.html"

echo "→ Canonicalizing $JSON_PATH"
jq -cS . "$JSON_PATH" > "$CJSON_PATH"

echo "→ Hashing canonical JSON"
HASH=$(shasum -a 256 "$CJSON_PATH" | awk '{print $1}')
echo "hash : $HASH"

echo "→ Signing canonical JSON with SSH key"
ssh-keygen -Y sign -f ~/.ssh/id_ed25519 -n pohw "$CJSON_PATH"

echo "→ Recording hash"
{
  echo "canonical JSON : $HASH"
  date +"timestamp : %Y-%m-%dT%H:%M:%SZ"
} > "$HASH_PATH"

# --- update homepage hash ---
echo "→ Updating homepage hash in $INDEX_PATH"
if grep -q "hash :" "$INDEX_PATH"; then
  # replace existing hash line
  sed -i '' "s|hash : 0x[0-9a-fA-F]*|hash : 0x$HASH|" "$INDEX_PATH"
else
  echo "⚠️  No 'hash :' line found in index.html — skipped updating."
fi

echo "→ Committing and pushing updates"
git add "$CJSON_PATH" "$SIG_PATH" "$HASH_PATH" "$INDEX_PATH"
git commit -m "Auto-sign and update homepage hash ($(date +%Y-%m-%d))"
git push

echo "✅ Done: new signature + homepage hash published"
