# GOGO ADD-ONS — COMPLETE LIST (DATA SOURCE OF TRUTH)

The single source of truth for per-add-on **facts** — status, names, links, IDs, installed folder, category, target marker, and slash command — across all Gogo1951 add-ons, active and retired. Other docs in this guide reference this file instead of restating these values, so a change lands in one place.

**Keep it accurate.** The Prelaunch Review reconciles the add-on under review against this file and proposes the updates in its Guide Feedback (applied via triage) before any launch (see `08 - Prelaunch Review.md`). When a value here disagrees with a live source, which side wins depends on the field:

- **Release-wired identifiers** — Repo, Folder (`package-as`), `X-Curse-Project-ID`, `X-Wago-ID`, CurseForge/Wago slugs and links: the live source (TOC, `.pkgmeta`, CurseForge, Wago, GitHub) wins — fix this file and note it.
- **Editorial fields** — Status, Category, target markers and slash commands: **this file wins** — fix the live TOC or listing to match.

## Active and retired

Every add-on is **Active** or **Retired**, shown in the Status column below. Check it before doing anything with an add-on. A retired add-on is often rolled into an Active one, and its Status then names that add-on (`Retired → Good to Go`).

- **Active** add-ons are maintained. Passes, sweeps, issues and live references all draw from them.
- **Retired** add-ons get **no work of any kind** unless the maintainer names that add-on and asks for it: no passes, no new issues, no Guide Feedback, and never a live reference or template. A task "for every add-on" means every Active add-on. Leave retired add-ons out and say so in one line.
- **Work on a merged add-on's features goes to the add-on it merged into.** A request, bug or idea about Open Sesame's auto-opening is GogoLoot work, filed and built in GogoLoot.
- **Retired rows stay in this file** so a session recognizes them on sight, and so their names, slash commands and target markers aren't reused while players still have them installed. A retired add-on that predates this guide carries only what its listing and TOC show, with `—` for the rest.
- **The guide still points at a retired add-on?** Treat it as a finding: propose an Active add-on in its place, in Guide Feedback.

## Shared constants (identical across every add-on)

- **Author:** `Gogo1951`
- **License:** MIT
- **Discord:** <https://discord.gg/eh8hKq992Q>
- **Supported locales (set & order):** `enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW`

## Quick reference

Full GitHub, CurseForge, and Wago links are in the per-add-on detail below. CurseForge and Wago slugs are irregular for several add-ons (some carry `-revisited` / `-classic` suffixes, and Wago and CurseForge sometimes differ), so treat the detail links as authoritative rather than deriving a slug from the name.

**Folder** is the installed folder name in `Interface/AddOns` — identical to `.pkgmeta`'s `package-as` and the Lua `ADDON_NAME` vararg, and the folder Claude Code sessions launch in for that add-on (see `01 - Local Setup.md`). It differs from the repo name for several add-ons (taken-over add-ons keep their original folder), so never derive folder from repo or vice versa.

