-- S.ContextMenu: opens beside a row on the side asked for with one item per option, runs the picked option's action
-- and closes, draws disabled and danger items in their colors, reuses its items for a shorter list, and closes on a
-- click elsewhere. S.Table hands onClick the clicked row to open it beside.
local S = NS.Style

local menu = S.ContextMenu()
local row = CreateFrame("Button", nil, UIParent)
local ran
local options = {
	{ text = "Focus", action = function() ran = "focus" end },
	{ text = "Route to Quest", action = function() ran = "route" end, tooltip = "Plans a route." },
	{ text = "Locked", action = function() ran = "locked" end, disabled = true },
	{ text = "Abandon", action = function() ran = "abandon" end, danger = true },
}

-- Opening shows one item per option, with the row as its owner
menu:Open(row, options, "RIGHT")
local shown = 0
for _, it in ipairs(menu.items) do
	if it:IsShown() then shown = shown + 1 end
end
MOCK.check("opens", menu:IsShown() and shown == 4 and menu.owner == row)
MOCK.check("height fits", menu:GetHeight() == 4 * S.CONTROL_H + 2 * S.metrics.menuInset)

-- On the right it hangs from the row's right edge, on the left from its left edge
local point, rel, relPoint = menu:GetPoint(1)
MOCK.check("right side", point == "TOPLEFT" and rel == row and relPoint == "TOPRIGHT", point)
menu:Open(row, options)
point, rel, relPoint = menu:GetPoint(1)
MOCK.check("left side", point == "TOPRIGHT" and rel == row and relPoint == "TOPLEFT", point)

-- Disabled items are drawn dimmed and can't be clicked; danger items take the error color
local function same(a, b) return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] end
MOCK.check("disabled", not menu.items[3]:IsEnabled() and same(menu.items[3].text.color, S.colors.disabled))
MOCK.check("danger", same(menu.items[4].text.color, S.colors.bad) and same(menu.items[1].text.color, S.colors.text))
MOCK.check("tooltip kept", menu.items[2].tooltip == "Plans a route.")

-- Picking runs the action and closes the menu
menu.items[2]:GetScript("OnClick")(menu.items[2])
MOCK.check("runs and closes", ran == "route" and not menu:IsShown())

-- A shorter list hides the items left over from the longer one
menu:Open(row, { options[1] })
MOCK.check("shorter list", menu.items[1]:IsShown() and not menu.items[2]:IsShown() and not menu.items[4]:IsShown())

-- Opening it closes the other menus, and a click elsewhere closes it
local other = S.ContextMenu()
other:Open(row, options)
MOCK.check("one open at a time", other:IsShown() and not menu:IsShown())
S.CloseMenus()
MOCK.check("closes with the others", not other:IsShown())

-- A table row's click hands onClick the row itself
local clickedRow, clickedButton
local t = S.Table.New(UIParent, "ContextTable", 300, 200, {
	columns = { { key = "name", label = "Name", width = 200 } },
	cell = function(item) return item.name end,
	onClick = function(_, button, r) clickedButton, clickedRow = button, r end,
})
t:SetItems({ { name = "Kobold Camp Cleanup" } })
local first = t.rows[1]
first:GetScript("OnClick")(first, "RightButton")
MOCK.check("table passes the row", clickedRow == first and clickedButton == "RightButton")
