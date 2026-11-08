# STYLE GUIDE — BUILD REFERENCE

The Style Guide's rules for building options rows and diagnostics, moved here verbatim so passes that build neither can skip them. They bind exactly as the guide does; a section named here but not found in this file is a Style Guide section.

## OPTIONS PANEL

### Label-Beside-Control Rows

A control that needs a caption sits **beside** its label on one line, never stacked under it. AceConfig renders a widget's own `name` above it, so the row is built from two args instead: a `ns.OptionsRowLabel` cell, then the control with `name = ""` ordered immediately after. They flow onto one line because their widths total exactly one row.

The grid constants live in `Data/Data.lua`, and every add-on carries them:

```lua
ns.OPTIONS_ROW_WIDTH = 3.4
ns.OPTIONS_LABEL_WIDTH = 2.1
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25 -- the item lists' remove column, sized to its icon
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115 -- the blank cell a sub-option row leads with
```

- **Label plus control always total `ns.OPTIONS_ROW_WIDTH`.** A row needing a wider control passes its own width as `ns.OptionsRowLabel`'s third argument and gives the control the remainder, so every row still ends where every other row ends.
- The label is a description: its text may be a string or a function, and it takes color like any other text.

Live reference: **Control Freak** — `Options/Options-Utilities.lua`, the shared label-beside-control row builder; **Magic Eraser** — `Options/Options-Feedback-Support.lua`, where the link rows pass their own label width.

### Sub-Option Rows

A **sub-option** is a control that belongs to the control above it: it only means anything while that toggle is on, or it refines what that dropdown or slider chose. It is marked two ways at once — an indented control and a silver `GetColor("HELP")` caption — so the dependency reads whether the player is scanning shape or color. The parent stays as it is: a primary toggle at `width = "full"`, or a label-beside-control row. A switch with exactly one setting of its own instead takes the caption's place on a label-beside-control row, at `ns.OPTIONS_LABEL_WIDTH`, with that setting beside it at `ns.OPTIONS_CONTROL_WIDTH`, hidden while the switch is off.

Each sub-option is built by `SubRow(order, hidden, controls)`, returning an unnamed `inline` group whose first arg is a blank description cell at `ns.OPTIONS_SUB_INDENT_WIDTH` (a real widget: AceConfig pins a checkbox to the left edge of its own widget, so padding the label with spaces moves only the caption) followed by the controls, and `SubLabel(text)`, returning the caption wrapped in `GetColor("HELP")`. Placement follows FILE STRUCTURE: file-locals in the panel file, hoisted to `Options/Options-Utilities.lua` once a second panel builds sub-rows.

- **One unnamed inline group per sub-option.** A fill widget always gets a line to itself, so one group per sub-option pins one row per sub-option. Laid out flat, the next pair packs onto whatever space is left and the indent stops indenting anything.
- **Inside the group, the cells total at most `ns.OPTIONS_ROW_WIDTH`, the indent included, and none is `"full"`.** A wider row tips its control onto its own line and strands the indent above it.
- **`hidden` goes on the group, never on the members.** Hung off the controls individually, the indent is left behind on its own line when the section collapses.

Live reference: **Magic Eraser** — Bag-Space Warnings' threshold slider for the indented sub-row; the Auto-Vend section for a switch beside its one setting.

### Item Lists

An add-on that lets the player build a list of items renders it through one shared builder, `ns:BuildItemListOptions` in `Options/Options-Utilities.lua`. The panel supplies only the labels, the source table, and the `onAdd` / `onRemove` / `onRestore` callbacks. A list whose items each carry more settings than one per-row control can hold is instead a `tree` group with a page per item, and of this section only the Rules bind it. Shape, in order:

1. **Add from Bags** — optional; a label row whose `select` lists each distinct carried item not already on the list, since the bags close when the options open.
2. **Add item** — a label row whose control is an `input` that parses what the player typed or dragged in, calls `onAdd`, and returns `""` from `get` so the box clears itself.
3. **One `inline` group per item**, sorted by item *name* — a list ordered by ID reads as random.
4. **Restore defaults** — last, only for a list that ships defaults; `execute` with `confirm = true` and a `confirmText`.

Each row is up to four cells:

