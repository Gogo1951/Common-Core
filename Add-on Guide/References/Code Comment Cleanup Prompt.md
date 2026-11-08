# Code Comment Cleanup (Editing, Comments Only)

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Code Comment Cleanup`. Write scope: **the add-on's Lua comments only, outside the `Data/{Game}/` folders.**

Slim and sharpen the comments across every Lua file in this add-on. The house standard is **few, sharp comments**, and this pass is what enforces it. The rules themselves are canonical in Style Guide → COMMENTS; this prompt is the *pass* that applies them, not a second copy of them.

**This pass edits the add-on's source — comments only. Behavior must stay identical: change comments, never code.** It's an on-demand pass, never a launch gate. Because it edits source, when you plan to run it before a release, run it **before** the Prelaunch Review — the last gate should review final code.

## What to do

Go file by file through every Lua file. Skip `Includes/`, which is vendored and never touched, and the `Data/{Game}/` folders, whose comments belong to `04 - Data Review.md` (Style Guide → DATA → Data File Layout):

- **Apply Style Guide → COMMENTS as written** — delete what doesn't earn its place (the default is *no* comment), keep only the non-obvious *why* that section defines, and shorten what stays: one line where one line does the job, multi-line preambles and ceremony cut to the essential point.
- **Keep the durable *why*, short.** When a comment explains a whole subsystem or design rather than the line it sits on, cut it to its essential point and leave it in place: step 10 writes it up in `README-Technical.md` from the code, and this pass never edits a README (Pass Preamble → Standing scope).
- **Never touch functional markers.** Leave `MIGRATION` tags and sanctioned `TODO:` markers exactly as they are — other passes depend on them. Leave the dashed SECTION HEADERS dividers and the data-array column-header / row legends; they're structure, not commentary.

Err toward trimming, but this isn't a scorched pass — a judgment-call comment that genuinely helps can stay. The aim is steady, decisive progress against over-commenting, not zero comments.

## Verify — required

- **Behavior unchanged.** You changed only comments. Confirm each touched file still parses (`luac -p`) and lints clean (luacheck), and diff each file to confirm no non-comment bytes moved.
- **Formatting preserved.** Run StyLua-default over every touched file (Style Guide → TABLE FORMATTING & STYLUA); a comment edit isn't done if it left non-StyLua whitespace behind.

Report briefly: how many files were touched, and roughly how many comments were cut versus kept.
