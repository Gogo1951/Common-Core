# ADD-ON CREATION RULES & STYLE GUIDE

Strict rules for all Lua code and text generation across all Gogo1951 add-ons.

**The rules here are authoritative — follow the rules, not any one file.** Snippets and named reference repos show the required *shape*; they are examples, not specs to reproduce byte-for-byte. Where a rule conflicts with a live file, the rule wins and the file is what gets fixed — in its own repo, never by an exception and never by Guide Feedback.

**One check comes first: the rule's Live reference.** Before fixing an add-on to match a rule that changes what players see, read the add-on the rule names as its Live reference on GitHub `main`. If the reference does the opposite of the rule, the guide may be what's wrong. Report the conflict to the maintainer as a question, quoting the rule and the reference's code, and change nothing until they rule.

**A rule that changes what players see changes only on the maintainer's explicit yes to that change.** This covers anything they see or feel: chat output, UI, defaults, and when anything prints, shows or runs. Whoever proposes it states it as before → after in player terms, checks it against the section's Live reference, and says in the question when the change would put the reference out of compliance. It never rides along with a wording, consolidation or cleanup edit. Once it's approved, the reference add-on gets the same fix, so the guide and its reference never disagree.

An add-on's departures from this guide live in its `README-Notes.md` — see README-NOTES.

-----

## GLOSSARY — HOUSE SPELLINGS

The maintainer's spellings are deliberate. **Never "correct," flag, or normalize them anywhere** — strings, READMEs, comments, reports, or chat. This glossary governs enUS; interpret its intent best-effort in other locales and don't re-ask per locale.

| Use | Never | Scope note |
|---|---|---|
| Add-on / add-on | Addon, addon, AddOn | Prose and player-facing text. Code identifiers (`ADDON_NAME`, `AddonNameDB`), API names (`C_AddOns.GetAddOnMetadata`), the `Interface/AddOns` path, and external titles keep their technical spelling. |
| Mini-map / mini-map | Minimap, minimap | Prose and player-facing text. `Features/Minimap-Button.lua`, the `minimap` saved-variables key, LibDBIcon APIs, and existing section headers keep their technical spelling. |
| Options Interface | options interface, Options Panel, Settings menu | Player-facing text. Two phrasings stay sanctioned: "options panel" for the AceConfig surface (this guide's own prose), and "Blizzard Options/Settings interface" for the host window — never collapse that one into "Options Interface". Code identifiers, file names, and section headers keep their spelling. |
| CurseForge | Curseforge, Curse Forge | — |
| GitHub | Github, github | — |
| Wago | wago, WAGO | Site addresses (`addons.wago.io`, `wago.tools`) stay lowercase. |
| WoW | Wow, WOW | — |
| `(=` | =), :), 🙂 | The house smiley, used verbatim. |

-----

## REPOSITORY LAYOUT

```
Repo-Name/
├── .github/
│   └── workflows/
│       ├── ci.yml                  Shared: calls Common-Core's CI — see COMMON-CORE
│       └── package.yml             Shared: calls Common-Core's release — see COMMON-CORE
├── .gitattributes                  Shared — see COMMON-CORE
├── .gitignore                      Shared — see COMMON-CORE
├── .luacheckrc                     Lint config — see LINTING
├── .pkgmeta                        Externals and ignore list
├── AddonFolder_Vanilla.toc         Classic Era, Season of Discovery included
├── AddonFolder_TBC.toc             TBC Anniversary
├── AddonFolder_Camelot.toc         WoW Forever — one TOC per target, never an unsuffixed one; see TOC FILE FORMAT → Flavor TOCs
├── Bindings.xml                    Optional — only if the add-on ships a key binding
├── Data/
│   ├── Flavor.lua                  see COMPATIBILITY
│   ├── Data.lua
│   ├── Default-Settings.lua
│   └── {Game}/{Table-Name}-{Game}.lua  Optional as a set — one folder per flavor; see DATA → Flavor Folders
├── Diagnostics/                    Diagnostic Tools, copied whole — see DIAGNOSTIC TOOLS
├── Features/
│   ├── Core.lua
│   ├── Utilities.lua
│   ├── Announcements.lua
│   ├── {Feature-Name}.lua          Optional — one per feature; a single-feature add-on may stay in Core.lua
│   └── Minimap-Button.lua          Optional — only with a mini-map button (MINIMAP BUTTON)
├── Includes/
│   ├── Images/                     The icon and other art
│   ├── Libraries/                  Vendored libraries — see REQUIRED LIBRARIES
│   └── Sounds/                     Optional — only if the add-on plays sound
├── Locales/
│   └── enUS.lua                    Source of truth; the full set ships beside it — see LOCALIZATION
├── Options/
│   ├── Options-Utilities.lua
│   ├── Options-General.lua
│   ├── Options-{Feature-Name}.lua  Optional — one file per feature panel
│   ├── Options-Profiles.lua
│   ├── Options-Feedback-Support.lua
│   └── Options.lua
├── Tests/                          Optional — offline tests; see LUA 5.1 → Offline Tests
├── LICENSE                         MIT
├── README.md                       End-user documentation
├── README-Notes.md                 The add-on's exceptions to this guide — see README-NOTES
├── README-Technical.md             Developer documentation
└── README-Testing.md               Optional — manual test plan; never a finding either way
```

**Every entry in the tree is mandatory unless its annotation says otherwise.** FILE STRUCTURE says what each file is *for*. On required-versus-optional, the tree wins. An optional entry ships exactly when its annotation's trigger is met, never on preference.

Live reference: **Connoisseur** — the folder layout, end to end.

**Dev-only files are outside this tree's scope.** A file that exists only for development — an API/type stub, a maintainer backlog, a parity harness under `tools/` — may sit anywhere in the repo; offline tests are the exception and live in `Tests/`. Its presence is never a finding; it is never added to the TOC (stubs that define real API names would overwrite live globals at load); and it must be in the `.pkgmeta` ignore list — one that isn't is a finding. The tree's own entries stay mandatory even when the ignore list keeps them out of the zip.

-----

## FILE STRUCTURE

|File|Responsibility|
|---|---|
|`Data/Flavor.lua`|Flavor identity (`ns.FLAVOR`, `ns.EXPANSION`, `ns.IS_DISCOVERY`) and the loaded data folder (`ns.DATA_FOLDER`). Copied byte for byte from `References/Canonical Files/Flavor.lua` — see COMPATIBILITY.|
|`Data/Data.lua`|Locale initialization (`ns.L`), constants, enums, color tables, target marker, AceConfig registry names, URLs. No logic beyond `GetLocale`.|
|`Data/Default-Settings.lua`|`ns.DATABASE_DEFAULTS`, the AceDB-3.0 defaults table.|
|`Data/{Game}/{Table-Name}-{Game}.lua`|Static game data, one complete set per flavor — see DATA → Flavor Folders.|
|`Features/Core.lua`|Add-on identity, saved-variable lifecycle, central event dispatcher — every registered event routes through it (feature files never call `RegisterEvent` or create an event frame), with the event list exported as `ns.EVENT_NAMES` so the dispatcher and Diagnostics can't drift. No shared utilities.|
|`Features/Utilities.lua`|Stateless functions used by multiple files: API shims, color accessors, tooltip helpers, parsing, small game-state predicates.|
|`Features/Announcements.lua`|The single home for all messaging: `PrintMessage`, `BuildAnnounceMessage` / `Announce`, `GetGroupChatChannel`.|
|`Features/{Feature-Name}.lua`|Self-contained feature module. Owns its logic, timers, caches. Exposes only what other modules need via the namespace.|
|`Features/Minimap-Button.lua`|Optional. LDB object, button, tooltip, click handlers.|
|`Diagnostics/`|The Diagnostic Tools framework and panel, with the add-on's own manifests and context probe in `Manifests.lua` — see DIAGNOSTIC TOOLS. Self-contained English strings. No gameplay logic.|
|`Options/Options.lua`|AceConfig registration, Blizzard panel wiring, panel navigation, slash commands. Nothing else.|
|`Options/Options-Utilities.lua`|Shared options infrastructure: widget helpers, shared list builders, custom AceGUI widgets, item-cache warming.|
|`Options/Options-General.lua`|The root General panel. No reset controls (see SAVED VARIABLES → Reset).|
|`Options/Options-{Feature-Name}.lua`|One file per options panel, named for the panel's enUS tab name or a `Features/` file it configures. A panel may hold several features' settings.|
|`Options/Options-Profiles.lua`|Returns the stock AceDBOptions-3.0 table unmodified.|
|`Options/Options-Feedback-Support.lua`|The Feedback & Support panel: the mandated Level Up note, the four links and the version line — see OPTIONS PANEL → Feedback & Support Panel.|
|`Locales/{langCode}.lua`|AceLocale-3.0 strings, our own words only (GAME NAMES). `enUS.lua` is source of truth.|

- **Single-feature add-ons** may keep the feature's pipeline in `Core.lua` rather than splitting it into a one-file `Features/` module; both shapes are correct. Otherwise `Core.lua` holds no feature logic.
- A function belongs in `Utilities` only when multiple files use it. ("Utilities", never "Helpers.")
- Everything hangs off the namespace table (`local ADDON_NAME, ns = ...`). The only globals are the ones something outside the add-on's own Lua must reach — SavedVariables tables, slash registrations, named frames, a key binding's global handler and `BINDING_*` strings (declared in a `Bindings.xml` at the add-on root, auto-loaded by the client and never listed in the TOC), and the names a written macro body reaches through `/run`. Each carries the add-on's distinctive prefix.
- **Keep files small and single-purpose.** Actively look for splits rather than letting files grow. When a file does more than one job or has grown past holding in your head, flag it and recommend a concrete split — which functions move where, and what each resulting file owns. Split on responsibility, not line count. A split-out file stays in its parent's folder, or a subfolder named for its feature, and the rules that bound its code move with it.

-----

## COMPATIBILITY

Every add-on supports every current target, one TOC each (TOC FILE FORMAT → Flavor TOCs). **Forever is the Retail engine running Classic Era data, plus new content still being datamined** — expect Retail API behavior with Classic items and spells, and test every feature there before each release.

- **The TOC names the flavor; code never works it out.** `Data/Flavor.lua` reads the chosen TOC's `## X-Flavor` and is the only place flavor identity is decided. Never identify a client by `WOW_PROJECT_ID`, a build number, or an interface range — Forever's `WOW_PROJECT_ID` has already changed value once, from Retail's `WOW_PROJECT_MAINLINE` to its own `WOW_PROJECT_CAMELOT`. It sets `ns.FLAVOR` from that field, `ns.EXPANSION` (the game's major version, Forever counting as 1), `ns.IS_DISCOVERY` (Season of Discovery, which no TOC can name) and `ns.DATA_FOLDER` (the data folder this client built). The file is identical in every add-on: copy `References/Canonical Files/Flavor.lua` byte for byte.

- **Put each flavor difference in the first of these places that can hold it:**
    1. **Data** — the rows in each flavor folder (DATA → Flavor Folders).
    2. **The TOC** — a feature with no path on a flavor is left out of that flavor's TOC, never half-run behind scattered checks: its `Features/` file and options panel go together, and the events only it needs go unregistered there, since registering an event the client lacks throws. Shared code that reaches into it checks that it loaded.
    3. **One `ns` accessor** in `Features/Utilities.lua`, for an API the engines genuinely differ on: modern branch first, resolved once at load, never written into a Blizzard global.
    4. **A code gate**, for behavior only. It reads `ns.FLAVOR` or `ns.IS_DISCOVERY`; one meaning "this expansion or later" compares `ns.EXPANSION` with `>=` — never an equality chain, and never a default branch that files an unrecognized flavor as the newest.
