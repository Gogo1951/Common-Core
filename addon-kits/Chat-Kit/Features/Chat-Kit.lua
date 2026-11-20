local _, ns = ...

-- luacheck: read globals C_ChatInfo C_Timer ChatEdit_GetActiveWindow ChatFrame1 ChatFrame_OpenChat ChatFrameUtil
-- luacheck: read globals DEFAULT_CHAT_FRAME GetTime IsInGroup IsInRaid LE_PARTY_CATEGORY_INSTANCE SendChatMessage
-- luacheck: read globals UIErrorsFrame issecretvalue

--[[
    Chat-Kit: every chat line a Gogo add-on writes, to the player and to other
    players, in the Style Guide's one format.

    Copied unchanged from Common-Core's addon-kits/Chat-Kit/ into
    Features/Chat-Kit.lua, after Features/Utilities.lua in the TOC, and checked
    byte for byte by CI. Never edit a copy: change Common-Core's and sync it
    (Common-Core/scripts/sync-addon-kits.sh).

    The kit knows nothing about the add-on. It reads only what every add-on
    already defines under one name: ns.PALETTE, ns.L (ADDON_TITLE,
    ADDON_SHORT_NAME, CHAT_LOADED), ns.TARGET_MARKER, ns.CHAT_MESSAGE_MAX_LENGTH,
    ns.db, ns.DATABASE_DEFAULTS, ns.FLAVOR and ns.Version.

    Spec: Common-Core/Add-on Guide/References/Design System/Chat Lines/
    Chat-Kit.md. Rules: Style Guide → MESSAGES and WELCOME MESSAGE.

    Prints, to the player only:
      Chat.Print(body)                    Full Name // Body.
      Chat.PrintBlock(first, lines)       A total or title, then each line, every one branded
      Chat.PrintAlert(body)               Body // Full Name, for a combat alert, as the group reads it
      Chat.PrintWarning(body, key)        A login warning (a conflict, a missing add-on): once a session
      Chat.PrintOnce(key, body)           Once a session for the key
      Chat.PrintQuiet(key, seconds, body) Not again within seconds for the key
      Chat.Welcome()                      L.CHAT_LOADED with ns.Version, while showWelcome is on
      Chat.PrintLine(body)                Print's line, unprinted, for an Example line
      Chat.AlertLine(body)                PrintAlert's line, unprinted
      Chat.Notice(body)                   Short Name // Body, red, center screen: refusing a click
      Chat.Player(name, classFile)        A name in its class color, inside a print
      Chat.Money(copper)                  12g 05s 00c, colored, inside a print
      Chat.Slash(text)                    A slash command in INFO, inside a print

    Sent, to other players:
      Chat.Build(formatKey, ...)          {rtN} Body // Short Name, or nil; the group's line
      Chat.Send(channel, target, formatKey, ...)
      Chat.BuildParts(formatKey, parts, formatArguments, channel)
      Chat.SendParts(channel, target, formatKey, parts, formatArguments)
      Chat.GroupChannel()                 INSTANCE_CHAT, RAID, PARTY, or nil when solo
      Chat.Whisper(name, text)            A finished line, queued 0.35 seconds apart
      Chat.Trim(body)                     The body less its closing ! . ? and opening ¡ ¿
      Chat.FillTokens(text, tokens)       {word} placeholders filled, never format codes
      Chat.Draft(text, chatType, target)  Into the player's own chat box: no marker, no name

    formatKey is an L key, or a table for more: { key = "L_KEY" } or
    { text = "a body already filled" }, plus channel = "WHISPER" (Build only:
    which line to build) and marker = false (a combat alert's: no marker).

    The Style Guide's names keep working: ns:PrintMessage(message),
    ns:BuildAnnounceMessage(formatKey, ...), ns:Announce(channel, target,
    formatKey, ...) and ns:GetGroupChatChannel().
]]

local Chat = {}
ns.ChatKit = Chat

local format = string.format
local concat = table.concat
local floor = math.floor

local SEPARATOR = "//"
local WHISPER_GAP = 0.35 -- Seconds between queued whispers: a burst risks the server's chat squelch
local LOCKDOWN_RETRY = 1 -- Seconds between looks while chat messaging is locked down
local LOCKDOWN_WAIT = 30 -- A whisper still locked out this long after it was queued is dropped, never sent stale
local DEFAULT_MAX_LENGTH = 255

-- Where an add-on's palette lacks a key: the Style Guide's own values.
local PALETTE = {
	TITLE = "FFD100",
	INFO = "00BBFF",
	TEXT = "FFFFFF",
	OFF = "CC3333",
	SEPARATOR = "AAAAAA",
}

-- Style Guide → COLORS: the same on every flavor.
local CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

-- Magic Eraser's coin colors.
local COIN_COLORS = { GOLD = "FFD700", SILVER = "C7C7CF", COPPER = "EDA55F" }

--------------------------------------------------------------------------------
-- Reading the Add-on
--------------------------------------------------------------------------------

local function Hex(key)
	return (ns.PALETTE and ns.PALETTE[key]) or PALETTE[key] or PALETTE.TEXT
end

local function Color(key)
	return "|cff" .. Hex(key)
end

--[[
    A locale string, or nil when the add-on has none under that key. Read raw:
    AceLocale answers a missing key with the key's own name (and may store it
    so), which would print ADDON_SHORT_NAME in game instead of falling back.
]]
local function Text(key)
	local value = type(ns.L) == "table" and rawget(ns.L, key)
	if type(value) == "string" and value ~= "" and value ~= key then
		return value
	end
	return nil
