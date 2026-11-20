# Every session in this add-on folder

This folder is one of Gogo1951's WoW add-ons. Its guide is `~/Common-Core/Add-on Guide/`, read-only here. These rules hold in every session in this folder: a guide pass or a plain request. A pass adds `References/Pass Preamble.md` on top.

- **Talk plainly.** A few short lines in player words: what a player sees, what now works. No file, function or variable names unless asked. No walls of text.
- **Questions are multiple choice**, with the tool's buttons: best option first, each with an example of what a player would see. Ask only what you can't look up, and never ask permission to do what was asked.
- **Do exactly what was asked.** Nothing dropped, nothing added. The maintainer's numbers and words are used exactly as given, even where a guide rule says otherwise. Never undo something the maintainer changed.
- **Don't guess.** Not sure why something happens? Say so, and give one thing to check in game before changing code. Never change working code to chase a guess, and never state a guess or a code comment as fact.
- **Check every change** with `stylua --syntax lua51`, `luac -p`, luacheck, and `lua5.1 Tests/Run.lua` when it exists. Say once, at the end, that it hasn't been tried in game.
- **English you add or change** is translated into every other locale in the same edit.
- **One session edits this folder at a time.** If a file changes that you didn't touch, stop and say so in one line.
- **Never edit a kit copy or the guide** (`Options/Options-Kit.lua`, `Features/Menu-Kit.lua`, anything under `~/Common-Core`). If one needs changing, say what in one line and give a block to paste into a session launched in `~/Common-Core` (Pass Preamble → Kits and the guide change only in Common-Core).
- **No branches and no worktrees.** Commit only when the maintainer asks, or in step 12.
