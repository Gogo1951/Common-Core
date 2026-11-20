-- Offline smoke test for addon-kits/Tooltip-Kit: stubs the game's tooltips, TooltipDataProcessor, C_Item and
-- the login event, loads the kit once on a Retail-style client (tooltip data) and once on a Classic-style one
-- (tooltip scripts), fires its hooks and checks every line it adds, with its colors.
-- Run from Common-Core: lua5.1 scripts/test-tooltip-kit.lua

local KIT = arg[1] or "addon-kits/Tooltip-Kit/Features/Tooltip-Kit.lua"

local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
	print("ok  " .. msg)
end

local PALETTE = {
	TITLE = "FFD100",
	INFO = "00BBFF",
	BODY = "FFFFFF",
	HELP = "CCCCCC",
	TEXT = "FFFFFF",
	ON = "33CC33",
	OFF = "CC3333",
	SEPARATOR = "AAAAAA",
	MUTED = "808080",
}
local L = { ADDON_SHORT_NAME = "TA", MENU_ON = "On", MENU_OFF = "Off", MENU_MORE = "%d more" }

-- The one color a whole string is drawn in, and its text: "|cffFFD100Title|r" -> "FFD100", "Title".
local function Painted(text)
	local hex, body = text:match("|cff(%x%x%x%x%x%x)(.-)|r")
	return hex and hex:upper(), body
