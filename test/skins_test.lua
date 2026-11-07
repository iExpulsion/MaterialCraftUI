-- Skins: Material by default, registering and switching skins, atlas pieces and trims, and the Cognac skin's
-- buttons, frames, sidebar, navigation entries and inputs.
local S = NS.Style
local parent = CreateFrame("Frame")
local function near(a, b) return math.abs(a - b) < 1e-4 end

-- The kit starts on Material, with no frame edge, and buttons drawn as flat backdrops.
MOCK.check("material by default", S.Skin() == "material" and S.metrics.edge == 0 and S.metrics.inset == S.PAD)
-- A Material well is the flat sunken panel.
MOCK.check("material well", S.Well(CreateFrame("Frame")).backdrop ~= nil)
local flat = S.Button(parent, "Flat", "secondary", 80)
MOCK.check("material button is a backdrop", flat.backdrop ~= nil and flat.plate == nil)
-- The new color roles start out as the scheme's own colors.
MOCK.check("skin roles default to the scheme", S.colors.rowHover == S.colors.hover and S.colors.navSelected == S.colors.heading)

-- Loading Cognac's files registers it; the list puts Material first and carries the credit.
LOAD("Skins/Cognac/Atlas.lua")
LOAD("Skins/Cognac/Skin.lua")
local list = S.Skins()
MOCK.check("skins listed", #list == 2 and list[1].key == "material" and list[2].key == "cognac"
	and list[2].credit:find("Jeff"))

-- Switching to Cognac brings its scheme, colors and metrics.
S.UseSkin("cognac")
MOCK.check("cognac scheme", S.Skin() == "cognac" and near(S.colors.accent[1], 0xf0 / 255) and near(S.colors.navSelected[2], 1))
MOCK.check("cognac metrics", S.metrics.edge == 18 and S.metrics.inset == 18 and S.metrics.navInset == 8)

-- A Cognac button is a nine-sliced plate from the addon's own copy of the atlas, not a backdrop.
local b = S.Button(parent, "Plate", "secondary", 90)
local corner = b.plate.textures[1]
MOCK.check("plate, no backdrop", b.backdrop == nil and corner.shown
	and corner.texture == "Interface\\AddOns\\TestAddon\\UI\\Skins\\Cognac\\Cognac")
local face = parent:CreateTexture()
S.Art(face, "cognac", "button_normal")
MOCK.check("normal face", b.plate.piece == "button_normal" and near(corner.coords[1], face.coords[1])
	and near(corner.coords[3], face.coords[3]))
-- Its corners keep the art's shape: 18 of the plate's 88 art pixels high, scaled to the button's height.
local _, ph = S.ArtSize("cognac", "button_normal")
MOCK.check("plate corners keep their scale", near(corner.width, 18 * S.CONTROL_H / ph) and near(corner.height, corner.width))
-- Pressing shows the pressed face; letting go goes back.
b.scripts.OnMouseDown(b)
MOCK.check("pressed face", b.platePiece == "button_pressed")
b.scripts.OnMouseUp(b)
MOCK.check("released", b.platePiece == "button_normal")
-- Disabled shows the disabled face with no glow.
b:Disable()
b.scripts.OnDisable(b)
MOCK.check("disabled face", b.platePiece == "button_disabled")
-- A square button gets the bezel, the selected side of a segmented button the chip.
local x = S.Button(parent, "X", "ghost", 24)
MOCK.check("square bezel", x.platePiece == "bezel")
local seg = S.Button(parent, "On", "secondary", 80)
seg:SetKind("selected")
MOCK.check("selected chip", seg.platePiece == "chip_selected")
-- The plate follows the button's size.
b:SetWidth(140)
b.scripts.OnSizeChanged(b)
local p = b.plate.textures
MOCK.check("plate resized", near(p[1].width + p[2].width + p[3].width, 140)
	and near(p[1].height + p[4].height + p[7].height, S.CONTROL_H) and near(p[3].width, p[1].width))

-- Part of a piece maps through to the matching part of its atlas coordinates.
local t, whole = parent:CreateTexture(), parent:CreateTexture()
S.Art(whole, "cognac", "card")
S.Art(t, "cognac", "card", 0, 0.5, 0, 1)
MOCK.check("part of a piece", near(t.coords[1], whole.coords[1]) and near(t.coords[2], (whole.coords[1] + whole.coords[2]) / 2)
	and near(t.coords[4], whole.coords[4]))
