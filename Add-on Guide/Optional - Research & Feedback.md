# WoW Add-on Research & Feedback (Ideation, Wireframe-First)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Research & Feedback Pass`. Write scope: **nothing. The wireframe is an Artifact, and the feature prompts go in chat.**

Come up with feature ideas for this add-on — your own, and ones learned from the competition — then **draw them** instead of asking about them one by one. The maintainer approves from the wireframe, and each approved idea comes out as a copy-and-run feature prompt.

Run it whenever fresh ideas are wanted; no other pass depends on it.

## Workflow — five phases (0–4), all required

0. **Permissions** — per the preamble. The Artifact publish asks for approval, and that prompt is expected: approve it with a plain **Yes**.

1. **Understand the add-on.** Read its code and `README.md` alongside the preamble's read-first docs, until you can state what it does, for whom, and what it deliberately doesn't do. Ideas must fit the flavors the add-on ships on.

2. **Research the landscape.** Build a picture of what similar add-ons offer that this one doesn't:
    - **Start with the README's Related Add-ons section** — that list is pre-researched; fetch each entry's CurseForge/GitHub page and read its features.
    - **Then search beyond it:** CurseForge, Wago, GitHub topics, and WoWInterface, using user-facing terms for each distinct thing the add-on does (synonyms, slang, pain points) — the same broad-search technique as the README pass. Look especially for well-known competitors missing from the README list.
    - **Freshness filter:** only mine add-ons that support the same expansion/flavors and were updated within the last 12 months (read the Updated date off the CurseForge listing). Dead or wrong-flavor add-ons aren't the current landscape.
    - For each candidate: note the features it has that ours lacks, and which of them fit this add-on's scope and the Style Guide's constraints (static data over API, read-only diagnostics, no CVar side effects, and so on).

    **Ideas only, never code.** Other add-ons' source is not read, copied, or adapted — licenses vary. Take the *feature concept* from the listing/README level and design the implementation fresh against the Style Guide.

3. **Ask a little, then draw.** Combine two idea sources into one candidate list: **gap features** (things competitors have that we don't; say which add-on does it and how popular it appears) and **original ideas** (quality-of-life, options, messaging, or scope extensions no competitor ships; be creative here).

    Then ask **at most four broad questions, in one round** (the direction the add-on should grow, how much scope is welcome, anything off-limits), never one per idea; zero is fine. Then draw every remaining idea into a wireframe per `05 - UX Review.md` → Wireframe Build, titled `{Add-on Name} Feature Ideas`: **Current** beside **Proposed**, one numbered card per idea saying what it does for the player, **why** it's worth building (and which competitor has it, if any), with the Build / Try first / Drop buttons. Publish to the last run's link if one exists. Give the maintainer the link and wait for them to say they've made their choices.

4. **Read the choices and output** per `05 - UX Review.md` → phase 4, with the feature prompts below.

## Feature prompts

For each **Build**, produce one copy-and-run prompt per the preamble's fix-prompt block rules, beginning with `Feature N: short title` on its own line. Include in each prompt: which files it touches (per FILE STRUCTURE), the locale keys it adds (enUS only — the Localization Review handles the rest), the options wiring, any `ns.EVENT_NAMES` / diagnostics-manifest additions, and any note the maintainer wrote on its card. Order the prompts so dependencies come first, and say when one must run before another. Close with a one-line reminder: after running feature prompts, re-enter the pipeline at `02 - Code Review.md`.

This pass does not audit the docs — no wording items, no rule critiques. If you trip over a genuine doc problem anyway, mention it in one line and move on.
