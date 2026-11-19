# Menu-Kit v2 (Common-Core)

The shared renderer every mini-map menu is built on, moved into Common-Core so all six add-ons copy one file. **The maintainer's work, in a session launched in `~/Common-Core`:** it lands before the add-ons move onto v2. A session in an add-on folder never builds or edits it; until it lands, every conversion copies Tracking Eye's kit from GitHub (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu).

- **Issue:** [Gogo1951/Common-Core#3](https://github.com/Gogo1951/Common-Core/issues/3), open until `addon-kits/Menu-Kit/` holds the kit. It was closed on 2026-11-14 with no PR and nothing landed; reopened 2026-11-19.
- **Where the kit is today:** v1, byte for byte the same `Features/Menu-Kit.lua` and `Includes/Images/Menu-Plate.tga` on `main` in Tracking Eye, GogoLoot and Magic Eraser. Tracking Eye's is the one a change goes to (Style Guide → MINIMAP MENU, Never edit a copy). **Good to Go's copy is ahead:** it adds what Style Guide → MENUS asks of every menu, working in game, and v2 takes it in: `Kit.FLYOUT_OVERLAP` (a flyout 12 points inside its menu, replacing `FLYOUT_GAP`'s 16-point gap), an entry's `submenu` on any row with the arrow in its own column, `Kit.AddPlate` (the plate alone, for a window), `Kit.OpenContextMenu` and `Kit.AddMenuHeader` (the game's `MenuUtil` menus in the kit's dress, a skin's backdrop cleared) and `Kit.PlatePullout` (an AceGUI dropdown's list on the plate).
- **Rules:** Style Guide → MINIMAP MENU.
- **Pieces:** `../README.md` → Components, Patterns, Kit Changes (Menu-Kit v2).
- **Drawn:** `../Mini-map Menus.html`.
- **The look comes from:** Pretty Wide Quest Log's Quest Arrow menu, [`Features/Routes/Routes-Arrow-Menu-Panel.lua`](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Features/Routes/Routes-Arrow-Menu-Panel.lua). v1 was cut from it (the same plate, nine-slice, insets, gold highlight and spacing; its `Route-Menu.tga` is byte for byte `Menu-Plate.tga`), and it has since grown four things v2 asks for, already working in game: a row's `hover` look, measured in both states so the width never moves (`rightOnHover`); an `itemID` row that shows the item's tooltip on hover (`item`); a color given as `{ r, g, b }` as well as a palette key (raw colors); and `Fill`, which lays a panel out again only when what its rows say changes, with the flyout's label keeping its highlight while the flyout is open. Read it before writing those pieces. It stays PWQL's own file: the Quest Arrow and world-map menus aren't mini-map menus.
- **Starts from:** Tracking Eye's [`Features/Menu-Kit.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Menu-Kit.lua) and the generic half of its [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua), on GitHub `main`. Magic Eraser's [`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Menu.lua) builds the same flyout by hand (copy the flyout block from either), plus the More Features flyout and count and the hover-only right side (`ApplyHoverIcons`).

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

- **`Kit.FeatureBlock(entries, { key, title, state, stateColor, description, note, rows, toggle, after })`**, where `toggle = { name, desc, flip, click }` and `click` is a click key (`"ShiftLeftButton"`) or nil.
- **Action entries** carry `click = "RightButton"` (or nil). The kit draws that click's name on the row's right in MUTED. `menu:HandleClick` finds the entry whose `click` matches, across the main entries only, and runs its `onClick`. With no match, the kit runs the add-on's `fallback[button]` when it gave one (Magic Eraser's Left-Click erases even while its Erase row is hidden); otherwise a Left-Click opens and holds the menu, and anything else does nothing. Shift + Middle-Click with no match opens `ns:OpenOptionsPanel()`, so every add-on gets it for free.
- **The Options row** is `Kit.OptionsRow(L["MENU_OPTIONS"])`: spacer, separator, and an action row naming Shift + Middle-Click.
- **Two new kinds:**
  - `item`: `{ kind = "item", itemID or link, count, right, rightColor, onClick }`. The kit draws the icon at line height and the name in its quality color without brackets, adds the count, and shows the item's tooltip on hover. An uncached item draws `Loading ID: %d` in MUTED and redraws when it arrives.
  - `value`: `{ kind = "value", left, right }`. BODY left, TEXT right, nothing to click.
- **`Kit.List(entries, rows, max)`** appends up to `max` (8) rows, then a `note` saying how many more.
- **Colors** take a palette key or a six-digit hex (class colors, quality colors).
- **`MAX_WIDTH = 320`** for the menu and every flyout. The left text of every row wraps within what's left after its right side and the 16-point gap, and the row grows to the wrapped height; the right side never wraps and stays level with the first line. Measured across all six add-ons and 11 locales, 55 of 682 rows ran past 320 on one line, worst 465, and none does with wrapping (`../README.md` → Will It Fit).
- **Defaults:** `action` is INFO left and MUTED right. The `hint` kind goes; nothing uses it once the Options row is an action row.
- **`Kit.MoreFeatures(entries, features)`** appends the More Features `submenu` row and builds its flyout: one compact toggle per set-and-forget feature from the add-on's `ns.FEATURES`, gated and confirmed as its switch is (Features Mirror). The row's right side counts the flyout's switches, `4 On, 3 Off` (On count ON, comma TEXT, Off count MUTED), then the arrow; block features aren't counted.
- **`rightOnHover = true`** on any entry shows its right side only while the row is hovered. The kit still measures it, so the menu never changes width on hover. A click-to-remove list row uses it for its delete icon (Style Guide → MINIMAP MENU → Blocks Beyond Features, Editable list).
- **`afterChange`** is the add-on's `ns.RefreshSettings` in every add-on (One Refresh).
- **Placement** is the kit's (Placement): corner to opposite corner, 2 points apart, by screen halves, flyout and row tooltips on the same side.
- **Any LDB display works.** The anchor is whatever frame called `OnEnter`: the mini-map button, or a Titan Panel or ChocolateBar plugin.
- **Every menu, not only the mini-map's.** `Kit.CreateMenu` also opens a menu or flyout off any frame, with the header naming what was clicked and the anchoring and closing of Style Guide → MENUS. Good to Go's `Kit.OpenContextMenu`, `Kit.AddMenuHeader` and `Kit.PlatePullout` come across unchanged in what they draw, so a right-click menu on the game's menus and a dropdown's list keep looking like the kit's panels.

## Distribution

1. The kit and plate live in `addon-kits/Menu-Kit/` here, in folders that mirror an add-on's (`Features/Menu-Kit.lua`, `Includes/Images/Menu-Plate.tga`), as Options-Kit's do.
2. **Already built, for every kit:** `scripts/sync-addon-kits.sh` copies a kit into each add-on that holds any of its files and leaves the rest alone (`--adopt Menu-Kit` the first time), and the reusable `ci.yml`'s **Shared kits match Common-Core** check fails an add-on whose copy differs, plate included. Dropping the two files into `addon-kits/Menu-Kit/` is all Menu-Kit needs.
3. **Every add-on holding either file counts as adopted the moment the kit lands,** and its next CI run fails until it's synced: Tracking Eye, GogoLoot, Magic Eraser and Good to Go carry both files, so land the kit and their moves together. **Play It Forward carries only `Includes/Images/Menu-Plate.tga`** (its reopen button's plate, `Features/UI-Reopen-Button.lua`), with no kit: as the check works today it would fail for a missing `Features/Menu-Kit.lua`. Before landing, either key adoption on `Features/Menu-Kit.lua` alone, or rename Play It Forward's plate.
4. Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1, copies the kit from `addon-kits/Menu-Kit/` instead of Tracking Eye on GitHub.

## Done When

- [ ] `addon-kits/Menu-Kit/` holds the kit and plate; StyLua, luacheck and `luac5.1 -p` pass on it.
- [x] The sync script and the CI check are in (`scripts/sync-addon-kits.sh`, built with Options-Kit).
- [ ] Tracking Eye runs on v2 with nothing visible changed but More Features, which moves into its flyout (`Tracking Eye.md`). That's the proof.
- [ ] Style Guide → MINIMAP MENU's live references point at `addon-kits/Menu-Kit/`.
