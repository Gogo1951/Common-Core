# Chat-Kit (Common-Core)

The shared helper every Gogo add-on writes its chat lines through, in Common-Core so every add-on copies one file. It prints to the player and sends to other players in the Style Guide's one format, so the marker, the names, the `//`, the Forever rule, the whisper queue and the link packing live in one place instead of seven copies of `Features/Announcements.lua`. **Written:** [`addon-kits/Chat-Kit/`](https://github.com/Gogo1951/Common-Core/tree/main/addon-kits/Chat-Kit) holds `Features/Chat-Kit.lua`, checked by StyLua, luacheck (under every add-on's config), `luac5.1 -p` and `scripts/test-chat-kit.lua` (`lua5.1 scripts/test-chat-kit.lua` from Common-Core). A change to it is the maintainer's work, in a session launched in `~/Common-Core`; a session in an add-on folder never edits it.

- **Rules:** Style Guide → MESSAGES, WELCOME MESSAGE, ADD-ON NAMES, COLORS.
- **Drawn:** `../Chat Lines.html`.
- **The kit knows nothing about the add-on.** It reads only `ns.PALETTE`, `ns.L` (`ADDON_TITLE`, `ADDON_SHORT_NAME`, `CHAT_LOADED`), `ns.TARGET_MARKER`, `ns.CHAT_MESSAGE_MAX_LENGTH`, `ns.db`, `ns.DATABASE_DEFAULTS`, `ns.FLAVOR` and `ns.Version`, all read when a line is written, so nothing has to exist before the kit loads.
- **Each add-on's move onto the kit is its own change,** through `scripts/sync-addon-kits.sh --adopt Chat-Kit`.

## Adopting It

1. From Common-Core: `scripts/sync-addon-kits.sh --adopt Chat-Kit ../Addon-Folder`. It copies `Features/Chat-Kit.lua` in; from then on a plain run keeps it current and CI's **Shared kits match Common-Core** check fails a copy that differs.
2. Add `Features/Chat-Kit.lua` to every TOC **right after `Features/Utilities.lua`**, before Tooltip-Kit, `Features/Announcements.lua` and anything that prints (Style Guide → TOC FILE FORMAT → File Group Order).
3. Delete what the kit now does from `Features/Announcements.lua` (What It Replaces, below). The kit defines `ns:PrintMessage`, `ns:BuildAnnounceMessage`, `ns:Announce` and `ns:GetGroupChatChannel`, so callers keep working unchanged; an add-on that still defines one of them later in the TOC overrides the kit's, so remove the old one rather than leave both.
4. Add `local Chat = ns.ChatKit` where a file uses the kit's other calls.
5. Call `ns.ChatKit.Welcome()` at the SavedVariables init point's end (`PLAYER_LOGIN`), in place of the add-on's `PrintWelcome`.

## API

```lua
local Chat = ns.ChatKit
```

### Prints (Player Only)