- **Don't codify differences between clients on assumption.** A flavor gate or client-difference workaround needs a demonstrated difference behind it: a manual test for how something behaves, and for whether a client *has* an API, event, or template, its UI source (one branch per client at <https://github.com/Gethe/wow-ui-source>) or a Diagnostics API row. An existing gate is never a finding for lacking that evidence, only for breaking a rule here.
- **Call a namespaced API directly wherever all three clients ship it** (`C_AddOns`, `C_Container`, `C_Item`, `C_Minimap`, `C_Secrets`, `C_Spell`, `C_SpellBook`, `C_UnitAuras`), with no legacy fallback — the Retail engine has dropped the legacy globals (`GetItemInfo`, `GetSpellInfo`, `UnitBuff`), so a bare legacy call errors on Forever.
- **Pick compatibility APIs by availability, never by truthy result.** `(C_CVar.GetCVarBool(...)) or GetCVar(...)` silently falls through to the legacy read whenever the modern call returns `false`. Check the API exists, then call exactly one, and check the modern one first: other add-ons put legacy globals back on Forever (Questie restores dozens, `UnitAura` and `GetSkillLineInfo` among them), so a legacy global being present proves nothing about the client.
- **A name the client doesn't know throws, so check before naming it.** `HookScript` on a script type the widget lacks throws (`OnTooltipSetUnit` is gone on Forever), and so does `CreateFrame` with a template the client doesn't ship (Forever's tab template is `PanelTabButtonTemplate`, not `TabButtonTemplate`). Ask `frame:HasScript(name)` and `C_XMLUtil.GetTemplateInfo(name)` first; events follow the TOC rule above.
- **Wrap the risky call, never a block.** A `pcall` around setup code turns one missing API into a whole feature that silently never starts.
- **A frame parented to a Blizzard panel stays protected for good.** After `SetParent` onto one, `IsProtected()` stays true even back on `UIParent`, and in combat only `SetAlpha` still goes through. Parent to `UIParent`, anchor next to the panel, and write nothing to the panel itself. Never call `SetUIPanelAttribute` or `RegisterUIPanel`, which taint Blizzard's secure panel chain; a window that closes on Escape goes in `UISpecialFrames`.
- Never use `SetBackdrop` without `BackdropTemplateMixin` or `BackdropTemplate` inheritance.
- **Combat-calculation features don't work on Forever, same as Retail.** In-combat reads of auras, cooldowns, casting, and unit identity come back secret: an aura read throws, and a secret value can't be tested or compared. Ask `C_Secrets` before any read that can go secret, and never work around one — a feature that needs the real value has no Forever path. The combat log is restricted there too: registering `COMBAT_LOG_EVENT_UNFILTERED` raises `ADDON_ACTION_FORBIDDEN` against the add-on, which `pcall` can't catch, so a feature built on it stays out of the Camelot TOC.

### Game Mechanics

- **Cooldown checks distinguish real cooldown from the GCD** — never with a magic threshold like `duration > 1.5`, which breaks under haste. `C_Spell.GetSpellCooldown` reports a spell on GCD as a short nonzero `duration`, so `duration > 0` alone misreads "on GCD" as "on cooldown." Compare ready times: a spell is on real cooldown when `duration > 0` and its `start + duration` exceeds the GCD's own (read the GCD from any known zero-cooldown spell). Where "ready within one GCD" is close enough, plain `duration > 0` is acceptable — say so in a comment at the call site.
- **Every spell rank has its own ID.** A lookup or cast by name resolves to the highest rank the player knows, and an aura carries the ID of the rank that was cast, so a check for a buff matches every rank's ID, never one. Read durations off the aura, never hard-code them: Forever changed some (Blessing of Might lasts an hour there).
- **The BoP master-loot trade window is instance-wide, not raid-only.** Gates check `instanceType == "raid" or instanceType == "party"`; never "correct" that to raid-only.
- **Arenas restrict consumables.** Ordinary food, drink, potions and scrolls are blocked there; conjured food/water and the arena-only drinks still work. Any feature that writes or rewrites a consumable macro must suppress those paths in an arena — detect live via `IsInInstance()`, never via zone-ID lists.

-----

## DATA

Prefer storing game data statically in `Data/` over fetching it at runtime: static data is deterministic and never fails on a cache miss. **Store statically** anything keyed off an ID that doesn't change between patches — prices, item-to-spell mappings, vendor and recipe data, faction IDs, currency values, and tooltip-derived item flags (conjured, unique-equipped: fixed per-ID constants taken from Validate Data's tooltip column; feature code never scans a tooltip for them). **Pull from the API** anything that changes during a session — player, target and group state, equipped items, buffs and debuffs, cooldowns — and every name the player sees, which the client supplies by ID (GAME NAMES).

### Flavor Folders

**Every flavor gets its own complete copy of the add-on's static game data, and each client loads exactly one copy.** No universal files and no exceptions: a row true on five flavors is written in five files. Duplication is the accepted price of every data file holding the whole truth for one client and nothing else.

- **Seven folders, one per flavor, each named by its code name (TOC FILE FORMAT → Flavor TOCs):** `Data/Vanilla/`, `Data/Discovery/`, `Data/TBC/`, `Data/Camelot/`, `Data/Wrath/`, `Data/Mists/`, `Data/Mainline/`. An add-on with any static game data keeps all seven in its repo, whichever TOCs it ships, so a flavor's data can be built before its TOC exists; an add-on with none has no folders.
- **Every folder holds the same table names, each suffixed with its folder's name, and each file declares the same tables.** A table with no rows on a flavor is declared empty there (`ns.FOOD_ITEMS = {}`), so feature code reads every table without checking which flavor built it.
- **A file declares its tables whole.** One table lives in one file, and no file adds rows to a table another file declared.
- **Game IDs live only in the flavor folders**, default item/spell lists included: they sit beside the tables they draw from, and `Default-Settings.lua` reads them from there.
- **A TOC lists its own folder and no other.** Camelot copies Vanilla's files rather than listing them. **The one pairing is Season of Discovery**, which runs on the Classic Era client, so no TOC can select it: the Vanilla TOC lists `Data/Vanilla/` then `Data/Discovery/`, and each file in the pair opens with its guard, so exactly one folder's tables are built.
- **No row carries an expansion tag, a flavor column, or a flavor check** — its folder says where it is true.
- **Row order never carries meaning.** A table that must be ranked carries the rank as a field and is sorted after load.
- **Copies drift, so every change says where it went.** A pass that changes a row looks up the same ID in the other six folders and reports which copies it changed, which it left, and why.
- **A table over 20 rows is never retyped or reproduced.** Edit only the rows at issue, in place; copy or move rows between folders with a script, never by retyping, and confirm each folder's row count.

`Data/Vanilla/Food-and-Water-Vanilla.lua`, then `Data/TBC/Food-and-Water-TBC.lua` declaring the same table whole with TBC's rows. Discovery's files open with the inverse guard; no other folder's files have one. Each file ends with its `How We Got the Data` block (Data File Layout).

```lua
local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- { itemId, category }
ns.FOOD_ITEMS = {
	{ 159, "WATER" }, -- Refreshing Spring Water
}
```

```lua
local _, ns = ...

-- { itemId, category }
ns.FOOD_ITEMS = {
	{ 159, "WATER" }, -- Refreshing Spring Water
	{ 27860, "WATER" }, -- Purified Draenic Water
}
```

### Default-Settings.lua

One AceDB-3.0 defaults table per add-on: the scope subtables the model calls for, one key per setting. Which model and which scope are decided in SAVED VARIABLES.

```lua
-- Data/Default-Settings.lua — Per-Character model
ns.DATABASE_DEFAULTS = {
	global = { -- account-wide
		showWelcome = true,
		featureEnabled = false,
		minimap = {},
	},
	profile = { -- per-character
		knownAbilities = {},
	},
}
```

Under Simple, the same keys live in the `profile` subtable, and `global` is absent unless the add-on keeps reset-proof state (SAVED VARIABLES).

Default **item/spell lists** live in the flavor folders (DATA → Flavor Folders) and seed the saved list once, tracked by a saved flag — or, with no flag, whenever the list is missing or empty — and again on Restore Defaults. New default entries reach a settings map (a spell-toggle map) wherever the user never saved that key, but never an existing seeded list; note them in release notes. A settings map is never refilled on empty: one turned entirely off must survive logins, as must a flagged list the player emptied.

### Data File Layout

**A data file opens with its data.** Above each table sit only its legend, one line naming every field, and the Season of Discovery guard where Flavor Folders calls for one. Group dividers inside a table (`-- Arrows`) and each row's trailing name stay. No path line, no notes, no source up top.

**How the data was made goes in one block comment at the end of the file**, titled `How We Got the Data`, under six headings that are always present, in this order. A heading with nothing under it reads `None.`, so a reader knows it was checked rather than forgotten. A file declaring more than one table keeps one block and names the table wherever its notes or query differ. **Only the Data Review lays these files out or edits their comments**; every other pass leaves them alone.

- **Last Validated** — the date the Data Review last applied a Validate Data report from this client to the file, then the client and build from the report header. Without one it reads `Never.`, or `Never. Copied from Data/TBC/.` for a file copied from another folder; a pass line that predates dates keeps its client and build after `Undated`. **In a folder a TOC lists, a date over six months old, or none, is a finding.**
- **Notes** — the most important part, so write it for a person, not a database. Plain-English bullets saying what belongs in the table and why: what the rows have in common, what's left out and why, and what each computed field means and which code reads it. "Quest items that drop in multiples, so the player can end up with a spare after the turn-in," never the flag bits that find them. Hand-picked IDs and the reason they're hand-picked go here too. Notes is never `None.`: a file that arrives without them gets them written from its rows and the code that reads them.
- **SQL (CMaNGOS)** — the real query that pulled the rows, written against the CMaNGOS schema, after a line naming the database it ran against (`classic-db`, `tbc-db`, `wotlk-db`), so the table stays regenerable. Never a reconstruction: a query nobody ran to build these rows is fiction. Without one, the heading holds `TODO: Add SQL Query`, a sanctioned marker that never blocks release.
- **Wowhead** — the URL of every Wowhead listing the rows came from or were checked against. A URL is a pointer, not a regenerable query, so it never stands in for the SQL.
- **wago.tools** — the URL of every wago.tools table the rows came from or were checked against, at the build used: `https://wago.tools/db2/{Table}?build={Client}.{Build}`.
- **QuestieDB** — the URL of every QuestieDB raw table the rows were checked against (Data Review → phase 3).

No source is trusted across flavors: the Anniversary client renumbered items and abilities that a CMaNGOS database still lists under their old IDs. So a query or URL from another flavor's source is a lead, and only a Validate Data report from this client earns a Last Validated date.

```lua
local _, ns = ...

-- [itemId] = { Item Use Level, Next Tier Use Level }, -- Item Name
ns.ALLOWED_DELETE_AMMO = {
	-- Arrows
	[2512] = { 1, 10 }, -- Rough Arrow
	[2515] = { 10, 25 }, -- Sharp Arrow

	-- Bullets
	[2516] = { 1, 10 }, -- Light Shot
}

--[[
How We Got the Data

Last Validated
	2026-10-04, WoW Forever 1.60.1.70205

Notes
	- Every arrow and bullet on this client, leaving out test, monster, deprecated and placeholder items.
	- Item Use Level is the level a hunter can use it. Where the game lists none, it's the item level minus 5, where every other arrow and bullet sits.
	- Next Tier Use Level is the use level of the next vendor arrow or bullet, the level this ammo becomes junk (GetAmmoEraseLevel in Features/Junk-Rules.lua). Ammo with none is never outgrown on this client.
	- The vendor line is hand-listed, because the game data can't tell vendor ammo from crafted or dropped ammo, and only vendor ammo is a replacement every hunter can buy. Arrows: 2512 Rough, 2515 Sharp, 3030 Razor, 11285 Jagged. Bullets: 2516 Light, 2519 Heavy, 3033 Solid, 11284 Accurate.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70205
	https://wago.tools/db2/ItemSparse?build=1.60.1.70205

QuestieDB
	None.
]]
```

Live reference: **Magic Eraser** — any file in `Data/Vanilla/`, `Data/TBC/` or `Data/Camelot/`.

-----

## SAVED VARIABLES

### The Two Models

**Every add-on uses one of exactly two models, and which one is decided by a rule, not a preference — so no pass ever asks.**

| | **Simple** | **Per-Character** |
|---|---|---|
| Profile | One shared `"Default"` profile for every character | One `"Name - Realm"` profile per character |
| Where settings live | `ns.db.profile` by default — settings, mini-map position, welcome toggle, all of it. `ns.db.global` holds only reset-proof state (below). | Presentation and account-wide settings in `ns.db.global`; per-character state in `ns.db.profile` |
| `AceDB:New` third argument | `true` | omitted |
| What Reset Profile clears | Everything on the profile, back to install defaults | That character's profile only; `ns.db.global` is untouched, so account-wide settings survive |
| Reference repo | Come & Get It | Tracking Eye |

**The selection rule: an add-on uses Per-Character if and only if it stores something that genuinely differs from character to character** — which abilities that character knows, a per-character ignore list, that character's own tracked history. State that is *about the character*, not about how the player wants the add-on to behave. An add-on storing nothing of that kind uses Simple. Read the add-on's data and apply the rule; there is no judgment call and nothing to record.

**A setting never goes in `ns.db.profile` under Per-Character just because it could.** If it has no reason to differ per character, it is account-wide — with one coherence rule: a feature's settings live in one scope, so when a feature's state is genuinely per-character (which abilities rotate, class-exclusive toggles), the rest of that feature's settings ride the profile with it rather than splitting the feature across scopes. A key whose effect persists in something every character shares (which General-tab macros exist) stays account-wide regardless, because per-character copies would undo each other. Under Per-Character, presentation — how the add-on presents itself and what it does to the client — is always account-wide, the mini-map position included, so switching or resetting profiles never moves the button. **Under Simple, `ns.db.global` holds only reset-proof state — what a profile switch, copy, reset, or delete must not take from the player:** presentation as just defined, and data the player built or the add-on accumulated (a hand-built list, a lifetime tally). Either scope is correct for those; anything else in `ns.db.global` is a finding, because Reset Profile must be able to restore it.

### Mechanics

- **One account-wide table, managed by AceDB-3.0.** Every add-on declares exactly one SavedVariables global — `AddonNameDB` — and hands it to AceDB. There is no `AddonNameCharDB` and no `SavedVariablesPerCharacter` line: per-character state is an AceDB *profile*, not a second table.
- `Features/Core.lua` creates the database at the **SavedVariables init point** — a name-guarded `ADDON_LOADED` (`if arg1 ~= ADDON_NAME then return end`) or `PLAYER_LOGIN`, never file scope and never `PLAYER_ENTERING_WORLD`, which refires on every loading screen:

    ```lua
    ns.db = LibStub("AceDB-3.0"):New("AddonNameDB", ns.DATABASE_DEFAULTS)       -- Per-Character
    ns.db = LibStub("AceDB-3.0"):New("AddonNameDB", ns.DATABASE_DEFAULTS, true) -- Simple
    ```

