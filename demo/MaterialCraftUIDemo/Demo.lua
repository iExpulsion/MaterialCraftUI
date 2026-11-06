local ADDON, NS = ...
local S = NS.Style

local WINDOW = "MaterialCraftUIDemoWindow"
local W, H, TITLE_H, NAV_W, ROW_H = 680, 460, 44, 150, 22
local CONTENT_W = W - NAV_W - 2

local THEMES = {
	{ value = 1, text = "Baseline", tooltip = "Material 3's baseline dark scheme, the kit's default." },
	{ value = 2, text = "Blue", tooltip = "S.SetTheme({ primary = \"7cacf8\" })", roles = { primary = "7cacf8" } },
	{ value = 3, text = "Amber", tooltip = "S.SetTheme({ primary = \"ffc400\" })", roles = { primary = "ffc400" } },
	{ value = 4, text = "Green", tooltip = "S.SetTheme({ primary = \"7dd99c\" })", roles = { primary = "7dd99c" } },
	{ value = 5, text = "Rose", tooltip = "S.SetTheme({ primary = \"ffb1c8\" })", roles = { primary = "ffb1c8" } },
}

local NAV = {
	{ "Controls", { "Buttons", "Forms" } },
	{ "Theme", { "Colors" } },
	{ "Data", { "Items" } },
}

local COLOR_ROLES = { "window", "sidebar", "panel", "well", "border", "outline", "hover", "selected", "accent",
	"accentHover", "onAccent", "text", "heading", "muted", "disabled", "good", "warn", "bad", "badDim" }

local QUALITY_NAMES = { [0] = "Poor", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Artifact", "Heirloom" }

local ITEMS = {
	{ "Frayed Linen Gloves", 0, "Hands", 4 },
	{ "Tarnished Copper Ring", 0, "Finger", 6 },
	{ "Cracked Stone Idol", 0, "Relic", 8 },
	{ "Traveler's Worn Satchel", 1, "Bag", 10 },
	{ "Weathered Fishing Pole", 1, "Two-Hand", 10 },
	{ "Sturdy Leather Boots", 1, "Feet", 12 },
	{ "Plain Wool Cloak", 1, "Back", 14 },
	{ "Ironbark Buckler", 2, "Off Hand", 21 },
	{ "Silvered Longsword", 2, "One-Hand", 24 },
	{ "Harvest Moon Pendant", 2, "Neck", 28 },
	{ "Polished Ashwood Bow", 2, "Ranged", 30 },
	{ "Stormcaller's Wand", 3, "Ranged", 34 },
	{ "Mantle of Quiet Embers", 3, "Shoulder", 40 },
	{ "Ridgewatch Greaves", 3, "Legs", 45 },
	{ "Moonsilver Circlet", 3, "Head", 48 },
	{ "Vambraces of the Tidecaller", 3, "Wrist", 52 },
	{ "Gilded Signet of Valor", 3, "Finger", 58 },
	{ "Glacierheart Chestguard", 4, "Chest", 60 },
	{ "Band of Waning Light", 4, "Finger", 64 },
	{ "Thornroot Staff", 4, "Two-Hand", 70 },
	{ "Helm of the Frozen Vigil", 4, "Head", 72 },
	{ "Duskwoven Sash", 4, "Waist", 75 },
	{ "Frostbound Gauntlets", 4, "Hands", 76 },
	{ "Starfall Spaulders", 4, "Shoulder", 78 },
	{ "Choker of Distant Echoes", 4, "Neck", 80 },
	{ "Emberforged Warblade", 5, "One-Hand", 80 },
	{ "Crown of the Last Dawn", 5, "Head", 80 },
	{ "Reliquary of Ancient Light", 6, "Two-Hand", 80 },
	{ "Veteran's Pauldrons", 7, "Shoulder", 80 },
}

local state = { theme = 1, page = "Buttons" }
local window
local generation = 0
local PAGE = {}

local function heading(page, title, blurb)
	local t = S.Text(page, "large", S.colors.heading)
	t:SetPoint("TOPLEFT", S.PAD, -S.PAD)
	t:SetText(title)
	local b = S.Text(page, "small", S.colors.muted)
	b:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -6)
	b:SetWidth(CONTENT_W - 2 * S.PAD)
	b:SetText(blurb)
	return b
