# GOGO DESIGN SYSTEM

The pieces every Gogo add-on's interface is built from, named and drawn, so a menu, a panel or a window in one add-on looks and behaves like its neighbor in another. **The Style Guide holds the rules; this folder holds the pieces they describe.** Where the two disagree, the Style Guide wins until a triage reconciles them, and the disagreement is a Guide Feedback finding.

It grows in waves, one surface at a time:

| Wave | Surface | State |
|---|---|---|
| 1 | Mini-map menus | **This folder.** Six add-ons drawn and specced, decisions made, issues filed. |
| 2 | Options panel | Later. Rows and sub-rows are already specified in the Build Reference. |
| 3 | The add-ons' own windows | Later. |
| 4 | Lines added to the game's tooltips | Later. |
| 5 | Chat prints and sent messages | Later. |

## Files

| File | What it is |
|---|---|
| `README.md` | This: foundations, components, patterns, decisions, and the order of work. |
| `Mini-map Menus/` | One spec per add-on: its tooltip today, its menu row by row, its clicks, its strings, and how to check it in game. |
| `Mini-map Menus.html` | The board: every mini-map tooltip drawn from its code beside the menu it becomes, clickable, with scenario switches. Open it in a browser next to `menu-mock.css` and `menu-mock.js`. |
| `menu-mock.css`, `menu-mock.js` | The mock kit. Draws Menu-Kit entries and old-style GameTooltip lines at the game's sizes. Any wireframe pass that draws a mini-map menu builds from these instead of redrawing one (Using the Mock Kit, below). |

## Foundations

### Color

The roles are `ns.PALETTE` (Style Guide → COLORS). In a menu:

| Role | Hex | Menu use |
|---|---|---|
| TITLE | `FFD100` | Every heading: the header, feature titles, sections. The row highlight, at 16%. |
| INFO | `00BBFF` | Everything you click that isn't a setting: Toggle, Open, Erase, Clear, the Options row. |
| BODY | `FFFFFF` | Descriptions, read-out labels. |
| TEXT | `FFFFFF` | A toggle or choice that's on, values, counts. |
| ON | `33CC33` | On, Active, and a success line. |
| MUTED | `808080` | Off, Paused, any state that isn't acting; a toggle or choice that's off; notes; the version; the button click named on an action row. |
| SEPARATOR | `AAAAAA` | The separator line, at 35%. Never a state word. |
| OFF | `CC3333` | Not used in menus. Off is gray: an off feature sits back, it isn't an error. |
| HELP | `CCCCCC` | Not used in menus; notes are MUTED. |

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
| `ROW_INSET` | 4 | The plate's edge to a row |
| `OPTION_INDENT` | 4 | Choice, toggle, item and value rows sit this much further in |
| Flyout gap | 12 | `ROW_INSET + SPACE.NEAR`; the flyout rises 8 so its first row meets the title |
| `MIN_WIDTH` | 128 | |
| Wrap caps | 320 / 260 | A description / a note, before it would widen the menu |

### The Plate and Art

- Pretty Wide Quest Log's Quest Arrow plate, `Menu-Plate.tga`, nine-sliced at half size, 80% alpha.
- No boxes, borders or backgrounds inside it.
- Stock art only: `ChatFrameExpandArrow` for a flyout, `UI-CheckBox-Check` for a pick, item and spell icons at line height (`|T…:0|t`).

## Components

Menu-Kit's row kinds (Style Guide → MINIMAP MENU → Row Kinds) plus two this wave proposes. Each is drawn in the board's Components section.

