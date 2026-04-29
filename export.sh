#!/bin/bash

echo "Packaging Genisys project for AI..."

# We selectively tar only the vital source files, excluding node_modules, old scripts, and heavy audio files.
tar -czvf ~/storage/shared/genisys_export.tar.gz \
  --exclude='*.mp3' \
  --exclude='*.wav' \
  --exclude='*.ogg' \
  README.md \
  index.html \
  package.json \
  package-lock.json \
  postcss.config.js \
  public/ \
  src/ \
  tailwind.config.ts \
  tsconfig.json \
  vite.config.ts

echo "---------------------------------------------------"
echo "Boom. Export complete! Audio tracks successfully blocked from the payload."
echo "Check the root of your phone's internal storage for 'genisys_export.tar.gz'."
