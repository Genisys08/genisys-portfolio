#!/usr/bin/env bash
# update_v2.sh — Safely upgrade an existing Genisys V1 install to V2.0.
# Preserves: public/images/  and  src/data/portfolioData.ts
# Run from inside this extracted V2 directory, pointing at your V1 project root.
#
# Usage:  ./update_v2.sh /path/to/your/v1/genisys
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /absolute/path/to/v1/genisys"
  exit 1
fi

DEST="$1"
SRC="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$DEST" ]; then
  echo "❌ Destination not found: $DEST"
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/.backup-v1-$STAMP"
echo "▸ Creating backup at $BACKUP"
mkdir -p "$BACKUP"
for keep in src public index.html package.json tailwind.config.ts vite.config.ts tsconfig.json postcss.config.js; do
  if [ -e "$DEST/$keep" ]; then cp -r "$DEST/$keep" "$BACKUP/"; fi
done

echo "▸ Preserving public/images and portfolioData.ts"
PRES="$(mktemp -d)"
[ -d "$DEST/public/images" ] && cp -r "$DEST/public/images" "$PRES/images"
[ -f "$DEST/src/data/portfolioData.ts" ] && cp "$DEST/src/data/portfolioData.ts" "$PRES/portfolioData.ts"

echo "▸ Wiping V1 source (src/, root configs)"
rm -rf "$DEST/src"
for f in index.html package.json package-lock.json tailwind.config.ts vite.config.ts tsconfig.json postcss.config.js README.md .gitignore; do
  rm -f "$DEST/$f"
done

echo "▸ Installing V2 files"
cp -r "$SRC/src" "$DEST/src"
cp -r "$SRC/public/." "$DEST/public/"
for f in index.html package.json tailwind.config.ts vite.config.ts tsconfig.json postcss.config.js README.md .gitignore; do
  cp "$SRC/$f" "$DEST/$f"
done

echo "▸ Restoring preserved assets"
[ -d "$PRES/images" ] && mkdir -p "$DEST/public/images" && cp -r "$PRES/images/." "$DEST/public/images/"
[ -f "$PRES/portfolioData.ts" ] && cp "$PRES/portfolioData.ts" "$DEST/src/data/portfolioData.ts"
rm -rf "$PRES"

echo "▸ Installing dependencies"
cd "$DEST" && npm install

echo "✓ Upgrade complete. Backup: $BACKUP"
echo "  Next: cd \"$DEST\" && npm run dev"
