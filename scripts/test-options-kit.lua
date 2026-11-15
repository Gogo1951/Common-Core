-- Offline smoke test for addon-kits/Options-Kit: stubs the WoW and Ace APIs the kit touches,
-- then builds every kind of piece and checks its shape. Run from Common-Core: lua5.1 scripts/test-options-kit.lua
local notified, timers, registered, added = {}, {}, {}, {}
local items = { [6948] = { "Hearthstone", "|cffffffff|Hitem:6948|h[Hearthstone]|h|r", icon = 134414 } }
function LibStub(name)
	if name == "AceConfigRegistry-3.0" then
		return {
			NotifyChange = function(_, n)
				notified[#notified + 1] = n
			end,
			RegisterOptionsTable = function(_, n, b)
				registered[n] = b
			end,
		}
	elseif name == "AceConfigDialog-3.0" then
		return {
			AddToBlizOptions = function(_, n, d, p)
				added[#added + 1] = { n, d, p }
				return {
					IsVisible = function()
						return false
					end,
					HookScript = function() end,
				},
					#added
			end,
			GetStatusTable = function()
				return {}
			end,
			Open = function() end,
		}
	else
		return {
			RegisterWidgetType = function() end,
			RegisterAsWidget = function(_, w)
				return w
			end,
		}
	end
end
C_Item = {
	GetItemInfo = function(id)
		local i = items[id]
		if i then
			return i[1], i[2], nil, nil, nil, nil, nil, nil, nil, i.icon
		end
	end,
	RequestLoadItemDataByID = function() end,
	DoesItemExistByID = function(id)
		return id ~= 99999
	end,
}
C_Timer = {
	After = function(_, f)
		timers[#timers + 1] = f
	end,
}
C_Container = {
	GetContainerNumSlots = function(bag)
		return bag == 0 and 1 or 0
	end,
	GetContainerItemInfo = function()
		return { itemID = 6948 }
	end,
}
NUM_BAG_SLOTS = 4
CreateFrame = function()
	return {
		Hide = function() end,
		CreateFontString = function()
			return {
				SetText = function(s, t)
					s.t = t
				end,
				GetStringWidth = function(s)
					return #s.t * 6
				end,
			}
		end,
	}
end
UnitClass = function()
	return "Druid", "DRUID"
end
GetUnitName = function()
	return "Aero"
end
RAID_CLASS_COLORS = { DRUID = { colorStr = "ffff7c0a" } }
InCombatLockdown = function()
	return false
end

local ns = {
	PALETTE = { TITLE = "FFD100", HELP = "CCCCCC", TEXT = "FFFFFF", MUTED = "808080", OFF = "CC3333" },
	L = setmetatable({ ADDON_TITLE = "Test Add-on" }, {
		__index = function(_, k)
			return k
		end,
	}),
	OPTIONS_REGISTRY = { General = "T", Feature = "T_Feature", Sub = "T_Sub" },
	db = { profile = { dispense = { party = false }, farm = true }, global = { cge = false } },
}
ns.FEATURES = {
	{
		store = "profile",
		setting = "farm",
		name = "FARM",
		caption = "ENABLE_FARM",
		desc = "ENABLE_FARM_DESC",
		block = true,
	},
	{
		store = "global",
		setting = "cge",
		name = "CGE",
		caption = "ENABLE_CGE",
		desc = "ENABLE_CGE_DESC",
		confirm = "CGE_CONFIRM",
	},
	{ store = "global", setting = "x", name = "X", caption = "ENABLE_X", desc = "ENABLE_X_DESC" },
}
function ns:PrintMessage(m)
	ns.printed = m
end
local chunk = assert(loadfile(arg[1] or "addon-kits/Options-Kit/Options/Options-Kit.lua"))
chunk("TestAddon", ns)
local Kit = ns.OptionsKit
local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
	print("ok  " .. msg)
end

check(math.abs(ns.OPTIONS_CONTROL_WIDTH - 1.3) < 1e-9, "grid published as ns.OPTIONS_*")
-- settings paths
local get, set = Kit.Get("profile", "dispense.party"), Kit.Set("profile", "dispense.party")
set(nil, true)
check(ns.db.profile.dispense.party == true and get() == true, "dotted path writes and reads")
check(notified[#notified] ~= nil, "Set ends in ns.RefreshSettings")
ns.db.profile = { dispense = { party = "fresh" } }
check(get() == "fresh", "Get follows a replaced profile table")
local choice = Kit.GetChoice("profile", "mode", { a = "A", b = "B" }, "a")
ns.db.profile.mode = "gone"
check(choice() == "a", "GetChoice falls back to the default for a stale value")
-- rows
local pairsArg = Kit.FeatureSwitches(23)
check(pairsArg.args.pair1 and pairsArg.args.pair2 and not pairsArg.args.pair3, "three features make two pair rows")
check(pairsArg.args.pair1.args.cell1.width == Kit.PAIR_WIDTH, "pair toggles take PAIR_WIDTH")
check(pairsArg.args.pair2.args.cell2 == nil, "odd feature leaves the second cell empty")
local sw = Kit.FeatureSwitch("cge")
check(
	sw.confirm(nil, false) == "CGE_CONFIRM" and sw.confirm(nil, true) == false,
	"confirm asks only when switching off"
)
sw.set(nil, true)
check(ns.db.global.cge == true, "feature switch writes its store")
ns.FEATURES[4] = { store = "profile", setting = "strangers.enabled", name = "S", caption = "S_ENABLE", desc = "S_DESC" }
ns.db.profile.strangers = { enabled = false }
local nested = Kit.FeatureSwitch("strangers.enabled")
nested.set(nil, true)
check(
	ns.db.profile.strangers.enabled == true and nested.get() == true,
	"feature switch reads and writes a dotted setting"
)
ns.FEATURES[4] = nil
local sub = Kit.SubRow(5, nil, { { type = "toggle" } })
check(sub.args.indent.width == Kit.SUB_INDENT_WIDTH and sub.args.cell1.order == 1, "SubRow leads with the indent cell")
local short = Kit.ToggleRow(1, {
	type = "toggle",
	name = "Sound",
	get = function()
		return false
	end,
}, { preview = Kit.SoundPreview(function() end) })
check(
	short.args.toggle.width == Kit.LABEL_WIDTH and short.args.preview.hidden() == true,
	"short caption shares the line; extras hide while off"
)
local long = Kit.ToggleRow(1, {
	type = "toggle",
	name = string.rep("W", 80),
	get = function()
		return true
	end,
}, { control = { type = "select" } })
check(
	long.args.toggle.width == "full" and long.args.below.args.control.width == Kit.CONTROL_WIDTH,
	"long caption drops its setting to the line below"
)
local ex = Kit.Example(3, nil, function()
	return Kit.SentLine("PARTY", "Hi {rt4}")
end)
local line = ex.args.lines.args.cell1.name()
check(
	ex.args.space
		and ex.args.label.name():find("Example|r$")
		and line:find("Aero")
		and line:find("UI%-RaidTargetingIcon_4"),
	"Example: spacer, its own label line, then the sent line with You and the marker icon"
)
local two = Kit.Example(4, nil, function()
	return { "one", "two" }
end)
check(two.args.lines.args.cell1.name() == "one\ntwo", "Example takes several lines, one under the other")
for _, old in ipairs({ "Example: %s", "Beispiel : %s", "\231\164\186\228\190\139\239\188\154%s" }) do
	Kit.SetText({ example = old })
	local label = Kit.Example(5, nil, function()
		return ""
	end).args.label.name()
	check(
		not label:find(":") and not label:find("\239\188\154") and not label:find(" |r"),
		"Example label drops a locale's colon: " .. old
	)
end
Kit.SetText({ example = "Example" })
-- Tint reopens its color only where the text closes more than it opened, so the color stack never grows.
local function MaxDepth(text)
	local depth, deepest = 0, 0
	for code in text:gmatch("|(.)") do
		if code == "c" then
			depth = depth + 1
			deepest = math.max(deepest, depth)
		elseif code == "r" then
			depth = depth - 1
		end
	end
	return deepest, depth
end
local coins = "|cffffffff5|r|cffffd700g|r |cffffffff3|r|cffc7c7cfs|r |cffffffff9|r|cffeda55fc|r"
local printed = "|cff00bbffMagic Eraser|r: |cffffffffSold 9 items for " .. coins .. ".|r"
local joined = table.concat({ Kit.PrintedLine(printed), Kit.PrintedLine(printed) }, "\n")
local deepest, open = MaxDepth(joined)
check(deepest <= 3 and open == 0, "PrintedLine: two joined lines stay shallow and close every color they open")
check(
	Kit.PrintedLine(printed) == "|cffFFFFFF" .. printed .. "|r",
	"PrintedLine leaves a line that closes its own colors untouched inside its tint"
)
check(Kit.Tint("TITLE", "a|rb") == "|cffFFD100a|r|cffFFD100b|r", "Tint reopens after a stray |r")
check(Kit.Tint("TITLE", "a||rb") == Kit.Color("TITLE", "a||rb"), "Tint leaves an escaped pipe alone")
local sent = Kit.SentLine("PARTY", "Need " .. items[6948][2] .. " x2 " .. items[6948][2])
deepest, open = MaxDepth(sent)
check(deepest <= 3 and open == 0, "SentLine with links stays shallow")
local lr = Kit.LabelRow(5, nil, "Output", { type = "select" }, nil, "Reaches only your layer.")
check(
	lr.args.row and lr.args.helper.args.cell2.width == Kit.CONTROL_WIDTH,
	"LabelRow puts its helper line under the control"
)
local sets = Kit.FieldSets(6, nil, { Kit.Desc("a"), Kit.Desc("b"), Kit.Desc("c") })
check(sets.args.space2 and sets.args.space3 and not sets.args.space1, "FieldSets puts a spacer between each set")
-- items
check(
	Kit.ParseItem("|Hitem:6948:0|h") == 6948
		and Kit.ParseItem(" 12 ") == 12
		and Kit.ParseItem("word") == nil
		and Kit.ParseItem("99999") == nil,
	"ParseItem reads links and IDs, refuses words and unknown IDs"
)
check(Kit.ItemName(6948):find("Hearthstone") and not Kit.ItemName(6948):find("%["), "ItemName drops the brackets")
check(Kit.ItemName(5):find("Loading ID: 5"), "uncached item reads as loading")
local list = { [6948] = true, [5] = true }
local args = Kit.ItemList({
	getSourceTable = function()
		return list
	end,
	onAdd = function(id)
		list[id] = true
	end,
	onRemove = function(id)
		list[id] = nil
	end,
	onClear = function() end,
	addFromBags = true,
	registryName = "T_Feature",
	labels = {
		addName = "Add",
		addHelp = "h",
		addInvalid = "bad",
		removeDesc = "r",
		empty = "e",
		fromBagsName = "B",
		clearName = "C",
	},
})
check(args.item6948 and args.item5 and args.foot, "ItemList draws a row per item and the foot")
check(args.item6948.order < args.item5.order, "loaded items sort above loading ones")
check(#timers > 0, "cold items start the warm poll")
args.item5.args.cell2.func()
check(list[5] == nil, "remove icon removes")
-- panels
Kit.RegisterPanel("General", function() end, "Test Add-on")
Kit.RegisterPanel("Feature", function() end, "Feature")
Kit.RegisterPanel("Sub", function() end, "Sub", "Feature")
check(
	added[1][3] == nil and added[2][3] == "Test Add-on" and added[3][3] == 2,
	"root, child by name, sub-panel by parent category ID"
)
InCombatLockdown = function()
	return true
end
ns:OpenOptionsPanel()
check(ns.printed ~= nil, "Combat Guard prints")
print("all passed")
