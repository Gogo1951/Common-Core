# Water Dispenser: Options Panels

**State:** a one-level tree of built tables, no `ns.FEATURES`, no shared refresh: two settings have two different setters, and most setters notify nothing. Its mini-map button still shows a tooltip (`Mini-map Menus/Water Dispenser.md` converts it).
**Live code:** [`Options/Options.lua`](https://github.com/Gogo1951/Water-Dispenser/blob/main/Options/Options.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Water-Dispenser/blob/main/Options/Options-General.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Water-Dispenser/blob/main/Options/Options-Utilities.lua), [`Options/Options-Dispensed-Items.lua`](https://github.com/Gogo1951/Water-Dispenser/blob/main/Options/Options-Dispensed-Items.lua).
**Needs first:** `Options-Kit.md` (in Common-Core). Pairs with `Mini-map Menus/Water Dispenser.md`: build `ns.FEATURES` here, and the menu reads it.
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.

## Panel Tree

| # | Tree label | Parent | Today | Proposed |
|---|---|---|---|---|
| 1 | Water Dispenser | root | table | builder function |
| 2 | Dispense | root | table | builder function |
| 2a | Dispensed Items | **root** | table, tree | **under Dispense**, title **Dispense > Dispensed Items** (Lists and separate tools get sub-panels) |
| 3 | Announcements | root | table | builder function |
| 4 | Inventory Tooltips | root | table | builder function |
| 5–7 | Profiles, Feedback & Support, Diagnostic Tools | root | | unchanged |

## Root Page

Description, Enable Welcome Message, Enable Mini-map Button, Features, /Commands.

- **Features** draws `Kit.FeatureSwitches(13)`: pairs at 1.6 (today four flat toggles at exactly 1.7, on the wrap edge, no pair rows).
- **Captions gain Enable** (Decision 5): Show Inventory in Player Tooltips → Enable Inventory Tooltips, Show Bag Tooltips → Enable Bag Tooltips, so the menu's name for each is its caption without Enable. The two key names (`OPTIONS_WELCOME_MESSAGE`, `OPTIONS_MINIMAP`) keep their text.

## Features

`ns.FEATURES` is new, in `Options/Options-Utilities.lua`. All `store = "profile"`.

| setting | name | caption today | block | apply |
|---|---|---|---|---|
| Dispense's setting | `TAB_DISPENSE` | `OPTIONS_DISPENSE_MASTER` | yes, `click = "LeftButton"` per the menu spec | `ns.SetDispense` |
| Announcements' setting | `TAB_ANNOUNCEMENTS` | `OPTIONS_ANNOUNCEMENTS_ENABLE` | | as today's setter |
| `ShowInventoryTooltips` | | `OPTIONS_SHOW_INVENTORY` | | as today's setter |
| `ShowBagTooltips` | | `OPTIONS_BAG_TOOLTIPS` | | as today's setter |

Take each setting key and side effect from today's root-page `FeatureToggle` (`Options-General.lua:22-34`). Every panel's Enable switch becomes `Kit.FeatureSwitch(setting)`, which ends the duplicate setters (`Options-General.lua:100-116` against `Options-Group-Spares.lua:37-57`).

## Panels

- **Dispense:** the intro stops repeating the Enable switch's tooltip string (`Options-Dispenser.lua:59` and `:65`): it gets its own short sentence on what the panel holds. The seven sub-rows become `Kit.SubToggleRow`. Both Examples become `Kit.Example`, hidden with the toggle they show (Decision 6); today they stay while their print is off. The Combat section hides with Dispense, as the rest of the page does (`Kit.HideAllExcept`).
- **Dispensed Items** (sub-panel of Dispense): the tree pane takes `Kit.TREE_ROW_WIDTH` and `TREE_LABEL_WIDTH` in place of its file-local 2.4 / 1.0 / 1.4; `Kit.PrepareTree` sets the 176 sidebar. Each item page keeps its shape: status line (`Kit.StatusLine`), Amounts grid, Item Settings, Remove Item with its confirm. The Distribute label loses its gold (labels are white; gold is for headers).
- **Announcements:** the preview line keeps its README-Notes shape (silver, no Example label).
- **Inventory Tooltips:** Show Inventory and Show Bag Tooltips become the two `Kit.FeatureSwitch` copies; Share My Inventory `Kit.SubToggleRow`.

## Onto the Kit

- Copy `Options/Options-Kit.lua`; delete the grid from `Data/Data.lua`.
- `Options-Utilities.lua`: delete the four standard helpers, `OptionsSubRow`, `OptionsSubLabel`, `OptionsExample`, `OptionsSubToggle`, `OptionsGetDB` / `OptionsSetDB` (become `Kit.Get` / `Kit.Set`). Keep the NumberBox widget, `OptionsParseCount`, `OptionsValidateCount`; its Apply button moves from 52 to 48 points (Spacing Scale: past 32, the next step is 64; 48 is a multiple of 16).
- `Options.lua`: `Kit.RegisterPanel` calls; `ns.RebuildDispensedItemsOptions` becomes `ns.RefreshSettings()`, since the panel is a builder function and rebuilds on every repaint.
- **One Refresh:** delete the hand `NotifyChange` calls (`Features/Dispenser.lua:80-81`, `Features/Announcements.lua:344-345`, `Options-General.lua:103,115`, `Options-Group-Spares.lua:42,56`); `ns:ApplyProfile` calls `ns.RefreshSettings()`.

## Strings

New: the Dispense intro sentence; `OPTIONS_ENABLE_INVENTORY_TOOLTIPS` and `OPTIONS_ENABLE_BAG_TOOLTIPS` (or reword the two keys in place). Keys keep their `_DESC` suffix; new keys take `_DESCRIPTION`.

## Keeps

README-Notes: Guildies Only Guild Line, Announcements Preview.

## Check in Game

- [ ] Flip Show Bag Tooltips on the root page with Inventory Tooltips open beside it: it follows at once, and the reverse.
- [ ] Dispensed Items sits under Dispense; Add an Item opens the new item's page.
- [ ] Each Example leaves with its toggle.
