-- Offline smoke test for addon-kits/Menu-Kit: stubs the WoW frames and APIs the kit touches, then lays out
-- panels, opens menus and sub-menus, routes button clicks and builds every helper, checking what comes out.
-- Text is measured at 6 points a character and 12 a line, so widths and wraps are predictable.
-- Run from Common-Core: lua5.1 scripts/test-menu-kit.lua

local CHAR, LINE = 6, 12
local cursor = { x = -1000, y = -1000 }
local shift = false
local popups, events, requested = {}, {}, {}

-- What a font string would draw: escapes stripped, an icon a character's room.
local function Visible(text)
	text = text:gsub("|T.-|t", "@"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	return #text
end

local Frame = {}
-- A method the stub doesn't know does nothing; a field it doesn't know is nil, as on a real frame.
local function Noop() end
Frame.__index = function(_, key)
	return Frame[key] or (key:match("^%u") and Noop) or nil
end
function Frame:Show()
	self.shown = true
end
function Frame:Hide()
	local was = self.shown
	self.shown = false
	if was and self.scripts.OnHide then
		self.scripts.OnHide(self)
	end
end
function Frame:SetShown(shown)
	if shown then
		self:Show()
	else
		self:Hide()
	end
end
function Frame:IsShown()
	return self.shown
end
function Frame:IsVisible()
	local frame = self
	while frame do
		if not frame.shown then
			return false
		end
		frame = frame.parent
	end
	return true
end
function Frame:SetScript(name, fn)
	self.scripts[name] = fn
end
function Frame:GetScript(name)
	return self.scripts[name]
end
function Frame:HookScript(name, fn)
	local before = self.scripts[name]
	self.scripts[name] = function(...)
		if before then
			before(...)
		end
		fn(...)
	end
end
function Frame:RegisterForClicks(...)
	self.registeredClicks = table.concat({ ... }, ",")
end
function Frame:GetParent()
	return self.parent
end
function Frame:GetName()
	return self.name
end
function Frame:SetFrameLevel(level)
	self.level = level
end
function Frame:GetFrameLevel()
	return self.level or 0
end
function Frame:EnableMouse(on)
	self.mouse = on and true or false
end
function Frame:IsMouseEnabled()
	return self.mouse
end
function Frame:SetSize(width, height)
	self.width, self.height = width, height
	self.sized = (self.sized or 0) + 1
end
function Frame:SetHeight(height)
	self.height = height
end
function Frame:SetWidth(width)
	self.width = width
	self.sized = (self.sized or 0) + 1 -- A panel's width is set only when it's laid out again
end
function Frame:EnableMouseWheel(on)
	self.wheel = on and true or false
end
function Frame:GetWidth()
	return self.width or 0
end
function Frame:GetHeight()
	return self.height or 0
end
function Frame:SetPoint(...)
	self.points[#self.points + 1] = { ... }
end
function Frame:ClearAllPoints()
	self.points = {}
end
function Frame:GetEffectiveScale()
	return 1
end
function Frame:GetCenter()
	return self.cx, self.cy
end
function Frame:GetLeft()
	return self.box and self.box[1]
end
function Frame:GetRight()
	return self.box and self.box[2]
end
function Frame:GetTop()
	return self.box and self.box[3]
end
function Frame:GetBottom()
	return self.box and self.box[4]
end
function Frame:LockHighlight()
	self.locked = true
end
function Frame:UnlockHighlight()
	self.locked = false
end
function Frame:RegisterEvent(event)
	events[event] = self
end
function Frame:CreateTexture()
	return setmetatable({ shown = true, scripts = {}, points = {} }, Frame)
end

local FontString = setmetatable({}, { __index = Frame })
FontString.__index = function(_, key)
	return FontString[key] or Frame[key] or (key:match("^%u") and Noop) or nil
end
function FontString:SetText(text)
	self.text = text
	self.textSetAtWidth = self.wrap and self.setWidth or nil
end
function FontString:GetText()
	return self.text
end
function FontString:SetTextColor(r, g, b)
	self.color = { r, g, b }
end
function FontString:SetWordWrap(wrap)
	self.wrap = wrap
end
function FontString:SetWidth(width)
	self.setWidth = width
end
function FontString:GetFont()
	return "Fonts\\FRIZQT__.TTF", LINE
end
function FontString:GetStringWidth()
	local width = Visible(self.text or "") * CHAR
	if self.wrap and self.setWidth and self.setWidth > 0 then
		return math.min(width, self.setWidth)
	end
	return width
end
function FontString:GetStringHeight()
	local width = Visible(self.text or "") * CHAR
	if self.wrap and self.setWidth and self.setWidth > 0 then
		return math.max(1, math.ceil(width / self.setWidth)) * LINE
	end
	return LINE
end
function Frame:CreateFontString()
	return setmetatable({ shown = true, scripts = {}, points = {} }, FontString)
end

local named = {}
function CreateFrame(_, name, parent)
	local frame = setmetatable({ shown = true, scripts = {}, points = {}, name = name, parent = parent }, Frame)
	if name then
		named[name] = frame
	end
	return frame
end
UIParent = CreateFrame("Frame", "UIParent")
function UIParent:GetWidth()
	return 1920
end
function UIParent:GetHeight()
	return 1080
end
UISpecialFrames = {}
GameTooltip = CreateFrame("GameTooltip", "GameTooltip")
function GameTooltip:SetOwner(owner)
	self.owner = owner
end
function GameTooltip:GetOwner()
	return self.owner
end
function GameTooltip:SetItemByID(id)
	self.item = id
end
-- The lines a tooltip was given, so a check can read the last one.
function GameTooltip:SetText(text)
	self.lines = { text }
end
function GameTooltip:AddLine(text, r, g, b)
	self.lines = self.lines or {}
	self.lines[#self.lines + 1] = text
	self.lastColor = r and { r, g, b }
end
function GetCursorPosition()
	return cursor.x, cursor.y
end
function IsShiftKeyDown()
	return shift
end
StaticPopupDialogs = {}
function StaticPopup_Show(which, text, _, data)
	popups[#popups + 1] = { which = which, text = text, data = data }
end
YES, NO = "Yes", "No"
local items = { [6948] = { "Hearthstone", 1, 134414 } }
C_Item = {
	GetItemInfo = function(id)
		local item = items[id]
		if item then
			return item[1], "link", item[2], nil, nil, nil, nil, nil, nil, item[3]
		end
	end,
	GetItemQualityColor = function(quality)
		return quality == 1 and 1 or 0.5, 1, 1, "ffffffff"
	end,
	RequestLoadItemDataByID = function(id)
		requested[#requested + 1] = id
	end,
}

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})
local ns = {
	L = L,
	PALETTE = {
		TITLE = "FFD100",
		INFO = "00BBFF",
		BODY = "FFFFFF",
		TEXT = "FFFFFF",
		ON = "33CC33",
		MUTED = "808080",
		SEPARATOR = "AAAAAA",
	},
	db = { profile = { a = true, b = false, c = true, gated = true, block = true }, global = {} },
}
local optionsOpened
function ns:OpenOptionsPanel(panel)
	optionsOpened = panel or "root"
end
ns.FEATURES = {
	{ store = "profile", setting = "block", name = "BLOCK", caption = "ENABLE_BLOCK", desc = "D", block = true },
	{ store = "profile", setting = "a", name = "A", caption = "ENABLE_A", desc = "D", confirm = "SURE_A" },
	{ store = "profile", setting = "b", name = "B", caption = "ENABLE_B", desc = "D" },
	{ store = "profile", setting = "c", name = "C", caption = "ENABLE_C", desc = "D", opensOptions = "c" },
	{
		store = "profile",
		setting = "gated",
		name = "G",
		caption = "ENABLE_G",
		desc = "D",
		gate = function()
			return false
		end,
	},
}

local chunk = assert(loadfile(arg[1] or "addon-kits/Menu-Kit/Features/Menu-Kit.lua"))
chunk("TestAddon", ns)
local Kit = ns.MenuKit
local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
	print("ok  " .. msg)
end

local function ShownRows(panel)
	local list = {}
	for _, row in ipairs(panel.rows) do
		if row:IsShown() then
			list[#list + 1] = row
		end
	end
	return list
end

Kit.SetText({
	on = "On",
	off = "Off",
	clicks = { RightButton = "Right-Click" },
})

-- Colors
check(Kit.Color("ON", "x") == "|cff33cc33x|r", "Color takes a palette key")
check(Kit.Color("FF8000", "x") == "|cffff8000x|r", "Color takes a raw hex")
check(Kit.Color({ 1, 0, 0 }, "x") == "|cffff0000x|r", "Color takes { r, g, b }")
check(Kit.FLYOUT_OVERLAP == 8 and Kit.FLYOUT_RISE == 8, "sub-menus overlap by 8 and rise 8")
check(Kit.FLYOUT_GAP == 0, "v1's FLYOUT_GAP, from the row, now overlaps")

-- v1: a panel made and filled by the add-on
local panel = Kit.CreatePanel("TestPanel")
panel:Show()
panel:Render({
	{ kind = "header", left = "Test", right = "1.0" },
	{ kind = "spacer" },
	{ kind = "toggle", left = "Short", on = true },
	{ kind = "section", left = "Group" },
	{ kind = "action", left = "Clear", click = "RightButton", onClick = function() end },
	{ kind = "submenu", left = "Settings", submenu = "x" },
	{ kind = "hint", left = "Old hint", right = "Click" },
	{ kind = "action", left = "Move", click = "Drag", onClick = function() end },
	{ kind = "choice", left = "Picked", selected = true },
	{ kind = "choice", left = "Other" },
	{ kind = "choice", left = "Off" },
	{ kind = "value", left = "Cooldown", right = "0 Seconds" },
	{ kind = "value", left = "Delay", right = "Off" },
})
local rows = ShownRows(panel)
check(#rows == 15, "a spacer goes in above each heading that doesn't follow one")
check(rows[4].entry.kind == "spacer" and rows[5].entry.kind == "section", "the spacer sits before the section")
check(rows[7].entry.kind == "spacer" and rows[8].entry.kind == "submenu", "and before the submenu")
check(rows[5].right:IsShown() == false, "a section with no right side draws none")
check(rows[6].right.text == "Right-Click", "an action row names the button's kept click on the right")
check(rows[6].right.color[1] > 0.5 and rows[6].right.color[1] < 0.51, "in MUTED")
check(rows[6].left.color[3] == 1 and rows[6].left.color[1] == 0, "an action row is INFO on the left")
check(rows[10].right.text == "Drag", "a gesture is named on the right")
check(rows[10].right.color[1] > 0.5 and rows[10].right.color[1] < 0.51, "in MUTED")
local VALUE = { 1, 1, 0x99 / 255 }
local function Is(color, want)
	for index = 1, 3 do
		if math.abs(color[index] - want[index]) > 0.01 then
			return false
		end
	end
	return true
end
check(Is(rows[11].left.color, VALUE), "the picked choice is VALUE, even with no VALUE in ns.PALETTE")
check(Is(rows[12].left.color, { 1, 1, 1 }), "a choice not picked is white")
check(Is(rows[13].left.color, { 0x80 / 255, 0x80 / 255, 0x80 / 255 }), "an Off choice is gray")
check(rows[11].left.text == Kit.CHECK_MARK .. " Picked", "the check sits on the left of the pick, then a space")
check(rows[12].left.text == Kit.CHECK_BLANK .. " Other", "a choice not picked keeps the check's room empty")
check(rows[11].right:IsShown() == false, "a picked choice draws nothing on the right")
check(Is(rows[14].right.color, VALUE), "a value is VALUE, 0 included")
check(Is(rows[15].right.color, { 0x80 / 255, 0x80 / 255, 0x80 / 255 }), "a value of Off is gray")
check(rows[6].registeredClicks == "AnyUp", "a row answers any mouse button")
check(rows[8].opensFlyout and rows[8].arrow:IsShown(), "v1: a submenu row carries the arrow")
check(rows[9].left.color[1] == 0 and rows[9].right.color[1] == 0, "v1's hint still draws, blue both sides")
check(panel.width >= 128 and panel.width <= 320, "the panel sits between MIN_WIDTH and MAX_WIDTH")
check(rows[3].height == 28, "a row is a line plus 8 above and below")
check(rows[3].left.height == 12, "a one-line label is pinned to the line height")
check(rows[1].points[1][4] == 8 and rows[1].points[1][5] == -8, "rows sit 8 in from the plate, the first 8 down")
check(rows[1].left.points[1][2] == 8 and rows[1].left.points[1][3] == -8, "text sits 8 in from its row, 8 down")
local rowsHeight = 0
for _, row in ipairs(rows) do
	rowsHeight = rowsHeight + row.height
end
check(panel.height == rowsHeight + 16, "the panel is its rows plus 8 above and below: 16 from the plate to the text")
check(rows[2].height == 16 and rows[2].left:IsShown() == false, "a spacer is 16 with nothing drawn")

-- A list of values: the check on the left, each value on the right, the pick VALUE, the rest white, Off gray
panel:Render({
	{ kind = "choice", right = "1,000g", selected = true },
	{ kind = "choice", right = "1g" },
	{ kind = "choice", right = "Off" },
})
rows = ShownRows(panel)
check(
	rows[1].left.text == Kit.CHECK_MARK and rows[2].left.text == Kit.CHECK_BLANK,
	"a value's row carries only the check or its room on the left"
)
check(rows[1].right.text == "1,000g" and Is(rows[1].right.color, VALUE), "the picked value is VALUE on the right")
check(Is(rows[2].right.color, { 1, 1, 1 }), "a value not picked is white")
check(Is(rows[3].right.color, { 0x80 / 255, 0x80 / 255, 0x80 / 255 }), "an Off value is gray")

-- Wrapping
local long = string.rep("Silence Sounds ", 6) -- 90 characters, 540 points
local sizedBefore = panel.sized
panel:Render({ { kind = "toggle", left = long, on = false }, { kind = "note", left = long } })
rows = ShownRows(panel)
check(panel.width == 320, "a long label caps the panel at 320")
check(panel.sized == sizedBefore + 1, "and lays it out again")
check(rows[1].left.wrap and rows[1].height > 28, "the label wraps and the row grows")
check(rows[1].right:IsShown() and rows[1].right.text == "Off", "the right side stays")
check(rows[1].left.setWidth == 320 - 32 - 4 - 16 - 18, "the label wraps within what its right side leaves")
check(rows[1].left.textSetAtWidth == rows[1].left.setWidth, "its text is set again after the width, so it re-wraps")
check(rows[1].left.height == 36 and rows[1].height == 52, "the label is pinned to its measured height, the row to that")
check(rows[2].left.wrap and rows[2].left.setWidth == 288, "a note wraps to the panel")
check(rows[2].left.height == 24 and rows[2].height == 40, "and its row grows to its two lines")

-- Laid out again only when what the rows show changes
sizedBefore = panel.sized
local clicked = 0
panel:Render({
	{ kind = "toggle", left = long, on = false },
	{
		kind = "note",
		left = long,
		onClick = function()
			clicked = clicked + 1
		end,
	},
})
check(panel.sized == sizedBefore + 1, "a row that becomes clickable lays it out again")
sizedBefore = panel.sized
panel:Render({
	{ kind = "toggle", left = long, on = false },
	{
		kind = "note",
		left = long,
		onClick = function()
			clicked = clicked + 10
		end,
	},
})
check(panel.sized == sizedBefore, "the same rows aren't laid out again")
ShownRows(panel)[2].scripts.OnClick(ShownRows(panel)[2])
check(clicked == 10, "but their clicks follow the new entries")

-- Items, values and hover-only right sides
panel:Render({
	{ kind = "item", itemID = 6948, count = 4, right = "Bag", rightOnHover = true },
	{ kind = "item", itemID = 12345 },
	{ kind = "value", left = "Total", right = "12" },
	{ kind = "item", left = "Pre-drawn v1 item row" },
})
rows = ShownRows(panel)
check(rows[1].left.text == "|T134414:0|t Hearthstone |cffffffffx4|r", "an item row: icon, name, count")
check(rows[1].left.color[1] == 1, "the name in its quality color")
check(not rows[1].right:IsShown(), "a hover-only right side hides until hovered")
rows[1].box = { 0, 300, 100, 80 }
cursor.x, cursor.y = 10, 90
rows[1].scripts.OnEnter(rows[1])
check(rows[1].right:IsShown(), "and shows on hover")
check(GameTooltip.item == 6948, "hovering an item shows the item")
rows[1].scripts.OnLeave(rows[1])
check(not rows[1].right:IsShown(), "and hides again on leave")
cursor.x, cursor.y = -1000, -1000
check(rows[2].left.text == "Loading ID: 12345" and requested[1] == 12345, "an uncached item asks for itself")
check(events.GET_ITEM_INFO_RECEIVED ~= nil, "and waits for it")
check(rows[3].left.color[1] == 1 and rows[3].right.text == "12", "a value row reads BODY and TEXT")
check(rows[4].left.text == "Pre-drawn v1 item row", "a v1 item row with its own left still draws")

-- A row's helper is a new section of its tooltip: a spacer above it, gray
panel:Render({
	{ kind = "item", itemID = 4544, helper = "Click to take it off your Ignore List." },
	{ kind = "action", left = "Plain", tooltip = Kit.OptionTooltip("Plain", "Does a thing."), helper = "Shift skips it." },
	{ kind = "item", itemID = 6948 },
})
rows = ShownRows(panel)
GameTooltip.lines = {}
rows[1].scripts.OnEnter(rows[1])
check(GameTooltip.item == 4544 and #GameTooltip.lines == 2, "an item row's helper follows the item's tooltip")
check(GameTooltip.lines[1] == " ", "after a spacer")
check(GameTooltip.lines[2] == "Click to take it off your Ignore List.", "then the helper")
check(math.abs(GameTooltip.lastColor[1] - 0.8) < 0.01, "in HELP gray")
rows[2].scripts.OnEnter(rows[2])
check(#GameTooltip.lines == 4 and GameTooltip.lines[3] == " ", "a row's own tooltip gets the spacer too")
GameTooltip.lines = {}
rows[3].scripts.OnEnter(rows[3])
check(#GameTooltip.lines == 0, "no helper, nothing added")

-- A menu, its sub-menus and the public names
local refreshed = 0
local FLYOUTS = {}
function FLYOUTS.full()
	return {
		{ kind = "toggle", left = "Inside", on = true },
		{ kind = "submenu", left = "Deeper", submenu = "deeper" },
	}
end
function FLYOUTS.empty()
	return {}
end
function FLYOUTS.deeper()
	return { { kind = "choice", left = "Pick", selected = true } }
end
local ran = {}
local function Build()
	local entries = { { kind = "header", left = "Test Add-on", right = "1.0" }, { kind = "spacer" } }
	Kit.FeatureBlock(entries, {
		key = "full",
		title = "Feature",
		state = "On",
		stateColor = "ON",
		description = "Does a thing.",
		toggle = {
			name = "Enable Feature",
			desc = "Turns it on.",
			click = "RightButton",
			flip = function()
				ran[#ran + 1] = "flip"
			end,
		},
	})
	Kit.FeatureBlock(entries, { key = "empty", title = "Quiet", state = "Off", stateColor = "MUTED" })
	Kit.MoreFeatures(entries)
	Kit.OptionsRow(entries, "Test Options")
	return entries
end
local menu = Kit.CreateMenu({
	name = "TestAddonMenu",
	build = Build,
	flyouts = FLYOUTS,
	afterChange = function()
		refreshed = refreshed + 1
		Kit.RefreshAll()
	end,
})
check(UISpecialFrames[1] == "TestAddonMenu", "Escape closes the named menu")
check(ns.ShowMenu and ns.HideMenu and ns.RefreshMenu == Kit.RefreshAll, "the first menu publishes v1's names")
check(ns.IsMenuShown and ns.IsMenuFrame and ns.OpenFlyout, "all of them")
check(Kit.CreateMenu({ build = Build, publish = false }) and Kit.mainMenu == menu, "a second menu doesn't take them")

local button = CreateFrame("Button", "TestButton")
button.cx, button.cy = 1800, 1000 -- Top right
button.box = { 1790, 1810, 1010, 990 }
menu.frame:Hide()
ns.ShowMenu(button, nil, "hover")
check(menu:IsShown(), "hovering the button opens the menu")
local point = menu.frame.points[1]
check(point[1] == "TOPRIGHT" and point[3] == "BOTTOMLEFT" and point[4] == -2, "top right: below and left, 2 apart")
check(menu.frame.tooltipAnchor == "ANCHOR_LEFT", "row tooltips open on the same side")

rows = ShownRows(menu.frame)
local byText = {}
for _, row in ipairs(rows) do
	if row.entry.left then
		byText[row.entry.left] = row
	end
end
check(byText.Feature.opensFlyout and byText.Feature.arrow:IsShown(), "a title whose flyout has rows gets the arrow")
check(not byText.Quiet.opensFlyout and not byText.Quiet.arrow:IsShown(), "an empty flyout means no arrow")
check(not byText.Quiet.highlight.shown, "and no highlight")
check(byText.Toggle.right.text == "Right-Click", "the Toggle row names the kept Right-Click")
check(not byText["Test Options"].right:IsShown(), "the Options row names no click")
GameTooltip.lines = {}
byText.Toggle.scripts.OnEnter(byText.Toggle)
check(GameTooltip.lines[#GameTooltip.lines] == "Turns it on.", "its tooltip is the option's own text, no shortcut line")
local more = byText["More Features"]
check(more and more.opensFlyout, "More Features opens its flyout")
check(more.right.text:find("2 On", 1, true) and more.right.text:find("1 Off", 1, true), "it counts: 2 On, 1 Off")
check(more.right.text == "|cff33cc332 On|r|cffffffff,|r |cff8080801 Off|r", "On green, comma white, Off gray")
local onRight = byText.Feature.right.points[1]
check(onRight[1] == "TOPRIGHT" and onRight[2] < -8, "a right side ends where the arrow's column begins")

-- Sub-menus
byText.Feature.scripts.OnEnter(byText.Feature)
local flyout = menu.panels[2]
check(flyout and flyout:IsShown(), "hovering a title opens its flyout")
check(byText.Feature.locked, "the title keeps its highlight while its flyout is open")
local place = flyout.points[1]
check(place[1] == "TOPRIGHT" and place[3] == "TOPLEFT" and place[4] == 0 and place[5] == 8, "it overlaps, rising 8")
local deeper = ShownRows(flyout)[3] -- After the spacer the kit puts above a heading
deeper.scripts.OnEnter(deeper)
check(menu.panels[3] and menu.panels[3]:IsShown(), "a sub-menu opens a sub-menu")
byText.Toggle.scripts.OnEnter(byText.Toggle)
check(not flyout:IsShown() and not menu.panels[3]:IsShown(), "hovering another row closes them")
check(not byText.Feature.locked, "and lets go of the highlight")
ns.OpenFlyout("empty")
check(not flyout:IsShown(), "an empty flyout never opens")

-- Clicks, both ways
refreshed = 0
byText.Toggle.scripts.OnClick(byText.Toggle)
check(ran[1] == "flip" and refreshed == 1, "a row click runs and ends in afterChange")
check(menu:HandleClick(button, "RightButton") and ran[2] == "flip", "the button's click runs the same row")
check(refreshed == 2, "and ends in afterChange too")
check(menu:HandleClick(button, "MiddleButton") == false, "a click with no job does nothing")
shift = true
optionsOpened = nil
check(not menu:HandleClick(button, "MiddleButton") and not optionsOpened, "Shift + Middle-Click opens nothing")
shift = false
menu:Hide()
ns.ShowMenu(button, nil, "hover")
check(menu:HandleClick(button, "LeftButton") and menu:IsShown(), "Left-Click holds a menu hover opened")
check(menu.state.closeDelay == 1.0, "for a second")
check(menu:HandleClick(button, "LeftButton") and not menu:IsShown(), "a second Left-Click closes it")
check(menu:HandleClick(button, "LeftButton") and menu:IsShown(), "and a third opens it again")
local erased
local quiet = Kit.CreateMenu({
	build = function()
		return {}
	end,
	fallback = {
		LeftButton = function()
			erased = true
		end,
	},
	publish = false,
})
quiet:HandleClick(button, "LeftButton")
check(not erased and quiet:IsShown(), "Left-Click toggles the menu even with a Left-Click fallback")

-- More Features' flyout
ns.OpenFlyout(Kit.MORE_FEATURES)
local switches = ShownRows(menu.panels[2])
check(#switches == 3 and switches[1].entry.left == "A", "More Features' flyout lists the compact features")
switches[2].scripts.OnClick(switches[2])
check(ns.db.profile.b == true, "a switch writes its setting")
switches = ShownRows(menu.panels[2])
switches[1].scripts.OnClick(switches[1])
check(ns.db.profile.a == true and popups[1] and popups[1].text == "SURE_A", "a confirmed switch asks first")
popups[1].data()
check(ns.db.profile.a == false, "and switches once answered Yes")
check(StaticPopupDialogs.TestAddonMenuKitConfirm.text == "%s", "the question is never formatted")
switches = ShownRows(menu.panels[2])
switches[3].scripts.OnClick(switches[3])
check(optionsOpened == "c" and not menu:IsShown(), "a feature with its own panel opens it")

-- Lists, the cursor menu, closing
local list = {}
local listed = {}
for index = 1, 10 do
	listed[index] = { kind = "value", left = "Row " .. index, right = tostring(index) }
end
Kit.List(list, listed)
check(#list == 10 and list[10].kind == "value", "a list shows every row by default")
list = {}
Kit.List(list, listed, 8)
check(#list == 9 and list[9].kind == "note" and list[9].left == "2 more", "given a max, it stops there, then N more")
local context = Kit.CreateMenu({
	name = "TestContext",
	build = function()
		return { Kit.MenuHeader("Attack") }
	end,
	publish = false,
})
Kit.SetText({ shortName = "TA" })
cursor.x, cursor.y = 300, 200 -- Bottom left
context:Show(nil, "cursor")
point = context.frame.points[1]
check(point[1] == "BOTTOMLEFT" and point[4] == 300 and point[5] == 200, "a right-click menu opens at the cursor")
check(ShownRows(context.frame)[1].right.text == "TA", "its header names the add-on's Short Name")
cursor.x, cursor.y = -1000, -1000
context:OnUpdate(0.45)
check(context:IsShown(), "it waits while the cursor is away")
context:OnUpdate(0.05)
check(not context:IsShown(), "and closes 0.5 seconds after the cursor leaves")
check(Kit.IsMenuFrame(ShownRows(menu.frame)[1] or menu.frame), "IsMenuFrame knows the kit's menus")
check(not Kit.IsMenuFrame(button), "and nothing else")
-- Disabled rows, gestures, windows
local gray = Kit.CreatePanel("TestGray")
local clicked = false
gray:Render({
	{
		kind = "action",
		left = "Share Quest",
		disabled = true,
		onClick = function()
			clicked = true
		end,
	},
	{ kind = "action", left = "Move Quest Arrow", click = "Drag" },
})
gray:Show()
rows = ShownRows(gray)
check(rows[1].left.color[1] > 0.5 and rows[1].left.color[1] < 0.51, "a disabled row is gray on the left")
check(not rows[1].highlight.shown, "and has no highlight")
rows[1].scripts.OnClick(rows[1])
check(not clicked, "and its click does nothing")
check(rows[2].right.text == "Drag", "a gesture's name is drawn on the right like a click")
check(
	Kit.WindowTitle("Buff Duty") == "|cffffffffBuff Duty|r |cffaaaaaa//|r |cff00bbffTA|r",
	"a window title: white, gray slashes, blue Short Name"
)
local window = CreateFrame("Frame", "TestWindow", UIParent)
local line = Kit.AddOptionsLine(window, "Options", function()
	return { { kind = "toggle", left = "Your Party", on = true, onClick = function() end } }
end)
window.box = { 100, 420, 600, 400 } -- left, right, top, bottom
window.cx, window.cy = 260, 500 -- Left half: the flyout opens right
line.box = { 108, 412, 432, 412 } -- ROW_INSET in from the window's sides
line.scripts.OnEnter(line)
check(line.menu:IsShown(), "hovering a window's Options line opens its flyout")
line.cx, line.cy = 260, 422
line.menu:Hide()
line.scripts.OnEnter(line)
local linePoint = line.menu.frame.points[1]
check(
	linePoint[1] == "TOPLEFT" and linePoint[3] == "TOPRIGHT" and linePoint[4] == -(8 - 8),
	"the line's flyout overlaps the window's edge by 8, not the line's end"
)
line.box = { 100, 420, 432, 412 }
line.menu:Hide()
line.scripts.OnEnter(line)
check(line.menu.frame.points[1][4] == -8, "measured from where the line really ends")
line.menu:Hide()

-- A flyout with its own afterChange still redraws after a click
local skip, afterRan = false, 0
local skipLine = Kit.AddOptionsLine(window, "Options", function()
	return {
		{
			kind = "toggle",
			left = "Skip",
			on = skip,
			onClick = function()
				skip = not skip
			end,
		},
	}
end, function()
	afterRan = afterRan + 1
end)
skipLine.box, skipLine.cx, skipLine.cy = line.box, line.cx, line.cy
skipLine.scripts.OnEnter(skipLine)
local skipRow = ShownRows(skipLine.menu.frame)[1]
skipRow.scripts.OnClick(skipRow)
check(afterRan == 1, "a flyout's own afterChange runs")
check(ShownRows(skipLine.menu.frame)[1].entry.on == true, "and the kit still redraws it, showing the new state")
skipLine.menu:Hide()

-- A window laid out as a menu is: 28-point rows lit across the window, the foot a menu's, 16 under the last text
check(Kit.ROW_HEIGHT == 28 and Kit.WINDOW_SPACER == 16, "a window's rows are 28 and its spacer 16")
local titled = CreateFrame("Frame", "TestTitled", UIParent)
local titleText, closeButton = Kit.AddWindowHeader(titled, "Buff Duty")
local tp, cp = titleText.points[1], closeButton.points[1]
check(tp[1] == "TOPLEFT" and tp[4] == 16 and tp[5] == -16, "the title's text sits 16 from the top and left")
check(cp[1] == "RIGHT" and cp[4] == -16 and cp[5] == -22, "the close button sits 16 from the right, on the title's line")
check(Kit.WINDOW_BODY_TOP == 64, "the body starts under the title bar and two spacers' room")
local body = CreateFrame("Frame", "TestBody", UIParent)
local amounts = Kit.AddWindowRow(body, function()
	return { { kind = "choice", left = "1g", selected = true, onClick = function() end } }
end)
check(amounts.highlight.shown and amounts.arrow.shown, "a row with a flyout lights and carries the arrow")
check(amounts.left.points[1][1] == "LEFT" and amounts.left.points[1][2] == 8, "its text sits 8 in from the row")
check(amounts.right.points[1][2] == amounts.arrow, "its right side ends where the arrow's column begins")
local under = Kit.PlaceWindowRow(amounts, -Kit.WINDOW_BODY_TOP)
local p1, p2 = amounts.points[1], amounts.points[2]
check(
	p1[1] == "TOPLEFT" and p1[4] == 8 and p1[5] == -64 and p2[1] == "TOPRIGHT" and p2[4] == -8,
	"a row spans the window 8 in from each side, so its highlight covers the whole line"
)
check(under == -92, "placing a row returns the y under it")
amounts.scripts.OnEnter(amounts)
check(amounts.menu:IsShown() and amounts.locked, "hovering anywhere on the row opens its flyout and keeps it lit")
amounts.menu:Hide()
check(not amounts.locked, "the row goes dark when its flyout closes")

local shared = Kit.CreateMenu({
	publish = false,
	build = function()
		return { { kind = "choice", left = "Off" } }
	end,
})
local rowA, rowB = Kit.AddWindowRow(body, shared), Kit.AddWindowRow(body, shared)
check(rowA.menu == shared and rowB.menu == shared, "rows can share one menu")
rowA.scripts.OnEnter(rowA)
rowB.scripts.OnEnter(rowB)
check(not rowA.locked and rowB.locked, "only the row the shared menu is open off stays lit")
shared:Hide()
check(not rowB.locked, "and it goes dark when the menu closes")

local heads = Kit.AddWindowRow(body)
check(
	not heads.arrow.shown and not heads.highlight.shown and heads.mouse == false,
	"a row with no flyout is a plain line: no arrow, no highlight, no mouse"
)
check(heads.right.points[1][1] == "RIGHT" and heads.right.points[1][2] == -8, "its right side ends 8 in from the row")

local foot, footLine = Kit.AddOptionsLine(body, "Options", function()
	return { { kind = "toggle", left = "Lock", on = false, onClick = function() end } }
end)
check(foot.left.text == "|cff00bbffOptions|r" and foot.arrow.shown, "the Options line is blue with the arrow")
local last = Kit.PlaceOptionsLine(foot, footLine, under)
check(
	footLine.points[1][4] == 16 and footLine.points[1][5] == -112 and footLine.points[2][4] == -16,
	"the separator sits a spacer and 4 under the body, across the text's width"
)
check(foot.points[1][5] == -116 and last == -144, "the Options line follows the separator's 8")
check(Kit.WindowHeight(last) == 152, "a window ending on a row ends 16 under its text")
check(Kit.WindowHeight(-200, true) == 216, "one ending on bare text ends 16 under it too")
check(Kit.WindowWidth(100) == 208 and Kit.WindowWidth(250) == 288, "a window's width is a multiple of 16, at least 200")

-- A gray row with a sub-menu: its arrow gray, and it opens nothing
local grayMenu = Kit.CreateMenu({
	publish = false,
	build = function()
		return {
			{ kind = "submenu", left = "Gray", submenu = "full", disabled = true },
			{ kind = "submenu", left = "Live", submenu = "full" },
		}
	end,
	flyouts = FLYOUTS,
})
local grayButton = CreateFrame("Button", "TestGrayButton")
grayButton.cx, grayButton.cy = 200, 200
grayMenu:Show(grayButton, "click")
rows = ShownRows(grayMenu.frame)
rows[2] = rows[#rows] -- past the spacer the kit puts above a heading
check(rows[1].arrow:IsShown() and rows[1].arrow.text:find(":128:128:128|t", 1, true), "a gray row's arrow is gray")
check(rows[2].arrow.text == Kit.SUBMENU_ARROW, "a live row's stays white")
check(not rows[1].opensFlyout, "a gray row opens no sub-menu")
rows[1].scripts.OnEnter(rows[1])
check(not (grayMenu.panels[2] and grayMenu.panels[2]:IsShown()), "not on hover")
rows[1].scripts.OnClick(rows[1])
check(not (grayMenu.panels[2] and grayMenu.panels[2]:IsShown()), "nor on a click")
rows[2].scripts.OnEnter(rows[2])
check(grayMenu.panels[2] and grayMenu.panels[2]:IsShown(), "while a live one does")
-- A panel grows to fit its rows: well past the old 20-row cap, it still shows every row
local longEntries = {}
for index = 1, 100 do
	longEntries[index] = { kind = "choice", left = "Bag " .. index, onClick = function() end }
end
local mainPanel = Kit.CreatePanel("TestLongMain")
mainPanel:Show()
mainPanel:Render({ unpack(longEntries, 1, 30) })
check(#ShownRows(mainPanel) == 30 and mainPanel.height == 30 * 28 + 16, "a 30-row menu shows every row")
check(not mainPanel.wheel and not mainPanel.thumb, "with no wheel and no thumb")

-- A panel that would run off the screen (1080 less 64) scrolls, its view a whole number of rows, the wheel moving it
local longPanel = Kit.CreatePanel("TestLong")
longPanel:Show()
longPanel:Render(longEntries)
rows = ShownRows(longPanel)
check(#rows == 35 and rows[1].entry.left == "Bag 1", "a 100-row list shows the first 35 that fit")
check(longPanel.height == 1080 - 64, "and stays as tall as the screen allows")
check(longPanel.wheel and longPanel.thumb:IsShown(), "the wheel scrolls it, and a thumb shows where it sits")
longPanel.scripts.OnMouseWheel(longPanel, -1)
rows = ShownRows(longPanel)
check(rows[1].entry.left == "Bag 4" and rows[1].points[1][5] == -8, "a notch down moves it 3 rows")
longPanel:Render(longEntries)
check(ShownRows(longPanel)[1].entry.left == "Bag 4", "a redraw keeps the place")
for _ = 1, 40 do
	longPanel.scripts.OnMouseWheel(longPanel, -1)
end
rows = ShownRows(longPanel)
check(#rows == 35 and rows[35].entry.left == "Bag 100", "it stops with the last row at the bottom")
for _ = 1, 40 do
	longPanel.scripts.OnMouseWheel(longPanel, 1)
end
check(ShownRows(longPanel)[1].entry.left == "Bag 1", "and with the first at the top")
longPanel:Render({ longEntries[1], longEntries[2] })
check(
	#ShownRows(longPanel) == 2 and not longPanel.wheel and not longPanel.thumb:IsShown(),
	"a short list doesn't scroll"
)

-- A dropdown hangs MENU_GAP under its field, or over it
local dropdown = Kit.CreateDropdownMenu("TestDropdown")
local field = CreateFrame("Button", "TestField")
field.cx, field.cy = 200, 600
local dropFrame = named.TestDropdown
dropdown:Open(field, { { kind = "choice", left = "One", onClick = function() end } })
local dropPoint = dropFrame.points[1]
check(
	dropPoint[1] == "TOPLEFT" and dropPoint[3] == "BOTTOMLEFT" and dropPoint[5] == -2,
	"a dropdown opens 2 under its field"
)
dropdown:Close()
dropdown:Open(field, { { kind = "choice", left = "One", onClick = function() end } }, nil, true)
dropPoint = dropFrame.points[1]
check(dropPoint[1] == "BOTTOMLEFT" and dropPoint[3] == "TOPLEFT" and dropPoint[5] == 2, "or 2 over it")
dropdown:Close()

print("all passed")
