# GOGO DESIGN SYSTEM

The pieces every Gogo add-on's interface is built from, named and drawn, so a menu, a panel or a window in one add-on looks and behaves like its neighbor in another. **The Style Guide holds the rules; this folder holds the pieces they describe.** Where the two disagree, the Style Guide wins until a triage reconciles them, and the disagreement is a Guide Feedback finding.

It grows in waves, one surface at a time:

| Wave | Surface | State |
|---|---|---|
| 1 | Mini-map menus | **This folder.** Six add-ons drawn and specced, decisions made, issues filed. |
| 2 | Options panels | **This folder** (Wave 2: Options Panels, below). Nine add-ons surveyed, drawn and specced; Options-Kit built in `addon-kits/Options-Kit/`; decisions made; issues not filed yet. |
| 3 | The add-ons' own windows | The title decided (Style Guide → WINDOWS); the rest later. |
| 4 | Lines added to the game's tooltips | **`Tooltips/`.** Surveyed across nine add-ons; rules in Style Guide → TOOLTIPS; Tooltip-Kit built in `addon-kits/Tooltip-Kit/`. |
| 5 | Chat prints and sent messages | **`Chat Lines/`.** Surveyed across nine add-ons; rules in Style Guide → MESSAGES; Chat-Kit built in `addon-kits/Chat-Kit/`. |

## Files

| File | What it is |
|---|---|
| `README.md` | This: foundations, components, patterns, decisions, and the order of work. Wave 1's sit under the top-level headings; Wave 2's under Wave 2: Options Panels. |
| `Options Panels/` | `Options-Kit.md`, the kit's spec, and one spec per add-on: its panel tree, root page, `ns.FEATURES`, each panel's changes, its move onto the kit, its strings, and how to check it in game. |
| `Options Panels.html` | The board: every add-on's Settings tree and pages drawn from its code, Today beside Proposed, clickable, with the kit's components and the decisions. Open it next to all four mock files. |
| `options-mock.css`, `options-mock.js` | The options mock kit. Draws AceConfig tables in the Blizzard Settings window at the game's sizes, and `GO.kit` mirrors Options-Kit's helpers. Loads after `menu-mock.css` and `menu-mock.js` (Wave 2 → Using the Options Mock Kit). |
| `Mini-map Menus/` | One spec per add-on: its tooltip today, its menu row by row, its clicks, its strings, and how to check it in game. |
| `Mini-map Menus.html` | The board: every mini-map tooltip drawn from its code beside the menu it becomes, clickable, with scenario switches. Open it in a browser next to `menu-mock.css` and `menu-mock.js`. |
| `menu-mock.css`, `menu-mock.js` | The mock kit. Draws Menu-Kit entries and old-style GameTooltip lines at the game's sizes. Any wireframe pass that draws a mini-map menu builds from these instead of redrawing one (Using the Mock Kit, below). |
| `Chat Lines/` | `Chat-Kit.md`, the chat kit's spec: every call, what it replaces in each add-on, and how to check it in game. |
| `Tooltips/` | `Tooltip-Kit.md`, the tooltip kit's spec: the hooks, the block shapes, what each add-on's block becomes, and how to check it in game. |
| `Chat Lines.html` | Every chat line the Style Guide defines, in a mock chat box in its exact colors and format: prints, the welcome message, the combat refusal, sent lines, a whisper and Example lines, each naming its rule. Open it next to `menu-mock.css`. |
| `Windows and Tooltips.html` | An add-on's own window and the lines it adds to a game tooltip, drawn from the Style Guide's rules, with standard WoW behavior marked Proposed default where it has none yet. Drawn before WINDOWS and TOOLTIPS were decided: where its window title or tooltip header differs, the Style Guide wins. Open it next to `menu-mock.css` and `menu-mock.js`. |
| `Wireframe Starter.html` | The page the UX Review copies and fills in for its wireframe: tabs per window, Current beside Proposed, each change a multiple-choice card whose options show their own example on hover or click, a Try first switch, `FILL` slots marked. Self-contained. |

## Foundations

### Color

The roles are `ns.PALETTE` (Style Guide → COLORS). In a menu:

