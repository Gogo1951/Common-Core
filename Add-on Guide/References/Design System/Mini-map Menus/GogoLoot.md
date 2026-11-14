# GogoLoot: Mini-map Menu

**State:** tooltip.
**Needs first:** `Menu-Kit.md`.
**Live example:** Tracking Eye's menu: [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua) for the click table, feature blocks, flyouts and More Features; [`Features/Minimap-Button.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Button.lua) for the button.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/GogoLoot#149](https://github.com/Gogo1951/GogoLoot/issues/149). Close it with the PR that builds this.

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
| More Features | status | `MENU_MORE_FEATURES` | | | always |
| Each set-and-forget feature | toggle | Speedy Loot, Loot Toasts, Loot Sounds, Automated Master Looting, Roll Macro | On / Off | | always; tooltip is the switch's caption and description |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

**When the loot windows come back:** Tradable Loot is a live report under Locked Items (item rows with the time left on the right in its window colors, `Kit.List` at 8). A `Loot Master & Loot Tracker` block (status with `MINIMAP_TO_HAND_OUT` on the right, `MINIMAP_LOOT_WINDOWS_DESCRIPTION`, an `MENU_OPEN` action naming Middle-Click) comes before Options.

**Idea, not in this issue:** Automated Rolls could open a flyout of Party and Raid choice lists. Thresholds would double it, so it waits for a request.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | Automated Rolls on/off (and the icon swap) | Rolls' Toggle |
| Right-Click | Automated Opening on/off | Opening's Toggle |
| Shift + Left-Click | Loot Announcements on/off | Announcements' Toggle |
| Shift + Right-Click | **Held for the Master Looting Window**, once it's built. Until then it does nothing. (Today it flips Automated Master Looting, which moves to More Features.) | the window's Open row, when it comes |
| Middle-Click | Loot windows, only while they're loaded | (their block, when it returns) |
| Shift + Middle-Click | Options | Options |

Each toggle keeps its current side effects (`ToggleAutomatedRolls` and the others): the icon, `NotifyChange` on its panels, the trade checkbox and the master-looter pop-ups.

## Strings

- **Rename, keeping every locale's text:** `MINIMAP_TOGGLE` → `MENU_TOGGLE`, `MINIMAP_OPEN` → `MENU_OPEN`, `MINIMAP_LEFT_CLICK` / `_RIGHT_CLICK` / `_SHIFT_LEFT_CLICK` / `_SHIFT_RIGHT_CLICK` / `_MIDDLE_CLICK` → `MENU_CLICK_*`, `MINIMAP_OPTIONS_KEYBIND` → `MENU_CLICK_SHIFT_MIDDLE`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`, `MINIMAP_TRADABLE_MORE` → `MENU_MORE`.
- **New:** `MENU_ON` / `MENU_OFF`, copied from Tracking Eye's. `MENU_ROLLS_SETTING` "%s, %s": each locale's `MINIMAP_ROLLS_SETTING` with its leading `%s: ` removed. `MENU_MORE_FEATURES` "More Features", translated fresh once and copied to every add-on with More Features.
- **Retire** `MINIMAP_ROLLS_SETTING`, `MINIMAP_ROLLS_SETTING_MANUAL`; and `STATUS_ENABLED` / `STATUS_DISABLED` only if nothing else reads them. **Keep** `STATUS_PAUSED`.

## Code

- Copy the kit and plate from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows above.
- `Features/Minimap-Button.lua`: remove `ShowTooltip`, `AddFeatureBlock`, `RollSettingLine` and the click tables; keep the toggles, `ns:UpdateMinimapIcon`, the loot-window helpers and the icon fit. `OnClick` goes to the kit.

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror: the root panel reorders.** Today it reads Speedy Loot, Automated Rolls, Automated Opening, Loot Toasts, Loot Sounds, Loot Announcements, Automated Master Looting, Roll Macro. It becomes the three blocks in menu order (Automated Rolls, Automated Opening, Loot Announcements), then Speedy Loot, Loot Toasts, Loot Sounds, Automated Master Looting and Roll Macro. The menu gains **More Features** with those five as compact rows (`TAB_SPEEDY_LOOT`, `TAB_LOOT_TOASTS`, `TAB_LOOT_SOUNDS`, `TAB_MASTER_LOOTER`, `TAB_ROLL_MACRO`), their switches' captions and descriptions as tooltips. **Automated Master Looting is set once per raid, not mid-fight, so it's a compact row**, and its row keeps the toggle's side effects (the not-master-looter chat line, the pop-ups). `FEATURE_SWITCHES` in `Options/Options-General.lua` becomes `ns.FEATURES`.
- **One refresh.** Each toggle's hand-listed `NotifyChange` calls (its own panel, General, the master-looter pop-ups) become its side effects, then `ns.RefreshSettings()`.
- **Button: two fixes.** GogoLoot is Simple, so its position moves from `ns.db.global.minimap` to `ns.db.profile.minimap`, copied over once in a migration so no button jumps. `ns:UpdateMinimapIcon` stops calling `LibDBIcon:Refresh`: assigning `brokerObject.icon` is enough. Icon Fit runs on Camelot and Mainline, as the rule says, not Camelot alone.

## Check in Game

- [ ] Each click in Button Clicks does its job with the menu open and closed, the state word follows, and the icon swaps with Automated Rolls.
- [ ] Automated Opening reads Paused while it's paused.
- [ ] Locked Items shows only with locked boxes in bags; a Rogue sees the Pick Lock line.
- [ ] Party and Raid read back each setting, Manual included.
- [ ] A controller's cursor reaches every row.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
