

local frame

-- Textures
local resize_texture = "Interface\\AddOns\\Cascade\\textures\\resizegrip"
local backdrop = {bgFile = "Interface/Buttons/WHITE8X8",
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				insets = {left = 4, right = 4, top = 4, bottom = 4},
				tile = true, tileSize = 16, edgeSize = 16,
}
Cascade.backdrop = backdrop

local media = LibStub("LibSharedMedia-3.0", true)
-- Local upvalues
local GetTime = GetTime
local date = date
local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown
local string_format, string_gsub = string.format, string.gsub
local GetMouseFocus = GetMouseFocus

local baseTime = time() - GetTime()
local millisecondsMaxDigits, millisecondsDefaultDigits = 3, 2
local millisecondFormat, millisecondsFactor = "%01d", 10
local timestampFormat = "%I:%M:%S"
local blizzTimestampFormat = "^[%d:]+>%s"
local defaultEventCacheSize = 150
local maxEventCacheSize = 5000
local eventDisplayOffset = 0
local scrollDownDelay = 10
local onMouseWheel, scrollUp, scrollDown

-------------------------------------------------------------------------------
-- eventCache contains all the displayed events and relevant information.
-- Direct access to the eventCache table is not available.
-- Access to the eventCache requires use of the following helper methods.
--
-- Methods:
-- * eventCache_initialize(size)
-- * eventCache_getSize()
-- * eventCache_insert(text, loc, r, g, b, icon, spellID, msg, msgClean)
-- * eventCache_get(i)
-- * eventCache_set(i, text, loc, r, g, b, icon, spellID, msg, msgClean)
-------------------------------------------------------------------------------

local eventCache_initialize, eventCache_getSize, eventCache_insert, eventCache_get, eventCache_set
do
	-- older -> current -> recent
	local eventCache = {}

	local eventCacheSize, head, size
	
	-- eventCache_initialize(size)
	-- * initializes the eventCache to the given size
	function eventCache_initialize(s)
	-- First fill out the eventCache table with tables to represent each event.
		eventCacheSize, head, size = s, 0, 0
		for i = 1, s do
			if not eventCache[i] then eventCache[i] = {} end
		end
		for i = s + 1, #eventCache do
			eventCache[i] = nil
		end
	end
		
	-- eventCache_getSize()
	-- * gets the size of the eventCache
	-- returns: size
	function eventCache_getSize()
		return size
	end

	-- eventCache_insert(text, loc, r, g, b, icon, spellID, msg, msgClean)
	-- * inserts an event into the cache.
	function eventCache_insert(...)
		if size < eventCacheSize then
			size = size + 1
		end
		
		head = head % eventCacheSize + 1
		local e = eventCache[head]
		e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8], e[9] = ...
	end
	
	-- eventCache_get(i)
	-- * gets the information pertaining to an event at an index i
	-- * An i of 0 returns the most recent index. As index i increases, events become increasingly old.
	-- * returns: text, loc, r, g, b, icon, spellID, msg, msgClean
	function eventCache_get(i)
		local e = eventCache[(head - (i or 0)) % eventCacheSize + 1]
		return e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8], e[9]
	end

	-- eventCache_set(i, text, loc, r, g, b, icon, spellID, msg, msgClean)
	-- * set the parameters of an event at an index of i
	function eventCache_set(i, text, loc, r, g, b, icon, spellID, msg, msgClean)
		local e = eventCache[(head - (i or 0)) % eventCacheSize + 1]
		
		if text then e[1] = text end
		if loc then e[2] = loc end
		if r then e[3] = r end
		if g then e[4] = g end
		if b then e[5] = b end
		if icon then e[6] = icon end
		if spellID then e[7] = spellID end
		if msg then e[8] = msg end
		if msgClean then e[9] = msgClean end
	end
end


