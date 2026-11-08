# Create Release Notes & PR

**Read `References/Pass Preamble.md` first; it governs everything below.** Pass Name: `the Release Notes & PR step`. Write scope: **git and GitHub only** — a branch, commits of the session's existing changes, and the PR. No add-on file edits: the code is final when this pass runs.

Run after the Prelaunch Review passes — this is how a release leaves the machine. It drafts the release notes, and once you approve them they become the PR body and the text for the GitHub release you write when tagging.

## Identity — paramount; gate everything on it

**No PII from this computer ever reaches git or GitHub, and the only GitHub identity ever used is `Gogo1951`.** The maintainer's other GitHub accounts are never used, named, or hinted at; nothing may link a personal identity with gaming. This outranks every other instruction, including finishing the pass.

Phase 0, before anything else:

1. **Repo-local author identity, set every run:** as bare calls from the repo folder (no `cd`, pipe or redirect): `git config user.name "Gogo1951"` and `git config user.email "Gogo1951@users.noreply.github.com"`. Repo-local only — never read out, print, or modify the global git config; the repo-local value shadows it.
2. **Acting account:** `gh auth status`, run bare, must show `Gogo1951`. Any other account: stop the pass and tell the maintainer to switch (`gh auth switch`). Never proceed with the wrong account, never "just this once."
3. **Verify after every commit:** `git log -1 --format='%an %ae / %cn %ce'` shows Gogo1951 with the noreply address as both author and committer. Anything else is amended before push.

**PII sweep on everything that leaves the machine** — branch name, commit messages, PR title and body, release notes: no real names; no email address other than the Gogo1951 noreply; no absolute local paths (`/Users/...`, `C:\Users\...` — repo-relative paths only); no machine or host names; no other account handles. Commits carry no trailers, co-author lines included.

## GitHub status: warn, never block

In Phase 0, `WebFetch` `https://www.githubstatus.com/api/v2/summary.json`. If any unresolved incident, in-progress maintenance, or non-`operational` status touches Git Operations, API Requests, Pull Requests, or Actions (the packager runs on Actions when the tag is pushed), open the Phase 2 message with a one-line warning: the affected components, the incident title, and a link to https://www.githubstatus.com/. Then carry on; whether to wait is the maintainer's call. All clear: say nothing. Fetch failed: say in one line that GitHub's status couldn't be checked.

## Always Start From the Latest `main`

**A PR is built on what is on GitHub right now, never on a branch or fork left over from earlier.** Building on a stale base is how a PR ends up rebuilt from scratch.

- **Gogo1951's own add-on:** `git fetch -q origin --tags`, then branch from `origin/main`. Open the PR with `gh pr create --repo Gogo1951/{Repo} --base main`, since `gh` aims a fork's PR at its parent by default.
- **Someone else's add-on** (it has no row in `References/Gogo Add-ons Complete List.md`): the PR goes to the original repo, and its base is that repo's latest default branch, never Gogo1951's fork.
    1. `gh repo fork {Owner}/{Repo} --clone=false` (it does nothing when the fork exists), then `gh repo sync Gogo1951/{Repo}` to bring the fork's default branch level with the original. If the sync refuses because the fork has diverged, stop and tell the maintainer; never force it.
    2. Add the original as `upstream` if it's missing (`git remote add upstream https://github.com/{Owner}/{Repo}.git`), `git fetch -q upstream --tags`, and branch from `upstream/{default branch}`.
    3. Push the branch to the fork (`git push -u https://github.com/Gogo1951/{Repo}.git release/<slug>`) and open the PR with `gh pr create --repo {Owner}/{Repo} --head Gogo1951:release/<slug>`.

## Workflow — six phases (0–5), all required

0. **Identity gate** above, the GitHub status check, plus permissions per the preamble.
1. **Gather the changes: everything since the last release, never just this session.** The notes cover every change a player gets between the previous release and this one, including work merged in earlier sessions or edited on GitHub and never tagged. Fetch the base per Always Start From the Latest `main`, then `git describe --tags --abbrev=0 {base}` for the last release tag (no tag means a first release: everything counts). Sources, all of them: `git log --oneline <tag>..{base}` and `git diff <tag> {base}` for what already landed since that tag; the working-copy diff for what this pass commits. Build the change list from what the player experiences, never from the code's shape.
   **Then match the change list to GitHub issues, every time, unasked.** Run `gh issue list --repo {Owner}/{Repo} --state open --limit 100 --json number,title,body` against the repo the PR goes to, and also take every `#N` named in the commits since the tag. Each open issue the release fully fixes is **Fixed**; one it only partly addresses is **Related**. Judge by what the issue reports, not by its title alone.