- **Defaults come from `ns.DATABASE_DEFAULTS`.** AceDB applies them when a scope is first accessed and handles explicit-`false`-vs-nil correctly. Never hand-merge defaults, and never write `db.field = db.field or default` — the `or` overwrites an explicit `false`.
- **Profile refresh — resets and switches must apply live.** Switching or resetting changes `ns.db.profile` and fires AceDB's callbacks, but only settings read live from the database update on their own; anything applied imperatively (events registered off a toggle, frames shown or hidden, LibDBIcon, applied scales) stays stale until a `/reload`. Right after `AceDB:New`, wire the settings-apply path to the callbacks:

    ```lua
    for _, msg in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
        ns.db.RegisterCallback(ns, msg, "ApplyProfile")
    end
    ```

    `ns:ApplyProfile` re-applies state from the active profile (and, under Per-Character, from `ns.db.global`) and calls `NotifyChange` for each registered panel so open options redraw.
- When the add-on has a mini-map button, its position lives in the `minimap` subtable, scoped as presentation. Pass that subtable directly to LibDBIcon.
- A retired key is nilled explicitly (`ns.db.profile.oldField = nil`) inside the change's migration, so the line is tagged and removed with it (Migration Windows).
- **Persisted derived caches:** when adding a field to a cache's schema, extend the stale-schema guard to nil-test the newest field. Version-stamp invalidation fires only on release bumps, never on same-version dev edits.

### Other-Client Characters

**Every add-on drops characters copied in from another game version, at every load, without a message.** Players copy a WTF folder from one client to another (Era to WoW Forever, say), and every character saved there comes along: other clients' characters show up in per-character lists, carry their settings, and fill the saved file. AceDB keys characters `"Name - Realm"` on realm clients and `"First Last"` on the realm-free ones (WoW Forever), so a saved character key shaped the other way from the one being played (`ns.db.keys.char`) can't belong to this client. Its `char` section and `profileKeys` entry go. Under Per-Character, its own profile (named after it) goes too, unless a character that stays still uses it. AceDB namespaces get the same treatment. Other profiles, `"Default"` included, are never touched.

- **It is not a migration.** A folder can be copied over again at any time, so the prune is permanent and carries no `MIGRATION` tag.
- **It runs right after `AceDB:New`**, before migrations, `ApplyProfile` wiring, or anything that reads `ns.db.sv`.
- **Realm clients can't tell each other apart.** Nothing on the client lists another version's realms, so a `"Name - Realm"` key copied from Era to Anniversary stays. Never guess from realm names.
- **Where the add-on has offline tests** (LUA 5.1 → Offline Tests), it has one test per direction: a Forever load drops a seeded `"Name - Realm"` character, and a realm load drops a seeded `"First Last"` one while keeping a character on another realm.

Use this code as written, in `Features/Core.lua`:

```lua
--[[
    Characters from another game version, dropped without a word. AceDB keys
    a character "Name - Realm" on realm clients and "First Last" on the
    realm-free ones (WoW Forever), so a saved key shaped the other way from
    the one being played came from a copied WTF folder: its char section,
    its profile choice and, unless someone still uses it, its own profile go.
]]
local REALM_KEY_SEPARATOR = " - "

---@param characterKey any
---@param realmClient boolean
---@return boolean
local function IsOtherClientKey(characterKey, realmClient)
	if type(characterKey) ~= "string" then
		return true
	end
	return (characterKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil) ~= realmClient
end

---@param sv table # the saved table, or one of its namespaces
---@param realmClient boolean
---@param profilesInUse table<string, boolean>
---@return nil
local function PruneSavedTable(sv, realmClient, profilesInUse)
	local pruned = {}
	for _, section in ipairs({ "char", "profileKeys" }) do
		local characters = sv[section]
		if type(characters) == "table" then
			for characterKey in pairs(characters) do
				if IsOtherClientKey(characterKey, realmClient) then
					characters[characterKey] = nil
					pruned[characterKey] = true
				end
			end
		end
	end
	if type(sv.profiles) == "table" then
		for characterKey in pairs(pruned) do
			if not profilesInUse[characterKey] then
				sv.profiles[characterKey] = nil
			end
		end
	end
end

---@return nil
local function PruneOtherClientCharacters()
	local currentKey = ns.db.keys and ns.db.keys.char
	local sv = ns.db.sv
	if type(currentKey) ~= "string" or type(sv) ~= "table" then
		return
	end
	local realmClient = currentKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil
	local profilesInUse = { [ns.db.keys.profile or ""] = true }
	for characterKey, profileName in pairs(sv.profileKeys or {}) do
		if not IsOtherClientKey(characterKey, realmClient) then
			profilesInUse[profileName] = true
		end
	end
	PruneSavedTable(sv, realmClient, profilesInUse)
	for _, namespace in pairs(sv.namespaces or {}) do
		if type(namespace) == "table" then
			PruneSavedTable(namespace, realmClient, profilesInUse)
		end
	end
end
```

Call it on the line after `AceDB:New`:

```lua
ns.db = LibStub("AceDB-3.0"):New("AddonNameDB", ns.DATABASE_DEFAULTS, true)
PruneOtherClientCharacters()
```

Live reference: **GogoLoot** — `Features/Core.lua`.

### Migration Windows

**Every change to the shape, name, or scope of saved data ships with its own migration for the data players already have, supported for 30 days.** Everything that exists only to carry what an earlier release saved into the current one — a repair of wrongly saved rows included — is tagged where it sits (code, TOC line, `.luacheckrc` name, test) with `MIGRATION (remove after YYYY-MM-DD)`, dated 30 days past the release that ships it and never re-dated. Inside its window, tagged code may name what the old data names — a legacy `SavedVariables` global, retired keys, retired globals a written macro body still calls, the game IDs of rows to repair — and no other rule is read against those names. Once the date passes, the next pass that touches the add-on deletes everything so tagged. Data players built by hand is never dropped without a bridge.

**A remove-after date expires that one migration, never migrations as a class.** Every new data-structure change gets its own fresh 30-day bridge — no shared cutoff ever means "no migrations from here on."

### Reset

**Canonical rule. Profile reset lives on the Profiles panel and nowhere else:** the General panel carries no reset control, and the Profiles panel adds no separate account-wide reset button. **Reset Profile** is the stock AceDBOptions-3.0 control and resets only the active profile (`ns.db:ResetProfile()`) — what that clears follows from the model, per the table above. Don't hand-roll a profile reset, and don't nil the SavedVariables global directly. Two exceptions: every player-editable text input carries a **Reset** `execute` on its own row that writes that one key's `ns.DATABASE_DEFAULTS` value back and nothing else, and an item list that ships defaults carries **Restore defaults** (Build Reference → Item Lists). Beyond those, no control resets settings Reset Profile can reach; keys it cannot reach return to defaults only through a confirmed `execute` on the panel that owns them, writing their `ns.DATABASE_DEFAULTS` values back and nothing else — added only when requested, never by default, and one already present was requested.

-----

## TOC FILE FORMAT

```
## Title: Full Name
## Notes: The add-on's standard tagline.
## Author: Gogo1951

## IconTexture: Interface/AddOns/AddonFolder/Includes/Images/Icon.tga
## X-License: MIT

## Category-enUS: Category Name
# ...one ## Category-* line per supported locale.

## Interface: 20506
## X-Flavor: TBC
## Version: @project-version@
## X-Curse-Project-ID: ######
## X-Wago-ID: ########

## SavedVariables: AddonNameDB
```

- `Title` is the Full Name (ADD-ON NAMES), as the game's AddOns list shows it.
- **`Interface` and `X-Flavor`** — one number and one flavor name per TOC, shown here for the TBC Anniversary TOC; see Flavor TOCs and Interface Versions below.
- `Notes` is the add-on's standard tagline, matching the README/CurseForge blurb. Single- and multi-sentence taglines are both correct.
- `IconTexture` uses forward slashes and points into `Includes/Images/`.
- **Category** — one per add-on, values copied verbatim from the wiki's canonical list (<https://warcraft.wiki.gg/wiki/Addon_Categories>), as `## Category-enUS:` plus one line per supported locale. Never CurseForge's category names: they look similar but don't match. Which category an add-on gets is the master list's Category column.
- **Release IDs** — every TOC carries `## X-Curse-Project-ID:` (numeric) and `## X-Wago-ID:` (8-character alphanumeric); per-add-on values live in the master list. A missing or placeholder ID is a Prelaunch Blocker.

### File Group Order

```
# Includes
# Exact ordered list lives in REQUIRED LIBRARIES → TOC Include Paths.

# Localization
Locales/enUS.lua
# ...one line per supported locale.

# Data
Data/Flavor.lua
Data/Data.lua
Data/TBC/{Table-Name}-TBC.lua
Data/Default-Settings.lua

# Add-on Name
Features/Core.lua
Features/Utilities.lua
Features/Announcements.lua
Features/{Feature-Name}.lua
Features/Minimap-Button.lua

# Diagnostics
Diagnostics/Diagnostics-Core.lua
Diagnostics/Manifests.lua
Diagnostics/Event-Log.lua
Diagnostics/Code-Reports.lua
Diagnostics/Settings-Reports.lua
Diagnostics/Validate-Data.lua
Diagnostics/Localization-Reports.lua
Diagnostics/Report-Runner.lua

# Options
Options/Options-Utilities.lua
Options/Options-General.lua
Options/Options-{Feature-Name}.lua
Options/Options-Profiles.lua
Options/Options-Feedback-Support.lua
Diagnostics/Options-Diagnostics.lua
Options/Options.lua
```

Group headers are single-hash `#` comments; `##` is reserved for metadata fields the client parses, never a section divider. Localization loads first after Includes — AceLocale must register locales before `Data/Data.lua` calls `GetLocale`. `Data/Flavor.lua` opens the Data block because everything after it may read the flavor. The TOC's own flavor folder follows `Data/Data.lua`, and `Data/Default-Settings.lua` closes the block, since its default lists come from that folder. The add-on section is dependency-first throughout; the Diagnostics panel file loads with the Options block, just before `Options.lua` registers it.

**Merged fragments load dependency-first.** When feature options are composed into the General panel as builder fragments rather than registered as their own panels, those files load *before* `Options-General.lua`.

### Footer

Every TOC ends with the feedback block, same format and link order. CurseForge and Wago live in the README's Setup section, not here. File ends with a newline.

```
# Feedback Welcome! (=
# Add-on Name on GitHub // https://github.com/Gogo1951/Repo-Name
# Add-on Name on Discord // https://discord.gg/eh8hKq992Q
```

### Flavor TOCs

