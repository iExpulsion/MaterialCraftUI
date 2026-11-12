-- Pixel alignment: the size of a screen pixel in UI units, snapping lengths to it, scaling a window to whole
-- pixels per unit at different UI scales and screen sizes, and snapping a window's position.
local S = NS.Style
local function near(a, b) return math.abs(a - b) < 1e-6 end

-- At 1080p with a UI scale of 1, one unit is 1080 / 768 screen pixels, so a pixel is 768 / 1080 units.
UIParent.scale = 1
local win = CreateFrame("Frame", nil, UIParent)
MOCK.check("pixel size", near(S.PixelSize(win), 768 / 1080))
-- A length snaps to the nearest whole number of pixels.
MOCK.check("snap", near(S.Snap(win, 12), math.floor(12 * 1080 / 768 + 0.5) * 768 / 1080))

-- Pixel-scaling the window makes one of its units exactly one screen pixel, the nearest whole number to 1.406.
S.PixelScale(win)
MOCK.check("whole pixels per unit", near(win:GetEffectiveScale() * 1080 / 768, 1) and near(S.PixelSize(win), 1))
-- Then whole-unit lengths are already on pixels.
MOCK.check("whole units land on pixels", near(S.Snap(win, 12), 12) and near(S.Snap(win, 0.4), 0))

-- At a UI scale whose units are 1.8 pixels, the window rounds to 2 pixels per unit.
UIParent.scale = 1.8 * 768 / 1080
S.PixelScale(win)
MOCK.check("rounds to the nearest multiple", near(win:GetEffectiveScale() * 1080 / 768, 2))
-- A UI scale change re-scales pixel-scaled windows.
UIParent.scale = 768 / 1080
MOCK.Fire("UI_SCALE_CHANGED")
MOCK.check("follows the UI scale", near(win:GetEffectiveScale() * 1080 / 768, 1))

-- On a 1440p screen at a UI scale of 1, units are 1.875 pixels, so the window rounds to 2.
MOCK.resolution = "2560x1440"
UIParent.scale = 1
S.PixelScale(win)
MOCK.check("other screen sizes", near(win:GetEffectiveScale() * 1440 / 768, 2))
-- Never below one pixel per unit, however small the UI scale.
UIParent.scale = 0.3
S.PixelScale(win)
MOCK.check("at least one pixel", near(win:GetEffectiveScale() * 1440 / 768, 1))

-- Turning it off puts the window's own scale back to 1.
S.PixelScale(win, false)
MOCK.check("off", win:GetScale() == 1)

-- Snapping the position moves the top left corner onto a whole pixel.
MOCK.resolution, UIParent.scale = "1920x1080", 1
S.PixelScale(win)
win.GetLeft = function() return 100.3 end
win.GetTop = function() return 500.6 end
S.SnapPosition(win)
MOCK.check("position snapped", win.point[1] == "TOPLEFT" and near(win.point[4], 100) and near(win.point[5], 501))
UIParent.scale = 1

-- PlaceWindow puts a window's top S.WINDOW_TOP (128) of UIParent's units below the screen's top, converted into a
-- pixel-scaled window's own units so it lands in the same place.
UIParent.scale = 1
local placed = CreateFrame("Frame", nil, UIParent)
S.PlaceWindow(placed)
MOCK.check("place window", placed.point[1] == "TOP" and placed.point[3] == "TOP" and near(placed.point[5], -128))
S.PixelScale(placed)
S.PlaceWindow(placed)
MOCK.check("place a scaled window", near(placed.point[5] * placed:GetEffectiveScale(), -128))

-- The window scale multiplies the snapped size: at 1080p and a UI scale of 1 a window is 1 pixel per unit, and
-- 1.5 makes it 1.5 exactly, since no whole number is near.
local sized = S.PixelScale(CreateFrame("Frame", nil, UIParent))
S.SetWindowScale(1.5)
MOCK.check("window scale", near(sized:GetEffectiveScale() * 1080 / 768, 1.5))
-- At 2 pixels per unit (1440p), 1.5 is exactly 3 whole pixels, and 1.25 (2.5) stays exact.
MOCK.resolution = "2560x1440"
MOCK.Fire("UI_SCALE_CHANGED")
MOCK.check("window scale snaps to a whole multiple", near(sized:GetEffectiveScale() * 1440 / 768, 3))
S.SetWindowScale(1.25)
MOCK.check("window scale between multiples", near(sized:GetEffectiveScale() * 1440 / 768, 2.5))
-- Within 5% of a whole number of pixels it snaps to it: 2 x 1.02 is 2.04, so 2.
S.SetWindowScale(1.02)
MOCK.check("window scale near a multiple", near(sized:GetEffectiveScale() * 1440 / 768, 2))
-- A window without snapping takes the window scale as it is.
local loose = S.PixelScale(CreateFrame("Frame", nil, UIParent), false)
S.SetWindowScale(1.3)
MOCK.check("window scale without snapping", near(loose:GetScale(), 1.3))
-- Changing it keeps a window's top left corner on the same spot of the screen.
loose.GetLeft = function(self) return 200 / self.scale end
loose.GetTop = function(self) return 600 / self.scale end
S.SetWindowScale(1.6)
MOCK.check("window scale keeps the spot", loose.point[1] == "TOPLEFT"
	and near(loose.point[4] * loose:GetEffectiveScale(), 200) and near(loose.point[5] * loose:GetEffectiveScale(), 600))
S.SetWindowScale(1)
MOCK.check("window scale back to 1", near(loose:GetScale(), 1) and near(sized:GetEffectiveScale() * 1440 / 768, 2))
MOCK.resolution = "1920x1080"
