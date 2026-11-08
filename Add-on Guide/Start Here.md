# Add-on Guide — Start Here

This folder is the guide for building and maintaining Gogo1951's WoW add-ons: the prompts Claude runs, and the rules they enforce. It lives in [Common-Core](https://github.com/Gogo1951/Common-Core) under `Add-on Guide/`, beside the shared CI and release logic every add-on is built on. Two kinds of files:

- **Numbered and `Optional - …` prompts** (this folder) — the pipeline steps; run them in Claude, in the order below.
- **`References/`** — what the steps consult or invoke: the **Pass Preamble** (the shared contract every pass prompt opens with), the Style Guide and its Build Reference (the rules), the master list (per-add-on facts), the permission template, the canonical files (`Data/Flavor.lua` and a `LICENSE` template), and two utility prompts (Guide Feedback Triage, Code Comment Cleanup) run on demand rather than per release.

Every pass prompt — numbered, optional, and Code Comment Cleanup alike — starts by reading `References/Pass Preamble.md` and then states only what is specific to it. Feedback Triage, which maintains the guide, runs by its own rules. Rules shared by all passes live there or in the Style Guide, never restated in a prompt.

## Setup

Sessions read the guide from a local clone of Common-Core at `~/Common-Core`. Clone it once:

```bash
git clone https://github.com/Gogo1951/Common-Core.git ~/Common-Core
```

From then on, Session Prep step 0 pulls it at the start of every code session, so the guide is always the latest `main`. Every guide path in these files (`References/…`, `01 - Local Setup.md`) is relative to `~/Common-Core/Add-on Guide/`.

To run a pass, launch Claude Code in the add-on's installed folder and paste the prompt's contents, or point the session at the file: `Run the pass in ~/Common-Core/Add-on Guide/03 - Code Review.md: read it and treat it as the request.`

## Supported clients

**Every add-on ships one TOC per client below.** Each TOC loads only its own flavor's complete data folder (Style Guide → DATA → Flavor Folders). Exact versions and interface numbers live in `01 - Local Setup.md` → Session Prep.

| Client | Install folder | TOC | What it is |
|---|---|---|---|
| Classic Era (1.15.x) | `_classic_era_` | `_Vanilla.toc` | Classic engine, Classic data. Season of Discovery runs on this client too, so its `Data/Discovery/` folder rides this TOC |
| TBC Anniversary (2.5.x) | `_anniversary_` | `_TBC.toc` | Classic engine, TBC data |
| WoW Forever (1.60.x) | `_forever_` | `_Camelot.toc` | **Retail engine, Classic Era data**, plus new content still being datamined: Retail for API behavior, Classic for items and spells (Style Guide → COMPATIBILITY) |

## The pipeline

Each step is one laser-focused job. Run them in order, and skip an optional one when it has nothing to do. Each entry says what the step is for, then what it changes.

- **`00 - Optional GitHub Cleanup.md`** — Starts a new add-on, or checks an existing one. For a new add-on it builds a complete, loadable skeleton on Common-Core. For an existing one it checks GitHub for every scaffolding file and repo setting. *Changes:* the new add-on's folder; for an existing add-on nothing local, with missing settings given as Run-button commands and corrected files as blocks to paste into GitHub.
- **`01 - Local Setup.md`** — **Run at the start of every code session you start yourself, before anything else** (step 0 needs only Session Prep step 0). Sessions a pass starts for you, and step 12, skip it. Refreshes the guide, sets the session's permissions, pulls the latest `main` and libraries down, and opens the folder in Sublime Text. *Changes:* the add-on's `.claude/settings.local.json`, its TOCs' version and interface lines, its READMEs and scaffolding files, its libraries, and its git wiring (no commits).
- **`02 - UX Review.md`** — Reviews how the add-on looks and reads to a player in about ten minutes. Asks at most four broad questions, then draws a clickable wireframe of Current beside Proposed for the windows its changes touch, layout fixes and feature ideas alike, and you approve each change on the page or in chat. Competitor research and full drawings run when you ask or say *full*. *Changes:* nothing itself unless you say to build; otherwise approved changes come out as feature prompts, which you run before step 3.
- **`03 - Code Review.md`** — A full review of the code, step 2's features included, against the Style Guide and good judgment. You get a report of findings, each with a copy-and-run fix prompt, then you run the fixes you want. *Changes:* nothing itself; the fix prompts edit the code.
- **`04 - Diagnostics Review.md`** — Brings the Diagnostic Tools panel in line with the code, so it captures everything that could explain a bug report, without asking. *Changes:* `Diagnostics/`, plus its TOC lines, `ns.EVENT_NAMES` and the dispatcher's logging call.
- **`05 - Data Review.md`** — Optional, and only once step 4 is finished. Applies the Validate Data reports you upload from the game: strips IDs a client doesn't have, corrects values, and adds anything wago.tools shows it missed, using QuestieDB to leave out items players can't get, all without asking. *Changes:* the `Data/{Game}/` folders the reports name.
- **`06 - Copy Review.md`** — Polishes the English in `enUS.lua`: typos, consistency, and strings to merge or split. Ends with a before-and-after table of every English string that changed. *Changes:* `Locales/enUS.lua`, plus code that uses a renamed key.
- **`07 - Localization Review.md`** — Translates every other language to match the current English, without asking. *Changes:* every locale file except `enUS.lua`.
- **`08 - Prelaunch Review.md`** — The last gate before tagging a release, run once manual testing is done. Checks release metadata, packaging, translations and leftovers, and gives a Ready to tag or Not ready verdict. *Changes:* nothing; master-list updates are proposed in Guide Feedback.
- **`09 - Optional Create README.md`** — Writes the marketing README players read before installing. A pitch change also rewrites the pitch in every TOC and every language. *Changes:* `README.md`, plus every copy of the pitch when it changes.
- **`10 - Optional Create README-Technical.md`** — Writes the deep technical reference for developers. *Changes:* `README-Technical.md`.
- **`11 - Optional Create README-Testing.md`** — Writes a short, plain-English test plan for volunteer testers. A Ready-to-tag step 8 offers it; run it again whenever testers need one. *Changes:* `README-Testing.md`.
- **`12 - Create Release Notes & PR.md`** — Drafts player-facing notes for everything since the last release, plus the PR title, for one approval. Then checks the GitHub identity, branches from the freshest upstream `main`, commits, pushes and opens the PR with the notes as its body. Tagging stays manual. *Changes:* git and GitHub only, as `Gogo1951`, and nothing is pushed before you approve.

