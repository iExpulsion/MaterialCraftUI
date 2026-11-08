-- The Classic skin: the stock dialog frame, panel buttons and their faces, tooltip-bordered menus and wells, the
-- quest log highlight on rows and navigation entries, and the stock edit box border.
local S = NS.Style
LOAD("Skins/Classic/Skin.lua")
local parent = CreateFrame("Frame")

-- It registers next to Material and brings the stock gold and its border metrics.
S.UseSkin("classic")
MOCK.check("classic on", S.Skin() == "classic" and S.colors.heading[2] == 0.82 and S.metrics.edge == 12)

-- A window is the dialog box: its background and 32px border.
local win = S.Frame(CreateFrame("Frame"), "window")
MOCK.check("dialog frame", win.backdrop.bgFile:find("UI%-DialogBox%-Background") and win.backdrop.edgeFile:find("UI%-DialogBox%-Border")
	and win.backdrop.edgeSize == 32)
-- Black over the see-through dialog background, heavier on a popup, which sits over a window.
local pop = S.Frame(CreateFrame("Frame"), "popup")
MOCK.check("dialog fill", win.fill.vertex[4] == 0.5 and pop.fill.vertex[4] == 0.8)
-- Tabs get room for the tab art's caps, and the rule under a tab bar is drawn where the title bar's isn't.
MOCK.check("tab padding", S.metrics.tabPad == 20)
MOCK.check("tab bar rule", S.Rule(parent, "BOTTOM", "tabs").shown and not S.Rule(parent, "BOTTOM").shown)
-- A menu and a well are tooltip-bordered.
MOCK.check("tooltip menu", S.Frame(CreateFrame("Frame"), "menu").backdrop.edgeFile:find("UI%-Tooltip%-Border"))
MOCK.check("tooltip well", S.Well(CreateFrame("Frame")).backdrop.edgeFile:find("UI%-Tooltip%-Border"))

-- A button is the red panel button in three slices, with a gold label.
local b = S.Button(parent, "Go", "secondary", 90)
MOCK.check("panel button", b.face.parts[1].texture == "Interface\\Buttons\\UI-Panel-Button-Up" and b.label.color[2] == 0.82)
-- Pressed shows the pushed face, disabled the disabled one with a gray label.
b.scripts.OnMouseDown(b)
MOCK.check("pushed face", b.face.parts[2].texture == "Interface\\Buttons\\UI-Panel-Button-Down")
b.scripts.OnMouseUp(b)
b:Disable()
b.scripts.OnDisable(b)
MOCK.check("disabled face", b.face.parts[3].texture == "Interface\\Buttons\\UI-Panel-Button-Disabled" and b.label.color[1] == 0.5)
-- The selected side of a segmented button stays pushed, with a white label.
local seg = S.Button(parent, "On", "secondary", 80)
seg:SetKind("selected")
MOCK.check("selected pushed", seg.face.parts[1].texture == "Interface\\Buttons\\UI-Panel-Button-Down" and seg.label.color[2] == 1)

-- A tab is the Interface Options tab art along its bottom: the active one while selected, the inactive otherwise.
local tabB = CreateFrame("Button", nil, parent)
tabB:SetHeight(32)
S.Tab(tabB, "Actions")
MOCK.check("tab inactive", tabB.inactive.parts[1].shown and not tabB.active.parts[1].shown
	and tabB.inactive.parts[1].texture:find("InActiveTab") and tabB.inactive.parts[1].height == 24
	and tabB.label.point[3] == -7)
tabB:SetSelected(true)
MOCK.check("tab active", tabB.active.parts[2].shown and not tabB.inactive.parts[2].shown
	and tabB.active.parts[2].texture:find("UI%-OptionsFrame%-ActiveTab") and tabB.label.point[3] == -4)

-- A navigation entry lights the quest log highlight in gold while selected.
local nav = S.NavEntry(CreateFrame("Button", nil, parent), "Page")
nav:SetSelected(true)
MOCK.check("nav selected", nav.selectedTex.shown and nav.selectedTex.texture:find("UI%-QuestLogTitleHighlight"))
nav:SetSelected(false)
MOCK.check("nav unselected", not nav.selectedTex.shown)

-- A one-line input is the stock edit box border; a tall one is tooltip-bordered and turns gold while focused.
local e = S.Input(parent, nil, 200, "Search")
MOCK.check("edit box border", e.border.parts[1].texture == "Interface\\Common\\Common-Input-Border" and e.backdrop == nil)
local tall = S.Input(parent, nil, 200, "Notes", 200, 3)
tall:SetFocus()
MOCK.check("tall input", tall.box.backdrop.edgeFile:find("UI%-Tooltip%-Border") and tall.backdrop == nil)

-- A checkbox is the stock box and tick, drawn larger than the box, with the disabled tick when it can't be used.
local c = S.Check(parent, 14)
MOCK.check("stock checkbox", c.box.texture == "Interface\\Buttons\\UI-CheckBox-Up" and c.box.width > 14 and not c.tick.shown)
c:SetChecked(true)
MOCK.check("checked", c.tick.shown and c.tick.texture == "Interface\\Buttons\\UI-CheckBox-Check")
c:SetEnabled(false)
MOCK.check("disabled tick", c.tick.texture == "Interface\\Buttons\\UI-CheckBox-Check-Disabled")

-- A dropdown's menu is tooltip-bordered like the other menus, with its rows inside the 4px border.
local d = S.Dropdown(parent, 120, function() end)
d:SetOptions({ { value = 1, text = "One" }, { value = 2, text = "Two" } })
MOCK.check("dropdown menu", d.menu.backdrop.edgeFile:find("UI%-Tooltip%-Border") and d.items[1].point[2] == -4
	and d.menu.height == 2 * S.CONTROL_H + 8)

-- A slider is the Interface Options groove and knob, the knob desaturated when disabled.
local sl = S.Slider(parent, 150, 0, 10, 1)
MOCK.check("stock slider", sl.bar.backdrop.bgFile:find("UI%-SliderBar%-Background") and sl.bar.height == 17
	and sl:GetThumbTexture().texture:find("UI%-SliderBar%-Button%-Horizontal") and sl.fill == nil)
sl:SetEnabled(false)
MOCK.check("disabled knob", sl:GetThumbTexture().desaturated == true)

S.UseSkin("material")
-- A skin without a slider gets Material's.
S.RegisterSkin("bare2", { label = "Bare" })
S.UseSkin("bare2")
MOCK.check("fallback slider", S.Slider(parent, 100, 0, 1, 1).fill ~= nil)
S.UseSkin("material")
-- Material keeps its flat checkbox, and a skin without one gets it too, and Material's divider lines.
MOCK.check("material checkbox", S.Check(parent, 14).fill ~= nil)
S.RegisterSkin("bare", { label = "Bare" })
S.UseSkin("bare")
local _, ruleLine = S.SectionHeading(parent, "Heading", 0, 0)
MOCK.check("fallback checkbox and line", S.Check(parent, 14).fill ~= nil and ruleLine.height == 1)
S.UseSkin("material")

-- Classic leaves out the rule under a title bar, and keeps a soft line beside section headings.
S.UseSkin("classic")
MOCK.check("no title rule", not S.Rule(parent, "BOTTOM").shown)
local _, soft = S.SectionHeading(parent, "Loot", 0, 0)
MOCK.check("heading line kept", soft.shown and soft.height == 1)
S.UseSkin("material")
