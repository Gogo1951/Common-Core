# WoW Add-on Code Review (Review-Only, 5-Phase)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Code Review`. Write scope: **nothing — report only.** Do not create, edit, or delete any files, including scratch or temp files, beyond the preamble's `README-Notes.md` record. Your only output is the Phase 4 report, in this chat.

## Workflow — five phases (0–4), all required

0. **Permissions** — per the preamble.
1. **Review.** Read the preamble's read-first docs and `References/Style Guide - Build Reference.md`, then everything in scope (see Standards and Ignore): the add-on's code, which is the whole record (READMEs are skipped; see Ignore). Build a full picture of what the add-on does and how. No output yet.
2. **Know where the reference implementations live** (you rarely need to fetch them). They are named at each rule's own site in the Style Guide. Fetch one only if a rule points to an implementation detail you can't resolve from the guide itself.
3. **Clarify — required, before any findings.** Identify what you'd need to know to be confident in your findings, and ask per the preamble. Ask about things that bear on the review, not trivia: whether a frame is ever shown in combat, which client a behavior targets, whether a departure that looks deliberate is intentional (check `git status` and the recent `git log` first, per Style Guide → README-NOTES). No findings until you're confident and any answers are in.
4. **Report.** Produce the report below.

## Standards

Apply two standards together:
1. **The Style Guide** (`References/Add-on Creation Rules & Style Guide.md`) — authoritative wherever it speaks.
2. **Your own judgment** on everything it doesn't cover — correctness, taint and secure-frame usage, event-registration efficiency, combat-time performance, in-combat reads that go secret on WoW Forever's Retail engine (Style Guide → COMPATIBILITY), frame and memory leaks, SavedVariables hygiene, deprecated/removed API for the target client, and localization patterns.
The guide is the floor: catch everything it catches, then catch more. If your judgment conflicts with the guide on a style matter, follow the guide but flag the disagreement.

**Reference check — required before any finding that changes what players see.** Fetch the rule's Live reference from GitHub `main` and confirm it does what the rule says. If it does the opposite, that's not a finding against this add-on. Ask about it in Phase 3, quoting the rule and the reference's code, and leave the add-on as it is until the maintainer rules (Style Guide, opening rules).

Always run one explicit sweep: search every reviewed file (including TOCs) for `MIGRATION` tags. A migration past its tagged remove-after date is deleted on sight: tag, migration branch, and legacy TOC entry. A migration still inside its 30-day window stays (Style Guide → SAVED VARIABLES → Migration Windows); one missing its remove-after tag gets the tag added, never deleted.

Always run one explicit **other-client character sweep**. Find the database setup with:

```
grep -rn 'AceDB-3.0"):New\|PruneOtherClientCharacters' --include="*.lua" . | grep -v Includes/
```

Check it against Style Guide → SAVED VARIABLES → Other-Client Characters, which is the full specification. Each of these is a finding:
- `PruneOtherClientCharacters` is missing, or isn't the next line after `AceDB:New`.
- Its code differs from the reference: it skips `profileKeys`, the character's own profile (Per-Character) or namespaces, it deletes a profile a staying character still uses, or it decides by realm names.
- It's tagged `MIGRATION` or prints anything.
- The add-on has `Tests/Run.lua` but no test for each direction.

Its fix prompt copies the reference code word for word, adds both tests where the add-on has offline tests, and must not claim it works in game until a load on WoW Forever and on one realm client confirms the copied characters are gone.