end
-- Every colored run in a string, in order.
local function Runs(text)
	local runs = {}
	for hex, body in text:gmatch("|cff(%x%x%x%x%x%x)(.-)|r") do
		runs[#runs + 1] = { hex = hex:upper(), text = body }
	end
	return runs
end
local function Near(a, b)
	return math.abs(a - b) < 0.01
end

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

local Tooltip = {}
Tooltip.__index = Tooltip
local function NewTooltip(name, scripts)
	return setmetatable({ name = name, lines = {}, shows = 0, hooks = {}, has = scripts }, Tooltip)
end
function Tooltip:AddLine(text, r, g, b, wrap)
	self.lines[#self.lines + 1] = { left = text, r = r, g = g, b = b, wrap = wrap }
end
function Tooltip:AddDoubleLine(left, right, r, g, b, r2, g2, b2)
	self.lines[#self.lines + 1] = { left = left, right = right, r = r, g = g, b = b, r2 = r2, g2 = g2, b2 = b2 }
end
function Tooltip:NumLines()
	return #self.lines
end
function Tooltip:Show()
	self.shows = self.shows + 1
end
function Tooltip:HasScript(name)
	return self.has[name] == true
end
function Tooltip:HookScript(name, fn)
	assert(self.has[name], "HookScript on a script " .. self.name .. " lacks: " .. name)
	self.hooks[name] = self.hooks[name] or {}
	table.insert(self.hooks[name], fn)
end
function Tooltip:Fire(name, ...)
	for _, fn in ipairs(self.hooks[name] or {}) do
		fn(self, ...)
	end
end
function Tooltip:ClearLines()
	self.lines = {}
	self:Fire("OnTooltipCleared")
end
function Tooltip:Hide()
	self:Fire("OnHide")
end
function Tooltip:SetOwner(owner, anchor)
	self.owner, self.anchor = owner, anchor
	self:ClearLines()
end
function Tooltip:ClearAllPoints()
	self.point = nil
end
function Tooltip:SetPoint(point, relativeTo, relative)
	self.point = { point, relativeTo, relative }
end
function Tooltip:GetOwner()
	return self.owner
end
function Tooltip:GetItem()
	return "Item", self.link
end
function Tooltip:GetUnit()
	return "Someone", self.unit
end
function Tooltip:GetSpell()
	return "Spell", self.spellID
end
function Tooltip:SetSpellByID(id)
	self.spellID = id
	self:AddLine("Spell " .. id)
end
function Tooltip:SetHyperlink(link)
	self.link = link
	self:AddLine("Link " .. link)
end
-- The game's own lines for a hovered thing.
function Tooltip:Fill(text)
	self:ClearLines()
	self:AddLine(text)
end

local loginFrame, postCalls, requested, combat
local TYPES = { Item = 0, Spell = 1, Unit = 2, Macro = 25 }

local function Owner(x, bag, scale, y)
	return {
		GetCenter = function()
			return x, y or 500
		end,
		GetEffectiveScale = function()
			return scale or 1
		end,
		GetBagID = bag and function()
			return bag
		end or nil,
	}
end

local function Process(kind, tooltip, data)
	for _, fn in ipairs(postCalls[TYPES[kind]] or {}) do
		fn(tooltip, data)
	end
end

local function Login()
	assert(loginFrame, "the kit waits for PLAYER_LOGIN")
	loginFrame.scripts.OnEvent(loginFrame, "PLAYER_LOGIN")
end

-- Fresh globals and a fresh copy of the kit. tdp: a Retail-style client; loggedIn: loaded after login.
local function Load(setup)
	loginFrame, postCalls, requested, combat = nil, {}, {}, false
	local legacy = not setup.tdp
	local scripts = {
		OnTooltipCleared = true,
		OnHide = true,
		OnTooltipSetItem = legacy,
		OnTooltipSetUnit = legacy,
		OnTooltipSetSpell = legacy,
	}
	GameTooltip = NewTooltip("GameTooltip", scripts)
	ItemRefTooltip = NewTooltip("ItemRefTooltip", scripts)
	function GameTooltip:SetBagItem(bag, slot)
		self.link = "|cff1eff00|Hitem:" .. (bag + 100) .. "|h[Bag Item]|h|r"
		self:Fill("Bag " .. bag .. " Slot " .. slot)
	end
	UIParent = {
		GetCenter = function()
			return 960, 540
		end,
		GetEffectiveScale = function()
			return 1
		end,
	}
	function CreateFrame()
		local frame = { scripts = {} }
		function frame:RegisterEvent(event)
			if event == "PLAYER_LOGIN" then
				loginFrame = self
			end
		end
		function frame:UnregisterEvent() end
		function frame:SetScript(name, fn)
			self.scripts[name] = fn
		end
		return frame
	end
	function IsLoggedIn()
		return setup.loggedIn or false
	end
	function InCombatLockdown()
		return combat
	end
	function hooksecurefunc(tbl, name, fn)
		local original = tbl[name]
		tbl[name] = function(...)
			original(...)
			fn(...)
		end
	end
	NUM_BAG_SLOTS = 4
	local items = {
		[6948] = { "Hearthstone", 1, 134414 },
		[4632] = { "Ornate Bronze Lockbox", 2, 132594 },
		[100] = { "Bag Item", 2, 1 },
	}
	C_Item = {
		GetItemInfo = function(item)
			local id = type(item) == "number" and item or tonumber(tostring(item):match("item:(%d+)"))
			local info = items[id]
			if info then
				return info[1], "link", info[2], nil, nil, nil, nil, nil, nil, info[3]
			end
		end,
		RequestLoadItemDataByID = function(id)
			requested[#requested + 1] = id
		end,
	}
	if setup.tdp then
		C_Item.GetItemQualityColor = function(quality)
			if quality == 2 then
				return 30 / 255, 1, 0
			end
			return 1, 1, 1
		end
		C_ClassColor = {
			GetClassColor = function(class)
				if class == "MAGE" then
					return { r = 0.25, g = 0.78, b = 0.92 }
				end
			end,
		}
		TooltipDataProcessor = {
			AddTooltipPostCall = function(kind, fn)
				postCalls[kind] = postCalls[kind] or {}
				table.insert(postCalls[kind], fn)
			end,
		}
		Enum = { TooltipDataType = TYPES }
	else
		function GetItemQualityColor(quality)
			if quality == 2 then
				return 30 / 255, 1, 0
			end
			return 1, 1, 1
		end
		C_ClassColor, RAID_CLASS_COLORS, TooltipDataProcessor, Enum = nil, nil, nil, nil
		C_Container = {
			GetContainerItemID = function(bag)
				return bag + 100
			end,
			GetContainerItemLink = function(bag)
				return "|cff1eff00|Hitem:" .. (bag + 100) .. "|h[Bag Item]|h|r"
			end,
		}
	end
	local ns = { L = L, PALETTE = PALETTE }
	assert(loadfile(KIT))("TestAddon", ns)
	return ns.TooltipKit
end

--------------------------------------------------------------------------------
-- A Retail-style client: TooltipDataProcessor
--------------------------------------------------------------------------------

print("-- with TooltipDataProcessor")
local Tip = Load({ tdp = true })

local lockboxSkill = 175
Tip.OnItem(function(block, itemID, link, tooltip)
	check(tooltip == GameTooltip, "the item hook hands over the tooltip")
	if itemID ~= 4632 then
		block:Header("Nothing Here") -- A header alone is nothing to report
		return
	end
	block:Header("Lockbox")
	block:Requirement("Requires Lockpicking", 175, lockboxSkill >= 175)
	check(link == "item-link", "and the item's link")
end, { bagsOnly = true })
check(next(postCalls) == nil, "no hook goes in before PLAYER_LOGIN")
Login()
check(#postCalls[TYPES.Item] == 1, "PLAYER_LOGIN installs the item post-call")
check(GameTooltip.hooks.OnTooltipCleared and GameTooltip.hooks.OnHide, "and watches the tooltip's clear and hide")

GameTooltip.owner = Owner(300, 0)
GameTooltip.link = "item-link"
GameTooltip:Fill("Ornate Bronze Lockbox")
local shows = GameTooltip.shows
Process("Item", GameTooltip, { id = 4632 })
local lines = GameTooltip.lines
check(#lines == 4, "the block is a spacer, a header and its row")
check(lines[2].left == " " and lines[2].right == nil, "the header adds the spacer itself")
check(Painted(lines[3].left) == "FFD100" and select(2, Painted(lines[3].left)) == "Lockbox", "title gold on the left")
check(
	Painted(lines[3].right) == "808080" and select(2, Painted(lines[3].right)) == "TA",
	"Short Name gray on the right"
)
check(Near(lines[3].r, 1) and Near(lines[3].g, 0.82) and Near(lines[3].b, 0), "the header's numeric color is gold too")
check(lines[4].left:sub(1, #Tip.INDENT) == Tip.INDENT, "rows sit one step in")
check(Painted(lines[4].left) == "FFFFFF" and Painted(lines[4].right) == "FFFFFF", "a met requirement reads white")
check(GameTooltip.shows == shows + 1, "Show() runs after the lines go in")

Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 4, "a second fire for the same show adds nothing")
GameTooltip:Fill("Ornate Bronze Lockbox")
lockboxSkill = 100
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 4, "after the tooltip clears, the block draws again")
check(Painted(GameTooltip.lines[4].left) == "CC3333", "a requirement the player is short of reads red")
check(Painted(GameTooltip.lines[4].right) == "CC3333", "on both sides")
GameTooltip:Hide()
GameTooltip.lines = { { left = "Again" } }
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 4, "hiding clears the guard too")

GameTooltip:Fill("Hearthstone")
shows = GameTooltip.shows
Process("Item", GameTooltip, { id = 6948 })
check(
	#GameTooltip.lines == 1 and GameTooltip.shows == shows,
	"a block with nothing to report draws nothing: no spacer, no header"
)

GameTooltip.owner = Owner(300, -1)
GameTooltip:Fill("Ornate Bronze Lockbox")
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 1, "bagsOnly: nothing in the bank's slots")
GameTooltip.owner = Owner(300)
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 1, "nor on an owner that isn't a bag slot")
GameTooltip.owner = Owner(300, 4)
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 4, "the last carried bag counts")
ItemRefTooltip:Fill("Ornate Bronze Lockbox")
Process("Item", ItemRefTooltip, { id = 4632 })
check(#ItemRefTooltip.lines == 1, "only GameTooltip by default")

-- Every row kind, its colors, the list cap and the total, on a second registration that takes ItemRefTooltip.
local roster = {}
for index = 1, 10 do
	roster[index] = { label = "Row " .. index, value = index }
end
Tip.OnItem(function(block, itemID)
	if itemID ~= 6948 then
		return
	end
	block:Total("Total", 25) -- First in, drawn last
	block:Header("Inventory Report")
	block:Row("Plain", 3)
	block:Item(4632, Tip.Counts({ { 7, "Bag" }, { 18, "Bank" } }))
	block:Item(99999, 1)
	block:Player("Gogo", "MAGE", 2)
	block:Player("Nobody", "NOTACLASS", 1)
	block:State("Dispense", true)
	block:State("Announce", false)
	block:Requirement("Unknown Skill", 50)
	block:Line("A sentence that wraps.")
	block:List(roster, 8)
end, { tooltips = { GameTooltip, ItemRefTooltip } })
check(#postCalls[TYPES.Item] == 2, "after login a registration installs right away")

ItemRefTooltip:Fill("Hearthstone")
Process("Item", ItemRefTooltip, { id = 6948 })
lines = ItemRefTooltip.lines
check(#lines == 1 + 2 + 9 + 9 + 1, "ItemRefTooltip when asked: spacer, header, 9 rows, 8 + more, total")
local function Line(index)
	return lines[index]
end
check(select(2, Painted(Line(3).left)) == "Inventory Report", "the header comes first")
check(Painted(Line(4).left) == "FFFFFF" and select(2, Painted(Line(4).right)) == "3", "a row: white label, white value")
local item = Line(5)
check(item.left:find("|T132594:0|t ", 1, true), "an item row carries its icon at line height")
check(
	Painted(item.left) == "1EFF00" and select(2, Painted(item.left)) == "Ornate Bronze Lockbox",
	"and its name in its quality color"
)
local runs = Runs(item.right)
check(#runs == 5, "7 Bag, 18 Bank: five runs")
check(runs[1].hex == "FFFFFF" and runs[1].text == "7", "the number first, white")
check(runs[2].hex == "808080" and runs[2].text == " Bag", "the word after it, gray")
check(runs[3].hex == "808080" and runs[3].text == ", ", "the comma gray with the words")
check(runs[4].text == "18" and runs[4].hex == "FFFFFF" and runs[5].text == " Bank", "then 18 Bank")
check(
	Painted(Line(6).left) == "808080" and select(2, Painted(Line(6).left)) == "99999",
	"an uncached item: its ID, gray"
)
check(requested[1] == 99999, "and the kit asks for it")
check(
	Painted(Line(7).left) == "3FC7EB",
	"a player's name in the Style Guide's class color, never the game's (C_ClassColor)"
)
check(Painted(Line(8).left) == "FFFFFF", "an unknown class reads white")
check(Painted(Line(9).right) == "33CC33" and select(2, Painted(Line(9).right)) == "On", "On green, MENU_ON")
check(Painted(Line(10).right) == "808080" and select(2, Painted(Line(10).right)) == "Off", "Off gray, MENU_OFF")
check(Painted(Line(11).left) == "FFFFFF" and Painted(Line(11).right) == "FFFFFF", "a requirement not known reads white")
check(Line(12).right == nil and Line(12).wrap == true, "a line wraps on its own")
check(Painted(Line(12).left) == "CCCCCC" and Line(12).left:sub(1, 1) == "|", "silver, not indented")
check(select(2, Painted(Line(20).left)) == "Row 8", "given a max of 8, a list stops at 8 rows")
check(Painted(Line(21).left) == "808080" and select(2, Painted(Line(21).left)) == "2 more", "then N more, gray")
local total = Line(22)
check(total == lines[#lines], "the total is the bottom row, like a sum")
check(
	total.left:sub(1, #Tip.INDENT) == Tip.INDENT and select(2, Painted(total.left:sub(#Tip.INDENT + 1))) == "Total",
	"Total on the left, indented"
)
check(select(2, Painted(total.right)) == "25", "the sum on the right")
local red = 0
for _, line in ipairs(lines) do
	for _, side in ipairs({ line.left or "", line.right or "" }) do
		if side:find("CC3333", 1, true) then
			red = red + 1
		end
	end
end
check(red == 0, "no red anywhere but an unmet requirement")

-- Two registrations on one tooltip: two blocks.
GameTooltip.owner = Owner(300, 0)
GameTooltip:Fill("Ornate Bronze Lockbox")
Tip.OnItem(function(block)
	block:Header("Second"):Row("Its own", 1)
end)
Process("Item", GameTooltip, { id = 4632 })
check(#GameTooltip.lines == 1 + 3 + 3, "two blocks on one tooltip each keep their own header")
check(select(2, Painted(GameTooltip.lines[6].left)) == "Second", "the second under the first")

-- Units
local unitCalls = 0
Tip.OnUnit(function(block, unit, tooltip)
	unitCalls = unitCalls + 1
	check(unit == "mouseover" and tooltip == GameTooltip, "the unit hook hands over the unit and tooltip")
	block:Header("Badge of Generosity"):Total("Gifts", 3)
end, { notInCombat = true })
GameTooltip.unit = "mouseover"
GameTooltip:Fill("Someone")
combat = true
Process("Unit", GameTooltip, {})
check(unitCalls == 0 and #GameTooltip.lines == 1, "notInCombat: nothing in combat")
combat = false
Process("Unit", ItemRefTooltip, {})
check(unitCalls == 0, "only the tooltips it was given")
Process("Unit", GameTooltip, {})
check(unitCalls == 1 and #GameTooltip.lines == 4, "out of combat, the unit block draws")
function issecretvalue(value)
	return value == "secret"
end
GameTooltip.unit = "secret"
GameTooltip:Fill("Someone")
Process("Unit", GameTooltip, {})
check(unitCalls == 1, "a secret unit is skipped")
issecretvalue = nil

-- notInCombat is the default; false draws in combat too
local defaultCalls, inCombatCalls = 0, 0
Tip.OnUnit(function(block)
	defaultCalls = defaultCalls + 1
	block:Header("Default"):Row("Row", 1)
end)
Tip.OnUnit(function(block)
	inCombatCalls = inCombatCalls + 1
	block:Header("In Combat"):Row("Row", 1)
end, { notInCombat = false })
GameTooltip.unit = "mouseover"
GameTooltip:Fill("Someone")
combat = true
Process("Unit", GameTooltip, {})
check(defaultCalls == 0, "a unit hook with no options draws nothing in combat")
check(inCombatCalls == 1, "notInCombat = false draws in combat")
combat = false

-- Spells, and a macro showing a spell
local spells = {}
Tip.OnSpell(function(block, spellID)
	spells[#spells + 1] = spellID
	block:Header("Firebolt Ranks"):List({ { "Rank 1", "Level 1" }, { "Rank 2", "Level 8" } })
end)
GameTooltip:Fill("Firebolt")
Process("Spell", GameTooltip, { id = 3110 })
check(spells[1] == 3110 and #GameTooltip.lines == 5, "the spell hook draws its block")
check(select(2, Painted(GameTooltip.lines[5].right)) == "Level 8", "a list takes { label, value } pairs")
GameTooltip:Fill("Macro")
Process("Macro", GameTooltip, { lines = { { tooltipType = TYPES.Spell, tooltipID = 7799 } } })
check(spells[2] == 7799, "a macro showing a spell counts as that spell")
GameTooltip:Fill("Macro")
Process("Macro", GameTooltip, { lines = { { tooltipType = TYPES.Item, tooltipID = 6948 } } })
check(#spells == 2, "a macro showing an item doesn't")

-- The add-on's own widgets
local function Corners(owner)
	return table.concat({ Tip.Anchor(owner) }, " ")
end
check(Corners(Owner(300)) == "BOTTOMLEFT TOPRIGHT", "Anchor: bottom left of the screen opens right and up")
check(Corners(Owner(1500)) == "BOTTOMRIGHT TOPLEFT", "right of the middle opens left")
check(Corners(Owner(300, nil, nil, 900)) == "TOPLEFT BOTTOMRIGHT", "the top half opens down")
check(Corners(Owner(1500, nil, nil, 900)) == "TOPRIGHT BOTTOMLEFT", "top right opens left and down")
check(Corners(Owner(600, nil, 2)) == "TOPRIGHT BOTTOMLEFT", "measured at the owner's scale")

local button = Owner(1500)
local tip = Tip.Help(button, "Restock List", "Buys what you keep.", {
	helper = "Shift skips it.",
	hints = { { "Open", "Left-Click" }, { "Options", "Right-Click" } },
})
lines = tip.lines
check(tip == GameTooltip and tip.owner == button and tip.anchor == "ANCHOR_NONE", "Help places it itself")
check(tip.point[1] == "BOTTOMRIGHT" and tip.point[2] == button and tip.point[3] == "TOPLEFT", "away from the edges")
check(#lines == 6, "Help: title, body, helper, spacer, two hints")
check(Painted(lines[1].left) == "FFD100" and lines[1].right == nil, "the title gold, no brand")
check(Painted(lines[2].left) == "FFFFFF" and lines[2].wrap, "the body white and wrapping, right under it")
check(Painted(lines[3].left) == "CCCCCC" and lines[3].wrap, "the helper silver")
check(lines[4].left == " ", "one spacer before the hints")
check(Painted(lines[5].left) == "00BBFF" and select(2, Painted(lines[5].left)) == "Open", "a hint's action blue")
check(Painted(lines[5].right) == "808080" and select(2, Painted(lines[5].right)) == "Left-Click", "its click gray")
check(select(2, Painted(lines[6].left)) == "Options", "no blank line between hints")
check(tip.shows > 0, "and it's shown")
tip = Tip.Help(Owner(300), "Title Only")
check(#tip.lines == 1 and tip.point[1] == "BOTTOMLEFT", "Help is at least a title")
tip = Tip.Help(Owner(300), "Pinned", nil, { anchor = "ANCHOR_TOP" })
check(tip.anchor == "ANCHOR_TOP", "opts.anchor wins")

local empty = NewTooltip("Empty", {})
Tip.Hints(empty, { { "Track", "Left-Click" } })
check(#empty.lines == 1 and empty.shows == 1, "Hints on an empty tooltip: no spacer, and it resizes")

tip = Tip.Thing(Owner(300), 133, function(block)
	block:Header("Protect List"):Line("Click to remove it.")
end)
lines = tip.lines
check(tip.spellID == 133 and lines[1].left == "Spell 133", "Thing: a number is the game's spell tooltip, first")
check(#lines == 4 and lines[2].left == " ", "then a spacer")
check(Painted(lines[3].left) == "FFD100" and lines[3].right == nil, "a gold section title, no brand")
check(Painted(lines[4].left) == "CCCCCC", "then the add-on's lines")
tip = Tip.Thing(Owner(300), "item:6948", { title = "Restock", lines = { { "Keep", 20 }, "Buys up to 20." } })
lines = tip.lines
check(lines[1].left == "Link item:6948", "a string is a link")
check(#lines == 5 and select(2, Painted(lines[4].right)) == "20", "a footer table: title, rows, sentences")
tip = Tip.Thing(Owner(300), 133, function() end)
check(#tip.lines == 1, "a footer with nothing to say adds nothing")

local own = NewTooltip("Own", {})
check(
	Tip.Block(own):Header("Own"):Row("A", 1):Done() == true and #own.lines == 2,
	"Block on an empty tooltip: no spacer"
)
check(own.lines[1].right ~= nil, "and the header still names the add-on")

local source = assert(io.open(KIT)):read("*a")
check(not source:find("NORMAL_FONT_COLOR") and not source:find("GameTooltip_Add"), "palette colors only")

--------------------------------------------------------------------------------
-- A Classic-style client: tooltip scripts
--------------------------------------------------------------------------------

print("-- without TooltipDataProcessor")
Tip = Load({ tdp = false })
local fired = 0
Tip.OnItem(function(block, itemID, link)
	fired = fired + 1
	block:Header("Lockbox"):Row("Item", itemID)
	check(link ~= nil, "the script route hands over the link")
end, { tooltips = { GameTooltip, ItemRefTooltip } })
local bagFired = {}
Tip.OnItem(function(block, itemID)
	bagFired[#bagFired + 1] = itemID
	block:Header("Dispense"):State("Will Dispense", true)
end, { bagsOnly = true })
local unitCustom = NewTooltip("NoScripts", { OnTooltipCleared = true })
Tip.OnUnit(function(block, unit)
	block:Header("Spares"):Player("Gogo", "WARRIOR", 1):Row(unit, 2)
end, { tooltips = { GameTooltip, unitCustom } })
Tip.OnSpell(function(block, spellID)
	block:Header("Ranks"):Row("Spell", spellID)
end)
check(GameTooltip.hooks.OnTooltipSetItem == nil, "no hook goes in before PLAYER_LOGIN")
Login()
check(
	#GameTooltip.hooks.OnTooltipSetItem == 1 and #ItemRefTooltip.hooks.OnTooltipSetItem == 1,
	"HookScript on each tooltip"
)
check(unitCustom.hooks.OnTooltipSetUnit == nil, "never on a script the tooltip lacks")

GameTooltip.link = "|cffffffff|Hitem:6948|h[Hearthstone]|h|r"
GameTooltip:Fill("Hearthstone")
GameTooltip:Fire("OnTooltipSetItem")
check(fired == 1 and #GameTooltip.lines == 4, "OnTooltipSetItem draws the block")
check(select(2, Painted(GameTooltip.lines[4].right)) == "6948", "with the item ID read off the link")
GameTooltip:Fire("OnTooltipSetItem")
check(fired == 1 and #GameTooltip.lines == 4, "a second fire for the same show adds nothing")
GameTooltip:Fill("Hearthstone")
GameTooltip:Fire("OnTooltipSetItem")
check(fired == 2 and #GameTooltip.lines == 4, "and draws again once the tooltip clears")

GameTooltip:SetBagItem(0, 1)
check(bagFired[1] == 100 and #GameTooltip.lines == 4, "bagsOnly hooks SetBagItem: a carried bag")
check(Painted(GameTooltip.lines[4].right) == "33CC33", "a state row in a status line")
GameTooltip:SetBagItem(-1, 1)
check(#bagFired == 1 and #GameTooltip.lines == 1, "not the bank")
GameTooltip:SetBagItem(5, 1)
check(#bagFired == 1, "nor past the last carried bag")

GameTooltip.unit = "target"
GameTooltip:Fill("Someone")
GameTooltip:Fire("OnTooltipSetUnit")
check(#GameTooltip.lines == 5, "OnTooltipSetUnit draws the unit block")
check(Painted(GameTooltip.lines[4].left) == "C69B6D", "the Style Guide's class color where the client has none")
GameTooltip.spellID = 133
GameTooltip:Fill("Fireball")
GameTooltip:Fire("OnTooltipSetSpell")
check(select(2, Painted(GameTooltip.lines[4].right)) == "133", "OnTooltipSetSpell draws the spell block")

ItemRefTooltip.link = "|cff1eff00|Hitem:4632|h[Ornate Bronze Lockbox]|h|r"
local quality = Tip.Block(NewTooltip("Q", {})):Header("Q"):Item(4632, 1)
quality:Done()
check(Painted(quality.tooltip.lines[2].left) == "1EFF00", "GetItemQualityColor where C_Item has none")

print("-- loaded after login")
Tip = Load({ tdp = true, loggedIn = true })
Tip.OnItem(function(block)
	block:Header("Late"):Row("A", 1)
end)
check(loginFrame == nil and #postCalls[TYPES.Item] == 1, "a kit loaded after login hooks right away")

print("-- a locale missing its keys")
L.ADDON_SHORT_NAME, L.MENU_ON = nil, nil
setmetatable(L, { -- AceLocale answers a missing key with its own name, and stores it
	__index = function(self, key)
		rawset(self, key, key)
		return key
	end,
})
local _ = L.MENU_ON
Tip = Load({ tdp = true, loggedIn = true })
local fallback = Tip.Block(NewTooltip("F", {})):Header("F"):State("Thing", true)
fallback:Done()
check(select(2, Painted(fallback.tooltip.lines[1].right)) == "", "no Short Name: blank, never ADDON_SHORT_NAME")
check(select(2, Painted(fallback.tooltip.lines[2].right)) == "On", "no MENU_ON: On, never the key's name")

print("all passed")