-------------------------------------------------------------------
------------------------------ Frame ------------------------------
-------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Create the display frame
-------------------------------------------------------------------------------
function Cascade:CreateFrame()
	-- Initialize our eventCache. Make sure custom eventCache sizes are supported.
	if self.db.profile.eventCacheSize then
		if (type(self.db.profile.eventCacheSize) ~= "number") or (self.db.profile.eventCacheSize <= 0) then
			self.db.profile.eventCacheSize = nil
		elseif self.db.profile.eventCacheSize > maxEventCacheSize then
			self.db.profile.eventCacheSize = maxEventCacheSize
		end
	end
	eventCache_initialize(self.db.profile.eventCacheSize or defaultEventCacheSize)
	
	
	if not frame then
		-- Create our frame.
		frame = CreateFrame("Frame", "CascadeFrame", UIParent)
		frame.totalEvents = 0
		self.Frame = frame
		
		-- Table to hold all of the eventFrames
		frame.eventFrames = {}
		
		-- Methods for moving CascadeFrame. Method references are stored so others can use them.
		frame.startMoving = function(self) if Cascade.db.profile.frame.locked then return end frame:StartMoving() end
		frame.stopMoving = function(self) frame:StopMovingOrSizing() Cascade:SaveFramePosition() end
		frame.startResizing = function(self) frame:StartSizing("BOTTOMRIGHT") end
		-- Methods for fading
		frame.onEnter = function(f) self:StopFading() end
		frame.onLeave = function(f) self:StartFading() end
		
		frame:EnableMouseWheel(true)
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetScript("OnSizeChanged", function(self) Cascade:CreateEventFrames() end)
		frame:SetScript("OnMouseWheel", onMouseWheel)
		frame:SetBackdrop(backdrop)
		frame:SetMinResize(128, 50)
		frame:SetMaxResize(800, 1200)

		-- Create the resize grip
		local grip = CreateFrame("Frame", nil, frame)
		frame.grip = grip
		grip:SetFrameLevel(frame:GetFrameLevel() + 10)
		grip:SetHeight(16)
		grip:SetWidth(16)
		grip:EnableMouse(true)
		grip:SetAlpha(0.5)
		grip:SetScript("OnEnter", frame.onEnter)
		grip:SetScript("OnLeave", frame.onLeave)
		
		local tex = grip:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture(resize_texture)
		tex:SetBlendMode("ADD")
		tex:SetAllPoints(grip)
	end

	self:RestoreFramePosition()
	self:UpdateFrameLock()
	self:UpdateFrameAppearance()
	self:SetMillisecondPrecision()

	if self.db.profile.frame.fadeOutOfCombat and not self.inCombat then
		frame:SetAlpha(0)
	end
end

-------------------------------------------------------------------------------
-- Restore the frame position and size
-------------------------------------------------------------------------------
function Cascade:RestoreFramePosition(reset)
	if self.db.profile.frame.clampToScreen then frame:SetClampedToScreen(true) end
	
	frame:ClearAllPoints()
	local s = frame:GetEffectiveScale()
	if reset then
		self.db.profile.frame.posx, self.db.profile.frame.posy = nil, nil
	end
	if self.db.profile.frame.posx and self.db.profile.frame.posy then
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.frame.posx / s, self.db.profile.frame.posy / s)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, -50 / s)
	end
	frame:SetHeight(self.db.profile.frame.height or 220)
	frame:SetWidth(self.db.profile.frame.width or 180)
	
	self:CreateEventFrames()
end

-------------------------------------------------------------------------------
-- Save the frame position and size
-------------------------------------------------------------------------------
function Cascade:SaveFramePosition()
	local s = frame:GetEffectiveScale()
	self.db.profile.frame.posx, self.db.profile.frame.posy = (frame:GetLeft() * s), (frame:GetTop() * s)
	self.db.profile.frame.height, self.db.profile.frame.width = frame:GetHeight(), frame:GetWidth()
end

-------------------------------------------------------------------------------
-- Update the appearance of the frame.
-------------------------------------------------------------------------------
function Cascade:UpdateFrameAppearance()
	-- Backdrop
	if media then
		backdrop.bgFile = media:Fetch("background", self.db.profile.frame.bgTexture)
		backdrop.edgeFile = media:Fetch("border", self.db.profile.frame.borderTexture)
	end
	-- Update the backdrop information
	backdrop.insets.left = self.db.profile.frame.inset
	backdrop.insets.right = self.db.profile.frame.inset
	backdrop.insets.top = self.db.profile.frame.inset
	backdrop.insets.bottom = self.db.profile.frame.inset
	backdrop.edgeSize = self.db.profile.frame.edgeSize
	backdrop.tile = self.db.profile.frame.tile
	backdrop.tileSize = self.db.profile.frame.tileSize
	-- Re-set the backdrop
	frame:SetBackdrop(backdrop)
	frame.grip:SetPoint("BOTTOMRIGHT", frame, -1 - backdrop.insets.right, 1 + backdrop.insets.bottom)
	
	frame:SetAlpha(self.db.profile.frame.alpha)
	-- Colors
	local colors = self.db.profile.colors.misc
	frame:SetBackdropColor(colors.frame.r, colors.frame.g, colors.frame.b, colors.frame.a)
	frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
	-- Colors for labels will be handled by UpdateLabels()
	self:UpdateLabels()
	
	-- History Frame
	local history = self:GetModule("History", true)
	if history then history:UpdateFrameAppearance() end
