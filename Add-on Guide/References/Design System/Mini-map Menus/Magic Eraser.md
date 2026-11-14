# Magic Eraser: Mini-map Menu

**State:** live ([Gogo1951/Magic-Eraser#52](https://github.com/Gogo1951/Magic-Eraser/pull/52)): the menu, with More Features in a flyout, click-to-remove Protect List rows, a Clear that asks first, and one refresh. Still to do: the move onto Menu-Kit v2, the maintainer's once the kit lands in Common-Core; nothing a player sees changes.
**Live code:** [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Menu.lua) (the click table, rows, the More Features flyout and count, `ApplyHoverIcons`), [`Features/Minimap-Button.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Button.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-General.lua) (`ns.FEATURES`), [`Features/Ignore-List.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Ignore-List.lua) (`ns:ConfirmClearIgnoreList`).
**Next:** its move onto Menu-Kit v2 (`Menu-Kit.md`): `FLYOUTS.features`, `AddMoreFeatures` and `ApplyHoverIcons` give way to `Kit.MoreFeatures` and `rightOnHover`.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Magic-Eraser#51](https://github.com/Gogo1951/Magic-Eraser/issues/51). Closed by [Gogo1951/Magic-Eraser#52](https://github.com/Gogo1951/Magic-Eraser/pull/52).

## Before This Spec

`Features/Minimap-Button.lua` → `RefreshTooltip`:

```
Magic Eraser                                       [version]
Lowest-Value Item                   (with junk; else the green congratulation)
  [icon] Chipped Claw x4                                 12c
Left-Click                                             Erase
Right-Click                                          Protect
Auto-Vend                               Enabled / Disabled (red)
Sells your junk the moment you open a merchant, cheapest first.
Shift + Right-Click                                   Toggle
Clutter Report
  9 Bag Slots (27 Items)                              2s 64c   (with clean bags: the hint line)
Protect List                        (only while this character's list has items)
  [icon] Light Feather
Middle-Click                              Clear Protect List
Magic Eraser Options
Shift + Middle-Click
```

## The Menu

| Row | Kind | Left | Right | Click | Shows |
|---|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | | always |
| Lowest-Value Item | status | `LOWEST_VALUE_ITEM` | | | `ns:FindItemToDelete()` returns an item |
| The item | item | link, count | `ns:FormatCurrency(value)`, or `NO_VALUE` in MUTED | | as above; tooltip is the item's |
| Erase | action | `ACTION_ERASE` | Left-Click | LeftButton | as above |
| Protect | action | `ACTION_PROTECT` | Right-Click | RightButton | as above |
| Bags clean | description, `leftColor = "ON"` | `BAGS_CLEAN_CONGRATS` | | | no item to erase |
| Auto-Vend | status | `AUTO_VEND` | On / Off | | always |
| | description | `AUTO_VEND_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Right-Click | ShiftRightButton | tooltip is the Auto-Vend switch's name and desc |
| Clutter Report | status | `CLUTTER_REPORT` | | | always |
| Totals | value | `CLUTTER_SLOTS` / `_ONE` + `CLUTTER_ITEMS` / `_ONE` in MUTED | `ns:FormatCurrency(reclaimValue)` | | an item to erase |
| Hint | description | `BAGS_CLEAN_HINT` | | | no item to erase |
| Protect List | status | `TAB_PROTECT_LIST` | | | this character's list has items |
| Each item | item, click to remove | name in quality color (`LOADING_ITEM` in MUTED until cached) | delete icon, `rightOnHover` | | as above, sorted by name; 8 max, then `MENU_MORE` |
| Clear Protect List | action | `ACTION_CLEAR_PROTECT_LIST` | Middle-Click | MiddleButton | as above; asks Yes/No first |
| More Features | submenu | `MENU_MORE_FEATURES` | `MENU_FEATURE_COUNT_ON` in ON, `,` in TEXT, `MENU_FEATURE_COUNT_OFF` in MUTED, then the arrow | | always |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

Order is the tooltip's: Protect List stays last of the reports because only it grows, so nothing above it moves. More Features follows it, last before Options.

**The More Features flyout:** one toggle per switch, in the root panel's order (Features, below), each with its switch's caption and description as the tooltip. The count on its row covers only these; Auto-Vend has its own block and isn't counted.

**A Protect List row:** a click takes the item off this character's list and prints `PROTECT_LIST_REMOVED`. The delete icon (`UI-GroupLoot-Pass-Up`) shows only while the row is hovered, and is always laid out, so the menu never changes width. Its tooltip is the item's own, then `MENU_UNPROTECT_HINT` in HELP.

## Button Clicks

Every click the tooltip's button had, and what it is now:

| Click | Before | Now | Row |
|---|---|---|---|
| Left-Click | `ns:RunEraser()` | The same; with clean bags it prints the congratulation | Erase |
| Shift + Left-Click | Erased (the Left-Click branch ignored Shift) | Opens and holds the menu: it has no entry in `CLICKS` | none |
| Right-Click | Toggled the lowest-value item on and off the Protect List | Protects it, add-only, with the same chat line as the key binding (`ProtectLowestValueItem`) | Protect |
| Middle-Click | `ns:ClearIgnoreList()`, one click, no confirmation | `ns:ConfirmClearIgnoreList()`: asks first, in the options page's Clear List words; with nothing listed, does nothing | Clear Protect List |
| Shift + Right-Click | Auto-Vend on/off | The same | Auto-Vend's Toggle |
| Shift + Middle-Click | Options | The same | Options |

Left-Click has a job, so **hover alone opens the menu**. After an erase, a protect or a removal, the open menu redraws on the next item.

**Every Protect List edit prints a chat line,** the same sentence however the player asked (row, button click or key binding): `PROTECT_LIST_ADDED`, `PROTECT_LIST_MOVED`, `PROTECT_LIST_ALREADY`, `PROTECT_LIST_REMOVED`.

## Strings

- **Renamed in `enUS.lua`**, every locale carried across: `ACTION_TOGGLE` → `MENU_TOGGLE`, `LEFT_CLICK` / `RIGHT_CLICK` / `MIDDLE_CLICK` / `SHIFT_RIGHT_CLICK` / `SHIFT_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`, and the Ignore keys → Protect (`ACTION_PROTECT`, `TAB_PROTECT_LIST`, `ACTION_CLEAR_PROTECT_LIST`).
- **New:** `MENU_ON` / `MENU_OFF`, `MENU_MORE`, `MENU_MORE_FEATURES` "More Features", `MENU_FEATURE_COUNT_ON` "%d On", `MENU_FEATURE_COUNT_OFF` "%d Off", `MENU_UNPROTECT_HINT` "Click to remove it from your Protect List.", `PROTECT_LIST_REMOVED` "Removed %s from your Protect List.", in every locale. Other add-ons take `MENU_FEATURE_COUNT_*` from here (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 4).
- **Not in the menu:** `AUTO_VEND_SHIFT_HINT`, the hold-Shift-to-skip tip, shows where it applies and on the options page (Style Guide → MINIMAP MENU → Layout, No how-to notes).

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** The root panel leads with Auto-Vend, the one block. The More Features flyout holds Bank Retrieval, Maximum Value to Erase, Skip Typing DELETE, Erase Confirmation, Junk Item Tint, Quest Item Alerts, Bag-Space Warnings, in that order, from `ns.FEATURES` in `Options/Options-General.lua`, each keeping its `onSet` (`ns.OnValueCapToggled`, `ns.OnTintJunkChanged`).
- **One refresh.** Every row click, button click and options `set` ends in `ns.RefreshSettings()`; `ns:RefreshDisplay` keeps only the bag tints and ends in it.
- **Button.** A **launcher**, not a `"data source"`; its position lives in `ns.db.profile.minimap`, copied once from `ns.db.global.minimap` in a migration; the next item's icon is set by assigning `ns.dataBrokerObject.icon` alone (`ns.UpdateMinimapIcon()`).

## Check in Game

- [ ] Hover opens the menu; Left-Click on the button erases and the menu shows the next item; so does the Erase row.
- [ ] Shift + Left-Click opens and holds the menu.
- [ ] Right-Click and the Protect row both protect, with a chat line, and the item joins the Protect List; a second press says it's already there.
- [ ] Clicking a Protect List row removes it, with a chat line; its delete icon shows only on hover, and the menu doesn't change width.
- [ ] Middle-Click and Clear Protect List both ask Yes/No before clearing; with the list empty, neither asks.
- [ ] Shift + Right-Click and the Toggle row both flip Auto-Vend.
- [ ] More Features opens its flyout; its count follows each switch; Auto-Vend isn't counted.
- [ ] With clean bags: the green congratulation and the Clutter Report hint, no Erase or Protect rows.
- [ ] A controller's cursor reaches every row, the flyout's included.
- [ ] Flip each Features switch in options with the menu open: the flyout and count follow. Flip each in the flyout with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