end

local function FullName()
	return Text("ADDON_TITLE") or ""
end

local function ShortName()
	return Text("ADDON_SHORT_NAME") or FullName()
end

local function MaxLength()
	return ns.CHAT_MESSAGE_MAX_LENGTH or DEFAULT_MAX_LENGTH
end

local function Now()
	return GetTime and GetTime() or 0
end

--------------------------------------------------------------------------------
-- Prints (Player Only)
--------------------------------------------------------------------------------

-- Full Name in INFO, // in SEPARATOR, the body in TEXT. Colors a body embeds (links, names) sit inside it.
function Chat.PrintLine(body)
	return Color("INFO")
		.. FullName()
		.. "|r "
		.. Color("SEPARATOR")
		.. SEPARATOR
		.. "|r "
		.. Color("TEXT")
		.. tostring(body)
		.. "|r"
end

function Chat.Print(body)
	if body == nil then
		return
	end
	print(Chat.PrintLine(body))
end

-- A report's total or a list's title first, then each line, every one carrying the name.
function Chat.PrintBlock(first, lines)
	Chat.Print(first)
	for _, line in ipairs(lines or {}) do
		Chat.Print(line)
	end
end

--[[
    Every message to other players drops its closing punctuation, because the
    name signs off after it. Translations carry their own (Spanish opens with
    an inverted mark, CJK closes with a full-width one), so the trim covers
    those too, matched as whole UTF-8 sequences so a multi-byte character is
    never cut in half.
]]
local CLOSING_MARKS = { "!", ".", "?", "\239\188\129", "\227\128\130", "\239\188\159" } -- ! . ? and full-width ！ 。 ？
local OPENING_MARKS = { "\194\161", "\194\191" } -- ¡ ¿

