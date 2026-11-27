# WoW Add-on README-Technical Generation (Editing, `README-Technical.md` and Lua Comments)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `README-Technical generation`. Write scope: **`README-Technical.md`, plus the add-on's Lua comments outside `Includes/` and the `Data/{Game}/` folders: comments only, never code.**

**This prompt is the request.** Pasted on its own, it means: run the whole pass now and bring the launch folder's `README-Technical.md` up to date by the rules below, then clean up the code's comments (Comment Cleanup). Never ask whether to run it.

**The reader is Claude.** Every pass reads this doc first as its map of the code (Pass Preamble → Read first), so write what saves the next session a cold read: where things live, how they connect, and what the code can't say for itself — the reasons behind a design and the traps a change would walk into. That *why* is the durable content Style Guide → COMMENTS reserves for this doc, lifted from the code's comments. Nothing here is for human contributors or players.

## Read

**Style Guide sections, only these** (the Preamble allows it): REPOSITORY LAYOUT, DATA → Default-Settings.lua, SAVED VARIABLES, COMMENTS, LUA 5.1 → Offline Tests, OPTIONS PANEL → Combat Guard, COMMON-CORE, README-NOTES.

**Code:** the files the update below needs. In `Diagnostics/`, only `Manifests.lua`; the rest is the copied framework.

## Update From the Diff

No pass before this one updates this doc (Pass Preamble → Standing scope), so it is behind by whatever changed since it was last written. Update that, not the whole doc:

1. `git log -1 --format=%H -- README-Technical.md` gives the commit that last touched the doc.
2. `git diff --stat <that commit> -- . ':!README*'` plus `git ls-files --others --exclude-standard` give every code file changed or added since: the diff compares the working tree, so this release's uncommitted work is included.
3. Read the changed files, and rewrite only the sections they touch: the File Map for added, removed or renamed paths; any section describing a changed system; Pitfalls & Why when a change creates or removes a trap. Every other section stays as written. Add any section below the doc lacks, and drop any section it has that isn't below.

**Rebuild in full from a whole code read** only when the doc has nothing past the title and cross-link (the step-00 stub), the diff touches more than about a third of the code files, or the maintainer asks.

## How to Write It

- **Terse notes, not prose.** Short bullets and fragments; file paths and symbols in backticks.
- **Point at the code, never copy it.** Name the constant or function that holds a value, threshold or list (`ns.MAX_VALUE` in `Data/Data.lua`) instead of writing the value, so the doc can't go stale when it changes.
- **Point at the Style Guide, never restate it.** Record only what this add-on does on top of the rules, or where it is unusual.
- **Only what exists.** No plans, no TODOs, and no section for something the add-on doesn't have.

## Sections (in order)

### 1. Title and Cross-link

H1 `# Add-on Name // Technical Reference`, then this line verbatim (substitute the add-on and repo names):