| Role | Hex | Menu use |
|---|---|---|
| TITLE | `FFD100` | Every heading: the header, feature titles, sections. The row highlight, at 16%. |
| INFO | `00BBFF` | Everything you click that isn't a setting: Toggle, Open, Erase, Clear, the Options row. |
| BODY | `FFFFFF` | Descriptions, setting names, read-out labels, choices not picked. |
| TEXT | `FFFFFF` | A toggle that's on; the comma in More Features' count. |
| VALUE | `FFFF99` | What a setting is set to: the value beside a picker's arrow, the picked choice inside it, counts, numbers and read-backs. |
| ON | `33CC33` | On, Active, and a success line. |
| MUTED | `808080` | Off, Paused, any state that isn't acting, even when it's a picked value; a toggle that's off; notes; the version. |
| SEPARATOR | `AAAAAA` | The separator line, at 35%. Never a state word. |
| OFF | `CC3333` | Not used in menus. Off is gray: an off feature sits back, it isn't an error. |
| HELP | `CCCCCC` | Not in menu rows; notes are MUTED. A row tooltip's shortcut line. |

Item names take their quality color; a class name its class color (Style Guide → COLORS).

### Type

One size. Every row is the same 12-point line; kinds differ by color only, never by size or weight.

### Spacing

On the Spacing Scale (Style Guide → SPACING SCALE). Menu-Kit's constants:

| Constant | Points | |
|---|---|---|
| Row | 20 | A 12-point line plus `SPACE.LINE` (4) above and below |
| Spacer | 16 | `SPACE.GROUP`. The kit adds one above every heading. |
| Separator | 8 | `SPACE.NEAR`, a 1-point line across it |
| `TEXT_INSET` | 8 | A row's edge to its text |
| `EDGE` | 16 | The plate's edge to the text, on every side |
| `ROW_INSET` | 8 | The plate's edge to a row |
| `OPTION_INDENT` | 4 | Choice, toggle, item and value rows sit this much further in |
| `FLYOUT_OVERLAP` | 8 | `ROW_INSET`: the flyout's edge sits this far inside its menu's, where a row's highlight ends, clear of the arrow, as the game's own sub-menus do (Style Guide → MENUS); it rises 12 (`FLYOUT_RISE`) so its first row meets the row that opened it |
| `MIN_WIDTH` | 128 | |
| Wrap caps | 320 / 256 | A description / a note, before it would widen the menu |

### The Plate and Art

- Pretty Wide Quest Log's Quest Arrow plate, `Menu-Plate.tga`, nine-sliced at half size, 80% alpha.
- No boxes, borders or backgrounds inside it.
- The kit's own thin white chevron, `Menu-Arrow.tga`, for a flyout; the game's `UI-CheckBox-Check` for a pick; item and spell icons at line height (`|T…:0|t`).

## Components

Menu-Kit's row kinds (Style Guide → MINIMAP MENU → Row Kinds) plus the two Menu-Kit v2 adds. Each is drawn in the board's Components section.

| Kind | Left | Right | Use |
|---|---|---|---|
| `header` | Full Name, TITLE | Version, MUTED | First row, always |
| `status` | Title, TITLE | State | A feature with no flyout, or any heading with nothing to click |
| `submenu` | Title, TITLE | State, then the arrow | A feature whose flyout has something to show; More Features, with its count |
| `section` | Label, TITLE | Optional state | A group's heading inside a flyout |
| `description` | BODY, wraps at 320 | — | What a feature does. With `leftColor = "ON"`, a success line. |
| `note` | MUTED, wraps at 256 | — | A reason, an empty list, *N more* |
| `action` | Label, INFO | Nothing, or what it touches in VALUE | Toggle, Open, Erase, Clear, Options: one click, one job |
| `toggle` | Name; MUTED while off | On ON / Off MUTED | A setting's switch |
| `choice` | Name; VALUE when picked, BODY otherwise; an Off choice MUTED | Check when picked | One of a set |
| `separator`, `spacer` | — | — | A line; a line's room |
| `item` *(Menu-Kit v2)* | Icon, name in its quality color, `x4` count | A value, count, ratio or slot | An item the add-on acts on or lists. Hover shows the item. Option indent. |
| `value` *(Menu-Kit v2)* | Label, BODY | Value, VALUE (Off in MUTED); with a sub-menu, then the arrow | A setting that opens a picker, or a read-out with nothing to click: a total, a setting's read-back. Option indent. |

## Patterns