end

local function label(parent, text, anchor, y)
	local l = S.Text(parent, "small", S.colors.muted)
	l:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, y or -16)
	l:SetText(text)
	return l
end

local function row(anchor, controls, gap)
	controls[1]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
	for i = 2, #controls do controls[i]:SetPoint("LEFT", controls[i - 1], "RIGHT", gap or S.GAP, 0) end
end

local function checkRow(parent, text, on, enabled)
	local usable = enabled ~= false
	local c = S.Check(parent, 14, function(box) box:SetChecked(not box.on) end)
	c:SetChecked(on)
	c:SetEnabled(usable)
	c.text = S.Text(parent, "small", usable and S.colors.text or S.colors.disabled)
	c.text:SetPoint("LEFT", c, "RIGHT", 8, 0)
	c.text:SetText(text)
	return c
end

local function hexOf(c)
	local hex = ("#%02x%02x%02x"):format(c[1] * 255 + 0.5, c[2] * 255 + 0.5, c[3] * 255 + 0.5)
	return (c[4] or 1) < 1 and ("%s  %d%%"):format(hex, c[4] * 100 + 0.5) or hex
end

function PAGE.Buttons(page)
	local top = heading(page, "Buttons", "Five kinds at one height, so rows line up. Hover the top row for tooltips; "
		.. "every kind shares one disabled look.")

	local kinds = {
		{ "primary", "Primary", "Filled: the one main action in a view." },
		{ "secondary", "Secondary", "Tonal: everyday actions, and the default kind." },
		{ "ghost", "Ghost", "Text only, for low-emphasis actions." },
		{ "danger", "Danger", "For actions that remove or reset something." },
		{ "selected", "Selected", "The chosen side of a segmented button." },
	}
	local enabled, disabled = {}, {}
	for i, k in ipairs(kinds) do
		enabled[i] = S.Button(page, k[2], k[1], 86, nil, k[3])
		disabled[i] = S.Button(page, k[2], k[1], 86)
		disabled[i]:Disable()
	end
	row(label(page, "Kinds", top), enabled)
	row(label(page, "Disabled", enabled[1]), disabled)

	local periods = {}
	local function pick(chosen)
		for _, b in ipairs(periods) do b:SetKind(b == chosen and "selected" or "secondary") end
	end
	for i, text in ipairs({ "Day", "Week", "Month", "Year" }) do
		periods[i] = S.Button(page, text, "secondary", 64, pick)
	end
	row(label(page, "Segmented", disabled[1]), periods, -1)
	pick(periods[2])

	local optionsButton = S.AddArrow(S.Button(page, "View Options", "secondary", 130))
	local popup = CreateFrame("Frame", nil, optionsButton)
	popup:SetFrameStrata("FULLSCREEN_DIALOG")
	popup:SetPoint("TOPLEFT", optionsButton, "BOTTOMLEFT", 0, -2)
	popup:SetSize(180, 2 * S.PAD + 3 * 14 + 2 * S.GAP)
	S.Panel(popup, S.colors.panel, S.colors.border)
	popup:EnableMouse(true)
	popup:Hide()
	popup.owner = optionsButton
	S.TrackPopup(popup)
	local previous
	for i, text in ipairs({ "Compact Rows", "Show Icons", "Group by Slot" }) do
		local c = checkRow(popup, text, i ~= 2)
		if previous then
			c:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -S.GAP)
		else
			c:SetPoint("TOPLEFT", S.PAD, -S.PAD)
		end
		previous = c
	end
	optionsButton:SetScript("OnClick", function()
		local open = popup:IsShown()
		S.CloseMenus()
		if not open then popup:Show() end
	end)
	optionsButton:HookScript("OnHide", function() popup:Hide() end)

	local labels = { "Grow", "Grows to Fit", "Grows to Fit Its Label" }
	local step = 1
	local grow = S.Button(page, labels[1], "secondary", 70, function(self)
		step = step % #labels + 1
		self:SetLabel(labels[step])
	end, "SetLabel widens the button to fit its text.")

	local clicks = 0
	local count = S.Text(page, "small", S.colors.muted)
	local counter = S.Button(page, "Click Me", "primary", 90, function()
		clicks = clicks + 1
		count:SetText("Clicked " .. S.Count(clicks, "Time"))
	end)
	count:SetText("Not Clicked Yet")

	row(label(page, "Popups and Labels", periods[1]), { optionsButton, grow })
	row(label(page, "Status Text", optionsButton), { counter, count }, 12)
