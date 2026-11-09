# Common Core

Shared build, release, CI and issue setup for every Gogo add-on: Come & Get It, Connoisseur & Restocker, Control Freak, GogoLoot, Good to Go, Magic Eraser, Open Sesame, Play It Forward, Pretty Wide Quest Log, Thanks for the Buff, Tracking Eye and Water Dispenser. It also holds the [Add-on Guide](Add-on%20Guide/Start%20Here.md), the prompts and rules every add-on is built and reviewed by.

Nothing in this repo ships to players.

## What lives where

Some files can be shared by reference and some can't, and that decides the layout.

| File | Where it lives | Why |
|---|---|---|
| Add-on Guide | `Add-on Guide/` here | One copy of the pipeline prompts, the Style Guide and the master list. Sessions read it from a local clone at `~/Common-Core`, which each session's prep pulls; start at `Add-on Guide/Start Here.md`. |
| Release logic | `.github/workflows/package.yml` here | Reusable workflow; each add-on calls it, so a fix here reaches every add-on. |
| CI checks | `.github/workflows/ci.yml` here | Reusable workflow, same reason. |
| Action version updates | `.github/dependabot.yml` here | The pinned actions are only referenced here, so only this repo needs Dependabot. |
| Thin callers, `.gitignore`, `.gitattributes` | `addon-files/` here, **copied** into each add-on | GitHub only runs workflows and git only reads these two files from the add-on's own repo. CI fails if an add-on's copy differs from the one here. |
| Issue forms (Defect, Request) and the issue-labels caller | `addon-files/` here, **copied** into each add-on | GitHub only reads issue forms and runs workflows from the add-on's own repo. Same CI check as above. |
| Issue labeling logic | `.github/workflows/issue-labels.yml` here | Reusable workflow; each add-on calls it. |
| Project board sweep | `.github/workflows/project-board.yml` here | A scheduled sweep (hourly on paper, every few hours in practice) adds every add-on's issues and PRs from the last two days to the [project board](https://github.com/users/Gogo1951/projects/6). It needs a personal token, and a personal account can't share a secret across repos, so it runs only here. |
| Issue page links (`.github/ISSUE_TEMPLATE/config.yml`) | Each add-on, starting from `addon-starters/` here | Different in every add-on: its own CurseForge page. |
| Issue labels | Each repo's labels, set by `scripts/sync-labels.sh` here | Labels aren't files, so the script is the source of truth. |
| `.pkgmeta`, `.luacheckrc`, TOCs, `LICENSE` | Each add-on | Different in every add-on: package name, libraries, the WoW globals each one reads. CI still checks `.pkgmeta` against `Includes/Libraries/`. |

## What CI checks

`ci.yml` runs on every pull request and every push to `main`. Every check runs even when one fails, so one run lists everything.

1. **Shared files match** `addon-files/` exactly.
2. **Line endings are LF** in git, as `.gitattributes` requires.
3. **Every vendored library is in `.pkgmeta`**, and every `.pkgmeta` external is committed. A library missing from `.pkgmeta` is never updated by a release.
4. **Lua 5.1 syntax** (`luac5.1 -p`) for every Lua file outside `Includes/`.
5. **luacheck** with the add-on's own `.luacheckrc`.
6. **StyLua** `--check --syntax lua51`, default configuration, `Includes/` skipped. Pinned to StyLua 2.5.2 so a new release can't reformat code under you; bump `STYLUA_VERSION` and `STYLUA_SHA256` in `ci.yml` together.
7. **Offline tests**: `lua5.1 Tests/Run.lua`, when the add-on has one. It must exit non-zero on any failure.

**Why Lua 5.1:** WoW embeds Lua 5.1. Code or tests that only work on 5.2 or later (`table.unpack`, `goto`, `loadfile` with an environment, `//`) pass on a newer interpreter and fail in game, so CI never uses one.

## Releasing

Unchanged from before: push a tag and the add-on's `package.yml` calls the one here, which refreshes `Includes/Libraries/` from `.pkgmeta`, commits that to `main`, moves the tag onto the commit, and uploads to CurseForge and Wago.

