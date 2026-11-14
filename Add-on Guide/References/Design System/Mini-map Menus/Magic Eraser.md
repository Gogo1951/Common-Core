# Magic Eraser: Mini-map Menu

**State:** tooltip. An action button: Left-Click erases.
**Needs first:** `Menu-Kit.md`.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Magic-Eraser#51](https://github.com/Gogo1951/Magic-Eraser/issues/51). Close it with the PR that builds this.

## Today

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
| The item | item | link, count | `ns:FormatCurrency(value)`, or `NO_VALUE` in MUTED | | as above |
| Erase | action | `ACTION_ERASE` | Left-Click | LeftButton | as above |
| Protect | action | `ACTION_IGNORE` | Right-Click | RightButton | as above |
| Bags clean | description, `leftColor = "ON"` | `BAGS_CLEAN_CONGRATS` | | | no item to erase |
| Auto-Vend | status | `AUTO_VEND` | On / Off | | always |
| | description | `AUTO_VEND_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Right-Click | ShiftRightButton | tooltip is the Auto-Vend switch's name and desc |
| Clutter Report | status | `CLUTTER_REPORT` | | | always |
| Totals | value | `CLUTTER_SLOTS` / `_ONE` + `CLUTTER_ITEMS` / `_ONE` in MUTED | `ns:FormatCurrency(reclaimValue)` | | an item to erase |
| Hint | description | `BAGS_CLEAN_HINT` | | | no item to erase |
| Protect List | status | `TAB_IGNORE_LIST` | | | this character's list has items |
| Each item | item | name in quality color | | | as above, sorted by name; `Kit.List`, 8 max |
| Clear Protect List | action | `ACTION_CLEAR_IGNORE` | Middle-Click | MiddleButton | as above; one click, no confirmation, as today |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

Order is the tooltip's: Protect List stays last because only it grows, so nothing above it moves.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | `ns:RunEraser()` | Erase |
| Right-Click | Protect the lowest-value item | Protect |
| Middle-Click | `ns:ClearIgnoreList()` | Clear Protect List |
| Shift + Right-Click | Auto-Vend on/off | Auto-Vend's Toggle |
| Shift + Middle-Click | Options | Options |

Left-Click has a job, so **hover alone opens the menu**. With clean bags, Left-Click still runs the eraser (which prints the congratulation), exactly as today. After an erase or a protect, the open menu redraws on the next item.

## Strings

- **Rename, keeping every locale's text:** `ACTION_TOGGLE` → `MENU_TOGGLE`, `LEFT_CLICK` / `RIGHT_CLICK` / `MIDDLE_CLICK` / `SHIFT_RIGHT_CLICK` / `SHIFT_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`.
- **New:** `MENU_ON` / `MENU_OFF`, copied from Tracking Eye's. `MENU_MORE`, copied from GogoLoot's `MINIMAP_TRADABLE_MORE`. `MENU_MORE_FEATURES` "More Features", translated fresh once and copied to every add-on with More Features.
- **Keep** `ENABLED` / `DISABLED` if the options read them.

## Code

- Copy the kit and plate from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows above.
- `Features/Minimap-Button.lua`: remove `RefreshTooltip` and the click branches; keep `ns:RefreshDisplay` (the icon follows the next item), which now redraws the open menu where it redrew the tooltip. `OnClick` goes to the kit.

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** The root panel's order already leads with Auto-Vend, the one block. The menu gains **More Features**: Bank Retrieval, Maximum Value to Erase, Manual Delete Assistance, Erase Confirmation, Junk Item Tint, Quest Item Alerts, Bag-Space Warnings, in that order, each with its switch's caption and description as the tooltip. `FEATURE_TOGGLES` in `Options/Options-General.lua` becomes `ns.FEATURES`, and keeps each `onSet` (`ns.OnValueCapToggled`, `ns.OnTintJunkChanged`).
- **One refresh.** The `NotifyChange` calls in the click handler and options become `ns.RefreshSettings()`; `ns:RefreshDisplay` keeps the bag tints and calls it.
- **Button: three fixes.**
  - A **launcher**, not a `"data source"`.
  - Magic Eraser is Simple, so its position moves from `ns.db.global.minimap` to `ns.db.profile.minimap`, copied once in a migration.
  - The next item's icon is set by assigning `ns.dataBrokerObject.icon` alone, not also `SetTexture` on the button.

Magic Eraser is the guide's Simple reference, so these land before another add-on copies it.

## Check in Game

- [ ] Hover opens the menu; Left-Click on the button erases and the menu shows the next item; so does the Erase row.
- [ ] Right-Click and the Protect row both protect, and the item joins the Protect List.
- [ ] Middle-Click and Clear Protect List both clear, with no confirmation.
- [ ] Shift + Right-Click and the Toggle row both flip Auto-Vend.
- [ ] With clean bags: the green congratulation and the Clutter Report hint, no Erase or Protect rows.
- [ ] A controller's cursor reaches every row.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
