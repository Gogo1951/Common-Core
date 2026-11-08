# Guide Feedback Triage (Fold Feedback Into the Guide)

Fold Guide Feedback from completed passes back into the guide — with maintainer approval per change. Input: one or more **Guide Feedback** blocks (pasted into chat, or pointed to). This pass edits only the guide's own docs (the Style Guide, the master list, and the prompts, all under `Add-on Guide/`); it never touches an add-on or the rest of Common-Core.

**Keep the docs simple.** Sort every item into **routine data** or **doc feedback** first, then apply the checks below to the doc-feedback ones only.

**Routine data items are exempt from all of it** — the bar, the two-item cap, and consolidation — because they are data updates, not feedback (Style Guide → GUIDE FEEDBACK defines them). They arrive as exact text, and a value the Prelaunch derived from the master list's own precedence rule is data, not a judgment call. A maintainer's rule-change ruling from a pass is doc feedback, asked about on its own, but skips the checks below.

For everything else, drop what fails:

- **Look for the simpler version.** Before approving an item, check whether the same item is better handled by rewriting a closed list as a principle, deleting a rule that keeps getting misread, or fixing the one add-on. Propose that version instead. An addition may grow the docs; never move or trim other text just to offset it.
- **More than two doc-feedback items from one pass** means the pass ignored its own cap. Rank them, take the top two, and drop the rest.
- **A recurring item is a signal about the doc, not the add-on.** When the same shape of item arrives from three passes, change the rule that generates it — surface that to the maintainer instead of landing another patch.

**Four things never go into these docs, no matter how an item is worded.** Drop any item proposing one, and say so in one line:

- **Date stamps.** Nothing records when something was ruled, verified, or true: no `(maintainer ruling, YYYY-MM)`, no "verified on", no "as of".
- **The current state of an add-on.** No compliance status, no "conversion pending", no "still uses X", no "not yet adopted". These documents set the rules; they don't track who follows them.
- **Bad examples.** No "don't do it like add-on X". Every example in these docs shows how something *should* be done. If the only way to illustrate a rule is a counter-example, state the rule without an example.
- **Personal information.** The guide is public. No real names, no email address other than the Gogo1951 noreply, no machine or host names, no other account handles, and no local path that names a user: a home folder is always `~` or `$HOME`.

**This is the only pass that writes the guide, and it never runs from a code session** — the template code sessions carry denies all writes to `~/Common-Core` by design. Run triage in a session launched in `~/Common-Core`, the guide's local clone: a **bare** Claude Code session (plain `claude` or the desktop app's Code tab, no `wowclaude`, no template, and deliberately no settings file ever created there), or Cowork with `~/Common-Core` connected. Approve its edit prompts as they come; triage runs are short and occasional, so a handful of approvals is the intended cost. Never work around the deny from a code session (not even via Bash).

**Approve them as a single batch.** List every routine item in full — one line each, showing the exact text that will land — and ask one confirmation covering all of them, rather than one question per item. Anything the maintainer strikes from that list is simply not applied.

## Workflow

0. **Start from the latest `main`.** `git pull -q --ff-only` before reading anything. If it refuses, stop and say why; never stash, reset or discard someone's local changes.

1. **Consolidate first.** Read every feedback item across all supplied blocks, then merge before asking:
    - Items making the same point from different passes become one proposed change.
    - Items that conflict get surfaced as a conflict, not silently resolved.
    - Items below the bar (see Style Guide → GUIDE FEEDBACK) are dropped — say which, in one line each.

2. **Ask — one yes/no question per consolidated change, nothing applied without approval.** Follow the Style Guide → ASKING THE MAINTAINER format, batching up to 4 questions per round. Each question is a plain-language statement of what would change and where, with a Yes and a No option. (The recommendation-first, flag-the-weak, and modification-is-approval rules live in that canonical section.)

3. **Apply approved changes only, in the right file.**
    - **A change that should apply to every add-on is a rule** — it goes in the Style Guide, stated absolutely, with no add-on named and no date.
    - **A change that carves one add-on out of a rule is an exception**, and belongs in that add-on's `README-Notes.md` (Style Guide → README-NOTES), never in these docs; any other ruling for one add-on alone isn't recorded here either. Hand the maintainer the exact text for that file instead.
    - **A change that records a per-add-on fact is data** — it goes in the master list.
    - Never rename release-wired identifiers (repos, folders, slugs, IDs) as a side effect of a wording fix.

4. **Verify.** Re-check each edit landed (search for the new text), confirm no cross-reference now points at removed text, and search the changed files for personal information (above).

5. **Commit and push.** The approval of the changes covers this step; don't ask again. Run each as a bare call from `~/Common-Core`:
    - `git config user.name "Gogo1951"` and `git config user.email "Gogo1951@users.noreply.github.com"`, repo-local only.
    - `gh auth status` must show `Gogo1951`. Any other account: stop, and tell the maintainer to switch (`gh auth switch`).
    - Stage only the files this run changed under `Add-on Guide/`, then commit with a one-line message naming each change in plain words (`Release Notes format: …; Copy Review: …`).
    - `git log -1 --format='%an %ae / %cn %ce'` shows Gogo1951 with the noreply address as both author and committer; amend anything else before pushing.
    - `git push origin main`. If it is rejected because `main` moved, `git pull --rebase -q` and push again. Never force-push.

6. **Report.** Changes applied, changes declined, items dropped below the bar, the net line change across the docs, and the pushed commit's link.

## Rules

- **Approval gates everything.** No edit lands without a yes.
- **A change to what players see is its own question** (Style Guide, opening rules): state it as before → after in player terms, name the section's Live reference and whether it already does this, and never fold it into another change.
- Keep edits minimal — record the ruling, don't rewrite the section around it. The exception is when the ruling reveals that the *section* is what keeps generating items; then rewriting it simpler is the correct fix.
