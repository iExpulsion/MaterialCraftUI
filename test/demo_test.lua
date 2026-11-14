-- The demo addon: it loads on the kit, opens with /mcui, builds every page, and rebuilds itself for each theme,
-- the Cognac, Classic and Material Glass skins included; and the Layout page's tabs, reorder list and pickers, the
-- Text page's dialog that grows with its text, and the Items table's right-click menu, work.
local S = NS.Style
LOAD("Skins/Cognac/Atlas.lua")
LOAD("Skins/Cognac/Skin.lua")
LOAD("Skins/Classic/Skin.lua")
LOAD("Skins/MaterialGlass/Skin.lua")

local file = io.open(ROOT .. "/demo/MaterialCraftUIDemo/Demo.lua", "r")
local src = file:read("*a")
file:close()
local chunk = assert(loadstring(src, "Demo.lua"))

-- The file loads, registers its slash command and lets Escape close the window.
chunk("MaterialCraftUIDemo", NS)
MOCK.check("demo loads", NS.Demo ~= nil and SlashCmdList.MATERIALCRAFTUIDEMO ~= nil)
MOCK.check("escape closes the window", UISpecialFrames[#UISpecialFrames] == "MaterialCraftUIDemoWindow")

-- /mcui opens the window, and again closes it.
SlashCmdList.MATERIALCRAFTUIDEMO()
local first = NS.Demo.window()
MOCK.check("slash opens the window", first ~= nil and first:IsShown())
SlashCmdList.MATERIALCRAFTUIDEMO()
MOCK.check("slash closes the window", not first:IsShown())

-- Every theme rebuilds the window with that theme's accent.
for i, roles in ipairs({ false, { primary = "7cacf8" }, { primary = "ffc400" }, { primary = "7dd99c" }, { primary = "ffb1c8" } }) do
	NS.Demo.setTheme(i)
	local accent = S.colors.accent
	local expected = roles and tonumber(roles.primary:sub(1, 2), 16) / 255 or 208 / 255
	MOCK.check("theme " .. i .. " rebuilds", NS.Demo.window():IsShown() and math.abs(accent[1] - expected) < 0.001)
end
MOCK.check("old window hidden after a theme change", not first:IsShown())

-- The Cognac entry rebuilds the window in that skin, larger by its border so the content keeps its size.
NS.Demo.setTheme(6)
local cognac = NS.Demo.window()
MOCK.check("cognac rebuilds", S.Skin() == "cognac" and cognac:IsShown() and cognac.width == 680 + 36)
-- The Classic entry rebuilds it in the stock look, larger by its dialog border.
NS.Demo.setTheme(7)
MOCK.check("classic rebuilds", S.Skin() == "classic" and NS.Demo.window().width == 680 + 24)
-- The Material Glass entry rebuilds it on glass with the amber accent, at Material's size.
NS.Demo.setTheme(8)
MOCK.check("glass rebuilds", S.Skin() == "materialglass" and NS.Demo.window().width == 680
	and math.abs(S.colors.accent[1] - 1) < 0.001 and NS.Demo.window().grain ~= nil)
-- The Layout page's tabs: the first starts selected, and clicking another moves the selection.
local parts = NS.Demo.parts
local tabs = parts.tabs
MOCK.check("tabs built", #tabs == 3 and tabs[1].selected and not tabs[2].selected)
tabs[2].scripts.OnClick(tabs[2])
MOCK.check("tab click selects", tabs[2].selected and not tabs[1].selected)

-- Dropping the last priority at the top moves it there and renumbers the rows.
parts.reorder.onMove(4, 1)
MOCK.check("reorder moves", NS.Demo.state.priorities[1] == "Filler" and parts.priorityRows[1].text.text == "1.  Filler"
	and parts.priorityRows[2].text.text == "2.  Interrupt")
parts.reorder.onMove(1, 4)

-- The item picker shows the picked item; the slot picker toggles slots and counts them.
parts.itemSpec.onPick(3)
MOCK.check("item picked", parts.itemPicker.label.text == "Cracked Stone Idol" and parts.itemSpec.isSelected(3))
parts.slotSpec.onPick("Head")
parts.slotSpec.onPick("Feet")
parts.slotSpec.onPick("Head")
MOCK.check("slots toggled", parts.slotSpec.isSelected("Feet") and not parts.slotSpec.isSelected("Head"))

-- Right-clicking an Items row opens its menu beside the row; Hide takes the item out of the list, and Show Hidden
-- Items, enabled only while something is hidden, brings it back.
local list = parts.list
local topItem = list.items[1]
local options = parts.rowMenu(topItem)
MOCK.check("menu options", #options == 4 and options[3].disabled and options[4].danger and options[2].disabled)
list.onClick(topItem, "RightButton", list.rows[1])
MOCK.check("right-click opens menu", parts.menu:IsShown() and parts.menu.owner == list.rows[1])
options[4].action()
MOCK.check("hide item", #list.items == 28 and list.items[1] ~= topItem and not parts.rowMenu(list.items[1])[3].disabled)
parts.rowMenu(list.items[1])[3].action()
MOCK.check("show hidden", #list.items == 29 and list.items[1] == topItem)

-- The Text page's dialog: longer text wraps to more lines, pushing the buttons down and growing the dialog; shorter
-- text shrinks it again. The mock measures each line of text as 14 tall.
local function linesOf(fs)
	fs.GetStringHeight = function(self) return 14 * math.ceil(#(self.text or "") / 60) end
end
parts.openDialog.scripts.OnClick(parts.openDialog)
local dialog = parts.dialog
linesOf(dialog.sub)
linesOf(dialog.body)
dialog.relayout()
local medium = dialog.height
local buttonsAt = dialog.stack.rows[4].region.point[5]
MOCK.check("dialog open", dialog:IsShown() and dialog.sub.text ~= nil and medium > 0)
local function click(label)
	for _, child in ipairs(MOCK.created) do
		if child.label and child.label.text == label and child.parent and child.parent.parent == dialog then
			child.scripts.OnClick(child)
			return
		end
	end
end
click("Longer")
MOCK.check("longer grows", dialog.height > medium and dialog.stack.rows[4].region.point[5] < buttonsAt)
click("Shorter")
click("Shorter")
MOCK.check("shorter shrinks", dialog.height < medium and NS.Demo.state.length == 1)
-- under Cognac the dialog is larger by its frame and its text keeps the same width
NS.Demo.setTheme(6)
MOCK.check("theme change drops the dialog", parts.dialog == nil and not dialog:IsShown())
parts.openDialog.scripts.OnClick(parts.openDialog)
MOCK.check("cognac dialog", parts.dialog.width == 360 + 2 * (S.metrics.inset - S.PAD) and parts.dialog.sub.width == 360 - 2 * S.PAD
	and parts.dialog.sub.point[4] == S.metrics.inset)

-- Back to a Material theme after it.
NS.Demo.setTheme(1)
MOCK.check("material again", S.Skin() == "material" and NS.Demo.window().width == 680)

S.UseSkin("material")
