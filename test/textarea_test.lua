-- S.TextArea: an edit box in a well that takes the well's clicks, reports typing apart from set text, leaves text
-- being typed alone, goes read-only, selects all on focus when asked, and handles Escape.
local S = NS.Style

local typed, changes, escaped = {}, 0, nil
local area = S.TextArea(UIParent, "TestTextArea", 300, 120, {
	font = "normal",
	onInput = function(text) typed[#typed + 1] = text end,
	onTextChanged = function() changes = changes + 1 end,
})
local edit = area.edit

-- it fills its well inside the padding, with the scroll frame as the edit box's parent
MOCK.check("built", area.width == 300 and area.height == 120 and edit.width == 300 - 2 * 8 - 10 and area.scroll ~= nil)

-- typing reports the text; text set from code changes it without reporting it as typed
edit:SetText("hello")
edit.scripts.OnTextChanged(edit, true)
edit.scripts.OnTextChanged(edit, false)
MOCK.check("typing reported", #typed == 1 and typed[1] == "hello" and changes == 2)

-- SetValue leaves text alone while it's being typed in
edit.scripts.OnEditFocusGained(edit)
area:SetValue("replaced")
MOCK.check("kept while typing", edit.text == "hello")
edit.scripts.OnEditFocusLost(edit)
area:SetValue("replaced")
MOCK.check("set when not typing", edit.text == "replaced")

-- a click in the well types in it
local focused = false
edit.SetFocus = function() focused = true end
area.scripts.OnMouseDown(area)
MOCK.check("well click focuses", focused)

-- read-only stops it taking the mouse
local mouse = {}
area.EnableMouse = function(_, on) mouse.box = on end
edit.EnableMouse = function(_, on) mouse.edit = on end
area:SetReadOnly(true)
MOCK.check("read-only", mouse.box == false and mouse.edit == false)

-- Escape stops typing by default, or does what the caller asks
local cleared = false
edit.ClearFocus = function() cleared = true end
edit.scripts.OnEscapePressed(edit)
MOCK.check("escape clears focus", cleared)
local copy = S.TextArea(UIParent, "TestCopyArea", 200, 80, { selectOnFocus = true, onEscape = function() escaped = true end })
local selected = false
copy.edit.HighlightText = function() selected = true end
copy.edit.scripts.OnEditFocusGained(copy.edit)
copy.edit.scripts.OnEscapePressed(copy.edit)
MOCK.check("select on focus and custom escape", selected and escaped)