2. **Draft and confirm — one gate for everything.** Draft the release notes (format below), the PR title and the branch slug. Present them together per Style Guide → ASKING THE MAINTAINER, naming the last release tag the notes run from, the version line, which base the branch comes from (own repo or someone else's), and the Fixed and Related issues by number and title (or `No linked issues.`); ask for Special Thanks, and **wait for the yes**. A modification is an approval of the modified version. Nothing is pushed or created on GitHub before approval.
3. **Execute.** Branch from the freshly fetched base (`git switch --no-track -c release/<slug> {base}`); commit the session's changes — developer-level detail belongs in commit messages, concisely. **Before pushing, run `git grep -n '^## Interface:' HEAD -- '*.toc'` and confirm every target TOC in `01 - Local Setup.md` is there with its number. If one is missing, stop: commit it if the working copy has it, otherwise report it as a Blocker. Never push or hand off for tagging otherwise.** Session Prep edits only the working copy, so this checks what actually ships. Then push, and open the PR with `gh pr create`, the approved title, and as the body the approved release notes followed by the Linked Issues block (below), passed as one quoted `--body` argument, never through `$(...)` or a heredoc. If a bare `git config` or `gh` call still fails in the sandbox, stop and hand the maintainer the exact command to run in Terminal.
4. **Verify the links, then report.** Run `gh pr view {PR} --repo {Owner}/{Repo} --json closingIssuesReferences` and confirm every Fixed issue is listed; if one is missing, fix the PR body with `gh pr edit --body` and check again. Report the PR link, the base it was built on, the Phase 0/3 identity verification plus each committed TOC's `## Interface:` value in one line, and the Fixed issues as links, saying they close when the PR merges. Then the approved notes in one fenced block, ready for the GitHub release (without the Linked Issues block).
5. **Close out after the merge.** When the maintainer says the PR is merged (in this session or a later one), check each Fixed issue with `gh issue view {N} --json state`. Close any still open with `gh issue close {N} --repo {Owner}/{Repo} --comment "Fixed in #{PR}."`, and report each issue's final state in one line. On someone else's repo, closing is the owner's: report any still open instead of closing it.

## Release Notes format

Exact skeleton. Include only sections that have items — an empty section is dropped outright, never left as a bare heading. The version line and Downloads are always present:

```
# Release Notes

## YYYY.MM.DD.A

1-2 sentences on what changed, total.

### New Features

* One line per item.

### Improvements

* One line per item.

### Bug Fixes

* One line per item.

### Special Thanks

* **{Name}** // {What they helped with, e.g. Coming up with the idea behind X.}

### Downloads

* [CurseForge]({CurseForge URL})
* [Wago]({Wago URL})
```

The version line is the tag the maintainer will push, in the house `YYYY.MM.DD.A` form (the letter advances for a second release on the same day) — confirm it in Phase 2. **Special Thanks is optional, but ask for it every time**: in Phase 2, prompt the maintainer for the people who helped with this release (testers, idea sources, bug reporters) and drop the section only when the answer is nobody. Downloads always closes the notes, both links taken from the add-on's master-list entry.

When the last tag is from the same day (the letter advances), start from that release's notes (`gh release view <tag>`) and fold this release's changes into them, so the notes cover the whole day; update any earlier bullet the new work changes.

**WoW Forever support is preliminary, and every release says so.** Put this line, verbatim, as its own paragraph right after the summary: `Support for WoW Forever is preliminary and will continue to improve as more game data becomes available.` Drop it when the add-on ships no Forever TOC; once Forever support is no longer preliminary, delete this paragraph.

**Written for players, not developers.** Every bullet says what the user will notice, in plain language — never function names, file names, APIs, or internals. Developer detail goes in commit messages, not release notes. Keep it short and human: one line per bullet, the whole thing readable at a glance. The no-em-dash and straight-quotes rules bind this copy (Style Guide → TONE AND COPY → In-Game Rendering Rules).

**README changes never appear in the release notes. Never.** Leave out every change to any `README*` file (`README.md`, `README-Notes.md`, `README-Technical.md`, `README-Testing.md`, or any other): no bullet, no mention in the summary, not folded into another item, and not reworded as a documentation or description update.

## Linked Issues block

Every Fixed and Related issue goes in the PR body, after the release notes, so GitHub links them to the PR and closes the Fixed ones when it merges into `main`. One closing keyword per issue, never a comma list (GitHub reads only the first number). Drop the block only when there are no linked issues; drop either line group when it is empty:

```
### Linked Issues

* Fixes #{N} // {Issue title}
* Related to #{N} // {Issue title}
```

For a PR to someone else's repo, the numbers are that repo's issues. The block stays out of the GitHub release text.

## Rules

- **Not a git repo means Session Prep didn't finish.** Run only the first line of `01 - Local Setup.md` → Session Prep step 2 (the git wiring), never its checkout line, since the working copy now holds this release's edits; if the remote can't be wired, stop and say so.
- **Never commit a deletion of a scaffolding file** (`.pkgmeta`, `.luacheckrc`, `LICENSE`, `.github/`, `.gitattributes`, `.gitignore`), **or any change to a shared one** (`.github/workflows/`, `.gitattributes`, `.gitignore`), which changes only in Common-Core (Style Guide → COMMON-CORE). A staged deletion of one is always a mistake.
- **Never commit a library update under `Includes/Libraries/`.** Common-Core's release workflow refreshes those folders from `.pkgmeta` and commits them itself, so a local edit there is overwritten. The one exception is adding or removing a library: its `.pkgmeta` external and its folder land, or leave, in the same commit, since CI fails either without the other (Style Guide → COMMON-CORE → What CI Enforces). Session Prep step 3 refreshes these folders every session, so local differences from `main` there are expected and never committed. Any other staged change under `Includes/Libraries/` is a mistake — revert it before pushing.
- **`README-Notes.md` is committed with the release** whenever it differs from the base, even if only earlier sessions changed it (Pass Preamble → Permissions). It is never printed or handed over to paste.
- **Never tag the release.** Tagging is the maintainer's manual act; the tag push is what triggers Common-Core's release workflow.
- No force-push, and no history rewrites beyond amending an unpushed commit's authorship.