Always run **luacheck** over the add-on in Phase 1 (`Includes/` excluded, per the repo's `.luacheckrc` — Style Guide → LINTING). Its warnings are ordinary findings; a missing `.luacheckrc` is one too.

Always run one explicit **comment-accuracy sweep**. Every comment must describe what the code actually does now; a comment that contradicts current behavior is a finding. The fix corrects or deletes the comment, never the code (Style Guide → COMMENTS). Also flag the obvious noise — commented-out code, decorative banners, and comments that only restate the code — per Style Guide → COMMENTS. Sanctioned `TODO:` markers are exempt; leave them. The `Data/{Game}/` files' comments belong to the Data Review, so this sweep skips them. This sweep keeps comments *true* and catches egregious clutter; the wholesale volume trim is its own pass (`References/Code Comment Cleanup Prompt.md`), so don't flood the report with every borderline comment — flag what's wrong or clearly noise, and let the cleanup pass do the rest.

Always run one explicit **game-name sweep** against Style Guide → GAME NAMES, which is the full specification. Two parts:

- **`enUS.lua` values that name a game record** — a spell, item, skill, zone, class or Blizzard UI label. Each is a finding: its fix stores the record's ID and asks the client for the name, and retires the key.
- **Every place code compares a name**, found with:

```
grep -rn "GetSpellName\|GetSpellSubtext\|GetItemInfo\|GetSkillLineInfo\|GetTradeSkillDisplayName\|GetMapInfo\|GetZoneText\|LOCALIZED_CLASS_NAMES\|_G\[" --include="*.lua" . | grep -v Includes/
```

For each hit that is matched against something the client shows, check that both sides are the same kind of record (a spell name searched in the skill list finds nothing in frFR — GAME NAMES → Match the Record Kind), and that no ID-returning API was available instead. A mismatch is a finding even when enUS works. Its fix prompt must include GAME NAMES → Checking a New Lookup, steps 1–3, and must not claim it works in-game until step 4 is done.

Always run one explicit **performance sweep** over the add-on's hot paths — `OnUpdate` handlers, `COMBAT_LOG_EVENT_UNFILTERED` and other high-frequency events, and anything that runs per-frame or in combat. Flag: table or closure allocation inside a hot path (hoist it out), `string.format`/string building done every frame when it could be cached or event-driven, polling where an event would do, repeated `C_Item.GetItemInfo`/API calls that static data could replace (see Style Guide → DATA; a name is never stored, so cache the looked-up one instead, per GAME NAMES), and unbounded growth in a cache or event buffer. Combat-time work that could be deferred to a dirty-flag replay is a finding. These are judgment calls rather than guide rules — mark them reduced-confidence where the impact depends on how hot the path really is.

Always run one explicit **Options-panel-open sweep**. Find the routing with:

```
grep -rn "OpenToCategory\|AddToBlizOptions\|SlashCmdList\|InCombatLockdown" --include="*.lua" . | grep -v Includes/
```

Then check it against Style Guide → OPTIONS PANEL → Opening the Panel, Combat Guard, and Slash Commands, which are the full specification. A missing opener or missing options command is itself a finding; the recurring defect is the name/title lookup that section forbids. Any fix prompt for this must direct that the changed file be run through `stylua --syntax lua51` and verified with `luac -p` and luacheck, and must **not** claim it works in-game — it needs a `/reload` and a manual test on every flavor.

Always run one **mandated-copy sweep**, so the strings are in place before Copy Review and Localization run. Check `L["CHAT_LOADED"]` against Style Guide → WELCOME MESSAGE, and that `PrintWelcome` prints at every login while `showWelcome` is on, with no version or first-login gate, and check the Feedback & Support panel against OPTIONS PANEL → Feedback & Support Panel: the Help [Add-on Name] Level Up paragraphs, the link order, the copy caption and the version line. Old Help [Add-on Name] Grow copy and links still on the General panel count as a difference. Every difference is one finding, and its fix prompt writes the mandated `enUS.lua` values and the panel code, with the Full Name filled in.

## Ignore

- **`.pkgmeta`, `.github/` (workflows), and `LICENSE`** — packaging and release wiring are reviewed by the Prelaunch Review, not here. Don't review their contents and don't flag their absence.
- **`Diagnostics/`** — `03 - Diagnostics Review.md` owns it. Only its load-time wiring (TOC entries, the dispatcher's one logging call) is reviewed here.
- **Includes folder** — don't review its contents. Separately, do verify its files are correctly referenced (in every TOC and any XML), and that every file a TOC references exists.
- Any **.tga** files.
- **Locales folder** — except enUS.lua, which should be reviewed.
- **Every README** (`README.md`, `README-Technical.md`, `README-Testing.md`) — skip entirely. Each describes the last release until steps 9–11 rewrite it from the code (Pass Preamble → Standing scope), so one that disagrees with the code is never a finding or a question. `README-Notes.md` is the exceptions record and is read as the preamble says.

## Report format

Open with a 2–3 sentence summary. Then list the issues, most worth fixing first — no severity labels except **Blocker** where the Pass Preamble names one (a missing target TOC), listed first; no category groupings. Keep the report tight: the description and the fix prompt are the whole issue; no padding, no restating the obvious.
Skip trivial style observations the guide doesn't address; within scope, report everything it does address regardless of triviality.

**Trim `README-Notes.md` first.** Before Phase 3, delete every entry in it that doesn't matter (Style Guide → README-NOTES → Only what matters), in `## Exceptions` and `## Decisions` alike, without asking. What they covered becomes ordinary findings, and the report says in one line which labels went.

**Legacy decisions.** If `README-Notes.md` still has a `## Decisions` section after that trim, the report's last issue is one fix prompt that empties what it can. For each entry about code, it adds a comment at that code per Style Guide → COMMENTS, reads it back, and deletes the entry once the comment is confirmed. It deletes UI copy, layout and `Declined:` entries outright, leaves entries about rows kept out of a data table for the Data Review, deletes the heading if nothing is left, and lists each comment it added as `file: comment`.

Fix-prompt block rules and the non-developer description rule are in the preamble. One addition here: if a fix must run after another issue's fix, say so in one clause inside the Description — there is no separate field for it.

Use this block per issue:

### Issue N: short title
**Description:** Plain-language user story for a non-developer (see above) — what the player experiences and why it matters.
**Fix prompt:**
```
Issue N: short title
A complete, runnable fix prompt following the rules above.
```