end

function PAGE.Forms(page)
	local top = heading(page, "Forms", "Inputs never take focus on their own. Click away or press Escape to let go "
		.. "of the keyboard, and opening one dropdown closes the other.")

	local status = S.Text(page, "small", S.colors.muted)
	status:SetPoint("BOTTOMLEFT", S.PAD, S.PAD + 6)
	local function setStatus(text, color)
		status:SetText(text)
		status:SetTextColor(unpack(color))
	end
	local function changed(_, userInput)
		if userInput then setStatus("Unsaved Changes", S.colors.warn) end
	end

	local nameLabel = label(page, "Character Name", top)
	local name = S.Input(page, nil, 200, "Who Is This For?", 24)
	name:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6)
	name:HookScript("OnTextChanged", changed)

	local roles = {
		{ value = 1, text = "Tank", tooltip = "Takes the hits." },
		{ value = 2, text = "Healer", tooltip = "Keeps the group standing." },
		{ value = 3, text = "Damage", tooltip = "Brings the enemies down." },
	}
	local role
	role = S.Dropdown(page, 130, function(v)
		role:SetText(roles[v].text)
		setStatus("Unsaved Changes", S.colors.warn)
	end)
	role:SetOptions(roles)
	role:SetText(roles[3].text)
	role:SetPoint("LEFT", name, "RIGHT", S.GAP, 0)
	local roleLabel = S.Text(page, "small", S.colors.muted)
	roleLabel:SetPoint("BOTTOMLEFT", role, "TOPLEFT", 0, 6)
	roleLabel:SetText("Role")

	local modes = {
		{ value = 1, text = "Normal" },
		{ value = 2, text = "Heroic", tooltip = "Harder, with better rewards." },
	}
	local mode
	mode = S.Dropdown(page, 110, function(v)
		mode:SetText(modes[v].text)
		setStatus("Unsaved Changes", S.colors.warn)
	end)
	mode:SetOptions(modes)
	mode:SetText(modes[1].text)
	mode:SetPoint("LEFT", role, "RIGHT", S.GAP, 0)
	local modeLabel = S.Text(page, "small", S.colors.muted)
	modeLabel:SetPoint("BOTTOMLEFT", mode, "TOPLEFT", 0, 6)
	modeLabel:SetText("Difficulty")

	local notesLabel = label(page, "Notes", name)
	local notes = S.Input(page, nil, 456, "Anything worth remembering, across a few lines.", 200, 3)
	notes:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -6)
	notes:HookScript("OnTextChanged", changed)

	local checksLabel = label(page, "Options", notes)
	local checks = {
		checkRow(page, "Show on Login", true),
		checkRow(page, "Lock Window", false),
		checkRow(page, "Sync Across Characters", true, false),
		checkRow(page, "Beta Features", false, false),
	}
	checks[1]:SetPoint("TOPLEFT", checksLabel, "BOTTOMLEFT", 0, -10)
	checks[2]:SetPoint("TOPLEFT", checks[1], "BOTTOMLEFT", 0, -S.GAP)
	checks[3]:SetPoint("LEFT", checks[1], "LEFT", 220, 0)
	checks[4]:SetPoint("LEFT", checks[2], "LEFT", 220, 0)

	local save = S.Button(page, "Save", "primary", 90, function()
		if (name:GetText() or "") == "" then
			setStatus("Enter a Name First", S.colors.bad)
		else
			setStatus("Saved", S.colors.good)
		end
	end)
	save:SetPoint("BOTTOMRIGHT", -S.PAD, S.PAD)
	local clear = S.Button(page, "Clear", "danger", 80, function()
		S.Dismiss()
		name:SetText("")
		notes:SetText("")
		checks[1]:SetChecked(true)
		checks[2]:SetChecked(false)
		setStatus("Cleared", S.colors.muted)
	end, "Empties the inputs and resets the options.")
	clear:SetPoint("RIGHT", save, "LEFT", -S.GAP, 0)

	setStatus("No Changes", S.colors.muted)
