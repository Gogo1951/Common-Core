# WoW Add-on Diagnostics Review (Editing, Diagnostics Only)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Diagnostics Review`. Write scope: **the `Diagnostics/` folder, the TOC lines that load it, `ns.EVENT_NAMES` and the dispatcher's one logging call in `Features/Core.lua`, and the add-on's offline Event Log tests.**

The Diagnostic Tools panel is what a player pastes into a bug report, so it should capture everything that could explain a bug, and nothing that changes the game. This pass makes it so: the framework is current, every manifest covers the add-on's whole surface, and the context probe answers every "nothing happens" report the add-on could get.

**This pass asks nothing and hands back nothing to apply.** The code is the evidence: every change the checklist calls for, it makes, and it says what it did.

## Workflow — five phases (0–4), all required

0. **Permissions** — per the preamble.
1. **Review.** Read Style Guide → DIAGNOSTIC TOOLS and `References/Style Guide - Build Reference.md` → DIAGNOSTIC TOOLS, then the add-on's `Diagnostics/` folder and everything it probes: the dispatcher in `Features/Core.lua`, every feature file, the data folders, the options, and the saved-variables defaults. Fetch Magic Eraser's live [`Diagnostics/`](https://github.com/Gogo1951/Magic-Eraser/tree/main/Diagnostics) folder for comparison (and Pretty Wide Quest Log's Message Length report when the add-on sends chat or writes macros). Build a full picture of every way a feature can silently fail to fire.
2. **Apply.** Make every change the checklist below finds, one checklist area at a time. After each, run the changed files through `stylua --syntax lua51`, `luac -p` and luacheck, fix what they flag, and give one status line, for example: `Manifests: added 3 events, 2 API checks and the Bags data row; probe now reads the combat and level gates.`
3. **Report.** A 2–3 sentence summary, then the status lines in order, then one line per rule Magic Eraser's folder breaks (Framework current). Never claim the panel works in-game: end by telling the maintainer to open it and run every report on every flavor, then give the Copy to Other Flavors command. A clean run changes nothing and says so.
4. **Worth Running Data Review?** Last, just before the Next Pass offer, one line: yes or no, and why. **Yes** when a file under `Data/` or a TOC's data lines changed since the last release tag (`git diff --stat $(git describe --tags --abbrev=0) -- Data/ '*.toc'`), when this pass added a data-source row, or when the maintainer mentioned a new game patch or build. **No** when the release left the data alone, as a small fix or a settings change does. An add-on with no data files says no and gets no step 5 offer. Either way, a Validate Data report that flags a bad or missing ID in the in-game test makes it worth running. On no, the step 5 offer says it can be skipped.

## Checklist

**Framework current.** Every file outside the re-authored surface (Style Guide → DIAGNOSTIC TOOLS → Live Reference) matches Magic Eraser's live copy, its panel copy included (Style Guide → DIAGNOSTIC TOOLS → Strings); diff them, and copy the live file over any that differs. Where the rules and the live copy disagree, follow the rule, and the report says in one line that the reference needs the fix too, so later copies inherit it.

**Every manifest covers the whole surface.** Find the surface with:

```
grep -rn "RegisterEvent\|RegisterUnitEvent\|GetCVar\|C_CVar\|IsPlayerSpell\|IsSpellKnown\|C_Spell\.\|C_Item\.\|C_Map\.\|C_TradeSkillUI\." --include="*.lua" . | grep -v "Includes/\|Diagnostics/"
```

- **Events** — every registered event is in `ns.EVENT_NAMES` and routes through the dispatcher.
- **API checks** — every API COMPATIBILITY routes, and every load-bearing API the core loop depends on, has a row in `ns.DIAGNOSTIC_API_CHECKS`.
- **Data sources** — every file in every flavor folder has a row in `ns.DIAGNOSTIC_DATA_SOURCES`.
- **Name lookups** — every game record the add-on names by ID has a row in `ns.DIAGNOSTIC_NAME_LOOKUPS`.
- **Spells and CVars** — every spell the add-on gates on is in `ns.DIAGNOSTIC_SPELLS`, and every CVar it reads or writes shows in a probe.
- **Saved Variables** — the dump reaches every table the add-on saves, and prints every row a player can edit.

Add what's missing, and drop any row for something the add-on no longer uses.

**The context probe answers "nothing happens."** For each feature, list every reason it could fail to fire: a setting off, a gate (combat, level, class, zone, instance), a spell not known, an API returning nil, an empty cache, an item not loaded. The probe prints each one's current value; add the read for any it can't show. This is the check that makes the panel worth having; spend the time here.

**All five tabs** (four without data files; Style Guide → DIAGNOSTIC TOOLS → Layout), each with every report it should hold, the Localization tab included (Build Reference → DIAGNOSTIC TOOLS → Localization Tab).

**Event Log** — the dispatcher's one guarded call, the buffer and argument caps, and firehose events handled per Build Reference → Event Log Noise, with its three tests where the add-on has offline tests. An add-on that registers any `CHAT_MSG_*` event carries the privacy hint.

**Hard rules** — read-only and side-effect free, nothing on load or on panel open, the enable gate runtime-only and off by default, off means off, strings plain English in `ns.DiagnosticsStrings`, and every report opening on the full Report Header.