end

-------------------------------------------------------------------------------
-- Show/hide the resize grip and enable/disable resizing as necessary
-------------------------------------------------------------------------------
function Cascade:UpdateFrameLock()
	if self.db.profile.frame.locked then
		frame.grip:Hide()
		frame.grip:SetScript("OnMouseDown", nil)
		frame.grip:SetScript("OnMouseUp", nil)
	else
		frame.grip:Show()
		frame.grip:SetScript("OnMouseDown", frame.startResizing)
		frame.grip:SetScript("OnMouseUp", frame.stopMoving)
	end
end

-------------------------------------------------------------------------------
-- Create the PLAYER and TARGET labels
-------------------------------------------------------------------------------
function Cascade:CreateLabels()
	if not self.db.profile.frame.showLabels then
		if frame.labels then frame.labels:Hide() end
		return
	end
	if frame.labels then self:UpdateLabels() return frame.labels end
	
	local labels = CreateFrame("Frame", nil, frame)
	frame.labels = labels
	
	labels:EnableMouse(true)
	labels:RegisterForDrag("LeftButton")
	labels:SetScript("OnDragStart", frame.startMoving)
	labels:SetScript("OnDragStop", frame.stopMoving)
	labels:SetScript("OnEnter", frame.onEnter)
	labels:SetScript("OnLeave", frame.onLeave)

	labels.left = labels:CreateFontString(nil, "OVERLAY")
	labels.left:SetFontObject(CascadeFont)
	labels.left:SetPoint("LEFT")
	labels.left:SetPoint("RIGHT", labels, "CENTER")

	labels.right = labels:CreateFontString(nil, "OVERLAY")
	labels.right:SetFontObject(CascadeFont)
	labels.right:SetPoint("RIGHT")
	labels.right:SetPoint("LEFT", labels, "CENTER")
	
	self:UpdateLabels()
	
	return frame.labels
end

-------------------------------------------------------------------------------
-- Update the size and text of the labels and show/hide them as necessary
-------------------------------------------------------------------------------
function Cascade:UpdateLabels()
	if not frame.labels then return end
	
	frame.labels:Show()
	frame.labels:SetHeight(self.db.profile.frame.frameHeight)
	frame.labels.right:SetText(self.db.profile.frame.flipEventSides and PLAYER or TARGET)
	frame.labels.left:SetText(self.db.profile.frame.flipEventSides and TARGET or PLAYER)
	
	-- Color
	local c = self.db.profile.colors.misc.text
	frame.labels.left:SetTextColor(c.r, c.g, c.b)
	frame.labels.right:SetTextColor(c.r, c.g, c.b)
end

-------------------------------------------------------------------------------
-- Update the millisecond format to use a specified number of digits.
-------------------------------------------------------------------------------
function Cascade:SetMillisecondPrecision(ms)
	-- If ms == true, method was called by GUI, so set number of digits to default.
	ms = ((ms == true) and millisecondsDefaultDigits) or ms or self.db.profile.milliseconds
	
	if ms and type(ms) == "number" then
		ms = math.ceil(ms)
		-- Make sure the number of digits is between 1-5
		if ms <= 0 then
			self.db.profile.milliseconds = false
		else
			self.db.profile.milliseconds = ((ms > millisecondsMaxDigits) and millisecondsMaxDigits) or ms
		end
	end

	if type(self.db.profile.milliseconds) ~= "number" then
		self.db.profile.milliseconds = false
		return
	end
	millisecondFormat, millisecondsFactor = "%.0"..self.db.profile.milliseconds.."d", 10^(self.db.profile.milliseconds)
end

-------------------------------------------------------------------------------
-- Method that handles mouse scrolling on the frame
-------------------------------------------------------------------------------
local lastScroll
function onMouseWheel(self, dir)
	if not dir then return end
	if Cascade.db.profile.frame.reverseScrollDir then
		dir = -dir
	end
		
	if dir < 0 then
		scrollDown(IsShiftKeyDown() and -1 or IsControlKeyDown() and 5)
	elseif dir > 0 then
		scrollUp(IsShiftKeyDown() and -1 or IsControlKeyDown() and 5)
	end
	
	if (self == frame) and (eventDisplayOffset > 0) then
		lastScroll = GetTime()
	end

	-- Update tooltips while scrolling
	local f = GetMouseFocus()
	if not f then return end
	local onLeave = f:GetScript("OnLeave")
	local onEnter = f:GetScript("OnEnter")
	if onLeave then onLeave(f) end
	if onEnter then onEnter(f) end
