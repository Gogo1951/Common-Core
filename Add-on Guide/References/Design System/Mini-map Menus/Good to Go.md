# Good to Go: Mini-map Menu

**State:** live ([Gogo1951/Good-to-Go#41](https://github.com/Gogo1951/Good-to-Go/pull/41)): the menu in `Features/Minimap-Menu.lua` is built and goes past this spec.
**Kit:** Menu-Kit v2, copied from Common-Core's `addon-kits/Menu-Kit/` (`Menu-Kit.md`; Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1). The Code section's v2 names (an entry's `click` key, `OnClick` going to `menu:HandleClick`) are the kit's own.
**Live example:** Tracking Eye's menu: [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua) for the click table, feature blocks, flyouts and More Features; [`Features/Minimap-Button.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Button.lua) for the button.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Good-to-Go#18](https://github.com/Gogo1951/Good-to-Go/issues/18). Close it with the PR that builds this.

## Today

`Features/Minimap-Button.lua` → `UpdateTooltip`:

```
Good to Go                                         [version]
Current Food
                                    [icon] Conjured Cinnamon Roll   (right-aligned on its own row)
Right-Click                                           Ignore
Buff Food & Scrolls            Enabled / Party, Raid (gray) / Disabled (red)
Uses Well Fed food and applies missing scroll buffs before you eat.
Left-Click                                            Toggle
Buff Duty                                Enabled / Disabled
Shows who's missing your buffs. Click an icon to cast.
Shift + Left-Click                                    Toggle
Restock List
Buys and banks the items on your list.
Shift + Right-Click                          Open / Disabled
Mage                               (class color; Hunter, Mage, Rogue, Warlock only)
Food & Water Macros
Right-Click                                          Conjure   (silver)
Target a lower-level player to conjure for their level.
Mana Gem Macro …
Restocker Report                   (while the Restocker is on)
  [icon] Arcane Powder                                  4/20   (out, then low; over 8: a count; stocked: green line; short but nothing low or out: gray line; empty list: body line)
Ignore List                        (while this character's list has items)
  [icon] Conjured Sweet Roll                                   (over 8: a count)
Middle-Click                               Clear Ignore List
GtG Options
Shift + Middle-Click
```

## The Menu

| Row | Kind | Left | Right | Click | Shows |
|---|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | | always |
| Current Food | status | `MINIMAP_BEST_FOOD` | | | always |
| The food | item | `ns.bestFoodID` | | | a food resolved; else a description, `MESSAGE_NO_ITEM` with `LABEL_FOOD` |
| Ignore | action | `MENU_IGNORE` | Right-Click | RightButton | a food resolved |
| Buff Food & Scrolls | status | `MINIMAP_BUFF_FOOD_SCROLLS` | On (ON) / Paused (MUTED) / Off (MUTED) | | always |
| | description | `MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT` with `ns.GetWellFedName()` | | | |
| Waiting | note | `MENU_WAITING_FOR` with the waiting label (`Waiting for: Party, Raid`, or the level filter's label) | | | on, while its When to Use doesn't hold |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | flips both as a pair (`ToggleBuffFoodAndScrolls`) |
| Buff Duty | status | `TAB_BUFF_DUTY` | On / Off, for this class | | always |
| | description | `BUFF_DUTY_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Left-Click | ShiftLeftButton | |
| Restocker | status | the feature's name, as the root panel's switch names it | On / Off, never a count | | always |
| | description | `MENU_RESTOCKER_DESCRIPTION` | | | |
| Each order | item | `ns.GetItemLabel(itemID)` | `MINIMAP_RESTOCKER_ITEM_COUNT` have/wanted, BODY | | Restocker on; `Kit.List`, 8 max, from `ns.BuildRestockReminderLists()`: out rows, then low rows |
| Stocked | description, `leftColor = "ON"` | `MINIMAP_RESTOCKER_STOCKED` | | | on, list has rows, nothing to buy |
| Nothing Low | note | `MINIMAP_RESTOCKER_NOTHING_LOW` (Nothing is low or out.) | | | on, list is short but nothing is low or out |
| Empty | note | `MINIMAP_RESTOCKER_EMPTY` | | | on, list has no rows |
| Toggle | action | `MENU_TOGGLE` | | none (all six clicks are taken) | tooltip is the Restocker's Enable switch |
| Open | action | `MENU_OPEN` | Shift + Right-Click | ShiftRightButton | Restocker on |
| [Class] Macros | submenu, class color | `MENU_CLASS_MACROS` with the class name | arrow | | the class has macro notes (below) |
| Each class item | item | the item | its slot or kind, MUTED: `MAINHANDSLOT` / `SECONDARYHANDSLOT` (Rogue poisons), `LABEL_PET_FOOD` (Hunter) | | the class has it |
| Ignore List | status | `MINIMAP_IGNORE_LIST` | | | this character's list has items |
| Each item | item | name in quality color | | | sorted by name; `Kit.List`, 8 max |
| Clear Ignore List | action | `MENU_CLEAR_IGNORE` | Middle-Click | MiddleButton | as above; prints what it cleared, as today |
| Options | action | `MENU_OPTIONS` (GtG Options) | Shift + Middle-Click | ShiftMiddleButton | always |

The Restocker Report moves **into** the Restock List block (a feature's own report sits in its block), so `MINIMAP_RESTOCKER_REPORT` goes. Restock List gains a Toggle: today, with the Restocker off, the button's click only says Disabled.

### The [Class] Macros Flyout

The **reference flyout** pattern: notes about a macro's clicks, not this menu's, so they leave the main menu. Built from the same `CLASS_NOTES` builders, macro blocks only:

| Row | Kind | Left | Right |
|---|---|---|---|
| Macro name | section | `NOTE_MACRO_*` | |
| Each click | value | what it does, as a verb: `NOTE_CONJURE`, `NOTE_CREATE`, `NOTE_CONJURE_LOWER_RANK` (mage), `NOTE_CREATE_LOWER_RANK` (warlock) | the macro's click (`NOTE_*` / `MINIMAP_*_CLICK`), MUTED |
| Closing note | note | `NOTE_MAGE_TARGET_LEVEL` and the like | |

`ns.AddConsumableMacroNotes`, which the Spellbook page's tooltip calls, keeps working: move it and `CLASS_NOTES` out of `Minimap-Button.lua` before removing the tooltip code.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | Buff Food & Scrolls on/off, as a pair | Buff Food's Toggle |
| Right-Click | Ignore the current food (prints) | Ignore |
| Middle-Click | Clear this character's Ignore List (prints) | Clear Ignore List |
| Shift + Left-Click | Buff Duty on/off for this class | Buff Duty's Toggle |
| Shift + Right-Click | Open the Restock List window | Open |
| Shift + Middle-Click | Options | Options |

Left-Click has a job, so hover alone opens the menu. Every click ends in `ns.RefreshSettings()`, which redraws the open menu and calls `ns.UpdateMinimapIcon()`.

## Strings

- **Rename in `enUS.lua`**, each listed old → new in the prompt; the Localization Review carries every locale's text across: `MINIMAP_TOGGLE` → `MENU_TOGGLE`, `MINIMAP_OPEN` → `MENU_OPEN`, `MINIMAP_LEFT_CLICK` / `_RIGHT_CLICK` / `_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_SHIFT_LEFT` → `MENU_CLICK_SHIFT_LEFT`, `MENU_RESTOCKER_KEYBIND` → `MENU_CLICK_SHIFT_RIGHT`, `MENU_OPTIONS_KEYBIND` → `MENU_CLICK_SHIFT_MIDDLE`. Check the macro notes before renaming `MINIMAP_RIGHT_CLICK` and the like: they name a macro's clicks too and keep reading the renamed key.
- **New, in `enUS.lua`:** `MENU_ON` / `MENU_OFF`, `MENU_MORE` and `MENU_PAUSED` "Paused" (GogoLoot's `STATUS_PAUSED` on GitHub has its translations). The Localization Review fills every other locale (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 4). Also new, translated by the Localization Review: `MENU_CLASS_MACROS` "%s Macros", `MENU_WAITING_FOR` "Waiting for: %s", `NOTE_CONJURE_LOWER_RANK` "Conjure Lower Rank" and `NOTE_CREATE_LOWER_RANK` "Create Lower Rank" (the second click on Mana Gem and Healthstone, which `Lower-Rank Backup` named as a label once the job led the row). `MENU_MORE_FEATURES` "More Features".
- **Retire**, if nothing else reads them: `NOTE_LOWER_RANK_BACKUP`, `MINIMAP_RESTOCKER_NEEDED`, `MINIMAP_RESTOCKER_REPORT`, `MINIMAP_IGNORE_COUNT`, `MINIMAP_BEST_PET_FOOD`, `MINIMAP_MAIN_HAND_POISON`, `MINIMAP_OFF_HAND_POISON`, `MINIMAP_ENABLED`, `MINIMAP_DISABLED`.

## Code

- Copy the kit and plate per Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows and the flyout above.
- `CLASS_NOTES`, its builders and `ns.AddConsumableMacroNotes` move to their own file, read by both the menu and the Spellbook page.
- `Features/Minimap-Button.lua`: remove `UpdateTooltip` and the click branches; keep registration and `ns.UpdateMinimapIcon`, which only sets the LDB icon (`ns.RefreshSettings()` redraws the open menu where the tooltip was redrawn); `ns.ToggleMinimapButton` is renamed (below). `OnClick` goes to the kit.

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** The root panel already reads Buff Duty, Restocker (the two blocks), then Enhanced Spellbook, Consumable Macros, Rank Watch (not on Mists), Inventory Report, Readiness Report. The menu gains **More Features** with those five as compact rows, their switches' captions and descriptions as tooltips; Enhanced Spellbook and Consumable Macros ask before turning off, as their switches do (`confirmOff`). `FEATURE_SWITCHES` and `ns.FEATURE_GROUPS` become `ns.FEATURES`.
- **Restock List's block is titled Restocker**, the feature's name on the root panel; its Open row still opens the Restock List window.
- **Buff Food & Scrolls** is a setting inside Consumable Macros that players flip mid-session, so it keeps a block of its own with no Features switch.
- **One refresh.** `ns.SetBuffDutyOn`, `ns.SetRestockerEnabled` and the rest end in `ns.RefreshSettings()` in place of their own repaints, and it calls `ns.UpdateMinimapIcon()`.
- **Button: two fixes.** A **launcher**, not a `"data source"`; the food icon is set by assigning `ns.dataBrokerObject.icon` alone, not also `SetTexture` on the button. Rename `ns.ToggleMinimapButton` → `ns:ApplyMinimapButton()`. Per-Character, so `ns.db.global.minimap` is right.

## Check in Game

On a mage, a rogue, a hunter and a warrior:

- [ ] Each click in Button Clicks does its job with the menu open and closed, with the same chat lines as today.
- [ ] Buff Food reads the waiting label in gray while its When to Use doesn't hold.
- [ ] Restock List: orders listed (out, then low; 8 max, then *N more*), stocked, nothing low, empty and off each draw as specified; Toggle and Open work.
- [ ] Each class sees its own macro flyout and items; a warrior sees neither.
- [ ] The Spellbook page's macro tooltips still show their notes.
- [ ] A controller's cursor reaches every row and the flyout.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
