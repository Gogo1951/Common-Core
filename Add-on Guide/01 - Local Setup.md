# Local Setup (Permissions + Session Prep)

**Step 1 of every code session you start yourself.** It refreshes the guide, scopes the session's permissions to this add-on, pre-approves every data source the guide uses, pulls the latest `main` and libraries down, and opens the folder in Sublime Text.

**Access is scoped to the add-on being worked on.** A session gets: **read + write** on the folder it was launched in; **read-only** on the same add-on's copies in the other two flavors, on all three clients' `WTF` folders, and on the guide (the `~/Common-Core` clone); and the open web (`WebFetch`/`WebSearch`) for reference repos and listings. Nothing else — other add-ons are neither readable nor writable without an explicit approval, the guide folder and `WTF` are deny-listed for writes, and no grant is ever machine-wide. **Access is not a reason to look:** the other copies and `WTF` are readable only so a look the maintainer asks for runs without a prompt, and a session never reads outside its launch folder unasked (Pass Preamble → Standing scope).

**The template is dynamic.** `References/Permission Template.json` carries a `{{ADDON}}` placeholder; the seed/launch step below renders it with **the name of the folder it's run from**, so the same template file produces a MagicEraser-scoped grant in the MagicEraser folder and an OpenSesame-scoped grant in the OpenSesame folder. Nothing is ever filled in by hand.

This file is safe to paste whole into a session: the launcher setup is human-only, and **Session Prep** at the bottom is the part Claude runs.

## Which app runs what — read this first

