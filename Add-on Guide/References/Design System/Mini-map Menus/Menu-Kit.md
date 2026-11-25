# Menu-Kit v2 (Common-Core)

The shared renderer every Gogo menu is built on, in Common-Core so every add-on copies one file. **Landed:** [`addon-kits/Menu-Kit/`](https://github.com/Gogo1951/Common-Core/tree/main/addon-kits/Menu-Kit) holds `Features/Menu-Kit.lua`, `Includes/Images/Menu-Plate.tga` and `Includes/Images/Menu-Arrow.tga`, checked by StyLua, luacheck, `luac5.1 -p` and `scripts/test-menu-kit.lua` (`lua5.1 scripts/test-menu-kit.lua` from Common-Core). A change to it is the maintainer's work, in a session launched in `~/Common-Core`; a session in an add-on folder never edits it.

- **Issue:** [Gogo1951/Common-Core#3](https://github.com/Gogo1951/Common-Core/issues/3), closed 2026-11-19 with the kit on `main`. Each add-on's move onto v2 is that add-on's own project, starting with Tracking Eye ([Gogo1951/Tracking-Eye#31](https://github.com/Gogo1951/Tracking-Eye/issues/31)).
- **v2 keeps v1's names** (`Kit.CreatePanel`, `panel:Render`, `panel:SubmenuRow`, `panel.onEnterRow`, `Kit.SetToggleText`, `Kit.IsCursorOver`, `Kit.IsInside`, `Kit.SUBMENU_ARROW`, `Kit.FLYOUT_GAP`, `Kit.FLYOUT_RISE`, the `hint` kind), so syncing v2 over a v1 copy changes nothing but the look the rules already ask for: sub-menus overlap their menu (`FLYOUT_GAP` is now 0), long labels wrap at 320, and an `action` row with no colors of its own reads INFO and MUTED. Checked offline with Tracking Eye's own `Minimap-Menu.lua` on v2. `Kit.OpenContextMenu`, `Kit.AddMenuHeader` and `Kit.PlatePullout` are untested in game.
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
| The game's submenu triangle | `addon-kits/Menu-Kit/Includes/Images/Menu-Arrow.tga` here, the kit's own chevron |
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
	clicks = { RightButton = L["MENU_CLICK_RIGHT"] }, -- "Right-Click"; only where the button keeps a click
})

-- One menu per add-on. build returns the main entries; flyouts[key] returns a flyout's.
local menu = Kit.CreateMenu({
	name = ADDON_NAME .. "Menu", -- named, so Escape closes it
	build = BuildMainEntries,
	flyouts = FLYOUTS,
	afterChange = ns.RefreshSettings, -- every row click and button click ends here (One Refresh)
	fallback = nil, -- optional { RightButton = fn }: run when no entry's click matches
})