Built from the components, in the order a menu runs top to bottom. **See them live in Tracking Eye** ([`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Tracking-Eye/blob/main/Features/Minimap-Menu.lua)): header, feature blocks, the pick list, a follow-up action, flyouts with a live status, the Options footer and both ways; **and in Magic Eraser** ([`Features/Minimap-Menu.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Menu.lua)): the item highlight, live reports, the editable list and the More Features flyout. Style Guide → MINIMAP MENU names the function behind each.

- **Header.** Full Name and version, then one spacer. (The tooltips used two blank lines.)
- **Feature block.** Title with its state on the right, one description sentence, any rows of its own, the blue **Toggle**, then any follow-up action that applies right now. Every feature a player turns on and off mid-session gets one. Its Toggle's tooltip is the feature's Enable option, name and description.
- **Pick list.** When picking is the feature's main job, the choices sit inside its block, before Toggle (Tracking Eye's Persistent Tracking).
- **Follow-up action.** An action after Toggle, shown only while it applies: Clear Tracking while something's picked, Open while the Restock List is on.
- **Flyout.** A feature's secondary settings, beside its title. A live status leads as a section. Empty while the feature is off, and then the arrow goes.
- **Short right, wrapping left.** A title row's right side is a state word; any other right side a number, money, a ratio, a slot name or a click. A long left side wraps; nothing widens a menu or flyout past 320 (Will It Fit, below).
- **Item highlight.** A heading, the item row, then an action row per thing you can do to it (Magic Eraser's Lowest-Value Item: Erase, Protect).
- **Live report.** A heading over item or value rows that change with the bags or the group: Clutter Report, Dispense Report, Locked Items. A feature's own report sits inside its block, with no count beside the title (the Restocker's orders). Up to 8 rows, then a gray *N more*.
- **Editable list.** A list the player builds: one click-to-remove item row per entry, a delete icon on its right only while hovered (`rightOnHover`), the item's own tooltip plus a HELP line. Removing prints a chat line; Clear asks Yes or No first, unless the list is empty (Magic Eraser's Protect List).
- **Message line.** One wrapping line that stands in for a report: green when the news is good (bags clean, fully stocked), a gray note when it's just empty or off.
- **Master switch.** An add-on-wide switch gets the first block. While it's off, the blocks it silences hide and a note says why (Control Freak's All Alerts).
- **Reference flyout.** Notes about something else's clicks (Good to Go's macros) go in a flyout of value rows behind a class-colored title, each reading job first and click second in gray (`Conjure … Right-Click`), so the menu only holds rows you click here.
- **More Features.** One `submenu` row, last before Options, its set-and-forget switches in a flyout. Its right side counts them, `4 On, 3 Off`: the On count green, the comma white, the Off count gray. Block features aren't counted.
- **Options footer.** Spacer, separator, the `[Short Name] Options` action row. Last, always.
- **Clicks.** Every action is a row a controller can click, and no row names a button click. Hover opens the menu; Left-Click holds it open or closes it, in every add-on. A button keeps at most one other click, Right-Click, for one action repeated all session (Magic Eraser's Erase), named in that row's tooltip. A row answers any mouse button. Style Guide → MINIMAP MENU → Button Clicks.

## Wave 1: The Six Mini-map Buttons

Drawn row for row from each add-on's `main` in the board. Each has a spec in `Mini-map Menus/` saying every row, click and string, and a GitHub issue in its repo tracking the work. **They are the maintainer's work orders** (Style Guide → MINIMAP MENU): the UX Review draws one as the add-on's Proposed menu, and no other pass acts on one. The maintainer's order of work: the kit, then Tracking Eye (which proves it), then smallest to largest.

**Tracking Eye's menu** is the one every conversion follows row for row, read on GitHub: its clicks on their rows, More Features, the Features section and one refresh. The kit itself comes from Common-Core's `addon-kits/Menu-Kit/` (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu).

**Magic Eraser's menu** is the reference for the More Features flyout, click-to-remove list rows and a Clear that asks first.

| Order | Spec | Issue |
|---|---|---|
| 1 | [Menu-Kit v2](Mini-map%20Menus/Menu-Kit.md), **landed** in `addon-kits/Menu-Kit/` | [Gogo1951/Common-Core#3](https://github.com/Gogo1951/Common-Core/issues/3) |
| 2 | [Tracking Eye](Mini-map%20Menus/Tracking%20Eye.md) | [Gogo1951/Tracking-Eye#31](https://github.com/Gogo1951/Tracking-Eye/issues/31) |
| 3 | [Water Dispenser](Mini-map%20Menus/Water%20Dispenser.md) | [Gogo1951/Water-Dispenser#25](https://github.com/Gogo1951/Water-Dispenser/issues/25) |
| 4 | [Control Freak](Mini-map%20Menus/Control%20Freak.md) | [Gogo1951/Control-Freak#25](https://github.com/Gogo1951/Control-Freak/issues/25) |
| 5 | [GogoLoot](Mini-map%20Menus/GogoLoot.md) | [Gogo1951/GogoLoot#149](https://github.com/Gogo1951/GogoLoot/issues/149) |
| 6 | [Magic Eraser](Mini-map%20Menus/Magic%20Eraser.md) | [Gogo1951/Magic-Eraser#51](https://github.com/Gogo1951/Magic-Eraser/issues/51) |
| 7 | [Good to Go](Mini-map%20Menus/Good%20to%20Go.md) | [Gogo1951/Good-to-Go#18](https://github.com/Gogo1951/Good-to-Go/issues/18) |

| Add-on | Today | In the menu |
|---|---|---|
| Tracking Eye | Clear Tracking (Right-Click), Farm Mode (Shift + Left-Click), Target Tracking (Shift + Right-Click) and Options (Shift + Middle-Click) on their rows; Left-Click opens and holds the menu; More Features | The same menu on Menu-Kit v2. |
| Water Dispenser | Tooltip: one feature, one report, 2 clicks | One feature block and the Dispense Report. The first to convert. |
| Control Freak | Tooltip: three features, 4 clicks | All Alerts as a master switch, then the three feature blocks. |
| GogoLoot | Locked Items, then Automated Rolls (Left-Click), Automated Opening (Right-Click) and Loot Announcements (Shift + Left-Click) with the roll read-back as value rows, More Features in a flyout, and Options (Shift + Middle-Click); Shift + Right-Click held for the Master Looting Window | The same menu on Menu-Kit v2. |
| Magic Eraser | Erase (Left-Click), Protect (Right-Click), Clear Protect List (Middle-Click, asks first), Auto-Vend (Shift + Right-Click) and Options on their rows; click-to-remove Protect List rows; More Features in a flyout with its count | The same menu on Menu-Kit v2. |
| Good to Go | Tooltip: an item highlight, three features, class notes, two reports, 7 clicks | Current Food, three feature blocks (Restock List carrying its report), class items, a *[Class] Macros* flyout, Ignore List. |

## Kit Changes (Menu-Kit v2)

**All six are in Common-Core's `addon-kits/Menu-Kit/`** (`Mini-map Menus/Menu-Kit.md` → API). The add-ons move onto it one by one, Tracking Eye first.

1. **The menu's machinery moves into the kit.** Opening from the button, placing away from the screen edge, the close timer, Escape, flyouts and the public `ns.ShowMenu` / `ns.HideMenu` / `ns.RefreshMenu` are about 250 lines of Tracking Eye's `Minimap-Menu.lua` that know nothing about tracking. They move into `Menu-Kit.lua` as `Kit.CreateMenu{ name, build, flyouts }`, and an add-on's `Minimap-Menu.lua` keeps only its rows.
2. **`AddFeature` moves into the kit** as `Kit.FeatureBlock`, with the action's label as an argument (Toggle or Open).
3. **Two row kinds:** `item` and `value` (Components). Colors take a raw six-digit hex as well as a palette key, for quality and class colors.
4. **The click table moves into the kit.** *(Since changed: no row names a click; a kept Right-Click is named in its row's tooltip, and Left-Click always toggles the menu. Decision 1.)* An action entry names its click, and the kit draws that click's name on the row's right in MUTED and routes the button's `OnClick` to the same function. The API is `Mini-map Menus/Menu-Kit.md` → API. `action` rows default to INFO left and MUTED right, and the `hint` kind retires: the Options row is an action row.
5. **One canonical copy, in Common-Core.** The kit and its plate move to `addon-kits/Menu-Kit/` here, are copied into each add-on with a mini-map button, and CI checks every copy matches, the way `addon-files/` works today. Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 1, then copies it from Common-Core instead of Tracking Eye on GitHub.
6. **Flyouts and hover-only right text.** Tracking Eye and Magic Eraser both build flyouts by hand; the kit takes them (Kit Change 1), with `Kit.MoreFeatures` drawing the More Features row, its count and its flyout, and a `rightOnHover` entry flag that shows a row's right side only on hover without changing the menu's width. The API is `Mini-map Menus/Menu-Kit.md` → API.

## Will It Fit

Every one-line menu row from all six add-ons, in all 11 locales, measured the way Menu-Kit sizes them (Friz Quadrata's proportions for Latin and Cyrillic, a full 12 points per character for Chinese and Korean): **682 rows; English fits a 320-point menu everywhere, and 55 rows don't** in German, French, Spanish, Italian, Portuguese and Russian. The worst:

| Width | Row | Fix |
|---|---|---|
| 465 | Good to Go, French: Buff Food & Scrolls with its waiting list on the title | Paused on the title; the list in a note |
| 454 | Tracking Eye, Portuguese: Silence Sounds From Tracking Ability Casts | The label wraps |
| 452 | Water Dispenser, Spanish: Show Bag Tooltips for Dispensed Items | The label wraps |
| 384 | Magic Eraser, German: Clutter Report totals | The label wraps; money stays right |
| 366 | Good to Go, French: Restock List with its order count | No count beside the title |
| 350 | Control Freak, Italian: Options … MAIUSC + pulsante centrale | The label wraps; the click stays right |

With the two rules (Patterns → Short right, wrapping left), every row fits. The board's Will It Fit section draws these before and after, in their own language.

## Decisions

All decided by the maintainer; the Style Guide's MINIMAP MENU says each one now.

1. **Left-Click toggles the menu; at most one Right-Click.** Every action is a row; the button keeps at most one other click, Right-Click, named in its row's tooltip, never on the row. Rows answer any mouse button. (This replaced "Both ways", where the button kept every click and each row named its click.)
2. **State words** are On / Off everywhere (`MENU_ON` / `MENU_OFF`); a third state keeps its own word.
3. **Third states** are MUTED while not acting, never SEPARATOR gray.
4. **The menu's machinery moves into the kit** (Kit Change 1), in Common-Core; Tracking Eye moves onto it after.
5. **The kit lives in Common-Core** (Kit Change 5), copied into each add-on and checked by CI.
6. **`item` and `value` row kinds** join the kit (Kit Change 3).
7. **Long lists** may stop at a number of rows the add-on picks, then a gray *N more*.
8. **A hunter's ten-row pick list** in Tracking Eye stays as it is.
9. **Good to Go's macro notes** move to a class-colored reference flyout.

10. **Every row fits every language:** short on the right, long on the left wraps, nothing past 320.
11. **GogoLoot's Automated Master Looting is a More Features row**, and the Master Looting Window is a menu row (it was held for Shift + Right-Click before Decision 1 changed).
12. **Control Freak's Tanking Tools lists its settings inline**, gray while it's off.

13. **Control Freak's All Alerts is toggled from its row.** (It was Shift + Right-Click before Decision 1 changed.)
14. **Good to Go's rows need no combat guard.**

15. **More Features goes in a flyout**, behind one row that counts its switches On and Off.
16. **An editable list's rows remove on click**, and its Clear asks first.
17. **Every list edit prints a chat line**, the same sentence from the row, the button and the key binding.
18. **A setting's value is VALUE light yellow**, both beside its picker's arrow and on the picked row inside, so the two match; choices not picked are white, and Off stays gray.

## Using the Mock Kit

A wireframe pass that draws a mini-map menu loads `menu-mock.css` and `menu-mock.js` beside its page (as the Artifact's supporting files) and writes the menu as the Lua would:

```html
<link rel="stylesheet" href="menu-mock.css">
<div class="gg"><div class="gg-stage" id="menu"></div></div>
<script src="menu-mock.js"></script>
<script>
  GG.menu(document.getElementById("menu"), [
    { kind: "header", left: "Water Dispenser", right: "2.0.3" },
    { kind: "spacer" },
    { kind: "status", left: "Dispense", right: "On", rightColor: "ON" },
    { kind: "description", left: "Automatically fills the trade window when a trade opens, based on your settings." },
    { kind: "action", left: "Toggle", onClick: () => {} },
    { kind: "spacer" }, { kind: "separator" },
    { kind: "action", left: "Water Dispenser Options", onClick: () => {} },
  ], { flyouts: {} });
</script>
```

`GG.tooltip(host, lines)` draws an old-style tooltip for a Current view; `GG.icon(hue)` draws a stand-in icon, never game art; `GG.money(copper)` draws coins. The file's header lists every option.

## Wave 2: Options Panels

Every Active add-on's options panels, surveyed file by file from GitHub `main`, drawn in `Options Panels.html` and specced in `Options Panels/`. The Profiles panel is inherited (stock AceDBOptions, Style Guide → OPTIONS PANEL → Profiles Panel), Feedback & Support is a mandated template, and Diagnostic Tools has its own section: this wave draws all three in the tree and touches none of them. It covers everything else: the root page, the feature panels and their sub-panels.

### What the Survey Found

Nine add-ons, about 28,000 lines of options code, one shared idea and nine copies of it:

- **The same helpers, grown apart.** Every add-on carries `OptionsHeader`, `OptionsDesc`, `OptionsSpacer` and `OptionsRowLabel`, but the sub-option row has four signatures, the Example line five, the feature switch six names, and toggles-two-to-a-line four shapes, three of them sitting exactly on the wrap edge (Options-Kit.md → Why a Kit).
- **Features Mirror is one add-on deep.** Tracking Eye alone has `ns.FEATURES`. Five others keep a table of their own under another name with other fields; three re-declare each switch on the root page and again on its panel, and in two of those the copies have different setters, so the panel that wasn't touched goes stale.
- **One Refresh is one add-on deep.** Tracking Eye alone has `ns.RefreshSettings`. Elsewhere a setter notifies its own panel, a hand-picked other, or nothing.
- **Visible drift:** Examples flush in five add-ons and indented in three; a parent-off line red in one, silver with a red word in another, absent in seven; four Reset shapes; sub-panel titles naming their parent in three of nine; tree sidebars of 176 and 180; speakers of 16 and 18; Features sections holding descriptions, status lines, icons, gold group switches or blank lines.
- **Good ideas worth sharing,** now in the kit: GogoLoot's measured toggle rows, Tracking Eye's registration, Magic Eraser's item list and status line, Thanks for the Buff's page gate, Pretty Wide Quest Log's tooltip on a caption, Control Freak's disabled-at-default Reset, Good to Go's item check.

### Foundations

**The window.** AceConfigDialog draws each panel on a canvas in the Blizzard Options/Settings interface: the tree on the left, the page on the right, the page's group `name` as its gold title. 1 width unit is 170 points, so `ns.OPTIONS_ROW_WIDTH` (3.4) is 578 points, the width every row spends.

**Color.** On a panel:

| Role | Use |
|---|---|
| TITLE | Section headers, the page title, nothing else. Labels and captions are white. |
| BODY | Descriptions, captions, labels. |
| HELP | Sub-option captions, status lines, the `Example` label, a list's one-word tag, the copy caption, a key binding's what-it-does line. |
| INFO | Slash commands, click names, an editable message's tokens. |
| OFF | Only a warning line: the settings mean nothing will happen (none ticked, too long to send). |
| MUTED | Not bound, Loading, a disabled caption. |

Class names in their class color; items in their quality color.

**Type.** `fontSize = "medium"` everywhere. Never small; never large (a large line is a header).

**Spacing.** Spacer, header, spacer, description, spacer: every section, every panel (`Kit.Section`). Widths come from the grid (Options-Kit.md → The Grid), never typed as literals; a row's cells total `ROW_WIDTH`.

### Components

Options-Kit's pieces (`Options Panels/Options-Kit.md` → API), each drawn in the board's Components section:

| Piece | Kit | What it is |
|---|---|---|
| Section | `Kit.Section` | Spacer, gold header, spacer, description, spacer |
| Primary toggle | AceConfig `toggle`, `width = "full"` | A setting on its own line |
| Label row | `Kit.LabelRow` | A white caption (2.1) beside its dropdown, slider or box (1.3), with an optional helper line under the field |
| Helper line | `Kit.Helper` | One short silver line under a field, in the control column: a limit or consequence a player needs before they'd hover |
| Field sets | `Kit.FieldSets` | A section's field sets, a spacer between each |
| Sub-option row | `Kit.SubRow`, `Kit.SubToggleRow`, `Kit.SubLabelRow` | Indented, silver caption, under the control it belongs to, hidden while that's off |
| Switch and its setting | `Kit.ToggleRow` | A switch with its one setting beside it, a sound's speaker past the row's end; a caption too long sends them to the line below |
| Pairs | `Kit.Pairs`, `Kit.FeatureSwitches` | Short switches two to a line (1.6 each) |
| Feature switch | `Kit.FeatureSwitch` | One Enable switch from `ns.FEATURES`, drawn on the root page and atop its panel |
| Status line | `Kit.StatusLine` | Silver, shown only while something elsewhere changes this page |
| Warning line | `Kit.WarningLine` | Red, shown only while nothing will happen |
| Example | `Kit.Example` | A spacer, the silver `Example` label on its own line, then the finished line or lines in their own colors, indented and aligned |
| Reset row | `Kit.ResetRow` | A caption and a Reset button in the control column, gray at default |
| Sound preview | `Kit.SoundPreview` | A 16-point speaker past the row's end |
| Item list | `Kit.ItemList` | Add from Bags, Add Item, one row per item, Restore and Clear at the foot |
| Tree pane | `Kit.PrepareTree`, `TREE_ROW_WIDTH` | A 176-point sidebar, a 2.5 pane, opening on the current character |
| Sub-panel title | `Kit.SubPanelTitle` | "Farm Mode > Abilities" |

### Patterns

- **Root page.** Description, Enable Welcome Message, Enable Mini-map Button (with a button), Features, any tool rows, Key Bindings, /Commands. Nothing else (Style Guide → Main Page Layout).
- **Features section.** `ns.FEATURES` switches, two to a line, menu order, Enable captions. No description, status line, icon, group heading or blank line inside it.
- **Feature panel.** Description; its Enable switch (`Kit.FeatureSwitch`); then its sections, all hidden while it's off (`Kit.HideAllExcept`), so a switched-off feature shows only what it is and how to turn it on.
- **Sub-panel.** A list or separate tool under its feature, titled "Feature > Sub-panel". It stays in the tree while the feature is off and opens with a silver status line naming the switch (Decision 7).
- **Field sets.** A section is its header and summary, then its field sets, a spacer between each. A field set is one control and what belongs to it: one setting riding on the switch's line (`ToggleRow`), a helper line under the field where a player needs it before they'd hover (`Kit.Helper`), sub-rows for anything more, and last its Example, drawn as Style Guide → OPTIONS PANEL says (the `Example` label on its own line, no colon, the lines under it). Everything after the control leaves while it's off.

  ```
  Section Header
  Summary copy
  -- spacer
  Question Label                      Field
                                      Helper text
  -- spacer
  Question Label                      Field
  -- spacer
  Example
      Message
      Message, line 2
  ```
- **Hidden or disabled.** Hidden: belongs to a switch that's off. Disabled: the player can't change it here and now (not the leader, a reload pending, nothing to pick, already the default).
- **Tree group.** A per-character or per-item page set: 176 sidebar, `TREE_ROW_WIDTH` rows, the description above the tree, opening on home every time.
- **Long checklist.** Past 64 boxes, AceConfig toggles stall the UI on every click; one custom widget pools its checkboxes and writes without a rebuild (Thanks for the Buff's emote grid).
- **Live widget.** A preview or editor that must update per keystroke is a `description` with a custom `dialogControl` that saves without an AceConfig redraw (Play It Forward's mail editor and badge preview).
- **Panel files.** One file per panel, `Options/Options-[Panel].lua`; a panel with several files gets a subfolder, `Options/[Feature]/`, with its helpers in `Options-[Feature]-Utilities.lua` (Good to Go).

### Order of Work

Each add-on's spec in `Options Panels/` is the maintainer's work order, as Wave 1's are: the UX Review draws it as the add-on's Proposed panels, and no other pass acts on one. The kit is done; Magic Eraser proves it, then smallest to largest:

| Order | Spec | Options code | Biggest change |
|---|---|---|---|
| 0 | [Options-Kit](Options%20Panels/Options-Kit.md) | (the kit) | **Done:** `addon-kits/Options-Kit/`, sync script, CI check, smoke test |
| 1 | [Magic Eraser](Options%20Panels/Magic%20Eraser.md) | 2,313 lines | The proof; real items in its Examples |
| 2 | [Tracking Eye](Options%20Panels/Tracking%20Eye.md) | 1,500 | `click` and `gate` on `ns.FEATURES` |
| 3 | [Play It Forward](Options%20Panels/Play%20It%20Forward.md) | 1,830 | One switch per feature; two resets ask first |
| 4 | [Water Dispenser](Options%20Panels/Water%20Dispenser.md) | 1,885 | `ns.FEATURES`; Dispensed Items under Dispense |
| 5 | [Pretty Wide Quest Log](Options%20Panels/Pretty%20Wide%20Quest%20Log.md) | 2,186 | Sub-panels through `AddToBlizOptions` |
| 6 | [Thanks for the Buff](Options%20Panels/Thanks%20for%20the%20Buff.md) | 2,820 | Sub-panel titles; the composer on the grid |
| 7 | [Control Freak](Options%20Panels/Control%20Freak.md) | 3,452 | Features as three blocks; Examples follow Print |
| 8 | [Good to Go](Options%20Panels/Good%20to%20Go.md) | 5,424 | `FEATURE_SWITCHES` into `ns.FEATURES`; the kit's item list |
| 9 | [GogoLoot](Options%20Panels/GogoLoot.md) | 6,300 | Features in menu order; silver feature-off notes |

### Decisions

All decided by the maintainer; the Style Guide's OPTIONS PANEL (and SAVED VARIABLES → Reset, MINIMAP MENU → One Refresh and Features Mirror, COMMON-CORE) says each one now. 1–4 and 14–16 change only code; 5–13 change what players see.

1. **One Options-Kit in Common-Core,** copied unchanged into `Options/Options-Kit.lua` and checked byte for byte by CI. *Built.*
2. **`ns.FEATURES` in every add-on with a Features section,** in the kit's record shape; the root page, each panel's Enable switch and the menu build from it.
3. **One Refresh in every add-on,** menu or not: the kit's `ns.RefreshSettings`.
4. **Every panel registers through `Kit.RegisterPanel`** as its builder function; sub-panels nest by category ID; every ID is captured, so `ns:OpenOptionsPanel(key)` opens any panel.
5. **The Features section holds only the switches:** `ns.FEATURES`, two to a line, Enable captions. Icons allowed; what each does is in its tooltip, so no description, status line, group heading or blank line. Control Freak's holds its three blocks (Monitoring, Naughty List, Tanking Tools); each child keeps its switch on its own tab. Play It Forward's three captions take feature names the maintainer words.
6. **An Example sits under the control it shows, indented, and leaves while that control is off.**
7. **A sub-panel whose feature is off stays in the tree and opens with a silver status line naming the switch.**
8. **Sub-panel page titles read "Parent > Child"** in every add-on.
9. **Red only for a warning line** (nothing will happen). Status lines, including the parent-off line, are silver.
10. **One Reset shape:** a row of its own, the button in the control column, gray while there's nothing to reset, confirmed when it discards more than one value.
11. **One sound preview:** a 16-point speaker past the row's end, one tooltip wording.
12. **Tree sidebars are 176 points** (Magic Eraser and Play It Forward are 180).
13. **Key binding rows on the grid:** caption 2.1, bound key 0.75, Set Key 0.55, totalling 3.4; the what-it-does line silver.
14. **The kit's five strings take one key in every add-on** (Options-Kit.md → Strings), renamed in `enUS.lua` only. Other keys keep their names; new keys take `_DESCRIPTION` for a tooltip.
15. **GogoLoot's item-list extras stay its own** (filter, add line, New, sections, all README-Notes); `Kit.ItemList` is Magic Eraser's shape until the maintainer wants them in the kit.
16. **Order of work** as the table above.

### Using the Options Mock Kit

A wireframe pass that draws an options panel loads all four mock files beside its page and writes the panel as the Lua would, with `GO.kit` standing in for `ns.OptionsKit`:

```html
<link rel="stylesheet" href="menu-mock.css">
<link rel="stylesheet" href="options-mock.css">
<div class="gg" id="panel"></div>
<script src="menu-mock.js"></script>
<script src="options-mock.js"></script>
<script>
  var K = GO.kit, on = true;
  GO.settings(document.getElementById("panel"), [
    { label: "Water Dispenser", build: function () {
      return { type: "group", name: "Water Dispenser", args: {
        desc: K.Desc("Hands out water and food when a trade opens.", 1),
        header: K.Header("Features", 3),
        switches: K.Pairs(4, null, [
          { type: "toggle", name: "Enable Dispense", get: () => on, set: (_, v) => { on = v; } },
        ]),
      } };
    }, children: [{ label: "Dispense", build: { type: "group", name: "Dispense", args: {} } }] },
  ]);
</script>
```

`GO.page(host, group)` draws one page without the window. Every arg takes AceConfig's own keys; `c` tags a widget for the board's overlay. The file's header lists every option.
