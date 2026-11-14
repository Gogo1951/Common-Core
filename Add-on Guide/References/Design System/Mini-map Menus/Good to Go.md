# Good to Go: Mini-map Menu

**State:** tooltip. The tallest, and the last to convert.
**Needs first:** `Menu-Kit.md`.
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
  [icon] Arcane Powder                                  4/20   (over 8: a count; stocked: green line; empty list: body line)
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
| Buff Food & Scrolls | status | `MINIMAP_BUFF_FOOD_SCROLLS` | On (ON) / the waiting label (MUTED) / Off (MUTED) | | always |
| | description | `MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT` with `ns.GetWellFedName()` | | | |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | flips both as a pair (`ToggleBuffFoodAndScrolls`) |
| Buff Duty | status | `TAB_BUFF_DUTY` | On / Off, for this class | | always |
| | description | `BUFF_DUTY_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Left-Click | ShiftLeftButton | |
| Restock List | status | `MENU_RESTOCKER` | `MINIMAP_RESTOCKER_NEEDED` while orders are out (TEXT); On / Off otherwise | | always |
| | description | `MENU_RESTOCKER_DESCRIPTION` | | | |
| Each order | item | `ns.GetItemLabel(itemID)` | `MINIMAP_RESTOCKER_ITEM_COUNT` have/wanted, BODY | | Restocker on; `Kit.List`, 8 max, from `ns.BuildGroceryList()` |
| Stocked | description, `leftColor = "ON"` | `MINIMAP_RESTOCKER_STOCKED` | | | on, list has rows, nothing to buy |
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
| Each click | value | `NOTE_*` / `MINIMAP_*_CLICK` (the macro's click) | what it does |
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

Left-Click has a job, so hover alone opens the menu. Every click ends in `ns.UpdateMinimapIcon()`, and the open menu redraws.

## Strings

- **Rename, keeping every locale's text:** `MINIMAP_TOGGLE` → `MENU_TOGGLE`, `MINIMAP_OPEN` → `MENU_OPEN`, `MINIMAP_LEFT_CLICK` / `_RIGHT_CLICK` / `_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_SHIFT_LEFT` → `MENU_CLICK_SHIFT_LEFT`, `MENU_RESTOCKER_KEYBIND` → `MENU_CLICK_SHIFT_RIGHT`, `MENU_OPTIONS_KEYBIND` → `MENU_CLICK_SHIFT_MIDDLE`. Check the macro notes before renaming `MINIMAP_RIGHT_CLICK` and the like: they name a macro's clicks too and keep reading the renamed key.
- **New:** `MENU_ON` / `MENU_OFF`, copied from Tracking Eye's. `MENU_MORE`, copied from GogoLoot's `MINIMAP_TRADABLE_MORE`. `MENU_CLASS_MACROS` "%s Macros", the one string to translate fresh.
- **Retire**, if nothing else reads them: `MINIMAP_RESTOCKER_REPORT`, `MINIMAP_IGNORE_COUNT`, `MINIMAP_BEST_PET_FOOD`, `MINIMAP_MAIN_HAND_POISON`, `MINIMAP_OFF_HAND_POISON`, `MINIMAP_ENABLED`, `MINIMAP_DISABLED`.

## Code

- Copy the kit and plate from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows and the flyout above.
- `CLASS_NOTES`, its builders and `ns.AddConsumableMacroNotes` move to their own file, read by both the menu and the Spellbook page.
- `Features/Minimap-Button.lua`: remove `UpdateTooltip` and the click branches; keep registration, `ns.UpdateMinimapIcon` (it redraws the open menu where it redrew the tooltip) and `ns.ToggleMinimapButton`. `OnClick` goes to the kit.

## Check in Game

On a mage, a rogue, a hunter and a warrior:

- [ ] Each click in Button Clicks does its job with the menu open and closed, with the same chat lines as today.
- [ ] Buff Food reads the waiting label in gray while its When to Use doesn't hold.
- [ ] Restock List: orders listed (8 max, then *N more*), stocked, empty and off each draw as specified; Toggle and Open work.
- [ ] Each class sees its own macro flyout and items; a warrior sees neither.
- [ ] The Spellbook page's macro tooltips still show their notes.
- [ ] A controller's cursor reaches every row and the flyout.
