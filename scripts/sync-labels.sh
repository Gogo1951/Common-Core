#!/bin/bash
# Makes each repo's issue labels exactly the set below: creates or updates these
# and DELETES every other label (deleting a label also removes it from any issue
# or pull request that has it). The issue forms in addon-files/ and the
# issue-labels workflow depend on these names, so change them together.
# Needs the GitHub CLI (gh), signed in with access to each repo.
# Usage: scripts/sync-labels.sh Gogo1951/Open-Sesame Gogo1951/GogoLoot ...
set -euo pipefail
[ $# -gt 0 ] || { echo "Usage: $0 <owner/repo> [...]"; exit 1; }

# name|color|description
LABELS=(
  "Defect|B60205|Something is broken or not working the way it should."
  "Feedback|1D76DB|A suggestion for something new or changed, or feedback on how things are working."
  "Area: Code|D4C5F9|Something errors, freezes, or stops working."
  "Area: Copy|D4C5F9|Text is wrong, unclear, or misspelled."
  "Area: Data|D4C5F9|Wrong item, spell, NPC, or numbers."
  "Area: Interface Design|D4C5F9|Something looks wrong or is hard to use."
  "Area: Localization|D4C5F9|A translation is wrong or missing."
)

# Label names in a REST path need percent-encoding ("Area: Code" -> "Area%3A%20Code").
urlencode() {
  local s="$1" out="" c i
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) out+="$(printf '%%%02X' "'$c")" ;;
    esac
  done
  printf '%s' "$out"
}

# Uses the REST API (gh api) throughout rather than gh label list/delete.
for repo in "$@"; do
  echo "== $repo"
  keep=()
  for entry in "${LABELS[@]}"; do
    IFS='|' read -r name color description <<<"$entry"
    gh label create "$name" --repo "$repo" --color "$color" --description "$description" --force >/dev/null
    echo "  set     $name"
    keep+=("$name")
  done
  gh api --paginate "repos/$repo/labels?per_page=100" --jq '.[].name' | while IFS= read -r existing; do
    for name in "${keep[@]}"; do
      [ "$existing" = "$name" ] && continue 2
    done
    gh api --method DELETE "repos/$repo/labels/$(urlencode "$existing")" >/dev/null
    echo "  deleted $existing"
  done
done