end

-------------------------------------------------------------------------------
-- Scroll the display up (show older events)
-------------------------------------------------------------------------------
function scrollUp(lines)
	local orig = eventDisplayOffset
	
	if lines == -1 then
		eventDisplayOffset = eventCache_getSize() - 1
	else
		eventDisplayOffset = eventDisplayOffset + (lines or 1)
		if eventDisplayOffset > eventCache_getSize() - 1 then
			eventDisplayOffset = eventCache_getSize() - 1
			if eventDisplayOffset < 0 then eventDisplayOffset = 0 end
		end
	end	

	if orig ~= eventDisplayOffset then
		Cascade:UpdateAllEvents()
	end
end

-------------------------------------------------------------------------------
-- Scroll the display down (show newer events)
-------------------------------------------------------------------------------
function scrollDown(lines)
	local orig = eventDisplayOffset
	
	if lines == -1 then
		eventDisplayOffset = 0
	else
		eventDisplayOffset = eventDisplayOffset - (lines or 1)
		if eventDisplayOffset < 0 then
			eventDisplayOffset = 0
		end
	end
	
	if orig ~= eventDisplayOffset then
		Cascade:UpdateAllEvents()
	end
end

-------------------------------------------------------------------------------
-- Flip the location of events across the y-axis. Update the eventCache as well
-------------------------------------------------------------------------------
function Cascade:FlipEventSides(value)
	if value == self.db.profile.frame.flipEventSides then return end
	self.db.profile.frame.flipEventSides = value
	self:UpdateLabels()
	-- Update all locations within the eventCache
	for i = 1, eventCache_getSize() do
		local _, loc = eventCache_get(i)
		if loc then eventCache_set(i, nil, -loc) end
	end
	self:UpdateAllEvents()
end

-------------------------------------------------------------------------------
-- Stores the data into the eventCache
-------------------------------------------------------------------------------
function Cascade:DisplayEvent(text, loc, r, g, b, icon, spellID, msg, msgClean)
	if not text then return end
	-- Reset the displayOffset if necessary
	if lastScroll and GetTime() > (lastScroll + scrollDownDelay) then
		lastScroll = nil
		eventDisplayOffset = 0
	end

	-- Don't scroll if we're looking up above. Nice for checking combat log while in combat.
	if eventDisplayOffset > 0 then scrollUp(1) end
	
	loc = loc or 0
	if self.db.profile.frame.flipEventSides then loc = -loc end
	
	-- Add timestamp
	if self.db.profile.timestamp then
		-- If we have timestamps enabled, strip Blizzard's timestamps if available.
		msg = msg and string_gsub(msg, blizzTimestampFormat, "")
		msgClean = msgClean and string_gsub(msgClean, blizzTimestampFormat, "")
		local timestamp
		if self.db.profile.milliseconds then
			local t = baseTime + GetTime()
			timestamp = "|cFFFFFFFF"..date(timestampFormat, t)..".".. string_format(millisecondFormat, (t % 1) * millisecondsFactor) .. "|r\n"
		else
			timestamp = "|cFFFFFFFF"..date(timestampFormat).."|r\n"
		end
		msg = timestamp .. (msg or "")
		msgClean = msgClean and timestamp..msgClean
	end
	eventCache_insert(text, loc, r or 1, g or 1, b or 1, icon, spellID, msg, msgClean)
	self:UpdateAllEvents()
end

-------------------------------------------------------------------------------
-- Update the display for all events
-------------------------------------------------------------------------------
local UpdateSingleEventFrame
function Cascade:UpdateAllEvents()
	for i = 1, frame.totalEvents do
		-- Find out the event id within the eventCache. Bad comment, I know, but, it's hard to explain. Trust me, though, it works.
		local id = frame.totalEvents - i + 1 + eventDisplayOffset
		if eventCache_getSize() >= id then
			UpdateSingleEventFrame(i, eventCache_get(id))
		else
			frame.eventFrames[i]:CleanFrame()
		end
	end
	self:ResetFading()
end

