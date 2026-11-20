# WoW Add-on Fix a Bug (On Demand, Editing)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `Fix a Bug`. Write scope: **any add-on file the fix needs, except the READMEs** (Pass Preamble → Standing scope).

Run this whenever testing turns up something broken, at any point in the pipeline. The maintainer describes the bug in plain words, and may paste a Lua error, a Diagnostic Tools report, or a tester's comment. You find the cause, fix it, and say exactly which passes, if any, need to run again.

## Workflow

0. **Permissions** — per the preamble. If this session didn't come from a Next Pass card, run `01 - Local Setup.md` → Session Prep first.

1. **Understand the bug.** Read what the maintainer gave you, then the code it points at. Reproduce it in your head from what a player does. **If you aren't sure of the cause, don't change code yet:** say so, and give the maintainer one thing to check in game (what to click, or one `/run` line to paste) that tells the causes apart. Never change something that works to chase a guess. If you truly can't tell what's wrong, ask one multiple-choice question (Style Guide → ASKING THE MAINTAINER), e.g. *When does it break?* `Right after login (Recommended)` — *the error pops up as the game loads* / `When I open the options` / `Only in a group`.

2. **Fix the cause, not the symptom.** Smallest change that makes the add-on do what was meant, following the Style Guide. Keep every comment you touch true to the code. English you add or change is translated into every other locale in the same edit. Don't refactor or polish anything else.

3. **Verify.** `stylua --syntax lua51`, `luac -p` and luacheck on every changed file, plus `lua5.1 Tests/Run.lua` when the add-on has it.

4. **Work out what to re-run.** Only what the fix actually touched:

    | The fix changed… | Re-run |
    |---|---|
    | Added a new event, setting or window | `04 - Diagnostics Review.md` |
    | Anything else (logic, data, layout, text) | nothing |

    Then test in game, then `08 - Prelaunch Review.md`.

## Report format

Keep it to a few short lines in player words (Pass Preamble → Every reply):

- **What was wrong** — one sentence a player would recognize.
- **What's fixed** — one sentence.
- **Re-run** — the passes from the table, or `Nothing to re-run.`

Then the Copy to Other Flavors command (Pass Preamble), Guide Feedback, and the Next Pass card for the first pass to re-run, or for step 8 when there's none.
