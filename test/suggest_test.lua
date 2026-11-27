-- S.Suggest: suggestions under an input as it's typed in, starts-with matches first, with Tab, Enter, Up, Down,
-- Escape and clicks, a list input completing only its last entry, and staying quiet when told to.
local S = NS.Style

local function type(input, text)
	input:SetText(text)
	input.scripts.OnTextChanged(input, true)
end

local SPELLS = {
	{ text = "Blood Strike", icon = "blood" },
	{ text = "Death Strike", icon = "death" },
	{ text = "Plague Strike", icon = "plague" },
	{ text = "Blood Boil", icon = "boil" },
	{ text = "Icy Touch" },
}
local entered, picked = 0, nil
local input = S.Input(UIParent, "SuggestTestInput", 200, "Spell")
input:SetScript("OnEnterPressed", function() entered = entered + 1 end)
local list = S.Suggest(input, { list = function() return SPELLS end, onPick = function(item) picked = item.text end })

-- names starting with the typed text come before names that contain it, capitals ignored
type(input, "blo")
MOCK.check("list opens", list.shown and #list.matches == 2 and list.matches[1].text == "Blood Strike")
type(input, "strike")
MOCK.check("contains matches", #list.matches == 3 and list.rows[1].text.text == "Blood Strike" and list.rows[1].icon.texture == "blood")
type(input, "D")
MOCK.check("starts first", #list.matches == 3 and list.matches[1].text == "Death Strike"
	and list.matches[2].text == "Blood Strike" and list.matches[3].text == "Blood Boil")
MOCK.check("first highlighted", list.rows[1].locked and not list.rows[2].locked)

-- Down and Up move the highlight, wrapping at the ends; the client's edit boxes have no OnArrowPressed, so the keys
-- come through OnKeyDown
MOCK.check("no arrow script hooked", input.scripts.OnArrowPressed == nil and input.scripts.OnKeyDown ~= nil)
input.scripts.OnKeyDown(input, "DOWN")
MOCK.check("down moves", list.rows[2].locked and not list.rows[1].locked)
input.scripts.OnKeyDown(input, "UP")
input.scripts.OnKeyDown(input, "UP")
MOCK.check("up wraps to the last", list.rows[#list.matches].locked)

-- Tab takes the highlighted one (Down from the last wraps to the first) and closes the list without Enter's action
input.scripts.OnKeyDown(input, "DOWN")
input.scripts.OnTabPressed(input)
MOCK.check("tab picks", input:GetText() == "Death Strike" and picked == "Death Strike" and not list.shown and entered == 0)

-- Enter takes it and then runs the input's own Enter
type(input, "icy")
input.scripts.OnEnterPressed(input)
MOCK.check("enter picks then enters", input:GetText() == "Icy Touch" and entered == 1)

-- with the list closed, Enter only does the input's own thing
type(input, "Nothing Like It")
MOCK.check("no matches, no list", not list.shown)
input.scripts.OnEnterPressed(input)
MOCK.check("typed text kept", input:GetText() == "Nothing Like It" and entered == 2)

-- the one match being exactly what's typed shows nothing
type(input, "icy touch")
MOCK.check("exact match hides", not list.shown)

-- Escape closes the list first, and only then leaves the input
type(input, "death")
input.scripts.OnEditFocusGained(input)
input.scripts.OnEscapePressed(input)
MOCK.check("escape closes the list", not list.shown and input.focused)
input.scripts.OnEscapePressed(input)
MOCK.check("escape again leaves", not input.focused)

-- clicking a suggestion picks it
type(input, "plag")
list.rows[1].scripts.OnClick(list.rows[1])
MOCK.check("click picks", input:GetText() == "Plague Strike")

-- a list input completes its last entry only
local many = S.Input(UIParent, "SuggestTestList", 200, "Spells")
local manyList = S.Suggest(many, { list = function() return SPELLS end, separator = "," })
type(many, "Icy Touch, plag")
MOCK.check("last entry matched", manyList.shown and manyList.matches[1].text == "Plague Strike")
many.scripts.OnTabPressed(many)
MOCK.check("last entry replaced", many:GetText() == "Icy Touch, Plague Strike")

-- enabled() false keeps it quiet
local quiet = true
local off = S.Input(UIParent, "SuggestTestOff", 200, "Lines")
local offList = S.Suggest(off, { list = function() return SPELLS end, enabled = function() return not quiet end })
type(off, "blo")
MOCK.check("quiet when disabled", not offList.shown)
quiet = false
type(off, "blo")
MOCK.check("speaks when enabled", offList.shown)

-- it's a menu: closing menus closes it, and hiding the input hides it
S.CloseMenus()
MOCK.check("closes with menus", not offList.shown)
type(off, "blo")
off.scripts.OnHide(off)
MOCK.check("closes with its input", not offList.shown)
