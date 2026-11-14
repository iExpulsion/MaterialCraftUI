-- Wrapped text and stacks: text that wraps to its width and measures its lines, and a column that places rows top to
-- bottom, so a longer text pushes the rows under it down and the parent can size to fit, under any skin's inset.
local S = NS.Style
local check = MOCK.check

-- a font string whose text is `lines` lines tall at 14 per line, as the client would measure it once wrapped
local function lines(fs, n)
	fs.GetStringHeight = function() return 14 * n end
	return fs
end

-- wrapped text wraps at word breaks and inside long words, sits at the top of its box, and measures its lines
local parent = CreateFrame("Frame")
parent:SetWidth(400)
local note = S.Wrapped(parent, "small")
check("wrapped is text", note.text == nil and note.wraps)
note.GetStringHeight = function() return 27.4 end
check("measures whole pixels", note:Measure() == 28)

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
local bottom = stack:Layout()
check("first row at the inset", title.point[2] == parent and title.point[4] == inset and title.point[5] == -inset)
check("text below with its gap", sub.point[5] == -(inset + 16 + 4))
check("row below the text", row.point[5] == -(inset + 16 + 4 + 14 + S.GAP))
check("returns the end", bottom == inset + 16 + 4 + 14 + S.GAP + 24)
check("wrapped text and fill rows get the width", sub.width == 376 and row.width == 376 and title.width == nil)
check("wrapped text is as tall as its lines", sub.height == 14)

-- two lines of text push the row down by a line and the column ends a line lower
lines(sub, 2)
local taller = stack:Layout()
check("pushed down", row.point[5] == -(inset + 16 + 4 + 28 + S.GAP) and taller == bottom + 14 and sub.height == 28)

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
local ends = stack:Layout()
check("indent", indented.point[4] == inset + 20 and indented.width == 376 - 20)
check("height from a function and a number", ends == taller + S.GAP + 30 + 10)

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
