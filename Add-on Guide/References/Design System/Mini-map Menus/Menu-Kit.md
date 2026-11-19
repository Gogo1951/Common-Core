# Menu-Kit v2 (Common-Core)

The shared renderer every Gogo menu is built on, in Common-Core so every add-on copies one file. **Landed:** [`addon-kits/Menu-Kit/`](https://github.com/Gogo1951/Common-Core/tree/main/addon-kits/Menu-Kit) holds `Features/Menu-Kit.lua` and `Includes/Images/Menu-Plate.tga`, checked by StyLua, luacheck, `luac5.1 -p` and `scripts/test-menu-kit.lua` (`lua5.1 scripts/test-menu-kit.lua` from Common-Core). A change to it is the maintainer's work, in a session launched in `~/Common-Core`; a session in an add-on folder never edits it.

- **Issue:** [Gogo1951/Common-Core#3](https://github.com/Gogo1951/Common-Core/issues/3), open until Tracking Eye runs on v2. It was closed on 2026-11-14 with nothing landed and reopened 2026-11-19; the kit landed the same day.
- **The add-ons are still on v1 until each moves:** Tracking Eye, GogoLoot, Magic Eraser and Good to Go each carry v1 (`Features/Menu-Kit.lua`, byte for byte the same on GitHub `main`) and drive it from their own `Minimap-Menu.lua`. **v2 keeps v1's names** (`Kit.CreatePanel`, `panel:Render`, `panel:SubmenuRow`, `panel.onEnterRow`, `Kit.SetToggleText`, `Kit.IsCursorOver`, `Kit.IsInside`, `Kit.SUBMENU_ARROW`, `Kit.FLYOUT_GAP`, `Kit.FLYOUT_RISE`, the `hint` kind), so syncing v2 over a v1 copy changes nothing but the look the rules already ask for: sub-menus overlap their menu (`FLYOUT_GAP` is now negative), long labels wrap at 320, and an `action` row with no colors of its own reads INFO and MUTED. Checked offline with Tracking Eye's own `Minimap-Menu.lua` on v2. **Good to Go's local copy is ahead of GitHub:** the MENUS pieces it carries (`Kit.FLYOUT_OVERLAP`, a switch's own `submenu` with the arrow column, `Kit.AddPlate`, `Kit.OpenContextMenu`, `Kit.AddMenuHeader`, `Kit.PlatePullout`) were never pushed, so v2 builds them from Style Guide → MENUS. Before syncing Good to Go, check its calls against v2's signatures below; `OpenContextMenu`, `AddMenuHeader` and `PlatePullout` are untested in game.
- **Rules:** Style Guide → MINIMAP MENU.
- **Pieces:** `../README.md` → Components, Patterns, Kit Changes (Menu-Kit v2).
- **Drawn:** `../Mini-map Menus.html`.
- **The look comes from:** Pretty Wide Quest Log's Quest Arrow menu, [`Features/Routes/Routes-Arrow-Menu-Panel.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Features/Routes/Routes-Arrow-Menu-Panel.lua). v1 was cut from it (the same plate, nine-slice, insets, gold highlight and spacing; its `Route-Menu.tga` is byte for byte `Menu-Plate.tga`), and it has since grown four things v2 asks for, already working in game: a row's `hover` look, measured in both states so the width never moves (`rightOnHover`); an `itemID` row that shows the item's tooltip on hover (`item`); a color given as `{ r, g, b }` as well as a palette key (raw colors); and `Fill`, which lays a panel out again only when what its rows say changes, with the flyout's label keeping its highlight while the flyout is open. Read it before writing those pieces. It stays PWQL's own file: the Quest Arrow and world-map menus aren't mini-map menus.
- **Built from:** Tracking Eye's [`Features/Menu-Kit.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Menu-Kit.lua) and the generic half of its [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua), and Magic Eraser's [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Menu.lua) (the More Features flyout and count, and the hover-only right side), on GitHub `main`.

## What Moves Where

| Today, in Tracking Eye | v2 |
|---|---|
| `Features/Menu-Kit.lua`: plate, rows, layout | `addon-kits/Menu-Kit/Features/Menu-Kit.lua` here, unchanged in spirit |
| `Includes/Images/Menu-Plate.tga` | `addon-kits/Menu-Kit/Includes/Images/Menu-Plate.tga` here |
| `Minimap-Menu.lua`: `CreatePanel` for menu and flyout, `UISpecialFrames`, `PositionMenu`, `PositionFlyout`, the `OnUpdate` close timer, `OnHide`, `RenderFlyout`, `ns.ShowMenu`, `ns.HideMenu`, `ns.RefreshMenu`, `ns.IsMenuShown`, `ns.IsMenuFrame`, `ns.OpenFlyout`, `menu.onEnterRow` | Into the kit, behind `Kit.CreateMenu` |
| `Minimap-Menu.lua`: `AddFeature` | Into the kit as `Kit.FeatureBlock` |
| `Minimap-Menu.lua`: `OptionTooltip`, `Toggle`, `Section`, `Separator`, `OnOff` | Into the kit as small helpers |
| Magic Eraser's `Minimap-Menu.lua`: `FLYOUTS.features`, `AddMoreFeatures` | Into the kit as `Kit.MoreFeatures` |
| Magic Eraser's `Minimap-Menu.lua`: `ApplyHoverIcons` and its hooks | Into the kit's row drawing, as the `rightOnHover` entry flag |
| `Minimap-Menu.lua`: tracking rows, flyouts, the Blizzard tracking-button hook | Stays in Tracking Eye |

## API

```lua
local Kit = ns.MenuKit

-- Once at load, every string the add-on localizes.
Kit.SetText({
	on = L["MENU_ON"], off = L["MENU_OFF"], toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"], -- "%d more"
	moreFeatures = L["MENU_MORE_FEATURES"], -- "More Features"
	featuresOn = L["MENU_FEATURE_COUNT_ON"], featuresOff = L["MENU_FEATURE_COUNT_OFF"], -- "%d On", "%d Off"
	count = L["ITEM_QUANTITY"], -- "x%d"; optional, default "x%d"
	clicks = {
		LeftButton = L["MENU_CLICK_LEFT"], RightButton = L["MENU_CLICK_RIGHT"], MiddleButton = L["MENU_CLICK_MIDDLE"],
		ShiftLeftButton = L["MENU_CLICK_SHIFT_LEFT"], ShiftRightButton = L["MENU_CLICK_SHIFT_RIGHT"],
		ShiftMiddleButton = L["MENU_CLICK_SHIFT_MIDDLE"],
	},
})

-- One menu per add-on. build returns the main entries; flyouts[key] returns a flyout's.
local menu = Kit.CreateMenu({
	name = ADDON_NAME .. "Menu", -- named, so Escape closes it
	build = BuildMainEntries,
	flyouts = FLYOUTS,
	afterChange = ns.RefreshSettings, -- every row click and button click ends here (One Refresh)
	fallback = nil, -- optional { LeftButton = fn }: run when no entry's click matches
})

-- The LDB object hands the kit its events; the kit routes clicks through the click table.
OnEnter = function(self) menu:Show(self, "hover") end,
OnLeave = function() end,
OnClick = function(self, button) menu:HandleClick(self, button) end,
```

- **`Kit.FeatureBlock(entries, { key, title, state, stateColor, description, note, rows, toggle, after })`**, where `toggle = { name, desc, flip, click, label, on, confirm }`: `click` is a click key (`"ShiftLeftButton"`) or nil, `label` replaces Toggle (`MENU_OPEN`), and with `on` and `confirm` turning it off asks first.
- **Action entries** carry `click = "RightButton"` (or nil). The kit draws that click's name on the row's right in MUTED. `menu:HandleClick` finds the entry whose `click` matches, across the main entries only, and runs its `onClick`. With no match, the kit runs the add-on's `fallback[button]` when it gave one (Magic Eraser's Left-Click erases even while its Erase row is hidden); otherwise a Left-Click opens and holds the menu, and anything else does nothing. Shift + Middle-Click with no match opens `ns:OpenOptionsPanel()`, so every add-on gets it for free.
- **The Options row** is `Kit.OptionsRow(entries, L["MENU_OPTIONS"])`: spacer, separator, and an action row naming Shift + Middle-Click, which closes the menu and opens options.
- **Two new kinds:**
  - `item`: `{ kind = "item", itemID or link, count, right, rightColor, onClick }`. The kit draws the icon at line height and the name in its quality color without brackets, adds the count, and shows the item's tooltip on hover. An uncached item draws `Loading ID: %d` in MUTED and redraws when it arrives.
  - `value`: `{ kind = "value", left, right }`. BODY left, TEXT right, nothing to click.
