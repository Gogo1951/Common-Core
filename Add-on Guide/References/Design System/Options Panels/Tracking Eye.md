# Tracking Eye: Options Panels

**State:** the live reference for Features Mirror: the only add-on with `ns.FEATURES`, `ns.OptionsFeatureSwitch`, `ns.RefreshSettings` and sub-panel titles. Its registration (`Register` / `RegisterChild`, every frame and category ID kept, `ns:OpenOptionsPanel(panel)`) is the kit's. Second to convert.
**Live code:** [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Options/Options-Utilities.lua), [`Options/Options.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Options/Options.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Options/Options-General.lua), [`Features/Utilities.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Utilities.lua) (`ns.RefreshSettings`).
**Needs first:** `Options-Kit.md` (in Common-Core).
**Labels:** `Type: Refactor`, `Area: Options`.
**Issue:** not filed yet.

## Panel Tree

Unchanged:

| # | Tree label | Parent | Page title |
|---|---|---|---|
| 1 | Tracking Eye | root | |
| 2 | Persistent Tracking | root | |
| 3 | Farm Mode | root | |
| 3a | Abilities | Farm Mode | Farm Mode > Abilities |
| 4 | Target Tracking | root | |
| 5 | Come & Get It | root | |
| 6 | Free Placement Mode | root | |
| 7–9 | Profiles, Feedback & Support, Diagnostic Tools | root | |

## Root Page

Unchanged: description, Enable Welcome Message, Enable Mini-map Button (disabled while Free Placement Mode is on), the Blizzard tracking-button hook, Features, Key Bindings, /Commands.

- **Features** draws `Kit.FeatureSwitches(23)`: the same five switches from the same `ns.FEATURES`, the same 1.6 pairs.
- **Key Bindings:** the Cycle Farm Mode Ability row moves onto the grid (Decision 13): caption 2.1, bound key 0.75, Set Key 0.55 (today 1.9 + 0.85 + 0.55 = 3.3).

## Features

`ns.FEATURES` keeps its five records and order. Two additions from the kit's record shape:

| setting | Adds |
|---|---|
| `farmMode` | `click = "ShiftLeftButton"` |
| `targetTracking` | `click = "ShiftRightButton"`, `gate = ns.KnowsHuntAbility` |

With `click` and `gate` on the records, the menu's three blocks can read `ns.FEATURES` the way More Features already does, instead of being written out by hand in `BuildMainEntries` (Features Mirror: "the Features section and the menu both build from it"). That move belongs to the menu's Menu-Kit v2 step (`Mini-map Menus/Tracking Eye.md` → Code); this spec only adds the fields.

## Panels

- **Persistent Tracking:** the three override rows become `Kit.SubToggleRow`. Unchanged to look at.
- **Farm Mode:** Silence Sounds and Zoom Out become `Kit.SubToggleRow`; the local `FarmSpacer` and `FarmDesc` become `Kit.Spacer` and `Kit.Desc`, which take `hidden`. Cycle Speed becomes `Kit.LabelRow` with `Kit.GetChoice` (today label 1.8 + select 1.6; the kit's 2.1 + 1.3 puts it in every other dropdown's column).
- **Abilities:** unchanged. Its class groups and spell toggles are Tracking Eye's.
- **Come & Get It:** the Default Output row becomes `Kit.LabelRow` with its note as the `helper` line, which the Style Guide now allows, so the README-Notes entry "Default Output note" retires. A spacer separates it from the switch above, and the Example closes its field set: a spacer, `Example:`, the line indented under it (Decision 6), from `Kit.SentLine` for party and whisper.
- **Free Placement Mode:** Icon Shape and Icon Size become `Kit.SubLabelRow`, so both controls sit in the 1.3 column (today a 0.9 label, totalling 2.015 and 2.915).

## Onto the Kit

- Copy `Options/Options-Kit.lua` from Common-Core, first in the TOC's Options group.
- `Data/Data.lua`: delete the five `ns.OPTIONS_*` grid lines.
- `Options/Options-Utilities.lua`: delete `ns.OptionsFeatureSwitch`, `ns.OptionsFeatureSwitchRows`, `ns.SubPanelTitle`, the four standard helpers, `OptionsSubLabel`, `OptionsSubRow`. Keep `ns.FEATURES`; add the `Kit.SetText` call.
- `Options/Options.lua`: `Register` and `RegisterChild` become `Kit.RegisterPanel`; delete `ns:OpenOptionsPanel` and `ns.IsOptionsPanelOpen` (the kit's do the same, Farm Mode's pause included).
- `Features/Utilities.lua`: delete `ns.RefreshSettings`; the kit's replaces it and loads after it.
- The two hand repaints that aren't settings writers stay: `UPDATE_BINDINGS` (`Features/Core.lua:307`) and the Come & Get It herb load (`Options-Come-and-Get-It.lua:64`).

## Strings

| Old | New |
|---|---|
| `SAMPLE_LOADING_ITEM` | `LOADING_ITEM` |

## Keeps

README-Notes: Free Placement Mode opens options. (Default Output note retires: helper lines are the rule now.)

## Check in Game

- [ ] Every panel looks as it did, apart from the Cycle Speed, Free Placement and key binding columns and the indented Example.
- [ ] Flip each Features switch with the menu open, then each menu row with options open: both follow; the same after a profile switch.
- [ ] With an options panel open, Farm Mode stays paused; closing the Settings window resumes it.