-- The LDB object hands the kit its events; the kit routes clicks through the click table.
OnEnter = function(self) menu:Show(self, "hover") end,
OnLeave = function() end,
OnClick = function(self, button) menu:HandleClick(self, button) end,
```

- **`Kit.FeatureBlock(entries, { key, title, state, stateColor, description, note, rows, toggle, after })`**, where `toggle = { name, desc, flip, click, label, on, confirm }`: `click` is the button's one kept click (`"RightButton"`) or nil, `label` replaces Toggle (`MENU_OPEN`), and with `on` and `confirm` turning it off asks first.
- **Clicks** (Style Guide → MINIMAP MENU → Button Clicks). `menu:HandleClick` gives Left-Click to the menu in every add-on: it holds a menu hover opened and closes one it already holds, whatever the entries or `fallback` say. Any other click runs the main entry whose `click` matches, then the add-on's `fallback[button]` (Magic Eraser's Right-Click erases even while its Erase row is hidden); a click with no job does nothing. Shift + Middle-Click no longer opens options.
- **Action entries** carry `click = "RightButton"` (or nil), the button's one kept click. The kit draws its name from `clicks` on the row's right in MUTED, as it does a gesture. A row answers any mouse button (`RegisterForClicks("AnyUp")`).
- **The Options row** is `Kit.OptionsRow(entries, L["MENU_OPTIONS"])`: spacer, separator, and an action row with no click, which closes the menu and opens options.
- **Two new kinds:**
  - `item`: `{ kind = "item", itemID or link, count, right, rightColor, onClick }`. The kit draws the icon at line height and the name in its quality color without brackets, adds the count, and shows the item's tooltip on hover. An uncached item draws `Loading ID: %d` in MUTED and redraws when it arrives.
  - `value`: `{ kind = "value", left, right }`. BODY left, VALUE right (Off in MUTED). With `submenu`, it's a picker: the value, then the arrow.
- **`Kit.List(entries, rows, max)`** appends every row, or up to `max` when given, then a `note` saying how many more.
- **Colors** take a palette key or a six-digit hex (class colors, quality colors).
- **`MAX_WIDTH = 320`** for the menu and every flyout. The left text of every row wraps within what's left after its right side and the 16-point gap, and the row grows to the wrapped height; the right side never wraps and stays level with the first line. A wrapped label's text is cleared and then set again once its width is set, because the game doesn't re-wrap a string whose text hasn't changed, so it re-wraps at that width on every layout, refreshes included, instead of drawing the cut-off one-line layout; the string is pinned to the height it then measures (a one-line label to the line height), and the row is sized from that. Measured across all six add-ons and 11 locales, 55 of 682 rows ran past 320 on one line, worst 465, and none does with wrapping (`../README.md` → Will It Fit).
- **The main menu never scrolls; a long flyout does.** The main menu always grows to fit every row, with no mouse-wheel scrolling and no thumb (the maintainer's ruling: no scroll bars on the main menu). A flyout or dropdown list whose rows run past 20 plain rows (`SCROLL_ROWS`, 424 points with its insets) stays that tall and shows whole rows; the mouse wheel moves them 3 at a time, a thin gray thumb in the plate's right margin shows where the view sits, a redraw keeps the place, and the list opens at its top. A sub-menu open off a row closes when its panel scrolls.
- **Margins:** 16 points from the plate's edge to the text on every side, as in Good to Go's Buff Duty window (`EDGE = SPACE.GROUP`). Rows sit 8 in from the plate (`ROW_INSET = SPACE.NEAR`, where a row's highlight starts), text 8 in from its row (`TEXT_INSET = EDGE - ROW_INSET`), and the panel keeps 12 above its first row and below its last (`PANEL_INSET = EDGE - SPACE.LINE`), which a row's own 4 above and below makes 16. Sub-menus overlap by `Kit.FLYOUT_OVERLAP = ROW_INSET` (8), where a row's highlight ends, so they never cover its arrow, and rise `Kit.FLYOUT_RISE = PANEL_INSET` (12); `Kit.FLYOUT_GAP` is 0.
- **Defaults:** `action` is INFO left and VALUE right (what it touches; a kept click or a gesture MUTED). `choice` is VALUE when picked, BODY otherwise, and MUTED for an Off choice. `item` is VALUE right. VALUE and HELP fall back to `FFFF99` and `CCCCCC` when the add-on's `ns.PALETTE` lacks them. The `hint` kind is retired for new menus: it still draws, blue both sides, so GogoLoot's v1 menu runs on v2 until its move.
- **`Kit.MoreFeatures(entries, features)`** appends the More Features `submenu` row and builds its flyout: one compact toggle per set-and-forget feature from the add-on's `ns.FEATURES`, gated and confirmed as its switch is (Features Mirror). The row's right side counts the flyout's switches, `4 On, 3 Off` (On count ON, comma TEXT, Off count MUTED), then the arrow; block features aren't counted.
- **`rightOnHover = true`** on any entry shows its right side only while the row is hovered. The kit still measures it, so the menu never changes width on hover. A click-to-remove list row uses it for its delete icon (Style Guide → MINIMAP MENU → Blocks Beyond Features, Editable list).
- **`afterChange`** is the add-on's `ns.RefreshSettings` in every add-on (One Refresh).
- **Placement** is the kit's (Placement): corner to opposite corner, 2 points apart, by screen halves, flyout and row tooltips on the same side.
- **Any LDB display works.** The anchor is whatever frame called `OnEnter`: the mini-map button, or a Titan Panel or ChocolateBar plugin.
- **Every menu, not only the mini-map's.** `menu:Show(anchor, how, flyoutKey)` takes `how` = `"hover"` or `"click"` (off a button's corner), `"line"` (off a window's line, overlapping it by 8) or `"cursor"` (a right-click menu, at the cursor). Sub-menus go three deep, each on the side the menu opened toward. `Kit.MenuHeader(title)` is a right-click menu's header: the title gold, the add-on's Short Name (`Kit.SetText{ shortName = ... }`) gray. Pass `publish = false` to any menu but the mini-map's: the first menu without it sets `ns.ShowMenu(anchor, flyoutKey, how)`, `ns.HideMenu`, `ns.RefreshMenu` (every open menu redraws), `ns.IsMenuShown`, `ns.IsMenuFrame` and `ns.OpenFlyout(key)`, v1's names, so `ns.RefreshSettings` reaches it.
- **The game's menus in the kit's dress:** `Kit.OpenContextMenu(owner, generator)` opens `MenuUtil.CreateContextMenu` and lays the plate under the menu and each sub-menu made with `Kit.Submenu(description, text)` as it opens, clearing whatever background a skin laid there, and gives it back when the game pools the frame. `Kit.AddMenuHeader(rootDescription, title)` writes the header on it. `Kit.PlatePullout(dropdown)` puts an AceGUI dropdown's list on the plate and gives its border back on release. `Kit.AddPlate(frame)` lays the plate alone under any frame.
- **More entry fields:** `helper = "a sentence"` for a gray line under the row's tooltip, or under an item row's item tooltip: the kit adds a spacer above it, since it opens a new section, then the sentence in HELP, wrapped (Good to Go's Ignore List rows: `Click to take it off your Ignore List.`); `closes = true` for a pick that acts (the menu closes first); `flyout = function` in place of `flyouts[submenu]`, for a sub-menu built on the spot (More Features uses it); `hover = { right, rightColor }` for a hover look measured in both states.
- **Closing:** 0.5 seconds after the cursor leaves the anchor, the menu and its sub-menus; 1.0 seconds when a Left-Click opened it (Style Guide → MENUS → Opening and Closing).
- **`disabled = true`** on any entry: both sides MUTED, no highlight, no click, its tooltip still shown. A gray row with a sub-menu keeps its arrow, drawn MUTED, and opens nothing on hover or click. For a row the game's own menu would gray (PWQL's Share Quest).
- **A gesture on an action row:** `click = "Drag"` (the caller's localized word). A name that isn't a button click is drawn as given, gray on the right, and routes nothing.
- **The arrow** is the kit's own thin white chevron, `Includes/Images/Menu-Arrow.tga` (`Kit.SUBMENU_ARROW`), not the game's solid triangle.
- **Windows** (Style Guide → WINDOWS, MENUS → Window-Menus): `Kit.WindowTitle(title)` returns `Title // Short Name`, white, gray and blue, for every window's title. A window on the plate takes `Kit.AddWindowHeader(frame, title, onClose)` (the title and the game's close button, `Kit.WINDOW_EDGE` in, `Kit.WINDOW_HEADER_HEIGHT` tall; `onClose` replaces the button's click, which would hide a protected parent) and `Kit.AddOptionsLine(frame, label, flyout, afterChange)` (a separator and a blue row in the rows' font with the arrow, `Kit.ROW_HEIGHT` tall; hovering or clicking it opens `flyout()`'s entries on a kit menu as a `"line"` flyout, overlapping the window's edge, not the line's end, by `Kit.FLYOUT_OVERLAP`). Both return their frames for the window to place.
- **Small helpers:** `Kit.Toggle(store, field, name, desc, onChange)`, `Kit.OptionTooltip(name, desc)`, `Kit.OnOff(enabled)`, `Kit.Section(text, right, rightColor)`, `Kit.Separator()`, `Kit.Spacer()`, `Kit.Confirm(text, onYes)` (Yes or No first; the text is never formatted), `Kit.Color(color, text)` and `Kit.RefreshAll()`.

