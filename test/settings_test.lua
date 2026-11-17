-- S.Settings: defaults filled into the saved table, the skin applied at load, window size and pixel snapping with
-- the addon's rescale callback and placed frames, the skin change prompt, and the title bar controls.
local S = NS.Style
LOAD("Skins/Classic/Skin.lua")

local rescales = 0
local db = { skin = "nonsense" }
S.Settings.Use(db, { name = "Test Addon", theme = { primary = "ffc400" }, onRescaled = function() rescales = rescales + 1 end })

-- an unknown skin falls back to Material, and the sizes get their defaults
MOCK.check("defaults", db.skin == "material" and db.pixelScale == true and db.windowScale == 1 and S.Skin() == "material")
MOCK.check("reload prompt defined", StaticPopupDialogs.TESTADDON_THEME_RELOAD
	and StaticPopupDialogs.TESTADDON_THEME_RELOAD.text:find("^Test Addon switches"))

-- a frame with a place of its own is put back after a size change; out-of-range sizes are refused
local placedTimes = 0
S.Settings.PixelScale(CreateFrame("Frame", nil, UIParent))
S.Settings.PixelScale(CreateFrame("Frame", nil, UIParent), function() placedTimes = placedTimes + 1 end)
MOCK.check("size set", S.Settings.SetWindowScale(1.5) and db.windowScale == 1.5 and S.windowScale == 1.5
	and placedTimes == 1 and rescales == 1)
MOCK.check("size refused", not S.Settings.SetWindowScale(9) and not S.Settings.SetWindowScale("big") and db.windowScale == 1.5)

-- turning pixel snapping off saves it and runs the same follow-up
S.Settings.SetPixelScale(false)
MOCK.check("snapping off", db.pixelScale == false and placedTimes == 2 and rescales == 2)
S.Settings.SetPixelScale(true)

-- a known skin is saved and prompts a reload with its label; an unknown one is refused
MOCK.check("skin saved", S.Settings.SetSkin("classic") and db.skin == "classic"
	and MOCK.popup.which == "TESTADDON_THEME_RELOAD" and MOCK.popup.arg == "Classic")
MOCK.check("unknown skin refused", not S.Settings.SetSkin("nope") and db.skin == "classic")
MOCK.check("labels", S.Settings.ScaleLabel(1.25) == "125%" and #S.Settings.SCALES == 8)

-- the title bar controls show the saved values, and follow a change made elsewhere (a slash command)
local bar = CreateFrame("Frame", nil, UIParent)
local controls, last = S.Settings.TitleBar(bar, CreateFrame("Frame", nil, bar))
MOCK.check("title bar shows saved", controls.size.label.text == "150%" and controls.snap.on and last.text == "Snap to Pixels")
S.Settings.SetWindowScale(1.25)
MOCK.check("title bar follows", controls.size.label.text == "125%")
-- picking from the Size dropdown sets it
controls.size.items[1].scripts.OnClick(controls.size.items[1])
MOCK.check("size picked", db.windowScale == 0.8 and controls.size.label.text == "80%")
-- the snap box toggles snapping
controls.snap.scripts.OnClick(controls.snap)
MOCK.check("snap box", db.pixelScale == false and not controls.snap.on)

-- hovering a theme shows a card drawn in that skin beside the menu, and the skin in use stays as it was
local accent = S.colors.accent
local classicItem = controls.theme.items[2]
classicItem.scripts.OnEnter(classicItem)
local card = S.SkinPreview("classic")
MOCK.check("preview shown", card and card.shown and card.point[2] == controls.theme.menu
	and card.rows[1].selectedTex.texture:find("UI%-QuestLogTitleHighlight"))
MOCK.check("skin kept", S.Skin() == "material" and S.colors.accent[1] == accent[1] and S.colors.accent[2] == accent[2]
	and S.metrics.inset == S.PAD)
-- built once per skin, and hidden again on leaving the item
classicItem.scripts.OnEnter(classicItem)
classicItem.scripts.OnLeave(classicItem)
MOCK.check("preview cached and hidden", S.SkinPreview("classic") == card and not card.shown)
S.UseSkin("material")
