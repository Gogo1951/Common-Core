# Water Dispenser: Mini-map Menu

**State:** tooltip. The smallest conversion, so it goes first after Tracking Eye.
**Needs first:** `Menu-Kit.md`.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Water-Dispenser#25](https://github.com/Gogo1951/Water-Dispenser/issues/25). Close it with the PR that builds this.

## Today

`Features/Minimap-Button.lua` → `ShowTooltip`:

```
Water Dispenser                                    [version]
Dispense                                Enabled / Disabled (red)
Automatically fills the trade window when a trade opens, based on your settings.
Left-Click                                            Toggle
Dispense Report               (only while Dispense is on and something's carried)
  [icon] Conjured Crystal Water                           60
Water Dispenser Options
Shift + Middle-Click
```

Clicks: Left-Click flips Dispense; Shift + Middle-Click opens options.

## The Menu

| Row | Kind | Left | Right | Click | Shows |
|---|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | | always |
| Dispense | status | `TAB_DISPENSE` | On (ON) / Off (MUTED) | | always |
| | description | `OPTIONS_DISPENSE_MASTER_DESC` | | | always |
| Toggle | action | `MENU_TOGGLE` | Left-Click | LeftButton | always; tooltip is the Dispense master switch's name and desc |
| Dispense Report | status | `MINIMAP_DISPENSE_REPORT` | | | Dispense on and `BuildAnnouncementSnapshot(true)` not empty |
| Each entry | item | item | count, only when `IncludeQuantity` | | as above; `Kit.List`, 8 max |
| Options | action | `MENU_OPTIONS` | Shift + Middle-Click | ShiftMiddleButton | always |

No flyout: Dispense's settings are set-and-forget and stay in options.

## Button Clicks

| Click | Job | Row |
|---|---|---|
| Left-Click | `ns.SetDispense(not …)` | Toggle |
| Shift + Middle-Click | Options | Options |

Hover opens the menu. Left-Click has a job, so it doesn't open it.

## Strings

- **Rename, keeping every locale's text:** `UI_TOGGLE` → `MENU_TOGGLE`, `UI_LEFT_CLICK` → `MENU_CLICK_LEFT`, `MINIMAP_OPTIONS_KEYBIND` → `MENU_CLICK_SHIFT_MIDDLE`, `MINIMAP_OPTIONS` → `MENU_OPTIONS`.
- **New:** `MENU_ON` "On" and `MENU_OFF` "Off", every locale's text copied from Tracking Eye's; `MENU_MORE` "%d more", copied from GogoLoot's `MINIMAP_TRADABLE_MORE`.
- **Retire** `UI_ENABLED` / `UI_DISABLED` only if nothing else reads them.

## Code

- Copy `Features/Menu-Kit.lua` and `Includes/Images/Menu-Plate.tga` from Common-Core; add `Features/Menu-Kit.lua` and `Features/Minimap-Menu.lua` to every TOC after `Features/Utilities.lua`.
- New `Features/Minimap-Menu.lua`: the rows above.
- `Features/Minimap-Button.lua`: remove `ShowTooltip` and `AddDispenseReport`; the LDB object's `OnEnter` / `OnLeave` / `OnClick` go to the kit. Keep `ns.ToggleMinimapButton` and `ns.InitMinimap`.
- Every Dispense change (button, row, options) redraws the open menu.

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** Root panel order stays Dispense, then Announcement Macro, Inventory in Player Tooltips, Bag Tooltips for Dispensed Items, now built from `ns.FEATURES`. The menu gains **More Features** with those three as compact rows (each labeled by its panel's name, or its caption without Enable), their switches' captions and descriptions as tooltips.
- **One refresh.** Every `NotifyChange` in `Features/Dispenser.lua`, `Features/Announcements.lua` and the options panels becomes `ns.RefreshSettings()`, which `ns:ApplyProfile` calls too.
- **Button:** a launcher keyed `ns.LOCALE_NAME`, Simple so `ns.db.profile.minimap`: right. Rename `ns.ToggleMinimapButton` → `ns:ApplyMinimapButton()`, a plain `Refresh` with the current subtable.

## Check in Game

- [ ] Hover opens the menu; Left-Click on the button flips Dispense and the state word follows; the Toggle row does the same.
- [ ] Dispense Report shows only while Dispense is on and something's carried, with counts where they belong.
- [ ] Shift + Middle-Click and the Options row both open options.
- [ ] A controller's cursor reaches every row.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
