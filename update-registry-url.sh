#!/usr/bin/env bash
# Update the registry URL in the verification page
# Usage: ./update-registry-url.sh https://your-registry-url.com

set -euo pipefail

REGISTRY_URL="${1:-}"

if [ -z "$REGISTRY_URL" ]; then
  echo "Usage: ./update-registry-url.sh <registry-url>"
  echo "Example: ./update-registry-url.sh https://pohw-registry.railway.app"
  exit 1
fi

# Remove trailing slash
REGISTRY_URL="${REGISTRY_URL%/}"

VERIFY_PAGE="pohw/verify/index.html"

if [ ! -f "$VERIFY_PAGE" ]; then
  echo "Error: $VERIFY_PAGE not found"
  exit 1
fi

echo "Updating registry URL to: $REGISTRY_URL"

# Update the REGISTRY_URL constant
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s|const REGISTRY_URL = .*|const REGISTRY_URL = '${REGISTRY_URL}';|" "$VERIFY_PAGE"
else
  # Linux
  sed -i "s|const REGISTRY_URL = .*|const REGISTRY_URL = '${REGISTRY_URL}';|" "$VERIFY_PAGE"
fi

echo "✅ Updated $VERIFY_PAGE"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff $VERIFY_PAGE"
echo "  2. Commit: git add $VERIFY_PAGE && git commit -m 'Update registry URL to ${REGISTRY_URL}'"
echo "  3. Push: git push origin main"

