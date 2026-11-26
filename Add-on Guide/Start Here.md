# Add-on Guide — Start Here

This folder is the guide for building and maintaining Gogo1951's WoW add-ons: the prompts Claude runs, and the rules they enforce. It lives in [Common-Core](https://github.com/Gogo1951/Common-Core) under `Add-on Guide/`, beside the shared CI and release logic every add-on is built on. Two kinds of files:

- **Numbered and `Optional - …` prompts** (this folder) — the pipeline steps; run them in Claude, in the order below.
- **`References/`** — what the steps consult or invoke: the **Pass Preamble** (the shared contract every pass prompt opens with), the Style Guide and its Build Reference (the rules), the master list (per-add-on facts), the permission template, the canonical files (`Data/Flavor.lua`, the other-client prune for `Features/Core.lua`, and a `LICENSE` template), `Add-on CLAUDE.md` (the rules every session in an add-on folder loads, which Session Prep copies in), and two utility prompts (Guide Feedback Triage, Code Comment Cleanup) run on demand rather than per release.

Every pass prompt — numbered, optional, and Code Comment Cleanup alike — starts by reading `References/Pass Preamble.md` and then states only what is specific to it. Feedback Triage, which maintains the guide, runs by its own rules. Rules shared by all passes live there or in the Style Guide, never restated in a prompt.

## Setup

Sessions read the guide straight from Common-Core `main` on GitHub (Pass Preamble → Guide paths), so it is always current and never needs pulling. The local clone at `~/Common-Core` is only for the `wowclaude` launcher, guide maintenance and the sync scripts. Clone it once:

```bash
git clone https://github.com/Gogo1951/Common-Core.git ~/Common-Core
```

Every guide path in these files (`References/…`, `01 - Local Setup.md`) is relative to `Add-on Guide/`.

To run a pass, launch Claude Code in the add-on's installed folder and paste the prompt's contents, or point the session at the file: `Run the pass in Common-Core's Add-on Guide/03 - Code Review.md on GitHub main: fetch it and treat it as the request.`

## Supported clients

**Every add-on ships one TOC per client below.** Each TOC loads only its own flavor's complete data folder (Style Guide → DATA → Flavor Folders). Exact versions and interface numbers live in `01 - Local Setup.md` → Session Prep.

| Client | Install folder | TOC | What it is |
|---|---|---|---|
| Classic Era (1.15.x) | `_classic_era_` | `_Vanilla.toc` | Classic engine, Classic data. Season of Discovery runs on this client too, so its `Data/Discovery/` folder rides this TOC |
| TBC Anniversary (2.5.x) | `_anniversary_` | `_TBC.toc` | Classic engine, TBC data |
| WoW Forever (1.60.x) | `_forever_` | `_Camelot.toc` | **Retail engine, Classic Era data**, plus new content still being datamined: Retail for API behavior, Classic for items and spells (Style Guide → COMPATIBILITY) |

## The pipeline

Each step is one laser-focused job. Run them as the diagram shows, and skip an optional one when it has nothing to do. Each entry says what the step is for, then what it changes.

**Reviews that only report: steps 2, 3 and 8** (and `Optional - Create UX Wireframes.md`). They never edit code; you get findings or feature prompts, then one question: *Apply all / Pick which ones / None for now*. Code changes only when you answer it. **Reviews that fix their own area: steps 4–7**, each inside the files its entry names, and nowhere else.

![The pass workflow: 01, then three optional jobs side by side (Paste In GitHub Issues, Address Reported Defects, Create New Features), then Preliminary In-Game Testing with its iterate loop, then 02 and 03, then 04 → the optional 05 beside 06 → 07, meeting at Final In-Game Testing with its iterate loop, then 08, then 09–11, 12 and 13](References/Pass%20Workflow.svg)

