-- Wrapped text and stacks: text that wraps to its width and measures its lines, and a column that places rows top to
-- bottom, so a longer text pushes the rows under it down and the parent can size to fit, under any skin's inset.
local S = NS.Style
local check = MOCK.check

-- a font string whose text the client has wrapped to `lines` lines of 14
local function lines(fs, n)
	fs.GetHeight = function() return 14 * n end
	fs.GetStringHeight = function() return 14 * n end
	return fs
end

-- wrapped text wraps at word breaks and inside long words, sits at the top of its box, and measures its lines
local parent = CreateFrame("Frame")
parent:SetWidth(400)
local note = S.Wrapped(parent, "small")
check("wrapped is text", note.text == nil and note.wraps)
note.GetHeight = function() return 27.4 end
note.GetStringHeight = function() return 14 end
check("measures whole pixels, the taller reading", note:Measure() == 28)
note.GetHeight = function() return 0 end
check("either reading", note:Measure() == 14)

-- a stack places its rows down from the inset, a gap between each, and returns where it ends
local stack = S.Stack(parent, { width = 376 })
local title = stack:Add(S.Text(parent, "large"))
title:SetHeight(16)
local sub = stack:Add(lines(S.Wrapped(parent, "small"), 1), { gap = 4 })
local row = CreateFrame("Frame", nil, parent)
row:SetHeight(24)
row:Show()
stack:Add(row, { fill = true })
local inset = S.metrics.inset
-- a height would make the client cut wrapped text to one line, so the stack never sets one
local heightSet = false
sub.SetHeight = function() heightSet = true end
local bottom = stack:Layout()
check("first row at the inset", title.point[2] == parent and title.point[4] == inset and title.point[5] == -inset)
check("text below with its gap", sub.point[5] == -(inset + 16 + 4))
check("row below the text", row.point[5] == -(inset + 16 + 4 + 14 + S.GAP))
check("returns the end", bottom == inset + 16 + 4 + 14 + S.GAP + 24)
check("wrapped text and fill rows get the width", sub.width == 376 and row.width == 376 and title.width == nil)
check("wrapped text gets no height", not heightSet)

-- two lines of text push the row down by a line and the column ends a line lower
lines(sub, 2)
local taller = stack:Layout()
check("pushed down", row.point[5] == -(inset + 16 + 4 + 28 + S.GAP) and taller == bottom + 14 and not heightSet)

-- the client measures new lines only once it has drawn them, so the stack lays out again on the next frame and
-- tells onLayout where it ends after each pass
local ends = {}
stack.onLayout = function(bottom) ends[#ends + 1] = bottom end
stack:Layout()
check("lays out again next frame", stack.later.shown and ends[1] == taller)
lines(sub, 3)
stack.later.scripts.OnUpdate(stack.later)
check("second pass sees the new lines", not stack.later.shown and ends[2] == taller + 14
	and row.point[5] == -(inset + 16 + 4 + 42 + S.GAP))
lines(sub, 2)
stack.onLayout = nil
stack:Layout()

-- a wrapped row gets its width as it's added, before any layout
local early = S.Stack(parent, { width = 200 })
local fresh = early:Add(S.Wrapped(parent, "small"))
check("width on add", fresh.width == 200)

-- hidden rows take no room and no gap
row:Hide()
check("hidden row skipped", stack:Layout() == inset + 16 + 4 + 28)
row:Show()

-- indent shifts a row and narrows a filled one; height can be fixed or worked out
local indented = CreateFrame("Frame", nil, parent)
indented:Show()
stack:Add(indented, { indent = 20, fill = true, height = function() return 30 end })
local fixed = CreateFrame("Frame", nil, parent)
fixed:Show()
stack:Add(fixed, { height = 10, gap = 0 })
local finish = stack:Layout()
check("indent", indented.point[4] == inset + 20 and indented.width == 376 - 20)
check("height from a function and a number", finish == taller + S.GAP + 30 + 10)

-- without a width the column is the parent's width less the inset on both sides
local open = S.Stack(parent)
local wide = open:Add(lines(S.Wrapped(parent, "small"), 1))
open:Layout()
check("default width", wide.width == 400 - 2 * inset)

-- a skin with a thicker frame moves the column in and makes it narrower
LOAD("Skins/Cognac/Atlas.lua")
LOAD("Skins/Cognac/Skin.lua")
S.UseSkin("cognac")
local thick = S.metrics.inset
local skinned = S.Stack(parent)
local text = skinned:Add(lines(S.Wrapped(parent, "small"), 1))
skinned:Layout()
check("skin inset", thick > inset and text.point[4] == thick and text.point[5] == -thick and text.width == 400 - 2 * thick)
