-- S.List: rows laid out top to bottom with their parts, header gaps and two-line rows, reuse across redraws,
-- cursor drops, the hover remove button, colored headers and the sticky header overlay.
local S = NS.Style

local list = S.List.New(UIParent, "TestList", 200, 100)
local clicked, dropped, removed
local function build(extra)
	list:Begin()
	list:Add({ text = "Offensive", header = true, status = "2 / 5", color = S.colors.red,
		onClick = function(row) clicked = row.text.text end })
	list:Add({ text = "Perk 1", check = true, icon = "Interface\\Icons\\Test", onDrop = function(...) dropped = { ... } end })
	list:Add({ text = "Perk 2", sub = "Second line", onRemove = function(row) removed = row.text.text end, removeTip = "Drop It" })
	for i = 3, 4 do list:Add({ text = "Perk " .. i, selected = i == 4 }) end
	list:Add({ text = "Misc", header = true, status = "1" })
	for i = 1, (extra or 4) do list:Add({ text = "Misc " .. i }) end
	list:End()
end
build()
local rows = list.rows

-- rows stack: a sub row is taller, a header after the first gets a gap above it
MOCK.check("rows stack", rows[1].y == 0 and rows[2].y == 22 and rows[3].y == 44 and rows[4].y == 80
	and rows[6].y == 22 * 4 + 36 + 6)
-- a checkbox and an icon push the text right; the selected row shows its bar
MOCK.check("row parts", rows[2].check.shown and rows[2].icon.shown and rows[2].text.point[2] == S.PAD + S.CHECK_H + 6 + 20
	and rows[5].bar.shown and not rows[4].bar.shown)

-- a colored header shows its color and a rule; a plain one the heading color and none
MOCK.check("colored header", rows[1].text.color[1] == S.colors.red[1] and rows[1].rule.shown)
MOCK.check("plain header", rows[6].text.color[1] == S.colors.heading[1] and not rows[6].rule.shown)

-- whatever is on the cursor drops on a row with onDrop, with GetCursorInfo's values
MOCK.cursor = { "spell", 12, "spell" }
rows[2].scripts.OnClick(rows[2], "LeftButton")
MOCK.check("cursor drop", dropped and dropped[1] == "spell" and dropped[2] == 12 and MOCK.cursor == nil)

-- hovering a removable row shows its X over the status; clicking it removes
rows[3].scripts.OnEnter(rows[3])
MOCK.check("remove on hover", rows[3].remove.shown and not rows[3].status.shown)
rows[3].remove.scripts.OnClick(rows[3].remove)
MOCK.check("remove clicked", removed == "Perk 2")
rows[3].scripts.OnLeave(rows[3])
MOCK.check("hover ends", not rows[3].remove.shown and rows[3].status.shown)

-- moving from a row onto its X keeps the row hovered; leaving the X for elsewhere ends it
rows[3].scripts.OnEnter(rows[3])
MOCK.mouseOver = rows[3].remove
rows[3].scripts.OnLeave(rows[3])
MOCK.check("hover kept on X", list.hoverRow == rows[3] and rows[3].remove.shown)
MOCK.mouseOver = nil
rows[3].remove.scripts.OnLeave(rows[3].remove)
MOCK.check("hover ends off X", list.hoverRow == nil and not rows[3].remove.shown)

-- entering the next row before the last one sees the mouse leave leaves one row hovered
rows[3].scripts.OnEnter(rows[3])
rows[4].scripts.OnEnter(rows[4])
MOCK.check("one hovered row", list.hoverRow == rows[4] and not rows[3].remove.shown and rows[3].status.shown)
rows[4].scripts.OnLeave(rows[4])
MOCK.check("no hovered row", list.hoverRow == nil)

-- a shorter redraw hides the rows it no longer needs and reuses the rest
build(1)
MOCK.check("rows reused", list.rows[1] == rows[1] and rows[7].shown and not rows[8].shown)
build()

-- Sticky headers: nothing held at the top; scrolled into a section, the overlay copies its header (text, status,
-- rule) and hands clicks to it; the next header takes over; back at the top it hides
list:SetSticky()
local scroll = 0
list.scroll.GetVerticalScroll = function() return scroll end
local function scrollTo(y)
	scroll = y
	list.scroll.scripts.OnVerticalScroll(list.scroll, y)
end
scrollTo(0)
MOCK.check("nothing held at the top", not list.stuck.shown)
scrollTo(30)
MOCK.check("first header held", list.stuck.shown and list.stuck.text.text == "Offensive"
	and list.stuck.status.text == "2 / 5" and list.stuck.rule.shown and list.stuck.source == rows[1])
list.stuck.scripts.OnClick(list.stuck, "LeftButton")
MOCK.check("click goes to the header", clicked == "Offensive")
scrollTo(rows[6].y + 5)
MOCK.check("second header held", list.stuck.text.text == "Misc" and not list.stuck.rule.shown)
scrollTo(0)
MOCK.check("hidden at the top again", not list.stuck.shown)
scroll = 30
build()
MOCK.check("a redraw keeps it", list.stuck.shown and list.stuck.text.text == "Offensive")
