-- The style kit loaded by an addon: its addon table, font names, buttons, dropdowns, inputs, popups, colors.
local S = NS.Style

-- The kit sits on the addon table and names its fonts after the addon.
MOCK.check("kit on the addon table", S ~= nil and S.Button ~= nil)
MOCK.check("fonts named after the addon", _G.TestAddonFontSmall ~= nil and _G.TestAddonFontNormal ~= nil)

-- Counts and color text.
MOCK.check("count", S.Count(1, "item") == "1 item" and S.Count(3, "item") == "3 items")
MOCK.check("hex", S.Hex({ 1, 0, 0 }, "x") == "|cffff0000x|r")

-- A button's SetText changes its label and keeps its width; SetLabel grows it to fit.
local parent = CreateFrame("Frame")
local b = S.Button(parent, "Old", "secondary", 80)
b:SetText("New")
MOCK.check("button SetText sets the label", b.label.text == "New")

-- AddArrow gives a button a dropdown's arrow and left-aligned label.
local arrowed = S.AddArrow(S.Button(parent, "Pick", "secondary", 120))
MOCK.check("arrow added", arrowed.arrow ~= nil)

-- A dropdown lists its options and reports the pick.
local picked
local d = S.Dropdown(parent, 120, function(v) picked = v end)
d:SetOptions({ { value = 1, text = "One" }, { value = 2, text = "Two" } })
d.items[2].scripts.OnClick(d.items[2])
MOCK.check("dropdown pick", picked == 2)
d:SetText("Two")
MOCK.check("dropdown text", d.label.text == "Two")

-- A one-line input keeps its text; a tall one turns line breaks into spaces.
local one = S.Input(parent, nil, 100, "Search")
one:SetText("abc")
MOCK.check("input text", one:GetText() == "abc")
local tall = S.Input(parent, nil, 100, "Notes", 200, 3)
tall:SetText("a\nb")
MOCK.check("tall input flattens line breaks", tall:GetText() == "a b")

-- A tracked popup closes on a click outside it and its owner, like a dropdown menu.
local popup = CreateFrame("Frame")
popup.owner = CreateFrame("Button")
S.TrackPopup(popup)
popup:Show()
MOCK.mouseOver = nil
S.ClickedAway()
MOCK.check("popup closes on an outside click", not popup:IsShown())
popup:Show()
MOCK.mouseOver = popup.owner
S.ClickedAway()
MOCK.check("popup stays open on its owner", popup:IsShown())

-- Quality colors are made once per quality.
ITEM_QUALITY_COLORS = { [4] = { r = 0.6, g = 0.2, b = 0.9 } }
local epic = S.QualityColor(4)
MOCK.check("quality color", epic[1] == 0.6 and epic[4] == 1)
MOCK.check("quality color reused", S.QualityColor(4) == epic)
MOCK.check("unknown quality falls back to text", S.QualityColor(99) == S.colors.text)

-- A section heading is a label with a rule beside it.
local label, line = S.SectionHeading(parent, "Loot", 12, -8)
MOCK.check("section heading", label.text == "Loot" and line ~= nil)
