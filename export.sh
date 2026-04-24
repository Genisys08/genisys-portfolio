#!/bin/bash

echo "Packaging Genisys project for Lovable..."

# We selectively tar only the vital source files, leaving behind node_modules and old scripts.
tar -czvf ~/storage/shared/genisys_export.tar.gz \
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
echo "Boom. Export complete!"
echo "Check the root of your phone's internal storage for 'genisys_export.tar.gz'."
