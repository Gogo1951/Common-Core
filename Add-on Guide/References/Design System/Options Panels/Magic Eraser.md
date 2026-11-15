# Magic Eraser: Options Panels

**State:** live on the kit ([Gogo1951/Magic-Eraser#52](https://github.com/Gogo1951/Magic-Eraser/pull/52)): every panel is built from `Options/Options-Kit.lua`, copied from Common-Core. It proved the kit, and is the Style Guide's live reference for the main page, item lists, sub-option rows, status lines, Example Lines and Feedback & Support.
**Live code:** [`Options/Options.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options.lua) (`Kit.RegisterPanel`, `Kit.PrepareTree`), [`Options/Options-General.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-General.lua) (`ns.FEATURES`, Key Bindings), [`Options/Options-Eraser.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-Eraser.lua) (the junk kinds), [`Options/Options-Auto-Vend.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-Auto-Vend.lua) and [`Options/Options-Quest-Item-Alerts.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-Quest-Item-Alerts.lua) (Examples), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-Utilities.lua) (`ns.ExampleLine`, `ns.BuildCharacterListTree`).
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.

## Panel Tree

| # | Tree label | Parent | Today | Proposed |
|---|---|---|---|---|
| 1 | Magic Eraser | root | built table, name `ns.ADDON_TITLE` | builder function, name `L["ADDON_TITLE"]` |
| 2 | Erasing | root | built table | builder function |
| 2a | Erase List | Erasing | function, tree | tree; page title reads **Erasing > Erase List** (Decision 8) |
| 2b | Protect List | Erasing | function, tree | tree; page title reads **Erasing > Protect List** |
| 3 | Merchant & Bank | root | built table | builder function |
| 4 | Alerts & Tints | root | built table | builder function |
| 5–7 | Profiles, Feedback & Support, Diagnostic Tools | root | template | unchanged |

`Kit.RegisterPanel` captures every panel's category ID, so `ns:OpenOptionsPanel("EraseList")` works.

## Root Page

Unchanged in shape: description, Enable Welcome Message, Enable Mini-map Button, Features, Key Bindings, /Commands.

- **Features** draws `Kit.FeatureSwitches(13)` from `ns.FEATURES` (below) instead of the local `FEATURE_TOGGLES` and `OptionsTogglePairs`. Same eight switches, same order, same 1.6 pairs.
- **Key Bindings** rows sit on the grid (Decision 13): the caption at 2.1 (`Kit.LABEL_WIDTH`), the bound key at 0.75 and Set Key at 0.55, totalling 3.4 (`Kit.ROW_WIDTH`; before, 1.9 + 0.85 + 0.55 = 3.3). The what-the-key-does line stays silver.

## Features

`ns.FEATURES` replaces `FEATURE_TOGGLES` in `Options/Options-Utilities.lua`, order unchanged. All `store = "profile"`.

| setting | caption (desc is `caption .. "_DESCRIPTION"`) | block | apply |
|---|---|---|---|
| `autoVendEnabled` | `OPTIONS_ENABLE_AUTO_VEND` | yes (the menu's Auto-Vend block) | — |
| `bankRetrievalEnabled` | `OPTIONS_ENABLE_BANK_RETRIEVAL` | | — |
| `valueCapEnabled` | `OPTIONS_ENABLE_VALUE_CAP` | | `ns.OnValueCapToggled` |
| `manualDeleteAutoFillEnabled` | `OPTIONS_ENABLE_MANUAL_DELETE_AUTOFILL` | | — |
| `eraseConfirmEnabled` | `OPTIONS_ENABLE_ERASE_CONFIRM` | | — |
| `tintJunkEnabled` | `OPTIONS_ENABLE_TINT` | | `ns.OnTintJunkChanged` |
| `questAlertsEnabled` | `OPTIONS_ENABLE_QUEST_ALERTS` | | — |
| `bagsFullNudgeEnabled` | `OPTIONS_ENABLE_BAGS_FULL_WARNINGS` | | — (the panel copy's `NotifyMerchantBank` goes: `ns.RefreshSettings` repaints every panel) |

Each record's `name` is the key the menu spec uses for that feature (`Mini-map Menus/Magic Eraser.md`); where the menu has no row for it, the panel or section heading key it sits under today.

- **Fixes a live bug:** today the root copy of Bag-Space Warnings omits the `onSet` the panel copy passes (`Options-Bag-Warnings.lua:97-104`), so flipping it on the root page leaves Merchant & Bank stale. One `Kit.FeatureSwitch` for both copies ends that.

## Panels

- **Erasing:** the What Counts as Junk "none checked" line is `Kit.WarningLine` (still red). The junk kinds are `Kit.Pairs` from `ns.ERASE_KINDS` in `Data/Data.lua`, two to a line, each pair a kind and its neighbor: Completed Quest Items and Dead-End Quest Starters, Outgrown Food & Drink and Outgrown Meat & Fish, White Weapons & Armor and Crafted Weapons & Armor, Outgrown Arrows & Bullets and Gray Trash. Maximum Value and Skip Typing DELETE are `Kit.ToggleRow` with their select as `control`.
- **Merchant & Bank:** Auto-Vend is `Kit.ToggleRow`. The bag-cushion note stays a `Kit.StatusLine`. Both Examples sit under the control they show, indented (Decision 6), with real links (below).
- **Alerts & Tints:** Bag-Space Warnings' slider row becomes `Kit.SubLabelRow` (the caption gets the kit's 1.985, today 1.935). The Tint switch and color picker keep their README-Notes shape (Color picker beside its switch), built as `Kit.Pairs`.
- **Erase List, Protect List:** `Kit.ItemList` with `rowWidth = Kit.TREE_ROW_WIDTH`, `addFromBags`, the Promote action column, Restore (Erase List) and Clear; `Kit.PrepareTree` opens each on the current character. Sidebar 176 points (before, 180; Decision 12). `ns.BuildCharacterListTree` and `ns.LeaveClearedScope` stay Magic Eraser's: no other add-on scopes lists this way yet.

## Example Lines

- **Real items.** Each Example names a real item the feature handles, from an ID in the flavor's data, through `C_Item.GetItemInfo`, and fills in on the next repaint while it loads (`ns.ExampleItemLink`). `OPTIONS_EXAMPLE_ITEM` and `ns.EXAMPLE_ITEM_LINK` are retired.
- **Through the print helper.** Each Example renders the line through the helper that prints it (`ns.ExampleLine`, which is `ns:FormatMessage`). It skipped `Kit.PrintedLine` while the kit's `Tint` reopened its color after every `|r`, which pushed the second line's coins to white; the kit now reopens only where a line would fall back to white, so `Kit.PrintedLine` is safe again.
- **The label is the bare word.** `SAMPLE_EXAMPLE` is "Example", no colon, in every locale.
- **Quest Item Alerts: one line,** the ready alert. The unavailable-starter alert is the same message with a different reason, so a second line would only repeat it.
- **Auto-Vend: the summary first.** Summary Only shows the total; Every Sale in Chat shows the total with one sale line under it, the order a merchant visit prints them, since Auto-Vend holds the sale lines until the merchant closes (Style Guide → MESSAGES → Print Outs).

## Onto the Kit

- Copy `Options/Options-Kit.lua` from Common-Core (`scripts/sync-addon-kits.sh --adopt Options-Kit`), first in the TOC's Options group, in every TOC.
- `Data/Data.lua`: delete the grid the kit now publishes (`ns.OPTIONS_ROW_WIDTH`, `_LABEL_WIDTH`, `_CONTROL_WIDTH`, `_REMOVE_ICON_WIDTH`, `_SUB_INDENT_WIDTH`, `_SUB_LABEL_WIDTH`, `_TREE_WIDTH`, `_TREE_ROW_WIDTH`). `ns.OPTIONS_PROMOTE_WIDTH` (0.9) stays: the Promote column is Magic Eraser's own.
- `Options/Options-Utilities.lua`: delete the four standard helpers, `OptionsFeatureToggle`, `OptionsTogglePairs`, `OptionsExample`, `OptionsStatusLine`, the item cache, parse, sort, display name, `BuildItemListOptions` and the ItemLink widget. Keep `BuildCharacterListTree`, `LeaveClearedScope`. Add `ns.FEATURES` and the `Kit.SetText` call.
- `Options/Options.lua`: `ns.RegisterOptionsPanels` becomes `Kit.RegisterPanel` calls; delete `PrepareListTree`, `ns:OpenOptionsPanel`, `ns.generalCategoryID`.
- **One Refresh** (Decision 3): every `set` ends in `ns.RefreshSettings()`; delete the hand `NotifyChange` calls in `Options-Bag-Warnings.lua`, `Features/Minimap-Button.lua:204-205` and the per-panel ones. `ns:ApplyProfile` calls `ns.RefreshSettings()` instead of looping the registry.
- `Diagnostics/`: Display Context and Eraser Context read nothing the kit renames. Leave them.

## Strings

In `enUS.lua` only; the Localization Review carries the rest.

| Old | New |
|---|---|
| `OPTIONS_EXAMPLE` | `SAMPLE_EXAMPLE`, now "Example" |
| — | `OPTIONS_RESET` "Reset" (only if a Reset row is added; none is today) |
| `OPTIONS_EXAMPLE_ITEM` | retire |

## Keeps

README-Notes: Color picker beside its switch.

## Check in Game

- [ ] Every panel looks as it did, apart from Decisions 6, 8, 12 and 13.
- [ ] Flip Bag-Space Warnings on the root page with Merchant & Bank open beside it: the cushion note follows at once.
- [ ] Every Example names a real item, in its quality color, and redraws when its dropdown changes.
- [ ] Every Sale in Chat's Example: the total, then the sale line, both lines' coins in gold, silver and copper.
- [ ] Each list page's title reads Erasing > Erase List or Erasing > Protect List.
- [ ] The Erase List on a fresh login: rows read Loading, then fill in.
- [ ] `/eraser` in combat prints the refusal; out of combat it docks the root panel.
