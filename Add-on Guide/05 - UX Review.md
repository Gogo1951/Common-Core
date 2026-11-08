# WoW Add-on UX Review (Wireframe-First)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the UX Review`. Write scope: **nothing. The wireframe is an Artifact, never a file in the add-on folder, and feature prompts go in chat.**

Review how the add-on looks and reads to a player, then **show it rather than describe it**: a clickable wireframe of every window, **Current** beside **Proposed**, with each change's reason written on the page and its **Build** / **Try first** / **Drop** buttons beside it. The maintainer approves from the wireframe, and each Build comes out as a feature prompt.

## Workflow: five phases (0–4), all required

0. **Permissions.** Follow the preamble. The Artifact publish asks for approval, and that prompt is expected: approve it with a plain **Yes**.

1. **Map every surface.** Read the code that draws or prints anything, along with the enUS locale and the `README.md`. The wireframe covers all of it, and never leaves these out:
    - **The Options interface, every panel and sub-panel**, row by row.
    - **The mini-map button's tooltip**, in each state it can show.
    - **Every window of the add-on's own**, such as a list editor, a picker that opens over it, or a window that opens at a mailbox, bank or merchant.
    - **Every tooltip the add-on adds to or changes**, on players, NPCs, items, spells or anything else, drawn on a realistic example of each with the game's own lines around the add-on's.
    - Every menu, popup, chat line, and first-run or empty state.
    - **Every Example line**, checked against the Style Guide's Example Lines rules: it follows the selected option, names the current character, uses roster names and MC or BWL bosses, real spell and item links and the colors of the chat it goes to, and draws the mark as an icon.

    For each, note its layout in game points and every size or gap that is off the Style Guide's Spacing Scale (2, 4, 8, 16, 32, 64, 128), its colors and fonts, its strings in the locale's exact words, and what each control does.

2. **Find the last wireframe, then ask a few broad questions.** List the maintainer's artifacts and look for the title `{Add-on Name} UX Wireframes`. If one exists, read it and any comments on it: it keeps its link across reruns, tester feedback in its comments counts as a candidate below, and a change the last run marked **Try first** comes back as a candidate with whatever testers said about it. Then ask **at most four broad questions, in one round**, about direction, never one per change: who the add-on is mostly for, what players trip over, how bold the redesign may be, anything off-limits. Skip any the record already answers; zero questions is fine.

3. **Review and draw.** Walk each job a player comes to the add-on for, screen by screen. Look for what a new player can't work out, names that differ for the same thing, controls that don't say what they do, dead ends, empty states that don't point anywhere, copy that explains mechanics instead of outcomes, and spacing off the Spacing Scale. Off-scale values become one *layout* change per window, listing each value and the step it moves to. Rank the rest by impact, then build and publish the wireframe per Wireframe Build below, with every change drawn into Proposed. Give the maintainer the link, say it stays private until they share it from the page's Share menu, and wait for them to say they've made their choices.

4. **Read the choices and output.** Read the approvals back (Wireframe Build → Approvals). Each **Build** gets a feature prompt (below). **Try first** gets nothing yet: the page keeps it as an *idea* for testers, and the next run brings it back. Each **Drop** is left alone and not recorded; a later run may suggest it again. A change with no choice is listed in one line and left alone. A note the maintainer wrote on a card changes that change: apply their version.

## Wireframe Build

Shared by this pass, `Optional - Create UX Wireframes.md` and `Optional - Research & Feedback.md`. Load the artifact-design skill first, then write one self-contained HTML page in the session's scratchpad directory, never in the add-on folder:

- **Title** as the calling pass names it, written for the testers, who are players: plain language, with no file paths, symbols or code. Material only the maintainer needs stays in chat.
- **Views.** **Current** is what the code does today, and nothing else. **Proposed**, when the pass has changes, is Current plus every change, each numbered on the mock, and a change carried over as Try first wears an *idea* badge. Add a view for each state worth testing on its own, such as an empty list or a first login.
- **Faithful and clickable.** Draw each window in the game's look: dark panels, gold headings, and quality and class colors, at the sizes the code gives, keeping that dark look in both page themes. Use the locale's strings word for word. Every control does what the code does: toggles, menus, fields, sorting, popups and chat lines in a mock chat box. Hovering shows each tooltip in the add-on's own words. Icons are drawn stand-ins; never copy or hotlink the game's art.
- **On the Spacing Scale.** Proposed draws every size and gap on the Style Guide's Spacing Scale, and the page's own layout uses it too: every padding, margin, gap and radius is 2, 4, 8, 16, 32, 64 or 128 px.
- **Realistic mock data.** Fill every window the way a real player's would look: real item, spell and zone names from the add-on's own data files, in believable amounts for a believable character. Invent the counts and the character names.
- **Every class and variant that looks different.** When a window changes by class, race, faction, level or flavor, show each version that differs, side by side or behind a picker. Classes that look identical share one view that names them all. Skip edge cases that change nothing visible. Never use a real character, account or realm name. Saved variables are read only when the maintainer hands them over in so many words, and only their shape (how many rows, which settings) reaches the page.
- **Change cards.** Below the mock, one card per numbered change: what the player sees, **why** in a sentence or two, and a tag (*layout*, *copy*, *behavior* or *idea*). Clicking a card highlights its control in the mock. After the cards, a short list of what works and stays.
- **Try this.** Per view, a short list of tasks for testers.
- **Approvals.** Load the artifact-capabilities skill, and declare `db` and `user` with a rule that only the owner writes the `approvals` collection. Each card carries **Build**, **Try first** and **Drop** buttons and a note box, shown only to the owner; everyone else sees the cards read-only. A choice writes `approvals/{change-id}`, where the id is a short stable slug for the change, never its number, so a rerun shows a carried-over change's earlier choice. Read them back with the `ArtifactData` tool (`list` on `approvals`), taking only the ids on the current page.

Publish to the existing link if the calling pass found one, otherwise as a new private artifact.

## Feature prompts

For each **Build**, output one feature prompt per `Optional - Research & Feedback.md` → Feature prompts, which states its format, contents and ordering. Close with a one-line reminder: after running the feature prompts, re-enter the pipeline at `02 - Code Review.md`, and rerun this pass once they land to refresh the link.

This pass does not audit the docs. If you run into a genuine doc problem, mention it in one line and move on.
