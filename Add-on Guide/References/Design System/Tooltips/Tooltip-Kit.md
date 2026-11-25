# Tooltip-Kit (Common-Core)

The shared kit every Gogo add-on draws its tooltip lines with, in Common-Core so every add-on copies one file. It does two jobs: the **blocks an add-on adds to the game's own tooltips** (item, unit, spell), and the **tooltips on the add-on's own widgets** (a button's help, an item or spell row's tooltip, click hints). The kit owns the hooks, so no add-on writes its own `TooltipDataProcessor` or `HookScript` code again, and every block reads the same way whichever add-on drew it.

- **Built:** [`addon-kits/Tooltip-Kit/`](https://github.com/Gogo1951/Common-Core/tree/main/addon-kits/Tooltip-Kit) holds `Features/Tooltip-Kit.lua`, checked by StyLua, luacheck, `luac5.1 -p` and `scripts/test-tooltip-kit.lua` (`lua5.1 scripts/test-tooltip-kit.lua` from Common-Core), which runs it once on a client with `TooltipDataProcessor` and once without. A change to it is the maintainer's work, in a session launched in `~/Common-Core`; a session in an add-on folder never edits it.
- **Each add-on's move onto it is that add-on's own change** (What Each Block Becomes, below).
- **Not yet checked in game.** Checking It in Game, below, is the list.
- **The kit knows nothing about the add-on.** It reads only `ns.PALETTE` and four strings from `ns.L`: `ADDON_SHORT_NAME`, `MENU_ON`, `MENU_OFF` and `MENU_MORE`.
- **Built from:** GogoLoot's `Features/Lockbox-Tooltips.lua` (the block on a lockbox), Water Dispenser's `Features/Item-Tooltips.lua` (the two hook routes and the bag-only check) and `Features/Group-Spares.lua` (the unit block), Good to Go's `Features/Utilities.lua` (`ns.AddItemTooltipPostCall`, `ns.AddSpellTooltipPostCall`, the macro route), `Features/Inventory-Report/Inventory-Report-Tooltip.lua` (the guard cleared with the tooltip) and `Features/Enhanced-Spellbook/Spell-Rank-Lines.lua`, Play It Forward's `Features/Generosity-Tooltip.lua`, and Pretty Wide Quest Log's `routes.AddClickHints` (`Features/Routes/Routes-Core.lua`).

## Adopting It

```sh
# From Common-Core, once per add-on
scripts/sync-addon-kits.sh --adopt Tooltip-Kit ../Addon
```

Then add the file to every TOC, after `Features/Utilities.lua` and Chat-Kit (and after `Data/Data.lua`, which defines `ns.PALETTE` and `ns.L`). The two kits never call each other, so this is just the one order every add-on uses (Style Guide → TOC FILE FORMAT → File Group Order):

```
Features/Utilities.lua
Features/Chat-Kit.lua
Features/Tooltip-Kit.lua
```

From then on a plain `scripts/sync-addon-kits.sh ../Addon` refreshes it, and CI's **Shared kits match Common-Core** check fails a copy that differs. Never edit the copy.

## The Look

Every block the kit adds to a game tooltip is:

1. **A spacer**, one blank line, so the block never reads as another line of the game's or another add-on's.
2. **A header that reads like a menu header**: the title in `PALETTE.TITLE` gold on the left, Title Case, the add-on's Short Name in `PALETTE.MUTED` gray on the right. The header adds the spacer itself, so no add-on can forget it.
3. **Its rows, one step in** (`Tip.INDENT`). Labels are white (`BODY`), or the thing's own color: an item's quality color, a player's class color. Values are white (`TEXT`) on the right. A word beside a number on the right is gray and comes after it: `7 Bag, 18 Bank`, `25 Total`.
4. **A total or a state at the bottom**, like a sum, never beside the title.

And:

- **States:** On in `ON` green, Off in `MUTED` gray, in the add-on's `MENU_ON` and `MENU_OFF`. **Red (`OFF`) only for a requirement the player doesn't meet**, such as `Requires Lockpicking … 175` while short of it. A met requirement reads white, like any row.
- **Nothing to report, nothing shown.** A block with no rows draws no spacer and no header: the kit waits until the block is done to draw anything.
- **A long list may stop** at a number of rows the add-on picks, then a gray `%d more` (`MENU_MORE`).
- **Two add-ons on one tooltip each keep their own block.** Nothing merges.
- **Palette colors only,** never `NORMAL_FONT_COLOR` or `GameTooltip_AddNormalLine`.

```
Ornate Bronze Lockbox
Requires Lockpicking (1)

Lockbox                         GogoLoot      ← TITLE gold … MUTED gray
 Requires Lockpicking                  1      ← BODY … TEXT (red both sides when short)
```

Tooltips on the add-on's own widgets: a gold title, and the add-on's lines under it.

## API

```lua
local Tip = ns.TooltipKit
```

### Hooks on the Game's Tooltips

```lua
Tip.OnItem(function(block, itemID, link, tooltip) end, { bagsOnly = true, tooltips = { GameTooltip, ItemRefTooltip } })
Tip.OnUnit(function(block, unit, tooltip) end) -- skipped in combat unless { notInCombat = false }
Tip.OnSpell(function(block, spellID, tooltip) end)
```

The callback fills `block`; the kit draws it after the callback returns, and only if it holds a row. Call these at load: the kit installs every hook at `PLAYER_LOGIN` (behind the add-ons that hook while they load, so the block sits low in the tooltip), or right away when the player is already in the world.

- **The route is the client's own.** Where the game fills its tooltips through `TooltipDataProcessor` (the Retail engine: Forever) the kit adds a post-call; where `GameTooltip` still has the old script (`OnTooltipSetItem`, `OnTooltipSetUnit`, `OnTooltipSetSpell`: Era, TBC Anniversary) it hooks that script, always asking `HasScript` first. The Classic clients ship `TooltipDataProcessor` but their `GameTooltip` never runs on it (Water Dispenser and Play It Forward found this in game), so the kit decides by the script, not by the table being there.
- **Once per show.** Each registration draws at most one block per tooltip until the tooltip clears (`OnTooltipCleared`) or hides. The game can fill a tooltip twice for one show (a recipe and what it makes); the second fire adds nothing.
- **`tooltip:Show()`** runs after the lines go in, so the tooltip grows to fit.
- **`tooltips`**: the tooltips a hook draws on, `{ GameTooltip }` by default. Add `ItemRefTooltip` for a link clicked in chat. The comparison tooltips beside them only repeat the block, so leave them out.
- **`bagsOnly`** (items): only an item in one of the player's carried bags (bag 0 through `NUM_BAG_SLOTS`, plus the reagent bag where the client has one). On the old route the kit hooks `GameTooltip:SetBagItem` instead of the script, scoped by the bag the call names, which holds under replacement bag add-ons; on the tooltip-data route it asks the owner's `GetBagID`.
- **`notInCombat`** (units): **on by default**: nothing while in combat, checked before the unit is read, since a unit read in combat on Forever can be secret. Pass `notInCombat = false` only for a block that must show in combat and reads nothing a secret unit breaks. A unit that reads secret is skipped either way.
- **Spells shown by a macro** count as that spell on the tooltip-data route (an action bar slot holding a macro fills a Macro tooltip, not a Spell one). A macro showing an item, or nothing, is skipped.
- **The callback decides everything else**: whether the feature is on, whether the item or unit is one it cares about. Return without adding a row and nothing shows.

### Block Methods

Every method returns the block, so calls chain.

| Call | Draws |
|---|---|
| `block:Header(title)` | Spacer, then the title gold … the Short Name gray |
| `block:Row(label, value)` | Label white … value white. `value` may be nil for a label alone |
| `block:Item(itemIDOrLink, value)` | The item's icon at line height and its name in its quality color … value. An item not cached yet shows its name from the link, or its ID, in gray, and is asked for, so the next show has it |
| `block:Player(name, classFile, value)` | The name in its class color (Style Guide → COLORS' fixed table, never the game's `RAID_CLASS_COLORS`, which other add-ons rewrite) … value |
| `block:State(label, on)` | Label white … On green or Off gray |
| `block:Requirement(label, value, met)` | White, or red on both sides when `met` is `false`. `nil` (not known: a non-Rogue, a client that can't read the skill) reads white |
| `block:Line(text)` | A silver (`HELP`) sentence that wraps, not indented |
| `block:List(rows, max)` | Every row, or up to `max` when given, then `%d more` gray. Each row is `{ label, value }`, `{ label = , value = }`, `{ item = , value = }` or `{ name = , class = , value = }` |
| `block:Total(label, value)` | The bottom row, like a sum, however early it's called: `label` white on the left, `value` white on the right (`Total … 25`). `true` or `false` draws On or Off instead |
| `block:Done()` | Draws it (hooked blocks are drawn for you). True when it drew |

A label or value that already opens with a color escape keeps its own color: that's how a caller colors a rank by its state.

### Blocks Without Hooks

```lua
local block = Tip.Block(tooltip, { brand = false }) -- brand = false: the header has no Short Name
block:Header(L["EXAMPLE_TITLE"]):Row(L["EXAMPLE_LABEL"], 3)
block:Done() -- spacer (unless the tooltip is empty), header, rows, Show()
```

For a block on a tooltip the add-on fills itself: an options panel's Example of a tooltip block, or a footer under a game tooltip it set. The hooks use it too.

### The Add-on's Own Widgets

```lua
Tip.Help(owner, title, body, { helper = L["..."], hints = { { L["OPEN"], L["MENU_CLICK_LEFT"] } }, anchor = nil })
Tip.Thing(owner, linkOrSpellID, footer) -- footer: function(block), { title = , lines = { "a sentence", { label, value } } } or a helper sentence
Tip.Helper(tooltip, text)
Tip.Hints(tooltip, { { action, click }, ... })
Tip.Anchor(owner) -- the tooltip's corner and the owner's opposite one: "BOTTOMLEFT", "TOPRIGHT"
Tip.Own(tooltip, owner, anchor) -- SetOwner, placed by Tip.Anchor unless an ANCHOR_ name is given
```

- **`Tip.Help`** sets `GameTooltip` on the owner: the title gold, the body white right under it with no blank line, the `helper` (`Tip.Helper`), then the `hints`. Always a title; the body is optional. Returns the tooltip, shown.
- **`Tip.Thing`** sets the game's own tooltip, unchanged (a number is a spell ID, a string an item or spell link, or `"item:6948"`), then the footer: a spacer, a gold section title (no brand), the add-on's lines. A footer that is a string is a helper sentence (`Tip.Helper`): a spacer, then the sentence silver, no title (Good to Go's Ignore List rows: `Click to take it off your Ignore List.`). A footer with nothing to say adds nothing.
- **`Tip.Helper`**: a new section, so one spacer (unless the tooltip is empty), then the sentence `HELP` silver, wrapped. A helper never sits right under the lines above it.
- **`Tip.Hints`**: one spacer (unless the tooltip is empty), then each hint on its own line, the action `INFO` blue on the left, the click `MUTED` gray on the right, no blank lines between them.
- **`Tip.Anchor`**: away from the screen's nearer edges, side to side and up and down, as a menu opens (Style Guide → MINIMAP MENU → Placement). An owner left of the screen's middle opens its tooltip to the right, else to the left; one in the bottom half opens it upward, else downward. It returns the tooltip's corner and the owner's opposite one (`BOTTOMLEFT`, `TOPRIGHT` for an owner low on the left). `Tip.Own` sets the owner with `ANCHOR_NONE` and places it there; `Tip.Help` and `Tip.Thing` use it. `opts.anchor` on `Tip.Help` (an `ANCHOR_` name) overrides it.

### Helpers

- **`Tip.Count(number, word)`**: `7 Bag`, the number white, the word gray.
- **`Tip.Counts({ { 7, L["BAG"] }, { 18, L["BANK"] } })`**: `7 Bag, 18 Bank`, the commas gray with the words.
- **`Tip.Color(color, text)`**: text in a palette key's color or a six-digit hex.
- **`Tip.INDENT`** (one space, the step the add-ons' blocks already use) and **`Tip.LIST_MAX`** (8).

## The Seven Shapes

Five for the game's tooltips, two for the add-on's own widgets. Every block an add-on draws is one of these.

### Status Line

One row saying where something stands: a state, or a requirement.

```lua
Tip.OnItem(function(block, itemID)
	local required = ns.LOCKBOX_SKILL_LEVELS[itemID]
	if not (required and LockboxTooltipsEnabled()) then
		return
	end
	local skill = ns.IsPlayerRogue() and ns.GetPlayerLockpickingSkill() or nil
	block:Header(L["LOCKBOX_TITLE"]) -- "Lockbox"
	block:Requirement(ITEM_REQ_SKILL:format(ns.GetLockpickingSkillName()), required, skill and skill >= required)
end, { tooltips = { GameTooltip, ItemRefTooltip } })
```

```
Lockbox                         GogoLoot
 Requires Lockpicking                175   ← red both sides while short
```

### Read-out

A few labelled figures.

```lua
Tip.OnUnit(function(block, unit)
	local gifts, items, itemLevels, value = TotalsFor(unit)
	if not gifts or gifts == 0 then
		return -- Hidden until something's given
	end
	block:Header(L["OPTIONS_GENEROSITY_HEADER"]) -- "Badge of Generosity"
	block:Row(L["OPTIONS_GENEROSITY_GIFTS"], ns.CommaNumber(gifts))
	block:Row(L["OPTIONS_GENEROSITY_ITEMS"], ns.CommaNumber(items))
	block:Row(L["OPTIONS_GENEROSITY_ITEM_LEVELS"], ns.CommaNumber(itemLevels))
	block:Row(L["OPTIONS_GENEROSITY_VALUE"], ns.MoneyString(value))
end)
```

### Roster

Characters in their class colors, each with a count, and the total at the bottom.

```lua
Tip.OnItem(function(block, itemID)
	local report = ns.GetInventoryReport(itemID) -- this character first, then the others holding some
	if not report then
		return
	end
	block:Header(L["INVENTORY_REPORT_TITLE"]) -- "Inventory Report"
	for _, holder in ipairs(report.holders) do
		block:Player(holder.name, holder.class, Tip.Counts({ { holder.bags, L["BAG"] }, { holder.bank, L["BANK"] } }))
	end
	block:Total(L["TOTAL"], report.total)
end, { tooltips = { GameTooltip, ItemRefTooltip } })
```

```
Inventory Report                     GtG
 Gogo                        7 Bag, 18 Bank
 Altgogo                             4 Bag
                                  29 Total
```

A long roster takes `block:List(rows)` with `{ name = , class = , value = }` rows, so it stops at 8.

### Item List

Items, each with its icon and quality color, and an amount.

```lua
Tip.OnUnit(function(block, unit)
	local rows = SparesFor(unit)
	if not rows then
		return
	end
	local list = {}
	for index, row in ipairs(rows) do
		list[index] = { item = row.itemID, value = ns.db.profile.ShowQuantity and row.Amount or nil }
	end
	block:Header(L["SPARES_TITLE"]):List(list) -- "Spares"
end)
```

```
Spares                   Water Dispenser
 [icon] Conjured Crystal Water        20
 [icon] Conjured Cinnamon Roll        10
```

### Ranked List

One thing's ranks or steps, each colored by where the player stands, with a note on the right.

```lua
Tip.OnSpell(function(block, spellID)
	local row, ranks = RanksFor(spellID)
	if not row then
		return
	end
	local list = {}
	for index, rank in ipairs(ranks) do
		list[index] = { label = ns.RankLabel(rank, rank.subtext), value = ns.RankNote(rank) }
	end
	block:Header(L["WHATS_NEXT_TOOLTIP_RANKS"]:format(row.name)):List(list) -- "Firebolt Ranks"
end)
```

The rank's own colors come in on the label (`ns.RankLabel` returns it colored), which the kit keeps.

### Help

A widget's own tooltip: what it is and does, with its clicks.

```lua
button:SetScript("OnEnter", function(self)
	Tip.Help(self, L["RESTOCK_LIST_TITLE"], L["RESTOCK_LIST_DESCRIPTION"], {
		hints = { { L["OPEN"], L["MENU_CLICK_LEFT"] }, { L["OPTIONS"], L["MENU_CLICK_RIGHT"] } },
	})
end)
button:SetScript("OnLeave", GameTooltip_Hide)
```

```
Restock List                                ← TITLE gold
Buys what you keep, at every merchant.      ← BODY white, right under it

Open                           Left-Click   ← INFO blue … MUTED gray
Options                       Right-Click
```

### Thing + Footer

An item or spell row on the add-on's own window: the game's tooltip for it, unchanged, then the add-on's lines.

```lua
row:SetScript("OnEnter", function(self)
	Tip.Thing(self, self.link, function(block)
		block:Header(L["PROTECT_LIST_TITLE"]) -- gold, no brand
		block:Line(L["PROTECT_LIST_REMOVE_HELP"]) -- "Click to take it off the list."
	end)
end)
```

## The Strings It Needs

Every add-on already carries these, or takes them with its first kit (Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu, step 4, for where each translation comes from):

| Key | enUS | Used for |
|---|---|---|
| `ADDON_SHORT_NAME` | the Short Name | Every header's right side. A key the locale lacks reads as missing and falls back (blank, or `On`, `Off`, `%d more`): the kit reads the table raw, since AceLocale answers a missing key with its own name. |
| `MENU_ON` | `On` | `block:State`, `block:Total(label, true)` |
| `MENU_OFF` | `Off` | `block:State`, `block:Total(label, false)` |
| `MENU_MORE` | `%d more` | `block:List` past its `max` |

Titles, labels and words beside numbers are the add-on's own keys, handed in. Title Case for titles is the caller's job.

## What Each Block Becomes

| Add-on, replacing | With the kit |
|---|---|
| **GogoLoot**, `Features/Lockbox-Tooltips.lua`: `GogoLoot` alone as a header, then the requirement or the player's rank, green or red | **Status line** `Lockbox … GogoLoot`, its row a `block:Requirement`: red when short, white when met or not known (no more green). Its line scan for the block and its own hooks go: the kit's guard and hooks replace them. Keep the scan for the client's own requirement line, which still picks the row's wording |
| **GogoLoot**, `Features/Loot-Master.lua`: the Roll List's bag tooltip (`AddBagTooltipLines`), in a file no TOC loads | **Deleted** |
| **Water Dispenser**, `Features/Item-Tooltips.lua`: one branded `Will Dispense` line on a carried bag item | **Status line** with a state row (`block:State(L["TOOLTIP_WILL_DISPENSE"], true)`), `bagsOnly = true`. `ns.SetupItemTooltips`, `GetCarriedBagSlot` and both routes go |
| **Water Dispenser**, `Features/Group-Spares.lua`: the branded spares header and item rows on a unit | **Item list** `Spares … Water Dispenser`, skipped in combat (the default), stopping at 8. Its own hook pair (`HookTooltip`) goes |
| **Good to Go**, `Inventory-Report-Tooltip.lua`: `GtG // Inventory Report` with the total beside it, this character, a blank line, the others | **Roster** with the `Total` row at the bottom, no blank line inside the block. `ns.AddItemTooltipPostCall`, the `reported` guard and the five-second hook delay go (the kit hooks at login) |
| **Good to Go**, `Spell-Rank-Lines.lua` and `Spell-Ranks-Tooltip.lua`: `GtG // Firebolt Ranks` and a line per rank | **Ranked list** `Firebolt Ranks … GtG`. `ns.AddSpellTooltipPostCall` goes; the What's Next? rows draw the same block with `Tip.Block(GameTooltip)` |
| **Play It Forward**, `Generosity-Tooltip.lua`: the branded Badge of Generosity header and four silver rows, on your own tooltip even at all zeros | **Read-out** `Badge of Generosity … PIF` (its Short Name moves to the master list's PIF, Chat-Kit.md), white labels, **hidden until something's given** (zero gifts is nothing to report). Its route check and hook go; the town-only gate and hover ping stay in the callback |
| **Pretty Wide Quest Log**, `routes.AddClickHints`: a blank line between each hint | `Tip.Hints`, no blank lines between hints |

## Checking It in Game

On each client the add-on ships for (Forever, Era, TBC Anniversary at least), with `/reload` between steps:

1. **The route.** Hover an item, a player and a spell: the block shows once, under the game's lines. `/dump GameTooltip:HasScript("OnTooltipSetItem")` says which route that client took (true: scripts; false: tooltip data).
2. **The look.** A blank line, the gold title with the gray Short Name on the right, the rows one space in, white values, a total at the bottom.
3. **Once per show.** Hover a recipe, and rest the cursor on a bag item for a few seconds: one block, no flicker, no second copy.
4. **Nothing to report.** Hover an item the add-on doesn't care about: no blank line at the bottom, no header.
5. **`bagsOnly`.** The block shows on a carried bag item, not on the same item in the bank, at a merchant or in a chat link.
6. **`ItemRefTooltip`.** Click an item link in chat: the block shows there for a hook that asked for it.
7. **`notInCombat`.** Hover a party member in combat: no block, and no Lua error on Forever.
8. **Two add-ons.** With two adopting add-ons on, an item both report on carries two blocks, each with its own header.
9. **Resizing.** No line runs past the tooltip's edge.
10. **Own widgets.** A help tooltip opens on the side away from the screen's edge, its body right under the title, its hints with no gaps.