- **The item** — an `input` with `name = ""` and `dialogControl = ns.ITEM_LINK_WIDGET_TYPE` (`ADDON_NAME .. "_ItemLink"`), the small AceGUI widget drawing the icon and colored link with a tooltip on hover.
- **An optional per-row control** — one control at the add-on's own column width.
- **An optional tag** — one short silver `GetColor("HELP")` word, such as "Protected", when something else overrules the row.
- **Remove is an icon, not a labeled button.** An `execute` carrying `image = "Interface/Buttons/UI-GroupLoot-Pass-Up"` with `imageWidth`/`imageHeight` of 16 renders as an AceGUI Icon. Keep `name = ""` so it draws no caption and put the label in `desc`. (A caption clips to a sliver in a column this narrow.)

Rules:

- **Confirm what takes real effort to rebuild.** An item the player can put back in seconds, by adding it again, removes on one click with no confirm. An item carrying configuration of its own confirms, as does Restore defaults.
- **Row widths still total `ns.OPTIONS_ROW_WIDTH`** — the item cell takes the row width minus the remove icon, minus any per-row control or tag.
- **Every mutation ends in `AceConfigRegistry:NotifyChange`** on the panel's registry key so the list redraws.
- **Handle uncached items.** `C_Item.GetItemInfo` returns `nil` until the client has the item. Register a refresh watcher when any row is uncached, redraw as answers arrive, and unregister once nothing is outstanding — never leave a bare ID where an item link belongs.

Live reference: **Magic Eraser** — `Options/Options-Utilities.lua`.

-----

## DIAGNOSTIC TOOLS

### Report Header

Every report opens with the client and build so a pasted snippet always carries it. The header also reports the active locale (`GetLocale()`), the flavor (`ns.FLAVOR`), and the data folder this client loaded (`ns.DATA_FOLDER`, which reads `Discovery` on a Season of Discovery realm) — never `WOW_PROJECT_ID`, which reads the same on Forever and Retail. Reports are plain text; no color escapes, which paste as literal `|cff` codes.

### Event Log

Every registered event already routes through Core's dispatcher, so the one per-add-on piece is a single guarded call there — `if ns.diagnostics.logging then ns:LogEvent(event, ...) end` — with the boolean read before any allocation; feature code is never touched.

- When logging is active, entries go into a fixed-size buffer keeping the most recent `EVENT_LOG_SIZE` (500) events, written *before* the real handler runs.
- `ns:LogEvent` snapshots each argument to a string immediately — **never retain references**, since some events carry frames or tables that would leak or go stale. It caps argument count (`EVENT_LOG_MAX_ARGS`, 8) and per-argument byte length (`EVENT_LOG_MAX_ARG_LENGTH`, 255 — sized to hold a full loot line with its item link). **Escape pipes (`|` → `||`) after the length cut**, so a truncated argument can never leave a dangling pipe.
- `ns.DIAGNOSTIC_EVENT_EXCLUDE` holds only firehose events **the add-on actually registers**, and is **normally empty**. A firehose that is *sometimes* signal is never dropped: classify it at capture with the per-id filter below when the event carries an id, otherwise exclude it here and have the deciding handler write its signal firings back through `ns:LogEventNow`.
- Start and Stop drive `ns.diagnostics.logging`: Stop halts capture and keeps what was captured, so start / reproduce / stop / show returns a real report, and Start replaces the buffer. Show prints the log under the Report Header, followed by the suppressed-traffic summary.
- **Privacy:** if the add-on registers any `CHAT_MSG_*` event, the log will contain message bodies including whispers. The hint string warns the player to review output before pasting it.

### Event Log Noise

Some registered events are firehoses — `UI_ERROR_MESSAGE` fires on every red combat error whether or not it concerns the add-on. Logged raw against a bounded buffer, that traffic silently evicts the entries the log exists to carry. The fix is a per-message-id filter applied at capture: `ns.MESSAGE_ID_FILTERED_EVENTS` names the events carrying a message id and which argument position it arrives in; `ns:SuppressUncorrelatedMessage` decides per firing whether to log in full or fold into a counter.

