local _, NS = ...
local S = NS.Style

local WINDOW = "MaterialCraftUIDemoWindow"
local W, H, TITLE_H, NAV_W, ROW_H = 680, 460, 44, 150, 22
local CONTENT_W = W - NAV_W - 2
-- the Items page's table, from below its search box to the page's bottom padding
local ITEMS_H = 300

local THEMES = {
	{ value = 1, text = "Baseline", tooltip = "Material 3's baseline dark scheme, the kit's default." },
	{ value = 2, text = "Blue", tooltip = "S.SetTheme({ primary = \"7cacf8\" })", roles = { primary = "7cacf8" } },
	{ value = 3, text = "Amber", tooltip = "S.SetTheme({ primary = \"ffc400\" })", roles = { primary = "ffc400" } },
	{ value = 4, text = "Green", tooltip = "S.SetTheme({ primary = \"7dd99c\" })", roles = { primary = "7dd99c" } },
	{ value = 5, text = "Rose", tooltip = "S.SetTheme({ primary = \"ffb1c8\" })", roles = { primary = "ffb1c8" } },
	{ value = 6, text = "Cognac", skin = "cognac",
		tooltip = "S.UseSkin(\"cognac\"): the painted skin. Art by Jeff, from AttuneNext." },
	{ value = 7, text = "Classic", skin = "classic",
		tooltip = "S.UseSkin(\"classic\"): the default UI's own frames, buttons and fonts." },
	{ value = 8, text = "Material Glass", skin = "materialglass", roles = { primary = "ffc400" },
		tooltip = "S.UseSkin(\"materialglass\", { primary = \"ffc400\" }): Material on see-through glass." },
}

local NAV = {
	{ "Controls", { "Buttons", "Forms", "Layout", "Text" } },
	{ "Theme", { "Colors" } },
	{ "Data", { "Items", "Groups" } },
}

-- each page's icon in the navigation (S.NavEntry's icon)
local NAV_ICONS = {
	Buttons = "Interface\\Icons\\INV_Misc_Gear_01",
	Forms = "Interface\\Icons\\INV_Misc_Note_01",
	Layout = "Interface\\Icons\\INV_Misc_Map_01",
	Text = "Interface\\Icons\\INV_Misc_Book_09",
	Colors = "Interface\\Icons\\INV_Misc_Gem_Variety_01",
	Items = "Interface\\Icons\\INV_Misc_Bag_08",
	Groups = "Interface\\Icons\\INV_Misc_GroupLooking",
}

local COLOR_ROLES = { "window", "sidebar", "panel", "well", "border", "outline", "hover", "selected", "accent",
	"accentHover", "onAccent", "text", "heading", "muted", "disabled", "good", "warn", "bad", "badDim", "red", "blue",
	"green", "yellow" }

-- the Groups page's groups, each with a hue and the item slots in it
local GROUPS = {
	{ name = "Weapons", hue = "red", slots = { ["One-Hand"] = true, ["Two-Hand"] = true, Ranged = true, ["Off Hand"] = true } },
	{ name = "Armor", hue = "blue", slots = { Head = true, Shoulder = true, Chest = true, Wrist = true, Hands = true,
		Waist = true, Legs = true, Feet = true, Back = true } },
	{ name = "Jewelry", hue = "yellow", slots = { Neck = true, Finger = true } },
	{ name = "Other", hue = "green", slots = { Bag = true, Relic = true } },
}

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

local SIZES = {
	{ value = 1, text = "90%", scale = 0.9 },
	{ value = 2, text = "100%", scale = 1 },
	{ value = 3, text = "115%", scale = 1.15 },
	{ value = 4, text = "130%", scale = 1.3 },
}

local TABS = {
	{ "Overview", "S.Tab buttons, sized to their labels, over the bar's S.Rule of kind \"tabs\"." },
	{ "Details", "Each skin marks the selected tab its own way: an underline, a chip or the stock tab art." },
	{ "History", "You place the tabs and swap what's under them; the kit only draws them." },
}
local TAB_H = 28

