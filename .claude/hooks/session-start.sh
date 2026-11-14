#!/bin/bash
# Cloud sessions start on an auto-named claude/... branch. This repo works on
# main only (see CLAUDE.md), so move the checkout onto an up-to-date main.
set -uo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

git fetch -q origin main 2>/dev/null || { echo "session-start: could not fetch origin/main; check the branch before committing."; exit 0; }

branch="$(git symbolic-ref --short -q HEAD || echo DETACHED)"

if [ "$branch" != "main" ]; then
  # Never move off a branch holding uncommitted work or commits main lacks.
  if [ -n "$(git status --porcelain)" ] || [ -n "$(git rev-list origin/main..HEAD 2>/dev/null)" ]; then
    echo "session-start: on '$branch' with work not on main; left in place. Bring it to main before continuing."
    exit 0
  fi
  git checkout -q -B main origin/main
  [ "$branch" != "DETACHED" ] && git branch -q -D "$branch" 2>/dev/null
  echo "session-start: switched from '$branch' to main (now at origin/main). Commit and push to origin main only."
else
  git merge -q --ff-only origin/main 2>/dev/null \
    && echo "session-start: on main, up to date with origin/main." \
    || echo "session-start: on main, but it has diverged from origin/main; sort that out before committing."
fi
exit 0
