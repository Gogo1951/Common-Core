# Control Freak: Mini-map Menu

**State:** tooltip.
**Needs first:** `Menu-Kit.md`.
**Labels:** `Type: Design`, `Area: Features`.

## Today

`Features/Minimap-Button.lua` → `RefreshTooltip`, driven by the `BLOCKS` table:

```
Control Freak                                      [version]
Monitoring                              Enabled / Disabled (red)
Taunts, interrupts, fears, incapacitation, tank deaths, and peer pressure.
Left-Click                                            Toggle
Naughty List                            Enabled / Disabled
Frost novas, parry monkeys, pets left on taunt, and shields on rage tanks.
Right-Click                                           Toggle
Tanking Tools                           Enabled / Disabled
Cold openers and armor debuffs.
Shift + Left-Click                                    Toggle
Control Freak Options
Shift + Middle-Click
```

With All Alerts off, the three blocks give way to a red `All Alerts is off, so nothing fires.`, and every click but Shift + Middle-Click does nothing. Nothing on the button turns All Alerts back on.

## The Menu

| Row | Kind | Left | Right | Click | Shows |
|---|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | | always |
| All Alerts | status | `KILL_SWITCH` | On / Off | | always |
| | note | `MINIMAP_ALL_ALERTS_OFF` | | | All Alerts off |
| Toggle | action | `MENU_TOGGLE` | | none | always; tooltip `KILL_SWITCH_ENABLE` / `KILL_SWITCH_ENABLE_DESC` |
| Monitoring | status | `OPTIONS_MONITORING_LABEL` | On / Off | | All Alerts on |
| | description | `MONITORING_MINIMAP_SUMMARY` | | | |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | |
| Naughty List | status | `OPTIONS_NAUGHTY_LIST_LABEL` | On / Off | | All Alerts on |
| | description | `NAUGHTY_LIST_MINIMAP_SUMMARY` | | | |
| Toggle | action | `MENU_TOGGLE` | Right-Click | RightButton | |
| Tanking Tools | status | `TAB_TANKING_TOOLS` | On / Off | | All Alerts on |
| | description | `TANKING_TOOLS_MINIMAP_SUMMARY` | | | |
| Toggle | action | `MENU_TOGGLE` | Shift + Left-Click | ShiftLeftButton | |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

All Alerts is the **master switch** pattern: first block, no description (its title says it), and while it's off the blocks it silences hide behind a gray note. Each Toggle's tooltip is that switch's own name and description from the options.

No flyouts for now. Monitoring and Naughty List each switch a handful of alerts in options; a flyout per block is a follow-up only if players change those mid-session.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | Monitoring on/off | Monitoring's Toggle |
| Right-Click | Naughty List on/off | Naughty List's Toggle |
| Shift + Left-Click | Tanking Tools on/off | Tanking Tools' Toggle |
| Shift + Middle-Click | Options | Options |

While All Alerts is off, the three clicks do nothing, as today, since their rows are hidden. Every toggle still goes through `ns:ApplyProfile()`, which re-tests the combat-log registration.

**Open:** Shift + Right-Click is the one click Control Freak leaves free. It could take All Alerts' Toggle. Drawn without it; the maintainer decides.

## Strings

- **Rename, keeping every locale's text:** `ACTION_TOGGLE` → `MENU_TOGGLE`, `LEFT_CLICK` → `MENU_CLICK_LEFT`, `RIGHT_CLICK` → `MENU_CLICK_RIGHT`, `MINIMAP_SHIFT_LEFT_CLICK` → `MENU_CLICK_SHIFT_LEFT`, `SHIFT_MIDDLE_CLICK` → `MENU_CLICK_SHIFT_MIDDLE`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`.
- **New:** `MENU_ON` / `MENU_OFF`, copied from Tracking Eye's. `MENU_MORE`, copied from GogoLoot's `MINIMAP_TRADABLE_MORE` (the kit needs it).
- **Keep** `STATE_ON` / `STATE_OFF`: `STATUS_ALL_ALERTS_OFF` and the options read them.

## Code

- Copy the kit and plate from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua` builds the rows from the same `BLOCKS` table, each block given its `click` key.
- `Features/Minimap-Button.lua`: remove `RefreshTooltip` and the click loop; the LDB object goes to the kit. Keep registration and `ns:ApplyMinimapButton`.

## Check in Game

- [ ] All Alerts' Toggle turns it off: the three blocks hide and the note shows. Turned back on, they return with their own states unchanged.
- [ ] Left, Right and Shift + Left-Click on the button each flip their block, and the state word follows, with the menu open and closed.
- [ ] A switched-off feature stops firing (combat-log registration follows).
- [ ] A controller's cursor reaches every row.
