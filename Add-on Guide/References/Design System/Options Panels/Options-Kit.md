# Options-Kit (Common-Core)

The shared pieces every options panel is built from, in one file every add-on copies unchanged. **It is already in Common-Core:** `addon-kits/Options-Kit/Options/Options-Kit.lua`, with its sync script and CI check. Every add-on spec in this folder builds on it.

- **Rules:** Style Guide → OPTIONS PANEL, and Build Reference → OPTIONS PANEL.
- **Pieces:** `../README.md` → Wave 2: Options Panels (Components, Patterns, Decisions).
- **Drawn:** `../Options Panels.html`.
- **Built from:** GogoLoot's row helpers (`Options/Options-Utilities.lua`), Tracking Eye's feature switches and registration (`Options/Options-Utilities.lua`, `Options/Options.lua`), Magic Eraser's item list, status line and ItemLink widget (`Options/Options-Utilities.lua`), Thanks for the Buff's `HideAllExcept`, Control Freak's and Pretty Wide Quest Log's Example renderers, Good to Go's item check, and Pretty Wide Quest Log's tooltip on a caption.
- **Smoke test:** `lua5.1 scripts/test-options-kit.lua` from Common-Core (stubs the game and Ace APIs, builds every piece, checks its shape).

## Why a Kit

Nine add-ons each carry their own `Options/Options-Utilities.lua`, and they have drifted apart. The surveys behind this wave found:

| Piece | How many shapes today |
|---|---|
| Sub-option row | 4: list form (Magic Eraser, Good to Go), list form with an order-0 indent (GogoLoot), keyed map (Pretty Wide Quest Log), file-local copies (Tracking Eye, Play It Forward, Thanks for the Buff) |
| Example line | 5: `(getText, order, hidden)` (Magic Eraser), `(order, lineFn, hidden)` (Good to Go), `RenderSample` (Control Freak, Pretty Wide Quest Log), `OptionsExampleRow` (GogoLoot), `OptionsExample(text, order, hidden, width)` (Water Dispenser); two label keys (`OPTIONS_EXAMPLE`, `SAMPLE_EXAMPLE`) |
| Feature switch | 6 names: `OptionsFeatureSwitch`, `OptionsFeatureToggle` (two signatures), `FeatureEnableToggle`, `ns.<X>Switch()`, `OptionsProfileToggle`, a local `FeatureToggle` |
| Toggles two to a line | 4: `OptionsTogglePairs` (three signatures), `OptionsFeatureSwitchRows`, and flat 1.7 with no pair rows (Water Dispenser, Pretty Wide Quest Log, Play It Forward) |
| Item list | 3 builders: Magic Eraser's (colon, Restore, tags, select column), Good to Go's (dot, existence check, no Restore), GogoLoot's (filter, add widget, sections) |
| `ns.RefreshSettings` | 1 of 9 add-ons (Tracking Eye). The rest notify single panels by hand or not at all. |
| `ns.FEATURES` | 1 of 9 (Tracking Eye). Five other tables with other names and fields. |
| Tree sidebar | 176 (Good to Go, Thanks for the Buff) and 180 (Magic Eraser, Play It Forward) points |
| Sound preview | 16 points (Thanks for the Buff, Good to Go) and 18 (Control Freak, GogoLoot) |

One copy ends the drift the way `addon-files/` did for workflows: a fix lands once, CI keeps every copy identical, and a pass reads one API instead of nine.

## What Moves Where

