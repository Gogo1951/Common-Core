#!/bin/bash
# Copies Common-Core's shared kits (addon-kits/<Kit>/) into one or more add-on
# clones, overwriting what is there. Commit the result in each add-on.
#
# A kit's folder mirrors the add-on's own paths (addon-kits/Options-Kit/Options/
# Options-Kit.lua lands at Options/Options-Kit.lua). An add-on has adopted a kit
# once any of the kit's files exists in it; a plain run refreshes every kit each
# add-on has adopted and leaves the rest alone. --adopt <Kit> copies that kit in
# for the first time (then add its file to the TOC, as the kit's spec says).
#
# Usage: scripts/sync-addon-kits.sh [--adopt Options-Kit] ../Magic-Eraser ../GogoLoot ...
set -euo pipefail
KITS="$(cd "$(dirname "$0")/../addon-kits" && pwd)"
adopt=""
if [ "${1:-}" = "--adopt" ]; then
  adopt="${2:?--adopt needs a kit name}"
  [ -d "$KITS/$adopt" ] || { echo "No kit named $adopt in addon-kits/"; exit 1; }
  shift 2
fi
[ $# -gt 0 ] || { echo "Usage: $0 [--adopt <Kit>] <add-on folder> [...]"; exit 1; }
for target in "$@"; do
  [ -f "$target/.pkgmeta" ] || { echo "Skipping $target: no .pkgmeta, so not an add-on root"; continue; }
  for kit in "$KITS"/*/; do
    kit="${kit%/}"
    name="$(basename "$kit")"
    files="$(cd "$kit" && find . -type f | sed 's|^\./||')"
    adopted=""
    while IFS= read -r file; do
      [ -f "$target/$file" ] && adopted=1
    done <<< "$files"
    [ -n "$adopted" ] || [ "$name" = "$adopt" ] || continue
    while IFS= read -r file; do
      mkdir -p "$target/$(dirname "$file")"
      cp "$kit/$file" "$target/$file"
    done <<< "$files"
    echo "== $target: $name"
  done
  git -C "$target" status --short
done