-- A trimmed piece is placed inside the box it would fill whole (corner_nw lost 0.070312 of each side but the bottom).
S.PlaceArt(t, parent, "cognac", "corner_nw", 0, 0, 100, 100)
MOCK.check("trimmed piece placed inside", near(t.point[4], 7.0312) and near(t.width, 100 * (1 - 0.070312 * 2)))
-- Mirrored coordinates come back reversed.
S.Art(t, "cognac", "search", 1, 0)
MOCK.check("mirrored", t.coords[1] > t.coords[2])

-- A window gets the glass, no flat border, and the gold chrome laid out for its size.
local win = CreateFrame("Frame")
win:SetSize(400, 300)
S.Frame(win, "window")
MOCK.check("window glass", win.backdrop and win.backdrop.bgFile:find("Tooltip") and not win.backdrop.edgeFile)
win.scripts.OnSizeChanged(win)
MOCK.check("window chrome", win.scripts.OnSizeChanged ~= nil)
-- A popup is the glass's tint but solid, so the window under it doesn't show through.
local pop = CreateFrame("Frame")
pop:SetSize(300, 200)
S.Frame(pop, "popup")
MOCK.check("popup solid", pop.backdrop and not pop.backdrop.bgFile:find("Tooltip") and not pop.backdrop.edgeFile)
-- A well is the framed card, with no flat backdrop.
local well = CreateFrame("Frame")
well:SetSize(200, 100)
S.Well(well)
MOCK.check("well card", well.backdrop == nil)
-- A menu is the chamfered frame of the tooltip art, not a flat panel, and its rows sit inside its rim.
local menu = CreateFrame("Frame")
menu:SetSize(160, 120)
S.Frame(menu, "menu")
MOCK.check("menu frame", menu.backdrop == nil and S.metrics.menuInset == 5)

-- A sidebar gets the card and a divider frame beside it.
local side = CreateFrame("Frame", nil, win)
side:SetSize(150, 280)
local before = #MOCK.created
S.Sidebar(side)
MOCK.check("sidebar divider", #MOCK.created == before + 1 and MOCK.created[#MOCK.created].parent == win)

-- A navigation entry shows the chip and the mint label while selected.
local nav = S.NavEntry(CreateFrame("Button", nil, side), "Page")
nav:SetSize(140, 30)
MOCK.check("nav unselected", not nav.plate.textures[5].shown and nav.label.color[1] == S.colors.text[1])
nav:SetSelected(true)
MOCK.check("nav selected", nav.plate.textures[5].shown and nav.platePiece == "chip_selected" and near(nav.label.color[2], 1))
-- A one-line input is three slices of the search plate that brighten on focus; a tall one is the framed card.
local e = S.Input(parent, nil, 200, "Search")
MOCK.check("input slices", #e.slices == 3 and e.backdrop == nil)
e:SetFocus()
MOCK.check("input focus tint", e.slices[1].vertex[3] < 1)
local tall = S.Input(parent, nil, 200, "Notes", 200, 3)
MOCK.check("tall input card", tall.backdrop == nil and tall.card ~= nil and tall.slices == nil)
-- Its text and height make room for the card's frame.
MOCK.check("tall input inset", tall:GetHeight() == 3 * 13 + 12 + 2 * S.metrics.wellInset)

-- A checkbox is S.CHECK_H by default: the gold square frame, nine-sliced at a fixed scale so its rim stays about
-- 2px (corners 40 art pixels at 0.15), with the gem diamond centered over it while checked, overflowing it.
local box = S.Check(parent)
local boxCorner = box.box.textures[1]
MOCK.check("framed checkbox", box.width == S.CHECK_H and boxCorner.texture:find("Cognac") and near(boxCorner.width, 6)
	and not box.tick.shown)
box:SetChecked(true)
MOCK.check("diamond when checked", box.tick.shown and box.tick.point[1] == "CENTER"
	and math.max(box.tick.width, box.tick.height) > S.CHECK_H)

-- No rule under a title bar; the gold divider beside section headings.
MOCK.check("no title rule", not S.Rule(parent, "BOTTOM").shown)
local _, divider = S.SectionHeading(parent, "Loot", 0, 0)
MOCK.check("gold divider", divider.texture:find("Cognac") and divider.height == 3)

-- Going back to Material with a scheme of the addon's own.
S.UseSkin("material", { primary = "ffc400" })
MOCK.check("back to material", S.Skin() == "material" and S.metrics.edge == 0 and near(S.colors.accent[2], 0xc4 / 255))
MOCK.check("material buttons again", S.Button(parent, "Flat", "secondary", 80).backdrop ~= nil)
-- An unknown skin is an error.
MOCK.check("unknown skin", not pcall(S.UseSkin, "nope"))
