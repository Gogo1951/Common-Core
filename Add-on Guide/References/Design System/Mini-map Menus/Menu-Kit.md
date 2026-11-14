# Menu-Kit v2 (Common-Core)

The shared renderer every mini-map menu is built on, moved into Common-Core so all six add-ons copy one file. **Do this first:** every add-on spec in this folder builds on it.

- **Issue:** [Gogo1951/Common-Core#3](https://github.com/Gogo1951/Common-Core/issues/3).
- **Rules:** Style Guide → MINIMAP MENU.
- **Pieces:** `../README.md` → Components, Patterns, Proposed Kit Changes.
- **Drawn:** `../Mini-map Menus.html`.
- **Starts from:** Tracking Eye's `Features/Menu-Kit.lua` and the generic half of its `Features/Minimap-Menu.lua`.

## What Moves Where

| Today, in Tracking Eye | v2 |
|---|---|
| `Features/Menu-Kit.lua`: plate, rows, layout | `addon-kits/Menu-Kit/Menu-Kit.lua` here, unchanged in spirit |
| `Includes/Images/Menu-Plate.tga` | `addon-kits/Menu-Kit/Menu-Plate.tga` here |
| `Minimap-Menu.lua`: `CreatePanel` for menu and flyout, `UISpecialFrames`, `PositionMenu`, `PositionFlyout`, the `OnUpdate` close timer, `OnHide`, `RenderFlyout`, `ns.ShowMenu`, `ns.HideMenu`, `ns.RefreshMenu`, `ns.IsMenuShown`, `ns.IsMenuFrame`, `ns.OpenFlyout`, `menu.onEnterRow` | Into the kit, behind `Kit.CreateMenu` |
| `Minimap-Menu.lua`: `AddFeature` | Into the kit as `Kit.FeatureBlock` |
| `Minimap-Menu.lua`: `OptionTooltip`, `Toggle`, `Section`, `Separator`, `OnOff` | Into the kit as small helpers |
| `Minimap-Menu.lua`: tracking rows, flyouts, the Blizzard tracking-button hook | Stays in Tracking Eye |

## API

```lua
local Kit = ns.MenuKit

-- Once at load, every string the add-on localizes.
Kit.SetText({
	on = L["MENU_ON"], off = L["MENU_OFF"], toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"], -- "%d more"
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
	afterChange = function() ns.RefreshOptionsPanels() end, -- every row click and button click ends here
})

-- The LDB object hands the kit its events; the kit routes clicks through the click table.
OnEnter = function(self) menu:Show(self, "hover") end,
OnLeave = function() end,
OnClick = function(self, button) menu:HandleClick(self, button) end,
```

- **`Kit.FeatureBlock(entries, { key, title, state, stateColor, description, note, rows, toggle, after })`**, where `toggle = { name, desc, flip, click }` and `click` is a click key (`"ShiftLeftButton"`) or nil.
- **Action entries** carry `click = "RightButton"` (or nil). The kit draws that click's name on the row's right in MUTED. `menu:HandleClick` finds the entry whose `click` matches, across the main entries only, and runs its `onClick`. With no match, a Left-Click opens and holds the menu, and anything else does nothing. Shift + Middle-Click with no match opens `ns:OpenOptionsPanel()`, so every add-on gets it for free.
- **The Options row** is `Kit.OptionsRow(L["MENU_OPTIONS"])`: spacer, separator, and an action row naming Shift + Middle-Click.
- **Two new kinds:**
  - `item`: `{ kind = "item", itemID or link, count, right, rightColor, onClick }`. The kit draws the icon at line height and the name in its quality color without brackets, adds the count, and shows the item's tooltip on hover. An uncached item draws `Loading ID: %d` in MUTED and redraws when it arrives.
  - `value`: `{ kind = "value", left, right }`. BODY left, TEXT right, nothing to click.
- **`Kit.List(entries, rows, max)`** appends up to `max` (8) rows, then a `note` saying how many more.
- **Colors** take a palette key or a six-digit hex (class colors, quality colors).
- **`MAX_WIDTH = 320`** for the menu and every flyout. The left text of every row wraps within what's left after its right side and the 16-point gap, and the row grows to the wrapped height; the right side never wraps and stays level with the first line. Measured across all six add-ons and 11 locales, 55 of 682 rows ran past 320 on one line, worst 465, and none does with wrapping (`../README.md` → Will It Fit).
- **Defaults:** `action` is INFO left and MUTED right. The `hint` kind goes; nothing uses it once the Options row is an action row.
- **`Kit.MoreFeatures(entries, features)`** appends the gold More Features heading and one compact toggle per set-and-forget feature from the add-on's `ns.FEATURES`, gated and confirmed as its switch is (Features Mirror).
- **`afterChange`** is the add-on's `ns.RefreshSettings` in every add-on (One Refresh).
- **Placement** is the kit's (Placement): corner to opposite corner, 2 points apart, by screen halves, flyout and row tooltips on the same side.
- **Any LDB display works.** The anchor is whatever frame called `OnEnter`: the mini-map button, or a Titan Panel or ChocolateBar plugin.

## Distribution

1. The kit and plate live in `addon-kits/Menu-Kit/` here.
2. `scripts/sync-addon-files.sh` copies them into each add-on that has `Features/Menu-Kit.lua` (`Features/` and `Includes/Images/`), and leaves add-ons without one alone.
3. `ci.yml` gains a check: an add-on that has `Features/Menu-Kit.lua` must match `addon-kits/Menu-Kit/Menu-Kit.lua` byte for byte, plate included, like the shared-files check.
4. The Style Guide's "copy it from Tracking Eye" becomes "copy it from Common-Core".

## Done When

- [ ] `addon-kits/Menu-Kit/` holds the kit and plate; StyLua, luacheck and `luac5.1 -p` pass on it.
- [ ] The sync script and the CI check are in, and CI passes on Common-Core.
- [ ] Tracking Eye runs on v2 with nothing visible changed except its restored clicks (`Tracking Eye.md`). That's the proof.
- [ ] Style Guide → MINIMAP MENU's live references point at `addon-kits/Menu-Kit/`.
