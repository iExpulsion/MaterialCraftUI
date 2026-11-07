-- S.Table: column layout (stretching, hidden columns, header widths), items, sorting, selection and scrolling, and
-- its contents sitting inside the skin's well border.
local S = NS.Style
local function cell() return "" end

-- With no column marked stretch, the first (the primary one) takes the spare width; hiding a column gives it its
-- width too, and the last shown column keeps the scroll bar inset. Showing it again restores the layout.
local t = S.Table.New(UIParent, nil, 300, 200, { columns = {
	{ key = "a", width = 100 }, { key = "b", width = 50 }, { key = "c", width = 60 },
}, cell = cell })
local a, b, c = t.columns[1], t.columns[2], t.columns[3]
MOCK.check("first column stretches", a.width == 188 and b.x == 188 and c.x == 238 and c.width == 60 and c.barInset ~= nil)
t:SetColumnShown("c", false)
MOCK.check("hidden column gives its width away", c.hidden and a.width == 248 and b.width == 50 and b.barInset ~= nil
	and c.barInset == nil)
t:SetColumnShown("c", true)
MOCK.check("shown again", not c.hidden and a.width == 188 and b.barInset == nil and c.width == 60 and a.x == 0)

-- A column marked stretch takes the spare width instead of the first.
local s = S.Table.New(UIParent, nil, 300, 200, { columns = {
	{ key = "a", width = 100 }, { key = "b", width = 50, stretch = true }, { key = "c", width = 60 },
}, cell = cell })
local sa, sb, sc = s.columns[1], s.columns[2], s.columns[3]
MOCK.check("stretch column takes the spare width", sa.width == 100 and sb.width == 138 and sc.x == 238
	and sc.width == 60 and sc.barInset ~= nil)
s:SetColumnShown("c", false)
MOCK.check("a hidden column's width goes to the stretch column", sa.width == 100 and sb.width == 198
	and sb.barInset ~= nil)

-- A column too narrow for its header (mock labels measure 60px) widens to fit it, scroll bar gap included, and
-- the stretch column gives up the difference.
local h = S.Table.New(UIParent, nil, 300, 200, { columns = {
	{ key = "a", label = "Item", width = 100, stretch = true }, { key = "b", label = "Sources", width = 50 },
}, cell = cell })
local ha, hb = h.columns[1], h.columns[2]
MOCK.check("narrow column fits its header", hb.width == 60 + 24 + 10 and ha.width == 298 - hb.width)
-- A header's label fits beside the sort arrow on its right.
local hh = h.headers[2]
MOCK.check("header label leaves room for the arrow", hh.label.point[1] == "RIGHT" and hh.label.point[2] == -16 - 10)

-- Items fill the rows with each cell's text and color; rows past the items hide; an empty list shows its text.
local items = { { n = "One" }, { n = "Two" }, { n = "Three" } }
local list = S.Table.New(UIParent, nil, 300, 140, {
	columns = { { key = "n", label = "Name", width = 100 } },
	cell = function(item) return item.n, S.colors.muted end,
	isSelected = function(item) return item.n == "Two" end,
})
MOCK.check("rows fit the height", list.visible == math.floor((140 - 2 - 23) / 20))
list:SetItems(items)
MOCK.check("cells filled", list.rows[1].cells[1].text == "One" and list.rows[1].shown and not list.rows[4].shown)
MOCK.check("selection shown", list.rows[2].selectedTex.shown and not list.rows[1].selectedTex.shown)
list:SetItems({}, "Nothing Here")
MOCK.check("empty text", list.empty.text == "Nothing Here")

-- Scrolling moves the window over the items and stops at the last full page.
local many = {}
for i = 1, 10 do many[i] = { n = "Item " .. i } end
list:SetItems(many)
list:ScrollTo(100)
MOCK.check("scroll clamps", list.offset == 10 - list.visible and list.rows[1].cells[1].text == "Item " .. (list.offset + 1))

-- Clicking a header sorts by it, again reverses it, and reports the change.
local sorted
local byName = S.Table.New(UIParent, nil, 300, 100, {
	columns = { { key = "n", label = "Name", width = 100 } }, cell = cell,
	onSort = function(key, desc) sorted = { key, desc } end,
})
byName.headers[1].scripts.OnClick(byName.headers[1])
MOCK.check("sorts", sorted[1] == "n" and sorted[2] == false and byName.headers[1].arrow.shown)
byName.headers[1].scripts.OnClick(byName.headers[1])
MOCK.check("reverses", sorted[2] == true)

-- In a skin with a framed well, the contents sit inside its border and the columns share what's left.
LOAD("Skins/Classic/Skin.lua")
S.UseSkin("classic")
local framed = S.Table.New(UIParent, nil, 300, 200, { columns = { { key = "a", width = 100 } }, cell = cell })
local inset = 1 + S.metrics.wellInset
MOCK.check("inside the well border", framed.content.point[1] == "BOTTOMRIGHT" and framed.content.point[2] == -inset
	and framed.columns[1].width == 300 - 2 * inset
	and framed.frame.backdrop.edgeFile:find("Tooltip"))
