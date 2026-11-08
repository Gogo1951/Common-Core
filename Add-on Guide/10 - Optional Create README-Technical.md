# WoW Add-on README-Technical Generation (Editing, `README-Technical.md`)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `README-Technical generation`. Write scope: **`README-Technical.md` only.**

**This prompt is the request.** Pasted on its own, it means: run the whole pass now and regenerate the launch folder's `README-Technical.md` by the rules below. Never ask whether to run it.

The developer companion to `README.md`. Architecture, conventions, contribution guide. This is what someone reads before touching the code. Keep `README.md` clean of these details — link between them.

**Carry what the code can't say for itself.** This doc's value is the *why* — architecture, the reasoning behind a design, and the traps a new contributor would otherwise hit — plus the contribution contract: the durable content Style Guide → COMMENTS reserves for this doc, lifted from the code's comments. The mechanical sections (File Map, the Saved Variables key list) are kept lightweight and **regenerated, not hand-maintained**. No pass before this one reads or updates this doc (Pass Preamble → Standing scope), so treat all of it as stale: rebuild the File Map from the current tree every run, and check every other claim against the code.

Code-comment tightening is a **separate** pass — see `References/Code Comment Cleanup Prompt.md`.

## Live References

- [Connoisseur/README-Technical.md](https://github.com/Gogo1951/Connoisseur-Restocker/blob/main/README-Technical.md)
- [Magic-Eraser/README-Technical.md](https://github.com/Gogo1951/Magic-Eraser/blob/main/README-Technical.md)

## Voice & Tone

Write for a developer who has read `README.md` but has never opened the code. Crisp, declarative, present tense. Explain the *why*, not just the *what*. **Be as specific as the code allows**: the exact events, thresholds, conditions and edge cases behind every behavior. Everything `README.md` leaves out to stay high level belongs here. No marketing language, no aspirational features, no "TODO" notes. This document is a snapshot of what currently exists.

## Required Sections (in order)

### 1. Title

H1, exact phrasing: `# Add-on Name // Technical Reference`

### 2. Cross-link

One sentence, verbatim (substitute the add-on and repo names):

> This document combines architecture notes and contribution guidance for developers working on Add-on Name. For end-user documentation, see [README.md](https://github.com/Gogo1951/Repo-Name/blob/main/README.md).

### 3. `## File Map`

A code-fenced ASCII tree of the repo, one short annotation per non-obvious file — orientation, not an exhaustive mirror. Standard files (`.toc`, `Locales/`) get a two-word label or none. Regenerate this from the current tree when it goes stale rather than hand-patching it. The one thing worth calling out explicitly: any deprecated or dead file, so a future contributor doesn't reintroduce it. Annotations attach with spaces only, aligned into one column two spaces past the longest path in the tree — never an em dash or other separator character — and each begins with a capital letter. Regenerating the map re-flows that column to the current longest path.

Build the tree from `git ls-files` plus `git ls-files --others --exclude-standard`: Session Prep points the index at `main`, so this lists the repo's files, including any the packager strips from the installed folder, plus files this session added, and leaves out local artifacts. List `.github/workflows/ci.yml` and `package.yml` as `Calls Common-Core: ...` (Style Guide → COMMON-CORE), and when `Tests/` is present, state that it runs on Lua 5.1.

### 4. `## Architecture`

Multiple `###` subsections. Include only those that apply to this add-on — don't pad with empty sections.

- **Event Loop** — events the add-on listens for, how they route to update logic, any debouncing or throttling.
- **Combat Lockdown** — what refuses outright during combat (the options opener always does: it prints and returns, never queues — Style Guide → OPTIONS PANEL → Combat Guard) and what defers instead, the flag/queue pattern, when deferred work replays.
- **Scan → Compose → Write** (or the add-on's analogous pipeline) — primary data flow phase by phase, with source files named inline.
- **Item Data Caching** — how `C_Item.GetItemInfo` cold-call nils are handled, where cache lives, what invalidates it.
- **State Encoding** — when a hashed/keyed state skips redundant writes, document the key namespace and why namespaces are disjoint.

### 5. Feature Deep-Dives

One `## Section` per system with non-obvious behavior, each named for the system itself. (Connoisseur's two-mode food macro and Magic Eraser's Auto-Vend combat deferral are model examples.) Include the macro/command/payload shape in a code block when relevant. Always explain the *why*.

### 6. `## Saved Variables`

Name each SavedVariables table and, in a sentence, what it's for. The shape — which top-level keys exist and what each holds — is regenerated from the code, not maintained key-by-key here, so don't mirror every field. If there's a migration chain, add a `### Migration Chain` subsection listing each `MigrateXxx` step in version order, one line each. **State which saved-variables model the add-on uses — Simple or Per-Character (Style Guide → SAVED VARIABLES → The Two Models) — and in one line what Reset Profile therefore clears.** That is the most load-bearing fact in this section: it tells a contributor which scope a new setting belongs in. Then state, in one line, how AceDB applies `ns.DATABASE_DEFAULTS` (Style Guide → SAVED VARIABLES → Mechanics), followed by a description of any default-list seeding logic (Style Guide → DATA → Default-Settings.lua). Every add-on uses AceDB-3.0 — if the one under review still hand-rolls a defaults merge, that's migration debt to flag, not a model to document as permanent.

### 7. `## Adding a New X`

Procedural how-tos for common extensions (a new consumable category, a new built-in collection, a new tracked spell, a new registered event — add it to `ns.EVENT_NAMES` in `Features/Core.lua` so the dispatcher and diagnostics pick it up together, etc.). Numbered steps; call out file paths. Reference the add-on's real output ceiling wherever it applies (Style Guide → MESSAGES → Message Length, canonical for both the macro and chat limits).

### 8. `## Localization`

Document how the add-on's strings are localized. This is **maintenance, not expansion** — WoW ships a fixed locale set and every supported locale file already exists, so there is no "add a new locale" step. Cover, briefly:

- **`enUS.lua` is the source of truth** and the only file that passes the `true` default-fallback flag; every other locale translates its key set, and the Localization Review (`07 - Localization Review.md`) owns those files — never hand-edit them during ordinary work.
- **Placeholders** — `%s`/`%d` count, type, and order must match `enUS` per key in every locale, or the string crashes at runtime.
- **Game names never go in `Locales/`** — spells, items, skills, zones and classes are stored as IDs and named by the client (Style Guide → GAME NAMES). Name the add-on's own ID constants and the lookup each uses.

Everything else (the Spanish file pairing, the overflow canary, the output ceilings) is per Style Guide → LOCALIZATION and MESSAGES → Message Length.

### 9. `## Common Pitfalls`

Bulleted list. Every entry is a real bug someone has hit (or could plausibly hit) in *this* codebase — not generic Lua or WoW advice. Each bullet leads with the trap, then names the existing mitigation:

> **Editing macros in combat**: silently fails. Always defer via the dirty flag.

### 10. `## Contributing`

Keep it short. Cover:

- **Where to open issues** — link the GitHub Issues tab.
- **Bug reports** — game version + locale, class + level, repro steps, relevant macro body / chat output.
- **Discord** — link.
- **PR guidelines** — scope, code style, migration discipline, the output-length check for any chat/macro changes (Style Guide → MESSAGES → Message Length), and "update this document if the architecture or file map changes."
- **PR descriptions say what a player will notice**, in plain language, the way release notes do; commit messages carry the developer detail.

## What Doesn't Belong Here

- Player-facing "what does the add-on do" content — that's `README.md`.
- Generic Lua or WoW add-on advice not specific to this codebase.
- How the static data is chosen and sourced. That lives only in each `Data/{Game}/` file's `How We Got the Data` block, owned by `04 - Data Review.md`; the File Map just lists the folders.
- Long uninterrupted code blocks. Use small illustrative snippets; the code itself is in the repo.
