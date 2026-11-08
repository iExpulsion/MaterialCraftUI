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

-- A slider starts at its minimum, shows its value to its right, and SetValue sets it quietly, on a step.
local changes = {}
local sl = S.Slider(parent, 160, 50, 200, 25, function(v) changes[#changes + 1] = v end,
	function(v) return v .. "%" end)
MOCK.check("slider starts at min", sl:GetValue() == 50 and sl.valueText.text == "50%" and #changes == 0)
MOCK.check("slider value beside it", sl.valueText.point[1] == "LEFT" and sl.valueText.point[3] == "RIGHT"
	and sl.valueText.point[4] == S.GAP)
sl:SetValue(130)
MOCK.check("slider set quietly on a step", sl:GetValue() == 125 and sl.valueText.text == "125%" and #changes == 0)
-- Dragging (the client's own value change) snaps to a step and reports it once, clamped to the range.
sl.scripts.OnValueChanged(sl, 161.2)
sl.scripts.OnValueChanged(sl, 155)
MOCK.check("slider drag snaps", sl:GetValue() == 150 and #changes == 1 and changes[1] == 150)
sl.scripts.OnValueChanged(sl, 999)
MOCK.check("slider clamps", sl:GetValue() == 200 and changes[2] == 200)
-- Fractional steps come out clean.
local fine = S.Slider(parent, 120, 0, 1, 0.05)
fine.scripts.OnValueChanged(fine, 0.6000001)
MOCK.check("fractional step", fine:GetValue() == 0.6 and fine.valueText.text == "0.6")
-- Material draws a track, an accent fill up to the handle, and an accent handle that greys out when disabled.
MOCK.check("slider look", sl.track ~= nil and sl.fill.point[2] == sl:GetThumbTexture()
	and sl:GetThumbTexture().vertex[1] == S.colors.accent[1])
sl:SetEnabled(false)
MOCK.check("slider disabled", sl:GetThumbTexture().vertex[4] == S.colors.disabled[4] and sl.valueText.color[1] == S.colors.disabled[1])

-- A tab in Material has the accent underline only while selected, and its label brightens.
local tabB = S.Tab(CreateFrame("Button", nil, parent), "Actions")
MOCK.check("tab unselected", not tabB.underline.shown and tabB.label.color[1] == S.colors.muted[1])
tabB:SetSelected(true)
MOCK.check("tab selected", tabB.underline.shown and tabB.label.color[1] == S.colors.text[1])

-- A vertical divider in Material is the 1px divider line standing on end.
local split, splitW = S.VerticalDivider(parent)
MOCK.check("vertical divider line", splitW == 1 and split.width == 1)

-- A one-line input keeps its text; a tall one turns line breaks into spaces.
local one = S.Input(parent, nil, 100, "Search")
one:SetText("abc")
MOCK.check("input text", one:GetText() == "abc")
local tall = S.Input(parent, nil, 100, "Notes", 200, 3)
tall:SetText("a\nb")
MOCK.check("tall input flattens line breaks", tall:GetText() == "a b")
-- A tall input's edit box is pinned inside its box, so it can't size itself to its text, and placing it places the
-- box, so what's anchored below it lands below the whole box.
tall:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -5)
MOCK.check("tall input keeps its height", tall:GetHeight() == 3 * 13 + 12 and tall.box.height == 3 * 13 + 12
	and tall.box.backdrop ~= nil)
MOCK.check("tall input pinned in its box", tall.box.point[2] == parent and tall.box.point[4] == 5
	and rawget(tall, "point")[1] == "BOTTOMRIGHT" and rawget(tall, "point")[2] == tall.box)
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