- **Claude Code** (Terminal, or the desktop app's Claude Code) is where **code sessions** run — every numbered step, the `Optional - …` passes, and the comment cleanup, each launched **in the add-on's installed folder** (e.g. `/Applications/World of Warcraft/_classic_era_/Interface/AddOns/MagicEraser`). Claude Code is the only app that reads the permission template. With the template loaded (either path below), these sessions never prompt for a read, and prompt for a write only outside the add-on folder.
- **Guide maintenance** — the Feedback Triage pass — runs in a session launched in `~/Common-Core`, the guide's local clone: Claude Code started there with no template, or Cowork with the folder connected. **Neither reads the permission template** (Cowork's Allow dialogs are the app's own layer, which no settings file suppresses), so never run permission setup there, and never judge the template by prompts seen there.

## How the template loads — two scoped paths

- **Terminal launch — session-only (cleanest).** One-time, human step: add this launcher to `~/.zshrc`:

  ```
  wowclaude() {
    local tmpl="$HOME/Common-Core/Add-on Guide/References/Permission Template.json"
    local rendered
    git -C "$HOME/Common-Core" pull -q --ff-only
    rendered=$(mktemp -t wowclaude)
    sed "s|{{ADDON}}|$(basename "$PWD")|g" "$tmpl" > "$rendered"
    claude --settings "$rendered" "$@"
  }
  ```

  Then working on an add-on is: `cd` into its folder, run `wowclaude`. The launcher pulls the guide, renders the template for that folder and loads it via `--settings` **for that session only** — nothing is installed or copied into any add-on folder, and the grants evaporate when the session ends.

- **Desktop-app launch — folder-scoped.** The desktop app's Claude Code takes no launch flags, so there the rendered template rides in the add-on folder itself: `.claude/settings.local.json`. Session Prep **step 0** below (re-)renders it in place. In a not-yet-seeded folder that render is the session's **one** approval — answer with a plain **Yes**, not "don't ask again" — and current Claude Code hot-reloads settings changes, so the grants apply immediately, no relaunch. The rendered file persists in that one add-on folder only: later sessions there start prompt-free with zero approvals, and deleting the folder's `.claude/` revokes everything. The repo's `.gitignore` covers `.claude/` (Style Guide → COMMON-CORE), so the file never lands in the repo.

- **Maintainer notes (human-only, never in-session):** if the WoW install lives somewhere other than `/Applications/World of Warcraft/`, a client folder is renamed, or the guide's clone ever moves from `~/Common-Core`, fix the paths in `References/Permission Template.json`, Session Prep step 0 below, Pass Preamble → Next Pass, and the `wowclaude` lines in `~/.zshrc`, which hard-code the clone's path. The `{{ADDON}}` placeholder is rendered by the seed/launch commands and is never edited by hand. Never edit the template itself from inside a session.

## What the template grants

The single source for the actual JSON is `References/Permission Template.json` — deliberately **not** duplicated here, so it can never drift from this prompt. `{{ADDON}}` below means the rendered add-on name.

- **Reads everywhere** — `Read(//**)` makes every read on the machine prompt-free: the launch folder, the other flavors' copies, every `WTF` folder, this guide, other add-ons. `additionalDirectories` adds the add-on's three flavor copies and the three `WTF` folders to the session workspace. Permission isn't scope: a pass still reads only what Pass Preamble → Standing scope allows, so the wider grant just means a read the maintainer asks for never stops for approval.
- **`WebFetch` + `WebSearch`** — the open web without prompts: reference repos, CurseForge/Wago listings, the wiki. Web reads are how passes study other add-ons — from their public listings and repos, never from the neighbors' installed folders.
- **`Edit(./**)` / `Write(./**)`** — the only *silent* write grant, scoped to the folder the session was launched in (`./` is cwd-relative). `defaultMode` is plain `default` (not `acceptEdits`): an edit inside the launch folder applies without a prompt; an edit anywhere outside it — including the other flavors' copies and every other add-on — prompts for approval instead of applying. That out-of-folder prompt is the safety rail — deny it unless the write was clearly intended.
- **`deny` `Edit`/`Write` on `~/Common-Core`** — the guide and the rest of the Common-Core clone are readable in every session and writable in none. `deny` beats `allow` in every mode, so this holds regardless of how the template was loaded — which is why guide maintenance runs in its own session launched in the guide folder (see Which app runs what). The sandbox applies the same deny to Bash, but an all-`git`, `gh` or `open` call runs outside it and isn't bound by it, so "never route a guide or `WTF` write through Bash" still stands.
- **`deny` on `WTF`** — readable when the maintainer asks, never writable, even by accident.
- **`Bash`** — allowed outright, and **sandboxed**: the OS lets a command write only in this add-on's three flavor copies and the session's temp folder (never `~/Common-Core` or `WTF`), and reach every host the guide's passes pull from without asking (the template's `allowedDomains`: GitHub, wago.tools, CurseForge (plus the CFWidget API for its project data) and WowAce including their library repos for Session Prep step 3's `svn` exports, Wago, warcraft.wiki.gg, WoWInterface and GitHub Status). A host a pass needs that isn't on the list is added to the template by the maintainer, never approved one session at a time. A call made only of `git`, `gh` or `open` commands runs outside the sandbox, since git must write `.git/config`, `gh` can fail TLS inside it on macOS, and `open` needs Apple Events. A call that mixes in anything else (a `cd`, a pipe, a redirect, or a `$(...)` or heredoc) stays sandboxed, which is fine for reads but fails a `git config` write and every `gh` call. **Strict mode** (`allowUnsandboxedCommands: false`) makes Claude Code ignore the Bash tool's `dangerouslyDisableSandbox`, so nothing else ever runs outside the sandbox. Commands run that way used to stop for approval whatever the template allowed (auto mode drops a blanket `Bash` allow), as on 2026-10-16. A command the sandbox blocks now just fails; the session reports it and never works around it. A few edge cases (`find -exec`, some in-place `sed` forms) can still prompt; approve those with a plain **Yes**, not "don't ask again", which only appends a rule that Session Prep step 0's next re-render erases.

## What a prompt means now (canonical — the passes point here)

- **A prompt for any read, or an edit inside the add-on folder:** the template isn't loaded — a desktop-app session before Session Prep step 0 has run, a session launched in the wrong folder, or a Terminal session started with plain `claude` instead of `wowclaude`. Fix the cause (run Session Prep step 0, or relaunch via `wowclaude` from the add-on folder) — never approve your way through a pass one command at a time.
- **A prompt marked `dangerouslyDisableSandbox` / "Runs outside Claude's sandbox":** this folder's settings predate strict mode. Approve it once, and Session Prep step 0 refreshes them; it can't recur after that.
- **A prompt for a write outside the add-on folder:** the safety rail — deny it unless the write was clearly intended.
- **A rare Bash edge case** (`find -exec` and friends), **or a sandboxed command's first connection to a host outside the template's `allowedDomains`:** approve it with a plain **Yes** if the pass needs it, and move on; if a pass will need that host again, the maintainer adds it to the template.

## Session Prep — Claude runs this at the start of every code session

**Skip it entirely in a session another pass started (Pass Preamble → Next Pass) and in step 12.** It already ran in this folder this cycle, and step 2 would overwrite the READMEs steps 9–11 wrote.

0. **Refresh the guide, then render / heal the permission file.** From the add-on folder, run these exactly, as two separate calls:

   ```
   git -C ~/Common-Core pull -q --ff-only
   ```

   ```
   sed "s|{{ADDON}}|$(basename "$PWD")|g" "$HOME/Common-Core/Add-on Guide/References/Permission Template.json" | cmp -s - .claude/settings.local.json && echo "Permissions current" || echo "Permissions need rendering"
   ```

   The first brings the guide's local clone level with Common-Core `main`; it is all `git`, so it runs outside the sandbox. If it fails, mention it in one line and carry on with the copy on disk. On `Permissions current`, move on. On `Permissions need rendering`, write `.claude/settings.local.json` with the Write tool: the template's exact text with every `{{ADDON}}` replaced by this folder's name, nothing else changed. The command runs inside the sandbox; the sandbox can't write `.claude/` and strict mode ignores `dangerouslyDisableSandbox`, so the Write tool is the only way to write the file. That write is the one approval a session can ask for, and only in a new folder or after the template changes (plain **Yes**). The check also catches drift and stray one-off approvals. Under `wowclaude` it also seeds the folder for future desktop-app sessions. If the file shows `{{ADDON}}` literally, the session wasn't launched from the add-on folder. **This is the guide's one sanctioned settings write** — never any other settings edit, never in `~/Common-Core`, never machine-wide.

1. **Normalize the add-on's TOCs** in this working copy — every `.toc` in the folder — directly and without asking for confirmation:

   - Set the `## Version:` line to the release token:

     ```
     ## Version: @project-version@
     ```

     This makes the local copy a dev copy — the `@` in the unreplaced token is what the version-display code detects to show `Dev` (Style Guide → VERSION DISPLAY). The packager replaces it at build time.

   - Set each flavor TOC's `## Interface:` line to its own client's current target — one number per TOC:

     | TOC | `## Interface:` | Client |
     |---|---|---|
     | `_Vanilla.toc` | `11509` | Classic Era 1.15.9 |
     | `_Camelot.toc` | `16001` | WoW Forever 1.60.1 |
     | `_TBC.toc` | `20506` | TBC Anniversary 2.5.6 |

     **This table is the single home for the current target numbers**, all three on every add-on (Style Guide → TOC FILE FORMAT → Interface Versions). Session Prep sets numbers only and never creates, renames, or deletes a TOC — a missing target TOC is a Blocker for the pass to report — so an unsuffixed TOC gets the version token and nothing else, and a TOC for any other flavor keeps the number it declares. When targets change, the maintainer updates them here **and every flavor line of the Testing & Localization template in `09 - Optional Create README.md`**, their one other live copy.

   Just make the edits; don't do them one prompt at a time across the session.

2. **Point the folder at the latest `main`, then blind-pull the READMEs and scaffolding files from GitHub.** The first line wires the folder as a clone of the repo and moves it onto the newest `main` without touching any file on disk, so `git status` shows exactly how this copy differs from GitHub. The second overwrites the READMEs and scaffolding, local edits included: no diffing, no comparing, no asking, no report, no Guide Feedback. The one file it leaves alone is `README-Notes.md`, which carries this folder's rulings until step 12 commits it with the release (Pass Preamble → Permissions). Every other file on disk stays as it is, since code runs ahead of `main` by design; a file `main` has that is missing from disk comes back from `main`, README-Notes.md included. From the add-on folder, run exactly (the repo URL is in the TOC footer, and only a folder without `.git` needs it):

   ```
   git fetch -q origin --tags && git symbolic-ref HEAD refs/heads/main && git reset -q origin/main; git config core.fileMode false
   git checkout -q origin/main -- 'README*.md' ':!README-Notes.md'; git checkout -q origin/main -- .gitattributes; git checkout -q origin/main -- .gitignore; git checkout -q origin/main -- .luacheckrc; git checkout -q origin/main -- .pkgmeta; git checkout -q origin/main -- .github; git checkout -q origin/main -- LICENSE; git checkout-index -a -q
   rm -f CHANGELOG.md
   ```

   A folder without `.git` first runs `git init -q -b main && git remote add origin https://github.com/Gogo1951/Repo-Name.git` as its own call. The first two lines stay all `git`, with no loop, `if`, `cd` or redirect, because only an all-`git` call runs outside the sandbox, and git must write `.git/` (on 2026-10-25 a loop in the second line kept it in the sandbox, which refused `.git/index.lock`). Each path gets its own `checkout`, since one call naming a path `main` lacks fails whole, and `git checkout-index -a -q` writes back only the files missing from disk, never overwriting one. If git says a path isn't on `main`, mention it in one line and move on. **No commits here, ever**: authorship is configured and verified only inside step 12's identity gate (`12 - Create Release Notes & PR.md`).

3. **Refresh `Includes/Libraries/` from `.pkgmeta`,** so the session tests against the latest library versions, the same ones Common-Core's release workflow vendors at tag time (Style Guide → COMMON-CORE → Releases). Each external is fetched into a temporary folder and swapped in only when the fetch succeeds, so a failed download leaves the old copy in place. The first line hands `svn` the sandbox's network proxy: git and curl read it from `HTTPS_PROXY`, but `svn` ignores that variable, so without the line its own host lookup is blocked and every CurseForge and WowAce download fails even though those hosts are on `allowedDomains`; when the proxy address carries a username and password, the line splits them off and hands them to `svn` too. A GitHub external is cloned into the temp folder with no template and moved into place, because the sandbox refuses the `.git/hooks` and `.git/config` that a clone writes inside the add-on folder. From the add-on folder, run exactly:

   ```
   p=${HTTPS_PROXY:-$https_proxy}; p=${p#*://}; p=${p%%/*}; a=; case $p in *@*) a=${p%@*}; p=${p##*@};; esac; mkdir -p "${TMPDIR:-/tmp}/svn"; { echo '[global]'; [ -n "$p" ] && printf 'http-proxy-host = %s\nhttp-proxy-port = %s\n' "${p%:*}" "${p##*:}"; [ -n "$a" ] && printf 'http-proxy-username = %s\nhttp-proxy-password = %s\n' "${a%%:*}" "${a#*:}"; } > "${TMPDIR:-/tmp}/svn/servers"
   awk '/^externals:/{e=1;next} e&&/^[^ ]/{e=0} e&&/^  [^ ]/{p=$1;sub(/:$/,"",p);if(NF>1)print p"|"$2} e&&/^ +url:/{print p"|"$2}' .pkgmeta | while IFS='|' read -r dest url; do
     rm -rf "$dest.new"
     case "$url" in
       *curseforge.com*|*wowace.com*) svn export -q --force --non-interactive --config-dir "${TMPDIR:-/tmp}/svn" "$url" "$dest.new" ;;
       *) t="${TMPDIR:-/tmp}/clone"; rm -rf "$t"; git clone -q --depth 1 --template= "$url" "$t" && rm -rf "$t/.git" && mv "$t" "$dest.new" ;;
     esac && rm -rf "$dest" && mv "$dest.new" "$dest" || { rm -rf "$dest.new"; echo "Library not updated: $dest"; }
   done
   ```

   If a library isn't updated (or `svn` isn't installed), mention it in one line and move on. The refreshed files usually differ from `main`; that's expected, and step 12 never commits them (`12 - Create Release Notes & PR.md` → Rules).

4. **Open the add-on folder in Sublime Text.** From the add-on folder, run exactly:

   ```
   open -a "Sublime Text" .
   ```

   If it fails, mention it in one line and move on.

5. **List the repo's open issues and pull requests.** From the add-on folder, run exactly:

   ```
   gh issue list --state open --limit 100; gh pr list --state open --limit 100
   ```

   End the prep by printing each one as a line: its number as a link to it on GitHub, then its title. Print `No open issues or PRs.` when there are none. This is a list for the maintainer to decide on, so never read into, act on, or plan around an issue or PR unless asked. If `gh` fails, mention it in one line and move on.

That's the whole prep: mechanical, a minute or two at most. No research, no diffing, no confirmations, nothing to report beyond step 5's list. Beyond step 0's render, do **not** create, verify, or edit any permission or settings file in a session, and do not re-derive or rewrite the template.