function Chat.Trim(body)
	if body == nil then
		return nil
	end
	body = tostring(body)
	local trimmed = true
	while trimmed do
		trimmed = false
		body = body:gsub("%s+$", "")
		for _, mark in ipairs(CLOSING_MARKS) do
			if body:sub(-#mark) == mark then
				body = body:sub(1, -#mark - 1)
				trimmed = true
			end
		end
	end
	trimmed = true
	while trimmed do
		trimmed = false
		body = body:gsub("^%s+", "")
		for _, mark in ipairs(OPENING_MARKS) do
			if body:sub(1, #mark) == mark then
				body = body:sub(#mark + 1)
				trimmed = true
			end
		end
	end
	return body
end

-- A combat alert brands at the end, as the group reads it, so the body's own raid mark is the line's only one.
function Chat.AlertLine(body)
	return Color("TEXT")
		.. Chat.Trim(body)
		.. "|r "
		.. Color("SEPARATOR")
		.. SEPARATOR
		.. "|r "
		.. Color("INFO")
		.. FullName()
		.. "|r"
end

function Chat.PrintAlert(body)
	if body == nil then
		return
	end
	print(Chat.AlertLine(body))
end

local printedOnce = {}
local warned = {}
local printedAt = {}

-- Once a session for the key (the body, when no key is given). True when it printed.
function Chat.PrintOnce(key, body)
	if body == nil then
		return false
	end
	key = key or body
	if printedOnce[key] then
		return false
	end
	printedOnce[key] = true
	Chat.Print(body)
	return true
end

-- Not again within `seconds` for the key (the body, when no key is given). True when it printed.
function Chat.PrintQuiet(key, seconds, body)
	if body == nil then
		return false
	end
	key = key or body
	local now = Now()
	local last = printedAt[key]
	if last and now - last < (seconds or 0) then
		return false
	end
	printedAt[key] = now
	Chat.Print(body)
	return true
end

--[[
    A login warning: a conflict, or a missing add-on this one needs. It never
    reads the welcome switch, and prints once a session per key (the body,
    when no key is given), so a check that runs on every loading screen says
    it once.
]]
function Chat.PrintWarning(body, key)
	if body == nil then
		return false
	end
	key = key or body
	if warned[key] then
		return false
	end
	warned[key] = true
	Chat.Print(body)
	return true
end

--[[
    showWelcome is a presentation key, scoped per the add-on's save model
    (Style Guide → SAVED VARIABLES → The Two Models): ns.db.global under
    Per-Character, ns.db.profile under Simple. The scope ns.DATABASE_DEFAULTS
    puts it in is the only one read, so a value an older version saved in the
    other scope never overrides the current switch. With no defaults to go by,
    global answers first, then the profile. On by default, and gated on
    nothing else.
]]
local function DefinesWelcome(scope)
	return type(scope) == "table" and scope.showWelcome ~= nil
end

local function WelcomeOn()
	local db = ns.db
	if not db then
		return true
	end
	local defaults = ns.DATABASE_DEFAULTS
	local value
	if type(defaults) == "table" and DefinesWelcome(defaults.profile) then
		value = db.profile and db.profile.showWelcome
	elseif type(defaults) == "table" and DefinesWelcome(defaults.global) then
		value = db.global and db.global.showWelcome
	elseif db.global then
		value = db.global.showWelcome
	end
	if value == nil and db.profile then
		value = db.profile.showWelcome
	end
	return value ~= false
end

function Chat.Welcome()
	local loaded = Text("CHAT_LOADED")
	if not loaded or not WelcomeOn() then
		return false
	end
	local ok, line = pcall(format, loaded, tostring(ns.Version or "Dev"))
	if not ok then
		return false
	end
	Chat.Print(line)
	return true
end

--[[
    Center screen, where the game says "can't do that": only to refuse a click
    right where the player is looking, in red. Short Name // Body. Refusing in
    combat is an ordinary print (Chat.Print), never this.
]]
function Chat.Notice(body)
	if body == nil or not UIErrorsFrame then
		return false
	end
	local hex = Hex("OFF")
	local red = tonumber(hex:sub(1, 2), 16) / 255
	local green = tonumber(hex:sub(3, 4), 16) / 255
	local blue = tonumber(hex:sub(5, 6), 16) / 255
	UIErrorsFrame:AddMessage(ShortName() .. " " .. SEPARATOR .. " " .. tostring(body), red, green, blue)
	return true
end

--------------------------------------------------------------------------------
-- Values Inside a Print
--------------------------------------------------------------------------------

--[[
    Each colors its value and picks the print's TEXT up again after it, so the
    rest of the body stays white. Colors never survive a sent message: these are
    for prints only.
]]

function Chat.Player(name, classFile)
	name = tostring(name or "")
	local hex = classFile and CLASS_COLORS[classFile]
	if not hex then
		return name
	end
	return "|cff" .. hex .. name .. "|r" .. Color("TEXT")
end

local function Grouped(number)
	return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function Coin(amount, letter, colorKey)
	return amount .. "|cff" .. COIN_COLORS[colorKey] .. letter .. "|r" .. Color("TEXT")
end

-- 1,234g 05s 00c; 5s 00c; 7c. Never negative.
function Chat.Money(copper)
	local value = floor(math.max(tonumber(copper) or 0, 0))
	local gold = floor(value / 10000)
	local silver = floor((value % 10000) / 100)
	local coins = value % 100
	local parts = {}
	if gold > 0 then
		parts[#parts + 1] = Coin(Grouped(gold), "g", "GOLD")
		parts[#parts + 1] = Coin(format("%02d", silver), "s", "SILVER")
	elseif silver > 0 then
		parts[#parts + 1] = Coin(tostring(silver), "s", "SILVER")
	end
	parts[#parts + 1] = Coin(format((gold > 0 or silver > 0) and "%02d" or "%d", coins), "c", "COPPER")
	return concat(parts, " ")
end

function Chat.Slash(text)
	return Color("INFO") .. tostring(text or "") .. "|r" .. Color("TEXT")
end

--------------------------------------------------------------------------------
-- Sent Messages (Other Players)
--------------------------------------------------------------------------------

local NO_OPTIONS = {}

--[[
    {rtN} on every sent line that carries one, with two exceptions: a combat
    alert (marker = false), whose body already carries the mark that matters,
    and WoW Forever's group and channel chat, which block raid-marker tokens;
    its whispers keep it.
]]
local function Marker(options, channel)
	local marker = ns.TARGET_MARKER
	if options.marker == false or type(marker) ~= "string" or marker == "" then
		return ""
	end
	if ns.FLAVOR == "Camelot" and channel ~= "WHISPER" then
		return ""
	end
	return marker .. " "
end

--[[
    The finished line for a channel, or nil: for a key with no text, for a
    translation whose placeholders don't fit its arguments (it would throw),
    and for a body the trim leaves empty. L[key] goes through string.format; a
    { text } body is the player's own and never does, so a stray % can't
    break it.
    Bodies carry item and spell links, which survive sent chat, so pipes stay.
]]
local function BuildFor(channel, formatKey, ...)
	local options = type(formatKey) == "table" and formatKey or NO_OPTIONS
	local body = options.text
	if body == nil then
		local template = Text(options.key or formatKey)
		if not template then
			return nil
		end
		local ok, filled = pcall(format, template, ...)
		if not ok then
			return nil
		end
		body = filled
	end
	body = Chat.Trim(body)
	if body == "" then
		return nil
	end
	return Marker(options, channel) .. body .. " " .. SEPARATOR .. " " .. ShortName()
end

-- The line as it would go out, unsent, so a caller can measure it. Group chat's, unless formatKey names a channel.
function Chat.Build(formatKey, ...)
	local channel = type(formatKey) == "table" and formatKey.channel or nil
	return BuildFor(channel, formatKey, ...)
end

-- True while the game holds add-on chat back (a boss fight on newer clients). A value it hides counts as held.
local function InLockdown()
	local lockdown = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
	if not lockdown then
		return false
	end
	local locked = lockdown()
	if issecretvalue and issecretvalue(locked) then
		return true
	end
	return locked and true or false
end

local function RawSend(message, channel, target)
	local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
	send(message, channel, nil, target)
end

--[[
    Whispers go out WHISPER_GAP apart, through one queue: a burst sent in one
    frame risks the server's chat squelch. An empty queue sends at once, so the
    usual single whisper feels instant. While chat messaging is locked down the
    queue waits, looking again every LOCKDOWN_RETRY; a whisper still locked out
    LOCKDOWN_WAIT after it was queued is dropped rather than sent stale.
]]
local queue = {}
local nextWhisperAt = 0
local waiting = false

local function Pump()
	waiting = false
	while queue[1] do
		local now = Now()
		if now < nextWhisperAt then
			waiting = true
			C_Timer.After(nextWhisperAt - now, Pump)
			return
		end
		local whisper = queue[1]
		if InLockdown() then
			if now - whisper.queuedAt < LOCKDOWN_WAIT then
				waiting = true
				C_Timer.After(LOCKDOWN_RETRY, Pump)
				return
			end
			table.remove(queue, 1)
		else
			table.remove(queue, 1)
			RawSend(whisper.text, "WHISPER", whisper.target)
			nextWhisperAt = now + WHISPER_GAP
		end
	end
end

-- Over the chat limit in bytes, SendChatMessage refuses the line: the kit never hands it one.
local function TooLong(message)
	return #message > MaxLength()
end

-- A finished line to one player, as written: build it first (Chat.Build) for the marker and name.
function Chat.Whisper(name, text)
	if not name or name == "" or not text or text == "" or TooLong(text) then
		return false
	end
	queue[#queue + 1] = { target = name, text = text, queuedAt = Now() }
	if not waiting then
		Pump()
	end
	return true
end

local function Deliver(channel, target, message)
	if channel == "WHISPER" then
		return Chat.Whisper(target, message)
	end
	if TooLong(message) or InLockdown() then
		return false
	end
	RawSend(message, channel, target)
	return true
end

-- Built for its channel and sent: whispers through the queue. Nothing without a channel or a message, or over
-- the limit.
function Chat.Send(channel, target, formatKey, ...)
	if not channel then
		return false
	end
	local message = BuildFor(channel, formatKey, ...)
	if not message then
		return false
	end
	return Deliver(channel, target, message)
end

--[[
    A list of parts (item links with counts, an enchant, money) as few lines as
    fit: packed greedily, each at most ns.CHAT_MESSAGE_MAX_LENGTH bytes, split
    only between parts (a link cut mid-escape is rejected), and each line the
    whole format, so it reads complete. A part too long alone still gets its
    own line here (it can't be shortened without breaking its link), and
    SendParts then skips that line, since chat would refuse it.
    formatArguments(joined) returns the format's arguments in order, for a
    format whose list isn't its only one; by default the list is.
]]
local function Arguments(formatArguments, joined)
	if formatArguments then
		return formatArguments(joined)
	end
	return joined
end

function Chat.BuildParts(formatKey, parts, formatArguments, channel)
	local messages = {}
	local options = type(formatKey) == "table" and formatKey or NO_OPTIONS
	local separator = options.separator or ", "
	channel = channel or options.channel
	local count = parts and #parts or 0
	local first = 1
	while first <= count do
		local last = first
		while last < count do
			local joined = concat(parts, separator, first, last + 1)
			local candidate = BuildFor(channel, formatKey, Arguments(formatArguments, joined))
			if not candidate or #candidate > MaxLength() then
				break
			end
			last = last + 1
		end
		local message = BuildFor(channel, formatKey, Arguments(formatArguments, concat(parts, separator, first, last)))
		if message then
			messages[#messages + 1] = message
		end
		first = last + 1
	end
	return messages
end

-- Returns the lines it sent (a whisper's: queued).
function Chat.SendParts(channel, target, formatKey, parts, formatArguments)
	local sent = {}
	if not channel then
		return sent
	end
	for _, message in ipairs(Chat.BuildParts(formatKey, parts, formatArguments, channel)) do
		if Deliver(channel, target, message) then
			sent[#sent + 1] = message
		end
	end
	return sent
end

-- The chat the whole group reads: an instance group's own first, then raid, then party. Nil when solo.
function Chat.GroupChannel()
	if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
	return nil
end

--[[
    {word} placeholders, each swapped through a function, which gsub takes
    literally, % included, so a player's saved text can't break the send. A
    token the table doesn't hold stays as typed.
]]
function Chat.FillTokens(text, tokens)
	if text == nil then
		return nil
	end
	tokens = tokens or NO_OPTIONS
	return (
		tostring(text):gsub("{([%w_]+)}", function(token)
			local value = tokens[token]
			if value ~= nil then
				return tostring(value)
			end
		end)
	)
end

--------------------------------------------------------------------------------
-- Drafts
--------------------------------------------------------------------------------

--[[
    A line put in the player's own chat box for them to send: their words, so
    no marker, no name and no //. chatType picks the box's channel through its
    slash command; a whisper needs its target. Never clobbers a box the player
    is already typing in. True when it opened the box.
]]
local DRAFT_COMMANDS = {
	SAY = "/s",
	YELL = "/y",
	PARTY = "/p",
	RAID = "/raid",
	RAID_WARNING = "/rw",
	INSTANCE_CHAT = "/i",
	GUILD = "/g",
	OFFICER = "/o",
	WHISPER = "/w",
}

local function ActiveChatBox()
	if ChatFrameUtil and ChatFrameUtil.GetActiveWindow then
		return ChatFrameUtil.GetActiveWindow()
	elseif ChatEdit_GetActiveWindow then
		return ChatEdit_GetActiveWindow()
	end
	return nil
end

function Chat.Draft(text, chatType, target)
	if text == nil or text == "" then
		return false
	end
	local open = (ChatFrameUtil and ChatFrameUtil.OpenChat) or ChatFrame_OpenChat
	if not open or ActiveChatBox() then
		return false
	end
	local command = chatType and DRAFT_COMMANDS[chatType]
	if chatType == "WHISPER" then
		command = target and (command .. " " .. target) or nil
	end
	if command then
		text = command .. " " .. text
	end
	open(text, ChatFrame1 or DEFAULT_CHAT_FRAME)
	return true
end

--------------------------------------------------------------------------------
-- The Style Guide's Names
--------------------------------------------------------------------------------

function ns:PrintMessage(message)
	Chat.Print(message)
end

function ns:BuildAnnounceMessage(formatKey, ...)
	return Chat.Build(formatKey, ...)
end

function ns:Announce(channel, target, formatKey, ...)
	return Chat.Send(channel, target, formatKey, ...)
end

function ns:GetGroupChatChannel()
	return Chat.GroupChannel()
end
