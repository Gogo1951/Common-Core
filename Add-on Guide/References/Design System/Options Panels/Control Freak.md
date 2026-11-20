# Control Freak: Options Panels

**State:** the live reference for label-beside-control rows, dropdowns and Example lines. The deepest tree (four levels), built from one alert section builder (`ns.AddWhoseAlertSection`) whose slots every alert panel fills. No `ns.FEATURES` (Features is drawn from `FEATURE_GROUPS` plus two local tables) and no shared refresh: most sets end in nothing.
**Live code:** [`Options/Options-Alert-Section.lua`](https://github.com/Gogo1951/Control-Freak/blob/main/Options/Options-Alert-Section.lua), [`Options/Options-Feature-Scope.lua`](https://github.com/Gogo1951/Control-Freak/blob/main/Options/Options-Feature-Scope.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Control-Freak/blob/main/Options/Options-General.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Control-Freak/blob/main/Options/Options-Utilities.lua).
**Needs first:** `Options-Kit.md` (in Common-Core). Pairs with `Mini-map Menus/Control Freak.md`: both read the `ns.FEATURES` built here.
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.

## Panel Tree

Unchanged, under README-Notes "Group pages in the settings tree" and "Sub-panels nest by category ID": root, the Monitoring and Naughty List group pages, their feature tabs, each Tracked Abilities sub-panel ("Taunts > Tracked Abilities"), Tanking Tools and its two tools. Every feature panel registers as its builder function through `Kit.RegisterPanel` (today only Diagnostics does).

## Root Page

Description, Enable Welcome Message, Enable Mini-map Button, Master Switch (README-Notes), Features, /Commands.

- **Master Switch:** Enable Control Freak becomes a full-width `Kit.FeatureSwitch`-style toggle (today drawn through the pair helper at 1.6, alone on its line).
- **Features** (Decision 5, decided: three blocks only): today three gold block switches, each over its children in indented pairs, the child captions bare names with spell icons, the children grayed while their block is off. Proposed: `Kit.FeatureSwitches` over `ns.FEATURES`, which holds what the menu holds, **the three blocks**: Enable Monitoring, Enable Naughty List, Enable Tanking Tools, two to a line. Each child feature's switch stays on its own tab (and its group page lists them), so nothing is lost from options; the root page stops carrying sixteen switches and their icons.

## Features

`ns.FEATURES` is new, built from `ns.FEATURE_GROUPS` and `ns.TANKING_TOOLS` so neither is restated:

| setting | name | block | click (menu spec) | apply |
|---|---|---|---|---|
| `featureGroups.monitoring` | `OPTIONS_MONITORING_LABEL` | yes | Left-Click | `ns:ApplyProfile()` today; becomes the side effect, then `ns.RefreshSettings()` |
| `featureGroups.naughtyList` | `OPTIONS_NAUGHTY_LIST_LABEL` | yes | Right-Click | same |
| Tanking Tools' enable | `TAB_TANKING_TOOLS` | yes | Shift + Left-Click | same |

The menu's spec reads these records for its blocks; its master switch reads the root panel's Enable Control Freak (Blocks Beyond Features).

## Panels

- **`ns.AddFeatureScope`:** the Enable switch beside the role ladder becomes `Kit.ToggleRow` with the ladder as `control`, so the ladder leaves while the feature is off (today it stays). The scope sub-rows become `Kit.SubToggleRow`. `ns.AddQuietStatus` becomes `Kit.StatusLine` with the same text: it is the parent-off line (Decision 7), already silver, and its red "off" word turns silver too (Decision 9).
- **`ns.AddWhoseAlertSection`** stays Control Freak's: its slots (control, caption rows, whose rows, marked row, extra rows, sound, sample, after-sample) are this add-on's alert model. Inside it:
  - the frame becomes `Kit.Section`;
  - the sound row becomes `Kit.ToggleRow` with the sound select as `control` and `Kit.SoundPreview` as `preview`. Its cells total 3.4 plus the speaker past the end, the same as GogoLoot's (today 3.55, by design; the kit keeps the over-the-edge speaker);
  - the sample becomes `Kit.Example`, indented under the rows it shows (Decision 6), built with `Kit.PrintedLine` and `Kit.SentLine`;
  - the whisper cooldown select hides with its whisper switch (today it stays: `Options-Alert-Section.lua:236-247`).
- **The Example follows Print, not only Announce.** With Announce on Never and Print unticked, nothing is printed or sent, so no Example shows (today it shows the print form: `Options-Alert-Section.lua:442-444`).
- **Tank Deaths:** its class Example's `name` becomes a function, so it follows the settings (`Options-Tank-Deaths.lua:121-130`).
- **Bad Parry Monkeys:** the message row's Reset becomes `Kit.ResetRow` under the box, keeping its "gray while it's the default" (Decision 10).
- **Tracked Abilities:** `ns.BuildAbilityToggles` and the `SpellToggle` widget stay Control Freak's.

## Onto the Kit

- Copy `Options/Options-Kit.lua`. `Data/Data.lua`: delete the standard grid; `OPTIONS_SPEAKER_WIDTH` and `OPTIONS_SUB_LABEL_WIDTH` go (the kit's); `GROUP_LABEL`, `SUB_CAPTION_*` stay Control Freak's.
- `Options-Utilities.lua`: delete the standard helpers, `OptionsTogglePairs`, `SubPanelTitle`, `NeverHidden`, `OptionsSubLabel`, `OptionsSubRow`, `DefineSoundPreview` (18 points; the kit's is 16, Decision 11). Keep `AddGatedHeader`, `OptionsSubCaptionRow`, `GetSoundValues`, `BuildCooldownValues`.
- `Options.lua`: `AddSubPanel` becomes `Kit.RegisterPanel(key, builder, name, parentKey)`; delete `ns:OpenOptionsPanel`.
- **One Refresh:** every `set` ends in `ns.RefreshSettings()`. Switches that also need `ns:ApplyProfile`'s work (combat-log registration) call that work first. Today sections, rows, sound, whisper, effects, abilities and welcome end in nothing.

## Strings

`ALERT_SOUND_PREVIEW_DESC` → `OPTIONS_SOUND_PREVIEW_DESCRIPTION`; `OPTIONS_RESET` "Reset" replaces the GlobalString `RESET` on the Bad Parry Monkeys row. New: `OPTIONS_ENABLE_MONITORING`, `OPTIONS_ENABLE_NAUGHTY_LIST` (Tanking Tools has its enable key). Keys keep `_DESC`; new keys take `_DESCRIPTION`.

## Keeps

README-Notes: Enable Control Freak under Master Switch; Group pages in the settings tree; Sub-panels nest by category ID; Mini-map tooltip while All Alerts is off; Brand last on local alert prints.

## Check in Game

- [ ] Untick Print and set Announce to Never on any alert: the Example leaves.
- [ ] Turn a feature off: its role ladder and whisper cooldown leave with it.
- [ ] Flip Monitoring in the menu with the root page open: the switch follows.