| Call | Prints | Notes |
|---|---|---|
| `Chat.Print(body)` | `Full Name // Body.` | Full Name (`L.ADDON_TITLE`) in `INFO`, `//` in `SEPARATOR`, body in `TEXT`. The body keeps its punctuation. A nil body prints nothing. |
| `Chat.PrintLine(body)` | nothing | `Print`'s exact line, for an options panel's Example line. |
| `Chat.PrintBlock(first, lines)` | `first`, then each of `lines` | A report's total, a list's title or a command help's heading first; **every line carries the name**, never an unbranded continuation. |
| `Chat.PrintAlert(body)` | `Body // Full Name` | Combat alerts only: the name at the end, as the group reads it. |
| `Chat.AlertLine(body)` | nothing | `PrintAlert`'s exact line. |
| `Chat.PrintWarning(body, key)` | `Full Name // Body.` | A login warning for a conflict or a missing add-on this one needs. Never reads the welcome switch. Once a session per `key` (the body when nil). |
| `Chat.PrintOnce(key, body)` | once a session per key | Returns true when it printed. |
| `Chat.PrintQuiet(key, seconds, body)` | not again within `seconds` per key | GogoLoot's repeat window and `AnnounceItemOnce`. Returns true when it printed. |
| `Chat.Welcome()` | `L.CHAT_LOADED` with `ns.Version` | Gated **only** by `showWelcome` (below). No once-per-session flag: it prints at every login while the switch is on. |
| `Chat.Notice(body)` | center screen: `Short Name // Body`, `OFF` red | `UIErrorsFrame`, only to refuse a click right where the player is looking (a macro that can't be deleted). A refusal in combat is an ordinary `Chat.Print`, never center screen. |

```lua
Chat.Print(L["CHAT_LIST_ADDED"]:format(link))
Chat.PrintBlock(L["CHAT_VENDOR_TOTAL"]:format(Chat.Money(total)), saleLines)
Chat.PrintAlert(L["ALERT_TAUNT"]:format(icon, Chat.Player(name, class), spellLink))
Chat.PrintQuiet("paused", ns.STATUS_REPEAT_COOLDOWN, L["CHAT_OPENING_PAUSED"])
Chat.PrintWarning(L["CHAT_CONFLICT_QUESTIE"])
Chat.Notice(L["ERROR_MACRO_ON_BARS"]) -- refusing a click: the macro can't be deleted while it's on your bars
```

**Where `showWelcome` lives.** The key is presentation, scoped per Style Guide → SAVED VARIABLES → The Two Models: `ns.db.profile.showWelcome` under Simple, `ns.db.global.showWelcome` under Per-Character. The kit reads only the scope the add-on's `ns.DATABASE_DEFAULTS` puts it in, so a value an older version saved in the other scope never overrides the current switch, and the kit needs no setting to know the model. Without `ns.DATABASE_DEFAULTS` it reads global first, then the profile. Before `ns.db` exists, or with neither scope holding the key, it reads as on, its default.

### Values Inside a Print

Each colors its value and then reopens `TEXT`, so the rest of the body stays white. Colors never survive `SendChatMessage`: these are for prints only.

| Call | Gives |
|---|---|
| `Chat.Player(name, classFile)` | The name in its class color (Style Guide → COLORS's table, the same on every flavor); plain for an unknown class. |
| `Chat.Money(copper)` | `1,234g 05s 00c`, `5s 00c`, `7c`: numbers white, coin letters in Magic Eraser's coin colors. Never negative. |
| `Chat.Slash(text)` | A slash command in `INFO`. |

### Sent Messages (Other Players)

| Call | Does |
|---|---|
| `Chat.Build(formatKey, ...)` | Returns the finished line, **unsent**, so a caller can measure it, or nil for a key with no text or a blank body. `{rtN} Body // Short Name`. Without a channel it builds the group's line. |
| `Chat.Send(channel, target, formatKey, ...)` | Builds for `channel` and sends; `WHISPER` goes through the queue. No-ops (returns false) on a nil channel and on a nil message. |
| `Chat.BuildParts(formatKey, parts, formatArguments, channel)` | The lines a parts list packs into, unsent. |
| `Chat.SendParts(channel, target, formatKey, parts, formatArguments)` | Packs and sends; returns the lines sent. |
| `Chat.GroupChannel()` | `INSTANCE_CHAT` (`IsInGroup(LE_PARTY_CATEGORY_INSTANCE)`), then `RAID`, then `PARTY`; nil when solo. Pass `SAY` or `YELL` explicitly, and only from the player's own click or key. |
| `Chat.Whisper(name, text)` | Queues a **finished** line to one player, as written: build it first for the marker and name. A line sent unbranded on purpose (Thanks for the Buff's Thank You Button) goes straight here. |
| `Chat.FillTokens(text, tokens)` | `{word}` placeholders filled by plain `gsub` through a function, never format codes, so a stray `%` can't crash. A token the table doesn't hold stays as typed. |
| `Chat.Draft(text, chatType, target)` | Puts `text` in the player's own chat box: their words, so **no marker, no name, no `//`**. `chatType` (`SAY`, `PARTY`, `RAID`, `INSTANCE_CHAT`, `GUILD`, `WHISPER` with `target`, ...) picks the box's channel through its slash command. Never opens over a box the player is already typing in. Returns true when it opened. |

**`formatKey`** is an `L` key, or a table for more:

- `{ key = "L_KEY" }`: the same as the bare key.
- `{ text = body }`: a body already filled (an editable whisper after `FillTokens`). It is signed off but **never formatted**, so the player's `%` is safe.
- `marker = false`: no marker. **Combat alerts are sent this way**: their bodies already carry the mark that matters.
- `channel = "WHISPER"`: `Build` and `BuildParts` only, which line to build (it matters on WoW Forever). `Send` takes its channel from its argument.
- `separator = ", "`: `BuildParts` and `SendParts` only, what joins the parts.

`L[key]` always goes through `string.format`, arguments or not, so write a literal `%` in a locale string as `%%`.

```lua
-- Group chat, or nothing when solo.
ns:Announce(ns:GetGroupChatChannel(), nil, "BUFF_DUTY_OTHERS_ASK_ONE", name, link)

-- A combat alert to the group: no marker.
Chat.Send(Chat.GroupChannel(), nil, { key = "ALERT_TAUNT", marker = false }, name, spellLink)

-- An editable whisper: the player's text, filled, signed off, queued. Empty text sends nothing;
-- too long, the default text in the player's chosen language goes instead (Style Guide → Editable Messages).
local tokens = { name = Ambiguate(sender, "short"), spell = link }
local function WhisperLine(text)
	return Chat.Build({ text = Chat.FillTokens(text, tokens), channel = "WHISPER" })
end
local line = WhisperLine(ns.db.profile.thanksWhisper)
if line and #line > ns.CHAT_MESSAGE_MAX_LENGTH then
	line = WhisperLine(ns.GetDefaultThanksWhisper()) -- the default for ns.GetMessageLanguage()
end
if line then
	Chat.Whisper(sender, line)
end

-- Many item links, as few lines as fit; the list isn't the format's only argument.
Chat.SendParts(channel, nil, "TRADE_GAVE", parts, function(list)
	return list, partnerName
end)

-- Drafted for the player to send.
Chat.Draft(announcement, "PARTY")
```

**The rules the kit applies to every sent line:**

- **The marker** is `ns.TARGET_MARKER`, followed by a space. An add-on without one (none defined, or an empty string) sends none.
- **WoW Forever** (`ns.FLAVOR == "Camelot"`) blocks raid-marker tokens in group and channel chat, so there the marker goes on whispers only: `Send` and `SendParts` decide from their channel, and `Build` builds the group's line unless given `channel = "WHISPER"`.
- **Pipes are kept**: bodies carry item, spell and quest links, which survive sent chat; stripping would break them.
- **Parts** (item links with counts, an enchant, money) pack greedily across as many lines as needed, each at most `ns.CHAT_MESSAGE_MAX_LENGTH` bytes (255 by default), split only between parts, each line the whole format so it reads complete. `formatArguments(joined)` returns the format's arguments in order, for a format whose list isn't its only one; by default the joined list is. A part too long alone still gets its own line from `BuildParts` (it can't be shortened without breaking its link), and `SendParts` skips that line.
- **Over the limit, nothing goes.** `Send`, `SendParts` and `Whisper` never hand chat a line over `ns.CHAT_MESSAGE_MAX_LENGTH` bytes, which it would refuse. Swapping in an editable message's default text is the add-on's build function's job, before the kit sees the line.
- **A translation whose placeholders don't fit** its arguments builds nothing (`Build` returns nil, `Send` sends nothing), never a Lua error.
- **Whispers** go through one queue, 0.35 seconds apart, so a burst never trips the server's chat squelch; an empty queue sends at once. While `C_ChatInfo.InChatMessagingLockdown()` (where the client has it) says chat is locked, the queue waits, looking again each second; a whisper still locked out 30 seconds after it was queued is dropped rather than sent stale. A lockdown value the game hides (`issecretvalue`) counts as locked. Group and channel sends during lockdown are skipped, never queued.
- **Sends** use `C_ChatInfo.SendChatMessage`, or `SendChatMessage` on a client without it.

### The Style Guide's Names

The kit defines these as thin aliases, so existing callers don't change:

| Name | Is |
|---|---|
| `ns:PrintMessage(message)` | `Chat.Print(message)` |
| `ns:BuildAnnounceMessage(formatKey, ...)` | `Chat.Build(formatKey, ...)`: the group's line |
| `ns:Announce(channel, target, formatKey, ...)` | `Chat.Send(channel, target, formatKey, ...)` |
| `ns:GetGroupChatChannel()` | `Chat.GroupChannel()` |

## Strings It Needs

Every add-on already has them; the kit adds no locale key.

| Key | What |
|---|---|
| `L["ADDON_TITLE"]` | The Full Name: every print, alert and warning. |
| `L["ADDON_SHORT_NAME"]` | The Short Name: every sent line's sign-off and the center-screen refusal. Falls back to the Full Name. A key the locale lacks counts as missing (the kit reads the table raw, since AceLocale answers a missing key with its own name). |
| `L["CHAT_LOADED"]` | The welcome message, `%s` the version (Style Guide → WELCOME MESSAGE). |

And from `Data/Data.lua`: `ns.PALETTE` (`INFO`, `SEPARATOR`, `TEXT`, `OFF`, `TITLE`; a missing key falls back to the Style Guide's value), `ns.TARGET_MARKER`, `ns.CHAT_MESSAGE_MAX_LENGTH`, `ns.FLAVOR` (`Data/Flavor.lua`) and `ns.Version`.

## What It Replaces

| Add-on | Replaces | With the kit |
|---|---|---|
| **Good to Go** | `Features/Announcements.lua`: `GetPrintPrefix`, `ns.BuildPrintLine`, `ns:PrintMessage`, `ns.WarnOnce`, `TrimSentBody`/`SignOff`/`BuildSent`, `ns:BuildAnnounceMessage`, `Send`, the whisper queue (`QueueWhisper`, `Deliver`), `ns:Announce`, `FillTokens`, `ns:GetGroupChatChannel`, `ns:QueueAutomatedWhisper`. `Features/Utilities.lua:67`: `ns.ShowUIError`, `ns.ShowUINotice`. | `Chat.Print`, `Chat.PrintLine`, `Chat.PrintWarning`/`PrintOnce`, `Chat.Build({ text = ... })`, `Chat.Whisper`, `Chat.Send`, `Chat.FillTokens`, `Chat.Notice(body)`. `BuildEditable` (the too-long fallback to the default text) and the whisper builders stay: they know the add-on's fields. |
| **Thanks for the Buff** | Its own `TrimSentBody`/`SignOff`, `ns:BuildAnnounceMessage`, `ns:Announce`, `ns:Whisper` (unbranded), the Good News whisper queue with its lockdown drop. Prints brand with the **Short Name** today. | The kit's calls; `ns:Whisper` becomes `Chat.Whisper` (queued now too). Prints move to the Full Name. |
| **GogoLoot** | `ns.BuildPrintMessage`, `ns:PrintMessage`, `ns:BuildAnnounceMessage`, `ns:Announce`, `ns:AnnounceParts` (packing with `formatArguments`), `ns:GetGroupChatChannel`, `StatusPrint`'s repeat check, `AnnounceItemOnce`, the welcome reading `ns.db.global.showWelcome`. | `Chat.SendParts(channel, target, key, parts, formatArguments)`, `Chat.PrintQuiet` (keyed by the text, or the item ID), `Chat.Welcome()`. The `lootNotifications` master switch stays GogoLoot's: it checks it before calling `Chat.Send`. The loading-screen quiet window (`SetQuiet`) stays GogoLoot's. |
| **Pretty Wide Quest Log** | `BuildSent` with the WoW Forever marker rule, `ns:BuildAnnounceMessage` (group), `ns:BuildWhisperMessage`, `ns:Announce`, `ns:GetGroupChatChannel`. Prints brand with the **Short Name** today. | `Chat.Build(key, ...)` and `Chat.Build({ key = key, channel = "WHISPER" }, ...)`; the quest-reference fitting stays. Prints move to the Full Name. |
| **Magic Eraser** | `ns:FormatCurrency` and `ns:FormatCommaNumber` in `Features/Utilities.lua`, used in prints; Auto-Vend's held sale lines under its total. | `Chat.Money(copper)` inside a print; `Chat.PrintBlock(total, sales)`. `ns:FormatCurrency` stays for windows and menus, where the print's `TEXT` reopening has no place. |
| **Control Freak** | `ns:PrintMessage`, `TrimClosingPeriod`, `ns.BuildAlertLine`/`ns:PrintAlert` (`Body // Control Freak`), `ns:PrintWelcome`, `ns:BuildAnnounceMessage` (no marker, period trim), `ns:Announce` with its cut-to-fit. | `Chat.PrintAlert`/`Chat.AlertLine`, `Chat.Welcome()`, `Chat.Send(channel, nil, { key = key, marker = false }, ...)`. Its raid-icon texture-to-token swap, `SafeCutLength` and the PARTY-only channel stay its own: build the body, then send `{ text = body, marker = false }`. |
| **Tracking Eye** | Come and Get It's `ChatFrameUtil.OpenChat` draft with its own slash prefix and active-box check. | `Chat.Draft(announcement, chatType)`. |

## Checking It in Game

1. `/reload` with the welcome switch on: one line, `Full Name // Version ...`, name blue, `//` gray, body white. Turn the switch off in Options, `/reload`: nothing. Under Per-Character, switch profiles: the switch holds (it's account-wide).
2. Trigger a print, a report with a total (every line branded, total first) and, in a fight, an alert (`Body // Full Name`).
3. In a party, send something: `{rtN} Body // Short Name`, links clickable. Leave the party and trigger it again: nothing is sent. In a battleground, it goes to instance chat.
4. On WoW Forever: the party line has no marker; a whisper does.
5. Hand out or trade a dozen items with long names: several lines, each complete, none rejected.
6. Trigger three whispers at once: they arrive about a third of a second apart. In a newer client's boss fight, a whisper waits until the encounter ends (up to 30 seconds), else is dropped.
7. Click something the add-on refuses: `Short Name // Message` in red, center screen.
8. Draft a line into the chat box: no marker, no name; with a draft already being typed, nothing happens.

## Done When

- [x] `addon-kits/Chat-Kit/Features/Chat-Kit.lua` is in; StyLua, luacheck (under every add-on's config), `luac5.1 -p` and `scripts/test-chat-kit.lua` pass on it.
- [ ] Each add-on adopts it as its own change, deleting what What It Replaces lists.
