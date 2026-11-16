# GogoLoot: Options Panels

**State:** live on the kit on GogoLoot's `main`: every panel registers through `Options/Options-Kit.lua`, copied from Common-Core, with `ns.FEATURES` and one refresh. It is the largest options surface, the live reference for Opening the Panel, and the source of the kit's row family (`OptionsRow`, `OptionsSelectRow`, `OptionsSubSelectRow`, `OptionsSubToggleRow`, `OptionsToggleRow` with its measured captions) and its Example renderers. Its item lists keep their filter, add widget, sections by item class and New section, all under README-Notes.
**Live code:** [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/GogoLoot/blob/main/Options/Options-Utilities.lua), [`Options/Options-Utilities-Item-Lists.lua`](https://github.com/Gogo1951/GogoLoot/blob/main/Options/Options-Utilities-Item-Lists.lua), [`Options/Options.lua`](https://github.com/Gogo1951/GogoLoot/blob/main/Options/Options.lua), [`Options/Options-General.lua`](https://github.com/Gogo1951/GogoLoot/blob/main/Options/Options-General.lua).
**Needs first:** `Options-Kit.md` (in Common-Core). Pairs with `Mini-map Menus/GogoLoot.md`.
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.
**Issue:** not filed yet.

## Panel Tree

Unchanged: General; Speedy Loot; Automated Rolls (Item Overrides, Character Rules); Automated Opening (Openables List, Lockboxes); Loot Toasts (Filters); Loot Sounds; Loot Announcements; Automated Master Looting (Ignore List); Roll Macro; Profiles, Feedback & Support, Diagnostic Tools. The Master Looter pop-up stays registered outside the tree.

- `FEATURE_PANELS` and `AddFeaturePanel` stay as the data table, but each row registers through `Kit.RegisterPanel(key, builder, title, parentKey)`. The `ns.OPTIONS_NESTED_PANELS` sibling fallback goes: nesting by category ID works on every flavor GogoLoot ships.
- **Sub-panel titles** read "Automated Rolls > Item Overrides" and so on (Decision 8).

## Root Page

Description, Enable Welcome Message, Enable Mini-map Button, Features, /Commands.

- **Features** draws `Kit.FeatureSwitches(23)`, in the menu's order: its blocks first (Automated Rolls, Automated Opening, Loot Announcements, per the menu spec), then More Features (Speedy Loot, Loot Toasts, Loot Sounds, Automated Master Looting, Roll Macro, in the menu spec's order). Today Speedy Loot leads.
- **Pairs at 1.6, always.** Today every switch is half the row unless any caption measures wider, and then all go full width. The kit's pair rows keep two to a line; a caption too long for 1.6 is the Localization Review's to shorten (Will It Fit, Decision 5).

## Features

`ns.FEATURES` replaces `FEATURE_SWITCHES` and the eight `ns.<X>Switch()` builders. Each builder's body becomes its record's `apply`; its caption and desc keys carry over.

