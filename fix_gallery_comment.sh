#!/usr/bin/env bash
# fix_gallery_comment.sh — Remove illegal JSX comment between props in Gallery.tsx
set -e

FILE="src/components/Gallery.tsx"
[[ ! -f "$FILE" ]] && echo "❌  $FILE not found — run from project root." && exit 1

# Remove the offending comment line (JSX comments cannot appear between JSX props)
sed -i '/{\/\* UPGRADE-3: entranceDelay creates the waterfall cascade \*\/}/d' "$FILE"

echo "✅  Fixed: removed JSX comment from between props in $FILE"
echo "    Running build check..."

npm run build && echo "✅  Build passed." || echo "❌  Build still failing — check output above."
