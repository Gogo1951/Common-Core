#!/bin/bash
# Makes each repo's issue labels exactly the set below: creates or updates these
# and DELETES every other label (deleting a label also removes it from any issue
# or pull request that has it). The issue forms in addon-files/ and the
# issue-labels workflow depend on these names, so change them together.
# Every issue carries at least one Area, one Priority and one Type label; the
# issue-labels workflow fills in any group a new issue opens without.
# Needs the GitHub CLI (gh), signed in with access to each repo.
# Usage: scripts/sync-labels.sh Gogo1951/Open-Sesame Gogo1951/GogoLoot ...
set -euo pipefail
[ $# -gt 0 ] || { echo "Usage: $0 <owner/repo> [...]"; exit 1; }

# name|color|description
LABELS=(
  # Area: where in the add-on, one per top-level folder
  "Area: Data|0080FF|Data/: flavor folders, constants, default settings. Wrong IDs, items, spells, NPCs, numbers."
  "Area: Diagnostics|0080FF|Diagnostics/: the Diagnostic Tools panel, its reports, and the Event Log."
  "Area: Features|0080FF|Features/: core, event dispatcher, feature logic, announcements, mini-map button."
  "Area: Includes|0080FF|Includes/: vendored libraries, icon, art, and sounds."
  "Area: Localization|0080FF|Locales/: translations that are wrong, missing, or too long."
  "Area: Options|0080FF|Options/: the settings panel, profiles, and Feedback & Support."
  "Area: Tests|0080FF|Tests/: offline tests."
  "Area: Packaging|0080FF|TOCs, .pkgmeta, CI, and the release workflow. The files at the repo root."
  # Priority
  "Priority: 0 Critical|FF0080|Lua errors on load, a broken release, or a dead feature on a live client. Drop everything."
  "Priority: 1 High|FF3399|Ships in the next release."
  "Priority: 2 Normal|FF80BF|Standard backlog. Most issues live here."
  "Priority: 3 Low|FFCCE6|Nice-to-have, or captured for the record."
  # Type: what kind of work
  "Type: Defect|00FF80|Something is broken, errors, or regressed."
  "Type: New Feature|00FF80|Net-new functionality."
  "Type: Enhancement|00FF80|Improvement to an existing feature."
  "Type: Design|00FF80|Looks wrong or is hard to use: layout, spacing, colors, icons, the infographic."
  "Type: Copywriting|00FF80|Text that is wrong, unclear, or misspelled, in game or in the README."
  "Type: Documentation|00FF80|README-Technical, README-Notes, README-Testing, code comments."
  "Type: Refactor|00FF80|Internal cleanup with no behavior change."
  "Type: Maintenance|00FF80|Interface version bumps, library updates, new client support, release chores."
  "Type: Research|00FF80|Investigation before work can start: APIs, data sources, other add-ons."
  "Type: Question|00FF80|Needs an answer before work can begin."
  # Meta
  "Epic|FFFF00|Parent issue tracking several sub-issues. Use sparingly."
  "Blocked|FFFF00|Waiting on something outside the add-on: a Blizzard fix, a library, another repo."
  "Needs Info|FFFF00|Waiting on the reporter for steps, game flavor, or Diagnostics reports."
  "Keep Open|FFFF00|Long-running tracker or known-issue placeholder. Never auto-closed."
  "Duplicate|FFFF00|Closed in favor of another issue. Link it in the closing comment."
)

# Label names in a REST path need percent-encoding ("Area: Data" -> "Area%3A%20Data").
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