local SLOTS = { "Head", "Neck", "Shoulder", "Back", "Hands", "Feet", "Finger", "One-Hand", "Two-Hand", "Off Hand",
	"Ranged", "Relic", "Bag" }

-- the Text page's dialog, from one line to several
local LENGTHS = {
	{ "Saved for every character.", "Pick one to load it." },
	{ "Saved for every character. Load one into this build, or save this tab as a new one.",
		"Templates hold the whole tab for every class, so a two-class build saves both at once." },
	{ "Saved for every character, whatever their class. Load one into this build, or save this tab as a new one to "
		.. "try it out on another build later.", "Templates hold the whole tab for every class, like an export, so a "
		.. "two-class build saves both at once; loading one replaces only its classes' part, and the other class stays "
		.. "as it was. A bigger font or a skin with a thicker frame wraps it sooner, and the dialog grows to fit." },
}
local DIALOG_W = 360

local state = { theme = 1, page = "Buttons", size = 2, priorities = { "Interrupt", "Defensive Cooldown", "Burst",
	"Filler" }, hidden = {}, slots = {}, length = 2 }
local window
local PAGE = {}
-- pieces the pages built, for the tests
local parts = {}

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
	local c = S.Check(parent, nil, function(box) box:SetChecked(not box.on) end)
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
	popup:SetSize(180, 2 * S.PAD + 3 * S.CHECK_H + 2 * S.GAP)
	S.Frame(popup, "menu")
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

	local slidersLabel = label(page, "Sliders", checks[2])
	local scale = S.Slider(page, 160, 50, 200, 5, function() setStatus("Unsaved Changes", S.colors.warn) end,
		function(v) return v .. "%" end)
	scale:SetValue(100)
	scale.tooltipText = "Click the track or drag the handle; it moves in steps of 5."
	scale:SetPoint("TOPLEFT", slidersLabel, "BOTTOMLEFT", 0, -6)
	local locked = S.Slider(page, 160, 0, 1, 0.05, nil, function(v) return ("%d%%"):format(v * 100 + 0.5) end)
	locked:SetValue(0.6)
	locked:SetEnabled(false)
	locked:SetPoint("LEFT", scale, "LEFT", 220, 0)

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

