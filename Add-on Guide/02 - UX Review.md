# WoW Add-on UX Review (Research + Wireframe-First)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the UX Review`. Write scope: **nothing, unless the maintainer says to build (phase 5). The wireframe is an Artifact, never a file in the add-on folder, and feature prompts go in chat.**

**Style Guide sections:** read only GLOSSARY, ADD-ON NAMES, SPACING SCALE, TONE AND COPY, MESSAGES, MINIMAP BUTTON, MINIMAP MENU, OPTIONS PANEL, ASKING THE MAINTAINER and GUIDE FEEDBACK, not the whole file.

The first review of the cycle: how the add-on looks and reads to a player, and what it could do next. Map every surface, research what similar add-ons offer when asked, then **show it rather than describe it**: a clickable wireframe of every window a change touches, **Current** beside **Proposed**, with each change's reason written on the page and its **Build** / **Try first** / **Drop** buttons beside it. The maintainer approves from the wireframe or in chat, each Build comes out as a feature prompt or is built in this session when the maintainer says to build, and `03 - Code Review.md` then reviews the code with them in.

**A rule the Style Guide already sets is the Code Review's, never a change here** — except the Spacing Scale and Menus, Not Tooltips (below), which move only through this pass's Build choices.

## Workflow: six phases (0–5)

**Phases 0, 1, 3, 4 and 5 always run, and the pass fits in about ten minutes.** The optional parts run only when the maintainer asks for them or says *full*: phase 2's research, drawing windows no change touches, a mock chat box or other simulator, a picker for each class or game version, and the **Try this** lists.

0. **Permissions.** Follow the preamble. The Artifact publish asks for approval, and that prompt is expected: approve it with a plain **Yes**.

1. **Map every surface.** Read the code that draws or prints anything, along with the enUS locale and the `README.md`, until you can say what the add-on does, for whom, and what it deliberately doesn't do. The map covers all of it, and never leaves these out:
    - **The Options interface, every panel and sub-panel**, row by row.
    - **The mini-map button's menu**, or the tooltip it replaces, in each state it can show.
    - **Every window of the add-on's own**, such as a list editor, a picker that opens over it, or a window that opens at a mailbox, bank or merchant.
    - **Every tooltip the add-on adds to or changes**, on players, NPCs, items, spells or anything else, drawn on a realistic example of each with the game's own lines around the add-on's.
    - Every menu, popup, chat line, Example line, and first-run or empty state.

    For each, note its layout in game points and every size or gap that is off the Style Guide's Spacing Scale (2, 4, 8, 16, 32, 64, 128), its colors and fonts, its strings in the locale's exact words, and what each control does.

2. **Research the landscape (optional).** Find what similar add-ons offer that this one doesn't, the way `09 - Optional Create README.md` → Related Add-ons searches: start from the README's Related Add-ons list, search beyond it with that section's broad search, and keep only add-ons on a flavor this one ships, updated within the last 12 months. Look hardest for well-known competitors the list misses. For each, note the features ours lacks that fit this add-on's scope and the Style Guide. **Ideas only, never code:** never read, copy or adapt another add-on's source, since licenses vary. Take the feature from its listing or README and design it fresh. Clones of Gogo1951's add-ons that turn up are reported in chat the way that section's Clones of Gogo1951's Add-ons says, comment included, before phase 3's questions.

3. **Find the last wireframe, then ask a few broad questions.** List the maintainer's artifacts and look for the title `{Add-on Name} UX Wireframes`. If one exists, read it and any comments on it: it keeps its link across reruns, tester feedback in its comments counts as a candidate below, and a change the last run marked **Try first** comes back as a candidate with whatever testers said about it. Then ask **at most four broad questions, in one round**, about direction, never one per change: who the add-on is mostly for, what players trip over, how bold the redesign may be, how far its scope may grow, anything off-limits. Skip any the record already answers; zero questions is fine.

4. **Review and draw.** Walk each job a player comes to the add-on for, screen by screen. Look for what a new player can't work out, names that differ for the same thing, controls that don't say what they do, dead ends, empty states that don't point anywhere, copy that explains mechanics instead of outcomes, and spacing off the Spacing Scale. Off-scale values become one *layout* change per window, listing each value and the step it moves to. Each tooltip the add-on draws for its own button or frame becomes one *layout* change to a menu (Menus, Not Tooltips below). Then add the feature ideas: **gap features** from phase 2 when it ran, saying which add-on has each and how popular it looks, and **original ideas** no competitor ships (quality of life, options, messaging, scope extensions; be creative here), each fitting the flavors the add-on ships. Rank everything by impact, then build and publish the wireframe per Wireframe Build below, titled `{Add-on Name} UX Wireframes`, with every change drawn into Proposed. Draw only the windows a change touches, and name the rest in the list of what works and stays. Give the maintainer the link, say it stays private until they share it from the page's Share menu, and wait for them to say they've made their choices.