**Optional, whenever wanted:**

- **`Optional - Create UX Wireframes.md`** — Draws every window exactly as it is now, as a clickable private page to share with testers, at step 2's link. Nothing is proposed. *Changes:* nothing.

**In `References/`, run on demand:**

- **`Code Comment Cleanup Prompt.md`** — Slims the code's comments, never its behavior. Because it edits source, run it **before** step 8. *Changes:* Lua comments outside `Data/{Game}/`.
- **`Guide Feedback Triage Prompt.md`** — Folds approved Guide Feedback into these docs, in a session launched in `~/Common-Core`. *Changes:* the guide docs, approved changes only, committed and pushed to Common-Core `main`.

**Steps 2–8 end with a copy-to-other-flavors Run button once the work is done** (Pass Preamble → Copy to Other Flavors): a pass with fix prompts gives it after you've run them, never beside them. You mirror the working folder into the add-on's other installed clients, then test. Claude only ever edits the one folder it was launched in.

**Each finished pass offers the next one in a new session** (Pass Preamble → Next Pass): 2 offers 3, 3 offers 4, 4 offers 6, 6 offers 7, 7 offers 8, and a Ready-to-tag 8 offers 9, 10 and 11, then 12 once they finish. Pick *New session* and they run side by side in this folder. Step 5 is never offered; start it yourself once step 4 is done and you have reports.

**Every pass ends with a Guide Feedback section** (Style Guide → GUIDE FEEDBACK), and most print `No changes proposed.` A departure the maintainer keeps for one add-on goes in that add-on's `README-Notes.md`, never here. A pass that does propose a change ends with a copy-and-run line: paste it into a **new session launched in `~/Common-Core`** (Claude Code there, or Cowork with it connected), where `References/Guide Feedback Triage Prompt.md` applies what you approve — **never back into the code session**, whose template denies guide writes.

## Ground rules

- **The guide is public, so nothing personal goes in it.** No real names, no email address other than the Gogo1951 noreply, no machine or host names, no other account handles, and no local path that names a user: a home folder is always `~` or `$HOME`. The same holds for every commit message.
- **The guide is generic and read-only to code sessions.** Only guide-maintenance sessions write it (Feedback Triage, or the maintainer reworking the guide directly), launched in `~/Common-Core` and pushed to `main`, and no `.claude/` settings file ever exists in the clone. Naming an add-on is fine where that's the point (the master list's rows, the Style Guide's Live reference lines), but a real add-on's *values* — folder names, IDs, live slash commands, file contents — never appear in a rule or code example; snippets use placeholders. The Interface targets in `01 - Local Setup.md` are the one sanctioned literal.
- **These documents set the rules; they never track how well any add-on follows them.** No file here records compliance, conversion progress, or pending work; that goes in a pass's report. Examples show only how things *should* be, never "don't do it like add-on X."
- **One folder per session.** A session works only in the folder **Claude Code was launched in**, reading this guide and the web beside it. Every other folder, this add-on's copies in the other clients and the `WTF` folders included, stays unread and unmentioned unless the maintainer asks (Pass Preamble → Standing scope). Switching flavors means a new session in that flavor's copy.
- **READMEs wait for steps 9–11.** Until then the code is the only record: no pass edits a README, or flags or asks about one that disagrees with the code (Pass Preamble → Standing scope).
- **Stability beats polish.** The guide changes when something breaks, or when copy or a reference goes stale, and not otherwise. A departure that's right for one add-on is recorded in its `README-Notes.md` and needs no guide change. A Guide Feedback of `No changes proposed.` is a pass that went well.
