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
-- A tall input's box keeps the height it was made with, however the edit box sizes itself to its text.
tall:SetHeight(14)
MOCK.check("tall input keeps its height", tall:GetHeight() == 3 * 13 + 12 and tall.box.height == 3 * 13 + 12
	and tall.box.backdrop ~= nil)
-- Hiding and showing it takes its box along.
tall:Hide()
local hidden = not tall.box.shown
tall:Show()
MOCK.check("tall input box follows", hidden and tall.box.shown)

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

-- Heirloom, which the 3.3.5 client's table leaves out, gets its link color; the client's own entry wins if present.
local heirloom = S.QualityColor(7)
MOCK.check("heirloom without a client color", math.abs(heirloom[1] - 0xe6 / 255) < 0.001 and math.abs(heirloom[3] - 0x80 / 255) < 0.001)
ITEM_QUALITY_COLORS[7] = { r = 0, g = 0.8, b = 1 }
S.SetTheme()
MOCK.check("client heirloom color wins", S.QualityColor(7)[2] == 0.8)
ITEM_QUALITY_COLORS[7] = nil

-- A section heading is a label with a rule beside it.
local label, line = S.SectionHeading(parent, "Loot", 12, -8)
MOCK.check("section heading", label.text == "Loot" and line ~= nil)

-- A theme recolors the roles it names in place, keeps colors an addon added, and reaches new buttons.
local function near(c, r, g, b) return math.abs(c[1] - r) < 0.01 and math.abs(c[2] - g) < 0.01 and math.abs(c[3] - b) < 0.01 end
local colors, defaultText = S.colors, S.colors.text
S.colors.custom = { 0, 1, 0, 1 }
S.SetTheme({ primary = "#3399ff" })
MOCK.check("theme sets the accent", near(S.colors.accent, 0.2, 0.6, 1) and near(S.colors.heading, 0.2, 0.6, 1))
MOCK.check("theme keeps the colors table", S.colors == colors and S.colors.custom ~= nil)
MOCK.check("roles left out keep the default", near(S.colors.text, defaultText[1], defaultText[2], defaultText[3]))
MOCK.check("light accent gets dark text", S.colors.onAccent[1] < 0.2 and S.colors.onAccent[3] < 0.3)
local themed = S.Button(parent, "Go", "primary", 80)
MOCK.check("primary button takes the theme", near(themed.label.color, S.colors.onAccent[1], S.colors.onAccent[2], S.colors.onAccent[3]))
MOCK.check("dark accent gets light text", (function() S.SetTheme({ primary = { 0.2, 0.1, 0.4 } }) return S.colors.onAccent[1] > 0.8 end)())
S.SetTheme({ primary = "112233", onPrimary = "ffffff" })
MOCK.check("given onPrimary is kept", near(S.colors.onAccent, 1, 1, 1))
MOCK.check("unknown role is an error", not pcall(S.SetTheme, { primry = "ff0000" }))
S.SetTheme()
MOCK.check("reset to the baseline scheme", near(S.colors.accent, 0.816, 0.737, 1))
MOCK.check("theme refreshes quality fallback", S.QualityColor(99) == S.colors.text)
