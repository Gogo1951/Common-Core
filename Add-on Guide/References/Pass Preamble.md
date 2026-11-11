# Pass Preamble — Read This First

Governs every pass prompt in this guide — numbered, optional, and Code Comment Cleanup alike. Feedback Triage, which maintains the guide, runs by its own rules. Each prompt opens by pointing here and then states only what is specific to it: its Pass Name, its write scope, and its own work.

**Guide paths.** The guide lives in the Common-Core repo's `Add-on Guide/` folder, read from the local clone at `~/Common-Core`, which Session Prep step 0 keeps level with `main`. Every guide file a prompt names (`References/…`, `01 - Local Setup.md`) is relative to `~/Common-Core/Add-on Guide/`; every other path is relative to the add-on folder.

## Permissions

Beyond Session Prep step 0's render (`01 - Local Setup.md`), never create or edit any settings file, and never write anything to `~/Common-Core`. Whatever its write scope, a pass may write the add-on's `README-Notes.md` as Style Guide → README-NOTES directs: to record an exception the maintainer keeps, or to trim or drain entries; whatever writes it then says in one line what it added or changed, and never prints the file. The local copy keeps it across sessions (Session Prep leaves `README-Notes.md` alone), and step 12 commits it with the release like any other change. Never set the Bash tool's `dangerouslyDisableSandbox`: the template runs the sandbox in strict mode, which ignores it. Reads and `git diff`/`status`/`log` work inside the sandbox, and a call made only of `git` or `gh` commands runs outside it on its own — but a `cd`, a pipe, a redirect, or a `$(...)` or heredoc anywhere in the call keeps all of it sandboxed, where `git config` can't write and `gh` fails TLS. Run those as bare calls. A command the sandbox blocks gets reported, never worked around. If an approval prompt appears mid-pass, stop and follow `01 - Local Setup.md` → What a prompt means now. A pass whose write scope is "nothing" denies any write prompt outright.

## Read first

- `References/Add-on Creation Rules & Style Guide.md` — the rules. Authoritative wherever it speaks. Read all of it, unless your prompt names the sections to read.
- `References/Style Guide - Build Reference.md` — the same rules for building options rows and diagnostics; read it when your prompt names it.
- `References/Gogo Add-ons Complete List.md` — per-add-on facts (names, IDs, links, categories, markers, slash commands). Note the add-on's row.
- The add-on's `README-Notes.md` — where it departs from the guide; Style Guide → README-NOTES says how it binds the pass. An add-on without one has no exceptions.
- The add-on's `README-Technical.md`, when it has more than the step-00 stub — the map of the code that step 10 writes for Claude: where things live, how they connect, the traps. Read it before the code, and let it tell you where to look. It never stands in for reading the code a finding rests on, and where the two disagree the code wins (Standing scope).

**Do not reconstruct any of these from memory.** If one can't be read, say so and stop rather than working from what you remember of it.

## Workflow contract

Run the prompt's phases in order. Don't skip one, and don't begin the report until the clarify phase has closed.

## Asking questions

Follow Style Guide → ASKING THE MAINTAINER. An empty clarify phase is a normal and good outcome.

## Standing scope — true in every pass

- **Only the launch folder exists.** A pass works in the add-on folder Claude Code was launched in (the scaffold: the folder it creates), reading only this guide and the web beside it. Every other folder on disk — this add-on's copies in the other game clients, every `WTF` folder, every other add-on — doesn't exist for it: never list, read, compare, sync, or mention one, and never spend a thought, finding, question, or fix prompt on one. The Copy to Other Flavors block below is the one exception, and the maintainer runs it. Whether those copies are current is the maintainer's business. The other exception is what the maintainer hands over or asks for in so many words, in this session (an uploaded report, a look at saved variables): the template can read the other copies and `WTF` for exactly that, so do what was asked, nothing more.
- **READMEs are frozen until steps 9–11.** Until those steps run, the code is the only record of what the add-on does. No pass or fix prompt writes `README.md`, `README-Technical.md` or `README-Testing.md` except the step that owns it, and none flags, asks about, or reconciles anything because a README says otherwise: one that disagrees with the code is out of date, and its own step rewrites it from the code. A pass that reads `README.md` reads it for what players are told, never as a record of how the code works. Every pass reads `README-Technical.md` as its map (Read first), and a stale line in it is ignored, never reported. `README-Notes.md` is the exceptions record, not a README here.
- **Every current target has its own flavor TOC, declaring the number `01 - Local Setup.md` Session Prep step 1 gives it.** Every pass that reads the TOCs checks this. A missing TOC is a **Blocker**, since that client never sees the add-on, and so is an unsuffixed one, since the rule is one TOC per flavor (Style Guide → TOC FILE FORMAT → Flavor TOCs). Never look the numbers up externally.
- **The flavor set is every current target** (Classic Era with Season of Discovery, WoW Forever, TBC Anniversary) **plus any other flavor the add-on ships a TOC for.** Fewer TOCs is the Blocker above, not a narrower scope. When a finding is client-specific, say which flavor.
- **Line endings are a closed subject** — never inspected, measured, restored, or reported, in any form. Common-Core's CI owns them (Style Guide → COMMON-CORE → Line Endings).
- **Optional passes (steps 0, 5, 9, 10, 11 and the `Optional - …` prompts) are never launch gates.**

## Report format — fix prompts

Each issue's fix prompt is copy-and-run ready: a fenced code block (no language tag) containing **only** the prompt text, beginning with `Issue N: short title` on its own line.