- **Filter by what you act on, never by what you don't.** The set of message ids the add-on correlates *is* the allowlist. Never hand-maintain a denylist of noise ids — noise is unbounded, varies by class and activity, and renumbers across patches.
- **Reuse the live resolution path.** The filter classifies with the exact lookup the real handlers use — constant names resolved to this client's numeric ids at runtime, never persisted. A drifted filter makes the log lie about what fired.
- **Count, don't delete.** Suppressed traffic aggregates per id — first-seen text plus a count — and renders as one compact block at the end of the report, biggest offender first: `UI_ERROR_MESSAGE(56, Ability is not ready yet.) x469`. This is also how a tester discovers an id the add-on *should* be correlating.
- **Unclassifiable is signal.** A firing missing the field the filter classifies by is logged verbatim, never suppressed.
- **Filter at capture, not at render.** Suppression happens in `ns:LogEvent`, before the entry reaches the buffer. Filtering at display time still lets spam push real events out.
- **Pin it with tests** when the add-on has offline tests (Style Guide → LUA 5.1 → Offline Tests). Three minimum: spam collapses to one counted row, a correlated id still logs as a full line, an event with no id logs verbatim.

### Add-on Context Probes

Every add-on adds at least one small probe, a report on the Settings tab, for the state most likely to explain *its* "feature doesn't appear" reports — existence and value reads only. Magic Eraser's **Eraser Context** report is the worked example: it prints the character and profile, every switch that can stop an erase, the key bindings, what the bags hold, the list sizes and the item the eraser would take next. Common shapes:

- **Player & spell context** — class, level, and `IsPlayerSpell` / spell-info over the spells this add-on gates on, driven by `ns.DIAGNOSTIC_SPELLS`. Most "nothing shows up" reports are "the player doesn't know the spell" or "the API returned nil."
- **Display context** (only for add-ons that draw frames or a mini-map button) — `GetPhysicalScreenSize()`, `UIParent:GetScale()`, and the `uiScale` CVar. Solves off-screen and wrong-position reports.
- **Relevant CVars** — a short, curated readout of the CVars the add-on actually reads.

### Validate Data

Exports everything the current client knows about every spell, item and quest ID the add-on's static data references, as copyable TSV — and flags every ID this client doesn't recognize.