- **`00 - Optional GitHub Cleanup.md`** — Starts a new add-on, or checks an existing one. For a new add-on it builds a complete, loadable skeleton on Common-Core. For an existing one it checks GitHub for every scaffolding file and repo setting. *Changes:* the new add-on's folder; for an existing add-on nothing local, with missing settings given as Run-button commands and corrected files as blocks to paste into GitHub.
- **`01 - Local Setup.md`** — **Run at the start of every code session you start yourself, before anything else** (step 0 needs only Session Prep step 0). Sessions launched from a pass's Next Pass prompt, and steps 12 and 13, run only its step 0. Sets the session's permissions, pulls the latest `main` and libraries down, and opens the folder in Sublime Text. *Changes:* the add-on's `.claude/settings.local.json`, its TOCs' version and interface lines, its READMEs and scaffolding files, its libraries, and its git wiring (no commits).
- **Paste In GitHub Issues · Address Reported Defects · Create New Features** — Optional, side by side, no prompt files: the cycle's work, asked for in plain words in a session after step 1. Paste in GitHub issues, describe a defect, or ask for a new feature. Once it's done, step 2 onward checks it was all done right. *Changes:* whatever the work needs.
- **`02 - UX Review.md`** — Reviews how the add-on looks and reads to a player. Asks at most four broad questions, then draws every window as a clickable wireframe, Current beside Proposed, with layout fixes and feature ideas alike, and you approve each change on the page or in chat. *Changes:* nothing itself; approved changes come out as feature prompts, which you run before step 3.
- **`03 - Code Review.md`** — A full review of the code, step 2's features included, against the Style Guide and good judgment. You get a report of findings, each with a copy-and-run fix prompt, then you run the fixes you want. *Changes:* nothing itself; the fix prompts edit the code.
- **`04 - Diagnostics Review.md`** — Brings the Diagnostic Tools panel in line with the code, so it captures everything that could explain a defect report, without asking. *Changes:* `Diagnostics/`, plus its TOC lines, `ns.EVENT_NAMES` and the dispatcher's logging call.
- **`05 - Data Review.md`** — Optional, once step 4 is finished. Checks the data against each client's own tables on wago.tools: strips IDs a client doesn't have, corrects values, and adds anything it missed, using QuestieDB to leave out items players can't get, all without asking. It asks you for an in-game Validate Data run only when the tables can't settle something. *Changes:* the `Data/{Game}/` folders the TOCs list.
- **`06 - Copy Review.md`** — Polishes the English in `enUS.lua`: typos, consistency, and strings to merge or split. Ends with a before-and-after table of every English string it changed. *Changes:* `Locales/enUS.lua`, plus code that uses a renamed key.
- **`07 - Localization Review.md`** — Translates every other language to match the current English, without asking. *Changes:* every locale file, `enUS.lua` only to fix a plain English mistake it finds.
- **`08 - Prelaunch Review.md`** — The last gate before tagging a release, run once manual testing is done. Checks release metadata, packaging, translations and leftovers, and gives a Ready to tag or Not ready verdict. *Changes:* nothing; master-list updates are proposed in Guide Feedback.
- **`09 - Optional Create README.md`** — Writes the marketing README players read before installing. A pitch change also rewrites the pitch in every TOC and every language. *Changes:* `README.md`, plus every copy of the pitch when it changes.
- **`10 - Optional Create README-Technical.md`** — Writes the code map every later pass reads first: where things live, how they connect, the traps. *Changes:* `README-Technical.md`.
- **`11 - Optional Create README-Testing.md`** — Writes a short, plain-English test plan for volunteer testers. A Ready-to-tag step 8 gives its prompt; run it again whenever testers need one. *Changes:* `README-Testing.md`.
- **`12 - Create Release Notes & PR.md`** — Drafts player-facing notes for everything since the last release, plus the PR title, for one approval. Then checks the GitHub identity, branches from the freshest upstream `main`, commits, pushes and opens the PR with the notes as its body. Tagging stays manual. *Changes:* git and GitHub only, as `Gogo1951`, and nothing is pushed before you approve.
- **`13 - Post Merge Sanity Check.md`** — Run once step 12's PR is merged. Checks that the folder and `main` now match, so nothing was left out of the release, and closes the release's Fixed issues. Offers whatever is still open (unsettled defects and questions, skipped data work, anything for the next run) as GitHub issues, then lists every change the cycle suggests for the guide and the kits, as one block for Feedback Triage. *Changes:* GitHub issues only, as `Gogo1951`, and none is created before you approve.

