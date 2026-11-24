-- Offline smoke test for addon-kits/Chat-Kit: stubs the WoW APIs the kit touches (print, SendChatMessage,
-- the group tests, C_Timer on a clock the test moves, UIErrorsFrame, the chat box, chat lockdown), then runs
-- every call and checks what comes out.
-- Run from Common-Core: lua5.1 scripts/test-chat-kit.lua

local say = print

-- What chat would show: color escapes stripped.
local function Visible(text)
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

-- The clock and C_Timer: timers run when the test moves the clock past them, in order.
local clock = 1000
local timers = {}
function GetTime()
	return clock
end
C_Timer = {
	After = function(delay, fn)
		timers[#timers + 1] = { at = clock + delay, fn = fn }
	end,
}
local function Advance(seconds)
	local target = clock + seconds
	while true do
		local soonest
		for index, timer in ipairs(timers) do
			if timer.at <= target + 1e-9 and (not soonest or timer.at < timers[soonest].at) then
				soonest = index
			end
		end
		if not soonest then
			break
		end
		local timer = table.remove(timers, soonest)
		clock = math.max(clock, timer.at)
		timer.fn()
	end
	clock = target
end

-- Prints, sends, the center screen and the chat box, each recorded.
local printed, sent, notices, opened = {}, {}, {}, {}
print = function(text)
	printed[#printed + 1] = text
end
local locked, secret = false, false
C_ChatInfo = {
	SendChatMessage = function(message, channel, _, target)
		sent[#sent + 1] = { message = message, channel = channel, target = target, at = clock }
	end,
	InChatMessagingLockdown = function()
		return locked
	end,
}
function issecretvalue()
	return secret
end
local legacySent = {}
function SendChatMessage(message, channel, _, target)
	legacySent[#legacySent + 1] = { message = message, channel = channel, target = target }
end
UIErrorsFrame = {
	AddMessage = function(_, text, red, green, blue)
		notices[#notices + 1] = { text = text, r = red, g = green, b = blue }
	end,
}
local activeBox
ChatFrame1 = { name = "ChatFrame1" }
ChatFrameUtil = {
	OpenChat = function(text, frame)
		opened[#opened + 1] = { text = text, frame = frame }
	end,
	GetActiveWindow = function()
		return activeBox
	end,
}

local group = { instance = false, raid = false, party = false }
LE_PARTY_CATEGORY_INSTANCE = 2
function IsInGroup(category)
	if category == LE_PARTY_CATEGORY_INSTANCE then
		return group.instance
	end
	return group.party or group.raid
end
function IsInRaid()
	return group.raid
end

local ns = {
	L = {
		ADDON_TITLE = "Good to Go",
		ADDON_SHORT_NAME = "GtG",
		CHAT_LOADED = "Version %s. Settings are under Options > AddOns > Good to Go. (=",
		BUFF_ASK = "%s is missing [Arcane Intellect]!",
		HELLO_ES = "¡Hola, %s!",
		THANKS_ZH = "谢谢%s。",
		QUESTION_ES = "¿Necesitas agua?",
		FULL_WIDTH = "准备好了吗？！",
		RUSSIAN = "Привет!",
		NOT_A_MARK = "你好",
		DOTS = "...",
		LOOT_LIST = "Handed out: %s.",
		TRADE = "Traded %s to %s.",
		ALERT = "{rt8} Taunted Soulflayer.",
		EMPTY = "",
	},
	PALETTE = {
		TITLE = "FFD100",
		INFO = "00BBFF",
		TEXT = "FFFFFF",
		OFF = "CC3333",
		SEPARATOR = "AAAAAA",
	},
	TARGET_MARKER = "{rt1}",
	CHAT_MESSAGE_MAX_LENGTH = 255,
	FLAVOR = "Vanilla",
	Version = "2026.11.20.A",
	db = { profile = { showWelcome = true }, global = {} },
}

local chunk = assert(loadfile(arg[1] or "addon-kits/Chat-Kit/Features/Chat-Kit.lua"))
chunk("TestAddon", ns)
local Chat = ns.ChatKit
local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
	say("ok  " .. msg)
end
local function Last(list)
	return list[#list]
end
local function Clear(list)
	for index = #list, 1, -1 do
		list[index] = nil
	end
end

-- Prints
Chat.Print("Some Message.")
check(
	Last(printed) == "|cff00BBFFGood to Go|r |cffAAAAAA//|r |cffFFFFFFSome Message.|r",
	"Print: Full Name in INFO, // in SEPARATOR, the body in TEXT"
)
check(Chat.PrintLine("Some Message.") == Last(printed), "PrintLine is Print's line, unprinted")
check(Visible(Last(printed)) == "Good to Go // Some Message.", "and reads Full Name // Body.")
local before = #printed
Chat.Print(nil)
check(#printed == before, "a nil body prints nothing")

Clear(printed)
Chat.PrintBlock("Sold 3 items for 12g.", { "Item one", "Item two", "Item three" })
check(#printed == 4 and Visible(printed[1]) == "Good to Go // Sold 3 items for 12g.", "PrintBlock: the total first")
local allBranded = true
for _, line in ipairs(printed) do
	allBranded = allBranded and Visible(line):sub(1, 14) == "Good to Go // "
end
check(allBranded and Visible(printed[4]) == "Good to Go // Item three", "and every line carries the name")

Chat.PrintAlert("{rt8} Taunted Soulflayer.")
check(
	Visible(Last(printed)) == "{rt8} Taunted Soulflayer. // Good to Go",
	"PrintAlert: Body // Full Name, punctuation kept"
)
check(Last(printed):find("|cffAAAAAA//|r |cff00BBFFGood to Go|r$") ~= nil, "with the name in INFO at the end")
check(Chat.AlertLine("Taunted!") == "|cffFFFFFFTaunted!|r |cffAAAAAA//|r |cff00BBFFGood to Go|r", "AlertLine unprinted")

-- Repeat suppression
Clear(printed)
check(Chat.PrintOnce("bags", "Bags full.") == true and #printed == 1, "PrintOnce prints the first time")
check(Chat.PrintOnce("bags", "Bags full.") == false and #printed == 1, "and never again this session")
check(Chat.PrintOnce(nil, "Keyless.") and not Chat.PrintOnce(nil, "Keyless."), "keyed on the body when no key")
Clear(printed)
check(Chat.PrintQuiet("paused", 5, "Paused.") == true and #printed == 1, "PrintQuiet prints the first time")
Advance(4.9)
check(Chat.PrintQuiet("paused", 5, "Paused.") == false and #printed == 1, "not again within its seconds")
Advance(0.2)
check(Chat.PrintQuiet("paused", 5, "Paused.") == true and #printed == 2, "and again once they pass")
check(Chat.PrintQuiet("other", 5, "Other.") == true, "each key keeps its own time")

-- Welcome, by save model
Clear(printed)
check(Chat.Welcome() == true, "Welcome prints while showWelcome is on")
check(
	Visible(printed[1]) == "Good to Go // Version 2026.11.20.A. Settings are under Options > AddOns > Good to Go. (=",
	"CHAT_LOADED with ns.Version"
)
check(Chat.Welcome() == true and #printed == 2, "at every login: no once-a-session flag")
ns.db = { profile = { showWelcome = false }, global = {} } -- Simple: the profile holds it
check(Chat.Welcome() == false and #printed == 2, "Simple: the profile's switch off silences it")
ns.db = { profile = {}, global = { showWelcome = false } } -- Per-Character: global holds it
check(Chat.Welcome() == false, "Per-Character: the global switch off silences it")
ns.db = { profile = { showWelcome = true }, global = { showWelcome = false } }
check(Chat.Welcome() == false, "and a profile left on doesn't override the global scope that holds it")
ns.db = { profile = { showWelcome = false }, global = { showWelcome = true } }
check(Chat.Welcome() == true, "global on prints whatever the profile says")
ns.db = nil
check(Chat.Welcome() == true, "before the database exists it is on, its default")
ns.DATABASE_DEFAULTS = { profile = { showWelcome = true } } -- Simple, with a stale global from an older version
ns.db = { profile = { showWelcome = true }, global = { showWelcome = false } }
check(Chat.Welcome() == true, "the scope the defaults name wins: an old global value can't silence it")
ns.db = { profile = { showWelcome = false }, global = { showWelcome = true } }
check(Chat.Welcome() == false, "and an old global value can't turn it back on")
ns.DATABASE_DEFAULTS = { global = { showWelcome = true } } -- Per-Character
ns.db = { profile = { showWelcome = false }, global = { showWelcome = true } }
check(Chat.Welcome() == true, "Per-Character defaults read global only")
ns.DATABASE_DEFAULTS = nil
ns.L.CHAT_LOADED_SAVED, ns.L.CHAT_LOADED = ns.L.CHAT_LOADED, "Version %d."
ns.db = { profile = { showWelcome = true }, global = {} }
check(Chat.Welcome() == false, "a CHAT_LOADED with the wrong placeholder prints nothing, never an error")
ns.L.CHAT_LOADED, ns.L.CHAT_LOADED_SAVED = ns.L.CHAT_LOADED_SAVED, nil
ns.db = { profile = { showWelcome = false }, global = {} }
Clear(printed)
check(Chat.PrintWarning("Turn off Other Add-on: it fights this one.") == true, "PrintWarning ignores the switch")
check(Visible(printed[1]) == "Good to Go // Turn off Other Add-on: it fights this one.", "branded like a print")
check(Chat.PrintWarning("Turn off Other Add-on: it fights this one.") == false, "and says it once a session")

-- Center screen
check(Chat.Notice("That macro is on 3 bars.") == true, "Notice adds to UIErrorsFrame")
local notice = Last(notices)
check(notice.text == "GtG // That macro is on 3 bars.", "Short Name // Message")
check(math.abs(notice.r - 0xCC / 255) < 1e-9 and math.abs(notice.g - 0x33 / 255) < 1e-9, "red (OFF) for a refusal")
Chat.Notice("Queued.", "notice")
notice = Last(notices)
check(math.abs(notice.r - 0xCC / 255) < 1e-9, "always red: there is no gold notice")

-- Values inside a print
check(Chat.Player("Katz", "DRUID") == "|cffFF7C0AKatz|r|cffFFFFFF", "Player: class color, then TEXT again")
check(Chat.Player("Katz", "MONK") == "Katz" and Chat.Player("Katz") == "Katz", "plain for a class it doesn't hold")
check(Visible(Chat.Money(12345678)) == "1,234g 56s 78c", "Money: gold, silver, copper, grouped")
check(Visible(Chat.Money(10005)) == "1g 00s 05c", "two-digit silver and copper after gold")
check(Visible(Chat.Money(500)) == "5s 00c", "silver alone")
check(Visible(Chat.Money(7)) == "7c" and Visible(Chat.Money(-5)) == "0c", "copper alone, never negative")
check(Chat.Money(7):find("|cffEDA55Fc|r|cffFFFFFF", 1, true) ~= nil, "the coin letter colored, TEXT again after")
check(Chat.Slash("/gtg") == "|cff00BBFF/gtg|r|cffFFFFFF", "Slash: INFO, then TEXT again")

-- Sent lines
check(
	Chat.Build("BUFF_ASK", "Katz") == "{rt1} Katz is missing [Arcane Intellect]! // GtG",
	"Build: {rtN} Body // Short Name"
)
check(Chat.Build("HELLO_ES", "Katz") == "{rt1} ¡Hola, Katz! // GtG", "Build keeps es punctuation")
check(Chat.Build("THANKS_ZH", "Katz") == "{rt1} 谢谢Katz。 // GtG", "Build keeps zh punctuation")
check(Chat.Build("QUESTION_ES") == "{rt1} ¿Necesitas agua? // GtG", "a format with no arguments")
check(Chat.Build("FULL_WIDTH") == "{rt1} 准备好了吗？！ // GtG", "full-width marks stay")
check(Chat.Build("NOT_A_MARK") == "{rt1} 你好 // GtG", "and nothing else does")
check(Chat.Build("RUSSIAN") == "{rt1} Привет! // GtG", "ru")
check(Chat.Build("MISSING") == nil and Chat.Build("EMPTY") == nil, "nil for a key with no text")
check(Chat.Build("DOTS") == "{rt1} ... // GtG", "a body is sent as written")
check(Chat.Build({ key = "ALERT", marker = false }) == "{rt8} Taunted Soulflayer. // GtG", "marker = false: none")
local link = "|cffa335ee|Hitem:19019::::::::60:::::|h[Thunderfury]|h|r"
check(Chat.Build("BUFF_ASK", link):find(link, 1, true) ~= nil, "pipes stay: links survive")
check(
	Chat.Build({ text = "Got 100% of it, {name}!" }) == "{rt1} Got 100% of it, {name}! // GtG",
	"a { text } body is never formatted: a stray % can't break it"
)
check(ns:BuildAnnounceMessage("BUFF_ASK", "Katz") == Chat.Build("BUFF_ASK", "Katz"), "ns:BuildAnnounceMessage")

-- Group channel
check(Chat.GroupChannel() == nil and ns:GetGroupChatChannel() == nil, "GroupChannel: nil when solo")
group.party = true
check(Chat.GroupChannel() == "PARTY", "PARTY in a party")
group.raid = true
check(Chat.GroupChannel() == "RAID", "RAID before PARTY")
group.instance = true
check(Chat.GroupChannel() == "INSTANCE_CHAT", "INSTANCE_CHAT first")
check(ns:GetGroupChatChannel() == "INSTANCE_CHAT", "ns:GetGroupChatChannel")
group.instance, group.raid, group.party = false, false, false

-- Send
Clear(sent)
check(Chat.Send(nil, nil, "BUFF_ASK", "Katz") == false and #sent == 0, "Send no-ops on a nil channel")
check(ns:Announce(Chat.GroupChannel(), nil, "BUFF_ASK", "Katz") == false and #sent == 0, "solo: ns:Announce no-ops")
check(Chat.Send("PARTY", nil, "MISSING") == false and #sent == 0, "and on a nil message")
check(Chat.Send("PARTY", nil, "BUFF_ASK", "Katz") == true, "Send to a group")
check(
	Last(sent).message == "{rt1} Katz is missing [Arcane Intellect]! // GtG" and Last(sent).channel == "PARTY",
	"built"
)
ns:Announce("RAID", nil, { key = "ALERT", marker = false })
check(Last(sent).message == "{rt8} Taunted Soulflayer. // GtG" and Last(sent).channel == "RAID", "an alert: no marker")
local sendChat = C_ChatInfo.SendChatMessage
C_ChatInfo.SendChatMessage = nil
Chat.Send("SAY", nil, "RUSSIAN")
check(Last(legacySent).message == "{rt1} Привет! // GtG", "SendChatMessage where C_ChatInfo lacks it")
C_ChatInfo.SendChatMessage = sendChat

-- WoW Forever: no marker in numbered channels only
ns.FLAVOR = "Camelot"
check(
	Chat.Build({ key = "BUFF_ASK", channel = "CHANNEL" }, "Katz") == "Katz is missing [Arcane Intellect]! // GtG",
	"Forever: no marker in a numbered channel's line"
)
check(Chat.Build("BUFF_ASK", "Katz"):sub(1, 6) == "{rt1} ", "but group lines keep it")
check(Chat.Build({ key = "BUFF_ASK", channel = "WHISPER" }, "Katz"):sub(1, 6) == "{rt1} ", "and whispers")
Chat.Send("RAID", nil, "BUFF_ASK", "Katz")
check(Last(sent).message:sub(1, 6) == "{rt1} ", "Forever: sent to the raid with it")
Chat.Send("CHANNEL", "2", "BUFF_ASK", "Katz")
check(Last(sent).message:sub(1, 4) == "Katz", "Forever: sent to a numbered channel without it")
Advance(1)
Chat.Send("WHISPER", "Aero", "BUFF_ASK", "Katz")
check(Last(sent).message:sub(1, 6) == "{rt1} " and Last(sent).channel == "WHISPER", "and whispered with it")
check(Last(sent).target == "Aero", "to its target")
ns.FLAVOR = "Vanilla"

-- Whisper queue
Advance(1)
Clear(sent)
local start = clock
Chat.Whisper("A", "one")
Chat.Whisper("B", "two")
Chat.Whisper("C", "three")
check(#sent == 1 and sent[1].target == "A", "an empty queue whispers at once")
Advance(0.34)
check(#sent == 1, "the next waits")
Advance(0.01)
check(#sent == 2 and math.abs(sent[2].at - start - 0.35) < 1e-9, "0.35 seconds apart")
Advance(0.35)
check(#sent == 3 and sent[3].target == "C" and math.abs(sent[3].at - start - 0.70) < 1e-9, "in order")
check(Chat.Whisper(nil, "x") == false and Chat.Whisper("A", "") == false, "nothing without a name and a line")

Advance(1)
Clear(sent)
locked = true
check(Chat.Whisper("D", "locked") == true and #sent == 0, "lockdown: the whisper waits")
Advance(10)
check(#sent == 0, "while chat stays locked")
locked = false
Advance(1)
check(#sent == 1 and sent[1].target == "D", "and goes once it lifts")
locked = true
Chat.Whisper("E", "stale")
Advance(31)
locked = false
Advance(2)
check(#sent == 1, "a whisper locked out past 30 seconds is skipped, never sent stale")
locked, secret = false, true
Chat.Whisper("F", "secret")
check(#sent == 1, "a lockdown value the game hides counts as locked")
secret = false
Advance(1)
check(#sent == 2 and sent[2].target == "F", "and goes once it reads plainly")
locked = true
check(Chat.Send("PARTY", nil, "BUFF_ASK", "Katz") == false and #sent == 2, "group chat is skipped in lockdown")
locked = false

-- Parts: links packed across as few lines as fit
local parts = {}
for index = 1, 30 do
	parts[index] = "|cffa335ee|Hitem:"
		.. (19000 + index)
		.. "::::::::60:::::|h[Epic Thing Number "
		.. index
		.. "]|h|r x"
		.. index
end
local messages = Chat.BuildParts("LOOT_LIST", parts)
local within, wellFormed, joined = true, true, {}
for _, message in ipairs(messages) do
	within = within and #message <= 255
	wellFormed = wellFormed and message:sub(1, 18) == "{rt1} Handed out: " and message:sub(-7) == " // GtG"
	for part in message:gmatch("|cffa335ee.-|h|r x%d+") do
		joined[#joined + 1] = part
	end
end
check(#messages > 1 and within, "parts: every line at most 255 bytes (" .. #messages .. " lines)")
check(wellFormed, "each line repeats the format and the sign-off")
local same = #joined == #parts
for index = 1, #parts do
	same = same and joined[index] == parts[index]
end
check(same, "every part once, in order, never split")
local greedy = true
local used = 0
for index = 1, #messages - 1 do
	local count = select(2, messages[index]:gsub("|Hitem:", ""))
	used = used + count
	local roomier = Chat.Build("LOOT_LIST", table.concat(parts, ", ", used - count + 1, used + 1))
	greedy = greedy and #roomier > 255
end
check(greedy, "packed greedily: no line could take the next part")
Clear(sent)
local sentParts = Chat.SendParts("RAID", nil, "LOOT_LIST", parts)
check(#sent == #messages and #sentParts == #messages and sent[1].message == messages[1], "SendParts sends each line")
check(#Chat.SendParts(nil, nil, "LOOT_LIST", parts) == 0 and #sent == #messages, "and nothing without a channel")
local long = "|cffa335ee|Hitem:1|h[" .. string.rep("Long", 70) .. "]|h|r"
local alone = Chat.BuildParts("LOOT_LIST", { "x1", long, "x2" })
check(#alone == 3 and alone[2]:find(long, 1, true), "a part too long alone still gets its own line")
local traded = Chat.BuildParts("TRADE", { "a", "b" }, function(list)
	return list, "Katz"
end)
check(#traded == 1 and traded[1] == "{rt1} Traded a, b to Katz. // GtG", "formatArguments places the list")
ns.FLAVOR = "Camelot"
Advance(1)
Clear(sent)
Chat.SendParts("WHISPER", "Aero", "LOOT_LIST", { "a", "b" })
check(#sent == 1 and sent[1].message == "{rt1} Handed out: a, b. // GtG", "Forever: whispered parts keep the marker")
check(Chat.BuildParts("LOOT_LIST", { "a" })[1] == "{rt1} Handed out: a. // GtG", "group parts keep it too")
check(
	Chat.BuildParts("LOOT_LIST", { "a" }, nil, "CHANNEL")[1] == "Handed out: a. // GtG",
	"numbered-channel parts don't"
)
ns.FLAVOR = "Vanilla"

-- Tokens
local filled = Chat.FillTokens("Thanks {name}, 100% {spell}! {unknown}", { name = "Katz", spell = "[Arcane %1]" })
check(filled == "Thanks Katz, 100% [Arcane %1]! {unknown}", "FillTokens: plain gsub, % taken literally")
check(Chat.FillTokens("{count} left", { count = 3 }) == "3 left", "numbers too")
check(
	Chat.Build({ text = filled, channel = "WHISPER" }) == "{rt1} Thanks Katz, 100% [Arcane %1]! {unknown} // GtG",
	"a filled body signs off without formatting"
)

-- Drafts
check(Chat.Draft("Copper Vein at 45, 67", "PARTY") == true, "Draft opens the chat box")
check(Last(opened).text == "/p Copper Vein at 45, 67" and Last(opened).frame == ChatFrame1, "on its channel")
Chat.Draft("Hello there!")
check(Last(opened).text == "Hello there!", "as written: no marker, no name")
Chat.Draft("Hi", "WHISPER", "Aero")
check(Last(opened).text == "/w Aero Hi", "a whisper names its target")
Chat.Draft("Hi", "WHISPER")
check(Last(opened).text == "Hi", "and without one, opens plain")
activeBox = {}
before = #opened
check(Chat.Draft("Hi", "SAY") == false and #opened == before, "never over a box the player is typing in")
activeBox = nil
local util = ChatFrameUtil
ChatFrameUtil = nil
function ChatFrame_OpenChat(text)
	opened[#opened + 1] = { text = text }
end
Chat.Draft("Old client", "SAY")
check(Last(opened).text == "/s Old client", "ChatFrame_OpenChat where ChatFrameUtil is missing")
ChatFrameUtil = util

-- AceLocale answers a missing key with its own name: the kit reads raw, so the fallback runs
local locale = ns.L
ns.L = setmetatable({ ADDON_TITLE = "Good to Go", BUFF_ASK = "%s is missing [Arcane Intellect]!" }, {
	__index = function(self, key)
		rawset(self, key, key)
		return key
	end,
})
check(
	Chat.Build("BUFF_ASK", "Katz") == "{rt1} Katz is missing [Arcane Intellect]! // Good to Go",
	"no Short Name: the Full Name, not ADDON_SHORT_NAME"
)
local _ = ns.L.ADDON_SHORT_NAME -- AceLocale stores a key it was asked for and lacked
check(Chat.Build("BUFF_ASK", "Katz"):find("ADDON_SHORT_NAME", 1, true) == nil, "even once the key's name is stored")
check(Chat.Build("NO_SUCH_KEY") == nil, "and a missing format key builds nothing")
ns.L = locale

-- Bad translations and the length limit
ns.L.BAD_PLACEHOLDER = "%d is missing %s"
Clear(sent)
check(Chat.Build("BAD_PLACEHOLDER", "Katz") == nil, "a translation whose placeholders don't fit builds nothing")
check(Chat.Send("PARTY", nil, "BAD_PLACEHOLDER", "Katz") == false and #sent == 0, "and sends nothing, never an error")
check(
	Chat.Send("PARTY", nil, { text = string.rep("a", 300) }) == false and #sent == 0,
	"Send refuses a line over 255 bytes"
)
check(Chat.Whisper("Aero", string.rep("a", 256)) == false and #sent == 0, "and so does Whisper")
check(Chat.Send("PARTY", nil, { text = string.rep("a", 200) }) == true and #sent == 1, "a line under it goes")
local oversized = Chat.SendParts("RAID", nil, "LOOT_LIST", { string.rep("x", 300), "b" })
check(#oversized == 1 and #sent == 2, "SendParts skips a part too long alone and sends the rest")

-- The Style Guide's names
Clear(printed)
ns:PrintMessage("Hi.")
check(Visible(printed[1]) == "Good to Go // Hi.", "ns:PrintMessage")
print = say
print("all passed")
