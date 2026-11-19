# Good to Go: Options Panels

**State:** live: every panel in Options/ is built on Options-Kit.lua and passes the Options Panels checks.
**Live code:** [`Options/Options-Feature-Switches.lua`](https://github.com/Gogo1951/Good-to-Go/blob/main/Options/Options-Feature-Switches.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Good-to-Go/blob/main/Options/Options-Utilities.lua), [`Options/Options-Item-Lists.lua`](https://github.com/Gogo1951/Good-to-Go/blob/main/Options/Options-Item-Lists.lua), [`Options/Options.lua`](https://github.com/Gogo1951/Good-to-Go/blob/main/Options/Options.lua).
**Needs first:** `Options-Kit.md` (in Common-Core). Pairs with `Mini-map Menus/Good to Go.md`.
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.
**Issue:** not filed yet.

## Panel Tree

Unchanged: General; Buff Duty (Tracked, Self-Buffs, Weapon Buffs); Restocker; Enhanced Spellbook; Consumable Macros (Class & Race, Ignore List); Rank Watch (Tracked, Ignored); Inventory Report; Readiness Report; Profiles, Feedback & Support, Diagnostic Tools. `RegisterChild` becomes `Kit.RegisterPanel`, which does the same job.

The feature subfolders stay: they're how a large add-on keeps a panel's files together, and FILE STRUCTURE doesn't forbid them. **Proposed rule** (README → Patterns → Panel files): a panel with more than one file gets a subfolder `Options/<Feature>/`, its helpers in `Options-<Feature>-Utilities.lua`.

## Root Page

Description, Enable Welcome Message, Enable Mini-map Button, Features, Key Bindings, /Commands with `/restock` and the Rank Watch ignore command.

- **Features** draws `Kit.FeatureSwitches(23)` (Decision 5): **no spacer between the two groups** (today Buff Duty … Rank Watch, a blank line, then the two reports). `ns.FEATURES` order is the menu's: its blocks first, then More Features, so the menu spec decides where the reports land.
- **Key Bindings:** rows on the grid (Decision 13): caption 2.1, key 0.75, Set Key 0.55 (today caption 2.1, status 0.65, Set Key 0.55 = 3.3).

## Features

`ns.FEATURES` replaces `FEATURE_SWITCHES` and `ns.FEATURE_GROUPS`, in `Options/Options-Utilities.lua` (or kept in `Options-Feature-Switches.lua`, loaded before the panels). Every record keeps its setting, its caption and desc, and its confirm:

| Good to Go's field | Kit field |
|---|---|
| `key` (in `db.global`) | `store = "global"`, `setting = key` |
| custom `get` / `set` | `apply` for the set; a custom get becomes a `setting` path the kit can read, or stays in `apply`'s write |
| `confirmOff` | `confirm` (the kit asks only when switching off, as `confirmOff` does) |
| `notifies` | gone: `ns.RefreshSettings` repaints everything |

The caption keys mix three families today (`BUFF_DUTY_ENABLE`, `OPTIONS_RESTOCKER_ENABLE`, `SWITCH_*`); they keep their names (no sweep). New keys take `OPTIONS_ENABLE_*`.

## Panels

- **Buff Duty:** the "no buffs" status line becomes `Kit.StatusLine`; the "none ticked" line `Kit.WarningLine` (it is `OptionsGroupContextNone` today, which stays as the builder of that line). The When rows become `Kit.ToggleRow` with their Where select. The favor switch and its duration become `Kit.ToggleRow`. The party Example becomes `Kit.Example` with `Kit.SentLine`.
- **Tracked, Self-Buffs, Weapon Buffs:** class- and category-grouped boxes stay Good to Go's. `OptionsAbilityLabel` becomes `Kit.Label` with a `desc`, or stays where it needs a spell hyperlink tooltip (InteractiveLabel with `tooltipHyperlink`).
- **Restocker:** the sound row becomes `Kit.ToggleRow` with `Kit.SoundPreview`. Every Example becomes `Kit.Example`.
- **Enhanced Spellbook:** the two delete-macros buttons keep their confirm; width moves from 1.5 to `Kit.CONTROL_WIDTH` beside a caption (`Kit.ResetRow` shape without the gray, Decision 10).
- **Consumable Macros:** the IconCheckBox widget stays. Mode selects become `Kit.ToggleRow` or `Kit.SubLabelRow`.
- **Ignore List:** `Kit.ItemList` (Good to Go's own builder goes; the kit's adds the existence check Good to Go's has, and Clear). The profile-scoped tree stays; `Kit.PrepareTree` sets its 176 sidebar.
- **Readiness Report:** its Reset becomes `Kit.ResetRow` (today `width = "double"`), still ungated and confirmed.

## Onto the Kit

- Copy `Options/Options-Kit.lua`; delete the grid from `Data/Data.lua` (`INLINE_*`, `ALIGNED_LABEL_WIDTH`, `LINK_WIDTH`, `PROMOTE` stay Good to Go's).
- `Options-Utilities.lua`: delete the standard helpers, `OptionsSubRow`, `OptionsSubLabel`, `OptionsExample`, `OptionsWhisperExample`, `OptionsChatExample`, `Build*ExampleLine` (become `Kit.Example` with `Kit.SentLine` / `Kit.PrintedLine`), `DefineSoundPreview`, `SubPanelTitle`.
- `Options-Item-Lists.lua`: delete the cache, parse, sort, display name, `OptionsRemoveIcon` and `BuildItemListOptions`; `Options-Widgets.lua` loses the ItemLink widget (the kit's).
- `Options.lua`: `Kit.RegisterPanel`; delete `ns:OpenOptionsPanel`, `ns.optionsFrames`.
- **One Refresh:** delete `NotifyAllPanels` and every per-panel `Refresh()`; sets that end in nothing today (`ReminderModeSelect`, Readiness toggles, Welcome) end in `ns.RefreshSettings()`.
- **Profiles:** `noDefaultProfiles = true` (tagged MIGRATION in `Options-Profiles.lua:19-22`) is the one departure from the stock one-liner. Leave it to its migration window; the Profiles panel is inherited and nothing else touches it.

## Strings

`OPTIONS_RESTOCKER_SOUND_PREVIEW` → `OPTIONS_SOUND_PREVIEW_DESCRIPTION`; `OPTIONS_RESET` joins.

## Keeps

README-Notes: Options command takes an ignore argument; Rank Watch's reset reaches its account-wide settings. (Readiness Report Example shows several lines retires: a several-line Example is the rule now, through `Kit.Example` with a list of lines.)

## Check in Game

- [ ] Turn Enhanced Spellbook off from the root page: it asks first, as its panel does.
- [ ] The Features section has no blank line inside it.
- [ ] The Ignore List refuses an item ID the client doesn't know.