S.UseSkin("material")

-- A plain list has no well frame and no header: its rows start at the top and fill the whole width.
local plain = S.Table.New(UIParent, nil, 200, 100, { plain = true, columns = { { key = "a", label = "", width = 50 } }, cell = cell })
MOCK.check("plain list", plain.frame.backdrop == nil and plain.bodyTop == 0 and plain.columns[1].width == 200
	and not plain.headers[1].shown and plain.visible == 5)

-- Dragging rows to reorder: the drop slot under the cursor, the dimmed row and drop line, edge scrolling, and the
-- move reported on release.
local moved
local drag = S.Table.New(UIParent, nil, 300, 140, {
	columns = { { key = "n", label = "Name", width = 100 } },
	cell = function(item) return item.n end,
	onClick = function(item) moved = { click = item.n } end,
	onMove = function(from, to) moved = { from, to } end,
})
local dragItems = {}
for i = 1, 10 do dragItems[i] = { n = "Item " .. i } end
drag:SetItems(dragItems)
drag.content.GetTop = function() return 400 end
local function cursorAt(slot) MOCK.cursorY = 400 - drag.bodyTop - (slot - drag.offset) * drag.rowH end
local function hold() MOCK.mouseDown = true end
local function release()
	MOCK.mouseDown = false
	drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
end
-- a plain table makes no drag parts and its rows don't drag
MOCK.check("no drag without onMove", list.dragLayer == nil and list.rows[1].scripts.OnDragStart == nil)

-- Dragging the second row below the fourth moves it to index 4, dims it while held and shows the drop line.
hold()
cursorAt(1)
drag.rows[2].scripts.OnDragStart(drag.rows[2])
MOCK.check("drag starts on the row", drag.drag.from == 2 and drag.rows[2].alpha == 0.4 and drag.rows[1].alpha == 1
	and drag.ghost.shown and drag.ghost.text.text == "Item 2")
drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
MOCK.check("no line where the row already is", not drag.dropLine.shown)
cursorAt(4)
drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
MOCK.check("drop line under the fourth row", drag.dropLine.shown and drag.dropLine.point[3] == -drag.bodyTop - 4 * drag.rowH + 1)
release()
MOCK.check("moved down", moved[1] == 2 and moved[2] == 4 and not drag.drag and not drag.dragLayer.shown
	and drag.rows[2].alpha == 1)
-- The release that ends a drag doesn't also click the row.
moved = nil
drag.rows[2].scripts.OnClick(drag.rows[2], "LeftButton")
MOCK.check("drop isn't a click", moved == nil)
MOCK.time = MOCK.time + 1
drag.rows[2].scripts.OnClick(drag.rows[2], "LeftButton")
MOCK.check("later clicks still select", moved and moved.click == "Item 2")

-- Dragging up to the top gap moves to index 1; letting go where it started reports nothing.
hold()
drag.rows[3].scripts.OnDragStart(drag.rows[3])
cursorAt(0.2)
drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
release()
MOCK.check("moved to the top", moved[1] == 3 and moved[2] == 1)
moved = nil
hold()
drag.rows[3].scripts.OnDragStart(drag.rows[3])
cursorAt(3)
drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
release()
MOCK.check("dropping in place reports nothing", moved == nil)

-- Holding at the bottom edge scrolls down a row at a time, and the drop can reach the end of the list.
hold()
drag.rows[1].scripts.OnDragStart(drag.rows[1])
for _ = 1, 20 do
	MOCK.time = MOCK.time + 1
	MOCK.cursorY = 400 - drag.bodyTop - drag.visible * drag.rowH
	drag.dragLayer.scripts.OnUpdate(drag.dragLayer, 0)
end
MOCK.check("edge scrolls to the end", drag.offset == 10 - drag.visible and drag.drag.slot == 10)
release()
MOCK.check("moved to the bottom", moved[1] == 1 and moved[2] == 10)

-- Hiding the table mid-drag cancels it without a move.
moved = nil
hold()
drag.rows[1].scripts.OnDragStart(drag.rows[1])
drag.dragLayer.scripts.OnHide(drag.dragLayer)
MOCK.check("hiding cancels", moved == nil and not drag.drag and not drag.ghost.shown)

-- Group header rows don't drag.
local grouped = S.Table.New(UIParent, nil, 300, 140, {
	columns = { { key = "n", label = "Name", width = 100 } }, cell = cell,
	header = function(item) return item.group end, onMove = function() end,
})
grouped:SetItems({ { group = "Group" }, { n = "A" } })
grouped.rows[1].scripts.OnDragStart(grouped.rows[1])
MOCK.check("headers don't drag", grouped.drag == nil)
MOCK.mouseDown, MOCK.cursorY = false, nil