| Add-on | Status | Short Name | Repo | Folder | X-Curse-Project-ID | X-Wago-ID | Category (enUS) | Target marker | Slash command |
|---|---|---|---|---|---|---|---|---|---|
| Come & Get It | Retired → Tracking Eye | Come & Get It | `Come-and-Get-It` | `ComeAndGetIt` | `1128926` | `QN537vKB` | Other | — (plain player-voice line, no marker) | `/cgi` |
| Connoisseur & Restocker | Retired → Good to Go | C&R | `Connoisseur-Restocker` | `Consumable-Connoisseur` | `1416865` | `aN0XyQNj` | Buffs & Debuffs | — (player-only) | `/foodie` |
| Control Freak | Active | Control Freak | `Control-Freak` | `Control-Freak` | `1401345` | `mNw73LNo` | Combat | — (urgent combat notifications, no marker) | `/freak` |
| GDKPd | Retired | GDKPd | `GDKPd-Classic` | `GDKPd` | `397856` | — | — | — | `/gdkpd`, `/gdkp` |
| GogoLoot | Active | GogoLoot | `GogoLoot` | `GogoLoot` | `423347` | `qGYZ3ONg` | Loot | `{rt4}` Triangle | `/gogo` |
| Good to Go | Active | GtG | `Good-to-Go` | `Good-to-Go` | `1782775` | `mKOa1PNx` | Buffs & Debuffs | `{rt1}` Star | `/gtg` |
| Groupie | Retired | Groupie | `Groupie` | `Groupie` | `661450` | — | — | — | `/groupie` |
| Magic Eraser | Active | Magic Eraser | `Magic-Eraser` | `MagicEraser` | `1146812` | `aNebBj62` | Inventory | — (player-only) | `/eraser` |
| Open Sesame | Retired → GogoLoot | Open Sesame | `Open-Sesame` | `Open-Sesame` | `830638` | `b6mvgDKP` | Inventory | — (player-only) | `/os` |
| Play It Forward | Active | PIF | `Play-It-Forward` | `Play-It-Forward` | `1617425` | `kGryrxKy` | Other | — (player-only) | `/pif` |
| Pretty Wide Quest Log | Active | PWQL | `Pretty-Wide-Quest-Log` | `Pretty-Wide-Quest-Log` | `1732686` | `Q6aqkj6W` | Quests | `{rt3}` Diamond | `/pwql` |
| Thanks for the Buff | Active | TFTB | `Thanks-for-the-Buff` | `TFTB` | `1140285` | `5NR8PeK3` | Buffs & Debuffs | `{rt1}` Star | `/tftb` |
| Tracking Eye | Active | Tracking Eye | `Tracking-Eye` | `TrackingEye` | `1129680` | `qGZOMXNd` | Professions | — (plain player-voice line, no marker) | `/te` |
| Water Dispenser | Active | Water Dispenser | `Water-Dispenser` | `Water-Dispenser` | `1531217` | `vNAgAgKo` | Other | `{rt6}` Square | `/wd` |

**Markers and slash commands.** The Target marker and Slash command columns are the collision registers; their rules are Style Guide → MESSAGES → Target Marker and OPTIONS PANEL → Slash Commands.

## What an add-on's entry may contain

An entry carries its links, plus these bullet classes and **nothing else**:

- **Identity note** — release-wired facts about how an add-on's brand, repo, folder, and slugs relate, where they don't all match. These exist because deriving one from another produces a broken link or a nil locale.
- **Retired note** — on a Retired add-on only: which Active add-on it was rolled into (matching its Status), what moved there, and anything a session needs to know about the move, so a player question about it gets the right answer.
- **Extra TOCs** — the flavor TOCs beyond the current targets that the maintainer approved for this add-on, as `Mists`. Only the maintainer's say-so adds one: a pass that finds an unlisted extra TOC reports it as a finding, never as a row update.

Anything else does not belong here. Where one add-on departs from the Style Guide goes in its `README-Notes.md` (Style Guide → README-NOTES); how far along an add-on is goes nowhere. (Retired is not a progress note: it decides whether the add-on gets work at all, so it lives in the Status column.)

## Per-add-on detail

### Come & Get It
- **GitHub:** <https://github.com/Gogo1951/Come-and-Get-It>
- **CurseForge:** <https://www.curseforge.com/wow/addons/come-get-it>
- **Wago:** <https://addons.wago.io/addons/come-and-get-it>
- **Retired note:** rolled into Tracking Eye, which carries its features now.
- **Identity note:** "Come & Get It" (with the ampersand) is the correct title everywhere it's displayed. The repo (`Come-and-Get-It`), folder (`ComeAndGetIt`), and slugs keep their release-wired spellings.

### Connoisseur & Restocker
- **GitHub:** <https://github.com/Gogo1951/Connoisseur-Restocker>
- **CurseForge:** <https://www.curseforge.com/wow/addons/connoisseur-restocker>
- **Wago:** <https://addons.wago.io/addons/connoisseur>
- **Retired note:** rolled into Good to Go, mostly a rename. Good to Go lists it in `ns.REPLACED_ADDONS` (`Data/Data.lua`) and imports its saved data, and C&R's final release tells players to switch.
- **Identity note:** Brand name `Connoisseur & Restocker`; GitHub repo `Connoisseur-Restocker`; packaged folder is `Consumable-Connoisseur`; CurseForge slug is `connoisseur-restocker`; Wago slug is `connoisseur`. The in-Lua identity constant stays `Connoisseur` (see Style Guide → NAMING → canonical in-Lua identity).

