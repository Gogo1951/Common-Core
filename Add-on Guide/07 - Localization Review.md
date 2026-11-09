# WoW Add-on Localization Review (Editing, 5-Phase)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Localization Review`. Write scope: **every `Locales/*.lua` except `enUS.lua`.**

Bring every other locale into line with `enUS.lua`, which `06 - Copy Review.md` has just made right. When this pass finishes, every locale carries a correct, idiomatic translation of every `enUS.lua` key. This pass does the translating: it never defers the work to a later human pass or leaves `TODO` markers behind. **It asks nothing.** Every wording, register, loanword and stay-English call is its own to make, so it makes it and moves on.

**`enUS.lua` is read-only here.** A translation that disagrees with `enUS.lua` is evidence about *either* file; when it shows the English is what's wrong, report it as an issue in the preamble's fix-prompt format and translate the English as it stands.

## Workflow — five phases (0–4), all required

0. **Permissions** — per the preamble.

1. **Audit — don't assume.** Before changing anything, list what needs translating:
    - **Changed English.** Every `enUS.lua` key whose value differs from `main` (`git diff origin/main -- Locales/enUS.lua`), the same set as the Copy Review's before-and-after table. Each of these is retranslated in every locale, whatever it holds now.
    - **Drift.** Per locale: keys missing, keys `enUS.lua` no longer has, values left in English that When a value may stay English (below) doesn't allow, and translations that no longer match the current English.
    - **Game-name keys.** Any key the Code Review flagged as a game name keeps its current values in every locale; its fix retires the key, and a typed-in game name is the guess GAME NAMES forbids.

2. **Translate every other locale file — the main event.** Reconcile each `Locales/*.lua` against the **full current** `enUS.lua`:
    - **Key set** — add every key `enUS.lua` has that this file lacks, and remove keys `enUS.lua` no longer has. When done, every locale carries exactly the same key set as `enUS.lua`.
    - **Translate every value into the target language.** New keys are translated fresh from the current English; a renamed key keeps the old key's value only when its English is unchanged. Changed English and drifted values get a fresh translation of the current source. Leave English only where When a value may stay English allows; everything else gets translated, loanwords included.
    - **Formatting and comments** — every locale file mirrors `enUS.lua`'s section structure, ordering, and instructional comments, so the files stay diffable against each other.

3. **Verify — required.** Script it where possible:
    - **Parse whole assignments, not physical lines** (Style Guide → LOCALIZATION → Reading Locale Files).
    - **Key parity** — every `Locales/*.lua` has an identical key set to `enUS.lua`: no missing keys, no orphans.
    - **Everything is translated** — no renamed key whose English changed kept the old key's value, and no value equals `enUS` except as When a value may stay English allows or a game-name flag exempts.
    - **Placeholder match** — count and type per key against `enUS`, in the same order unless numbered (`%2$s`, which translators use to reorder words), where each number must point at an `enUS` placeholder of the same type (a mismatch crashes at runtime — highest-value check).
    - **Rendering** — no em-dashes or curly quotes in any locale's values, per Style Guide → TONE AND COPY → In-Game Rendering Rules.
    - **Parse** — every touched file still parses and registers the correct locale code.
    If anything fails, fix it before finishing.

4. **Report.** Open with a 2–3 sentence summary and the Phase 3 result. Then, per locale, how many keys were translated this pass (new, renamed, and retranslated combined), confirming each is now fully aligned with `enUS.lua`. Then any issue about the English itself. Keep prose lean.

## When a value may stay English

- **Value-equals-English is authoritative.** A value that equals `enUS` in some locales but is translated in others is a bug in the English-left ones, loanwords included — a term stays English only if it stays English in *every* locale. Two cases legitimately equal English; anything else equal to English is a bug. Judge by the principle, not by matching the examples:
    - **Nothing translatable in it** — the add-on's Full Name and Short Name (Style Guide → ADD-ON NAMES), brand and site names, slash-command literals, a heading whose entire text is a slash command, feature product names pairing the brand with a feature word, true universal tokens (`PvP`), and format-only strings whose entire content is placeholders, digits, and punctuation (`"%dx %s"`).
    - **Native vocabulary in the target language** — verified per case by the pass itself. esES/esMX/frFR/ptBR "Local (/1)" is correct even though deDE renders "Lokal"; don't "fix" it.
- **The "&" connector localizes** — it renders as each locale's idiomatic connector ("y", "et", "и", "与"); keep "&" only where the language conventionally uses it. "Feedback & Support" is translatable copy, not a proper noun (deDE "Feedback & Unterstützung").
