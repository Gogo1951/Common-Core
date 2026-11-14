# GogoLoot: Mini-map Menu

**State:** tooltip.
**Needs first:** `Menu-Kit.md`.
**Labels:** `Type: Design`, `Area: Features`.

## Today

`Features/Minimap-Button.lua` → `ShowTooltip`:

```
GogoLoot                                           [version]
Locked Items                       (only while boxes wait on a lock)
  [icon] Heavy Junkbox x2
  [icon] Strong Junkbox
  A Rogue can pick these for you.   (silver; a Rogue reads "Pick these with Pick Lock to unlock them.")
Tradable Loot                      (parked: loot windows are out of the TOCs)
Automated Rolls                          Enabled / Disabled (red)
Rolls for you on eligible items up to the quality you pick.
    Party: Greed, Uncommon & Lower      (silver, indented with two spaces)
    Raid: Manual
Left-Click                                            Toggle
Automated Opening              Enabled / Paused (gray) / Disabled
Opens clams, crates, coin purses, and unlocked lockboxes in your bags.
Right-Click                                           Toggle
Loot Announcements                       Enabled / Disabled
Posts trade summaries and master loot hand-outs to chat.
Shift + Left-Click                                    Toggle
Automated Master Looting                 Enabled / Disabled
Hands out loot to the players you picked for each quality.
Shift + Right-Click                                   Toggle
Loot Master & Loot Tracker         (parked)
GogoLoot Options
Shift + Middle-Click
```

## The Menu

| Row | Kind | Left | Right | Click | Shows |
|---|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | | always |
| Locked Items | status | `MINIMAP_LOCKED_ITEMS` | | | `ns.GetLockedBoxes()` not empty |
| Each box | item | item link | count | | as above; `Kit.List`, 8 max |
| Hint | note | `MINIMAP_LOCKED_ITEMS_HINT` / `_HINT_ROGUE` | | | as above; the Rogue line waits for Pick Lock's name |
| Automated Rolls | status | `TAB_AUTOMATED_ROLLS` | On / Off | | always |
| | description | `MINIMAP_AUTOMATED_ROLLS_DESCRIPTION` | | | |
| Party | value | `PARTY` (global) | `MENU_ROLLS_SETTING` "%s, %s" (action, threshold), or the action alone when Manual | | |
| Raid | value | `RAID` (global) | as Party | | |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | |
| Automated Opening | status | `TAB_AUTOMATED_OPENING` | On (ON) / Paused (MUTED) / Off (MUTED) | | always |
| | description | `MINIMAP_AUTOMATED_OPENING_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Right-Click | RightButton | |
| Loot Announcements | status | `TAB_ANNOUNCEMENTS` | On / Off | | always |
| | description | `MINIMAP_ANNOUNCEMENTS_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Left-Click | ShiftLeftButton | |
| Automated Master Looting | status | `TAB_MASTER_LOOTER` | On / Off | | always |
| | description | `MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Right-Click | ShiftRightButton | |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

**When the loot windows come back:** Tradable Loot is a live report under Locked Items (item rows with the time left on the right in its window colors, `Kit.List` at 8). A `Loot Master & Loot Tracker` block (status with `MINIMAP_TO_HAND_OUT` on the right, `MINIMAP_LOOT_WINDOWS_DESCRIPTION`, an `MENU_OPEN` action naming Middle-Click) comes before Options.

**Idea, not in this issue:** Automated Rolls could open a flyout of Party and Raid choice lists. Thresholds would double it, so it waits for a request.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | Automated Rolls on/off (and the icon swap) | Rolls' Toggle |
| Right-Click | Automated Opening on/off | Opening's Toggle |
| Shift + Left-Click | Loot Announcements on/off | Announcements' Toggle |
| Shift + Right-Click | Automated Master Looting on/off | Master Looting's Toggle |
| Middle-Click | Loot windows, only while they're loaded | (their block, when it returns) |
| Shift + Middle-Click | Options | Options |

Each toggle keeps its current side effects (`ToggleAutomatedRolls` and the others): the icon, `NotifyChange` on its panels, the trade checkbox and the master-looter pop-ups.

## Strings

- **Rename, keeping every locale's text:** `MINIMAP_TOGGLE` → `MENU_TOGGLE`, `MINIMAP_OPEN` → `MENU_OPEN`, `MINIMAP_LEFT_CLICK` / `_RIGHT_CLICK` / `_SHIFT_LEFT_CLICK` / `_SHIFT_RIGHT_CLICK` / `_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_OPTIONS_KEYBIND` → `MENU_CLICK_SHIFT_MIDDLE`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`, `MINIMAP_TRADABLE_MORE` → `MENU_MORE`.
- **New:** `MENU_ON` / `MENU_OFF`, copied from Tracking Eye's. `MENU_ROLLS_SETTING` "%s, %s": each locale's `MINIMAP_ROLLS_SETTING` with its leading `%s: ` removed.
- **Retire** `MINIMAP_ROLLS_SETTING`, `MINIMAP_ROLLS_SETTING_MANUAL`; and `STATUS_ENABLED` / `STATUS_DISABLED` only if nothing else reads them. **Keep** `STATUS_PAUSED`.

## Code

- Copy the kit and plate from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows above.
- `Features/Minimap-Button.lua`: remove `ShowTooltip`, `AddFeatureBlock`, `RollSettingLine` and the click tables; keep the toggles, `ns:UpdateMinimapIcon`, the loot-window helpers and the icon fit. `OnClick` goes to the kit.

## Check in Game

- [ ] Each click in Button Clicks does its job with the menu open and closed, the state word follows, and the icon swaps with Automated Rolls.
- [ ] Automated Opening reads Paused while it's paused.
- [ ] Locked Items shows only with locked boxes in bags; a Rogue sees the Pick Lock line.
- [ ] Party and Raid read back each setting, Manual included.
- [ ] A controller's cursor reaches every row.
