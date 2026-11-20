# Pretty Wide Quest Log: Options Panels

**State:** live: every panel in Options/ is built on Options-Kit.lua and passes the Options Panels checks. No mini-map button. Its font section, reload watcher and Examples-under-their-toggle are the patterns other add-ons borrow.
**Live code:** [`Options/Options.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Options/Options.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Options/Options-General.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Options/Options-Utilities.lua), [`Options/Options-Fonts.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Options/Options-Fonts.lua).
**Needs first:** `Options-Kit.md` (in Common-Core).
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.

## Panel Tree

Same tree, registered through `Kit.RegisterPanel` with each sub-panel's parent key, so every child is a real `AddToBlizOptions` category nested by its parent's ID (Decision 4) and every ID is captured. `AddPanel` and `AddPanelUnder` go: Magic Eraser, Good to Go, Control Freak and Tracking Eye all nest this way on every flavor this add-on ships.

| # | Tree label | Parent | Page title (Decision 8) |
|---|---|---|---|
| 1 | Pretty Wide Quest Log | root | |
| 2 | Wide Quest Log | root | |
| 2a–2d | Quest List, Quest Details, Window & Map, NPC Dialogue | Wide Quest Log | **Wide Quest Log > Quest List**, and so on |
| 3 | Maps & Objectives (with routes) | root | |
| 3a–3c | Mini-map, Zone Map, Wide Map | Maps & Objectives | **Maps & Objectives > Mini-map**, and so on |
| 4 | Quest Route (with routes) | root | |
| 5 | Quest Arrow (with routes) | root | |
| 6 | Quality of Life | root | |
| 7–9 | Profiles, Feedback & Support, Diagnostic Tools | root | |

## Root Page

Description, Enable Welcome Message, Features, Key Bindings (with routes), /Commands.

- **Features** draws `Kit.FeatureSwitches(13)`: pairs at 1.6, in tree order, so Quality of Life moves to last (today it's second).
- **The reload line leaves Features** (Decision 5): `QuestLogReloadPendingText` moves onto the Wide Quest Log panel, where the switch that needs the reload lives, as a `Kit.StatusLine`. It stays on the Quest List, Quest Details, Window & Map and NPC Dialogue panels as today.
- **Key Bindings:** the one row moves onto the grid (Decision 13): caption 2.1, key 0.75, Set Key 0.55 (today 2.0 + 0.85 + 0.55).

## Features

`ns.FEATURES` is new. All `store = "profile"`, none a block (no menu).

| setting | caption today | apply / notes |
|---|---|---|
| `enableWideQuestLog` | `ENABLE_WIDE_QUEST_LOG` | as today |
| `showMap` | (from `OptionsRoutesToggle`) | `gate`: routes loaded; the options panel still lists it |
| Quest Route's setting | (from `OptionsQuestRouteToggle`) | disabled while markers are off, as today |
| `showArrow` | | |
| `enableQualityOfLife` | | `ApplyQualityOfLifeSettings` |

Carry each caption key over from `Options-General.lua`. A routes-only switch hides on a client without routes, as today.

## Panels

- **Wide Quest Log:** Handy Clicks stays: a click name in blue beside what it does is a key-binding-style read-out, not a control.
- **Quest List:** Sorting becomes `Kit.LabelRow` (today 1.4 + 2.0). `SortSubOption`'s caption that drops its silver while disabled stays Pretty Wide Quest Log's.
- **Window & Map:** the scale sliders become `Kit.LabelRow`. Reset Window becomes `Kit.ResetRow` with its confirm (today a blank label and a 1.25 button).
- **Every font section** (`ns.AddFontOptions`): Font, Size and Outline become `Kit.LabelRow` with `Kit.Label`'s tooltip; **Reset Font becomes `Kit.ResetRow` and asks first**: it writes back every font key in the section (Style Guide → SAVED VARIABLES → Reset: confirm when it discards more than one value). README-Notes "Font sections carry Reset Font" stays.
- **Quest Route:** What to Route's Plan Ahead and Route Focus are dropdowns on `Kit.LabelRow`, each with the chosen choice's `_DESCRIPTION` as its `helper` line (`Kit.Helper`), never a status line: a status line is only for something elsewhere changing the page. Search Range is `Kit.SubLabelRow` under Plan Ahead; Line Speed and Line Opacity are `Kit.LabelRow`; Group Up is `Kit.SubToggleRow`. The needs-markers line is the silver `Kit.StatusLine`.
- **Quest Arrow:** its Reset already sits as a label beside its button; it becomes `Kit.ResetRow`, the shape every Reset takes (Decision 10).
- **Maps sub-panels:** `AddSwitchWithSize` becomes `Kit.ToggleRow` with the size select. The "needs markers" line is the parent-off line (Decision 7): `Kit.StatusLine`, silver.
- **Quality of Life:** already draws Examples indented under their toggles; they become `Kit.Example`, and the sound row `Kit.ToggleRow` with `Kit.SoundPreview`.

## Onto the Kit

- Copy `Options/Options-Kit.lua`; delete the five grid lines from `Data/Data.lua`.
- `Options-Utilities.lua`: delete the standard helpers, `OptionsStatusLine`, `OptionsSubLabel`, `OptionsSubRow` (callers pass lists now), `OptionsExampleRow`, `RenderSample` (becomes `Kit.PrintedLine` / `Kit.SentLine`). Keep `OptionsRoutes*`, `OptionsSizeValues`, the reload watcher.
- `Options.lua`: `Kit.RegisterPanel` calls; delete `AddPanel`, `AddPanelUnder`.
- **One Refresh:** sets keep their feature applies, then call `ns.RefreshSettings()`. Today none repaints, so a change on one panel shows stale on the others until it's reopened.

## Strings

`OPTIONS_RESET` "Reset" replaces the Reset Font and Reset Window button keys (each keeps its row caption and confirm). `ZONE_SHARE_SOUND_PREVIEW` → `OPTIONS_SOUND_PREVIEW_DESCRIPTION`.

## Keeps

README-Notes: Font sections carry Reset Font; Prints lead with the Short Name; Party whispers are fixed text.

## Check in Game

- [ ] Every sub-panel nests under its parent on Classic Era, TBC Anniversary and Mainline, and `ns:OpenOptionsPanel` opens each docked.
- [ ] Reset Font asks first.
- [ ] Turn the Wide Quest Log off and on: the reload line shows on its own panel and its children, not on the root page.
