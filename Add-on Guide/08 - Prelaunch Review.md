# WoW Add-on Prelaunch Review (Review + Master-List Refresh)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Prelaunch Review`. Write scope: **nothing — report only.**

Run this when manual testing is **complete** and the add-on is believed to be working — the last gate before tagging a release. Functionality is presumed correct; this pass checks everything else: release metadata, packaging, localization, ship-cleanliness, and the master-list row. Your output is the Phase 4 report, in this chat.

**The local dev copy is the source of truth, and it runs ahead of GitHub `main` on purpose.** The maintainer builds and tests locally, then pushes everything to `main` *after* this gate passes — so `main` legitimately lacks this session's fixes, and the local copy will differ from `main`, often by many files. **Never treat that as a problem:** don't flag that `main` is missing this session's work, that the local copy differs from `main`, or that `main` "isn't ready to tag." The only things this pass checks on GitHub are the repo-only packaging files listed under **Packaging** below; everything else is reviewed here, in the local copy.

## Workflow — five phases (0–4), all required

0. **Permissions** — per the preamble.
1. **Review.** Read the preamble's read-first docs, plus every file in `Locales/`, which the Code Review skips. **README files are out of scope — skip `README.md` and `README-Testing.md` entirely, and read `README-Technical.md` only as the map the preamble describes**; they're owned by steps 9–11. The `Includes/` folder stays vendored — verify its wiring, don't review its contents.
2. **Study the targets.** Fetch the live reference files from GitHub and use them as the target state:
    - [Thanks-for-the-Buff](https://github.com/Gogo1951/Thanks-for-the-Buff) — `.pkgmeta`, which the packaging check validates against (see Packaging below).
    - [Addon Categories](https://warcraft.wiki.gg/wiki/Addon_Categories) — the canonical category list and its per-locale strings, the live source of truth for the Category check below. It is deliberately never copied into this guide, and it always wins.

    The guide is the standard wherever it speaks (Style Guide, opening rule). For what it tells you to copy verbatim — `.pkgmeta` and the wiki's category strings — the fetched live source is the comparison target; where that source fails an explicit guide requirement, the reference file is what needs fixing. If a needed live file can't be fetched, say so and mark affected findings reduced-confidence.

    **Reference check — required before any finding that changes what players see** (Style Guide, opening rules). A Live reference that does the opposite of its rule is a Phase 3 question, never a finding.
3. **Clarify — required, before any findings.** Ask per the preamble. For example: *this release adds a setting that changes what other players in the group see; should it ship on or off by default?* No findings until any answers are in.
4. **Report.** Produce the report below.

## Presumption of working code

Manual testing is done. Do **not** review feature logic or hunt behavioral bugs — that is what's out of scope, and no finding may come from it. **Reading code to establish a fact you need is allowed** — if answering your own question means opening a file and looking, do that rather than spending a blocking question round on it; only ask in Phase 3 when the answer isn't recorded anywhere and can't be read off the code either. Code is in scope for findings on exactly two things: **load-time integrity** and **ship cleanliness**, as defined in the checklist.

## Master list refresh

Before tagging, reconcile this add-on's entry in `References/Gogo Add-ons Complete List.md` against what it actually ships, so the next run starts accurate. **This pass never edits the master list:** each update is a routine data item in Guide Feedback — the exact replacement text, undated — landed via triage.

**Reconcile facts only.** The master list records what an add-on *is*, never how far along it is; a shortfall against a rule is a finding in this report, not a master-list note.

- Compare the add-on's live TOC (plus `.pkgmeta` and the live CurseForge/Wago listings where relevant — never the READMEs, which this pass ignores) against its master-list row: `## X-Curse-Project-ID:`, `## X-Wago-ID:`, CurseForge slug, installed folder (`.pkgmeta` `package-as` — the Folder column), category (enUS), target marker (or player-only), the slash command literal(s) the add-on actually registers (the Slash command column), and the GitHub and CurseForge links.
- Where they differ, apply the field-scoped precedence rule at the top of the master list: release-wired identifiers follow the shipping add-on (propose the row update); editorial fields follow the master list (a finding against the add-on — the TOC needs fixing); anything else unclear, ask in Phase 3. Note every difference in the report.
- If the add-on is new and has no row yet, propose one in the same format.
- Scope every proposed edit to this add-on's detail entry and Quick reference row; never propose touching other add-ons' data.

## Checklist

**Release metadata (every TOC):**
- `## Version:` is `@project-version@` — never a hardcoded string.
- **Blocker: one flavor TOC per current target, each declaring its own number.** Run `grep -n '^## Interface:\|^## X-Flavor:' *.toc`, compare the output to `01 - Local Setup.md` Session Prep step 1, and quote the output in the report whether it passes or fails. `## X-Flavor:` always equals the TOC's own suffix; a missing target TOC, an unsuffixed TOC, or any other `## X-Flavor:` value fails it (Style Guide → TOC FILE FORMAT → Flavor TOCs).
- `## X-Curse-Project-ID:` and `## X-Wago-ID:` are real IDs, not placeholders, and match the master list (`References/Gogo Add-ons Complete List.md`, Quick reference table) for this add-on.
- Single `## SavedVariables: AddonNameDB` line present (one AceDB-managed table — see the Style Guide's SAVED VARIABLES); any extra global or `SavedVariablesPerCharacter` line is a finding unless a migration still inside its remove-after window declares it (Style Guide → SAVED VARIABLES → Migration Windows); the declared global matches what the code actually uses.
- `## IconTexture:` path resolves to a file that exists.
- `## Category-*:` — exactly one category from the wiki's list, still fitting the add-on's primary job (the master list's Category column), written as `## Category-enUS:` plus one line per supported locale in the master list's Shared constants order. Every line ships, even where the string equals English (`Chat`, `PvP`), copied verbatim from the wiki: no hand translations, no drift. (The wiki writes English as a bare `## Category:`; the house `## Category-enUS:` changes presentation, not the string.) A missing block is a Blocker; a partial or drifted one is a finding.
- Footer block present with the correct GitHub repo URL and Discord link, in that order (CurseForge and Wago are not in the TOC footer — they live in the README's Setup section).
- The TOCs differ only where Style Guide → TOC FILE FORMAT → Flavor TOCs allows — diff them against each other.

**Load-time integrity:**
- Every file each TOC lists exists; every Lua file in the repo is listed in at least one TOC, **except dev-only files that must not load in-game** (API/type stubs, `Tests/` — see Style Guide → REPOSITORY LAYOUT → Dev-only files) and the data folders of flavors the add-on ships no TOC for yet, which wait for their TOCs. Their absence from the TOCs is correct; adding them is the bug.
- `Data/Flavor.lua` matches `References/Canonical Files/Flavor.lua` verbatim. Data files follow Style Guide → DATA → Flavor Folders: `Data/Flavor.lua` first and `Data/Default-Settings.lua` last in every TOC's Data block, each TOC listing its own flavor folder and no other (the Vanilla TOC lists `Data/Vanilla/` then `Data/Discovery/`), no game-data file outside the folders, all seven folders holding the same table names, and every file suffixed with its own folder's name (`Data/Mists/Collections-Mists.lua`) — run `ls Data/*/` and quote the output.
- **Data freshness.** Every file in the folders the TOCs list follows Style Guide → DATA → Data File Layout. Run `for f in Data/*/*.lua; do grep -H -A1 '^Last Validated' "$f" || echo "$f: no Last Validated heading"; done` and quote the output for those folders. A file with no `Last Validated` heading, or one reading `Never.` or `Undated`, or dated more than six months before today, is a finding, **Fix before release**: list each file with its date, and the fix is a Validate Data run on that client, applied by `05 - Data Review.md`.
- Load order follows the Style Guide, including the AceConfig sub-library order.
- Every Lua file parses — no syntax errors. No feature-logic review beyond this.
- `luacheck .` runs clean (Style Guide → LINTING); a warning here is a finding like any other.

**Packaging** (this pass is the sole owner of these checks — the Code Review ignores `.pkgmeta`, `.github/`, and `LICENSE` entirely). Review these files as they exist on the **`main` branch of the add-on's GitHub repo** (the repo URL from the TOC footer / master-list row), **not** the local working copy — fetch them from GitHub and check those versions. If a file can't be fetched from `main`, say so and mark the affected findings reduced-confidence rather than falling back to the local copy.
- `.pkgmeta` is validated against **the live `Thanks-for-the-Buff` `.pkgmeta`**, which carries the two load-bearing AceDB externals (`AceDB-3.0`, `AceDBOptions-3.0`). The checks: trailing slashes on CurseForge URLs, `package-as` matches the master list's Folder column (the installed folder — not the repo name or CurseForge slug), externals match the TOC Includes block exactly, and mini-map libraries only when there's a mini-map button, matching the live `Magic-Eraser` `.pkgmeta`'s. `enable-toc-creation` is not used — don't flag its absence.
- `LICENSE` matches `References/Canonical Files/LICENSE.txt`, with `{{YEAR}}` as the add-on's first year; the `.pkgmeta` ignore list is correct (Style Guide → REQUIRED LIBRARIES → .pkgmeta).
- `.luacheckrc` present on `main`.
- **Shared files are Common-Core's** (`.github/workflows/`, `.gitignore`, `.gitattributes`): its CI fails any copy that differs from `addon-files/`, so this pass never compares them, and one that needs a change is changed in Common-Core and synced, never edited in the add-on (Style Guide → COMMON-CORE).

**Localization — all files, not just enUS:**
- Every `Locales/*.lua` parses, registers the correct locale code for its filename, and uses the same identity literal/constant as `enUS.lua`.
- `enUS.lua` is complete: every key referenced in code is defined, every defined key is referenced.
- **Format placeholders match enUS in count, type, and order in every locale** — a `%s`/`%d` mismatch crashes at runtime.
- An `enUS.lua` key missing from a locale is a finding (players see English); orphans are harmless, one-line count per file.
- No locale value is itself the name of a spell, item, skill, zone, class or Blizzard UI label (Style Guide → GAME NAMES). One that does is a finding: the name must come from the client by ID.

**Documentation:**
- The **Feedback & Support** panel's URLs (`ns.LINKS`) — Discord, CurseForge, Wago, GitHub, in that order (see Style Guide → OPTIONS PANEL → Feedback & Support Panel) — are all present and match the add-on's master-list row, and the Help [Add-on Name] Level Up paragraphs above them and the copy caption below them are the mandated copy with the correct Full Name.

**Ship cleanliness:**
- No leftover debug prints, `/dump` calls, or commented-out code blocks.
- Diagnostics enable gate defaults off and persists nothing.
- Welcome message string is the mandated copy (Style Guide → WELCOME MESSAGE), with the `%s` version token and the correct Full Name, printed at every login while Enable Welcome Message is on, with no version or first-login gate.
- Target marker matches the add-on's master-list row (the Target marker column) — no collision with another add-on.
- The options command exists, its literal(s) match the master-list row (the Slash command column) with no collision, its `/Commands` description is the mandated copy, and `ns:OpenOptionsPanel` opens with the `InCombatLockdown()` gate (Style Guide → OPTIONS PANEL → Slash Commands and Combat Guard).
- `TODO: Add SQL Query` under a data file's SQL (CMaNGOS) heading is sanctioned and never blocks release; any other TODO/FIXME gets reported.

## Report format

**Never offer to create a PR, branch, or commit — don't ask, don't suggest it.** That is the job of `12 - Create Release Notes & PR.md`, run only after this gate passes. It offers step 12 only as Pass Preamble → Next Pass says, once the README sessions it started have all finished. This pass edits nothing in the add-on beyond the preamble's `README-Notes.md` record (see intro); its fix prompts edit the working copy, which step 12 commits. The exception is a Packaging file, checked on `main`: print its complete corrected contents in its own fenced code block, ready for the maintainer to paste into GitHub themselves.

Open with the verdict — **Ready to tag** or **Not ready: N blocker(s)** — and a 2–3 sentence summary. Then list issues grouped by checklist area, Blockers first. Include a short **Master list** line stating whether the master-list row was already current or what updates are proposed (when there are updates, the exact edits ride in Guide Feedback as routine data items). Keep prose lean.

Severity scale:
- **Blocker** — do not tag a release until fixed.
- **Fix before release** — the release would function, but fix it first.
- **Polish** — can ship; worth noting.

Fix-prompt block rules and the non-developer description rule (here, the **What's wrong** field) are in the preamble.

Use this block per issue:

### Issue N: short title
**Severity:** Blocker / Fix before release / Polish
**Area:** TOC / Load / Packaging / Localization / Docs / Cleanliness
**What's wrong:** Plain-language user story for a non-developer (see above) — what the player experiences and why it matters.
**Dependencies:** Other issues/prompts that must be run first, or "None."
**Fix prompt:**
```
Issue N: short title
A complete, runnable fix prompt following the rules above.
```
