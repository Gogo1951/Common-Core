# Tracking Eye: Mini-map Menu

**State:** live on `main` ([Gogo1951/Tracking-Eye#32](https://github.com/Gogo1951/Tracking-Eye/pull/32)): the clicks are back on their rows, with More Features, the Features section and one refresh. Still to do: the Code section's move onto Menu-Kit v2, the maintainer's once the kit lands in Common-Core; nothing a player sees changes.
**Live code:** [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua), [`Features/Minimap-Button.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Button.lua), [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Options/Options-Utilities.lua) (`ns.FEATURES`), [`Features/Utilities.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Utilities.lua) (`ns.RefreshSettings`).
**Next:** its move onto Menu-Kit v2 (`Menu-Kit.md`).
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Tracking-Eye#31](https://github.com/Gogo1951/Tracking-Eye/issues/31). Closed by [Gogo1951/Tracking-Eye#32](https://github.com/Gogo1951/Tracking-Eye/pull/32).

## Before This Spec

The menu before Tracking-Eye#32 (`Features/Minimap-Menu.lua`): Persistent Tracking with its pick list, Toggle and Clear Tracking; Farm Mode with its flyout; Automatic Target Tracking (only for a character with an ability a hunt can cast); the Options row reading `Tracking Eye Options … Open`. Hover or Left-Click opens it. No other click does anything.

Before the menu (commit `fbcd7e3`), the tooltip's clicks were:

| Click | Job | String |
|---|---|---|
| Left-Click | Opened the Tracking Menu | `LEFT_CLICK` "Left-Click" |
| Right-Click | Clear Tracking | `RIGHT_CLICK` "Right-Click" |
| Shift + Left-Click | Farm Mode on/off | `SHIFT_LEFT` "Shift + Left-Click" |
| Shift + Right-Click | Automatic Target Tracking on/off | `SHIFT_RIGHT` "Shift + Right-Click" |
| Shift + Middle-Click | Options | `SHIFT_MIDDLE` "Shift + Middle-Click" |

## The Menu

The live menu, row by row.

| Row | Kind | Left | Right | Click |
|---|---|---|---|---|
| Header | header | `ADDON_TITLE` | version | — |
| Persistent Tracking | status / submenu | `PERSISTENT_TRACKING` | On / Off | — |
| | description | `MENU_PERSISTENT_DESCRIPTION` | | |
| Pick list | choice, one per known ability | spell icon + name | check | — |
| Toggle | action | `MENU_TOGGLE` | | none (it had none before) |
| Clear Tracking | action, while something's picked | `CLEAR_TRACKING` | **Right-Click** | RightButton |
| Farm Mode | status / submenu | `TAB_FARM_MODE` | Active / Paused / Off | — |
| | description | `MENU_FARM_DESCRIPTION` | | |
| Toggle | action | `MENU_TOGGLE` | **Shift + Left-Click** | ShiftLeftButton |
| Automatic Target Tracking | status, hunt-capable characters only | `TARGET_TRACKING` | On / Off | — |
| | description | `MENU_TARGET_DESCRIPTION` | | |
| Toggle | action | `MENU_TOGGLE` | **Shift + Right-Click** | ShiftRightButton |
| More Features | section | `MENU_MORE_FEATURES` | | — |
| Come & Get It, Free Placement Mode | toggle, one each | the switch's caption | On / Off | — |
| Options | action | `MENU_OPTIONS` (was `TOOLTIP_OPTIONS`) | **Shift + Middle-Click** | ShiftMiddleButton |

Flyouts (Persistent Tracking's class overrides, Farm Mode's status, abilities, conditions and extras) are unchanged.

## Button Clicks

- **Left-Click** opens and holds the menu, as it opened the old Tracking Menu. It has no row: the menu is its job.
- **Right-Click** with nothing picked does nothing, as Clear Tracking's row is hidden then.
- **Shift + Right-Click** on a character with no hunt ability does nothing, as the Target Tracking block is hidden.
- The **Blizzard tracking-button hook** (Classic Era) opens the menu on its own click and keeps doing so.

## Strings (built in Tracking-Eye#32)

- **Bring back from git** (`fbcd7e3:Locales/*.lua`), every locale, under the standard names: `RIGHT_CLICK` → `MENU_CLICK_RIGHT`, `SHIFT_LEFT` → `MENU_CLICK_SHIFT_LEFT`, `SHIFT_RIGHT` → `MENU_CLICK_SHIFT_RIGHT`, `SHIFT_MIDDLE` → `MENU_CLICK_SHIFT_MIDDLE`.
- **Rename:** `TOOLTIP_OPTIONS` → `MENU_OPTIONS`.
- **Retire:** `OPEN` (only the Options row read it).
- **New:** `MENU_MORE_FEATURES` "More Features", in every locale; other add-ons take its translations from here on GitHub (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 4). `MENU_MORE` "%d more" comes with the v2 move (the kit needs it; Tracking Eye's lists never reach 8 today).

## Code (the Menu-Kit v2 move: the maintainer's, once Common-Core#3 lands; nothing a player sees)

- `Features/Menu-Kit.lua` and `Includes/Images/Menu-Plate.tga`: replaced by Common-Core's copy.
- `Features/Minimap-Menu.lua`: drop the machinery the kit now owns (`Menu-Kit.md` → What Moves Where); build with `Kit.CreateMenu`, `Kit.FeatureBlock` and `Kit.OptionsRow`; add `click` to the three actions above.
- `Features/Minimap-Button.lua`: `OnClick` calls `menu:HandleClick(self, button)`.

## Features, Refresh and Button (built in Tracking-Eye#32)

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror.** The root panel's Features section is built from `ns.FEATURES` in `Options/Options-Utilities.lua`: Persistent Tracking, Farm Mode, Automatic Target Tracking (the three blocks, in menu order), then Come & Get It and Free Placement Mode. Each switch binds the same setting as its panel's enable toggle. Tracking Eye follows Features Mirror like every other add-on, with no README-Notes exception.
- **More Features** in the menu: Come & Get It and Free Placement Mode as compact rows, each with its switch's caption and description (`OPTIONS_ENABLE_COME_AND_GET_IT`, `OPTIONS_ENABLE_FREE` and their descriptions) as the tooltip.
- **One refresh.** `ns.RefreshSettings()` in `Features/Utilities.lua` replaced `ns.RefreshOptionsPanels` and the separate menu redraw, and is called by every options `set`, every menu and button click, the Cycle Farm Mode Ability binding and slash commands that change a setting, and `ns:ApplyProfile`.
- **Button:** a launcher keyed `ADDON_NAME`, Per-Character so `ns.db.global.minimap`, shown or hidden by `ns:ApplyMinimapButton()`.
- **Placement:** the reference the kit takes.

## Check in Game

On a hunter, a druid and a warrior, with a mouse and with a controller:

- [ ] Each click in Button Clicks does its job with the menu open and closed, and the open menu redraws.
- [ ] Each row names its click; Persistent Tracking's Toggle names none.
- [ ] Everything in the old menu still works, flyouts included.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
