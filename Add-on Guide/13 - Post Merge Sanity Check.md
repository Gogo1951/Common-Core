# Post Merge Sanity Check

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Post Merge Sanity Check`. Write scope: **GitHub issues only** — closing the release's Fixed issues and creating the issues you approve. No add-on file edits, no commits, no push, no PR.

Run once step 12's PR is merged into `main`: the cycle's close-out. It checks that the folder and `main` now match, so nothing the cycle changed was left out of the release, turns whatever is still open into GitHub issues once you approve them, and lists every change the cycle suggests for the guide and the kits.

**Identity.** `12 - Create Release Notes & PR.md` → Identity binds this pass: `gh auth status`, run bare, must show `Gogo1951` before any GitHub write, and its PII sweep covers every issue title, body, label and comment this pass writes. Nothing from a session transcript is quoted into an issue: issues are written fresh, in plain words.

## Workflow — five phases (0–4), all required

0. **Identity check** above, plus permissions per the preamble.
1. **Confirm the merge.** `git fetch -q origin --tags` (`upstream` for someone else's add-on, per step 12 → Always Start From the Latest `main`). Find the release PR: the one the maintainer names, else the newest merged `release/…` PR (`gh pr list --repo {Owner}/{Repo} --state merged --limit 5 --json number,title,headRefName,mergedAt,mergeCommit`). Not merged yet: stop and say so in one line.
2. **Compare the folder with `main`.** Run `git status --porcelain` and `git diff --ignore-cr-at-eol --stat origin/main` from the add-on folder, plus `git ls-files --others --exclude-standard` for new files never committed. Every difference is one of:
    - **Expected, never reported:** anything under `Includes/Libraries/` (Session Prep refreshes it, CI commits it at tagging), `.claude/`, and kit copies that match Common-Core's current `addon-kits/` (the kits moved after the merge; the next release carries them).
    - **Left out:** a change in the folder that `main` doesn't have — an edit made after the PR, or a file never staged. Each is a **Blocker**, said in player words. This pass never commits it; it offers step 12 for a follow-up PR (Next Pass, below).
    - **Only on `main`:** a change made on GitHub or by a review commit. Not a problem; say it in one line. The next Session Prep brings it down.

   Then the merge's own checks, one line each: `README-Notes.md` matches `main`; `git grep -n '^## Interface:' origin/main -- '*.toc'` shows every target TOC from `01 - Local Setup.md` with its number (a missing one is a Blocker); CI's latest run on `main` passed (`gh run list --repo {Owner}/{Repo} --branch main --limit 3 --json name,conclusion,headSha`); and whether the merge is tagged yet (`git tag --contains {merge commit}`). Untagged is a reminder, never a Blocker: tagging stays manual.
3. **Gather what's still open.**
    - **Fixed issues.** `gh pr view {PR} --repo {Owner}/{Repo} --json closingIssuesReferences`, then `gh issue view {N} --json state` for each. Close any still open with `gh issue close {N} --repo {Owner}/{Repo} --comment "Fixed in #{PR}."`. On someone else's repo, closing is the owner's: report any still open instead.
    - **The cycle's sessions.** This pass's one sanctioned read outside the launch folder: the Claude Code transcripts for this folder, in `~/.claude/projects/`, under the folder named for the launch folder's path with every character other than a letter or digit turned into `-`. Read only the `.jsonl` files changed since the last release tag's date (`git log -1 --format=%cI {previous tag}`). If there are none, say so in one line and work from this session's checks alone.
    - **From those, collect:** fix or feature prompts the maintainer answered `None for now` or left unpicked (never one they turned down); defects or questions a pass raised and the cycle never settled; anything a pass said it couldn't check or finish; every Guide Feedback section and every kit-change paste block (Pass Preamble → Kits and the guide change only in Common-Core); and every place the guide or a kit made the work harder: a rule the maintainer overrode, a question asked twice, a permission prompt, a kit that couldn't draw what was needed.
    - **Skipped data work.** When `git diff --stat {previous tag} {merge commit} -- Data/ '*.toc'` shows data changed, but a data file in a folder a TOC lists has a Last Validated date older than the previous tag (or `Never.`), step 5 didn't cover it this cycle. Each such folder is one proposed issue for the next run. So is a `TODO` or `FIXME` left in the code, except the sanctioned `TODO: Add SQL Query`.
    - **Leave out** anything `main` already has, any issue already open (`gh issue list --repo {Owner}/{Repo} --state open --limit 100 --json number,title,body`; judge by what it reports, not its title), and every guide or kit item Common-Core `main` already reflects (fetch the file it names and check).
4. **Report, ask once, then create.** The report (below), ending with one question per Style Guide → ASKING THE MAINTAINER, the same three options as Pass Preamble → Batch apply, worded for issues: `Create all (Recommended)` / `Pick which ones` / `None for now`. Then create the chosen issues with `gh issue create --repo {Owner}/{Repo} --title "…" --body "…" --label "…"` as bare calls, one quoted argument each, never through `$(...)` or a heredoc. Every issue carries one Area, one Priority and one Type label from Common-Core's `scripts/sync-labels.sh`; items for the next run are `Priority: 2 Normal` unless they block a release. Reply with each issue's link in one line. On someone else's repo, never create issues: give each as a title and body to file by hand.

## Report format

1. **Verdict**, one line: `Folder matches main` or `Folder and main differ: {count} left out`.
2. **Merge checks**, one line each, in Phase 2's order: the PR link, local vs `main`, `README-Notes.md`, the TOCs with their numbers, CI, the tag.
3. **Left out**, only when something was: one plain line per change, what a player would miss.
4. **Fixed issues**, one line each with its final state, or `No linked issues.`
5. **Proposed issues**, numbered `Issue N`: the title, one plain sentence saying what a player sees or what the next run should do, and its three labels. Group them **Still open** (defects, questions, unapplied prompts) then **For the next run** (skipped data work, unfinished checks, TODOs). Left out when there are none, and so is the question.
6. **Guide & Kit Changes**, the full list (below), when there is any.
7. The question, last.

## Guide & Kit Changes

**This is the cycle's full list, not a pass's Guide Feedback:** the two-item cap and the report-only-what-breaks bar in Style Guide → GUIDE FEEDBACK don't apply. Everything else there does, and so do triage's four never-items (no dates, no add-on's current state, no bad examples, no personal information).

- **One numbered line per change:** the file under `Add-on Guide/` or `addon-kits/`, what it says now, what happened this cycle, and the suggested edit, in plain words. Same-point items from different sessions merge into one; conflicting ones are listed as a conflict.
- **Every earlier pass's Guide Feedback item is carried in word for word**, so the maintainer pastes this one list instead of hunting for the others. Routine data items (Style Guide → GUIDE FEEDBACK) ride along, marked routine.
- **Close with** *Paste the block below into a new session launched in `~/Common-Core`.* and one fenced block holding the triage line, the stamp `Generated on [Date] after performing the Post Merge Sanity Check on [Add-on Name].`, and every item, word for word:

```
Triage this Guide Feedback using Add-on Guide/References/Guide Feedback Triage Prompt.md; edit nothing before I approve.

{the stamp line and every item}
```

## Next Pass

Only when something was **left out** (Phase 2): offer `12 - Create Release Notes & PR.md` as a card (Pass Preamble → Next Pass), to ship it in a follow-up PR. Otherwise the cycle is done and nothing is offered.