end

function PAGE.Colors(page)
	local top = heading(page, "Color Roles", "Every color in S.colors, drawn on a well so the translucent layers show. "
		.. "Pick another theme at the top to see them change.")

	local colW, rowH = math.floor((CONTENT_W - 2 * S.PAD) / 3), 32
	for i, role in ipairs(COLOR_ROLES) do
		local col, line = (i - 1) % 3, math.floor((i - 1) / 3)
		local swatch = CreateFrame("Frame", nil, page)
		swatch:SetSize(24, 24)
		swatch:SetPoint("TOPLEFT", top, "BOTTOMLEFT", col * colW, -14 - line * rowH)
		S.Panel(swatch, S.colors.well, S.colors.border)
		local fill = S.Solid(swatch, "ARTWORK", S.colors[role])
		fill:SetPoint("TOPLEFT", 1, -1)
		fill:SetPoint("BOTTOMRIGHT", -1, 1)
		local roleName = S.Text(page, "small")
		roleName:SetPoint("TOPLEFT", swatch, "TOPRIGHT", 8, 0)
		roleName:SetText(role)
		local hex = S.Text(page, "small", S.colors.muted)
		hex:SetPoint("BOTTOMLEFT", swatch, "BOTTOMRIGHT", 8, 0)
		hex:SetText(hexOf(S.colors[role]))
	end

	local qualityLabel = label(page, "Item Qualities", top, -14 - math.ceil(#COLOR_ROLES / 3) * rowH - 8)
	local previous
	for q = 0, 7 do
		local t = S.Text(page, "small", S.QualityColor(q))
		t:SetText(_G["ITEM_QUALITY" .. q .. "_DESC"] or QUALITY_NAMES[q])
		if previous then
			t:SetPoint("LEFT", previous, "RIGHT", 14, 0)
		else
			t:SetPoint("TOPLEFT", qualityLabel, "BOTTOMLEFT", 0, -8)
		end
		previous = t
	end
end

function PAGE.Items(page)
	local top = heading(page, "Items", "A list in a well with the kit's thin scroll bar. Rows show hover and "
		.. "selection, and the search box filters by name.")

	local search = S.Input(page, nil, 220, "Search Items", 40)
	search:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -14)
	local count = S.Text(page, "small", S.colors.muted)
	count:SetPoint("LEFT", search, "RIGHT", 12, 0)

	local well = CreateFrame("Frame", nil, page)
	well:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -S.GAP)
	well:SetPoint("BOTTOMRIGHT", -S.PAD, S.PAD)
	S.Panel(well, S.colors.well, S.colors.border)

	local header = CreateFrame("Frame", nil, well)
	header:SetPoint("TOPLEFT", 1, -1)
	header:SetPoint("TOPRIGHT", -1, -1)
	header:SetHeight(ROW_H)
	S.Rule(header, "BOTTOM")
	local columns = { { "Name", 8 }, { "Slot", 250 } }
	for _, c in ipairs(columns) do
		local t = S.Text(header, "small", S.colors.outline)
		t:SetPoint("LEFT", c[2], 0)
		t:SetText(c[1])
	end
	local levelHeader = S.Text(header, "small", S.colors.outline)
	levelHeader:SetPoint("RIGHT", -20, 0)
	levelHeader:SetText("Level")

	local scrollName = ADDON .. "ItemsScroll" .. generation
	local scroll = CreateFrame("ScrollFrame", scrollName, well, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
	scroll:SetPoint("BOTTOMRIGHT", -12, 1)
	S.ScrollBar(scroll, scrollName)
	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(CONTENT_W - 2 * S.PAD - 14, 1)
	scroll:SetScrollChild(child)

	local rows, selected = {}, nil
	for i, item in ipairs(ITEMS) do
		local r = CreateFrame("Button", nil, child)
		r:SetHeight(ROW_H)
		local hover = S.Solid(r, "HIGHLIGHT", S.colors.hover)
		hover:SetAllPoints()
		r.selection = S.Solid(r, "BACKGROUND", S.colors.selected)
		r.selection:SetAllPoints()
		r.selection:Hide()
		local itemName = S.Text(r, "small", S.QualityColor(item[2]))
		itemName:SetPoint("LEFT", 8, 0)
		itemName:SetText(item[1])
		local slot = S.Text(r, "small", S.colors.muted)
		slot:SetPoint("LEFT", 250, 0)
		slot:SetText(item[3])
		local level = S.Text(r, "small", S.colors.muted)
		level:SetPoint("RIGHT", -8, 0)
		level:SetJustifyH("RIGHT")
		level:SetText(item[4])
		r.item = item
		r:SetScript("OnClick", function(self)
			if selected then selected.selection:Hide() end
			selected = self
			self.selection:Show()
		end)
		r:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(S.Hex(S.QualityColor(item[2]), item[1]))
			GameTooltip:AddLine(item[3] .. ", level " .. item[4], 1, 1, 1)
			GameTooltip:Show()
		end)
		r:SetScript("OnLeave", function() GameTooltip:Hide() end)
		rows[i] = r
	end

	local function refresh()
		local query = (search:GetText() or ""):lower()
		local shown = 0
		for _, r in ipairs(rows) do
			if query == "" or r.item[1]:lower():find(query, 1, true) then
				r:ClearAllPoints()
				r:SetPoint("TOPLEFT", 0, -shown * ROW_H)
				r:SetPoint("TOPRIGHT", 0, -shown * ROW_H)
				r:Show()
				shown = shown + 1
			else
				r:Hide()
			end
		end
		child:SetHeight(math.max(shown * ROW_H, 1))
		count:SetText(S.Count(shown, "Item"))
	end
	search:HookScript("OnTextChanged", refresh)
	refresh()
