# Tracking Eye: Mini-map Menu

**State:** converted to a menu; the conversion dropped the button's four clicks. This brings them back and moves the menu onto Menu-Kit v2.
**Needs first:** `Menu-Kit.md`.
**Labels:** `Type: Design`, `Area: Features`.
**Issue:** [Gogo1951/Tracking-Eye#31](https://github.com/Gogo1951/Tracking-Eye/issues/31). Close it with the PR that builds this.

## Today

The menu on `main` (`Features/Minimap-Menu.lua`): Persistent Tracking with its pick list, Toggle and Clear Tracking; Farm Mode with its flyout; Automatic Target Tracking (only for a character with an ability a hunt can cast); the Options row reading `Tracking Eye Options … Open`. Hover or Left-Click opens it. No other click does anything.

Before the menu (commit `fbcd7e3`), the tooltip's clicks were:

| Click | Job | String |
|---|---|---|
| Left-Click | Opened the Tracking Menu | `LEFT_CLICK` "Left-Click" |
| Right-Click | Clear Tracking | `RIGHT_CLICK` "Right-Click" |
| Shift + Left-Click | Farm Mode on/off | `SHIFT_LEFT` "Shift + Left-Click" |
| Shift + Right-Click | Automatic Target Tracking on/off | `SHIFT_RIGHT` "Shift + Right-Click" |
| Shift + Middle-Click | Options | `SHIFT_MIDDLE` "Shift + Middle-Click" |

## The Menu

Unchanged row for row, except the click column.

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
| Options | action | `MENU_OPTIONS` (was `TOOLTIP_OPTIONS`) | **Shift + Middle-Click** | ShiftMiddleButton |

Flyouts (Persistent Tracking's class overrides, Farm Mode's status, abilities, conditions and extras) are unchanged.

## Button Clicks

- **Left-Click** opens and holds the menu, as it opened the old Tracking Menu. It has no row: the menu is its job.
- **Right-Click** with nothing picked does nothing, as Clear Tracking's row is hidden then.
- **Shift + Right-Click** on a character with no hunt ability does nothing, as the Target Tracking block is hidden.
- The **Blizzard tracking-button hook** (Classic Era) opens the menu on its own click and keeps doing so.

## Strings

- **Bring back from git** (`fbcd7e3:Locales/*.lua`), every locale, under the standard names: `RIGHT_CLICK` → `MENU_CLICK_RIGHT`, `SHIFT_LEFT` → `MENU_CLICK_SHIFT_LEFT`, `SHIFT_RIGHT` → `MENU_CLICK_SHIFT_RIGHT`, `SHIFT_MIDDLE` → `MENU_CLICK_SHIFT_MIDDLE`.
- **Rename:** `TOOLTIP_OPTIONS` → `MENU_OPTIONS`.
- **Retire:** `OPEN` (only the Options row read it).
- **New:** `MENU_MORE` "%d more" (the kit needs it; Tracking Eye's lists never reach 8 today). `MENU_MORE_FEATURES` "More Features", translated fresh once and copied to every add-on with More Features.

## Code

- `Features/Menu-Kit.lua` and `Includes/Images/Menu-Plate.tga`: replaced by Common-Core's copy.
- `Features/Minimap-Menu.lua`: drop the machinery the kit now owns (`Menu-Kit.md` → What Moves Where); build with `Kit.CreateMenu`, `Kit.FeatureBlock` and `Kit.OptionsRow`; add `click` to the three actions above.
- `Features/Minimap-Button.lua`: `OnClick` calls `menu:HandleClick(self, button)`.
- `README-Notes.md`: delete the "Feature switches with their features" exception (Features, Refresh and Button).

## Features, Refresh and Button

Style Guide → MINIMAP MENU → Features Mirror, One Refresh, Placement; MINIMAP BUTTON → Building the Button.

- **Features mirror: the root panel has no Features section yet.** Add one, built from a new `ns.FEATURES`: Persistent Tracking, Farm Mode, Automatic Target Tracking (the three blocks, in menu order), then Come & Get It and Free Placement Mode. Each switch binds the same setting as its panel's enable toggle. **The README-Notes exception "Feature switches with their features" is withdrawn:** Tracking Eye follows Features Mirror like every other add-on, so the PR deletes that entry along with adding the section.
- **The menu gains More Features:** Come & Get It and Free Placement Mode as compact rows, each with its switch's caption and description (`OPTIONS_ENABLE_COME_AND_GET_IT`, `OPTIONS_ENABLE_FREE` and their descriptions) as the tooltip.
- **One refresh.** `ns.RefreshOptionsPanels` and `ns.RefreshMenu` become `ns.RefreshSettings()`, called by every options `set`, every menu and button click, the Cycle Farm Mode Ability binding and slash commands that change a setting, and `ns:ApplyProfile`.
- **Button:** already right (a launcher keyed `ADDON_NAME`, Per-Character so `ns.db.global.minimap`). Its show/hide function is renamed `ns:ApplyMinimapButton()`.
- **Placement:** already right; it's the reference the kit takes.

## Check in Game

On a hunter, a druid and a warrior, with a mouse and with a controller:

- [ ] Each click in Button Clicks does its job with the menu open and closed, and the open menu redraws.
- [ ] Each row names its click; Persistent Tracking's Toggle names none.
- [ ] Everything in the old menu still works, flyouts included.
- [ ] Flip each Features switch in options with the menu open: the menu follows. Flip each in the menu with options open: options follow. Same after a profile switch.
- [ ] The menu opens from the button's corner in all four screen quadrants, and from an LDB display bar if one is installed.