**Optional, whenever wanted:**

- **`Optional - Fix a Defect.md`** — Testing found something broken? Describe it in plain words (or paste the error) and it fixes it, then tells you which passes to re-run, usually none. *Changes:* whatever the fix needs, never the READMEs.
- **`Optional - Create UX Wireframes.md`** — Draws every window exactly as it is now, as a clickable private page to share with testers, at step 2's link. Nothing is proposed. *Changes:* nothing.

**In `References/`, run on demand:**

- **`Code Comment Cleanup Prompt.md`** — Slims the code's comments, never its behavior. Because it edits source, run it **before** step 8. *Changes:* Lua comments outside `Data/{Game}/`.
- **`Guide Feedback Triage Prompt.md`** — Folds approved Guide Feedback into these docs, in a session launched in `~/Common-Core`. *Changes:* the guide docs, approved changes only, committed and pushed to Common-Core `main`.

**Steps 2–8 end with a copy-to-other-flavors Run button once the work is done** (Pass Preamble → Copy to Other Flavors): you mirror the working folder into the add-on's other installed clients, then test.

**Each finished pass offers the next pass's prompt**, in the order the diagram shows (Pass Preamble → Next Pass): a card you click to start it in a new session when you're ready. No pass ever starts the next one for you. Step 5 needs no in-game test first. Start step 8 once step 7, and step 5 if it ran, are done and you've tested in game.

**After step 3 the work runs in two branches, side by side** in the same folder: 4 then 5, and 6 then 7, meeting at 8. **Steps 9–11 also run side by side**; each writes its own file.

**A pass that spots a problem in the guide adds a Guide Feedback section** (Style Guide → GUIDE FEEDBACK); most have none. One that proposes a change ends with a copy-and-run line for a **new session launched in `~/Common-Core`**, where `References/Guide Feedback Triage Prompt.md` applies what you approve — **never the code session**, whose template denies guide writes.

## Ground rules

- **The guide is public, so nothing personal goes in it.** No real names, no email address other than the Gogo1951 noreply, no machine or host names, no other account handles, and no local path that names a user: a home folder is always `~` or `$HOME`. The same holds for every commit message.
- **The guide is generic and read-only to code sessions.** Only guide-maintenance sessions write it (Feedback Triage, or the maintainer reworking the guide directly), launched in `~/Common-Core` and pushed to `main`, and no `.claude/` settings file ever exists in the clone. Naming an add-on is fine where that's the point (the master list's rows, the Style Guide's Live reference lines), but a real add-on's *values* — folder names, IDs, live slash commands, file contents — never appear in a rule or code example; snippets use placeholders. The Interface targets in `01 - Local Setup.md` are the one sanctioned literal.
- **These documents set the rules; they never track how well any add-on follows them.** No file here records compliance, conversion progress, or pending work; that goes in a pass's report. Examples show only how things *should* be, never "don't do it like add-on X."
- **One folder per session.** A session works only in the folder **Claude Code was launched in**, reading this guide and the web beside it. Every other folder, this add-on's copies in the other clients and the `WTF` folders included, stays unread and unmentioned unless the maintainer asks (Pass Preamble → Standing scope). Switching flavors means a new session in that flavor's copy.
- **READMEs wait for steps 9–11.** Until then the code is the only record: no pass edits a README, or flags or asks about one that disagrees with the code (Pass Preamble → Standing scope). Passes still read `README-Technical.md` as their map; the code wins.
- **Stability beats polish.** The guide changes when something breaks, or when copy or a reference goes stale, and not otherwise. A departure that's right for one add-on is recorded in its `README-Notes.md` and needs no guide change. A pass with no Guide Feedback is a pass that went well.