function PAGE.Layout(page)
	local top = heading(page, "Layout", "Tabs, a list you drag into order, pickers, and two panes split by a divider. "
		.. "The Size dropdown at the top scales the whole window.")
	local fullW = CONTENT_W - 2 * S.PAD

	local tabsLabel = label(page, "Tabs", top)
	local bar = CreateFrame("Frame", nil, page)
	bar:SetPoint("TOPLEFT", tabsLabel, "BOTTOMLEFT", 0, -6)
	bar:SetSize(fullW, TAB_H)
	S.Rule(bar, "BOTTOM", "tabs")
	local about = S.Text(page, "small")
	about:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -10)
	about:SetWidth(fullW)
	local tabs = {}
	local function pickTab(index)
		for i, t in ipairs(tabs) do t:SetSelected(i == index) end
		about:SetText(TABS[index][2])
	end
	local x = 0
	for i, t in ipairs(TABS) do
		local b = CreateFrame("Button", nil, bar)
		b:SetHeight(TAB_H)
		S.Tab(b, t[1])
		b:SetWidth(math.ceil(b.label:GetStringWidth()) + 2 * S.metrics.tabPad)
		b:SetPoint("BOTTOMLEFT", x, 0)
		x = x + b:GetWidth()
		b:SetScript("OnClick", function() pickTab(i) end)
		tabs[i] = b
	end
	pickTab(1)
	parts.tabs = tabs

	-- two panes, a vertical divider centered in the gap between them
	local split, splitW = S.VerticalDivider(page)
	local gap = 2 * S.GAP + splitW
	local paneW = math.floor((fullW - gap) / 2)

	local orderLabel = label(page, "Drag to Reorder", about, -18)
	local inset = 1 + S.metrics.wellInset
	local list = CreateFrame("Frame", nil, page)
	list:SetPoint("TOPLEFT", orderLabel, "BOTTOMLEFT", 0, -6)
	list:SetSize(paneW, #state.priorities * ROW_H + 2 * inset)
	S.Well(list)
	local rows = {}
	local function relabel()
		for i, r in ipairs(rows) do r.text:SetText(i .. ".  " .. state.priorities[i]) end
	end
	for i = 1, #state.priorities do
		local r = CreateFrame("Button", nil, list)
		r:SetHeight(ROW_H)
		r:SetPoint("TOPLEFT", inset, -inset - (i - 1) * ROW_H)
		r:SetPoint("TOPRIGHT", -inset, -inset - (i - 1) * ROW_H)
		S.Highlight(r)
		local grip = S.Grip(r)
		grip:SetPoint("LEFT", 8, 0)
		r.text = S.Text(r, "small")
		r.text:SetPoint("LEFT", grip, "RIGHT", 10, 0)
		r.moveIndex = i
		rows[i] = r
	end
	local reorder = S.Reorder.New({ rows = rows, lineParent = list, onMove = function(from, to)
		local moved = table.remove(state.priorities, from)
		table.insert(state.priorities, to, moved)
		relabel()
	end })
	for _, r in ipairs(rows) do reorder:Attach(r, function(dragged) return state.priorities[dragged.moveIndex] end) end
	relabel()
	parts.priorityRows, parts.reorder = rows, reorder

	split:SetPoint("TOPLEFT", list, "TOPRIGHT", S.GAP, 0)
	split:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", S.GAP, 0)

	local pickLabel = S.Text(page, "small", S.colors.muted)
	pickLabel:SetPoint("LEFT", orderLabel, "LEFT", paneW + gap, 0)
	pickLabel:SetText("Pickers")
	local choices = {}
	for i, item in ipairs(ITEMS) do
		choices[i] = { value = i, text = item[1], tooltip = item[3] .. ", level " .. item[4] }
	end
	local favorite
	local itemPicker
	local itemSpec = {
		items = choices,
		placeholder = "Search Items",
		isSelected = function(v) return v == favorite end,
		onPick = function(v)
			favorite = v
			itemPicker:SetText(ITEMS[v][1])
		end,
	}
	itemPicker = S.PickerButton(page, paneW, function() return itemSpec end)
	itemPicker:SetText("Pick an Item")
	itemPicker:SetPoint("TOPLEFT", pickLabel, "BOTTOMLEFT", 0, -6)

	local slotChoices = {}
	for i, slot in ipairs(SLOTS) do slotChoices[i] = { value = slot, text = slot } end
	local slotPicker
	local function slotText()
		local n = 0
		for _ in pairs(state.slots) do n = n + 1 end
		slotPicker:SetText(n == 0 and "Any Slot" or S.Count(n, "Slot"))
	end
	local slotSpec = {
		items = slotChoices,
		placeholder = "Search Slots",
		multi = true,
		isSelected = function(v) return state.slots[v] end,
		onPick = function(v)
			state.slots[v] = not state.slots[v] or nil
			slotText()
		end,
	}
	slotPicker = S.PickerButton(page, paneW, function() return slotSpec end)
	slotPicker:SetPoint("TOPLEFT", itemPicker, "BOTTOMLEFT", 0, -S.GAP)
	slotText()
	local pickHint = S.Text(page, "small", S.colors.muted)
	pickHint:SetPoint("TOPLEFT", slotPicker, "BOTTOMLEFT", 0, -S.GAP)
	pickHint:SetWidth(paneW)
	pickHint:SetText("The first picks one item; the second toggles several slots and stays open.")
	parts.itemPicker, parts.itemSpec, parts.slotSpec = itemPicker, itemSpec, slotSpec
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

-- A popup laid out with S.Stack: title, a wrapped subtitle and body, then its buttons. Every row sits under the one
-- before, so longer text pushes the buttons down and the dialog grows to fit, inside whatever frame the skin draws.
local function textDialog()
	local C = S.colors
	-- the theme's dialog padding; the dialog grows by the difference from the kit's, so its contents keep their width
	local grow = 2 * (S.metrics.inset - S.PAD)
	local d = CreateFrame("Frame", "MaterialCraftUIDemoTextDialog", UIParent)
	d:SetWidth(DIALOG_W + grow)
	d:SetPoint("CENTER")
	d:SetFrameStrata("DIALOG")
	d:EnableMouse(true)
	S.PixelScale(d)
	S.Frame(d, "popup")
	tinsert(UISpecialFrames, "MaterialCraftUIDemoTextDialog")

	-- sized after each pass, the second once the client has wrapped the new text
	local stack = S.Stack(d, { width = DIALOG_W - 2 * S.PAD,
		onLayout = function(bottom) d:SetHeight(bottom + S.metrics.inset) end })
	d.title = stack:Add(S.Text(d, "large"))
	d.title:SetHeight(16)
	d.title:SetText("Templates")
	d.sub = stack:Add(S.Wrapped(d, "small", C.muted), { gap = 4 })
	d.body = stack:Add(S.Wrapped(d, "normal"), { gap = S.PAD })
	local buttons = CreateFrame("Frame", nil, d)
	buttons:SetHeight(S.CONTROL_H)
	buttons:Show()
	stack:Add(buttons, { gap = S.PAD, fill = true })
	local function relayout()
		local texts = LENGTHS[state.length]
		d.sub:SetText(texts[1])
		d.body:SetText(texts[2])
		stack:Layout()
	end
	local shorter = S.Button(buttons, "Shorter", "secondary", 80, function()
		state.length = math.max(1, state.length - 1)
		relayout()
	end, "Less text: the dialog shrinks.")
	shorter:SetPoint("LEFT")
	local longer = S.Button(buttons, "Longer", "secondary", 80, function()
		state.length = math.min(#LENGTHS, state.length + 1)
		relayout()
	end, "More text: it wraps, and the buttons move down.")
	longer:SetPoint("LEFT", shorter, "RIGHT", S.GAP, 0)
	local close = S.Button(buttons, "Close", "primary", 80, function() d:Hide() end)
	close:SetPoint("RIGHT")
	d.relayout, d.stack = relayout, stack
	relayout()
	return d
end

function PAGE.Text(page)
	local top = heading(page, "Text", "S.Wrapped is text that wraps to its width and measures its lines, and S.Stack "
		.. "places rows top to bottom, each under the one before. Together a dialog fits its text in any skin or font.")
	local open = S.Button(page, "Open Dialog", "primary", 110, function()
		parts.dialog = parts.dialog or textDialog()
		parts.dialog.relayout()
		parts.dialog:Show()
		parts.dialog:Raise()
	end, "A dialog laid out with S.Stack. Its Longer and Shorter buttons change how much text it holds.")
	open:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -14)
	local hint = S.Wrapped(page, "small", S.colors.muted)
	hint:SetPoint("TOPLEFT", open, "BOTTOMLEFT", 0, -S.GAP)
	hint:SetWidth(CONTENT_W - 2 * S.PAD)
	hint:SetText("Try it under each theme and at each window size: Cognac's thicker frame and a bigger font both wrap "
		.. "the text sooner, and nothing should spill past the dialog's edge or overlap its buttons.")
	parts.openDialog = open
end

function PAGE.Items(page)
	local top = heading(page, "Items", "An S.Table: sortable columns, a thin scroll bar and the mouse wheel. Rows show "
		.. "hover and selection, the search box filters by name, and right-clicking a row opens its menu.")

	local search = S.Input(page, nil, 220, "Search Items", 40)
	search:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -14)
	local count = S.Text(page, "small", S.colors.muted)
	count:SetPoint("LEFT", search, "RIGHT", 12, 0)

	local selected
	local sortKey, sortDesc = "level", false
	local SORT = { name = 1, slot = 3, level = 4 }
	local list, refresh
	local menu = S.ContextMenu()
	local function rowMenu(item)
		local anyHidden = next(state.hidden) ~= nil
		return {
			{ text = "Select", action = function()
				selected = item
				list:Redraw()
			end },
			{ text = "Link to Chat", disabled = true, tooltip = "The demo's items aren't real, so there's nothing to link." },
			{ text = "Show Hidden Items", disabled = not anyHidden, action = function()
				wipe(state.hidden)
				refresh()
			end },
			{ text = "Hide", danger = true, tooltip = "Hides it until you show hidden items again.", action = function()
				state.hidden[item] = true
				refresh()
			end },
		}
	end
	list = S.Table.New(page, nil, CONTENT_W - 2 * S.PAD, ITEMS_H, {
		rowH = ROW_H,
		columns = {
			{ key = "name", label = "Name", width = 220, stretch = true },
			{ key = "slot", label = "Slot", width = 120 },
			{ key = "level", label = "Level", width = 64, defaultDesc = true },
		},
		cell = function(item, key)
			if key == "name" then return item[1], S.QualityColor(item[2]) end
			if key == "slot" then return item[3], S.colors.muted end
			return tostring(item[4]), S.colors.muted
		end,
		tooltip = function(tt, item)
			tt:SetText(S.Hex(S.QualityColor(item[2]), item[1]))
			tt:AddLine(item[3] .. ", level " .. item[4], 1, 1, 1)
		end,
		isSelected = function(item) return item == selected end,
		onClick = function(item, button, r)
			if button == "RightButton" then
				menu:Open(r, rowMenu(item), "RIGHT")
			else
				selected = item
				list:Redraw()
			end
		end,
	})
	list.frame:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -S.GAP)

	refresh = function()
		local query = (search:GetText() or ""):lower()
		local shown = {}
		for _, item in ipairs(ITEMS) do
			if not state.hidden[item] and (query == "" or item[1]:lower():find(query, 1, true)) then
				shown[#shown + 1] = item
			end
		end
		local field = SORT[sortKey]
		table.sort(shown, function(a, b)
			if a[field] == b[field] then return a[1] < b[1] end
			if sortDesc then return a[field] > b[field] end
			return a[field] < b[field]
		end)
		list:SetItems(shown, "Nothing Matches")
		count:SetText(S.Count(#shown, "Item"))
	end
	list.onSort = function(key, desc)
		sortKey, sortDesc = key, desc
		refresh()
	end
	list:SetSort(sortKey, sortDesc)
	search:HookScript("OnTextChanged", refresh)
	refresh()
	parts.list, parts.menu, parts.rowMenu = list, menu, rowMenu
end

function PAGE.Groups(page)
	local top = heading(page, "Groups", "An S.Table of groups. Each header takes a hue from the theme (headerColor), "
		.. "the group you've scrolled into stays on top (stickyHeaders), and clicking a header folds its group away.")
	local collapsed = {}
	local list
	local function refresh()
		local rows = {}
		for _, group in ipairs(GROUPS) do
			rows[#rows + 1] = { header = group.name .. (collapsed[group] and " (Folded)" or ""), group = group }
			if not collapsed[group] then
				for _, item in ipairs(ITEMS) do
					if group.slots[item[3]] then rows[#rows + 1] = item end
				end
			end
		end
		list:SetItems(rows, nil, true)
	end
	list = S.Table.New(page, nil, CONTENT_W - 2 * S.PAD, ITEMS_H + S.CONTROL_H + S.GAP, {
		rowH = ROW_H,
		columns = {
			{ key = "name", label = "Name", width = 220, stretch = true, sortable = false },
			{ key = "slot", label = "Slot", width = 120, sortable = false },
			{ key = "level", label = "Level", width = 64, sortable = false },
		},
		cell = function(item, key)
			if key == "name" then return item[1], S.QualityColor(item[2]) end
			if key == "slot" then return item[3], S.colors.muted end
			return tostring(item[4]), S.colors.muted
		end,
		header = function(item) return item.header end,
		headerColor = function(item) return S.colors[item.group.hue] end,
		headerClicks = true,
		stickyHeaders = true,
		onClick = function(item)
			if item.group then
				collapsed[item.group] = not collapsed[item.group] or nil
				refresh()
			end
		end,
	})
	list.frame:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -14)
	refresh()
	parts.groups = list
end

local setTheme

local function build()
	S.RefreshFonts()
	local C = S.colors
	-- the skin's window border sits around the same content area in every skin
	local inset = S.metrics.edge + 1

	local f = CreateFrame("Frame", WINDOW, UIParent)
	f:SetSize(W + 2 * S.metrics.edge, H + 2 * S.metrics.edge)
	f:SetFrameStrata("HIGH")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	-- whole screen pixels per unit, so every edge and 1px border inside lands on real pixels
	S.PixelScale(f)
	if state.point then f:SetPoint(unpack(state.point)) else S.PlaceWindow(f) end
	S.SnapPosition(f)
	S.Frame(f, "window")
	f:SetScript("OnHide", S.Dismiss)

	local bar = CreateFrame("Frame", nil, f)
	bar:SetPoint("TOPLEFT", inset, -inset)
	bar:SetPoint("TOPRIGHT", -inset, -inset)
	bar:SetHeight(TITLE_H)
	bar:EnableMouse(true)
	bar:RegisterForDrag("LeftButton")
	bar:SetScript("OnDragStart", function() f:StartMoving() end)
	bar:SetScript("OnDragStop", function()
		f:StopMovingOrSizing()
		S.SnapPosition(f)
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
	local size
	size = S.Dropdown(bar, 70, function(v)
		state.size = v
		size:SetText(SIZES[v].text)
		S.SetWindowScale(SIZES[v].scale)
	end)
	size:SetOptions(SIZES)
	size:SetText(SIZES[state.size].text)
	size:SetPoint("RIGHT", themeLabel, "LEFT", -2 * S.GAP, 0)
	local sizeLabel = S.Text(bar, "small", C.muted)
	sizeLabel:SetPoint("RIGHT", size, "LEFT", -S.GAP, 0)
	sizeLabel:SetText("Size")

	local nav = CreateFrame("Frame", nil, f)
	nav:SetPoint("TOPLEFT", bar, "BOTTOMLEFT")
	nav:SetPoint("BOTTOMLEFT", inset, inset)
	nav:SetWidth(NAV_W)
	nav:SetHeight(H - TITLE_H - 2)
	S.Sidebar(nav)
	local hint = S.Text(nav, "small", C.outline)
	local hintInset = S.PAD + S.metrics.navInset
	hint:SetPoint("BOTTOMLEFT", hintInset, hintInset)
	hint:SetWidth(NAV_W - 2 * hintInset)
	hint:SetWordWrap(true)
	hint:SetText("/mcui Toggles This Window")

	local content = CreateFrame("Frame", nil, f)
	content:SetPoint("TOPLEFT", nav, "TOPRIGHT")
	content:SetPoint("BOTTOMRIGHT", -inset, inset)

	local pages, entries = {}, {}
	local function show(name)
		S.Dismiss()
		state.page = name
		for key, p in pairs(pages) do
			if key == name then p:Show() else p:Hide() end
		end
		for _, e in ipairs(entries) do e:SetSelected(e.page == name) end
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
			S.NavEntry(e, name, NAV_ICONS[name])
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
	-- the dialog is drawn by the skin it was made under, so the next one is made under the new skin
	if parts.dialog then parts.dialog:Hide() end
	parts.dialog = nil
	S.UseSkin(THEMES[index].skin or "material", THEMES[index].roles)
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
NS.Demo = { state = state, parts = parts, toggle = toggle, setTheme = setTheme, window = function() return window end }
DEFAULT_CHAT_FRAME:AddMessage(S.Hex(S.colors.accent, "MaterialCraftUI Demo") .. " loaded. Type /mcui to open it.")
