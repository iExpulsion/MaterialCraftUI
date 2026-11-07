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