| setting | store | caption today | apply (side effect) |
|---|---|---|---|
| `speedyLoot` | global | `SPEEDY_LOOT_ENABLE` | `EnsureAutoLoot` |
| `autoGreed` | profile | `ROLLS_ENABLE` | update the mini-map icon (now `ns.RefreshSettings`'s job) |
| `autoOpen` | profile | `AUTOMATED_OPENING_ENABLE` | `ScheduleOpeningScan` |
| `lootToasts` | profile | `LOOT_TOASTS_ENABLE` | `SetLootToastsEnabled` |
| `lootSoundsEnabled` | profile | `LOOT_SOUNDS_SWITCH` | — |
| `lootNotifications` | profile | `ANNOUNCEMENTS_ENABLE` | the trade checkbox sync |
| `autoMasterLoot` | profile | `MASTER_LOOTER_AUTO_ENABLE` | the "not master looter" print |
| `rollMacro` | global | `ROLL_MACRO_ENABLE` | `ApplyRollMacro` |

`block` and `click` come from the menu spec. The mini-map tooltip's hand-written toggle functions (`Minimap-Button.lua:91-123`) go: the menu reads these records.

## Panels

- **Feature-off notes** (`ns.AddFeatureOffNote`): the line stays, at the top of each child panel, but turns silver (Decisions 7 and 9). It is `Kit.StatusLine` with the same text. Red is for "nothing will happen", and a child of a switched-off feature is simply idle.
- **Examples:** already indented under their control; they become `Kit.Example` with `Kit.PrintedLine` / `Kit.SentLine`, and **leave while their own toggle is off** (Decision 6). Today they stay "because it is what somebody reads to decide whether to turn that toggle on"; the proposal reads it the other way: the toggle's tooltip says what it does, and the Example shows what your settings will print once it's on.
- **Character Rules:** the class line drops `fontSize = "large"` for a header (Widget Conventions: medium only). The catch-all toggle and Reset to Class Defaults gain `desc` tooltips. The other-gear note moves into the catch-all toggle's tooltip (Helper Text Lives in the Tooltip). Reset to Class Defaults becomes `Kit.ResetRow`, still asking nothing (README-Notes).
- **Loot Toasts:** Reset Position becomes `Kit.ResetRow` with its confirm.
- **Loot Sounds:** the speaker becomes `Kit.SoundPreview` (16 points, today 18, Decision 11).
- **Automated Master Looting:** `AddLabeledRow` (flat, `hidden` on each member) becomes `Kit.LabelRow`.

## Item Lists

`ns:BuildItemListOptions` stays GogoLoot's for now: the add line, filter line, New section and item-class sections are all README-Notes exceptions, and the kit's `Kit.ItemList` is Magic Eraser's shape (Decision 15). Inside it, GogoLoot takes the kit's pieces where they match: `Kit.ITEM_LINK_WIDGET` for the item cell (its own ItemLink widget adds the note under the tooltip, so it stays until the kit's grows a note), `Kit.ParseItem`, `Kit.SortItems` inside each section. It gains `startOrder` and `rowWidth`, so a list can sit in a tree pane.

## Onto the Kit

- Copy `Options/Options-Kit.lua`. `Data/Data.lua`: delete the standard grid, `SUB_LABEL_WIDTH`, `SPEAKER_WIDTH`, `PIXELS_PER_WIDTH_UNIT`, `TREE_ROW_WIDTH`, `TREE_LABEL_WIDTH` (the kit's). The filter and list constants stay.
- `Options-Utilities.lua`: delete the standard helpers and the row family (now the kit's), `MeasureCaptionPixels`, `OptionsToggleWidth`, the Example helpers. Keep `OptionsQualityChoices`.
- `Options.lua`: delete `ns:OpenOptionsPanel` and `ns.optionsFrames` (the kit's), keeping the `SettingsPanel` OnHide hook that forgets New items.
- **One Refresh:** every `set` ends in `ns.RefreshSettings()`; delete the hand `NotifyChange` calls (`Minimap-Button.lua:97-123`, `Options-Announcements.lua:73`, `Loot-Toasts-Handle.lua:257-258`, `Master-Looter.lua:544-545`) and `ns:ApplyProfile`'s registry loop.

## Strings

| Old | New |
|---|---|
| `OPTIONS_EXAMPLE` | `SAMPLE_EXAMPLE` |
| `ITEM_LOADING` ("Loading... (ID: %d)") | `LOADING_ITEM` ("Loading ID: %d") |

The `_TOOLTIP` suffix keys keep their names (no sweep); new keys take `_DESCRIPTION`. Section headers on `TAB_*` keys that aren't panels keep their names too.

## Keeps

README-Notes: Sound toggles carry a speaker; Item lists open with an add line and a filter line; Restore Defaults closes an item list; Openables List rows carry a reason tag; Item lists group rows by item class; Loot Toasts Filters grid; Loot Toasts settings sit at panel level; Reset to Class Defaults asks nothing; Character Rules save per character; Mini-map tooltip reads back Automated Rolls; Locked Items leads the tooltip.

## Check in Game

- [ ] Root Features: blocks first, then More Features, two to a line in German and French.
- [ ] Turn Automated Rolls off: Item Overrides and Character Rules open with a silver line naming it.
- [ ] Untick Print Item on Automated Rolls: its Example leaves.
