-- Minimal 3.3.5 client for the style kit's offline tests: frames whose methods all exist, fonts, and the few
-- globals the kit reads.
local mock = { failures = 0, frames = {} }
_G.MOCK = mock

-- bit library (the client has it built in)
local function bitop(a, b, fn)
	local r, m = 0, 1
	a, b = a % 4294967296, b % 4294967296
	for _ = 1, 32 do
		local x, y = a % 2, b % 2
		if fn(x, y) then r = r + m end
		a, b, m = (a - x) / 2, (b - y) / 2, m * 2
	end
	return r
end
bit = {
	band = function(a, b) return bitop(a, b, function(x, y) return x == 1 and y == 1 end) end,
	bor = function(a, b) return bitop(a, b, function(x, y) return x == 1 or y == 1 end) end,
	bxor = function(a, b) return bitop(a, b, function(x, y) return x ~= y end) end,
	lshift = function(a, n) return (a * 2 ^ n) % 4294967296 end,
	rshift = function(a, n) return math.floor((a % 4294967296) / 2 ^ n) end,
}

-- frames: every method exists and does nothing unless listed
local function Stub()
	local o = { scripts = {}, shown = false }
	return setmetatable(o, { __index = function(t, k)
		local f
		if type(k) ~= "string" or not k:match("^%u") then return nil
		elseif k == "SetScript" then f = function(self, s, fn) self.scripts[s] = fn end
		elseif k == "Show" then f = function(self) self.shown = true end
		elseif k == "Hide" then f = function(self) self.shown = false end
		elseif k == "IsShown" then f = function(self) return self.shown end
		elseif k == "RegisterEvent" then f = function(self) mock.frames[#mock.frames + 1] = self end
		elseif k == "HookScript" then f = function(self, s, fn)
			local old = self.scripts[s]
			self.scripts[s] = function(...) if old then old(...) end fn(...) end
		end
		elseif k == "GetScript" then f = function(self, s) return self.scripts[s] end
		elseif k == "SetText" then f = function(self, v) self.text = v end
		elseif k == "SetTextColor" then f = function(self, r, g, b) self.color = { r, g, b } end
		elseif k == "SetFontObject" then f = function(self, font) self.fontObject = font end
		elseif k == "SetAttribute" then f = function(self, key, v) self.attributes = self.attributes or {} self.attributes[key] = v end
		elseif k == "GetAttribute" then f = function(self, key) return self.attributes and self.attributes[key] end
		elseif k == "IsVisible" then f = function(self) return self.shown end
		elseif k == "GetRight" then f = function() return 400 end
		elseif k == "GetCenter" then f = function() return 300, 200 end
		elseif k == "GetEffectiveScale" then f = function() return 1 end
		elseif k == "SetPoint" then f = function(self, ...) self.point = { ... } end
		elseif k == "SetFocus" then f = function(self)
			if self.scripts.OnEditFocusGained then self.scripts.OnEditFocusGained(self) end
		end
		elseif k == "ClearFocus" then f = function(self)
			if self.scripts.OnEditFocusLost then self.scripts.OnEditFocusLost(self) end
		end
		elseif k == "SetFont" then f = function(self, face, height) self.face, self.height = face, height end
		elseif k == "GetFont" then f = function(self) return self.face, self.height, "" end
		elseif k == "GetText" then f = function(self) return self.text end
		elseif k == "SetChecked" then f = function(self, v) self.checked = v and 1 or nil end
		elseif k == "GetChecked" then f = function(self) return self.checked end
		elseif k == "GetFontString" then f = function(self) self.fs = self.fs or Stub() return self.fs end
		elseif k == "GetStringWidth" then f = function() return 60 end
		elseif k == "GetStringHeight" or k == "GetTextHeight" then f = function() return 14 end
		elseif k == "GetVerticalScrollRange" then f = function(self) return self.scrollRange or 0 end
		elseif k == "GetFrameLevel" then f = function() return 1 end
		elseif k == "GetThumbTexture" then f = function(self) self.thumb = self.thumb or Stub() return self.thumb end
		elseif k == "Enable" then f = function(self) self.enabled = true end
		elseif k == "Disable" then f = function(self) self.enabled = false end
		elseif k == "IsEnabled" then f = function(self) return self.enabled ~= false and 1 or nil end
		elseif k:match("^Create") then f = function() return Stub() end
		else f = function() end end
		rawset(t, k, f)
		return f
	end })
end
mock.Stub = Stub
CreateFrame = function(_, name, parent)
	local f = Stub()
	f.parent = parent
	mock.created = mock.created or {}
	mock.created[#mock.created + 1] = f
	if name then
		_G[name] = f
		_G[name .. "Text"] = Stub()
		_G[name .. "ScrollBar"] = Stub()
		_G[name .. "ScrollBarScrollUpButton"] = Stub()
		_G[name .. "ScrollBarScrollDownButton"] = Stub()
	end
	return f
end
UIParent = Stub()
Minimap = Stub()
Minimap.GetWidth = function() return 140 end
Minimap.GetCenter = function() return 500, 500 end
Minimap.GetEffectiveScale = function() return 1 end
GetCursorPosition = function() return mock.cursorX or 500, mock.cursorY or 500 end
GameTooltip = Stub()
UIErrorsFrame = { AddMessage = function(_, msg) mock.lastError = msg end }
UISpecialFrames = {}
tinsert = table.insert
SlashCmdList = {}
PlaySound = function() end
-- font objects keep their face and size; GameFontHighlightSmall has no face and GameFontHighlight a 0 size, as
-- copies came back in game with ElvUI restyling the stock fonts
local function Font(face, height)
	local f = Stub()
	f.face, f.height = face, height
	f.GetFont = function(self) return self.face, self.height, "" end
	f.SetFont = function(self, face2, height2) self.face, self.height = face2, height2 end
	f.CopyFontObject = function(self, other) self.face, self.height = other.face, other.height end
	return f
end
local FRIZ = "Fonts\\FRIZQT__.TTF"
GameFontNormalLarge, GameFontHighlight, GameFontHighlightLarge = Font(FRIZ, 16), Font(FRIZ, 0), Font(FRIZ, 16)
GameFontNormalHuge, ChatFontNormal, GameFontHighlightSmall = Font(FRIZ, 20), Font("Fonts\\ARIALN.TTF", 14), Font()
STANDARD_TEXT_FONT = FRIZ
CreateFont = function(name) local f = Font() if name then _G[name] = f end return f end
unpack = unpack or table.unpack
LOCALIZED_CLASS_NAMES_MALE = { PALADIN = "Paladin", MAGE = "Mage", HUNTER = "Hunter", WARRIOR = "Warrior" }
DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) mock.lastMessage = msg end }
GetAddOnMetadata = function() return "test" end
IsShiftKeyDown = function() return false end
IsModifiedClick = function() return mock.modified end
mock.time = 100
GetTime = function() return mock.time end
-- the mouse: whether a button is held, and the one frame it's over
mock.mouseDown, mock.mouseOver = false, nil
IsMouseButtonDown = function() return mock.mouseDown end
MouseIsOver = function(f) return f ~= nil and mock.mouseOver == f end

function mock.Fire(event, ...)
	for _, f in ipairs(mock.frames) do
		if f.scripts.OnEvent then f.scripts.OnEvent(f, event, ...) end
	end
end

function mock.check(label, ok)
	if not ok then mock.failures = mock.failures + 1 end
	print((ok and "ok    " or "FAIL  ") .. label)
end

-- Runs every OnUpdate script until none of the frames that have one is shown, or `limit` passes.
function mock.RunUpdates(limit)
	for _ = 1, limit or 100 do
		mock.time = mock.time + 1
		for _, f in ipairs(mock.created) do
			if f.shown ~= false and f.scripts.OnUpdate then f.scripts.OnUpdate(f, 1) end
		end
	end
end

