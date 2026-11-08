# WoW Add-on README Generation (Editing, `README.md`)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `README generation`. Write scope: **`README.md` only** — plus `.claude/README-Infographic.svg` (Infographic), and the pitch-sync surfaces (every TOC's `## Notes` and `OPTIONS_DESCRIPTION` in every locale) when the pitch changes.

**This prompt is the request.** Pasted on its own, it means: run the whole pass now and regenerate the launch folder's `README.md` by the rules below. Never ask whether to run it or how much of it; the only questions are Phase 2's.

The user-facing companion to `README-Technical.md`: description, TL;DR, showcase, setup, features, and tips & tricks. This is what someone reads on CurseForge or GitHub before installing; technical detail stays out (What Doesn't Belong Here).

## Workflow — five phases (0–4), all required

0. **Read** — the preamble's Read first list, then the add-on's `README.md` (the local file is the raw source; Session Prep pulled it from `main`), its TOCs, `Locales/enUS.lua`, and enough of the code to know what a player gets.
1. **Research** — the Related Add-ons candidates (section 9), and from them the search vocabulary for the pitch.
2. **Clarify** — only what the record doesn't answer (Style Guide → ASKING THE MAINTAINER). A better pitch over an already-synced one is asked here, as a proposal (Sync duty). An empty phase is normal.
3. **Write** — `README.md` in the section order below, the pitch last; the infographic when the Showcase has none; every copy of the pitch when it changed.
4. **Report** — a few lines in chat: what changed, the infographic to convert and upload if one was drawn, and the pitch surfaces rewritten, if any. Then Guide Feedback.

## Voice & Tone

**Marketing, not technical.** Written for a player browsing CurseForge or GitHub who is deciding whether to install. Every section sells the benefits, why they'd want to use it, and spares the details: nothing about how it works under the hood, nothing they don't need to make that call. Friendly, direct, lightly playful. WoW slang welcome.

**High level, and short.** Say what it does for the player, never how or when: "Cleans trash out of your bags," not the thresholds and conditions behind it. Leave out edge cases, settings and exceptions; the options' tooltips and `README-Technical.md` carry those. Sell the outcome, and what a player misses out on without it. Write the draft, then cut about a third before showing it.

**Show, don't tell.** Players skim. Anything the infographic, a table, or a screenshot already says gets no prose of its own.

## Naming & Formatting

- **Full Name and Short Name** — the add-on's two names, and where each goes: Style Guide → ADD-ON NAMES. The README talks about the add-on by its Full Name.
- **Long Name** — CurseForge title and SEO metadata only; never appears in the README body. Format: `Full Name // Descriptive Subtitle`. Example: `Connoisseur & Restocker // Automatically use Your Best Food, Water, Healthstone, Potions, Bandages, Scrolls, Poisons, & Pet Food`.
- **Separator** — ` // ` is the separator throughout (between feature title and benefit, in the status lines, in Special Thanks bullets). Em dashes and en dashes are never used, in any slot or sentence; the title-to-benefit slot is always ` // `. Hyphens are fine everywhere, including the pitch — "auto-loot" is correct, not a violation.

## Image Handling

**The README carries one image: the Showcase's, under the TL;DR.** Copy its tag from the existing README **verbatim**. Each tag is an opaque string — paste it character for character, no rewriting. URL, alt text, width, height, align, and every other attribute stay exactly as they appear. When the Showcase has no image, move the existing screenshot that best shows the add-on at work there; every other image tag, an Options screenshot included, is dropped. You never rewrite *what* the tag says.

**Don't translate between formats.** `<img>` stays `<img>`. `![alt](url)` stays `![alt](url)`. Going from `<img>` to markdown silently drops width, height, and align attributes, so the image renders at full size and the README looks broken — that's a bug, not a cleanup. The rule applies even when the source has no size attributes, even when the URL looks weird, tokenized, or expired.

**Concrete example.** If the existing README has this line:

```html
<img width="360" src="https://github.com/user-attachments/assets/48e86839-798f-4086-82d1-bcf9c23dc1eb" />
```

Then the new README has the same line. Not paraphrased, not re-flowed, not "cleaned up," not converted to markdown.

**Always work from raw source.** GitHub's rendered preview shows JWT-proxied URLs that look totally different from the markdown source — longer paths, expiring tokens, the works. Use the "Raw" button on GitHub or `raw.githubusercontent.com/<user>/<repo>/main/README.md`. If only the rendered version is available, ask for the raw file — don't reconstruct the tag from what's visible.

**If no media URL is provided in the input, omit the image line entirely.** Don't fabricate URLs, don't leave placeholder stubs, don't invent alt text for an image that doesn't exist.

## Required Sections (in order)

### 1. Title

H1, `Full Name (Short Name)`: `# Connoisseur & Restocker (C&R)`. When the two names are the same, the name alone: `# Tracking Eye`. That's it.

### 2. Description

One to three sentences, **255 characters max**, written to be found in CurseForge search: lead with what the add-on is, in the words players type into the search box, then list what it covers (Control Freak: "Combat announcer for taunts, interrupts, fears, tank deaths, bad pets..."). Never names the add-on; selling the *why* is the TL;DR's job. Plain prose only — no markdown (no bold, no links, no headers) and no em-dashes (use a comma, period, or ` // `): this summary syncs to the in-game `OPTIONS_DESCRIPTION` and every TOC's `## Notes`, where the Style Guide's In-Game Rendering Rules bind it and symbols leak through as literal characters.

**Build this last.** The pitch is the #1 discovery surface — most users find the add-on through CurseForge or Google search, so this slot has to earn its keep on SEO. It's the most important 255 characters in the whole README.

**TL;DR line.** Directly under the pitch, a `**TL;DR:**` label (colon inside the bold) and one or two short sentences: the elevator pitch of *why* you'd use it, in benefits to the player. No BS, no fluff. README-only (it syncs nowhere), written fresh rather than restating the pitch, free of the add-on's name, and bound only by the no-em-dash and straight-quotes rules.

**Showcase.** Directly under the TL;DR, before Setup, the README always shows the add-on at work:

- **One image** — the infographic (Infographic, below) or a screenshot (Image Handling). Never more than one.
- **Up to five example messages**, when the add-on prints or sends chat lines: under an `### Example Messages` heading right below the image, its best few, each its own blockquote with a blank line between them. The bold label names what triggers the line, a comma, then where it lands: `**Self:**` is a print to the player's own window, `**Party:**` or `**Raid:**` a group announcement, `**Message To {Name}:**` a whisper; prefix `🔊 & ` when the line also plays a sound. The text is the line as the game shows it, with links as `[Name]` and names from the house roster (Style Guide → Example Lines):

```markdown
### Example Messages

> **Hearth Home After Raid, 🔊 & Self:** Connoisseur & Restocker // Don't forget to restock while you're in town!

> **Ready Check, Self:** Connoisseur & Restocker // Missing Items : Healthstone, Mana Potion
```

With neither an image nor a chat line to show, write one or two sentences on the moment it saves the player. Never skip it: a README with nothing here is broken.

**Sync duty:** when the pitch changes, the same pass rewrites every copy of it: `## Notes` in every TOC (the flavor TOCs match line for line), enUS `OPTIONS_DESCRIPTION`, and `OPTIONS_DESCRIPTION` in every other locale, translated fresh from the new English per `07 - Localization Review.md` and the In-Game Rendering Rules. No locale keeps the old pitch. **When an existing pitch is already synced across those surfaces, treat SEO improvements as a proposal to the maintainer, not an automatic edit** — the cascade cost (up to fourteen surfaces, including ten translations) outranks a marginal keyword gain. Rewrite a synced pitch only on the maintainer's say-so.

**SEO rules:**

- Pack in terms users actually search for. Pull these from the Related Add-ons list — read their titles, descriptions, and tags, and steal the vocabulary that recurs.
- Cover the obvious nouns *and* their synonyms (e.g., "tracking," "minimap tracking," "find herbs," "find ore," "gathering").
- **Do not name WoW flavors** (Classic, SoD, Forever, Anniversary, Cata Classic, MoP Classic, Retail) in the pitch — not even "Works with Classic and Anniversary." That information lives in Testing & Localization Status, and only there. The pitch sells value; flavor support is metadata.
- Avoid author-commentary framing like "A smarter X for Y." Lead with what users search for, not with editorializing.

**Infographic.** Where the add-on's value fits in a picture, and it nearly always does, this pass draws one for the Showcase. When an image tag already sits under the TL;DR and the maintainer hasn't asked for a new one, keep it verbatim and draw nothing.

- **Style** — copy `References/Canonical Files/Infographic Template.svg` (the Magic Eraser infographic) and keep everything its comment says to keep: canvas, colors, fonts, card frames, number badges, arrows, caption boxes. Swap only titles, pictures, and caption text. Never invent a new look.
- **Story** — three cards, left to right: the moment the player hits the problem, the one action (or none, when it's automatic), the payoff. Titles are two to four words. Caption boxes hold either the add-on's real chat line, in the colors the game draws it (Style Guide → Example Lines: a print in its branded colors, a sent line in its channel's, links in theirs), or a big green result with one short gray line under it. Two cards is fine when the story has two beats; never more than three.
- **Words** — a dozen or so per card, all in the titles and captions. The picture carries the rest.
- **Captions** — lay out every caption the template's way: one centered `<text>` per line, a literal space wherever two colored pieces meet on a line (SVG draws adjacent `<tspan>`s with no gap, so `[Taunt]on` and `Aeroused` happen), and the words exactly as the game prints them. Break lines at phrase boundaries with lengths roughly even: the add-on name keeps its ` // `, and a link, a name and its verb, or a short phrase like "was resisted" never splits across lines. Before showing it, measure each caption line in the browser pane (`getBBox().width`, under the box width minus 40) and zoom in to check every space.
- **Pictures** — flat, simple shapes built from the template's pieces (bag slots, mini-map button, cursor, sparkles). Never Blizzard art, icons, or screenshots pasted in.
- **Output** — write it to `.claude/README-Infographic.svg` (gitignored, so it never ships or commits), open it in the browser pane to check it renders, and show it to the maintainer. The maintainer converts it to PNG and uploads it; this pass never fabricates the URL. Until the maintainer pastes back the `<img width="800" src="..." />` tag, the Showcase goes without an image.

### 3. `## Setup`

Numbered list, 4-6 steps.

- Step 1 is always Install (plain text, not bolded) with **both** the CurseForge and Wago links inline — e.g. *Install the add-on, ideally using [CurseForge](URL) or [Wago](URL).* Pull both URLs from the master list (`References/Gogo Add-ons Complete List.md`).
- When the add-on has options, step 2 opens them: the slash command, and the mini-map click when there is a button (Control Freak: *Type `/freak`, or Shift + Middle-Click the mini-map button, to open the Options Interface.*). This is the README's one mention of a slash command.
- Last step is a short, funny outcome line in the user's voice, italicised with underscores and in straight quotes (`_"..."_`): a play on a movie line or meme, themed to what the add-on actually does. Examples:
  - GogoLoot // _"Zug zug your way to record Naxx clears."_
  - Magic Eraser // _"But wait, there's more bag space!"_
  - Connoisseur // _"Luck favors the prepared, darling."_
  - Tracking Eye // _"All your nodes are belong to us."_
  - Water Dispenser // _"You had me at H₂O."_
- Don't reuse a line across add-ons; if the themes overlap, the outcome still shouldn't.

### 4. `## Features`

**Five entries at most**, the 🦺 Safety First entry included. The best reasons to install, not an inventory — you get no points for using more screen space. Don't make 5 points when 3 would do.

**Format:** emoji + `**Bold Feature Name**` + ` // ` + a short benefit of one or two short sentences, never a run-on. **Each line is 250 characters at most**, counted as written, emoji and markup included (`wc -m`). No leading list marker — each line starts with the emoji itself, never `-` or `*`. The ` // ` slot is fixed.

The section header says "Features" but the focus is **benefits to the user**.

A feature qualifies when it's a distinct reason to install that the pitch doesn't already cover. Common bloat:

- Restating the pitch as a bullet.
- Splitting one capability into two to reach five.

If a bullet's benefit can't stand alone without leaning on the bullet next to it, merge or cut.

**Do not list localization as a feature** — it belongs in Testing & Localization Status, and only there.

**Optional:** a 🦺 **Safety First** entry is great when the add-on touches inventory, chat, or anything destructive. Not mandatory.

> Example: 🦺 **Safety First** // Never touches quest items, BoP gear, recipes, mounts, pets, or legendaries.

### 5. `## Tips & Tricks`

The few things a player is glad to have read after installing, and nothing else. Short, with tables and bullets over paragraphs. No Options panel list, settings inventory or slash command list (the options' tooltips carry those), and nothing that retells Features or the infographic.

- **`### Mini-Map Button`** (whenever the add-on has one) — the click-action table, plus one line on what hovering it shows, if anything.
- **A game setting the add-on writes** (a CVar) — always disclosed here, so then the section is never skipped (Style Guide → WRITING USER CVARS).
- Beyond those, **at most two** sub-sections worth a player's time: a why-it-works-this-way story (Control Freak's "Every Alert Works the Same Way"), Macros Created, or a class-specific callout.

Skip the section when none of these applies.

### 6. `## Testing & Localization Status`

Every flavor line, newest game at the top, Season of Discovery on its own line since its item data diverges meaningfully from regular Classic. The version strings are **hardcoded** — paste them verbatim; they're bumped with the interface targets in `01 - Local Setup.md`.

Per-add-on, change **only** the colored status emoji. The template's emojis are defaults for a *new* file — **when regenerating over an existing README, preserve its per-flavor emojis**, never downgrading a 🟡 the author set.

**Status legend:**

- 🟢 Works, Fully Tested
- 🟡 Likely Works, Partially Tested
- 🔴 Likely Won't Work, No Testing

**Section template (paste this, change only the emojis):**

> 🔴 World of Warcraft // 12.1.0
>
> 🔴 Mists of Pandaria Classic // 5.5.4
>
> 🟢 Burning Crusade Anniversary // 2.5.6
>
> 🟢 World of Warcraft: Forever // 1.60.1
>
> 🟡 World of Warcraft: Season of Discovery // 1.15.9
>
> 🟢 World of Warcraft: Classic // 1.15.9
>
> **Available Locales** // enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

The locale list matches the master list's Shared constants — the source of truth for the set. Don't extend or trim it based on the testing matrix.

### 7. `## Appreciation & History` (optional)

History first, then Special Thanks. Include a block only when it has entries, and skip the whole section when neither does — never an empty heading. Every lead line is canonical: use it verbatim, never reword. No additional prose.

**History** — the ancestry. Pick the one lead line that is true:

> 👾 **I didn't create this add-on, I just updated it.**

when Gogo1951 took over someone else's add-on, or

> 🚀 **This add-on stands on the shoulders of those that came before.**

when Gogo1951 rolled prior add-ons, WeakAuras, or an absorbed subsystem into this one. Then the ancestors:

> * {Ancestor Author Name}'s [{Ancestor Add-On Name}]({URL})

**Special Thanks** — testers, translators, and anyone who played a key role. Names come from the existing README or the maintainer, never invented; no one to thank means no sub-section. Bold name, ` // `, then a sentence in the maintainer's voice on what they did:

> ### Special Thanks
>
> * **{Name}** // {What they did, as a full sentence.}

### 8. `## Get Involved`

Always present, verbatim except the GitHub URL. CurseForge and Wago live in Setup, so they're not repeated here.

> ❤️ **You can help make this better!** Feedback, code contributions, testing, and localization assistance are always appreciated. If you'd like to get involved, please reach out.
>
> * [GitHub]({URL})
> * [Discord](https://discord.gg/eh8hKq992Q)

### 9. `## Related Add-ons`

Research add-ons that overlap with this one. Search broadly — aim to surface **15-20 candidates** — then cut to the cap below before writing.

**Cap: 5 entries per status color.** Selection order within each color:

1. **Gogo1951's own add-ons first.** They always make the cut when they genuinely belong in that color.
2. **Then highest usage.** Read the Total Downloads figure off each candidate's CurseForge listing and keep the biggest. Downloads are the tiebreaker — not your read of which is the closest competitor, and not a desire to cover one of each feature. A candidate with no CurseForge listing has no figure to read and ranks below every candidate that has one.
3. **Fewer than five is fine.** A color with three honest entries stays at three; never pad to the cap.

**Don't list anything that already appears in History.** History is the ancestry chain (forks, predecessors); Related Add-ons is the current competitive landscape. Different lists, no overlap.

**Where to look:**

- CurseForge — search the relevant category and the add-on's keywords.
- GitHub — search by topic tag (e.g., `wow-addon`, `wow-classic`) and by feature name.
- The "See also" / "Related" sections on the top 2-3 results from above.
- WoWInterface — older add-ons that never moved to CurseForge live here.

**Search broadly.** Don't just search the add-on's name. For each distinct thing the add-on does, run a *separate* search using user-facing terms — synonyms, slang, item types it touches, pain points it solves. An auto-clam-opener should turn up under "clam," "auto open," "lockbox," "container," and any well-known competitor name in that niche (e.g., "clam pulp"). If you can think of an obvious competitor and it's not in your results, search for it directly by name. **Missing the biggest competitor is the most common failure mode in this section.**

**Filter to flavors the add-on actually supports.** Every entry must run on at least one client the add-on ships a TOC for; add-ons for other clients are noise, not research. Read each candidate's supported clients before adding it.

**Filter to add-ons still alive: updated within the last 12 months.** Read the Updated date and supported game versions straight off each candidate's CurseForge listing before adding it. An add-on last touched years ago isn't part of the current landscape — recommending it sends readers to something likely broken. If a famous-but-abandoned competitor feels essential context, it belongs in History (if it's an ancestor) or nowhere.

This list also feeds the SEO step for the pitch summary — once candidates are surfaced, scan their titles and descriptions for the vocabulary the pitch should adopt.

**Take each URL from the listing's canonical link or address bar, never from the add-on's current title.** CurseForge slugs freeze at the original title and often no longer resemble it — a guessed slug that happens to render today (via a redirect) is a link that breaks silently later. Copy the real slug from the page you are actually on.

**Format:** one `###` sub-section per color in the order below, skipping any color with no entries. Inside each, one `*` bullet per add-on, alphabetical by add-on name. Escape Markdown characters in author names (`enshadowed\_`).

> ### 🟢 Pairs With
>
> * oscarucb's [RaidBuffStatus](https://www.curseforge.com/wow/addons/raidbuffstatus)
>
> ### 🟡 Overlaps
>
> * Galeina's [Consumable Checker](https://www.curseforge.com/wow/addons/consumable-checker)
>
> ### 🔴 Alternatives
>
> * ollidiemaus's [Auto Potion](https://www.curseforge.com/wow/addons/auto-potion)

## What Doesn't Belong Here

- Technical details — SavedVariables, APIs, architecture, file maps, character limits, contributing rules. All of that lives in `README-Technical.md`.
- Speculation, "TODO" notes, or upcoming features that aren't shipped. This document describes what the add-on does today.
