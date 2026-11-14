# Play It Forward: Options Panels

**State:** the live reference for the Combat Guard. No mini-map button. Its Features switches and its feature panels each declare their own toggle for the same setting, nothing calls a shared refresh, and two of its resets skip a confirm.
**Live code:** [`Options/Options.lua`](https://github.com/Gogo1951/Play-It-Forward/blob/main/Options/Options.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Play-It-Forward/blob/main/Options/Options-General.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Play-It-Forward/blob/main/Options/Options-Utilities.lua).
**Needs first:** `Options-Kit.md` (in Common-Core).
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.
**Issue:** not filed yet.

## Panel Tree

| # | Tree label | Parent | Today | Proposed |
|---|---|---|---|---|
| 1 | Play It Forward | root | table, name `ns.ADDON_TITLE` | builder function, `L["ADDON_TITLE"]` |
| 2 | What to Give Away | root | table | builder function |
| 3 | Recipients | root | table | builder function |
| 3a | My Alts | Recipients | function, tree | title **Recipients > My Alts** (Decision 8) |
| 3b | My Guilds | Recipients | function, tree | title **Recipients > My Guilds** |
| 4 | Mail Message Text | root | table | builder function |
| 5 | Badge of Generosity | root | table | builder function |
| 6–8 | Profiles, Feedback & Support, Diagnostic Tools | root | | unchanged |

`ns:OptionsPanelRoute()`, which both the opener and the Diagnostics manifest read, stays: the kit's `ns:OpenOptionsPanel` routes the same way, and Diagnostics keeps reading the route. Point `OptionsPanelRoute` at the kit's captured ID.

## Root Page

Description, Enable Welcome Message, Features, /Commands. No mini-map toggle (no button).

- **Features** draws `Kit.FeatureSwitches(23)` (pairs at 1.6; today three flat toggles at exactly 1.7, on the wrap edge).
- **Captions gain Enable** (Decision 5): each becomes Enable and the feature's name, as every other add-on's are. Today's captions are verbs (Distribute Gear, Share Badge of Generosity), so "Enable Distribute Gear" won't do: the maintainer words the three feature names (a noun each, such as Gear Giving), and the panels keep their own titles.

## Features

`ns.FEATURES` replaces the local `FEATURES` in `Options-General.lua`, in its order. All `store = "profile"`, none a block (no menu).

| setting | caption today | apply |
|---|---|---|
| `includeGear` | `OPTIONS_DISTRIBUTE_GEAR` | `ns.RefreshMailWindow` |
| `includeConsumables` | `OPTIONS_DISTRIBUTE_CONSUMABLES` | `ns.RefreshMailWindow` |
| `shareStats` | `OPTIONS_SHARE_STATS` | — |

- **One switch, two places.** What to Give Away and Badge of Generosity draw `Kit.FeatureSwitch(setting)` instead of re-declaring the toggle (`Options-Give-Away.lua:81,114`, `Options-Generosity.lua:152`). Distribute Gear's rarity select rides with it as `Kit.ToggleRow`.
- The mail window's top bar writes the same settings: it calls `ns.RefreshSettings()` instead of notifying General and What to Give Away by hand (`UI-Top-Bar.lua:79-85`).

## Panels

- **What to Give Away:** Distribute Gear and Disenchant Unmatched Gear become `Kit.ToggleRow`; Level Rule becomes `Kit.SubLabelRow`; the five kinds `Kit.SubToggleRow`. The file-local `SubRow` and `ns.OptionsHelp` go.
- **Recipients:** unchanged in shape. Its class grid is Play It Forward's. Restore Defaults becomes `Kit.ResetRow` with its confirm (README-Notes: Spec Restore Defaults).
- **My Alts, My Guilds:** `Kit.PrepareTree` replaces `PrepareListTree` (sidebar 176, today 180, Decision 12). Gear Levels become `Kit.Row` pairs on `Kit.TREE_LABEL_WIDTH` / `TREE_CONTROL_WIDTH`, so they stop laying out flat. Forget keeps its confirm.
- **Guild remove asks first:** a guild carries per-member settings, so its remove icon confirms (Build Reference → Item Lists: confirm what takes real effort to rebuild). Today it removes on one click.
- **Mail Message Text:** the editor widget stays. Restore Default becomes `Kit.ResetRow` and **asks first**: it discards two values, subject and body (Style Guide → SAVED VARIABLES → Reset). README-Notes "One mail reset" still holds: one button resets both.
- **Badge of Generosity:** unchanged.

## Onto the Kit

- Copy `Options/Options-Kit.lua`; delete the grid from `Data/Data.lua` (`OPTIONS_TREE_WIDTH` included).
- `Options-Utilities.lua`: delete the four standard helpers, `OptionsProfileToggle` (becomes `Kit.Get` / `Kit.Set`), `OptionsHelp`. Keep `RefreshMailWindow`, `OptionsProfileOff`, `OptionsClassIcon`.
- `Options.lua`: `ns:RegisterOptionsPanels` (colon) becomes `ns.RegisterOptionsPanels` (dot), a list of `Kit.RegisterPanel` calls; `ns.GeneralPanel` and `ns.GeneralCategoryID` go.
- **One Refresh:** every `set` ends in `ns.RefreshSettings()`; delete the per-panel `NotifyChange` calls (`Alts.lua:58`, `Guilds.lua:35`, `Mail.lua:277`).
- Widget type names become `ADDON_NAME .. "_MailEditor"` and `ADDON_NAME .. "_BadgePreview"`, constants in `Data/Data.lua` (Item Lists' `ns.ITEM_LINK_WIDGET_TYPE` convention).

## Strings

New: `OPTIONS_RESET` "Reset", `OPTIONS_GUILD_REMOVE_CONFIRM`, `OPTIONS_MAIL_RESET_CONFIRM`, `OPTIONS_ENABLE_*` captions for the three features (or reword the existing three; one key each either way).

## Keeps

README-Notes: One mail reset (its "no confirm" reading ends), Spec Restore Defaults, English mail, typed spec names.

## Check in Game

- [ ] Untick Distribute Gear on the mail window's top bar with options open: the root page and What to Give Away follow at once.
- [ ] Mail Message Text's Restore Default asks first; so does removing a guild.
- [ ] My Alts opens on the current character every time.