> Code map for working on Add-on Name: where things live, how they connect, and the traps. Where this and the code disagree, the code wins. For players, see [README.md](https://github.com/Gogo1951/Repo-Name/blob/main/README.md).

### 2. `## File Map`

A code-fenced ASCII tree of the repo, one short annotation per non-obvious file saying what it owns — enough to know which file to open. Standard files (`.toc`, `Locales/`) get a two-word label or none, and `Diagnostics/` gets one line naming `Manifests.lua` as this add-on's part. Call out any deprecated or dead file, so no change reintroduces it. Annotations attach with spaces only, aligned into one column two spaces past the longest path in the tree — never an em dash or other separator character — and each begins with a capital letter. Changing the tree re-flows that column to the current longest path.

The tree is `git ls-files` plus `git ls-files --others --exclude-standard`: Session Prep points the index at `main`, so this lists the repo's files, including any the packager strips from the installed folder, plus files this session added, and leaves out local artifacts. List `.github/workflows/ci.yml` and `package.yml` as `Calls Common-Core: ...` (Style Guide → COMMON-CORE), and when `Tests/` is present, state that it runs on Lua 5.1.

### 3. `## Architecture`

One `###` per part that applies, saying how it works and which files hold it:

- **Event Loop** — events listened for, how they route to the logic, any debouncing or throttling.
- **Combat Lockdown** — what refuses in combat (the options opener always does — Style Guide → OPTIONS PANEL → Combat Guard), what defers instead, and when deferred work replays.
- **Main Pipeline** — the primary data flow phase by phase (Scan → Compose → Write, or this add-on's equivalent).
- **Caching** — how cold `C_Item.GetItemInfo` nils are handled, where the cache lives, what invalidates it.
- **Any other system with non-obvious behavior**, named for the system — the shape of what it writes or sends (macro body, chat payload) when that matters.

### 4. `## Files That Change Together`

Only when the add-on has them: the common changes that span files, each with every touch point, so none is missed — a new registered event goes in `ns.EVENT_NAMES` in `Features/Core.lua`, which the dispatcher and diagnostics both read; a new setting needs its `ns.DATABASE_DEFAULTS` key, its options row and its locale keys. One line per change.

### 5. `## Saved Variables`

- Each SavedVariables table and what it's for, in a line. Don't list its keys; the code and `ns.DATABASE_DEFAULTS` hold them.
- **The model — Simple or Per-Character (Style Guide → SAVED VARIABLES → The Two Models) — and what Reset Profile therefore clears.** This tells the next change which scope a new setting belongs in.
- Any default-list seeding (Style Guide → DATA → Default-Settings.lua).
- `### Migration Chain` when there is one: each migration in run order, one line each.

Every add-on uses AceDB-3.0; one that still hand-rolls a defaults merge gets that noted as migration debt here.

### 6. `## Pitfalls & Why`

Bullets. Each is a trap someone has hit, or plausibly could, in *this* codebase, or a design that looks wrong but is deliberate — never generic Lua or WoW advice. Lead with the trap or the surprise, then the reason or the mitigation:

> **Editing macros in combat**: silently fails. Always defer via the dirty flag.

## What Doesn't Belong Here

- Anything for players or human contributors — `README.md`, `README-Testing.md` and GitHub cover those.
- Values, lists and logic the code states; name where they live instead.
- Rules the Style Guide already states, and generic Lua or WoW advice.
- How the static data is chosen and sourced. That lives only in each `Data/{Game}/` file's `How We Got the Data` block, owned by `05 - Data Review.md`; the File Map just lists the folders.
- Code blocks beyond a line or two of a payload's shape.

## Comment Cleanup

Once the doc is written, slim and sharpen the comments across every Lua file. The house standard is **few, sharp comments**, and this is what enforces it. The rules are canonical in Style Guide → COMMENTS; this applies them, not a second copy of them. **Comments only: behavior must stay identical, so never change code.**

Go file by file through every Lua file. Skip `Includes/`, which is vendored and never touched, and the `Data/{Game}/` folders, whose comments belong to `05 - Data Review.md` (Style Guide → DATA → Data File Layout):

- **Apply Style Guide → COMMENTS as written:** delete what doesn't earn its place (the default is *no* comment), keep only the non-obvious *why* that section defines, and shorten what stays: one line where one line does the job, multi-line preambles and ceremony cut to the essential point.
- **Keep the durable *why*, short.** A comment explaining a whole subsystem or design rather than the line it sits on is cut to its essential point and left in place. Its full version belongs in this doc: write it up there first if the doc lacks it.
- **Never touch functional markers.** Leave `MIGRATION` tags and sanctioned `TODO:` markers exactly as they are; other passes depend on them. Leave the dashed SECTION HEADERS dividers and the data-array column-header and row legends; they're structure, not commentary.

Err toward trimming, but this isn't a scorched pass: a judgment-call comment that genuinely helps can stay. The aim is steady progress against over-commenting, not zero comments.

**Verify, required:**

- **Behavior unchanged.** Confirm each touched file still parses (`luac -p`) and lints clean (luacheck), and confirm each file's code is unchanged: the `luac5.1 -l -l -p` listing of its `luac5.1 -s` output is identical before and after once the `<?:N,M>` line pairs and `0x…` addresses are masked (`sed -E 's/<\?:[0-9]+,[0-9]+>/<?>/; s/0x[0-9a-f]+/0x/g'`).
- **Formatting preserved.** Run StyLua-default over every touched file (Style Guide → TABLE FORMATTING & STYLUA); a comment edit isn't done if it left non-StyLua whitespace behind.

## Report

Briefly: which doc sections changed (or that the doc was rebuilt), then how many Lua files the cleanup touched and roughly how many comments were cut versus kept.
