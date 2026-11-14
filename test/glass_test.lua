-- The Material Glass skin: its see-through colors on the addon's own scheme, the glass on windows and popups with
-- the tiled grain, sheen and lit edge, the near-solid menu, and its translucent buttons in every kind and state.
local S = NS.Style
LOAD("Skins/MaterialGlass/Skin.lua")
local parent = CreateFrame("Frame")

-- It registers next to Material under its own label, keeps the addon's accent and Material's metrics.
S.UseSkin("materialglass", { primary = "ffc400" })
local listed
for _, s in ipairs(S.Skins()) do
	if s.key == "materialglass" then listed = s.label end
end
MOCK.check("glass registered", S.Skin() == "materialglass" and listed == "Material Glass")
MOCK.check("glass keeps the accent", math.abs(S.colors.accent[1] - 1) < 1e-4 and math.abs(S.colors.accent[2] - 0xc4 / 255) < 1e-4)
MOCK.check("glass metrics", S.metrics.edge == 0 and S.metrics.inset == S.PAD)
-- The window fill is see-through, the well nearly solid, and lines light.
MOCK.check("glass colors", S.colors.window[4] < 0.9 and S.colors.well[4] >= 0.8 and S.colors.border[1] == 1)
-- Muted text is lifted toward the text color.
MOCK.check("muted lifted", S.colors.muted[1] > 0xca / 255 and S.colors.muted[1] < 0xe6 / 255)

-- A window is the translucent fill, the sheen and the lit top edge.
local win = CreateFrame("Frame")
win:SetSize(402, 258)
S.Frame(win, "window")
MOCK.check("window fill", win.backdrop and win.backdrop.bgFile:find("WHITE8X8") and win.backdrop.edgeFile)
MOCK.check("window sheen", win.sheen.height == math.min(258 * 0.4, 160) and win.shine.height == 1)
-- The frost, from the addon's own copy, is a grid of whole 256-unit tiles inside the edge, the last column and row
-- cropped (400 x 256: 2 columns, the last 144 wide, and 1 whole row), since the client clamps rather than wraps.
local tiles = win.grain
local last = tiles[2]
MOCK.check("frost tiles", #tiles == 2 and tiles[1].texture == "Interface\\AddOns\\TestAddon\\UI\\Skins\\MaterialGlass\\MaterialGlass"
	and tiles[1].vertex[4] > 0 and tiles[1].coords[2] == 1 and tiles[1].point[4] == 1 and tiles[1].point[5] == -1)
MOCK.check("frost last column cropped", last.width == 144 and last.coords[2] == 144 / 256 and last.point[4] == 257)
-- A taller window adds a second row, cropped.
win:SetSize(402, 302)
win.scripts.OnSizeChanged(win)
MOCK.check("frost second row", #tiles == 4 and tiles[3].point[5] == -257 and tiles[3].height == 44
	and tiles[3].coords[4] == 44 / 256)
-- A smaller window reuses its tiles and hides the ones it no longer needs.
win:SetSize(130, 130)
win.scripts.OnSizeChanged(win)
MOCK.check("frost follows size", #tiles == 4 and tiles[1].shown and tiles[1].width == 128 and not tiles[2].shown
	and not tiles[4].shown and win.sheen.height == 130 * 0.4)

-- A popup is the same glass, nearly solid; a menu a near-solid panel.
local pop = S.Frame(CreateFrame("Frame"), "popup")
MOCK.check("popup glass", pop.grain ~= nil)
local menu = S.Frame(CreateFrame("Frame"), "menu")
MOCK.check("menu panel", menu.grain == nil and menu.shine ~= nil)

-- A secondary button is a faint white fill with a lit top edge that brightens on hover.
local b = S.Button(parent, "Go", "secondary", 90)
MOCK.check("secondary glass", b.backdrop and b.shine ~= nil)
-- A primary button stays the solid accent.
local p = S.Button(parent, "Apply", "primary", 90)
MOCK.check("primary solid", p.shine.alpha > 0 and p.label.color[1] == S.colors.onAccent[1])
-- Disabled buttons lose the lit edge and fade their label.
b:Disable()
b.scripts.OnDisable(b)
MOCK.check("disabled", b.shine.alpha == 0 and b.label.color[1] == S.colors.disabled[1])
-- A ghost button has no fill or edge at rest.
local g = S.Button(parent, "X", "ghost", 24)
MOCK.check("ghost", g.shine.alpha == 0)

-- A well has the field border, as strong as a secondary button's, under a faint lit top edge.
local well = S.Well(CreateFrame("Frame"))
MOCK.check("well edge", well.shine ~= nil and well.shine.vertex[4] < 0.1 and S.colors.border[4] < 0.14)
-- An input has the same edge, keeps the field border at rest and takes the accent while focused.
local e = S.Input(parent, nil, 120)
MOCK.check("input edge", (e.box or e).shine ~= nil)
e:SetFocus()
e:ClearFocus()
MOCK.check("input focus round trip", not e.focused)

-- Checkboxes fall back to Material's: a well with an accent fill.
local cb = S.Check(parent)
MOCK.check("material checkbox", cb.fill ~= nil and cb.backdrop ~= nil)
