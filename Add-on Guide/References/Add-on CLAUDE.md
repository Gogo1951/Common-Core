# Every session in this add-on folder

This folder is one of Gogo1951's WoW add-ons. Its guide is Common-Core's `Add-on Guide/` on GitHub `main`, read-only here. These rules hold in every session in this folder: a guide pass or a plain request. A pass adds `References/Pass Preamble.md` on top.

- **Read the guide from GitHub.** Fetch each guide file from `main` with `curl -fsSL "https://raw.githubusercontent.com/Gogo1951/Common-Core/main/Add-on%20Guide/{path}"` (spaces as `%20`). Never read, pull or update a local copy of it.
- **Talk plainly.** A few short lines in player words: what a player sees, what now works. No file, function or variable names unless asked. No walls of text.
- **Questions are multiple choice**, with the tool's buttons: best option first, each with an example of what a player would see. Ask only what you can't look up, and never ask permission to do what was asked: no closing "want me to commit?" or "shall I go on?".
- **The maintainer's preferences go in the guide, never in Claude's memory notes.** One that holds for every add-on goes to Common-Core as a paste block (Style Guide → GUIDE FEEDBACK); one this add-on alone keeps goes in `README-Notes.md` (Style Guide → README-NOTES).
- **Do exactly what was asked.** Nothing dropped, nothing added. The maintainer's numbers and words are used exactly as given, even where a guide rule says otherwise. Never undo something the maintainer changed.
- **Don't guess.** Not sure why something happens? Say so, and give one thing to check in game before changing code. Never change working code to chase a guess, and never state a guess or a code comment as fact.
- **Check every change** with `stylua --syntax lua51`, `luac -p`, luacheck, and `lua5.1 Tests/Run.lua` when it exists. Say once, at the end, that it hasn't been tried in game.
- **English you add or change** is translated into every other locale in the same edit, except where a pass's write scope says otherwise.
- **Other sessions may be working in this folder** (steps 9–11 run side by side). Ignore changes to files you aren't editing, `.claude/` included; never stop or ask about them. Re-read a file before editing it.
- **Never edit a kit copy or the guide** (anything Common-Core's `addon-kits/` holds, anything under `~/Common-Core`). If one needs changing, say what in one line and give a block to paste into a session launched in `~/Common-Core` (Pass Preamble → Kits and the guide change only in Common-Core).
- **No branches and no worktrees.** Commit only when the maintainer asks, or in step 12.