5. **Read the choices and output.** Read the approvals back (Wireframe Build → Approvals). Each **Build** gets a feature prompt (below). **Try first** gets nothing yet: the page keeps it as an *idea* for testers, and the next run brings it back. Each **Drop** is left alone and not recorded; a later run may suggest it again. A change with no choice is listed in one line and left alone. A note the maintainer wrote on a card changes that change: apply their version. Choices the maintainer gives in chat count the same as the page's buttons: write each one to `approvals` so a rerun shows it. When the maintainer says to build, run the Builds in this session instead of printing feature prompts, in the order below, and after each run `stylua --syntax lua51`, `luac -p` and luacheck on the changed files, stopping to report if one fails.

## Menus, Not Tooltips

A tooltip the add-on draws on hover over its own mini-map button, arrow or frame becomes a menu: every click hint and modifier click becomes a row the player clicks, so a controller reaches everything. Build it per Style Guide → MINIMAP MENU, which holds the layout, the look, the character-level rule (the menu shows only what this character can use; the options panel keeps every setting) and the steps to move a tooltip over.

Lines the add-on adds to the game's own tooltips (items, units, spells) stay tooltip lines.

## Wireframe Build

Shared by this pass and `Optional - Create UX Wireframes.md`. Load the artifact-design skill first, then write one self-contained HTML page in the session's scratchpad directory, never in the add-on folder:

- **Title** as the calling pass names it, written for the testers, who are players: plain language, with no file paths, symbols or code. Material only the maintainer needs stays in chat.
- **Views.** **Current** is what the code does today, and nothing else. **Proposed**, when the pass has changes, is Current plus every change, each numbered on the mock, and a change carried over as Try first wears an *idea* badge. Add a view for each state worth testing on its own, such as an empty list or a first login.
- **Faithful and clickable.** Draw each window in the game's look: dark panels, gold headings, and quality and class colors, at the sizes the code gives, keeping that dark look in both page themes. Use the locale's strings word for word. Every control does what the code does: toggles, menus, fields, sorting, popups and chat lines in a mock chat box. Hovering shows each tooltip in the add-on's own words. Icons are drawn stand-ins; never copy or hotlink the game's art.
- **On the Spacing Scale.** Proposed draws every size and gap on the Style Guide's Spacing Scale, and the page's own layout uses it too: every padding, margin, gap and radius is 2, 4, 8, 16, 32, 64 or 128 px.
- **Realistic mock data.** Fill every window the way a real player's would look: real item, spell and zone names from the add-on's own data files, in believable amounts for a believable character. Invent the counts and the character names.
- **Every class and variant that looks different.** When a window changes by class, race, faction, level or flavor, show each version that differs, side by side or behind a picker. Classes that look identical share one view that names them all. Skip edge cases that change nothing visible. Never use a real character, account or realm name. Saved variables are read only when the maintainer hands them over in so many words, and only their shape (how many rows, which settings) reaches the page.
- **Change cards.** Below the mock, one card per numbered change: what the player sees, **why** in a sentence or two (and which competitor has it, for a gap feature), and a tag (*layout*, *copy*, *behavior* or *feature*). Clicking a card highlights its control in the mock. After the cards, a short list of what works and stays.
- **Try this.** Per view, a short list of tasks for testers.
- **Approvals.** Load the artifact-capabilities skill, and declare `db` and `user` with a rule that only the owner writes the `approvals` collection. Each card carries **Build**, **Try first** and **Drop** buttons and a note box, shown only to the owner; everyone else sees the cards read-only. A choice writes `approvals/{change-id}`, where the id is a short stable slug for the change, never its number, so a rerun shows a carried-over change's earlier choice. Read them back with the `ArtifactData` tool (`list` on `approvals`), taking only the ids on the current page.

Publish to the existing link if the calling pass found one, otherwise as a new private artifact.

## Feature prompts

Unless the maintainer said to build (phase 5), for each **Build** output one copy-and-run prompt per the preamble's fix-prompt block rules, beginning with `Feature N: short title` on its own line. Each says which files it touches (Style Guide → FILE STRUCTURE), the enUS locale keys it adds (the Localization Review translates them), its options wiring, any event it adds to `ns.EVENT_NAMES`, and any note the maintainer wrote on its card. The Diagnostics Review covers the new surface in step 4. Order the prompts so dependencies come first, and say when one must run before another.

This pass does not audit the docs. If you run into a genuine doc problem, mention it in one line and move on.
