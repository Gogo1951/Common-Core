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
	clicks = { RightButton = "Right-Click", ShiftMiddleButton = "Shift + Middle-Click" },
})

-- Colors
check(Kit.Color("ON", "x") == "|cff33cc33x|r", "Color takes a palette key")
check(Kit.Color("FF8000", "x") == "|cffff8000x|r", "Color takes a raw hex")
check(Kit.Color({ 1, 0, 0 }, "x") == "|cffff0000x|r", "Color takes { r, g, b }")
check(Kit.FLYOUT_OVERLAP == 16 and Kit.FLYOUT_RISE == 12, "sub-menus overlap by 16 and rise 12")
check(Kit.FLYOUT_GAP == -8, "v1's FLYOUT_GAP, from the row, now overlaps")

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
})
local rows = ShownRows(panel)
check(#rows == 9, "a spacer goes in above each heading that doesn't follow one")
check(rows[4].entry.kind == "spacer" and rows[5].entry.kind == "section", "the spacer sits before the section")
check(rows[7].entry.kind == "spacer" and rows[8].entry.kind == "submenu", "and before the submenu")
check(rows[5].right:IsShown() == false, "a section with no right side draws none")
check(rows[6].right.text == "Right-Click", "an action row names its click on the right")
check(rows[6].left.color[3] == 1 and rows[6].left.color[1] == 0, "an action row is INFO on the left")
check(rows[6].right.color[1] > 0.5 and rows[6].right.color[1] < 0.51, "and MUTED on the right")
check(rows[8].opensFlyout and rows[8].arrow:IsShown(), "v1: a submenu row carries the arrow")
check(rows[9].left.color[1] == 0 and rows[9].right.color[1] == 0, "v1's hint still draws, blue both sides")
check(panel.width >= 128 and panel.width <= 320, "the panel sits between MIN_WIDTH and MAX_WIDTH")
check(rows[3].height == 20, "a row is a line plus 4 above and below")
check(rows[3].left.height == 12, "a one-line label is pinned to the line height")
check(rows[1].points[1][4] == 8 and rows[1].points[1][5] == -12, "rows sit 8 in from the plate, the first 12 down")
check(rows[1].left.points[1][2] == 8 and rows[1].left.points[1][3] == -4, "text sits 8 in from its row, 4 down")
local rowsHeight = 0
for _, row in ipairs(rows) do
	rowsHeight = rowsHeight + row.height
end
check(panel.height == rowsHeight + 24, "the panel is its rows plus 12 above and below: 16 from the plate to the text")
check(rows[2].height == 16 and rows[2].left:IsShown() == false, "a spacer is 16 with nothing drawn")

-- Wrapping
local long = string.rep("Silence Sounds ", 6) -- 90 characters, 540 points
local sizedBefore = panel.sized
panel:Render({ { kind = "toggle", left = long, on = false }, { kind = "note", left = long } })
rows = ShownRows(panel)
check(panel.width == 320, "a long label caps the panel at 320")
check(panel.sized == sizedBefore + 1, "and lays it out again")
check(rows[1].left.wrap and rows[1].height > 20, "the label wraps and the row grows")
check(rows[1].right:IsShown() and rows[1].right.text == "Off", "the right side stays")
check(rows[1].left.setWidth == 320 - 32 - 4 - 16 - 18, "the label wraps within what its right side leaves")
check(rows[1].left.textSetAtWidth == rows[1].left.setWidth, "its text is set again after the width, so it re-wraps")
check(rows[1].left.height == 36 and rows[1].height == 44, "the label is pinned to its measured height, the row to that")
check(rows[2].left.wrap and rows[2].left.setWidth == 288, "a note wraps to the panel")
check(rows[2].left.height == 24 and rows[2].height == 32, "and its row grows to its two lines")

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
check(byText.Toggle.right.text == "Right-Click", "the Toggle row names its click")
check(byText["Test Options"].right.text == "Shift + Middle-Click", "the Options row names Shift + Middle-Click")
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
check(place[1] == "TOPRIGHT" and place[3] == "TOPLEFT" and place[4] == 8 and place[5] == 12, "it overlaps, rising 12")
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
check(menu:HandleClick(button, "MiddleButton") and optionsOpened == "root", "Shift + Middle-Click opens options")
check(not menu:IsShown(), "and closes the menu")
shift = false
check(menu:HandleClick(button, "LeftButton") and menu:IsShown(), "Left-Click with no job opens the menu")
check(menu.state.closeDelay == 1.0, "and holds it a second")
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
check(erased and not quiet:IsShown(), "a fallback Left-Click does its job instead")

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
check(#list == 9 and list[9].kind == "note" and list[9].left == "2 more", "a long list stops at 8, then N more")
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
	linePoint[1] == "TOPLEFT" and linePoint[3] == "TOPRIGHT" and linePoint[4] == -(16 - 8),
	"the line's flyout overlaps the window's edge by 16, not the line's end"
)
line.box = { 100, 420, 432, 412 }
line.menu:Hide()
line.scripts.OnEnter(line)
check(line.menu.frame.points[1][4] == -16, "measured from where the line really ends")

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
print("all passed")
