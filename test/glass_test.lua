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
MOCK.check("glass colors", S.colors.window[4] < 0.8 and S.colors.well[4] >= 0.8 and S.colors.border[1] == 1)

-- A window is the translucent fill, the grain from the addon's own copy tiled one texture pixel per unit, the sheen
-- and the lit top edge.
local win = CreateFrame("Frame")
win:SetSize(402, 258)
S.Frame(win, "window")
MOCK.check("window fill", win.backdrop and win.backdrop.bgFile:find("WHITE8X8") and win.backdrop.edgeFile)
MOCK.check("window grain", win.grain.texture == "Interface\\AddOns\\TestAddon\\UI\\Skins\\MaterialGlass\\MaterialGlass"
	and win.grain.vertex[4] > 0 and win.grain.coords[2] == 400 / 128 and win.grain.coords[4] == 256 / 128)
MOCK.check("window sheen", win.sheen.height == math.min(258 * 0.4, 160) and win.shine.height == 1)
-- The grain keeps its scale when the window is resized.
win:SetSize(642, 130)
win.scripts.OnSizeChanged(win)
MOCK.check("grain follows size", win.grain.coords[2] == 640 / 128 and win.sheen.height == 130 * 0.4)

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

-- Checkboxes fall back to Material's: a well with an accent fill.
local cb = S.Check(parent)
MOCK.check("material checkbox", cb.fill ~= nil and cb.backdrop ~= nil)