**One TOC per flavor, named by the suffix that client looks for, and never an unsuffixed TOC** — each client loads only its own data folder, and a client the add-on doesn't support never sees it. **A flavor's code name is its Blizzard TOC suffix** (<https://warcraft.wiki.gg/wiki/TOC_format>). Use it unchanged as the TOC suffix, the data folder, the data file suffix, the `## X-Flavor` value, and every `ns` value. Season of Discovery has no Blizzard name, so it is `Discovery`. One word per flavor, Blizzard's own, leaves nothing to translate between a TOC and the files and code it loads, and no two data files share a name.

| Flavor | Client | TOC |
|---|---|---|
| Classic Era | 1.15.x | `_Vanilla.toc` |
| Season of Discovery | the Classic Era client | rides `_Vanilla.toc` |
| TBC Anniversary | 2.5.x | `_TBC.toc` |
| WoW Forever | 1.60.x | `_Camelot.toc` |
| Wrath | no live client | `_Wrath.toc` |
| MoP Classic | 5.5.x | `_Mists.toc` |
| Retail | 12.x | `_Mainline.toc` |

- **Every add-on ships a TOC for every current target** — today Classic Era, **WoW Forever**, and TBC Anniversary. A missing one is a **Blocker** in every pass that reads the TOCs: with no unsuffixed TOC to fall back on, that client never sees the add-on. A Wrath TOC waits for a live Wrath client; a Mists or Mainline TOC ships only where the add-on's master-list entry lists it under **Extra TOCs**; an unlisted one is a finding in every pass that reads the TOCs.
- **The TOCs match line for line except `## Interface`, `## X-Flavor`, each one's data-folder lines (DATA → Flavor Folders), and any feature that flavor cannot run (COMPATIBILITY).**
- Forward-prep for a flavor the add-on ships no TOC for yet (API guards, class tables, its data folder per DATA → Flavor Folders) is deliberate — never flag it or ask about it.

### Interface Versions

**Each TOC declares its own client's current number, and the numbers live in `01 - Local Setup.md` (Session Prep step 1).** One number per TOC: the packager fails the build when a TOC's number doesn't belong to its suffix's client. Numbers in this guide's examples are illustrative snapshots. No pass looks the numbers up externally or asks whether they're stale, and automated interface-version tooling is never added.

-----

## SECTION HEADERS

80-character dashed dividers between logical sections. The section name is the only thing between the two divider lines; explanatory comments go in a separate block below, blank-line separated.

```lua
--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- The event log keeps only the most recent events.

local EVENT_LOG_SIZE = 500
```

-----

## COMMENTS

The house style is **few, sharp comments**. Most code carries none. A comment is a liability — it rots out of sync — so every one has to earn its maintenance cost. When in doubt, delete.

**What earns a comment:** something the code cannot say for itself — a constraint (combat lockdown, the 255-byte chat limit, a `C_Item.GetItemInfo` cold-call nil), a trap that would otherwise be reintroduced, the reason a surprising line is correct, or a maintainer's choice about that code that a review would otherwise undo.

- **Never restate the code.** `-- increment i`, `-- loop over items` — cut them.
- **Never leave commented-out code** or decorative banners. (The dashed dividers under SECTION HEADERS are a sanctioned structural format.)
- **The durable *why*** — a comment explaining the system rather than the line (architecture, data flow, subsystem pitfalls) — stays where it is as one short comment. Step 10 writes it up in full in `README-Technical.md`, from the code; no earlier pass moves it (Pass Preamble → Standing scope). The one exception is a data file's `How We Got the Data` block (DATA → Data File Layout), which explains its table in place.

**Multi-line comments use `--[[ ... ]]`, never a `--` prefix on each line** (it breaks copy/paste, SQL especially). One-liners keep `--`, row legends and trailing notes included.

**Keep comments true.**

- **The code is the source of truth.** When you change code, update or delete every comment describing it in the same edit; when a comment and the code disagree, the comment is the bug — fix or delete it, never the code.
- **State current constraints and contracts, never history.** No "we used to", no "fixed a bug where", no references to code that no longer exists, no session narration. When a past bug must not recur, write the constraint that prevents it — lead with the trap, then the rule.

-----

## TABLE FORMATTING & STYLUA

Run StyLua in write mode, with its default configuration plus `--syntax lua51`, directly on every Lua file outside `Includes/` — the repos ship no `.stylua.toml`, and don't add one. CI checks the result with StyLua 2.5.2 (COMMON-CORE → What CI Enforces). **StyLua's default output is the house format and wins over everything**, including this guide's snippets and any repo file whose whitespace predates it. "Copy verbatim" means the *content*; the formatter owns the whitespace.

**Locally, never run `stylua --check` on the file itself.** It reports a whole-file diff for any file whose line endings differ from its output, so on a normal working copy it produces false failures that have nothing to do with formatting. Compare content only:

```sh
tr -d '\r' < FILE | stylua --syntax lua51 --check -
```

StyLua expands single-line guards and one-line function bodies to full blocks and strips manual alignment everywhere — **never hand-align columns**.

Data arrays carry a column-header comment naming each field on the line above the table, and each row ends with a trailing comment naming its item or spell (shape: DATA → Data File Layout).

-----

## LINTING

Every repo ships a root `.luacheckrc`, identical in shape across add-ons and adjusted only in its name lists. **A clean `luacheck .` run accompanies `luac -p` wherever these docs require it**, and CI runs both on every PR (COMMON-CORE → What CI Enforces) — luacheck catches typo'd global reads, accidental global writes and shadowed locals. CI's `luac5.1` rejects what the client rejects; a newer local `luac` accepts `goto` and `//`, so StyLua's `--syntax lua51` flag is what refuses them on your machine.

```lua
-- .luacheckrc
std = "lua51"
max_line_length = false -- StyLua owns formatting
ignore = { "212/self", "611", "612", "613", "614", "621" } -- implicit self (house ns: methods) + whitespace — StyLua owns the latter
exclude_files = { "Includes/", ".claude/" } -- vendored or session-local, never linted
read_globals = {
	-- every WoW API the add-on reads, explicit
}
globals = {
	-- only what the add-on defines (FILE STRUCTURE's globals bullet): slash command names, binding globals
	SlashCmdList = { fields = { "ADDONNAME" } }, -- a field, so only the add-on's own slash entry is writable
}
```

`read_globals` is every WoW API the add-on reads and never writes; `globals` lists only what the add-on defines, with `SlashCmdList` declared as a field, never as a whole global. A luacheck warning is a finding, never a formatting nit: fix the code, or where one line is legitimately dynamic, annotate that line rather than widening the config.

-----

## LUA 5.1

WoW embeds Lua 5.1, and CI never uses a newer Lua: code or tests that only work on 5.2 or later pass on a newer interpreter and fail in game.

- No `table.unpack` (use `unpack`), `goto`, `//`, bitwise operators, or `io.read("a")` (use `"*a"`).
- `loadfile` has no environment argument; tests set one with `setfenv`.
- `-0` prints as `"-0"`; a test that compares formatted numbers normalizes with `+ 0`.
- `string.format("%s", nil)` raises an error, so test stubs supply every value the code formats.
- `and`/`or` keep only the first return value: `local a, b = X and X:f()` leaves `b` nil without an error. Test first, then call.

### Offline Tests

Optional. The entry point is `Tests/Run.lua`, run from the add-on root with `lua5.1 Tests/Run.lua`; it exits non-zero on any failure, and CI runs it whenever it exists. `.pkgmeta` ignores `Tests`, so it never ships.

-----

## ADD-ON NAMES

**Every add-on has two names, both the maintainer's: a Full Name and a Short Name.** The Short Name may be the Full Name itself: Tracking Eye is both.

|Name|Where it goes|Example|
|---|---|---|
|**Full Name**|Window titles, shaped `Title // Full Name`; the TOC `## Title`; the Options category and root panel; the mini-map tooltip's header; the front of every chat print; anywhere the add-on is talked about: sentences, mandated copy, doc titles and prose|`Restock List // Connoisseur & Restocker`, `Connoisseur & Restocker // Some Message.`|
|**Short Name**|Every other tooltip line that names the add-on, including the header of a block it adds to someone else's tooltip (`Short Name // Title`); the end of every message sent to another player|`{rtN} Some Message // C&R`, `C&R // Inventory Report`|
|**Both**|The README's H1, `Full Name (Short Name)`; the Full Name alone when the two are the same|`# Connoisseur & Restocker (C&R)`, `# Tracking Eye`|

**They live in two locale keys, and nowhere else in code:**

```lua
-- Locales/enUS.lua, and every other locale file, as written
L["ADDON_TITLE"] = "Connoisseur & Restocker" -- Full Name
L["ADDON_SHORT_NAME"] = "C&R" -- Short Name
```

- **Both keys ship in every locale, as written.** The names are proper nouns, never translated, and an add-on whose two names match still defines both.
- **Code never types either name.** Window titles, prints, sent messages and tooltip headers read the key. A window title's key holds only the title part, and the code joins the two: `title:SetText(L["RESTOCK_LIST_TITLE"] .. " // " .. L["ADDON_TITLE"])`. A locale string that names the add-on inside a sentence or label writes the name its slot calls for, as written in every locale: the welcome message's Options path carries the Full Name, a tooltip's `Short Name Options` line the Short Name.
- **Internal identifiers are not names.** The AceLocale name, `ADDON_NAME`, SavedVariables, registry names, the LibDBIcon key and global function and frame names follow NAMING, never either display name.
- **In this guide's templates, `Add-on Name` and `[Add-on Name]` stand for the Full Name.** The Short Name is spelled out wherever it goes.

-----

## NAMING

- **Casing, no abbreviations:** files `Title-Case-Hyphenated.lua` (`Default-Settings.lua`, `Minimap-Button.lua`); functions `PascalCase`; data fixed at load `UPPER_SNAKE_CASE`; runtime state `camelCase` (`ns.db`); names this guide spells itself keep that spelling. `spellId` not `sid`. Locale keys are `UPPER_SNAKE_CASE` matching the feature (`PERSISTENT_TRACKING`), abbreviation-free.
- The technical add-on name comes from the file vararg — `local ADDON_NAME, ns = ...` — never a hardcoded string outside the locale files' `NewLocale` literal. It is never localized; the display names are `L["ADDON_TITLE"]` and `L["ADDON_SHORT_NAME"]` (ADD-ON NAMES).
- **When the brand name differs from the installed folder name, pin one canonical in-Lua identity.** `ADDON_NAME` is the installed folder name (`.pkgmeta`'s `package-as`), which need not be the repo name or CurseForge slug. When the in-Lua identity (AceLocale name, LibDBIcon key, LDB object name) is a shorter brand name, define one constant in `Data/Data.lua` and use it everywhere that identity appears — every `NewLocale()` uses the same literal. APIs keyed off the *packaged* add-on (`C_AddOns.GetAddOnMetadata`, the TOC `Version` token) still take `ADDON_NAME`.

    ```lua
    -- Data/Data.lua — folder: Long-Folder-Name, brand: Brand
    ns.LOCALE_NAME = "Brand"
    ns.L = LibStub("AceLocale-3.0"):GetLocale(ns.LOCALE_NAME)
    ```

- AceConfig registry names live in `ns.OPTIONS_REGISTRY` in `Data/Data.lua`, derived from `ADDON_NAME` (`ADDON_NAME .. "_FeatureName"`). Never build them inline, never localize them. Keys are PascalCase matching the panel's file suffix — `ns.OPTIONS_REGISTRY.General`, `.Profiles`, `.Diagnostics`.
- Event handler functions are named for the event they handle (`BAG_UPDATE` → `OnBagUpdate`), never for what they do.

-----

## COLORS

**Color constants are plain 6-character hex strings** — never the `|cff` escape prefix, which is a display prefix prepended at point of use.

The raw palette is a namespace table so `Features/Utilities.lua` can read it. Every add-on uses this shape; loose `ns.C_*` scalars are not a second option. Elsewhere in this guide, `C_TITLE`, `C_INFO` and the like are role shorthand for the matching `ns.PALETTE` keys.

```lua
-- Data/Data.lua
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names, Field Titles
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
}
```

The derived prefixed table and the `ns.GetColor(key)` accessor live in `Features/Utilities.lua`. `GetColor` returns the prefixed escape string and falls back to `TEXT`; append `|r` at point of use. Every file that uses it and loads after `Features/Utilities.lua` aliases it once — `local GetColor = ns.GetColor`. When tooltip or texture APIs need numeric colors, derive a parallel `COLORS_RGB` table from the same palette rather than repeating literals.

**Class colors** are a separate table, covering classes through Wrath so it stays identical across flavors:

```lua
local CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}
```

Add later classes only if a supported flavor includes them. Item-quality colors (item-link purple is `A335EE`) go in one small table, never loose scalars.

-----

## SPACING SCALE

**Every size and gap the add-on sets in game points is a step on one scale: 2, 4, 8, 16, 32, 64, 128.** Padding, margins, the space between controls, `SetPoint` offsets, row heights, icon and texture sizes, and border insets all take a value from it. A dimension past 128, such as a window's width or height, is a multiple of 16. Each choice is then a step up or down the scale, never a number tuned by eye, and every window spaces the same way.

Three things sit outside it:

- **AceConfig `width` values.** They are fractions of the panel's column, not points; Build Reference → Label-Beside-Control Rows governs them.
- **Geometry fitted to Blizzard's art**, such as Icon Fit's 20-point icon and its offset inside LibDBIcon's ring.
- **A 1-point line or border.**

Existing add-ons move onto the scale through the UX Review's Build choices, never in a sweep.

-----

## LOCALIZATION

- **Locale files other than `enUS.lua` are written only by the Localization Review (`07 - Localization Review.md`), the new-add-on scaffold (`00 - Optional GitHub Cleanup.md`), and a pitch change in `09 - Optional Create README.md`, which retranslates `OPTIONS_DESCRIPTION` alone, and read only by the Prelaunch Review for its own checks.** Every other pass edits and flags `enUS.lua` alone.
- Always localize, even when the only language is English. All user-facing strings go through `L["KEY"]`, never hardcoded.
- **Only our own words are localized.** A game name (a spell, item, skill, zone, class or Blizzard UI label) comes from the client by ID and never enters `Locales/` — see GAME NAMES.
- **Every add-on ships the full supported locale set**, one file per locale code — `esES.lua` and `esMX.lua` are separate files even though the strings are usually identical. The set and order are the master list's Shared constants (`References/Gogo Add-ons Complete List.md`).
- **Keep `enUS.lua` perfect:** every key it defines is referenced by code, every key code references is defined. Rename enUS and every call site together.
- **Never reuse a retired key name.** Other locales keep the old key until the next Localization Review, and AceLocale falls back to enUS only for keys a locale does not define, so the stale translation would silently win.
- Which values may stay English: `07 - Localization Review.md` → When a value may stay English.

### Locale File Pattern

```lua
-- Locales/enUS.lua
local L = LibStub("AceLocale-3.0"):NewLocale("AddonName", "enUS", true)
if not L then
	return
end

L["FEATURE_NAME"] = "Feature Name"

-- Data/Data.lua, first lines; every other file reads ns.L
local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
```

`NewLocale` spells the identity as a string literal — the one place it is written out, since locale files load before anything that could supply it — and `GetLocale` must resolve to the same string: `ADDON_NAME`, or the NAMING constant when the brand differs.

### Reading Locale Files

A script that checks locale files parses whole assignments, never physical lines. StyLua wraps a long value onto its own line and writes a value in single quotes when that avoids escaping; both are authoritative output, never re-flowed or re-quoted. A line-by-line or double-quote-only script under-counts keys, reports false extra keys, and skips placeholder checks on exactly the wrapped strings. Match each assignment with a newline-spanning pattern: `L%["KEY"%]%s*=%s*` followed by a string literal in either delimiter.

-----

## GAME NAMES

**Never translate a game name. Store the ID of the exact record you need and ask the client for its name at load.** The client's name is right in every locale, on every client, with no upkeep. A translation we type in is a guess: it can be wrong on day one, go stale when Blizzard renames something, or differ between clients.

### Match the Record Kind

A spell, a skill line, an item, an aura, a zone and a faction are separate records, each with its own name, and two records that look like one thing can be named differently in some languages. **Before comparing a looked-up name with anything, ask what kind of record the other side shows, then look up that kind.**

> **Why it matters:** First Aid's *spell* (3273) is "Premiers soins" in frFR, but its *skill line* (129), which is what the skill list shows, is "Secourisme". Engineering differs the same way ("Ingénieur" vs "Ingénierie"). enUS, deDE and the rest happen to match, so a spell name searched in the skill list passes testing there and finds nothing in frFR.

|You're matching or showing…|Store|Look it up with|
|---|---|---|
|A spell to cast (`/cast`, spell buttons)|Spell ID|`C_Spell.GetSpellName(spellID)`|
|A spell's rank text|Spell ID|`C_Spell.GetSpellSubtext(spellID)`|
|A profession or skill in the skill list|**Skill line ID**|`C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID)`|
|An item (`/use`, UI rows, chat)|Item ID|`C_Item.GetItemInfo(itemID)`, which can be nil until `GET_ITEM_INFO_RECEIVED`|
|A zone|uiMapID|`C_Map.GetMapInfo(uiMapID).name`|
|A class|Class token (`"MAGE"`)|`UnitClass` / `LOCALIZED_CLASS_NAMES_*`|
|A Blizzard UI label|The GlobalStrings constant|The global itself (`MAINHANDSLOT`, `ITEM_CONJURED`)|

All three clients ship every call in the table (wow-ui-source's API documentation on the `classic_era`, `classic_anniversary` and `forever` branches).

- **Prefer IDs over names when the client gives you IDs.** A name match is a fallback for APIs that return only names (Era's `GetSkillLineInfo`, pet food types, zone text). When an API returns an ID, compare the ID and never look at the name.
- **Locale files hold only our own words:** option labels, tips, messages, and concepts that aren't one game record ("Bread", "Water", "Arrows"). A value that is itself the name of a spell, item, skill, zone, class or Blizzard UI label doesn't belong in `Locales/`; prose that mentions one is our own words.
- **The IDs live in the flavor folders** (DATA → Flavor Folders), usually `Data/{Game}/Game-IDs-{Game}.lua`, even an ID that is the same on every client, such as a skill line. Class tokens aren't IDs; they stay code constants. Name each constant after its record kind: `FIRST_AID_SKILL_LINE_ID`, never `FIRST_AID_ID`.
- **A name in a data row or a trailing comment is an English label for maintainers.** Code never shows it or matches against it.

### Checking a New Lookup

When code compares a looked-up name with something the client shows, check that the two names agree **in every locale on every client** before shipping:

1. Find both records' tables on wago.tools (for example `SpellName.Name_lang` and `SkillLine.DisplayName_lang`).
2. Fetch each client's build in all 11 supported locales (`&locale=frFR`, …). Era and TBC fall back to English for `itIT`, which is expected.
3. Compare byte for byte with a script, not by eye.
4. In game, `/dump` the lookup on at least one client and check it returns what the other side shows.

### Traps

- **Gendered and faction names.** Some class names change with gender in frFR and deDE (`LOCALIZED_CLASS_NAMES_MALE` / `_FEMALE`). Skill lines have a `HordeDisplayName_lang` column, so the Horde name can differ.
- **Macro length.** Translated names are often longer than English ones, so a macro that fits in enUS can pass 255 bytes in another locale. Test against the overflow canary (MESSAGES → Message Length).
- **Items load late.** An item name can be nil on first ask. Show a placeholder (an `L` key such as "Loading ID: %d") and repaint on `GET_ITEM_INFO_RECEIVED`. Never fall back to a translated string.
- **Look-alike records.** A profession's rank spells, its skill line and its trade-skill window can all carry different names. So can an item and the spell it casts.

-----

## TONE AND COPY

### Voice

- Concise, helpful, slightly RPG-flavored but clear. Active voice: "Cycles between…" not "This feature will cycle between…"
- Don't reword existing copy for voice unless specifically asked.
- A mini-map tooltip's feature description leads with what the feature does; a control's `desc` leads with what the control changes. A further sentence or line is only for what the player cannot see for themselves, never a restatement; length alone is never a finding.

### English

- **EN-US, always.** Every English word we write is American English: in-game strings, READMEs, comments, reports and chat. Never British, Australian or Canadian spelling or usage: color, gray, center, favorite, organize, canceled, traveled, defense, armor, catalog, license. A non-American spelling is a typo. The glossary's house spellings still win.
- **Titles and headers are Title Case.** Window titles, panel and tab names, section headers, column headers, tooltip titles and README headings. Capitalize every word except a, an, the, and, but, or, nor, for, so, yet, as, at, by, in, of, off, on, per, to, up and via, which stay lowercase unless they open or close the title. Glossary spellings keep their own case (Add-on, Mini-map). Title Case is English-only: other locales follow their own language's convention for headers.

### In-Game Rendering Rules

These are technical rendering constraints, not English style, so they bind **every string the client renders, in every locale** — the TOC `## Notes:` tagline included, and with it the README pitch paragraph that syncs into it. The no-em-dash and straight-quotes rules also bind the READMEs and pass reports; the rest stop at the client.

- **No em-dashes.** They render badly in the game client's fonts. Rewrite around them: comma, period, hyphen, or the house ` // ` separator. This covers the CJK full-width double dash (——) and the Russian copula dash («X — это Y»).
- **Straight quotes only** (`'` and `"`). Curly quotes render as boxes in some fonts and locales; this covers guillemets («») and CJK corner brackets used as quotes.
- **No bold, no italics, no markdown of any kind.** The client doesn't render it — the symbols leak through as literal characters. Emphasis comes from the color palette.
- **No emojis.** The only pictures in game text are target-marker tokens (`{rt7}`) and texture escapes (`|T...|t`).

-----

## VERSION DISPLAY

Every TOC's `Version` field is always `@project-version@` — never a hardcoded string, in the repo or any dev copy. The packager replaces the token at build time.

Read the version from TOC metadata via `C_AddOns.GetAddOnMetadata`, and store it once as `ns.Version`. **Return `Dev` when the value is missing *or* contains `@`** — `if not version or version:find("@") then return "Dev" end`.

-----

## MESSAGES

Two output contexts: prints to the player carry no target marker and use branded colors, and everything sent to other players shares one format. Every print leads with the Full Name, `L["ADDON_TITLE"]`, and every sent message trails with the Short Name, `L["ADDON_SHORT_NAME"]` (ADD-ON NAMES), never the code identifier. A sent message's body drops its closing period. Bodies always come from `L["KEY"]` — the helpers apply the marker, name, and separator so locale strings stay clean.

| Context | Channel | Format | Example |
|---|---|---|---|
| Print to the player only | `print()` | `Full Name // Message.`, in branded colors | `Connoisseur & Restocker // Some Message.` |
| Message to other players | `WHISPER`, `PARTY`, `RAID`, `INSTANCE_CHAT`, `SAY`, `YELL` | `{rtN} Message // Short Name` | `{rtN} Some Message // C&R` |

### Target Marker

The target marker is one constant in `Data/Data.lua` (`ns.TARGET_MARKER = "{rtN}"`), used on every sent message that carries one. Assigned markers are tracked in the master list's Target marker column — check it before choosing so two add-ons never collide. An add-on defines a marker only when something it sends carries one: player-only prints carry none, nor do mid-fight alerts, whose bodies already carry the mark that matters, and a line drafted into the player's own chat box for them to send is the player's words — no marker, no add-on name, no ` // `.

### Print Outs (Player Only)

Local prints use branded colors: `C_INFO` for the Full Name, `C_SEPARATOR` for the `//`, `C_TEXT` for the body.

```lua
function ns:PrintMessage(message)
	print(
		GetColor("INFO") .. L["ADDON_TITLE"] .. "|r "
			.. GetColor("SEPARATOR") .. "//" .. "|r "
			.. GetColor("TEXT") .. message .. "|r"
	)
end
```

Slash commands inside printed messages are wrapped in `C_INFO`.

### Sent Messages (Other Players)

All cross-player chat routes through one entry point so the marker, name, and separator are handled in one place.

- `ns:BuildAnnounceMessage(formatKey, ...)` formats `ns.L[formatKey]` and returns the finished line **without sending**, so callers can measure length first: the sent format above, or the bare body for a line drafted for the player to send (both per Target Marker).
- `ns:Announce(channel, target, formatKey, ...)` builds and calls `SendChatMessage`. It no-ops on a nil channel **and on a nil message**.
- `ns:GetGroupChatChannel()` resolves `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)` → `IsInRaid()` → `IsInGroup()`, returning `INSTANCE_CHAT` / `RAID` / `PARTY` in that order, and **returns nil when the player is not grouped** — `ns:Announce` then no-ops, so a caller whose message must still land falls back (for example, whispering the relevant player). Pass the channel explicitly for `SAY` or `YELL`.
- **`SAY`, `YELL` and numbered channels need a click or key press behind the send** outside instances. From an event, a timer or login the send is blocked as `ADDON_ACTION_BLOCKED`, which `pcall` doesn't see, so these sends only ever run from the player's own input.

### Pipe Escapes in Sent Chat

Color codes and textures (`|cff`, `|T`) never survive `SendChatMessage`; item links (`|Hitem...`) do. If bodies never carry item links, strip stray pipes defensively (`message:gsub("|", "")`). If they do, don't strip — stripping breaks the links — and say so in a one-line comment on the helper.

### Message Length

- **Chat: 255 bytes.** `SendChatMessage` rejects anything longer. Define it once as `ns.CHAT_MESSAGE_MAX_LENGTH` in `Data/Data.lua`.
- **Add-on messages: 255 bytes, cut silently.** `C_ChatInfo.SendAddonMessage` reports success and delivers only the first 255 bytes, so anything that can grow is split before sending. Its prefix doesn't survive the session: register it again at every login.
- **Macro: 255, unit unconfirmed — measure with `#body` (bytes).** Byte length is never smaller than character length, so a `#body` guard cannot overflow either unit. Never convert an existing `#body` check to a character count.

Because the ceiling is in bytes, **the overflow canary is whichever supported locale encodes widest — usually ruRU.** Test overflow against that locale, not English.

Any message that can carry multiple item links is built as a parts list and split across as many messages as needed: measure via `BuildAnnounceMessage`, pack parts greedily, split only at part boundaries (a link broken mid-escape is rejected), and repeat the format template so every message reads as a complete announcement.

-----

## WELCOME MESSAGE

Every add-on prints a welcome message through `PrintMessage` on every login, on by default. The player who wants it gone turns it off with the toggle the message itself points to. Its copy is **mandated, identical in every add-on** apart from the Full Name:

```lua
L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) are under Options > AddOns > [Add-on Name]. Enjoying this add-on? Tell a friend, Favorite it on CurseForge, or Star it on GitHub. (="
```

The `%s` is `ns.Version`. Replace `[Add-on Name]` with the Full Name when copying into a new add-on — it is baked in literally rather than composed from `L["ADDON_TITLE"]` so it sits inline naturally across translations. Printed, it reads: `Connoisseur & Restocker // Version 2026.10.23.A. Settings (including the option to disable this message) are under Options > AddOns > Connoisseur & Restocker. ...`

`showWelcome` (default `true`) ships in `ns.DATABASE_DEFAULTS` as a presentation key, scoped per SAVED VARIABLES → The Two Models. `PrintWelcome` reads it, returns early when false, and otherwise prints; the General panel's Enable Welcome Message toggle (OPTIONS PANEL → Main Page Layout) binds the same key. **Never gate it on anything else:** no stored version, no first-login or once-per-update check, no saved "already shown" flag. While the toggle is on, it prints at every login.

Live reference: **Magic Eraser** — `L["CHAT_LOADED"]` in `Locales/enUS.lua`.

-----

## MINIMAP BUTTON

Live reference: [Magic-Eraser/Features/Minimap-Button.lua](https://github.com/Gogo1951/Magic-Eraser/blob/main/Features/Minimap-Button.lua).

**Being replaced by a menu.** The UX Review turns this tooltip into a menu, and its click hints and modifier clicks into rows (`02 - UX Review.md` → Menus, Not Tooltips). Once an add-on's menu is built, it follows that section, and the Code Review doesn't flag Tooltip Structure or Click Handlers differences for it.

### Tooltip Structure

```
[TITLE] Full Name (C_TITLE, left)           Version (C_MUTED, right)
[BLANK LINE]
[BLANK LINE]

-- Per feature block: --
[FEATURE NAME] (C_TITLE, left)              [STATE] (C_ON/C_OFF, right)
[DESCRIPTION] (C_BODY, word-wrap, one or more lines)
[KEYBIND] (C_INFO, left)                    [ACTION] (C_INFO, right)
[BLANK LINE]

[Short Name] Options (C_TITLE)
Shift + Middle-Click (C_INFO)
```

The header is the Full Name; every other line naming the add-on uses the Short Name (ADD-ON NAMES). Pairs are `AddDoubleLine`; descriptions pass `true` as `AddLine`'s wrap argument; a blank line is `tooltip:AddLine(" ")`. The options block is always last, with no hint line below it. Never show slash commands in the tooltip.

### Icon Fit

On Camelot and Mainline, LibDBIcon leaves the square icon off-center in its ring; fit it right after `LibDBIcon:Register`, passing `GetMinimapButton` the same key `Register` took (NAMING's pinned constant when the brand differs from the folder):

```lua
if ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline" then
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	if button and button.icon then
		button.icon:SetSize(20, 20)
		button.icon:ClearAllPoints()
		button.icon:SetPoint("CENTER", 1, -0.35)
		local mask = button:CreateMaskTexture()
		mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
end
```

Never call `SetButtonIcon` here: its `ResetButtonIcon` calls `icon:UpdateCoord()`, which errors when another add-on has replaced the button's icon.

### Click Handlers

- **Shift + Middle-Click always opens the options panel** (`ns:OpenOptionsPanel()`). This check runs first in `OnClick`, before any feature buttons.
- Left-Click and Right-Click are the add-on's primary feature interactions — **toggles** for launcher-style buttons (one toggle per tooltip feature block), or **actions** for action-button add-ons (left-click performs the main action, right-click the secondary one). Both shapes are correct; match the add-on's design.
- After a toggle click, re-render the tooltip in place when `GameTooltip:GetOwner()` is still the button, so On/Off state updates live.

-----

## OPTIONS PANEL

Row, sub-row and item-list construction: `References/Style Guide - Build Reference.md` → OPTIONS PANEL.

### Standard Helpers

Defined once in `Options/Options-Utilities.lua` and shared by every panel file. Dot-defined (no `self`), matching the panel builders.

```lua
function ns.OptionsHeader(text, order, hidden)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order, hidden = hidden }
end

function ns.OptionsDesc(text, order)
	return { type = "description", name = text, fontSize = "medium", order = order }
end

function ns.OptionsSpacer(order, hidden)
	return { type = "description", name = " ", order = order, hidden = hidden }
end

function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end
```

Every section header is a real AceConfig `header` — no panel draws its own from a colored description. `ns.OptionsHeader` and `ns.OptionsSpacer` take an optional last `hidden` argument, so a gated section collapses whole.

### Panels and Registration

- Each panel file exposes one builder (`ns.Build{FeatureName}Options`) returning an AceConfig group. Its `name` is `L["ADDON_TITLE"]`, the Full Name (ADD-ON NAMES), for the root panel and a `TAB_*` locale key for a feature panel, or the GlobalStrings constant when the panel is named for a Blizzard UI label (GAME NAMES); the Profiles panel's arrives already localized from AceDBOptions-3.0, and the Diagnostics panel's comes from its strings table.
- `Options/Options.lua` registers every builder against its `ns.OPTIONS_REGISTRY` name and wires `AddToBlizOptions(registryName, name, L["ADDON_TITLE"])` — the third argument must match the root panel's display name exactly.
- **Registration is deferred, never file-scope.** The Profiles builder calls `AceDBOptions:GetOptionsTable(ns.db)`, and `ns.db` doesn't exist until the SavedVariables init point, so file-scope registration crashes on load. Wrap all registration in `ns.RegisterOptionsPanels()` and call it from `Features/Core.lua` immediately after `AceDB:New`.
- **Lists and separate tools get sub-panels.** A list of abilities or items moves off its feature's panel onto a sub-panel of its own, registered with that panel's category ID (the second value its own `AddToBlizOptions` returned) as the parent, since only the root panel resolves by display name; the feature panel keeps the feature's own settings, such as its sound and Example line. A panel holding several separate tools gives each tool a sub-panel, leaving only the settings the tools share on the parent.
- **Child-panel order is fixed:** General (root) → feature panels, each followed by its sub-panels → Profiles → Feedback & Support → Diagnostic Tools last. That order is the order of `AddToBlizOptions` calls.

### Opening the Panel

One entry point opens the add-on's settings **inside the Blizzard Options/Settings interface**, backing both the slash command and the mini-map button's Shift + Middle-Click.

**Route by captured handles, never by name.** `AddToBlizOptions` returns `(frame, categoryID)`. Capture **both** at the root panel's registration and route with captured handles end-to-end: combat gate first, then `Settings.OpenToCategory(<captured categoryID>)`, then `AceConfigDialog:Open` as a genuine last resort that a correctly-routed add-on never reaches. A title lookup — `Settings.GetCategory(<title>)`, or the title passed to `Settings.OpenToCategory` — fails wherever the category ID is a number assigned at registration: execution falls through to `AceConfigDialog:Open` and the panel opens as a standalone floating window instead of docking. It breaks on TBC Anniversary while still working on Classic Era, so it survives testing on one flavor.

```lua
-- inside ns.RegisterOptionsPanels(), at the root panel's registration
local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])
ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID }

function ns:OpenOptionsPanel()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end
	if not ns.optionsFrames then
		return
	end
	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
		return
	end
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.General)
end
```

Live reference: **GogoLoot** — `Options/Options.lua`.

### Combat Guard

**`ns:OpenOptionsPanel` refuses to open during combat and tells the player why.** `InCombatLockdown()` is the function's first statement — one gate in front of the whole routing chain, never inside a single route and never at a call site (the slash handler, the mini-map click). Blizzard's Settings panel is protected in combat; without the gate the player gets an `ADDON_ACTION_BLOCKED` error naming the add-on. The gate prints and returns every time the player asks: it never queues, retries, or registers `PLAYER_REGEN_ENABLED`, because a silent refusal reads as a broken command.

The refusal is a player-only print whose copy is **mandated, identical in every add-on**, used here and nowhere else:

```lua
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."
```

Live reference: **Play It Forward** — `Options/Options.lua`.

### Slash Commands

**Every add-on ships exactly one slash command that opens the Options Interface, and it takes no arguments.** A missing one is an ordinary finding.

The literal is the maintainer's, assigned once per add-on and recorded in the master list's Slash command column — check it before assigning so two add-ons never collide. An add-on may answer to more than one literal for this same command (initials and full-name forms) as `SLASH_ADDONNAME2`, `SLASH_ADDONNAME3`, and so on; every literal is recorded, and `OPTIONS_COMMAND` shows them all, comma-separated in registration order.

**The command's description is mandated copy, identical in every add-on** — `/cmd  Opens the Options Interface for this add-on.` Both halves are locale keys, and the key names carry no add-on abbreviation so every locale file reads the same:

```lua
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/cmd"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."
```

Registration is one function in `Options/Options.lua` that does nothing but call the opener.

```lua
SLASH_ADDONNAME1 = "/cmd"
SlashCmdList["ADDONNAME"] = function()
	ns:OpenOptionsPanel()
end
```

The /Commands section is always present on the root panel, with the options command as its first line:

```lua
spaceCommands0 = ns.OptionsSpacer(90),
headerCommands = ns.OptionsHeader(L["OPTIONS_COMMANDS_HEADER"], 91),
spaceCommands1 = ns.OptionsSpacer(92),
descCommands = ns.OptionsDesc(
	GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
	93
),
```

**Any other slash command exists only by maintainer request** — never generate one, and never verify, flag, or ask about one already present: it was requested. Feature commands stay deliberately untracked (only the options command is recorded); their wiring is still checked, and a broken wire is an ordinary finding. Each one a player types gets its own `ns.OptionsDesc` on its own `L["KEY"]` pair in the /Commands section, separated by an `ns.OptionsSpacer` — never joined into one description with `"\n"`, which renders with no separation. A command that exists for a macro to run is never listed there: players aren't meant to type it.

### Widget Conventions

- Section layout: spacer → header → spacer → desc → spacer → toggle/control → spacer; adjacent sections share the spacer between them.
- Primary toggles: `toggle` with `width = "full"`, except the root panel's Features switches, two to a line.
- Dropdowns: `select` on a label row (Build Reference → Label-Beside-Control Rows).
- Multi-select groups: `group` with `inline = true` containing toggle children.
- Read-only URLs: a label row — `ns.OptionsRowLabel` for the service name, then an `input` with `name = ""`, the remaining row width, and a no-op `set`.
- Destructive actions: `execute`, with `confirm = true` and `confirmText` when what it destroys takes real effort to rebuild (Build Reference → Item Lists has the worked cases).
- Player-managed item lists: the shared builder — see Build Reference → Item Lists.
- Spell rows with icons: toggle, `name = "|T" .. texture .. ":16|t " .. name`.
- Text descriptions: `fontSize = "medium"`; spacers carry none, as `ns.OptionsSpacer` shows. Never `"small"`. Never `SetFont()`.
- **List every class's spells, grouped by class.** One profile can serve every character, so a panel of spells never hides a row behind `IsPlayerSpell`.
- **When every gated section on a panel hides on the same condition, define a local builder that bakes the condition in** rather than repeating the predicate on each widget.

Live reference: **Control Freak** — dropdowns and toggles throughout its panels.

### Helper Text Lives in the Tooltip

**A control explains itself once: in its mouseover tooltip, or on the panel only where the hover already shows an item or spell.** Every toggle and control carries exactly two strings — its label and that one explanation, normally `desc`, which AceConfig renders as the tooltip. Never add a second description line under a control: it multiplies the strings every locale must carry and clutters the panel. Section-level `Desc` blocks (Widget Conventions) and row captions (Build Reference → Label-Beside-Control Rows, Sub-Option Rows) are layout, not helper text. Three on-panel lines aren't helper text either: a key binding row's line saying what the key does (its only control opens the game's Key Bindings list), an Example line showing what a chat-printing feature prints (Example Lines, below), and a status line shown only while the current settings change what a feature does.

Live reference: **Water Dispenser** — the Dispense panel's toggles; **Thanks for the Buff** — the Thank You Button panel's on-panel lines; **Magic Eraser** — its Key Bindings and status lines (`ns.OptionsStatusLine`).

### Example Lines

**Every feature that prints or sends a chat line shows one Example line on its panel, drawn exactly as the line will arrive with the settings the player has chosen.** An Example is one sample line, even when the feature prints several: pick the kind of line the player will see most often, such as a typical line from the body of a longer report, never its title or header. The player should see the finished line, colors, links and marks included, before it happens.

- **The Example follows the selected option.** It is drawn in the form the current setting picks: a Print setting shows the print, an Announce setting shows party chat, and nothing shows a destination the player hasn't chosen. Give it a function `name` so it redraws the moment the dropdown changes. When a feature has several rows with their own dropdowns, the Example follows the row its line belongs to: a line about the player's own cast follows the player's row, a line about someone else's follows the others' row.
- **The label is silver, the line is not.** `L["SAMPLE_EXAMPLE"] = "Example: %s"`, with the label in `C_HELP`. The line inside it carries its own colors. Open `C_HELP` again after the line, for a locale whose label continues past `%s`.
- **Draw the line in the colors of where it goes:**

|Where the line goes|Drawn as|Color|
|---|---|---|
|The player's own window (`print()`)|The exact string the print helper builds: Full Name, separator and body in their branded colors, player names in class colors|Body `C_TEXT`|
|`PARTY`, `RAID` or `INSTANCE_CHAT`|`[Party] [Name]: message`, from the client's `CHAT_PARTY_GET`|`ChatTypeInfo.PARTY`, fallback `AAAAFF`|
|`WHISPER`|`[Name] whispers: message`, from `CHAT_WHISPER_GET`: the line as the person receiving it sees it|`ChatTypeInfo.WHISPER`, fallback `FF80FF`|

  Every group channel is drawn as party chat: party is the one every group has. Read the color from `ChatTypeInfo` so a player who recolored a channel sees their own color.
- **"You" is the character the player is on.** The sender of a party line or whisper, and every place the line names the player, is the current character (`GetUnitName("player")`) in its class color, read when the line is drawn rather than when the panel is built.
- **Everyone else comes from the house roster**, in the class color that goes with the name: **Spek** (Hunter), **Katz** (Priest), **Fathom** (Rogue), **Aero** (Druid), **Prima** (Warrior), **Greasy** (Warlock), **Aiek** (Paladin), **Portalrico** (Mage), **Moondragon** (Shaman). A class with no name of its own borrows one. Pick the class whose ability the line names, so the name, its color and the spell agree. They are proper names, the same in every locale: keep them in `Data/Data.lua` (`ns.SAMPLE_NAMES`, keyed by class token), never in `Locales/`.
- **Bosses come from Molten Core and Blackwing Lair.** Every raider knows them, and a real boss reads as a real alert where "Boss Name" reads as unfinished UI. Their names differ by client, so they live in the locale (`L["SAMPLE_BOSS_*"]`, with a TRANSLATORS note to use the client's exact name).
- **A spell or item is a real link, never a placeholder.** Build it from an ID in the flavor's data: a spell in the client's spell-link blue (`ns.SPELL_LINK_COLOR`, `71D5FF`), an item in its quality color (Item-quality colors, COLORS). The ID is something the feature really handles, such as a quest item for an eraser or a tank's own taunt for a taunt alert. Words like "Item Link", "Example Item" or "Some Spell" never appear. An item's link can be nil on first ask; the function `name` fills it in on the next redraw, the way GAME NAMES → Traps describes for items that load late.
- **A target marker is drawn as the mark.** A sent line carries `{rtN}`, which the receiving client turns into the icon, so the Example swaps the token for its `|T...|t` texture. A line about a mob puts the skull on it, since that is what a real raid does.
- **Re-open the line's color after every `|r`.** A chat frame falls back to the channel's color when a link closes; a panel falls back to white, so tint the line again after each `|r` it holds.
- **Render it through the feature's own builder**, the call that prints or sends the real line (`ns:BuildAnnounceMessage`, the print helper), with the same parts the feature passes. Never hand-copy the text: rewording a message must change its Example too. Game names come from the client by ID.
- **A whisper gets its own Example**, under the toggle that sends it, drawn as the whisper the other player receives.

Live reference: **Control Freak** — `RenderSample` and `AddSample` in `Options/Options-Alert-Section.lua` (all three forms, following each row's dropdown), with `ns.BuildAlertLine` in `Features/Announcements.lua` for the print form.

### Main Page Layout

Page order of the root General panel:

```
Full Name (AceConfig group name = L["ADDON_TITLE"])
Brief Description (L["OPTIONS_DESCRIPTION"] — the pitch-synced string; the key name is house-standard, never abbreviated)
Enable Welcome Message (toggle, default on)
Enable Mini-map Button (toggle, default on — only when the add-on has a mini-map button)
Features (every feature's on/off switch, two to a line, if any)
[Feature Name] (one per feature split into tool sub-panels: each tool's on/off switch, two to a line, hidden while the feature is off)
Key Bindings (if any: one row per binding with its caption, bound key and a Set Key button, then one line saying what the key does)
/Commands (always)
```

**Features never holds a switch for the whole add-on**, such as Enable [Add-on Name]: the game's AddOns list already turns it off. A tool's switch on the root panel binds the same key as the enable toggle on its sub-panel.

The root panel ends at /Commands. The links, the version line and the note asking players to help live on their own panel (Feedback & Support Panel, below).

The **Enable Mini-map Button** toggle reads/writes the `hide` field on the mini-map subtable (inverted for the "Enable" label), calling `LibDBIcon:Refresh(name, subtable)`, which also re-points the button after Reset Profile replaces the subtable.

Live reference: **Magic Eraser** — [`Options/Options-General.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-General.lua), the whole page.

### Feedback & Support Panel

Every add-on registers a **Feedback & Support** child panel, between Profiles and Diagnostic Tools (Panels and Registration). The tree lists it under `L["OPTIONS_FEEDBACK"]`, the name passed to `AddToBlizOptions`; the page's own title, the group's `name`, is `L["OPTIONS_LEVEL_UP_TITLE"]`. Page order:

```
Help [Add-on Name] Level Up (the group name, drawn as the page title)
Seven paragraphs: intro, ways, four bullets (Share Feedback, Tell a Friend, Favorite on CurseForge, Star on GitHub), thanks
Spacer
Feedback & Support Links (header)
Spacer, then Discord; spacer, then CurseForge; spacer, then Wago; spacer, then GitHub (TITLE-colored label beside a read-only URL box, in that order)
Spacer
Copy caption (C_HELP)
Version (C_INFO, order 999, after a full-width blank spacer)
```

Every link row and the copy caption has an `ns.OptionsSpacer` before it. Without them the four URL boxes sit flush against each other and the caption touches the GitHub box. The spacer before the first row is also the one under the header, so the header doesn't get a second one.

**Its copy is mandated, identical in every add-on** apart from the Full Name, baked in literally as in WELCOME MESSAGE. Each paragraph is its own `ns.OptionsDesc` on its own key, separated by an `ns.OptionsSpacer`, never joined with `"\n"`; the bullets are part of the strings:

```lua
L["OPTIONS_LEVEL_UP_TITLE"] = "Help [Add-on Name] Level Up"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"This add-on was built by players who love this game and want to make it as fun as possible for everyone. We'll never ask for donations. The real satisfaction comes from knowing our work makes the game a little better for you. If it does, we'd love to hear about it!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Here are a few ways you can help us reach more players."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Share Feedback: Found a bug or have an idea? Let us know on Discord. Your feedback helps us improve the add-on, and pull requests are always welcome."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Tell a Friend: Know someone who might enjoy this add-on? Tell them about it. Word of mouth helps more players discover great add-ons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorite on CurseForge: Open the CurseForge link below, sign in, and click the star beneath the Download button. Favorites help more players discover the add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star on GitHub: Open the GitHub link below, sign in, and click Star in the top right. Stars help the project qualify for more free developer tools."
L["OPTIONS_LEVEL_UP_THANKS"] = "Thanks for choosing [Add-on Name]!"

L["OPTIONS_FEEDBACK"] = "Feedback & Support"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Feedback & Support Links"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "To copy a link, click its box, then press Ctrl+A and Ctrl+C."
L["OPTIONS_VERSION"] = "Version %s"
```

Translations keep "Star" as GitHub's English button label (the site isn't localized), and Discord, CurseForge, Wago and GitHub stay as written.

The URLs live in `Data/Data.lua` as `ns.LINKS`, values from the add-on's master-list row; the panel file lists the rows and paragraphs as tables and builds from them:

```lua
-- Data/Data.lua
ns.LINKS = {
	CURSEFORGE = "https://www.curseforge.com/wow/addons/magic-eraser",
	GITHUB = "https://github.com/Gogo1951/Magic-Eraser",
	DISCORD = "https://discord.gg/eh8hKq992Q",
	WAGO = "https://addons.wago.io/addons/magic-eraser",
}

-- Options/Options-Feedback-Support.lua: { captionKey, linkKey }, in display order
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}
```

Each link row is `ns.OptionsRowLabel(GetColor("TITLE") .. L[captionKey] .. "|r", order, 0.6)` beside an `input` with `name = ""`, `width = ns.OPTIONS_ROW_WIDTH - 0.6`, a `get` returning `ns.LINKS[linkKey]` and a no-op `set`: the label is one short word and the box holds a full URL, so the row still ends where every other row does.

Live reference: **Magic Eraser** — [`Options/Options-Feedback-Support.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Options/Options-Feedback-Support.lua), its registration in `Options/Options.lua`, `ns.LINKS` in `Data/Data.lua`, and the strings under `-- Options: Feedback & Support Panel` in `Locales/enUS.lua`.

### Profiles Panel

`Options/Options-Profiles.lua` **returns the stock AceDBOptions-3.0 table unmodified** — no additions, no confirm, no extra buttons, no `PROFILES_*` locale keys:

```lua
function ns.BuildProfilesOptions()
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db)
end
```

The stock table already carries the profile picker, **Copy From**, **Delete a Profile**, and **Reset Profile**, wired to `ns.db` and translated in every locale. Switching stays stock: we don't detect context, auto-swap, or add a quick-toggle. Live refresh comes from `ns:ApplyProfile` (SAVED VARIABLES → Mechanics), not from the panel; what a profile holds, what Reset Profile clears, and which scope a setting belongs in are defined in SAVED VARIABLES.

**Shared-table trap — never mutate the returned `args`.** `GetOptionsTable` does not return a private copy; the table is shared by every database and every Ace add-on in the session, so writing to it changes other add-ons' Profiles panels.

-----

## DIAGNOSTIC TOOLS

A standard `Options > [Add-on Name] > Diagnostic Tools` panel **ships in every add-on**. The framework — the runner, the panel, the event buffer, every builder — is copied from Magic Eraser, re-authoring only what Live Reference below lists. What changes per add-on is the *contents* of the manifests the framework reads, scoped strictly to the add-on's real surface:

- **Events** — driven off `ns.EVENT_NAMES`, so the diagnostic set can never drift from what the add-on registers.
- **API calls** — every API COMPATIBILITY routes — called directly as a namespaced API, or reached through a guard or an `ns` accessor — gets a row in `ns.DIAGNOSTIC_API_CHECKS`, plus the load-bearing APIs the core loop depends on. Incidental globals (`print`, `UnitClass`) don't get rows, and an add-on never probes an API it doesn't use. Tests are existence or shape checks only.
- **Saved variables** — the dump targets the add-on's own tables by name and nothing else.
- **Data sources** — every file in the flavor folders gets a row in `ns.DIAGNOSTIC_DATA_SOURCES`, and the Data tab builds one report row per file. The folders share their table names, and each manifest row is labeled by table name, so one manifest serves every flavor, and adding a file to the folders adds its row — the validator can never drift from what the add-on ships.
- **Name lookups** — every game record the add-on names by ID (GAME NAMES) gets a row in `ns.DIAGNOSTIC_NAME_LOOKUPS`, so the Localization tab checks every name a player sees.
- **Plus** whatever spells (`ns.DIAGNOSTIC_SPELLS`), CVars, and bespoke context the add-on actually depends on.

These are not unit tests — WoW's sandboxed Lua has no test framework, so everything here is environment probing and state capture for bug reports. Real logic tests live in the dev toolchain and are documented in `README-Technical.md`.

Report sections, Event Log and Validate Data: `References/Style Guide - Build Reference.md` → DIAGNOSTIC TOOLS.

### Layout

Five tabs (`childGroups = "tab"`) sit under the warning and the enable toggle, four where the add-on ships no data files (Live Reference):

- **Run Tests** holds the live tools, none of which is a report: the Event Log, the Taint Log, an **In-Game Tools** box and an **External Tools** box, each a titled inline group.
- **Settings** holds the add-on's context probes, Saved Variables, Display Context where it applies, and Other Add-ons. **Code** holds Event Registration, API Endpoints and Library Versions. **Data** holds one Validate Data report per data file. **Localization** holds Locale Context, Game Names and, where the add-on sends chat or writes macros, Message Length (Build Reference → DIAGNOSTIC TOOLS → Localization Tab). Each of these tabs has a **Run All** and one row per report, with the report's name and last state on the left, what it covers in silver beneath, and its button on the right. Each has **one** output box showing whatever ran last on that tab: the Report Header once, then a `---- [Report Title] ----` block per report with each report's own header stripped. The copy line is the only text beneath the box: no tab adds a hint or legend under it, the Data tab included.

Reports and tabs come from two manifests, `ns.DIAGNOSTIC_REPORTS` and `ns.DIAGNOSTIC_SECTIONS`, so a new report is a manifest row, not panel code. The runner runs one report at a time, a frame apart, and one run at a time. It disables every run button while a run is going, and **Stop** keeps what finished. A report that throws is written into the box as an error, and the run goes on. Run All is the bulk path; there is no combined all-tabs report.

Rows sit label-left, controls-right, each in an unnamed inline group. A tab's pane is 60px narrower than a plain panel, and a titled box takes another 20px, so rows spend `ns.OPTIONS_ROW_WIDTH` less those insets, with slack.

### Live Reference

Copy Magic Eraser's `Diagnostics/` folder whole. Re-author only what describes this add-on: every manifest table and every builder that reads its features or frames, wherever it lives (`Manifests.lua`, the Settings tab's report list in `Report-Runner.lua`, the event-filter tables and `ns:SuppressUncorrelatedMessage` in `Event-Log.lua`, Display Context in `Settings-Reports.lua`), plus the probe's strings in `Diagnostics-Core.lua`. Saved Variables reads the table name from `ns.SAVED_VARIABLES_NAME` in `Data/Data.lua`. Magic Eraser's probes are **Eraser Context** and **Merchant & Bank Context**, and its Display Context reads the mini-map button; replace them with the state behind this add-on's own "nothing happens" reports.

An add-on with no data files leaves out `Validate-Data.lua`, its TOC line and the Data tab's row in `ns.DIAGNOSTIC_SECTIONS`. Magic Eraser sends no chat, so it has no Message Length report: an add-on that sends chat or writes macros takes Pretty Wide Quest Log's (`ns:BuildMessageLengthReport` in `Localization-Reports.lua`, the `messages` row in `Report-Runner.lua`, and `MESSAGES_TITLE` / `MESSAGES_DESCRIPTION` in `Diagnostics-Core.lua`) and re-authors it.

- [Magic-Eraser/Diagnostics](https://github.com/Gogo1951/Magic-Eraser/tree/main/Diagnostics)
- [Pretty-Wide-Quest-Log/Diagnostics/Localization-Reports.lua](https://github.com/Gogo1951/Pretty-Wide-Quest-Log/blob/main/Diagnostics/Localization-Reports.lua) (Message Length only)

### Strings (Not Localized)

Diagnostics strings stay in the diagnostics files as plain English — developer-facing troubleshooting text is never added to `Locales/` or translated. Define them once in `ns.DiagnosticsStrings`. The one localized string diagnostics reads is `ns.L["ADDON_TITLE"]`.

**The panel's copy is Magic Eraser's, word for word**: the warning, the enable toggle, every tab intro, every shared report's title and description, and the copy line. Only the probes' strings and any line that describes this add-on rather than the panel are re-authored. For example:

```lua
WARNING = "These tools help diagnose problems and are meant for developers. They won't change how the add-on works, but their output includes technical details about your client and installed add-ons. Leave this off unless you're troubleshooting with someone.",
ENABLE = "Enable Diagnostic Tools",
COPY_HINT = "Click in the box, press Ctrl+A to select it all, then Ctrl+C to copy.",
```

Live reference: **Magic Eraser** — the `ns.DiagnosticsStrings` table in [`Diagnostics/Diagnostics-Core.lua`](https://github.com/Gogo1951/Magic-Eraser/blob/main/Diagnostics/Diagnostics-Core.lua).

### Enable Gate

A single toggle gates the whole panel, and it is **runtime-only**. It lives in an in-memory `ns.diagnostics` table, never in SavedVariables, so it starts `false` at every login and nothing persists between sessions. File-scope init is correct for this table; the SavedVariables init rule applies only to SavedVariables.

**Off means off.** When disabled, no event log is allocated, and the dispatcher's logging branch is skipped behind a single boolean check before any allocation or string work. `ns:SetDiagnosticsEnabled(false)` stops logging, stops any run, and clears every report.

When off, only the warning text and the enable toggle show. The tabs are **left out of the table, never hidden**. AceConfigDialog decides whether to draw a tab frame from `hidden` as inherited off the parent, not each tab's own, so hidden tabs leave an empty bordered frame. Register the panel as its builder function, which adds the tabs only while the gate is on, so every repaint rebuilds it.

### Hard Rules

- **Read-only and side-effect free.** Probes never cast, never send chat, and never take a gameplay action; a cache-load request counts as a read. The only writes are the in-memory event log and the `taintLog` CVar via its explicit button.
- **Nothing runs on load or on panel open.** Reports build only on an explicit button press, and results are never saved.

-----

## WRITING USER CVARS

Reading CVars is unrestricted. Writing one changes a game-wide setting the user may not know the add-on owns, so:

- Feature code may write a user CVar only when the CVar is core to the add-on's function (a loot add-on enforcing `autoLootDefault`), or momentarily to silence its own automated action: written around that action and restored within a second to the exact value read. Never as a convenience side effect.
- Write only on an actual change: read the current value first and skip the write when it already matches.
- Every lasting write prints a notice via `PrintMessage` naming the setting and its new state, and `README.md` discloses it. A momentary one prints nothing and gets no README line.
- Every write has an options toggle so the user can opt out, unless the feature it serves cannot work with the CVar left alone.
- Diagnostics' `taintLog` button is user-initiated, not an enforcement, and follows Build Reference → DIAGNOSTIC TOOLS → Taint Log.

-----

## REQUIRED LIBRARIES

**Every add-on ships the TOC Include Paths block down to AceDBOptions-3.0**, wired identically everywhere: same `.pkgmeta` external, same include path, same slot. AceConfig-3.0 is one external; its Registry, Cmd and Dialog sub-libraries ride inside it as subdirectories and are never declared separately.

**Anything else ships only with the capability that needs it**, appended after AceDBOptions-3.0 in this order: a mini-map button takes LibDataBroker-1.1 and LibDBIcon-1.0; a dropdown menu takes LibUIDropDownMenu; a font or sound picker takes LibSharedMedia-3.0. Without the capability, none of it ships: no external, no TOC line, no folder.

- Never use `LibStub("LibName", true)` (the silent flag) for bundled libraries. If it's in Includes, it loads; the silent flag masks load-order bugs.
- `Includes/Libraries/` is vendored third-party code: never edited by hand, never linted, never reviewed. Passes check only its wiring — the TOC include lines, and at Prelaunch the `.pkgmeta` externals.
- Never use WowAce URLs (`repos.wowace.com`, `svn.wowace.com`) — use CurseForge (`repos.curseforge.com`) or GitHub.

### TOC Include Paths

The single source of truth for the `# Includes` block. **The order is fixed and must not be reordered** — `AceConfig-3.0.lua` opens with non-silent requires for AceConfigRegistry-3.0 and AceConfigCmd-3.0, and AceConfigDialog-3.0 needs AceGUI-3.0 already loaded. A wrong order is often masked on a machine running other Ace3 add-ons, so it ships silently and only breaks for users with a minimal add-on set.

```
# Includes
Includes/Libraries/LibStub/LibStub.lua
Includes/Libraries/CallbackHandler-1.0/CallbackHandler-1.0.lua
Includes/Libraries/AceLocale-3.0/AceLocale-3.0.lua
Includes/Libraries/AceDB-3.0/AceDB-3.0.lua
Includes/Libraries/AceGUI-3.0/AceGUI-3.0.xml
Includes/Libraries/AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua
Includes/Libraries/AceConfig-3.0/AceConfigCmd-3.0/AceConfigCmd-3.0.lua
Includes/Libraries/AceConfig-3.0/AceConfigDialog-3.0/AceConfigDialog-3.0.lua
Includes/Libraries/AceConfig-3.0/AceConfig-3.0.lua
Includes/Libraries/AceDBOptions-3.0/AceDBOptions-3.0.lua
Includes/Libraries/LibDataBroker-1.1/LibDataBroker-1.1.lua
Includes/Libraries/LibDBIcon-1.0/LibDBIcon-1.0.lua
```

AceGUI-3.0 loads through its `.xml`. The last two lines ship only with a mini-map button.

### .pkgmeta

**Start from [Thanks-for-the-Buff/.pkgmeta](https://github.com/Gogo1951/Thanks-for-the-Buff/blob/main/.pkgmeta):** set `package-as` and make the externals mirror the TOC Includes block exactly, capability libraries included — a mini-map add-on copies its two externals from [Magic-Eraser/.pkgmeta](https://github.com/Gogo1951/Magic-Eraser/blob/main/.pkgmeta). Everything else is copied verbatim.

- `package-as` is the **installed folder name** inside the published zip — the master list's Folder column and the Lua `ADDON_NAME` vararg. It is not the repo name and not the CurseForge slug.
- `enable-nolib-creation: no` and no `enable-toc-creation`: every add-on ships its libraries in-tree, and the flavor TOCs are hand-written and ship as-is.
- Every folder in `Includes/Libraries/` has an externals entry, and every external is committed; CI fails either gap (COMMON-CORE → What CI Enforces).
- The `ignore:` list keeps dev-repo files out of the player zip: `.DS_Store`, `.git`, `.gitattributes`, `.github`, `.gitignore`, `.idea`, `.luacheckrc`, `.pkgmeta`, `.vscode`, `LICENSE`, `README-Notes.md`, `README-Technical.md`, `README-Testing.md`, `Tests`, and every other dev-only file the repo carries (see REPOSITORY LAYOUT → Dev-only files), plus exactly the `Data/{Game}` folders no TOC lists. A new flavor TOC takes its folder off the list in the same change, or that client installs a TOC whose data never shipped.

-----

## COMMON-CORE

**Every add-on is built on [Common-Core](https://github.com/Gogo1951/Common-Core), which holds the shared CI and release logic for all Gogo add-ons; its README is the source of truth wherever this section and it differ.** Nothing in it ships to players. Its `.github/workflows/package.yml` and `ci.yml` are reusable workflows: add-ons call them and never copy their logic.

- **Shared files.** `addon-files/` holds the files every add-on carries an exact copy of: `.github/workflows/package.yml` and `.github/workflows/ci.yml` (thin callers), `.gitignore` and `.gitattributes`. `scripts/sync-addon-files.sh <add-on folder>` copies them in, and CI fails an add-on whose copy differs. They change only in Common-Core, then get synced to every add-on: never edit one inside an add-on.
- **Per add-on, written by hand:** `.pkgmeta`, `.luacheckrc`, the TOCs, `LICENSE` and the README files.

### What CI Enforces

On every PR and every push to `main`, Common-Core's CI checks that:

1. The shared files match `addon-files/`.
2. Git stores every file with LF line endings.
3. Every folder in `Includes/Libraries/` is listed under `.pkgmeta` externals, and every external is committed.
4. `luac5.1 -p` passes on every Lua file outside `Includes/`.
5. `luacheck .` is clean using the add-on's own `.luacheckrc` (LINTING).
6. `stylua --check --syntax lua51` passes: default config, `Includes/` skipped, StyLua pinned to 2.5.2, no `.stylua.toml`.
7. If `Tests/Run.lua` exists, `lua5.1 Tests/Run.lua` passes (LUA 5.1 → Offline Tests).

### Releases

Push a tag. Common-Core's workflow refreshes `Includes/Libraries/` from `.pkgmeta`, commits that to `main`, moves the tag onto the commit, then uploads to CurseForge and Wago with the `CF_API_KEY` and `WAGO_API_TOKEN` secrets. Never add `GITHUB_OAUTH` or `GITHUB_API_TOKEN`; Common-Core's `package.yml` explains why. The GitHub release's notes are the ones `12 - Create Release Notes & PR.md` drafted, pasted in by hand when tagging. A manual **Run workflow** on "Package and release" in the Actions tab is always a dry run: it builds the zip and uploads nothing.

### Line Endings

**Settled by `.gitattributes` and enforced by CI.** Git normalizes every text file to LF at commit no matter how it arrives, so working-copy line endings carry no information — CRLF, LF, or mixed on disk all commit as LF, and a Mac checkout and a Windows checkout are *supposed* to differ.

**No pass ever inspects, measures, converts, restores, or reports line endings** — not as a finding, not as an observation, not as an aside, not in Guide Feedback. CI's shared-file and LF checks own `.gitattributes` and what git stores. A tool that rewrites line endings as a side effect needs no correction and no mention; run it normally and move on. Never touch a file solely to change its line endings, and never route around a tool to avoid changing them.

-----

## README-NOTES

Each add-on's `README-Notes.md` lists its **exceptions**: the places it departs from a rule in this guide, and nothing else. Every pass reads it before flagging or asking anything. What it lists is settled — don't flag it, re-verify it, propose changing it, or ask about it. A departure it doesn't list is a finding. When it matters (below) and looks deliberate (a comment explains it, or the working tree or recent commits changed it), it is asked about once instead, never reverted on sight. The question asks whether to keep what the add-on does now, never whether to undo the work: keeping it is the `(Recommended)` option unless it will break something, which the question then names. One the maintainer keeps becomes a README-Notes exception, never a fix prompt and never a guide change.

- **Layout.** H1 `# Add-on Name // Notes`, then this line with the name substituted: `> Where Add-on Name departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.` Then `## Exceptions`, holding `None.` until its first entry.
- **Only what matters.** A departure matters when a player would notice the difference, or when following the rule would break something or fight a game constraint. One that doesn't (a name, an order, a helper's shape, a comment's form) is never asked about and never recorded: the Code Review's fix prompt brings it in line with the guide. The Code Review deletes every entry that doesn't matter without asking, and lists their labels in one line.
- **An exception** is `### Short label`, then three one-sentence bullets. **Departs from:** the guide section plus the fewest words that pick out the rule, never a paraphrase of it. **Instead:** what the add-on does, scoped by the reason rather than by the symptoms seen. **Why:** the reason, stated categorically. It names nothing the add-on's code could rename.
- **Nothing else goes here.** A choice the guide leaves open is not an exception: one about code is a comment at that code (COMMENTS), and any other isn't recorded. A declined feature isn't recorded either; a later pass may suggest it again.
- **Legacy `## Decisions`.** A file may still end with a `## Decisions` section from before this rule. Passes treat its entries as settled, and nothing is ever added to it. It empties as each entry finds its home: the Code Review deletes every entry that doesn't matter (above) and moves each choice about code that does into a comment at that code, and the Data Review moves every row left out of a table on purpose into that data file's How We Got the Data Notes. An entry is deleted only once its comment is confirmed in place; UI copy, layout and `Declined:` entries are deleted by the Code Review unrecorded. The heading goes when the section is empty.
- **Every entry stays true.** No status, no removal steps, and no date except an exception's remove-after date in its heading, after which the entry no longer applies. An edit that renames or removes something an entry names updates the entry in the same edit. An entry leaves by deletion, with no tombstone; one the guide has since adopted is no longer a departure and is deleted the same way.
- **The notes file is enough.** An exception records the maintainer's ruling that a departure stays, and the guide doesn't change to match it, however many add-ons carry the same entry.

-----

## ASKING THE MAINTAINER

The single definition of how a pass asks the maintainer anything. The Diagnostics, Data and Localization Reviews never ask: they decide from their evidence and say what they decided.

- **Never ask permission to do the job.** What the prompt or the maintainer already asked for gets done and reported, never confirmed first: no "shall I apply these?", "want me to run it?" or "ready to continue?". A question is only for a genuine choice the record can't settle.
- **Multiple-choice, always.** Tappable options using whatever question tool the surface provides, 2–4 concrete options per question, related questions batched. Fall back to a short numbered list only if the surface has no such tool.
- **Look first, then ask freely.** Check the record before asking: this guide, the add-on's `README-Notes.md`, its master-list entry, and the code. A README is never the record (Pass Preamble → Standing scope). A question one of those answers is a lookup you skipped. For what genuinely isn't recorded, ask as many questions as it takes, across as many rounds as it takes. Never assume.
- **Answerable without reading the code.** Every question states in plain language what the maintainer would observe if this were left alone — the behavior a player hits, or the wrong result a future pass produces. Name symbols and paths only as supporting detail. If a question can't be answered without opening a diff, do the reading yourself and re-ask in terms of consequences. Say what you verified and how.
- **Recommend honestly.** Put your recommendation first and end its label with `(Recommended)`; flag weak items rather than rubber-stamping.
- **Don't re-ask an answered question.** If a tool call fails or a round repeats for mechanical reasons, carry existing answers forward.
- **A modification is an approval.** When the maintainer answers with a modification instead of picking an option, apply their version.
- **Stop and wait.** Nothing proceeds until the answers are in.
- **Record only what a pass would otherwise undo.** An answer that keeps this add-on off a rule, in a way that matters (README-NOTES), is an **exception** and goes straight into its `README-Notes.md`, written by the pass that asked (README-NOTES); a choice about code the guide leaves open goes in a comment at that code, if anywhere; anything else, a declined idea included, isn't recorded. One the maintainer says in so many words applies to every add-on is a **rule** (this guide), and a per-add-on fact such as a link or ID is **data** (the master list); propose those as exact edits in Guide Feedback. Never record the current state of an add-on. If an answer fits none of these, it wasn't durable.

-----

## GUIDE FEEDBACK

How a pass proposes a change to these documents.

**Every pass ends with this section, even when it is empty.** Nothing to propose is the normal outcome — the section is then just the heading, the context stamp, and `No changes proposed.` on its own line, with no venue pointer or triage block.

**Report only what will break.** An item clears the bar only if leaving it unfixed will break the add-on, break the build or release, or make a future pass produce a genuinely wrong result, or if a copy line or reference the guide quotes has gone stale (a moved link, a renamed file, copy the maintainer changed). That is the entire bar. Cuts, wording tweaks, clarity improvements, style preferences, and nice-to-have gaps do not clear it, and neither does anything one add-on does differently: that belongs in its `README-Notes.md`. No pass is rewarded for volume; an empty section is the expected result.

**Keep the guide simple.**

- **Prefer the simpler fix.** Rewriting a closed list as a principle beats appending a member to it. Deleting a rule that keeps getting misread beats adding a clause explaining it. An addition is fine when it is the simplest fix; never move or trim other text just to offset it.
- **Two items, maximum**, counting doc feedback only. If a pass believes it has more, it ranks them and reports the top two. The rest are dropped — not deferred, not listed as "also noted."

**Never report the current state of an add-on as a doc change** — not partially converted, mid-migration, or pending anything. An add-on behind a rule is a code fix in the pass's own report.

**Routine data items ride here too, exempt from the bar and the cap**, because they record a durable per-add-on *fact* rather than criticise the docs: the Prelaunch's row reconciliation, a scaffold's new row, and the like. Give each as its exact proposed edit, ready to apply. A maintainer's rule-change ruling from the pass is doc feedback, asked about on its own at triage, but exempt from the cap.

**Format.** Title the section **Guide Feedback**, with one context-stamp line directly under it: `Generated on [Date] after performing [Pass Name] on [Add-on Name].` Per item: what the doc currently says, what reality is, and the suggested edit. When there is an item, close with this venue pointer on its own line — *Paste the line below into a new session launched in `~/Common-Core`; triage never runs in this code session.* — followed by this block:

```
Triage the Guide Feedback above using Add-on Guide/References/Guide Feedback Triage Prompt.md; edit nothing before I approve.
```