- Write it as direct instructions. It runs in this same session and can rely on the Style Guide and prior findings being in context.
- Reference symbols, files, and APIs with inline backticks. **No fenced code blocks inside the prompt** — that breaks the outer block. Describe the change precisely enough to run rather than pasting a listing.
- Every fix leaves the files it edits in StyLua-default formatting, and leaves every comment it touches true to the changed code — update or delete any comment the change makes stale, in the same edit.
- Don't add explanatory comments the change doesn't require, and never edit a README (Standing scope); step 10 writes the durable *why* up from the code.

**Write each description for a non-developer** — a short user story, not a bug label. In one or two plain sentences, say what the player sees or experiences (or what quietly breaks) and why it matters, so the reader can judge the fix without reading code. Gloss any unavoidable technical term. Prefer *"After a UI reload the mini-map button vanishes and only comes back if you toggle it off and on again. Annoying, not harmful"* over *"LibDBIcon `hide` flag not restored on `PLAYER_LOGIN`."*

## Batch apply

When a report contains at least one issue, follow the last issue with a one-sentence **Batch apply** note telling the maintainer they can paste any subset of the fix prompts back in a single message — edited or reordered — together with the line below, and each will run one at a time with the same rigor. Give that line by itself in a fenced code block:

```
Apply these in dependency order, one at a time; after each, run stylua --syntax lua51 + luac + luacheck (+ a sanity check where relevant) and stop and report if anything fails; give me a one-line status per issue, then tell me they're done and give me the Copy to Other Flavors command.
```

## Copy to Other Flavors

In steps 2–8 this command means "the work is done, go test." It comes once the edits are finished, never beside prompts still to run:

- **A report with fix or feature prompts carries no copy command.** Once the prompts the maintainer pastes back have run, the reply gives the one-line statuses, says the prompts are done, and ends with the command.
- **A report with none** ends with the command, just before Guide Feedback, when the pass itself edited files (Diagnostics, Data, Copy and Localization Reviews), and leaves it out when nothing changed.

Give it in a fenced block tagged `bash`, so the app shows a Run button. Fill in the launch folder's client folder for `{Client}` and the add-on's folder for `{Folder}`:

```bash
src="/Applications/World of Warcraft/{Client}/Interface/AddOns/{Folder}"; for t in "$src"/{Folder}_*.toc; do case "${t##*_}" in Vanilla.toc) c=_classic_era_;; TBC.toc) c=_anniversary_;; Camelot.toc) c=_forever_;; Mists.toc) c=_classic_;; Mainline.toc) c=_retail_;; *) continue;; esac; d="/Applications/World of Warcraft/$c/Interface/AddOns/{Folder}"; [ "$d" != "$src" ] && [ -d "${d%/*}" ] && rsync -a --delete --exclude .git --exclude .claude "$src/" "$d/" && echo "Copied to $c"; done
```

It reads the add-on's own TOCs and mirrors this folder into every installed client the add-on has a TOC for (Style Guide → TOC FILE FORMAT → Flavor TOCs maps suffix to client; Wrath has none), leaving their `.git` and `.claude` alone. One line above it says so. The maintainer runs it when they choose; **Claude never runs it**, and never edits another flavor's copy any other way (Standing scope).

## Next Pass

When a pass's work is done, it offers the next pass in a new session, so the maintainer never has to start one by hand. Done means the reply that gives the Copy to Other Flavors command, or the report itself when the pass has nothing left to run. The offer comes last, after Guide Feedback when the reply has one.

| Pass done | Offer |
|---|---|
| `02 - UX Review.md` | `03 - Code Review.md` |
| `03 - Code Review.md` | `04 - Diagnostics Review.md` and `06 - Copy Review.md`, side by side |
| `04 - Diagnostics Review.md` | `05 - Data Review.md` |
| `06 - Copy Review.md` | `07 - Localization Review.md` |
| `07 - Localization Review.md` | `08 - Prelaunch Review.md` |
| `08 - Prelaunch Review.md`, verdict **Ready to tag** | `09 - Optional Create README.md`, `10 - Optional Create README-Technical.md` and `11 - Optional Create README-Testing.md` |
| The sessions step 8 started, once all have finished | `12 - Create Release Notes & PR.md`, offered by the step 8 session |

**After step 3 the work runs in two branches:** 4 then 5, and 6 then 7. Their write scopes never meet, so either branch can run ahead of the other. `05 - Data Review.md` needs Validate Data reports, which exist only once step 4 is tested in game, so the maintainer starts its card after that test; step 4 says first whether it is worth running (`04 - Diagnostics Review.md` → phase 4). It is optional and ends its branch with no offer. Step 7's offer of step 8 adds one line: start it once any Data Review session has finished too, so step 8 reviews both branches.

In the Claude desktop app, offer each one with the app's start-session tool, as an offer (its card asks *New session* or *Do it here*): one card per pass, a fresh session, no worktree, since the game loads the add-on from this folder. The brief is exactly this line, with the prompt's file name filled in. Anywhere else, print the same line in a fenced block, to paste into a new session launched in this folder.

```
Run the pass in ~/Common-Core/Add-on Guide/{Prompt file}: read it and treat it as the request. Session Prep already ran in this folder; skip it.
```

**Sessions running side by side share this folder,** so the passes paired above never write the same files. A lint or parse failure in a file outside your write scope is another session's edit in progress: run the check again once, and report it only if it fails again.

## Guide Feedback

Follow Style Guide → GUIDE FEEDBACK. **Every pass ends with that section, even when empty.** Each prompt supplies only its own Pass Name for the context stamp.
