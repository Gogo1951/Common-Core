# Control Freak: Mini-map Menu

**State:** tooltip.
**Kit:** Tracking Eye's, copied from GitHub until Menu-Kit v2 lands (`Menu-Kit.md`, the maintainer's work). Until then the Code section's v2 names (an entry's `click` key, `OnClick` going to the kit) are built with Tracking Eye's `CLICKS` table and `ns.HandleLauncherClick` (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu).
**Live example:** Tracking Eye's menu: [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua) for the click table, feature blocks, flyouts and More Features; [`Features/Minimap-Button.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Button.lua) for the button.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Control-Freak#25](https://github.com/Gogo1951/Control-Freak/issues/25). Close it with the PR that builds this.

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
| Toggle | action | `MENU_TOGGLE` | Shift + Right-Click | ShiftRightButton | always; tooltip `KILL_SWITCH_ENABLE` / `KILL_SWITCH_ENABLE_DESC` |
| Monitoring | status / submenu | `OPTIONS_MONITORING_LABEL` | On / Off | | All Alerts on |
| | description | `MONITORING_MINIMAP_SUMMARY` | | | |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | |
| Naughty List | status / submenu | `OPTIONS_NAUGHTY_LIST_LABEL` | On / Off | | All Alerts on |
| | description | `NAUGHTY_LIST_MINIMAP_SUMMARY` | | | |
| Toggle | action | `MENU_TOGGLE` | Right-Click | RightButton | |
| Tanking Tools | status | `TAB_TANKING_TOOLS` | On / Off | | All Alerts on |
| | description | `TANKING_TOOLS_MINIMAP_SUMMARY` | | | |
| Its settings, inline | toggle, C_MUTED while Tanking Tools is off | `SCOPE_GROUP_HAS_TANK`, `TANKING_TOOLS_COLD_OPENER_HEADER`, `TANKING_TOOLS_ARMOR_HEADER`, then while Armor Debuffs is on `TANKING_TOOLS_ARMOR_FAERIE_FIRE` and `TANKING_TOOLS_ARMOR_RECKLESSNESS` | On / Off | | All Alerts on; tooltips are the options' own descriptions |
| Toggle | action | `MENU_TOGGLE` | Shift + Left-Click | ShiftLeftButton | |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

All Alerts is the **master switch** pattern: first block, no description (its title says it), and while it's off the blocks it silences hide behind a gray note. Each Toggle's tooltip is that switch's own name and description from the options.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | Monitoring on/off | Monitoring's Toggle |
| Right-Click | Naughty List on/off | Naughty List's Toggle |
| Shift + Left-Click | Tanking Tools on/off | Tanking Tools' Toggle |
| Shift + Right-Click | All Alerts on/off (new: today this click does nothing) | All Alerts' Toggle |
| Shift + Middle-Click | Options | Options |

While All Alerts is off, the three feature clicks do nothing, as today, since their rows are hidden; Shift + Right-Click still works, to turn it back on. Every toggle still goes through `ns:ApplyProfile()`, which re-tests the combat-log registration.

**Shift + Right-Click turns All Alerts on and off**, the one click Control Freak had free, so a mouse player can silence or restore every alert without opening the menu. It works while All Alerts is off, unlike the other three.

## Strings

- **Rename in `enUS.lua`**, each listed old → new in the prompt; the Localization Review carries every locale's text across: `ACTION_TOGGLE` → `MENU_TOGGLE`, `LEFT_CLICK` → `MENU_CLICK_LEFT`, `RIGHT_CLICK` → `MENU_CLICK_RIGHT`, `MINIMAP_SHIFT_LEFT_CLICK` → `MENU_CLICK_SHIFT_LEFT`, `SHIFT_MIDDLE_CLICK` → `MENU_CLICK_SHIFT_MIDDLE`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`.
- **New, in `enUS.lua`:** `MENU_ON` / `MENU_OFF` and `MENU_MORE` (the kit needs it). The Localization Review fills every other locale (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 4).
- **Keep** `STATE_ON` / `STATE_OFF`: `STATUS_ALL_ALERTS_OFF` and the options read them.

## Code

- Copy the kit and plate per Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua` builds the rows from the same `BLOCKS` table, each block given its `click` key.
- `Features/Minimap-Button.lua`: remove `RefreshTooltip` and the click loop; the LDB object goes to the kit. Keep registration and `ns:ApplyMinimapButton`.

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** The root panel already draws All Alerts (the master switch), then Monitoring, Naughty List and Tanking Tools with their tool switches under each. The menu matches it. **Monitoring and Naughty List gain a flyout of their tool switches**, the same rows in the same order from `ns.FEATURE_GROUPS`: Monitoring (Taunts, Interrupts, Fears, Incapacitated, Tank Deaths, Peer Pressure), Naughty List (Bad Mages, Bad Parry Monkeys, Bad Pets, Bad Priests). A flyout is empty, and its arrow gone, while its block is off. **Tanking Tools lists its settings inline instead** (the table above): it ships off, and a flyout would hide everything a player could switch on. Inline rows are gray while it's off, as the options panel draws them, and still switch. Captions and tooltips are the options' own. No More Features: every feature is a block.
- **One refresh.** `ns:ApplyProfile` already notifies every panel and re-tests the combat-log registration; `ns.RefreshSettings()` wraps that redraw plus the menu, and every switch, row and click ends in it.
- **Button:** a launcher keyed `ns.LOCALE_NAME`, Simple so `ns.db.profile.minimap`, shown through `ns:ApplyMinimapButton()`: already the standard.

## Check in Game

- [ ] All Alerts' Toggle and Shift + Right-Click both turn it off: the three blocks hide and the note shows. Turned back on, they return with their own states unchanged.
- [ ] Left, Right and Shift + Left-Click on the button each flip their block, and the state word follows, with the menu open and closed.
- [ ] A switched-off feature stops firing (combat-log registration follows).
- [ ] A controller's cursor reaches every row.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
