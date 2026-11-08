# WoW Add-on Copy Review (enUS Only, Editing, 5-Phase)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Copy Review`. Write scope: **`Locales/enUS.lua` and code references to renamed keys.** No other locale file is touched; `07 - Localization Review.md` translates them next.

Polish the English. `enUS.lua` is the source every other locale is translated from, so it gets right first, and the report carries a before-and-after table of every English string that changed, so step 7 knows exactly what to retranslate.

**The pitch is step 9's.** `OPTIONS_DESCRIPTION` carries `README.md`'s pitch, which `09 - Optional Create README.md` owns and keeps in sync. Fix its rendering-rule drift, never its wording, and never compare it with `README.md` or ask about a difference.

## Workflow — five phases (0–4), all required

Do not touch code before Phase 3, and do not begin Phase 3 until the Phase 2 answers are in.

0. **Permissions** — per the preamble.

1. **Review `enUS.lua` for cleanliness.** Read `enUS.lua` end to end and audit the source strings. Check for:
    - **Typos and grammar** — misspellings, wrong punctuation, broken capitalization inside the display text.
    - **EN-US** — American spelling and usage only (Style Guide → TONE AND COPY → English). A British, Australian or Canadian spelling is a typo.
    - **Title Case** — every string that is a title or header (window title, panel or tab name, section header, column header, tooltip title) is in Title Case per Style Guide → TONE AND COPY → English.
    - **Consistency** (make it checkable, not vibes): one term per concept (don't call the same thing "config" in one string and "settings" in another); consistent capitalization for buttons and option names; consistent trailing punctuation; and a consistent placeholder format (`%s`, `%d`, `%1$s` — flag any mixing of styles or any placeholder whose type doesn't match how the code uses it).
    - **Rendering** — Style Guide → TONE AND COPY → In-Game Rendering Rules: no em-dashes, straight quotes, no markdown or emojis.
    - **Comment and formatting hygiene** — the instructional comments and section structure that organize the file are present, accurate, and consistently applied.
    - **Key parity with the code** — every key defined is referenced, every key referenced is defined (Style Guide → LOCALIZATION).
    No edits yet — collect findings for Phase 2.

2. **Ask about the choices, and only those.** A fix a rule settles (typos and grammar, EN-US, Title Case, rendering, key parity, placeholder style) needs no approval and goes straight to Phase 3 (Style Guide → ASKING THE MAINTAINER). Ask about the rest:
    - **Wording** — any improvement beyond what a rule requires, and which term wins where two name one concept.
    - **Structural changes** — strings to **consolidate** (near-duplicate strings that should become one shared key) and strings to **break up** (an overloaded string doing two jobs, or one that concatenates fragments that should be separate keys for translators). For each, name the keys and say why.

    Ask per the preamble: multiple choice, grouped so the maintainer can accept or reject in batches, the recommended option first and labeled `(Recommended)`. **Only approved choices get made**; an empty round is fine.

3. **Implement the rule fixes and the approved choices — in `enUS.lua` and everywhere the keys are used.** Consolidating or splitting strings **changes keys**, so update **every code reference** (call sites in `.lua`, and any XML) to the old keys so nothing points at a key that no longer exists, and so new keys are actually wired up. A structural change isn't done until the code that uses it is updated too. Never reuse a retired key name (Style Guide → LOCALIZATION).

4. **Verify — required.** Script it where possible:
    - **Parse whole assignments, not physical lines** (Style Guide → LOCALIZATION → Reading Locale Files).
    - **No dangling code references** — no `.lua`/XML reference points at a key that was renamed or removed. Match **bare string literals** as well as `L["KEY"]`: keys reached through a manifest field (`mapping.formatKey`, `channel.labelKey`, and the like) never appear in the explicit `L["…"]` form, so an `L["KEY"]`-only scan wrongly flags them as unused.
    - **Placeholders** — every changed value keeps the count, type, and order its call sites pass.
    - **Parse** — `enUS.lua` and every touched code file still parse, through `stylua --syntax lua51`, `luac -p` and luacheck.
    If anything fails, fix it before finishing.

## Report format

Open with a 2–3 sentence summary: what was cleaned, what was consolidated or split, and the Phase 4 result. Keep prose lean.

Then the **before-and-after table**, the part that matters most: columns **Key | English Before | English After**, one row for **every `enUS.lua` key whose value differs from `main`** (`git diff origin/main -- Locales/enUS.lua`), whatever made the change: this pass, an earlier fix prompt, or a feature prompt. A new key shows `none` as Before; a removed key shows `none` as After; a renamed key shows `old → new` in the Key column. Quote both values exactly as they appear in the file, placeholders included. Leave no change out; if nothing changed, say so in one line. Step 7 retranslates from this table.