-------------------------------------------------------------------------------
-- Method updates a single event at a given id
-------------------------------------------------------------------------------
function UpdateSingleEventFrame(id, text, loc, r, g, b, icon, spellID, msg, msgClean)
	local f = frame.eventFrames[id]
	
	f.spellID = spellID
	f.tooltipText = msg
	f.tooltipTextClean = msgClean
	
	-- Position the icons correctly. Set the alpha values as well.
	if loc == 1 then
		f.rightIcon:ClearAllPoints()
		f.rightIcon:SetPoint("RIGHT", f, "RIGHT", - Cascade.db.profile.frame.petOffset, 0)
		f.text:SetTextColor(r, g, b, Cascade.db.profile.frame.petAlpha)
		f.rightIcon:SetVertexColor(1, 1, 1, Cascade.db.profile.frame.petAlpha)
	elseif loc == -1 then
		f.leftIcon:ClearAllPoints()
		f.leftIcon:SetPoint("LEFT", f, "LEFT", Cascade.db.profile.frame.petOffset, 0)
		f.text:SetTextColor(r, g, b, Cascade.db.profile.frame.petAlpha)
		f.leftIcon:SetVertexColor(1, 1, 1, Cascade.db.profile.frame.petAlpha)
	elseif loc == 0 then
		f.rightIcon:ClearAllPoints()
		f.rightIcon:SetPoint("LEFT", f, "RIGHT")
		f.leftIcon:ClearAllPoints()
		f.leftIcon:SetPoint("RIGHT", f, "LEFT")
		f.text:SetTextColor(r, g, b, 1)
	else
		f.rightIcon:ClearAllPoints()
		f.rightIcon:SetPoint("RIGHT")
		f.rightIcon:SetVertexColor(1, 1, 1, 1)
		f.leftIcon:ClearAllPoints()
		f.leftIcon:SetPoint("LEFT")
		f.leftIcon:SetVertexColor(1, 1, 1, 1)
		f.text:SetTextColor(r, g, b, 1)
	end
	
	-- Set the textures and text justification.
	if loc > 0 then
		f.rightIcon:SetTexture(icon)
		f.leftIcon:SetTexture()
		f.text:SetJustifyH("RIGHT")
	elseif loc < 0 then
		f.rightIcon:SetTexture()
		f.leftIcon:SetTexture(icon)
		f.text:SetJustifyH("LEFT")
	else
		f.rightIcon:SetTexture()
		f.leftIcon:SetTexture()
		f.text:SetJustifyH("CENTER")
	end
	
	f.text:SetText(text)
end

-------------------------------------------------------------------------------
-- Fading
-------------------------------------------------------------------------------
local fadeDelay, fadeOutOfCombat
-- fadeTime - Time in seconds to fade one event frame.
local fadeTime = 1.5
-- nextFadeAlpha - Alpha value which when reached triggers the next frame to begin fading.
-- 		setting to 1 will fade all events at the same time, while setting to 0 will fade events one after another.
local nextFadeAlpha = .5
local fadeFactor = fadeTime * (1 - nextFadeAlpha)

local onUpdate = function(self, e)
	self.elapsed = self.elapsed + e
	if self.elapsed < fadeDelay then return end
	if fadeOutOfCombat then
		self:SetAlpha(0)
		return self:SetScript("OnUpdate", nil)
	end
	for i = self.current, self.totalEvents do
		local start = fadeDelay + (i - 1) * fadeFactor
		if self.elapsed < start then return end
		local a = 1 - ((self.elapsed - start) / fadeTime)
		if a <= 0 then self.current = i + 1 end
		self.eventFrames[i]:SetAlpha(a)
	end
	if self.current > self.totalEvents then
		self:SetScript("OnUpdate", nil)
	end
end

function Cascade:StartFading()
	if self.inCombat then return end
	fadeDelay, fadeOutOfCombat = self.db.profile.frame.fadeDelay, self.db.profile.frame.fadeOutOfCombat
	if not fadeOutOfCombat and fadeDelay <= 0 then return end
	frame.elapsed = 0
	frame.current = 1
	frame:SetScript("OnUpdate", onUpdate)
end

function Cascade:ResetFading()
	if self.inCombat or self.db.profile.frame.fadeOutOfCombat or self.db.profile.frame.fadeDelay <= 0 then return end
	self:StopFading()
	self:StartFading()
end

function Cascade:StopFading()
	if self.inCombat then return end
	frame:SetScript("OnUpdate", nil)
	frame:SetAlpha(self.db.profile.frame.alpha)
	for k, v in pairs(frame.eventFrames) do
		v:SetAlpha(1)
	end
end

