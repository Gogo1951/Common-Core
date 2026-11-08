# WoW Add-on README-Testing Generation (Editing, `README-Testing.md`)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `README-Testing generation`. Write scope: **`README-Testing.md` only.**

**This prompt is the request.** Pasted on its own, it means: run the whole pass now and regenerate the launch folder's `README-Testing.md` by the rules below. Never ask whether to run it.

The test plan for volunteer testers. They are players, not developers, and every minute they spend reading is a minute not spent testing. **Short beats complete.** The plan points them at what matters; the small bugs surface from players anyway.

Run it before handing a build to testers. Their testing is what `08 - Prelaunch Review.md` presumes done.

## The shape, exactly

```
# Add-on Name // Test Plan

One or two sentences: what the add-on does, and what we most want you to try this time.

**Play on {each flavor}.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. One sentence per check.

## Everything Else

2. One sentence per check, numbered on from above.
```

`{each flavor}` lists every flavor the add-on ships a TOC for, plus Season of Discovery when it carries `Data/Discovery/`. Nothing else goes in the file: no fixtures list, no results grid, no sign-off.

## Rules

- **One short sentence per check**, an instruction any player can follow: *Click the mini-map button to remove your lowest-value item.* No step-by-step, no "you should see", no failure description; add the expected result in a few words only when it isn't obvious.
- **About ten checks, never more than fifteen**, numbered continuously so a tester can report "check 7."
- **What's New** has one check per change a player would notice since the last release: read from `git diff` against the last release tag (`git describe --tags --abbrev=0 origin/main`), working copy included. Leave it out when nothing changed.
- **Everything Else** covers the core of the add-on: the thing it exists to do (including any class-specific path), opening the options from the options command and the mini-map button, and the options refusing to open in combat. Where a flavor tends to break, the check names it: on WoW Forever, try anything that reads auras, cooldowns or casts **in combat**.
- **Plain words.** No code, file names, API names, or how it works. Slash commands, buttons and menu names are fine, taken from the source and `README.md`, never invented.
