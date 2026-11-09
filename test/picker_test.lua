-- S.Picker and S.PickerButton: the searchable list opens under its button, filters as you type, picks and closes,
-- stays open in multi mode, and opening it from the same button again closes it.
local S = NS.Style

local picked
local items = { { value = 1, text = "Elwynn Forest" }, { value = 2, text = "Westfall" }, { value = 3, text = "Duskwood" } }
local b = S.PickerButton(UIParent, 170, function()
	return { items = items, placeholder = "Search Zones", isSelected = function(v) return v == 2 end,
		onPick = function(v) picked = v end }
end)
b:SetText("Westfall")
MOCK.check("button shows the choice", b.label:GetText() == "Westfall")

-- Clicking the button opens the picker with every item and the placeholder it asked for
b:GetScript("OnClick")(b)
local picker = _G.TestAddonPicker
MOCK.check("opens", picker and picker:IsShown() and #picker.list.items == 3)
MOCK.check("placeholder", picker.search.placeholder:GetText() == "Search Zones")
-- The selected entry is drawn in the heading color
local text, color = picker.list.cell(items[2], "text")
MOCK.check("selected color", text == "Westfall" and color == S.colors.heading)

-- Typing filters, ignoring case
picker.search:SetText("WEST")
picker.search:GetScript("OnTextChanged")(picker.search, true)
MOCK.check("filters", #picker.list.items == 1 and picker.list.items[1].value == 2)

-- Picking calls onPick and closes
picker.list.onClick(picker.list.items[1])
MOCK.check("picks and closes", picked == 2 and not picker:IsShown())

-- Clicking the same button twice opens then closes it
b:GetScript("OnClick")(b)
b:GetScript("OnClick")(b)
MOCK.check("toggles", not picker:IsShown())

-- Multi mode stays open and marks the picked entries
local chosen = {}
S.Picker.Open(b, { multi = true, items = items, isSelected = function(v) return chosen[v] end,
	onPick = function(v) chosen[v] = not chosen[v] end })
picker.list.onClick(items[3])
local mark = picker.list.cell(items[3], "text")
MOCK.check("multi stays open", picker:IsShown() and chosen[3] and mark:find("+", 1, true) ~= nil)
S.Picker.Close()
MOCK.check("close", not picker:IsShown())