| Kind | Left | Right | Use |
|---|---|---|---|
| `header` | Full Name, TITLE | Version, MUTED | First row, always |
| `status` | Title, TITLE | State | A feature with no flyout, or any heading with nothing to click |
| `submenu` | Title, TITLE | State, then the arrow | A feature whose flyout has something to show |
| `section` | Label, TITLE | Optional state | A group's heading inside a flyout |
| `description` | BODY, wraps at 320 | — | What a feature does. With `leftColor = "ON"`, a success line. |
| `note` | MUTED, wraps at 260 | — | A reason, an empty list, *N more* |
| `action` | Label, INFO | The button click that does the same job, MUTED | Toggle, Open, Erase, Clear, Options: one click, one job |
| `toggle` | Name; MUTED while off | On ON / Off MUTED | A setting's switch |
| `choice` | Name; MUTED unless picked | Check when picked | One of a set |
| `separator`, `spacer` | — | — | A line; a line's room |
| `item` *(proposed)* | Icon, name in its quality color, `x4` count | A value, count, ratio or slot | An item the add-on acts on or lists. Hover shows the item. Option indent. |
| `value` *(proposed)* | Label, BODY | Value, TEXT | A read-out with nothing to click: a total, a setting's read-back, a macro's click. Option indent. |

## Patterns

Built from the components, in the order a menu runs top to bottom.

- **Header.** Full Name and version, then one spacer. (The tooltips used two blank lines.)
- **Feature block.** Title with its state on the right, one description sentence, any rows of its own, the blue **Toggle**, then any follow-up action that applies right now. Every feature a player turns on and off mid-session gets one. Its Toggle's tooltip is the feature's Enable option, name and description.
- **Pick list.** When picking is the feature's main job, the choices sit inside its block, before Toggle (Tracking Eye's Persistent Tracking).
- **Follow-up action.** An action after Toggle, shown only while it applies: Clear Tracking while something's picked, Open while the Restock List is on.
- **Flyout.** A feature's secondary settings, beside its title. A live status leads as a section. Empty while the feature is off, and then the arrow goes.
- **Item highlight.** A heading, the item row, then an action row per thing you can do to it (Magic Eraser's Lowest-Value Item: Erase, Protect).
- **Live report.** A heading over item or value rows that change with the bags or the group: Clutter Report, Dispense Report, Locked Items. A feature's own report sits inside its block (the Restock List's orders). Up to 8 rows, then a gray *N more*.
- **Message line.** One wrapping line that stands in for a report: green when the news is good (bags clean, fully stocked), a gray note when it's just empty or off.
- **Master switch.** An add-on-wide switch gets the first block. While it's off, the blocks it silences hide and a note says why (Control Freak's All Alerts).
- **Reference flyout.** Notes about something else's clicks (Good to Go's macros) go in a flyout of value rows behind a class-colored title, so the menu only holds rows you click here.
- **Options footer.** Spacer, separator, the `[Short Name] Options` action row naming `Shift + Middle-Click`. Last, always.
- **Both ways.** Every action is a row a controller can click, and the button keeps every click it had. The row names its click on the right in gray: the old tooltip line `Right-Click … Clear Tracking` becomes `Clear Tracking … Right-Click`, the same two strings with the sides swapped. One table per add-on names each action's click and function; the row and the button's `OnClick` both read it, so they can't drift apart. Hover opens the menu. Left-Click opens and holds it, unless Left-Click has a job of its own (Magic Eraser erases), in which case hover alone opens it. Six clicks: Left, Right and Middle, plain or with Shift; Shift + Middle-Click is always Options. Style Guide → MINIMAP MENU → Button Clicks.

## Wave 1: The Six Mini-map Buttons

Drawn row for row from each add-on's `main` in the board. Each has a spec in `Mini-map Menus/` saying every row, click and string, and a GitHub issue in its repo tracking the work. Build in this order: the kit, then Tracking Eye (which proves it), then smallest to largest.

| Order | Spec | Repo for its issue |
|---|---|---|
| 1 | [Menu-Kit v2](Mini-map%20Menus/Menu-Kit.md) | Common-Core |
| 2 | [Tracking Eye](Mini-map%20Menus/Tracking%20Eye.md) | Tracking-Eye |
| 3 | [Water Dispenser](Mini-map%20Menus/Water%20Dispenser.md) | Water-Dispenser |
| 4 | [Control Freak](Mini-map%20Menus/Control%20Freak.md) | Control-Freak |
| 5 | [GogoLoot](Mini-map%20Menus/GogoLoot.md) | GogoLoot |
| 6 | [Magic Eraser](Mini-map%20Menus/Magic%20Eraser.md) | Magic-Eraser |
| 7 | [Good to Go](Mini-map%20Menus/Good%20to%20Go.md) | Good-to-Go |