end

local setTheme

local function build()
	generation = generation + 1
	S.RefreshFonts()
	local C = S.colors

	local f = CreateFrame("Frame", WINDOW, UIParent)
	f:SetSize(W, H)
	f:SetFrameStrata("HIGH")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f:SetPoint(unpack(state.point or { "CENTER" }))
	S.Panel(f, C.window, C.border)
	f:SetScript("OnHide", S.Dismiss)

	local bar = CreateFrame("Frame", nil, f)
	bar:SetPoint("TOPLEFT", 1, -1)
	bar:SetPoint("TOPRIGHT", -1, -1)
	bar:SetHeight(TITLE_H)
	bar:EnableMouse(true)
	bar:RegisterForDrag("LeftButton")
	bar:SetScript("OnDragStart", function() f:StartMoving() end)
	bar:SetScript("OnDragStop", function()
		f:StopMovingOrSizing()
		local point, _, relativePoint, x, y = f:GetPoint()
		state.point = { point, UIParent, relativePoint, x, y }
	end)
	S.Rule(bar, "BOTTOM")

	local title = S.Text(bar, "large", C.heading)
	title:SetPoint("LEFT", S.PAD, 0)
	title:SetText("MaterialCraftUI")
	local subtitle = S.Text(bar, "small", C.muted)
	subtitle:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 10, 1)
	subtitle:SetText("Style Kit Demo")

	local close = S.Button(bar, "Close", "ghost", 60, function() f:Hide() end)
	close:SetPoint("RIGHT", -S.PAD + 2, 0)
	local theme = S.Dropdown(bar, 120, function(v) setTheme(v) end)
	theme:SetOptions(THEMES)
	theme:SetText(THEMES[state.theme].text)
	theme:SetPoint("RIGHT", close, "LEFT", -S.GAP, 0)
	local themeLabel = S.Text(bar, "small", C.muted)
	themeLabel:SetPoint("RIGHT", theme, "LEFT", -S.GAP, 0)
	themeLabel:SetText("Theme")

	local nav = CreateFrame("Frame", nil, f)
	nav:SetPoint("TOPLEFT", bar, "BOTTOMLEFT")
	nav:SetPoint("BOTTOMLEFT", 1, 1)
	nav:SetWidth(NAV_W)
	S.Panel(nav, C.sidebar)
	local edge = S.Solid(nav, "BORDER", C.border)
	edge:SetWidth(1)
	edge:SetPoint("TOPRIGHT")
	edge:SetPoint("BOTTOMRIGHT")
	local hint = S.Text(nav, "small", C.outline)
	hint:SetPoint("BOTTOMLEFT", S.PAD, S.PAD)
	hint:SetText("/mcui Toggles This Window")

	local content = CreateFrame("Frame", nil, f)
	content:SetPoint("TOPLEFT", nav, "TOPRIGHT")
	content:SetPoint("BOTTOMRIGHT", -1, 1)

	local pages, entries = {}, {}
	local function show(name)
		S.Dismiss()
		state.page = name
		for key, p in pairs(pages) do
			if key == name then p:Show() else p:Hide() end
		end
		for _, e in ipairs(entries) do
			local on = e.page == name
			if on then e.selection:Show() else e.selection:Hide() end
			e.text:SetTextColor(unpack(on and C.accent or C.text))
		end
	end

	local y = -S.PAD
	for _, section in ipairs(NAV) do
		S.SectionHeading(nav, section[1], S.PAD, y)
		y = y - 18
		for _, name in ipairs(section[2]) do
			local e = CreateFrame("Button", nil, nav)
			e:SetHeight(S.CONTROL_H)
			e:SetPoint("TOPLEFT", 4, y)
			e:SetPoint("TOPRIGHT", -5, y)
			local hover = S.Solid(e, "HIGHLIGHT", C.hover)
			hover:SetAllPoints()
			e.selection = S.Solid(e, "BACKGROUND", C.selected)
			e.selection:SetAllPoints()
			e.text = S.Text(e, "normal")
			e.text:SetPoint("LEFT", S.PAD - 4, 0)
			e.text:SetText(name)
			e.page = name
			e:SetScript("OnClick", function() show(name) end)
			entries[#entries + 1] = e

			local p = CreateFrame("Frame", nil, content)
			p:SetAllPoints()
			PAGE[name](p)
			pages[name] = p
			y = y - S.CONTROL_H - 2
		end
		y = y - 12
	end

	show(state.page)
	return f
end

setTheme = function(index)
	state.theme = index
	window:Hide()
	S.SetTheme(THEMES[index].roles)
	window = build()
	window:Show()
end

local function toggle()
	if window and window:IsShown() then
		window:Hide()
	else
		window = window or build()
		window:Show()
	end
end

tinsert(UISpecialFrames, WINDOW)
SLASH_MATERIALCRAFTUIDEMO1 = "/mcui"
SlashCmdList.MATERIALCRAFTUIDEMO = toggle
NS.Demo = { state = state, toggle = toggle, setTheme = setTheme, window = function() return window end }
DEFAULT_CHAT_FRAME:AddMessage(S.Hex(S.colors.accent, "MaterialCraftUI Demo") .. " loaded. Type /mcui to open it.")