**Dry run:** in an add-on's Actions tab, open "Package and release" and click "Run workflow". It builds the zip without committing, moving a tag, or uploading anything. Use it after changing the release workflow here.

The release workflow deliberately has no GitHub token; the comment in `package.yml` explains why. Never add one.

## Changing something

- **The Add-on Guide:** a pass that proposes a guide change ends with a triage line; paste it into a session launched in `~/Common-Core`, where `Add-on Guide/References/Guide Feedback Triage Prompt.md` applies what you approve and pushes it to `main`. The guide is public, so no real names, personal emails or user-named local paths go in it.
- **Release or CI logic:** edit `.github/workflows/` here. Every add-on picks it up on its next run, so try a dry run (and a CI run on any add-on) afterwards.
- **A shared file** (`addon-files/`): edit it here, then copy it into every add-on and commit there. `scripts/sync-addon-files.sh ../Open-Sesame ../GogoLoot ...` does the copy. Until an add-on has the new copy, its CI fails the "Shared files match" check, which is the reminder.
- **Issue forms:** edit them in `addon-files/.github/ISSUE_TEMPLATE/`, copy them into this repo's own `.github/ISSUE_TEMPLATE/` (which runs Common-Core's own "New issue" page), then sync the add-ons as above.
- **Issue labels:** edit the list in `scripts/sync-labels.sh`, then run it on Common-Core and every add-on: `scripts/sync-labels.sh Gogo1951/Common-Core Gogo1951/Open-Sesame Gogo1951/GogoLoot ...`. It deletes every label not in the list, so a renamed label is a delete plus a create, and the open issues need relabeling afterwards.
- **A new add-on:** run the sync script on it, copy `addon-starters/.github/ISSUE_TEMPLATE/config.yml` in and fill in its name, CurseForge page and Discord invite, run `scripts/sync-labels.sh` on it, add a `.luacheckrc`, and set the repo settings below.

## Issues

Every add-on's "New issue" page offers two forms, plus a blank issue and links to Discord and the add-on's CurseForge page.

- **Defect** (label `Type: Defect`): Issue Description, Issue Type, Steps to Reproduce, Screenshots, Game Flavor, then four boxes for the add-on's Diagnostic Tools reports. Issue Type picks the Area: Data adds `Area: Data`, Copywriting and Localization add `Area: Localization`, and anything else, blank included, adds `Area: Features`.
- **Request** (label `Type: Enhancement`): Your Request and Why It Matters to You. Suggestions and feedback both go here.

**Every issue carries at least one Area, one Priority and one Type label.** Areas follow the add-on's top-level folders (Data, Diagnostics, Features, Includes, Localization, Options, Tests) plus Packaging for the TOCs, `.pkgmeta` and CI. The issue-labels workflow fills in whichever group a new issue opens without: the Area from Issue Type, `Priority: 2 Normal`, and `Type: Question` for a blank issue. Triage corrects the defaults. The meta labels (`Epic`, `Blocked`, `Needs Info`, `Keep Open`, `Duplicate`) are optional. No other labels exist on any repo.

Every issue and pull request lands on the [project board](https://github.com/users/Gogo1951/projects/6). Both forms name it (`projects: ["Gogo1951/6"]`), which adds your own issues at once; GitHub ignores that key for anyone without write access to the board, so `project-board.yml` adds everything else, PRs included, on its next run. GitHub throttles that hourly schedule to one run every several hours, so each run looks back two days, which rides out long gaps. Re-adding an item already on the board changes nothing, but an item removed from the board by hand comes back until it is two days old. It needs the `PROJECT_TOKEN` secret on this repo: a classic personal access token with the `project` scope. To backfill, run "Project board" from the Actions tab with an early "since" date.

## Repo settings every add-on uses

- **Ruleset "Protect main"** on the default branch: blocks force pushes and deletion. Pull requests and status checks are not required, because the release workflow pushes the vendored-library commit straight to `main`.
- **Security:** Dependabot alerts and security updates, secret scanning with push protection, private vulnerability reporting, CodeQL default setup.
- **Actions:** workflow token is read-only by default; each workflow asks for what it needs.
- **Merging:** squash merge only; head branches are deleted automatically.
