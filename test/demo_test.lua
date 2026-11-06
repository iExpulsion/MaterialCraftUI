-- The demo addon: it loads on the kit, opens with /mcui, builds every page, and rebuilds itself for each theme.
local S = NS.Style

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

S.SetTheme()
