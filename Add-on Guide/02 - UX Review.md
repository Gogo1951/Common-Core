# WoW Add-on UX Review (Research + Wireframe-First)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the UX Review`. Write scope: **nothing — report only.** No code or add-on file is written in this session, whatever the maintainer approves (Pass Preamble → Report-only passes). The wireframe is an Artifact, never a file in the add-on folder, and feature prompts go in chat.

**Style Guide sections:** read only GLOSSARY, ADD-ON NAMES, SPACING SCALE, TONE AND COPY, MESSAGES, MINIMAP BUTTON, MENUS, MINIMAP MENU, OPTIONS PANEL, ASKING THE MAINTAINER and GUIDE FEEDBACK, not the whole file.

The first review of the cycle: how the add-on looks and reads to a player, and what it could do next. Map every surface, research what similar add-ons offer when asked, then **show it rather than describe it**: a clickable wireframe of every window a change touches, **Current** beside **Proposed**, with each change asked on the page as a multiple-choice question whose every option is drawn as its own example (Wireframe Build → Change cards). The maintainer picks from the wireframe or in chat, each Build comes out as a feature prompt the maintainer pastes back to run, and `03 - Code Review.md` then reviews the code with them in.

**A rule the Style Guide already sets is the Code Review's, never a change here** — except the Spacing Scale, Menus, Not Tooltips, Every Other Menu and Options Panels (below), which move only through this pass's Build choices.

## Workflow: six phases (0–5)

**Phases 0, 1, 3, 4 and 5 always run, and the pass fits in about ten minutes.** The optional parts run only when the maintainer asks for them or says *full*: phase 2's research, drawing windows no change touches, a mock chat box or other simulator, a picker for each class or game version, and the **Try this** lists.

0. **Permissions.** Follow the preamble. The Artifact publish asks for approval, and that prompt is expected: approve it with a plain **Yes**.

1. **Map every surface.** Read the code that draws or prints anything, along with the enUS locale and the `README.md`, until you can say what the add-on does, for whom, and what it deliberately doesn't do. The map covers all of it, and never leaves these out:
    - **The Options interface, every panel and sub-panel**, row by row.
    - **The mini-map button's menu**, or the tooltip it replaces, in each state it can show.
    - **Every window of the add-on's own**, such as a list editor, a picker that opens over it, or a window that opens at a mailbox, bank or merchant.
    - **Every tooltip the add-on adds to or changes**, on players, NPCs, items, spells or anything else, drawn on a realistic example of each with the game's own lines around the add-on's.
    - **Every message sent to another player**, with the box the player words it in (Style Guide → MESSAGES → Editable Messages), or why it stays fixed text.
    - Every menu, popup, chat line, Example line, and first-run or empty state.

    For each, note its layout in game points and every size or gap that is off the Style Guide's Spacing Scale (2, 4, 8, 16, 32, 64, 128), its colors and fonts, its strings in the locale's exact words, and what each control does.

    When the code matches every row of an add-on's spec (`References/Design System/Mini-map Menus/` or `Options Panels/`), list flipping its State to `live` as a routine data item in Guide Feedback.

2. **Research the landscape (optional).** Find what similar add-ons offer that this one doesn't. Search CurseForge, Wago, GitHub and WoWInterface with a separate search for each thing the add-on does, in the words players use (synonyms, slang, the item types it touches, the pain it solves), and search any obvious competitor by name: missing the biggest one is the usual failure. Keep only add-ons on a flavor this one ships, updated within the last 12 months. For each, note the features ours lacks that fit this add-on's scope and the Style Guide. **Ideas only, never code:** never read, copy or adapt another add-on's source, since licenses vary. Take the feature from its listing or README and design it fresh. Clones of Gogo1951's add-ons that turn up are reported in chat per Clones of Gogo1951's Add-ons (below), comment included, before phase 3's questions.

