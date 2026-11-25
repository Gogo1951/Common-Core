# Pass Preamble — Read This First

Governs every pass prompt in this guide — numbered, optional, and Code Comment Cleanup alike. Feedback Triage, which maintains the guide, runs by its own rules. Each prompt opens by pointing here and then states only what is specific to it: its Pass Name, its write scope, and its own work.

**Guide paths.** The guide is the Common-Core repo's `Add-on Guide/` folder on GitHub `main`. Every guide file a prompt names (`References/…`, `01 - Local Setup.md`) is relative to it, fetched with `curl -fsSL "https://raw.githubusercontent.com/Gogo1951/Common-Core/main/Add-on%20Guide/{path}"` (spaces as `%20`), never read from a local copy; every other path is relative to the add-on folder.

## Permissions

Beyond Session Prep step 0's render (`01 - Local Setup.md`), never create or edit any settings file, and never write anything to `~/Common-Core`. Whatever its write scope, a pass may write the add-on's `README-Notes.md` as Style Guide → README-NOTES directs: to record an exception the maintainer keeps, or to trim or drain entries; whatever writes it then says in one line what it added or changed, and never prints the file. The local copy keeps it across sessions (Session Prep leaves `README-Notes.md` alone), and step 12 commits it with the release like any other change. Never set the Bash tool's `dangerouslyDisableSandbox`: the template runs the sandbox in strict mode, which ignores it. Reads and `git diff`/`status`/`log` work inside the sandbox, and a call made only of `git` or `gh` commands runs outside it on its own — but a `cd`, a pipe, a redirect, or a `$(...)` or heredoc anywhere in the call keeps all of it sandboxed, where `git config` can't write and `gh` fails TLS. Run those as bare calls. A command the sandbox blocks gets reported, never worked around. If an approval prompt appears mid-pass, stop and follow `01 - Local Setup.md` → What a prompt means now. A pass whose write scope is "nothing" denies any write prompt outright.

## Kits and the guide change only in Common-Core

