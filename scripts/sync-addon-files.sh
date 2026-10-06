#!/bin/bash
# Copies Common-Core's shared files (addon-files/) into one or more add-on clones,
# overwriting what is there. Commit the result in each add-on.
# Usage: scripts/sync-addon-files.sh ../Open-Sesame ../GogoLoot ...
set -euo pipefail
[ $# -gt 0 ] || { echo "Usage: $0 <add-on folder> [...]"; exit 1; }
SRC="$(cd "$(dirname "$0")/../addon-files" && pwd)"
for target in "$@"; do
  [ -f "$target/.pkgmeta" ] || { echo "Skipping $target: no .pkgmeta, so not an add-on root"; continue; }
  (cd "$SRC" && find . -type f) | while IFS= read -r file; do
    mkdir -p "$target/$(dirname "$file")"
    cp "$SRC/$file" "$target/$file"
  done
  echo "== $target"
  git -C "$target" status --short
done