| Today, in each add-on | With the kit |
|---|---|
| `Data/Data.lua`: `ns.OPTIONS_ROW_WIDTH` … `ns.OPTIONS_TREE_*` | The kit's grid, published under the same `ns.OPTIONS_*` names. Delete the Data lines. |
| `Options/Options-Utilities.lua`: `OptionsHeader`, `OptionsDesc`, `OptionsSpacer`, `OptionsRowLabel`, `OptionsSubLabel`, `OptionsSubRow`, `OptionsRow`, `OptionsSelectRow`, `OptionsSubSelectRow`, `OptionsSubToggleRow`, `OptionsToggleRow`, `OptionsTogglePairs`, `OptionsStatusLine`, `OptionsExample*`, `DefineSoundPreview`, `HideAllExcept`, `SubPanelTitle` | `Kit.*` (API, below). Delete the add-on's copies. |
| `ns.FEATURES` or its stand-in (`FEATURE_SWITCHES`, `FEATURE_TOGGLES`, `FEATURES`, `FEATURE_GROUPS`) and its switch builder | `ns.FEATURES` in `Options/Options-Utilities.lua`, in the kit's record shape; `Kit.FeatureSwitch` and `Kit.FeatureSwitches` draw it |
| `ns:BuildItemListOptions`, `WarmItemCache`, `ParseItemInput`, `SortItemIdentifiersByName`, `GetItemDisplayName`, the ItemLink widget | `Kit.ItemList`, `Kit.WarmItems`, `Kit.ParseItem`, `Kit.SortItems`, `Kit.ItemName`, `Kit.ITEM_LINK_WIDGET` |
| `ns.RefreshSettings` (Tracking Eye's `Features/Utilities.lua`), `NotifyAllPanels`, per-panel `Refresh()` | The kit's `ns.RefreshSettings`. Delete the add-on's. |
| `Options/Options.lua`: `Register`, `RegisterChild`, `AddSubPanel`, `AddFeaturePanel`, `AddPanel`, `PrepareListTree`, `ns:OpenOptionsPanel`, `ns.IsOptionsPanelOpen`, `ns.optionsFrames` | `Kit.RegisterPanel`, `Kit.PrepareTree`, and the kit's `ns:OpenOptionsPanel(key)` and `ns.IsOptionsPanelOpen()`. `ns.RegisterOptionsPanels` stays, as a list of `Kit.RegisterPanel` calls. |
| What only this add-on has: its alert section builder, emote grid, whisper composer, mail editor, filter grid, font section | Stays in the add-on, built from kit pieces |

## Load Order

`Options/Options-Kit.lua` is the first file in the TOC's Options group, before `Options/Options-Utilities.lua`. It runs at file scope (it only defines functions, the grid and one AceGUI widget type) and reads `ns.db` only when a panel draws.

## API

```lua
local Kit = ns.OptionsKit

-- Once at load, in Options/Options-Utilities.lua: every string the kit draws.
Kit.SetText({
	example = L["SAMPLE_EXAMPLE"], -- "Example: %s"
	loading = L["LOADING_ITEM"], -- "Loading ID: %d"
	soundPreview = L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"],
	inCombat = L["CHAT_OPTIONS_IN_COMBAT"],
	reset = L["OPTIONS_RESET"],
})
```

### The Grid

| `Kit.` | `ns.` | Value | |
|---|---|---|---|
| `ROW_WIDTH` | `OPTIONS_ROW_WIDTH` | 3.4 | Every row totals this (578 points) |
| `LABEL_WIDTH` | `OPTIONS_LABEL_WIDTH` | 2.1 | A caption beside its control |
| `CONTROL_WIDTH` | `OPTIONS_CONTROL_WIDTH` | 1.3 | Every dropdown, slider and box |
| `SUB_INDENT_WIDTH` | `OPTIONS_SUB_INDENT_WIDTH` | 0.115 | A sub-row's lead cell |
| `SUB_LABEL_WIDTH` | `OPTIONS_SUB_LABEL_WIDTH` | 1.985 | A sub-row caption, paying for its indent, so its control keeps the column |
| `PAIR_WIDTH` | — | 1.6 | Two to a line, with 0.2 of slack so the second never wraps |
| `REMOVE_ICON_WIDTH` | `OPTIONS_REMOVE_ICON_WIDTH` | 0.25 | A list row's remove icon |
| `TAG_WIDTH` | — | 0.55 | A list row's silver tag |
| `SPEAKER_WIDTH` | — | 0.15 | A sound preview, past the row's end |
| `TREE_PIXELS` | `OPTIONS_TREE_WIDTH` | 176 | A tree's sidebar, in points |
| `TREE_ROW_WIDTH` | `OPTIONS_TREE_ROW_WIDTH` | 2.5 | A tree pane's row |
| `TREE_LABEL_WIDTH`, `TREE_CONTROL_WIDTH` | — | 1.2, 1.3 | A tree pane's caption and control; the control matches the panel's column |

Widths are AceConfig units (170 points each), so they sit outside the Spacing Scale by its own exception. The 0.2 of pair slack and the sub-label's −0.115 are the only derived values; everything else is the table.

### Text and Rows

| Call | Returns | Use |
|---|---|---|
| `Kit.Header(text, order, hidden)` | header | A section's gold heading |
| `Kit.Desc(text, order, hidden)` | description | A section's or page's text, `fontSize = "medium"` |
| `Kit.Spacer(order, hidden)` | description | One blank line |
| `Kit.Section(args, keyPrefix, order, title, description, hidden)` | next order | Spacer, header, spacer, then the description and a spacer when given |
| `Kit.Label(text, order, width, desc)` | description | A caption cell; with `desc`, the stock InteractiveLabel, so hovering the caption shows the tooltip |
| `Kit.SubLabel(text)` | string | Silver caption text |
| `Kit.Row(order, hidden, cells)` | inline group | Cells left to right on one pinned line |
| `Kit.SubRow(order, hidden, cells)` | inline group | The same, indented: a sub-option |
| `Kit.LabelRow(order, hidden, caption, control, desc)` | inline group | A caption beside its dropdown, slider or box |
| `Kit.SubLabelRow(order, hidden, caption, control, desc)` | inline group | The same under the control it belongs to |
| `Kit.SubToggleRow(order, hidden, toggle)` | inline group | An on/off choice under the control it belongs to |
| `Kit.Pairs(order, hidden, toggles)` | inline group | Toggles two to a line |
| `Kit.ToggleRow(order, toggle, { control, preview, hidden })` | inline group | A switch with its one setting beside it and a sound's speaker past the end; both leave while it's off; a caption too long for the label column (measured) sends them to the line below |
| `Kit.SoundPreview(play)` | execute | The speaker for `ToggleRow` |
| `Kit.HideAllExcept(args, isHidden, keep)` | — | Hides a page behind its switch, keeping the named args, composed with each arg's own `hidden` |
| `Kit.Color(key, text)`, `Kit.Tint(key, text)` | string | Palette key or hex; `Tint` reopens the color after every `\|r` |

### Settings

| Call | Returns | |
|---|---|---|
| `Kit.Get(store, path)` | `get` | `Kit.Get("profile", "dispense.party")`: looked up on every read, so a profile switch never leaves a stale table |
| `Kit.Set(store, path, onSet)` | `set` | Writes, runs `onSet(value)` for side effects, then `ns.RefreshSettings()` |
| `Kit.GetChoice(store, path, values, default)` | `get` | A dropdown's `get` that reads `default` when the saved value isn't a choice any more, so it never draws blank |
| `ns.RefreshSettings()` | — | Repaints every panel in `ns.OPTIONS_REGISTRY`, then `ns.RefreshMenu()` and `ns.UpdateMinimapIcon()` where they exist |

### Features

`ns.FEATURES`, in `Options/Options-Utilities.lua`, in menu order (blocks first, then More Features):

```lua
ns.FEATURES = {
	{
		store = "profile", setting = "autoVendEnabled", -- ns.db[store][setting]
		name = "TAB_AUTO_VEND", -- the feature's name: menu title, panel name
		caption = "OPTIONS_ENABLE_AUTO_VEND", desc = "OPTIONS_ENABLE_AUTO_VEND_DESCRIPTION",
		block = true, -- flipped mid-session: a menu block, not a More Features row
		apply = function(value) ns.SetAutoVend(value) end, -- optional; default writes the value
		confirm = "OPTIONS_AUTO_VEND_CONFIRM_OFF", -- optional; asked before switching off
		click = "ShiftRightButton", -- optional; the button click its Toggle row names
		gate = function() return true end, -- optional; menu only: can this character use it
		opensOptions = "AutoVend", -- optional; its More Features row opens this panel
	},
}
```

- `Kit.FeatureSwitch(setting, order, width)`: the feature's Enable switch. The root panel's Features section and the feature's own panel both draw this one, so they share caption, tooltip, confirm and setter.
- `Kit.FeatureSwitches(order)`: the root panel's Features switches, two to a line, in `ns.FEATURES` order.
- Menu-Kit v2's `Kit.MoreFeatures` and `Kit.FeatureBlock` read the same records.

### Lines

| Call | Draws | When |
|---|---|---|
| `Kit.StatusLine(getText, order)` | Silver | Only while `getText()` returns text: something elsewhere changes what this page does |
| `Kit.WarningLine(text, isWrong, order)` | Red | Only while `isWrong()`: the settings mean nothing will happen |
| `Kit.Example(order, hidden, getLine)` | Silver `Example:`, then the line in its own colors, indented under its control | Whenever its control's row shows |
| `Kit.PrintedLine(printLine)` | A print, retinted after each link | Pass the add-on's print helper's finished string |
| `Kit.SentLine("PARTY" or "WHISPER", message)` | `[Party] [You]: …` or `[You] whispers: …` in the player's channel color, markers as icons | |
| `Kit.You()`, `Kit.ClassColor(classFile)`, `Kit.Markers(text)` | The current character in class color; a class's hex; `{rtN}` as icons | |

### Reset

`Kit.ResetRow(order, hidden, caption, desc, isDefault, reset, confirmText)`: the caption in the label column, a Reset button in the control column, gray while `isDefault()` says there's nothing to reset, confirmed when `confirmText` is given (more than one value). Every player-editable text input carries one; anything else only on request (Style Guide → SAVED VARIABLES → Reset).

### Items

| Call | |
|---|---|
| `Kit.ItemList(spec)` | Args for a player-managed list: Add from Bags, Add Item, a row per item sorted by name (ItemLink cell, optional tag, optional action column, remove icon), then Restore Defaults and Clear List at the foot. Spec fields are in the kit's comment above it. |
| `Kit.ParseItem(text)` | A bare ID or an item link, refusing words and IDs the client doesn't have |
| `Kit.ItemName(itemId)` | Icon and unbracketed colored link, or gray `Loading ID: %d` |
| `Kit.SortItems(itemIds)` | By name, uncached last, ties by ID |
| `Kit.WarmItems(itemIds, registryName)` | Requests cold items and repaints that panel as they land, bounded |
| `Kit.ITEM_LINK_WIDGET` | `ADDON_NAME .. "_ItemLink"`, the AceGUI type for an item cell (`dialogControl`) |

### Panels

```lua
-- Options/Options.lua
function ns.RegisterOptionsPanels()
	Kit.RegisterPanel("General", ns.BuildGeneralOptions, L["ADDON_TITLE"])
	Kit.RegisterPanel("AutoVend", ns.BuildAutoVendOptions, L["TAB_AUTO_VEND"])
	Kit.RegisterPanel("EraseList", ns.BuildEraseListOptions, L["TAB_ERASE_LIST"], "Erasing")
	-- Profiles, Feedback & Support, Diagnostic Tools last, in that order.
	Kit.PrepareTree("EraseList", function() return ns.db.keys.char end)
end
```

- `Kit.RegisterPanel(key, builder, displayName, parentKey)`: registers the builder function (so every repaint rebuilds it) under `ns.OPTIONS_REGISTRY[key]`, adds it to the tree under the root, or under `parentKey`'s captured category ID, and keeps its frame and category ID.
- `ns:OpenOptionsPanel(key)`: the Combat Guard first, then `Settings.OpenToCategory` with the captured ID of that panel, or the root.
- `ns.IsOptionsPanelOpen()`: whether any of the add-on's panels is on screen, read live.
- `Kit.SubPanelTitle(parentName, name)`: `"Farm Mode > Abilities"`, a sub-panel's page title.
- `Kit.PrepareTree(key, home)`: a tree's 176-point sidebar, opening on `home()` every time.

## Strings

The kit reads five strings, one name in every add-on. An add-on renames its existing key to the standard name in `enUS.lua` only, and its prompt lists each old → new key; the Localization Review carries every locale across.

| Key | enUS | Renamed from |
|---|---|---|
| `SAMPLE_EXAMPLE` | `Example: %s` | `OPTIONS_EXAMPLE` (Magic Eraser, GogoLoot) |
| `LOADING_ITEM` | `Loading ID: %d` | `SAMPLE_LOADING_ITEM` (Tracking Eye), `ITEM_LOADING` (GogoLoot) |
| `OPTIONS_SOUND_PREVIEW_DESCRIPTION` | `Play this sound now, whether or not the sound is turned on.` (Control Freak's) | `ALERT_SOUND_PREVIEW_DESC` (Control Freak), `NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION` (Thanks for the Buff), `OPTIONS_RESTOCKER_SOUND_PREVIEW` (Good to Go), `ZONE_SHARE_SOUND_PREVIEW` (Pretty Wide Quest Log); the one wording replaces theirs |
| `OPTIONS_RESET` | `Reset` | new; Control Freak reads the GlobalString `RESET` |
| `CHAT_OPTIONS_IN_COMBAT` | Mandated copy (Combat Guard) | already standard |

## Distribution

1. The kit lives in `addon-kits/Options-Kit/`, whose folders mirror an add-on's: `Options/Options-Kit.lua`.
2. `scripts/sync-addon-kits.sh --adopt Options-Kit ../Add-on` copies it in the first time; a plain `scripts/sync-addon-kits.sh ../Add-on` refreshes every kit an add-on has adopted.
3. The reusable `ci.yml` checks **Shared kits match Common-Core**: an add-on holding any of a kit's files must match all of them byte for byte. Add-ons that haven't adopted a kit are untouched.
4. A change to the kit is a Common-Core commit, then a sync into each add-on. Never edit an add-on's copy.

## Done When

- [x] `addon-kits/Options-Kit/` holds the kit; luac 5.1, luacheck (bare config) and StyLua 2.5.2 pass on it; the smoke test passes.
- [x] The sync script and the CI check are in.
- [ ] Magic Eraser runs on it with nothing visible changed except what its spec says. That's the proof (`Magic Eraser.md`).
- [ ] Style Guide → OPTIONS PANEL's live references point at `addon-kits/Options-Kit/` for every piece the kit owns.

## Check in Game

On Classic Era, TBC Anniversary and Mainline (or the flavors the add-on ships):

- [ ] Every panel opens from the tree and from `ns:OpenOptionsPanel(key)`, docked, never as a floating window; in combat the slash command prints the refusal.
- [ ] A switch flipped on a feature panel shows on the root panel's Features section at once, and in the mini-map menu where there is one; the same after a profile switch.
- [ ] A `ToggleRow` in German and French: a caption that fits shares its line; one that doesn't sends its setting to the line below, still in the column.
- [ ] An item list on a fresh login: rows read Loading, then fill in without a click.
- [ ] Every Example redraws when the dropdown it follows changes.
