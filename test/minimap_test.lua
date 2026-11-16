-- S.MinimapButton: placed on the minimap's edge at its angle, dragged around it or (Shift) anywhere, hidden and
-- reset from its saved table, clicks and the tooltip with the drag hint.
local S = NS.Style

local db = {}
local clicks, dragStarts, reparents = {}, 0, 0
local b = S.MinimapButton({
	name = "TestMinimapButton", icon = "Interface\\Icons\\Test", db = db, angle = 0,
	onClick = function(_, mouse) clicks[#clicks + 1] = mouse end,
	tooltip = function(tt) tt:AddLine("Test Addon") end,
	hint = "/test minimap hides it.",
	onDragStart = function() dragStarts = dragStarts + 1 end,
	onReparent = function() reparents = reparents + 1 end,
})

-- at angle 0 it sits on the minimap's right edge (radius 70 + 5), shown, with its icon
MOCK.check("placed on the edge", b.point[1] == "CENTER" and b.point[2] == Minimap and b.point[4] == 75 and b.point[5] == 0
	and b.shown and b.icon.texture == "Interface\\Icons\\Test" and b:GetParent() == Minimap)

-- clicks go to onClick with the mouse button
b.scripts.OnClick(b, "RightButton")
MOCK.check("click", clicks[1] == "RightButton")

-- the tooltip has the addon's lines, the drag hint and the hint line
local lines = {}
GameTooltip.AddLine = function(_, text) lines[#lines + 1] = text end
b.scripts.OnEnter(b)
MOCK.check("tooltip", lines[1] == "Test Addon" and lines[2]:find("^Drag to move") and lines[3] == "/test minimap hides it.")

-- dragging straight up from the minimap's center moves it to 90 degrees, until the mouse is let go
b.scripts.OnDragStart(b)
MOCK.mouseDown, MOCK.cursorX, MOCK.cursorY = true, 500, 600
b.dragger.scripts.OnUpdate(b.dragger)
MOCK.check("dragged around", dragStarts == 1 and math.abs(db.angle - 90) < 0.01 and math.abs(b.point[5] - 75) < 0.01)
MOCK.mouseDown = false
b.dragger.scripts.OnUpdate(b.dragger)
MOCK.check("drag ends on release", not b.dragger.shown)

-- Shift-drag frees it onto UIParent at the cursor
local shift = IsShiftKeyDown
IsShiftKeyDown = function() return true end
b.scripts.OnDragStart(b)
IsShiftKeyDown = shift
MOCK.mouseDown, MOCK.cursorX, MOCK.cursorY = true, 300, 200
b.dragger.scripts.OnUpdate(b.dragger)
MOCK.check("freed", db.free and db.free.x == 300 and b:GetParent() == UIParent and b.point[2] == UIParent and reparents == 1)
MOCK.mouseDown = false
b.dragger.scripts.OnUpdate(b.dragger)

-- reset puts it back on the minimap at its starting angle
b:ResetPosition()
MOCK.check("reset", db.free == nil and db.angle == nil and b:GetParent() == Minimap and b.point[4] == 75 and reparents == 2)

-- hiding is saved in the table
db.hide = true
b:Refresh()
MOCK.check("hidden", not b.shown)