3. **Find the last wireframe, then ask a few broad questions.** List the maintainer's artifacts and look for the title `{Add-on Name} UX Wireframes`. If one exists, read it and any comments on it: it keeps its link across reruns, tester feedback in its comments counts as a candidate below, and a change the last run marked **Try first** comes back as a candidate with whatever testers said about it. Then ask **at most four broad questions, in one round**, about direction, never one per change: who the add-on is mostly for, what players trip over, how bold the redesign may be, how far its scope may grow, anything off-limits. Each is multiple choice with an example per option (Style Guide → ASKING THE MAINTAINER), e.g. *How bold?* `Small polish (Recommended)` — *the same windows, tidier* / `Rework one window` — *the main menu gets a new layout* / `Fresh design` — *every window redrawn*. Skip any the record already answers; zero questions is fine.

4. **Review and draw.** Walk each job a player comes to the add-on for, screen by screen. Look for what a new player can't work out, names that differ for the same thing, controls that don't say what they do, dead ends, empty states that don't point anywhere, copy that explains mechanics instead of outcomes, and spacing off the Spacing Scale. Off-scale values become one *layout* change per window, listing each value and the step it moves to. Each tooltip the add-on draws for its own button or frame becomes one *layout* change to a menu (Menus, Not Tooltips below). Each other menu that misses a check in Every Other Menu (below) becomes one *layout* change per menu. Each options panel that misses a check in Options Panels (below) becomes one *layout* change per panel, listing every miss. Then add the feature ideas: **gap features** from phase 2 when it ran, saying which add-on has each and how popular it looks, and **original ideas** no competitor ships (quality of life, options, messaging, scope extensions; be creative here), each fitting the flavors the add-on ships. **At most 8 changes**, ranked by impact; a rerun in the same release cycle proposes only what testers raised or what is new since the last run. Then build and publish the wireframe per Wireframe Build below, titled `{Add-on Name} UX Wireframes`, with every change drawn into Proposed. Draw only the windows a change touches, and name the rest in the list of what works and stays. Give the maintainer the link, say it stays private until they share it from the page's Share menu, and wait for them to say they've made their choices.

5. **Read the choices and output.** Read the approvals back (Wireframe Build → Approvals). A pick of any option but `Keep as is` is a **Build** and gets a feature prompt (below), written for the option picked. A change ticked **Try first** gets nothing yet, whatever its pick: the page keeps it as an *idea* for testers, and the next run brings it back. `Keep as is` is a **Drop**: left alone and not recorded; a later run may suggest it again. A change with no choice is listed in one line and left alone. A note the maintainer wrote on a card changes that change: write their version into its feature prompt. Choices the maintainer gives in chat count the same as the page's buttons: write each one to `approvals` so a rerun shows it. **A Build is an approval, never a go-ahead to code:** this pass ends with the feature prompts, and nothing is built until the maintainer pastes them back.

## Clones of Gogo1951's Add-ons

Phase 2's research turns up clones too: new add-ons, usually AI-generated, that rebuild one of Gogo1951's add-ons instead of sending it a PR. **A clone goes in chat, never in the README or the wireframe**, so the maintainer can decide whether to leave a comment. Report a clone of this add-on, and of any other Gogo1951 add-on that turns up along the way. Never post, comment or contact anyone yourself.

**What makes a clone:** it does the same job as one of Gogo1951's add-ons, feature for feature, and it appeared after ours. Most also show a name that plays on ours, a small download count, an AI-written description (emoji headers, stacked dashes, generic feature lists), or a new author with nothing else published. A long-standing competitor with its own approach is not a clone, however close it is.

**Report each clone** in one table: add-on, author, link, Total Downloads, created date, a line on why it reads as a clone, and **where a comment can go**. Open the listing to check that: CurseForge comments if the Comments tab is open, else GitHub issues if it links a repo with issues on, else "nowhere to comment". Under the table, print the comment below with its placeholders filled in for the add-on it copies, ready to paste.