| Add-on | Today | In the menu |
|---|---|---|
| Tracking Eye | Menu (the draft); its four old clicks were dropped | The same menu with the clicks back on their rows: Clear Tracking (Right-Click), Farm Mode (Shift + Left-Click), Target Tracking (Shift + Right-Click), Options (Shift + Middle-Click). Left-Click opens and holds the menu. |
| Water Dispenser | Tooltip: one feature, one report, 2 clicks | One feature block and the Dispense Report. The first to convert. |
| Control Freak | Tooltip: three features, 4 clicks | All Alerts as a master switch, then the three feature blocks. |
| GogoLoot | Tooltip: four features, a report, 5 clicks | Locked Items, then four feature blocks; the roll read-back as value rows. |
| Magic Eraser | Tooltip: an item highlight, a feature, two reports, 5 clicks | Lowest-Value Item with Erase and Protect, Auto-Vend, Clutter Report, Protect List. Left-Click still erases. |
| Good to Go | Tooltip: an item highlight, three features, class notes, two reports, 7 clicks | Current Food, three feature blocks (Restock List carrying its report), class items, a *[Class] Macros* flyout, Ignore List. |

## Proposed Kit Changes

1. **The menu's machinery moves into the kit.** Opening from the button, placing away from the screen edge, the close timer, Escape, flyouts and the public `ns.ShowMenu` / `ns.HideMenu` / `ns.RefreshMenu` are about 250 lines of Tracking Eye's `Minimap-Menu.lua` that know nothing about tracking. They move into `Menu-Kit.lua` as `Kit.CreateMenu{ name, build, flyouts }`, and an add-on's `Minimap-Menu.lua` keeps only its rows.
2. **`AddFeature` moves into the kit** as `Kit.FeatureBlock`, with the action's label as an argument (Toggle or Open).
3. **Two row kinds:** `item` and `value` (Components). Colors take a raw six-digit hex as well as a palette key, for quality and class colors.
4. **The click table moves into the kit.** `Kit.SetClickText` takes the six localized click names once; an action entry carries `click = { button, shift }`, and the kit draws its name on the row's right in MUTED and routes the button's `OnClick` to the same function (`Kit.HandleClick`). `action` rows default to INFO left and MUTED right, and the `hint` kind retires: the Options row is an action row.
5. **One canonical copy, in Common-Core.** The kit and its plate move to `addon-kits/Menu-Kit/` here, are copied into each add-on with a mini-map button, and CI checks every copy matches, the way `addon-files/` works today. The Style Guide's "copy it from Tracking Eye" becomes "copy it from Common-Core".

## Decisions

All decided by the maintainer; the Style Guide's MINIMAP MENU says each one now.

1. **Both ways.** Every action is a row, and the button keeps every click it had, named on that row in MUTED.
2. **State words** are On / Off everywhere (`MENU_ON` / `MENU_OFF`); a third state keeps its own word.
3. **Third states** are MUTED while not acting, never SEPARATOR gray.
4. **The menu's machinery moves into the kit** (Kit Change 1), in Tracking Eye first.
5. **The kit lives in Common-Core** (Kit Change 5), copied into each add-on and checked by CI.
6. **`item` and `value` row kinds** join the kit (Kit Change 3).
7. **Long lists** show up to 8 rows, then a gray *N more*.
8. **A hunter's ten-row pick list** in Tracking Eye stays as it is.
9. **Good to Go's macro notes** move to a class-colored reference flyout.

Still open, in its spec: whether Control Freak's free Shift + Right-Click goes to All Alerts.

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
    { kind: "action", left: "Toggle", right: "Left-Click", onClick: () => {} },
    { kind: "spacer" }, { kind: "separator" },
    { kind: "action", left: "Water Dispenser Options", right: "Shift + Middle-Click", onClick: () => {} },
  ], { flyouts: {} });
</script>
```

`GG.tooltip(host, lines)` draws an old-style tooltip for a Current view; `GG.icon(hue)` draws a stand-in icon, never game art; `GG.money(copper)` draws coins. The file's header lists every option.