## Distribution

1. The kit and its art live in `addon-kits/Menu-Kit/` here, in folders that mirror an add-on's (`Features/Menu-Kit.lua`, `Includes/Images/Menu-Plate.tga`, `Includes/Images/Menu-Arrow.tga`), as Options-Kit's do.
2. **Already built, for every kit:** `scripts/sync-addon-kits.sh` copies a kit into each add-on that holds any of its files and leaves the rest alone (`--adopt Menu-Kit` the first time), and the reusable `ci.yml`'s **Shared kits match Common-Core** check fails an add-on whose copy differs, plate included. Dropping the kit's files into `addon-kits/Menu-Kit/` is all Menu-Kit needs.
3. **An add-on holding the kit's Lua file has adopted it**, and its next CI run fails until it's synced: Tracking Eye, GogoLoot, Magic Eraser and Good to Go, so each takes `scripts/sync-addon-kits.sh` on its next change. **Art alone doesn't adopt a kit:** the CI check and the sync script key adoption on a kit's `.lua` files, so Play It Forward, which carries only `Includes/Images/Menu-Plate.tga` for its reopen button, is left alone.
4. Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1, copies the kit from `addon-kits/Menu-Kit/` instead of Tracking Eye on GitHub.

## Done When

- [x] `addon-kits/Menu-Kit/` holds the kit, plate and arrow; StyLua, luacheck (under all four add-ons' configs), `luac5.1 -p` and `scripts/test-menu-kit.lua` pass on it.
- [x] The sync script and the CI check are in (`scripts/sync-addon-kits.sh`, built with Options-Kit).
- [x] ~~Tracking Eye runs on v2~~: moved to Tracking Eye's own project ([Gogo1951/Tracking-Eye#31](https://github.com/Gogo1951/Tracking-Eye/issues/31), `Tracking Eye.md`), with nothing visible changed but More Features, which moves into its flyout.
- [x] Style Guide → MINIMAP MENU's live references point at `addon-kits/Menu-Kit/`.
