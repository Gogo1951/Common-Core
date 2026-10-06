# Common Core

Shared build, release and CI setup for every Gogo add-on: Come and Get It, Connoisseur Restocker, Control Freak, GogoLoot, Magic Eraser, Open Sesame, Play It Forward, Thanks for the Buff, Tracking Eye and Water Dispenser.

There is no Lua here and nothing in this repo ships to players.

## What lives where

Some files can be shared by reference and some can't, and that decides the layout.

| File | Where it lives | Why |
|---|---|---|
| Release logic | `.github/workflows/package.yml` here | Reusable workflow; each add-on calls it, so a fix here reaches all ten. |
| CI checks | `.github/workflows/ci.yml` here | Reusable workflow, same reason. |
| Action version updates | `.github/dependabot.yml` here | The pinned actions are only referenced here, so only this repo needs Dependabot. |
| Thin callers, `.gitignore`, `.gitattributes` | `addon-files/` here, **copied** into each add-on | GitHub only runs workflows and git only reads these two files from the add-on's own repo. CI fails if an add-on's copy differs from the one here. |
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

- **Release or CI logic:** edit `.github/workflows/` here. Every add-on picks it up on its next run, so try a dry run (and a CI run on any add-on) afterwards.
- **A shared file** (`addon-files/`): edit it here, then copy it into every add-on and commit there. `scripts/sync-addon-files.sh ../Open-Sesame ../GogoLoot ...` does the copy. Until an add-on has the new copy, its CI fails the "Shared files match" check, which is the reminder.
- **A new add-on:** run the sync script on it, add a `.luacheckrc`, and set the repo settings below.

## Repo settings every add-on uses

- **Ruleset "Protect main"** on the default branch: blocks force pushes and deletion. Pull requests and status checks are not required, because the release workflow pushes the vendored-library commit straight to `main`.
- **Security:** Dependabot alerts and security updates, secret scanning with push protection, private vulnerability reporting, CodeQL default setup.
- **Actions:** workflow token is read-only by default; each workflow asks for what it needs.
- **Merging:** squash merge only; head branches are deleted automatically.