### Control Freak
- **GitHub:** <https://github.com/Gogo1951/Control-Freak>
- **CurseForge:** <https://www.curseforge.com/wow/addons/control-freak>
- **Wago:** <https://addons.wago.io/addons/control-freak>

### GDKPd
- **GitHub:** <https://github.com/Gogo1951/GDKPd-Classic>
- **CurseForge:** <https://www.curseforge.com/wow/addons/gdkpdclassic>
- **Retired note:** retired before this guide existed and never built on it; not rolled into another add-on.
- **Identity note:** brand and folder `GDKPd`, repo `GDKPd-Classic`, CurseForge slug `gdkpdclassic`.

### GogoLoot
- **GitHub:** <https://github.com/Gogo1951/GogoLoot>
- **CurseForge:** <https://www.curseforge.com/wow/addons/gogoloot>
- **Wago:** <https://addons.wago.io/addons/gogoloot>
- **Extra TOCs:** Mists

### Good to Go
- **GitHub:** <https://github.com/Gogo1951/Good-to-Go>
- **CurseForge:** <https://www.curseforge.com/wow/addons/good-to-go>
- **Wago:** <https://addons.wago.io/addons/good-to-go>
- **Extra TOCs:** Mists

### Groupie
- **GitHub:** <https://github.com/Gogo1951/Groupie>
- **CurseForge:** <https://www.curseforge.com/wow/addons/groupie>
- **Retired note:** retired before this guide existed and never built on it; not rolled into another add-on.

### Magic Eraser
- **GitHub:** <https://github.com/Gogo1951/Magic-Eraser>
- **CurseForge:** <https://www.curseforge.com/wow/addons/magic-eraser>
- **Wago:** <https://addons.wago.io/addons/magic-eraser>

### Open Sesame
- **GitHub:** <https://github.com/Gogo1951/Open-Sesame>
- **CurseForge:** <https://www.curseforge.com/wow/addons/open-sesame>
- **Wago:** <https://addons.wago.io/addons/open-sesame>
- **Retired note:** rolled into GogoLoot, whose Automated Opening carries its auto-opening now.

### Play It Forward
- **GitHub:** <https://github.com/Gogo1951/Play-It-Forward>
- **CurseForge:** <https://www.curseforge.com/wow/addons/play-it-forward>
- **Wago:** <https://addons.wago.io/addons/play-it-forward>
- **Extra TOCs:** Mists

### Pretty Wide Quest Log
- **GitHub:** <https://github.com/Gogo1951/Pretty-Wide-Quest-Log>
- **CurseForge:** <https://www.curseforge.com/wow/addons/pretty-wide-quest-log>
- **Wago:** <https://addons.wago.io/addons/pretty-wide-quest-log>
- **Extra TOCs:** Mists

### Thanks for the Buff
- **GitHub:** <https://github.com/Gogo1951/Thanks-for-the-Buff>
- **CurseForge:** <https://www.curseforge.com/wow/addons/thanks-for-the-buff-revisited>
- **Wago:** <https://addons.wago.io/addons/thanks-for-the-buff>
- **Identity note:** repo `Thanks-for-the-Buff`, folder `TFTB`, CurseForge slug `thanks-for-the-buff-revisited`, Wago slug `thanks-for-the-buff` — all four differ, so never derive one from another.
- **Extra TOCs:** Mists

### Tracking Eye
- **GitHub:** <https://github.com/Gogo1951/Tracking-Eye>
- **CurseForge:** <https://www.curseforge.com/wow/addons/tracking-eye-revisited>
- **Wago:** <https://addons.wago.io/addons/tracking-eye>
- **Identity note:** brand `Tracking Eye`, repo `Tracking-Eye`, folder `TrackingEye`, CurseForge slug `tracking-eye-revisited`, Wago slug `tracking-eye` — never derive one from another. The bare `tracking-eye` CurseForge slug belongs to LindenRyuujin's abandoned predecessor, which is still live, so a guessed slug resolves to a different add-on rather than 404ing.
- **Extra TOCs:** Mists

### Water Dispenser
- **GitHub:** <https://github.com/Gogo1951/Water-Dispenser>
- **CurseForge:** <https://www.curseforge.com/wow/addons/water-dispenser-revisited>
- **Wago:** <https://addons.wago.io/addons/water-dispenser>
