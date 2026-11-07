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

-- A navigation entry lights the quest log highlight in gold while selected.
local nav = S.NavEntry(CreateFrame("Button", nil, parent), "Page")
nav:SetSelected(true)
MOCK.check("nav selected", nav.selectedTex.shown and nav.selectedTex.texture:find("UI%-QuestTitleHighlight"))
nav:SetSelected(false)
MOCK.check("nav unselected", not nav.selectedTex.shown)

-- A one-line input is the stock edit box border; a tall one is tooltip-bordered and turns gold while focused.
local e = S.Input(parent, nil, 200, "Search")
MOCK.check("edit box border", e.border.parts[1].texture == "Interface\\Common\\Common-Input-Border" and e.backdrop == nil)
local tall = S.Input(parent, nil, 200, "Notes", 200, 3)
tall:SetFocus()
MOCK.check("tall input", tall.backdrop.edgeFile:find("UI%-Tooltip%-Border"))

-- A checkbox is the stock box and tick, drawn larger than the box, with the disabled tick when it can't be used.
local c = S.Check(parent, 14)
MOCK.check("stock checkbox", c.box.texture == "Interface\\Buttons\\UI-CheckBox-Up" and c.box.width > 14 and not c.tick.shown)
c:SetChecked(true)
MOCK.check("checked", c.tick.shown and c.tick.texture == "Interface\\Buttons\\UI-CheckBox-Check")
c:SetEnabled(false)
MOCK.check("disabled tick", c.tick.texture == "Interface\\Buttons\\UI-CheckBox-Check-Disabled")

-- A dropdown's menu is tooltip-bordered like the other menus.
local d = S.Dropdown(parent, 120, function() end)
MOCK.check("dropdown menu", d.menu.backdrop.edgeFile:find("UI%-Tooltip%-Border"))

S.UseSkin("material")
-- Material keeps its flat checkbox, and a skin without one (Cognac) gets it too.
MOCK.check("material checkbox", S.Check(parent, 14).fill ~= nil)
LOAD("Skins/Cognac/Atlas.lua")
LOAD("Skins/Cognac/Skin.lua")
S.UseSkin("cognac")
MOCK.check("fallback checkbox", S.Check(parent, 14).fill ~= nil)
S.UseSkin("material")