- **`Kit.List(entries, rows, max)`** appends up to `max` (8) rows, then a `note` saying how many more.
- **Colors** take a palette key or a six-digit hex (class colors, quality colors).
- **`MAX_WIDTH = 320`** for the menu and every flyout. The left text of every row wraps within what's left after its right side and the 16-point gap, and the row grows to the wrapped height; the right side never wraps and stays level with the first line. Measured across all six add-ons and 11 locales, 55 of 682 rows ran past 320 on one line, worst 465, and none does with wrapping (`../README.md` → Will It Fit).
- **Defaults:** `action` is INFO left and MUTED right. The `hint` kind is retired for new menus: it still draws, blue both sides, so GogoLoot's v1 menu runs on v2 until its move.
- **`Kit.MoreFeatures(entries, features)`** appends the More Features `submenu` row and builds its flyout: one compact toggle per set-and-forget feature from the add-on's `ns.FEATURES`, gated and confirmed as its switch is (Features Mirror). The row's right side counts the flyout's switches, `4 On, 3 Off` (On count ON, comma TEXT, Off count MUTED), then the arrow; block features aren't counted.
- **`rightOnHover = true`** on any entry shows its right side only while the row is hovered. The kit still measures it, so the menu never changes width on hover. A click-to-remove list row uses it for its delete icon (Style Guide → MINIMAP MENU → Blocks Beyond Features, Editable list).
- **`afterChange`** is the add-on's `ns.RefreshSettings` in every add-on (One Refresh).
- **Placement** is the kit's (Placement): corner to opposite corner, 2 points apart, by screen halves, flyout and row tooltips on the same side.
- **Any LDB display works.** The anchor is whatever frame called `OnEnter`: the mini-map button, or a Titan Panel or ChocolateBar plugin.
- **Every menu, not only the mini-map's.** `menu:Show(anchor, how, flyoutKey)` takes `how` = `"hover"` or `"click"` (off a button's corner), `"line"` (off a window's line, overlapping it by 12) or `"cursor"` (a right-click menu, at the cursor). Sub-menus go three deep, each on the side the menu opened toward. `Kit.MenuHeader(title)` is a right-click menu's header: the title gold, the add-on's Short Name (`Kit.SetText{ shortName = ... }`) gray. Pass `publish = false` to any menu but the mini-map's: the first menu without it sets `ns.ShowMenu(anchor, flyoutKey, how)`, `ns.HideMenu`, `ns.RefreshMenu` (every open menu redraws), `ns.IsMenuShown`, `ns.IsMenuFrame` and `ns.OpenFlyout(key)`, v1's names, so `ns.RefreshSettings` reaches it.
- **The game's menus in the kit's dress:** `Kit.OpenContextMenu(owner, generator)` opens `MenuUtil.CreateContextMenu` and lays the plate under the menu and each sub-menu made with `Kit.Submenu(description, text)` as it opens, clearing whatever background a skin laid there, and gives it back when the game pools the frame. `Kit.AddMenuHeader(rootDescription, title)` writes the header on it. `Kit.PlatePullout(dropdown)` puts an AceGUI dropdown's list on the plate and gives its border back on release. `Kit.AddPlate(frame)` lays the plate alone under any frame.
- **More entry fields:** `closes = true` for a pick that acts (the menu closes first); `flyout = function` in place of `flyouts[submenu]`, for a sub-menu built on the spot (More Features uses it); `hover = { right, rightColor }` for a hover look measured in both states.
- **Small helpers:** `Kit.Toggle(store, field, name, desc, onChange)`, `Kit.OptionTooltip(name, desc)`, `Kit.OnOff(enabled)`, `Kit.Section(text, right, rightColor)`, `Kit.Separator()`, `Kit.Spacer()`, `Kit.Confirm(text, onYes)` (Yes or No first; the text is never formatted), `Kit.Color(color, text)` and `Kit.RefreshAll()`.

## Distribution

1. The kit and plate live in `addon-kits/Menu-Kit/` here, in folders that mirror an add-on's (`Features/Menu-Kit.lua`, `Includes/Images/Menu-Plate.tga`), as Options-Kit's do.
2. **Already built, for every kit:** `scripts/sync-addon-kits.sh` copies a kit into each add-on that holds any of its files and leaves the rest alone (`--adopt Menu-Kit` the first time), and the reusable `ci.yml`'s **Shared kits match Common-Core** check fails an add-on whose copy differs, plate included. Dropping the two files into `addon-kits/Menu-Kit/` is all Menu-Kit needs.
3. **An add-on holding the kit's Lua file has adopted it**, and its next CI run fails until it's synced: Tracking Eye, GogoLoot, Magic Eraser and Good to Go, so each takes `scripts/sync-addon-kits.sh` on its next change (Good to Go after the check above). **Art alone doesn't adopt a kit:** the CI check and the sync script key adoption on a kit's `.lua` files, so Play It Forward, which carries only `Includes/Images/Menu-Plate.tga` for its reopen button, is left alone.
4. Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1, copies the kit from `addon-kits/Menu-Kit/` instead of Tracking Eye on GitHub.

## Done When

- [x] `addon-kits/Menu-Kit/` holds the kit and plate; StyLua, luacheck (under all four add-ons' configs), `luac5.1 -p` and `scripts/test-menu-kit.lua` pass on it.
- [x] The sync script and the CI check are in (`scripts/sync-addon-kits.sh`, built with Options-Kit).
- [ ] Tracking Eye runs on v2 with nothing visible changed but More Features, which moves into its flyout (`Tracking Eye.md`). That's the proof.
- [x] Style Guide → MINIMAP MENU's live references point at `addon-kits/Menu-Kit/`.