- **Manifest-driven.** `ns.DIAGNOSTIC_DATA_SOURCES` carries one entry per data file: a label (the table-name part of the file name, e.g. `Collections`) and, per table in that file, the table's key on `ns` (a name, not a reference, so a table that was never built can be reported), its kind (one per ID kind a client API can answer: `"spell"`, `"item"`, `"quest"`, `"area"`; `"other"` only for IDs none looks up), and how to reach the ID in each row. The Data tab builds one report row per entry, titled **Validate Data: [folder]/[label]-[folder].lua**, with the folder read from `ns.DATA_FOLDER`. Its button is labeled by the manifest label, and its silver line names the file.
- **TSV built for a spreadsheet.** The report is the standard client header, a blank line, then one TSV block per kind: a header row naming every column, then one row per ID. Strip embedded tabs and newlines from values, and escape pipes (`|` → `||`) so item links arrive as copyable text, not rendered links.
- **Every reader the client ships for the ID, one column each, blank where this client lacks it.** Validate Data is the data-generation source, so a row carries everything any of the three clients answers from the ID alone: never player or session state (counts, cooldowns, bag location, quest progress) beyond `IsPlayerSpell` and `IsSpellKnown`. For an item: all eighteen `C_Item.GetItemInfo` returns, the seven `C_Item.GetItemInfoInstant` returns, every `C_Item.*ByID` reader, every `C_Item.Is*` predicate that takes an item, `C_Item.GetItemFamily`, `C_Item.GetDetailedItemLevelInfo`, the class and subclass names, the stat table as sorted `key=value` pairs, and the item's spell (`C_Item.GetItemSpell`) with that spell's `C_Spell.GetSpellInfo` fields, subtext, description and tooltip. For a spell: the same spell columns plus `IsPlayerSpell` and `IsSpellKnown`. For a quest: every `C_QuestLog` reader that takes only the quest ID. Last comes the whole tooltip in one cell, lines joined by ` // ` and a right-hand text after ` >> `, through one `ns` accessor (`C_TooltipInfo` where the client ships its getters, a hidden `GameTooltipTemplate` tooltip where it doesn't). A reader a client adds later is a missing column.
- **Flag what's not on this client.** A `STATUS` column opens every row: `OK` once the ID, its text and its tooltip have all loaded; `NOT ON CLIENT` when `C_Spell.DoesSpellExist` or `C_Item.DoesItemExistByID` is false, or the ID never loads; `INCOMPLETE` when it loaded but its text or tooltip never did; `NO TITLE` or `NO NAME` when a quest's title or an area's name never comes back, which is not grounds to prune; `ERROR`, with the message in the Name cell, when a reader throws. The run carries on past `INCOMPLETE` and `ERROR`, and neither is grounds to prune. Flagged rows still print with their ID and source table, so the bad entry is copyable straight out of the sheet. A table the manifest names that this client's folder never built prints one `TABLE MISSING` row — that folder is missing a file or a table. An `"other"` table prints its row count instead of per-ID rows. A clean run flags nothing on any client — a `NOT ON CLIENT` ID is a row in the wrong folder (DATA → Flavor Folders).
- **One batch at a time.** Request 100 IDs (`C_Item.RequestLoadItemDataByID`, `C_Spell.RequestLoadSpellData`, `C_QuestLog.RequestLoadQuestByID`, and each item's spell), poll until every row in the batch has settled, asking again for stragglers after a few idle polls, and only then start the next batch. Progress shows on the report's row (`Running: 300 / 1,240 IDs`), never in the box. The finished TSV goes to the runner's callback with its `STATUS` tallies, which become the row's note (`Done: 1,207 OK, 15 INCOMPLETE`). Never stall the client inside one frame, and never wait forever: after a bounded run of polls with no progress, a straggler settles as a flagged row.

### Localization Tab

What a player on a non-English client pastes when a name, a line of chat or a macro comes out wrong. Each report is a manifest row like any other.

- **Locale Context.** `GetLocale()`, the `textLocale` and `audioLocale` CVars, and how many keys `ns.L` defines.
- **Game Names.** One row per game record the add-on names by ID (Style Guide → GAME NAMES), driven by `ns.DIAGNOSTIC_NAME_LOOKUPS`: the constant's name, its record kind, its ID, and the name this client returns through the add-on's own accessor, the exact call its features make. A lookup that returns nothing is flagged `NIL`; an item that hasn't loaded yet is requested and settled like Validate Data's stragglers. Run on a non-English client, this is GAME NAMES → Checking a New Lookup step 4 done for every lookup at once.
- **Message Length** (only where the add-on sends chat or writes macros). Builds each message and macro through the add-on's own builder, with the longest names its data holds in this locale, and prints each one's byte length against its ceiling (Style Guide → MESSAGES → Message Length), flagging any over. It builds strings only: nothing is sent and no macro is written. Pretty Wide Quest Log's `ns:BuildMessageLengthReport` is the worked example.

### Saved Variables Dump

Dumps the add-on's saved tables as readable text so a player can paste their exact configuration into a bug report. Use a small recursive printer — no serializer library, nothing new in Includes. Cap recursion depth. Print every row the player can edit, since those rows explain the bug; only data the add-on fills in itself (caches, history, scan results) may be summarized by length.

### Taint Log

A **Taint Log** box on Run Tests. **Turn On** sets the `taintLog` CVar to verbose (`2`) and **Turn Off** sets it to `0`. Each is disabled when it would change nothing, and the current level shows beside them. The add-on can't read `Logs\taint.log`, so the Taint Log is a toggle, never a report. Tell the player the setting persists across sessions, and that a `/reload` captures taint from load onward.

### Don't Build These

Point players at the mature tools instead of re-implementing them. They go in two boxes on Run Tests, each row a label beside a read-only copy box (the game can't open links, so a URL is something to copy):

- **In-Game Tools:** Event Trace (`/etrace`; the in-panel log captures only the add-on's own registered events) and Console Errors (`/console scriptErrors 1`).
- **External Tools:** Bug Grabber and Bug Sack, credited to their author, Funkeh, each with its CurseForge URL. Name add-ons as readable words, never by their folder names (`!BugGrabber`).