**A pass never edits the guide or a shared kit copy** (anything Common-Core's `addon-kits/` holds), not even to fix a bug in one, because the next sync puts Common-Core's version back and the fix is lost. When the add-on needs one changed:

1. Say in one plain line what's wrong, e.g. *Two-line Examples run together; they need a blank line between them.*
2. Give a block the maintainer pastes into a session launched in `~/Common-Core`, saying exactly what to change and why:

```
In Common-Core, change {file under addon-kits/ or Add-on Guide/}: {what to change and why, in plain words}. Update the kit's spec and the Style Guide if a rule changes. Commit and push to main.
```

3. Leave the add-on's kit copy matching Common-Core, and build what the kit can already do.

**A kit copy that differs from Common-Core is never overwritten silently.** If it holds a change Common-Core lacks, give the paste block for that change first, then copy Common-Core's file over it. Once the change is on Common-Core's `main`, copying Common-Core's file over the add-on's, unchanged, brings it in.

## Read first

- `References/Add-on Creation Rules & Style Guide.md` — the rules. Authoritative wherever it speaks. Read all of it, unless your prompt names the sections to read.
- `References/Style Guide - Build Reference.md` — the same rules for building options rows and diagnostics; read it when your prompt names it.
- `References/Gogo Add-ons Complete List.md` — per-add-on facts (status, names, IDs, links, categories, markers, slash commands). Note the add-on's row. If its Status is Retired, stop and ask the maintainer before any work, unless they already named this add-on for this pass (Complete List → Active and retired).
- The add-on's `README-Notes.md` — where it departs from the guide; Style Guide → README-NOTES says how it binds the pass. An add-on without one has no exceptions.
- The add-on's `README-Technical.md`, when it has more than the step-00 stub — the map of the code that step 10 writes for Claude: where things live, how they connect, the traps. Read it before the code, and let it tell you where to look. It never stands in for reading the code a finding rests on, and where the two disagree the code wins (Standing scope).

**Do not reconstruct any of these from memory.** If one can't be read, say so and stop rather than working from what you remember of it.

## The maintainer's word wins

**What the maintainer says in this session beats every rule in this guide.** A size, a number, a word, a name, where a setting lives: use it exactly as given, even off the Spacing Scale or against a copy rule, and don't argue or round it. Do exactly what was asked, nothing dropped and nothing added. **Never undo something the maintainer changed**, in this session or a recent one (the working tree and recent commits show it), and never bundle an undo into a larger change. If it breaks something, say what in one line and leave it.

**Don't guess.** When you aren't sure why something happens, say so and give one thing to check in game before changing code. Never change working code to chase a guess, and never state a guess or a code comment as fact.

## Workflow contract

Run the prompt's phases in order. Don't skip one, and don't begin the report until the clarify phase has closed. A clarify phase with nothing to ask is skipped.

## Every reply — plain words

**Every reply to the maintainer is written for a non-developer,** not only a report's issue descriptions. Keep it to a few short lines in player words: say what happens in game — what a player sees, or what now works — not how the code does it. No function, file or variable names unless the maintainer asks for them. When something needs deciding, end with a short multiple-choice question, best option first, each option with an example of what a player would see (Asking questions, below). A report keeps its own format, its prose in the same plain words; the text inside fix and feature prompts and command blocks is written for Claude or for running, and keeps its own rules.

## Asking questions

Follow Style Guide → ASKING THE MAINTAINER. An empty clarify phase is a normal and good outcome.

## Report-only passes

**A pass whose write scope is "nothing" edits no code until the maintainer says go** (the preamble's `README-Notes.md` record aside). It writes its report and its fix or feature prompts, then asks the one Apply question (Batch apply, below). **"Build it", "do it", "yes", "apply" or "go" is the answer to that question:** run the prompts it covers in this session right away, without asking again.

## Standing scope — true in every pass

- **Only the launch folder exists.** A pass works in the add-on folder Claude Code was launched in (the scaffold: the folder it creates), reading only this guide and the web beside it. Every other folder on disk — this add-on's copies in the other game clients, every `WTF` folder, every other add-on — doesn't exist for it: never list, read, compare, sync, or mention one, and never spend a thought, finding, question, or fix prompt on one. The Copy to Other Flavors block below is the one exception, and the maintainer runs it. Whether those copies are current is the maintainer's business. The other exception is what the maintainer hands over or asks for in so many words, in this session (an uploaded report, a look at saved variables): the template can read the other copies and `WTF` for exactly that, so do what was asked, nothing more.
- **READMEs are frozen until steps 9–11.** Until those steps run, the code is the only record of what the add-on does. No pass or fix prompt writes `README.md`, `README-Technical.md` or `README-Testing.md` except the step that owns it, and none flags, asks about, or reconciles anything because a README says otherwise: one that disagrees with the code is out of date, and its own step rewrites it from the code. A pass that reads `README.md` reads it for what players are told, never as a record of how the code works. Every pass reads `README-Technical.md` as its map (Read first), and a stale line in it is ignored, never reported. `README-Notes.md` is the exceptions record, not a README here.
- **Every current target has its own flavor TOC, declaring the number `01 - Local Setup.md` Session Prep step 2 gives it.** Every pass that reads the TOCs checks this. A missing TOC is a **Blocker**, since that client never sees the add-on, and so is an unsuffixed one, since the rule is one TOC per flavor (Style Guide → TOC FILE FORMAT → Flavor TOCs). Never look the numbers up externally.
- **The flavor set is every current target** (Classic Era with Season of Discovery, WoW Forever, TBC Anniversary) **plus any other flavor the add-on ships a TOC for.** Fewer TOCs is the Blocker above, not a narrower scope. When a finding is client-specific, say which flavor.
- **Line endings are a closed subject** — never inspected, measured, restored, or reported, in any form. Common-Core's CI owns them (Style Guide → COMMON-CORE → Line Endings).
- **Optional passes (steps 0, 5, 9, 10, 11 and the `Optional - …` prompts) are never launch gates.**

## Report format — skim list

**Every report that lists issues or feature prompts opens with a skim list**, right after its opening summary or verdict, whatever the pass's own report format says next: one line per item, its `Issue N` or `Feature N` and a few plain words, in up to three groups in this order, each left out when empty.

1. **Bugs in Code** — something is broken, and the fix restores what was meant.
2. **Improvements to Code** — less memory, better performance or easier upkeep, with nothing a player sees.
3. **UX Changes Needed** — anything a player would see or feel beyond fixing a break: chat, UI, defaults, timing. Said in player terms, naming the flavor where only one is affected. These need the maintainer's care, so one never hides in the other two groups.

The items themselves follow in the pass's own order.

## Report format — fix prompts

Each issue's fix prompt is copy-and-run ready: a fenced code block (no language tag) containing **only** the prompt text, beginning with `Issue N: short title` on its own line.

- Write it as direct instructions. It runs in this same session and can rely on the Style Guide and prior findings being in context.
- Reference symbols, files, and APIs with inline backticks. **No fenced code blocks inside the prompt** — that breaks the outer block. Describe the change precisely enough to run rather than pasting a listing.
- Every fix leaves the files it edits in StyLua-default formatting, and leaves every comment it touches true to the changed code — update or delete any comment the change makes stale, in the same edit.
- Don't add explanatory comments the change doesn't require, and never edit a README (Standing scope); step 10 writes the durable *why* up from the code.

**Write each description for a non-developer** — a short user story, not a bug label. In one or two plain sentences, say what the player sees or experiences (or what quietly breaks) and why it matters, so the reader can judge the fix without reading code. Gloss any unavoidable technical term. Prefer *"After a UI reload the mini-map button vanishes and only comes back if you toggle it off and on again. Annoying, not harmful"* over *"LibDBIcon `hide` flag not restored on `PLAYER_LOGIN`."*

## Batch apply

**The maintainer never has to copy and paste prompts back.** When a report contains at least one fix or feature prompt (`Issue N` or `Feature N`), it ends with one multiple-choice question (Style Guide → ASKING THE MAINTAINER), after Guide Feedback:

- `Apply all (Recommended)` — *every Issue and Feature above runs now, one at a time*
- `Pick which ones` — *type the numbers, e.g. "1, 3, 4"*
- `None for now` — *nothing changes; the prompts stay above to paste later*

Drop `(Recommended)` from Apply all, and recommend Pick which ones, when any item is flagged as weak or as a UX change you'd rather the maintainer choose. Pasting prompts back, edited or not, works the same as picking them.

**How chosen prompts run.** Apply them in dependency order, one at a time; after each, run `stylua --syntax lua51` + `luac` + luacheck, plus `lua5.1 Tests/Run.lua` when the add-on has it, and stop and report if anything fails. A prompt that adds or changes English also translates it into every other locale in the same edit, so no later pass has to come back for it. Give a one-line status per item, then say they're done, say plainly that none of it has been tried in game, and give the Copy to Other Flavors command.

## Copy to Other Flavors

In steps 2–8 this command means "the work is done, go test." It comes once the edits are finished, never beside prompts still to run:

- **A report with fix or feature prompts carries no copy command.** Once the prompts the maintainer chose have run, the reply gives the one-line statuses, says the prompts are done, and ends with the command.
- **A report with none** ends with the command, just before Guide Feedback, when the pass itself edited files (Diagnostics, Data, Copy and Localization Reviews), and leaves it out when nothing changed.

Give it in a fenced block tagged `bash`, so the app shows a Run button. Fill in the launch folder's client folder for `{Client}` and the add-on's folder for `{Folder}`:

```bash
src="/Applications/World of Warcraft/{Client}/Interface/AddOns/{Folder}"; for t in "$src"/{Folder}_*.toc; do case "${t##*_}" in Vanilla.toc) c=_classic_era_;; TBC.toc) c=_anniversary_;; Camelot.toc) c=_forever_;; Mists.toc) c=_classic_;; Mainline.toc) c=_retail_;; *) continue;; esac; d="/Applications/World of Warcraft/$c/Interface/AddOns/{Folder}"; [ "$d" != "$src" ] && [ -d "${d%/*}" ] && rsync -a --delete --exclude .git --exclude .claude "$src/" "$d/" && echo "Copied to $c"; done
```

It reads the add-on's own TOCs and mirrors this folder into every installed client the add-on has a TOC for (Style Guide → TOC FILE FORMAT → Flavor TOCs maps suffix to client; Wrath has none), leaving their `.git` and `.claude` alone. One line above it says so. The maintainer runs it when they choose; **Claude never runs it**, and never edits another flavor's copy any other way (Standing scope).

## Next Pass

When a pass's work is done, it offers the next pass's prompt, which the maintainer starts in a new session when they are ready. **A pass only offers; it never starts the next pass itself:** no hand-off, no moving on to the next pass in this session. The maintainer decides when the next pass runs. Done means the reply that gives the Copy to Other Flavors command, or the report itself when the pass has nothing left to run. The prompt comes last, after Guide Feedback when the reply has one.

| Pass done | Prompt for |
|---|---|
| `02 - UX Review.md` | `03 - Code Review.md` |
| `03 - Code Review.md` | `04 - Diagnostics Review.md` and `06 - Copy Review.md`, side by side |
| `04 - Diagnostics Review.md` | `05 - Data Review.md` when phase 4 says yes, else nothing |
| `06 - Copy Review.md` | `07 - Localization Review.md` |
| `07 - Localization Review.md` | `08 - Prelaunch Review.md`, with one line: start it once any Data Review session has finished too |
| `08 - Prelaunch Review.md`, verdict **Not ready** | Nothing: once its chosen fixes have run, it checks again **in this same session** and gives its new verdict. Only a blocker another pass owns (stale data → `05 - Data Review.md`) gets that pass's prompt, with one line: then run 08 again |
| `Optional - Fix a Bug.md` | the pass its report names to re-run, or `08 - Prelaunch Review.md` |
| `08 - Prelaunch Review.md`, verdict **Ready to tag** | `09 - Optional Create README.md`, `10 - Optional Create README-Technical.md` and `11 - Optional Create README-Testing.md`, then `12 - Create Release Notes & PR.md` with one line: run it once 9–11 have finished |

**After step 3 the work runs in two branches, side by side:** 4 then 5, and 6 then 7, meeting at 8. `05 - Data Review.md` reads each client's tables from wago.tools and QuestieDB, so it needs no in-game test first; step 4 says whether it is worth running (`04 - Diagnostics Review.md` → phase 4).

**Only a pass in the table's left column offers a prompt.** 05, 09, 10, 11 and 12 offer none: the pass that started them already offered what comes next.

**Offer each next pass as a card with a play button, never as a copy box.** Just before the final reply, call `mcp__ccd_session__start_session` once per next pass (if it isn't loaded, load it with `ToolSearch`): initiation `user_asked`, title `Run {prompt file name}`, and the prompt exactly the line below. It waits as a card; Play starts a new session with the prompt running in it. Print the line as text only if calling the tool fails.

```
Run the pass in Common-Core's Add-on Guide/{Prompt file} on GitHub main: fetch it and treat it as the request. Session Prep already ran in this folder; run only its step 0.
```

**Sessions can share a folder** (04–07 and 09–11 run side by side). A change to a file this session isn't editing, `.claude/` included, is another session's work: ignore it, never stop or ask about it. Re-read a file before editing it.

## Guide Feedback

Follow Style Guide → GUIDE FEEDBACK. A pass with something to propose ends with that section; one with nothing leaves it out. Each prompt supplies only its own Pass Name for the context stamp.