> Hey mate! I noticed quite a bit of overlap between your add-on and {Full Name}. I've already built a lot of that functionality, and I'd love to hear what you have in mind for yours.
>
> {CurseForge URL}
>
> Want to work on it together? I'm happy to show you around the code and help you get your ideas into {Full Name}. PRs are always welcome! Come say hi on Discord sometime. I'm always up for talking WoW add-ons or software development. Cheers! (=
>
> https://discord.gg/eh8hKq992Q

## Menus, Not Tooltips

A tooltip the add-on draws on hover over its own mini-map button, arrow or frame becomes a menu: every click hint becomes a row the player clicks, so a controller reaches everything, and the button keeps the click, named on that row. Its feature prompt builds it per Style Guide → MINIMAP MENU → Moving a Tooltip to a Menu.

**When the add-on has a spec** in `References/Design System/Mini-map Menus/{Add-on Name}.md`, that spec is the Proposed menu, and its open GitHub issue is the change: draw it as written, give it one *layout* card that names the issue, and don't redesign it. **Once its State opens with `live`, the work order is done:** the code is the record, reviewed like any other add-on's menu, and what the code has gained since is never a finding or a reason to update the spec. Anything the spec still lists as to do stays the maintainer's.

**Every UX Review checks the menu**, converted or not, and each miss is a change. It checks what a player sees, against Style Guide → MINIMAP MENU: Button Clicks (every click the button had still works and is named on its row; no click hint survives outside an action row), Two Homes for Every Setting (only this character's rows; the options panel keeps every setting), Layout's state words (On / Off, C_MUTED for anything not acting, never red), Features Mirror, Blocks Beyond Features and Placement, and a controller's cursor reaching every row and flyout. How the code behind it is built (One Refresh, Building the Button, row widths) is the Code Review's. More Features, one row opening a flyout with its switches counted On and Off, is the design, not a hidden setting: don't flag it, or ask for its switches back in the main menu.

Lines the add-on adds to the game's own tooltips (items, units, spells) stay tooltip lines.

## Every Other Menu

Every menu the add-on opens that isn't the mini-map menu (a right-click menu, a flyout off a window's line, a dropdown's list in its own window) is checked against everything a player sees in Style Guide → MENUS (One Look, Three Ways to Draw It; The Header; Groups; Rows; Sub-menus; Opening and Closing), and each window's misses become one *layout* change, listing every miss. Draw each with the menu mock files, as the mini-map menu is. The options panel's AceConfig dropdowns are the Settings window's, never a change here.

## Options Panels

Every options panel is built from Options-Kit, the shared kit in Common-Core's `addon-kits/Options-Kit/`, and laid out per Style Guide → OPTIONS PANEL. Its pieces and patterns are drawn in `References/Design System/Options Panels.html` and named in the Design System README → Wave 2: Options Panels.

**When the add-on has a spec** in `References/Design System/Options Panels/{Add-on Name}.md`, that spec is the Proposed panels, and its GitHub issue, once filed, is the change: draw it as written, give it one *layout* card that names the spec, and don't redesign it. Once its State opens with `live`, it is done, as a menu spec is (Menus, Not Tooltips). The add-on's move onto the kit is part of that change; a Build never asks for a helper the kit already has.

**Every UX Review checks the panels**, on the kit or not, against what a player sees in Style Guide → OPTIONS PANEL, and each miss is a change. How the code behind it is built (Options-Kit, One Refresh, registration, `ns.FEATURES`) is the Code Review's.

- **Main Page Layout:** the root page holds its listed rows and nothing else, and Features holds only the switches.
- **Widget Conventions:** the section and field-set layout (every caption in the label column, every control in the control column), hidden versus gray, line colors (headers gold, captions white), Reset rows, sound previews and tree sidebars.
- **Helper Text Lives in the Tooltip** and **Example Lines.**
- **Panels and Registration:** a sub-panel's title names its parent, and it stays in the tree with its silver line while its feature is off.

Profiles (inherited), Feedback & Support (templated) and Diagnostic Tools (its own pass) are checked only for being in the tree, in order; their pages are never a change here.

## Wireframe Build

Shared by this pass and `Optional - Create UX Wireframes.md`. Load the artifact-design skill first, then write one self-contained HTML page in the session's scratchpad directory, never in the add-on folder:

- **Title** as the calling pass names it, written for the testers, who are players: plain language, with no file paths, symbols or code. Material only the maintainer needs stays in chat.
- **Views.** **Current** is what the code does today, and nothing else. **Proposed**, when the pass has changes, is Current plus every change in its recommended option, each numbered on the mock, and a change carried over as Try first wears an *idea* badge. Add a view for each state worth testing on its own, such as an empty list or a first login.
- **Mini-map menus and tooltips** are drawn with `References/Design System/menu-mock.css` and `menu-mock.js`, published as the Artifact's supporting files, with the add-on's real rows written as the Lua writes them, and a mini-map button beside each menu that runs the same clicks (as `Mini-map Menus.html` does).
- **Options panels** are drawn with `References/Design System/options-mock.css` and `options-mock.js`, loaded after the menu mock files and published beside them: the Settings window with the add-on's whole tree (`GO.settings`), each page written as the Lua writes it, through `GO.kit`, which mirrors Options-Kit's calls (as `Options Panels.html` does). Its confirms are drawn in the page, since the viewer refuses `confirm()`.
- **Faithful and clickable.** Draw each window in the game's look: dark panels, gold headings, and quality and class colors, at the sizes the code gives, keeping that dark look in both page themes. Use the locale's strings word for word. Every control does what the code does: toggles, menus, fields, sorting, popups and chat lines in a mock chat box. Hovering shows each tooltip in the add-on's own words. Icons are drawn stand-ins; never copy or hotlink the game's art.
- **On the Spacing Scale.** Proposed draws every size and gap on the Style Guide's Spacing Scale, and the page's own layout uses it too: every padding, margin, gap and radius is 2, 4, 8, 16, 32, 64 or 128 px.
- **Realistic mock data.** Fill every window the way a real player's would look: real item, spell and zone names from the add-on's own data files, in believable amounts for a believable character. Invent the counts and the character names.
- **Every class and variant that looks different.** When a window changes by class, race, faction, level or flavor, show each version that differs, side by side or behind a picker. Classes that look identical share one view that names them all. Skip edge cases that change nothing visible. Never use a real character, account or realm name. Saved variables are read only when the maintainer hands them over in so many words, and only their shape (how many rows, which settings) reaches the page.
- **Change cards.** Below the mock, one card per numbered change, each a multiple-choice question: a title, **why** in a sentence or two (and which competitor has it, for a gap feature), a tag (*layout*, *copy*, *behavior* or *feature*), then 2–4 options with the options on the left and an example beside them. Each option is a version of the change, with the best first marked Recommended and `Keep as is` last where leaving it alone is a real choice (its example is Current). **Every option draws its own example**, as the player would see it and with the same mock pieces as the views: hovering an option shows its example, and clicking picks it. A change with one sensible version still offers it beside `Keep as is`. Clicking a card's title highlights its control in the mock. After the cards, a short list of what works and stays. `References/Design System/Wireframe Starter.html` has the card built.
- **Try this.** Per view, a short list of tasks for testers.
- **Approvals.** Load the artifact-capabilities skill, and declare `db` and `user` with a rule that only the owner writes the `approvals` collection. Each card's option buttons, a **Try first** switch and a note box are shown only to the owner; everyone else sees the cards read-only, and still sees every option's example on hover. A choice writes `approvals/{change-id}` as the picked option's slug, the Try first switch and the note, where the id is a short stable slug for the change, never its number, so a rerun shows a carried-over change's earlier choice. Read them back with the `ArtifactData` tool (`list` on `approvals`), taking only the ids on the current page.

Publish to the existing link if the calling pass found one, otherwise as a new private artifact. Only this pass and `Optional - Create UX Wireframes.md` publish to the `{Add-on Name} UX Wireframes` link. Any other design round publishes its own page titled `{Add-on Name} {Window} Design`.

## Feature prompts

For each **Build**, output one copy-and-run prompt per the preamble's fix-prompt block rules, beginning with `Feature N: short title` on its own line, built to the option the maintainer picked. Each says which files it touches (Style Guide → FILE STRUCTURE), the enUS locale keys it adds (the Localization Review translates them), its options wiring in Options-Kit's calls (`Kit.LabelRow`, `Kit.Example` and the rest, never a hand-rolled helper), any event it adds to `ns.EVENT_NAMES`, and any note the maintainer wrote on its card. The Diagnostics Review covers the new surface in step 4. Order the prompts so dependencies come first, and say when one must run before another. After the last one, end with the Apply question, every run that has a Build (Pass Preamble → Batch apply).

This pass does not audit the docs. If you run into a genuine doc problem, mention it in one line and move on.
