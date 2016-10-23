

local history = Cascade:GetModule("History", true)
if not history then return end
local L = LibStub("AceLocale-3.0"):GetLocale("Cascade")

-- Textures
local backdrop
local resize_texture = "Interface\\AddOns\\Cascade\\textures\\resizegrip"
local highlight = {bgFile = "Interface/QuestFrame/UI-QuestTitleHighlight", insets = {left = 1, right = 1, top = 1, bottom = 1}}
local anchorBackdrop = {bgFile = "Interface/Buttons/WHITE8X8", tile = true, tileSize = 16, edgeSize = 16}
local downTexture = "Interface/BUTTONS/Arrow-Down-Up"
local upTexture = "Interface/BUTTONS/Arrow-Up-Up"

-- Upvalues
local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown
local date = date
local string_find = string.find
local table_insert, table_sort = table.insert, table.sort
local pairs = pairs
local GetMouseFocus = GetMouseFocus

local timestampFormat = "%m/%d/%y %H:%M:%S"
local sessionTimestampFormat = "%H:%M:%S" -- Timestamp if the event was tracked during this session.

local frame, db
local frameCache = {}
local timeLoaded = time()
local display = "DAMAGE_OUT"
local displayOffset, displaySize = 0, 0

-- Local functions
local pairsByKeys, sortFunction, onMouseWheel, scrollUp, scrollDown

-- Local key button methods (buttons to switch what we're displaying)
local createKeyButton

-- Local header method
local headerOnClick

-- Local event frame methods
local getEventFrame, cleanEventFrame, resizeEventFrame, onEnter, onLeave, onClick, showRightClickMenu

-- Local variables used to calculate a width for the hit/crit columns
local hiddenFontString
local textWidth = 60
local sampleFontWidth = "555555555"


-------------------------------------------------------------------
------------------------------ Frame ------------------------------
-------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Create the history frame
-------------------------------------------------------------------------------
function history:CreateFrame()
	if frame then return end
	
	-- Initialize local variables
	db = self.HISTORY
	
	-- Create our frame.
	frame = CreateFrame("Frame", "CascadeHistoryFrame", UIParent)
	tinsert(UISpecialFrames, frame:GetName())
	self.Frame = frame

	-- Table to hold all of the eventFrames
	frame.eventFrames = {}

	-- Place our frame
	frame:SetPoint("CENTER")
	frame:SetHeight(300)
	frame:SetWidth(300)


	-- Establish the default sorting method. Sort by name and ascending. A-Z
	-- * asc:    1
	-- * desc:  -1
	frame.sortType = "name" -- "name", "hit", "crit"
	frame.sortDir = 1
	
	-- Methods for moving CascadeHistoryFrame. Method references are stored so others can use them.
	frame.startMoving = function(self) frame:StartMoving() end
	frame.stopMoving = function(self) frame:StopMovingOrSizing() end
	frame.startResizing = function(self) frame:StartSizing("BOTTOMRIGHT") end
	
	frame:SetClampedToScreen(true)
	frame:EnableMouseWheel(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetScript("OnSizeChanged", function(self) history:CreateEventFrames() end)
	frame:SetScript("OnMouseWheel", onMouseWheel)
	
	-- Background
	backdrop = Cascade.backdrop
	frame:SetBackdrop(backdrop)
	frame:SetMaxResize(800, 1200)
	
	-- Top anchor
	local anchor = CreateFrame("Frame", nil, frame)
	frame.anchor = anchor
	anchor:SetMovable(true)
	anchor:EnableMouse(true)
	anchor:SetClampedToScreen(true)
	anchor:RegisterForDrag("LeftButton", "RightButton")
	anchor:SetHeight(24)
	local inset = backdrop.insets.top
	--anchor:SetPoint("TOPLEFT", inset, -inset)
	--anchor:SetPoint("TOPRIGHT", -inset, -inset)
	anchor:SetScript("OnDragStart", frame.startMoving)
	anchor:SetScript("OnDragStop", frame.stopMoving)

	anchor.text = anchor:CreateFontString(nil, "OVERLAY")
	anchor.text:SetFontObject(CascadeFont)
	anchor.text:SetPoint("CENTER")
	anchor:SetBackdrop(anchorBackdrop)
	anchor:SetBackdropColor(0, 0, 0, .5)

	-- Close button
	local close = CreateFrame("Button", nil, frame.anchor, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT")
	close:SetScript("OnClick", function(self) frame:Hide() end)
	close:SetHeight(24)
	close:SetWidth(24)

	-- Create the resize grip
	local grip = CreateFrame("Frame", nil, frame)
	frame.grip = grip
	grip:SetFrameLevel(frame:GetFrameLevel() + 10)
	grip:SetHeight(16)
	grip:SetWidth(16)
	--grip:SetPoint("BOTTOMRIGHT", frame, - (inset + 1), inset + 1)
	grip:EnableMouse(true)
	grip:SetAlpha(0.5)
	grip:SetScript("OnMouseDown", frame.startResizing)
	grip:SetScript("OnMouseUp", frame.stopMoving)
	local tex = grip:CreateTexture(nil, "BACKGROUND")
	tex:SetTexture(resize_texture)
	tex:SetBlendMode("ADD")
	tex:SetAllPoints(grip)
	
	-- Reset button
	local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	reset:SetText(L.RESET)
	reset:SetWidth(reset:GetTextWidth() + 10)
	reset:SetHeight(18)
	reset:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
	reset:SetScript("OnClick", function(self) history:ResetHistory() end)
	
	-- Create the side buttons.
	local D_ou = createKeyButton(frame, "DAMAGE_OUT", "Spell_Shadow_ShadowBolt", "TOPLEFT", frame, "TOPRIGHT", 3, -24)
	local D_in = createKeyButton(frame, "DAMAGE_IN", "Spell_Holy_SealOfSacrifice", "TOPRIGHT", frame, "TOPLEFT", -3, -24)
	local H_ou = createKeyButton(frame, "HEAL_OUT", "Spell_Nature_MagicImmunity", "TOPLEFT", D_ou, "BOTTOMLEFT", 0, -6)
	local H_in = createKeyButton(frame, "HEAL_IN", "Spell_Holy_HolyBolt", "TOPRIGHT", D_in, "BOTTOMRIGHT", 0, -6)
	
	-- Create side button indicator.
	frame.displayIndicator = D_ou:CreateTexture(nil, "OVERLAY")
	frame.displayIndicator:SetTexture("Interface\\Buttons\\UI-Button-Outline")
	frame.displayIndicator:SetBlendMode("ADD")
	frame.displayIndicator:SetHeight(2 * 24)
	frame.displayIndicator:SetWidth(2 * 24)
	frame.displayIndicator:SetVertexColor(0, 0, 1, 1)


	-- Create the header
	local header = getEventFrame()
	header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 1, 0)
	header:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", -1, 0)
	header.CleanFrame = nil

	header.sortType = "name"
	header.crit.sortType = "crit"
	header.hit.sortType = "hit"
	
	header.name:SetText(NAME)
	header.crit.text:SetText(CRIT_ABBR)
	header.hit.text:SetText(HIT)
	
	header:SetScript("OnMouseUp", headerOnClick)
	header.crit:SetScript("OnMouseUp", headerOnClick)
	header.hit:SetScript("OnMouseUp", headerOnClick)
	frame.header = header

	-- Create the indicator
	header.indicator = header:CreateTexture(nil, "OVERLAY")
	header.indicator:SetHeight(12)
	header.indicator:SetWidth(12)
	header.indicator:SetVertexColor(1, 1, 1, .8)
	header.indicator:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT")
	
	self:UpdateFrameAppearance()
	self:OnFontChanged()
end

-------------------------------------------------------------------------------
-- Update the background, border, and header colors
-------------------------------------------------------------------------------
function history:UpdateFrameAppearance()
	if not frame then return end
	local inset = backdrop.insets.top
	frame.anchor:SetPoint("TOPLEFT", inset, -inset)
	frame.anchor:SetPoint("TOPRIGHT", -inset, -inset)
	frame.grip:SetPoint("BOTTOMRIGHT", frame, - (inset + 1), inset + 1)

	-- Backdrop
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(Cascade.db.profile.colors.misc.frame.r, Cascade.db.profile.colors.misc.frame.g, Cascade.db.profile.colors.misc.frame.b, Cascade.db.profile.colors.misc.frame.a)
	frame:SetBackdropBorderColor(Cascade.db.profile.colors.misc.border.r, Cascade.db.profile.colors.misc.border.g, Cascade.db.profile.colors.misc.border.b, Cascade.db.profile.colors.misc.border.a)
	-- Set header text color
	local textColor = Cascade.db.profile.colors.misc.text
	frame.header.name:SetTextColor(textColor.r, textColor.g, textColor.b)
	frame.header.hit.text:SetTextColor(textColor.r, textColor.g, textColor.b)
	frame.header.crit.text:SetTextColor(textColor.r, textColor.g, textColor.b)
end

-- keyButton methods
local keyButtonClick = function(self, button) history:ShowHistory(self.key) end

local keyOnLeave = function() GameTooltip:Hide() end

local keyOnEnter = function(self)
	GameTooltip:SetOwner(self, Cascade.db.profile.frame.tooltipAnchor)
	GameTooltip:SetText(L[self.key], Cascade.db.profile.colors.misc.text.r, Cascade.db.profile.colors.misc.text.g, Cascade.db.profile.colors.misc.text.b, 1, 1)
end

createKeyButton = function(anchor, key, texture, ...)
	local button = CreateFrame("Button", nil, anchor or frame)
	frame[key] = button
	button.key = key
	button:SetHeight(24)
	button:SetWidth(24)
	button:SetScript("OnClick", keyButtonClick)
	button:SetScript("OnEnter", keyOnEnter)
	button:SetScript("OnLeave", keyOnLeave)
	button:SetNormalTexture("Interface\\Icons\\"..texture)
	button:GetNormalTexture():SetTexCoord(.1, .9, .1, .9)
	button:SetPoint(...)
	return button
end

-- Header on click method
headerOnClick = function(self, button)
	if frame.sortType == self.sortType then
		frame.sortDir = (- frame.sortDir)
	else
		frame.sortType = self.sortType
		-- Default sort asc. for name, desc. for hit/crit
		frame.sortDir = frame.sortType == "name" and 1 or -1
	end
	
	history:UpdateAllEvents()
end

-------------------------------------------------------------------------------
-- Update the indicator to show how the history is currently being sorted
-------------------------------------------------------------------------------
function history:UpdateIndicator()
	local f = frame.header
	
	local off
	if frame.sortDir == 1 then
		off = -2
		f.indicator:SetTexture(upTexture)
	else
		off = -6
		f.indicator:SetTexture(downTexture)
	end
	f.indicator:ClearAllPoints()
	
	if frame.sortType == "name" then
		f.indicator:SetPoint("CENTER", f, "TOP", - (f.crit:GetWidth() + f.hit:GetWidth()) / 2, off)
	elseif frame.sortType == "crit" then
		f.indicator:SetPoint("CENTER", f.crit, "TOP", 0, off)
	elseif frame.sortType == "hit" then
		f.indicator:SetPoint("CENTER", f.hit, "TOP", 0, off)
	end
end

-------------------------------------------------------------------------------
-- Toggle the history frame display
-------------------------------------------------------------------------------
function Cascade:ToggleHistory()
	if frame and frame:IsVisible() then
		frame:Hide()
	else
		history:ShowHistory()
	end
end

-------------------------------------------------------------------------------
-- Show History frame
-------------------------------------------------------------------------------
function history:ShowHistory(key)
	if not frame then self:CreateFrame() end
	frame:Show()
	
	if db[key] then
		displayOffset = 0
		display = key
		frame.sortType = "name"
		frame.sortDir = 1
	end
	
	-- Update anchor text
	frame.anchor.text:SetText(L[display])
	frame.displayIndicator:SetPoint("CENTER", frame[display])
	
	self:UpdateAllEvents()
end

-------------------------------------------------------------------------------
-- Method that handles mouse scrolling on the frame
-------------------------------------------------------------------------------
function onMouseWheel(self, dir)
	if not dir then return end
	
	if dir < 0 then
		scrollDown(IsShiftKeyDown() and -1 or IsControlKeyDown() and 5)
	elseif dir > 0 then
		scrollUp(IsShiftKeyDown() and -1 or IsControlKeyDown() and 5)
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
-- Scroll the display up
-------------------------------------------------------------------------------
function scrollUp(lines)
	local orig = displayOffset
	
	if lines == -1 then
		displayOffset = 0
	else
		displayOffset = displayOffset - (lines or 1)
		if displayOffset < 0 then
			displayOffset = 0
		end
	end	

	if orig ~= displayOffset then
		history:UpdateAllEvents()
	end
end

-------------------------------------------------------------------------------
-- Scroll the display down
-------------------------------------------------------------------------------
function scrollDown(lines)
	local orig = displayOffset
	
	if lines == -1 then
		displayOffset = displaySize - frame.totalEvents
	else
		displayOffset = displayOffset + (lines or 1)
		if displayOffset > displaySize - frame.totalEvents then
			displayOffset = displaySize - frame.totalEvents
		end
	end
	
	if orig ~= displayOffset then
		history:UpdateAllEvents()
	end
end

-- Get a combat log message with a timestamp.
local function getFormattedMessage(timestamp, msg)
	if not timestamp then return msg end
	if timestamp and msg then
		return "|cffffffff"..date((timestamp > timeLoaded) and sessionTimestampFormat or timestampFormat, timestamp).."|r\n"..msg
	end
end

-------------------------------------------------------------------------------
-- Update the display for all events
-------------------------------------------------------------------------------
function history:UpdateAllEvents()
	if not (frame and frame:IsVisible()) then return end
	
	self:UpdateIndicator()
	local id = 1 -- frame id
	local i = 0 -- iterations through the loop
	displaySize = 0
	for k in pairs(db[display]) do
		displaySize = displaySize + 1
	end
	
	for spell, info in pairsByKeys(db[display], sortFunction) do
		if i >= displayOffset then
			local f = frame.eventFrames[id]
			if not f then break end
			f.name:SetText(spell)
			f.icon:SetTexture(info.icon)
			f.hit.text:SetText(info.HIT_amount)
			f.crit.text:SetText(info.CRIT_amount)
			f.hit_msg = getFormattedMessage(info.HIT_time, info.HIT_msg)
			f.crit_msg = getFormattedMessage(info.CRIT_time, info.CRIT_msg)
			--f.hit_msgClean = getFormattedMessage(info.HIT_time, info.HIT_msgClean)
			--f.crit_msgClean = getFormattedMessage(info.CRIT_time, info.CRIT_msgClean)
			
			id = id + 1
		end
		i = i + 1
	end
	
	for i = id, frame.totalEvents do
		frame.eventFrames[i]:CleanFrame()
	end
end

-- Sort function
pairsByKeys = function(t, f)
	local a = {}
		for n in pairs(t) do table_insert(a, n) end
		table_sort(a, f)
		local i = 0 -- iterator variable
		local iter = function() -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end

-- Comparison method for sort function
sortFunction = function(a, b)
	-- Sort by name
	if frame.sortType == "name" then
		if frame.sortDir == 1 then
			return a < b
		else
			return a > b
		end
	-- Sort by hit amount
	elseif frame.sortType == "hit" then
		local a_amt, b_amt = db[display][a].HIT_amount, db[display][b].HIT_amount
		if frame.sortDir == 1 then
			if a_amt and b_amt then
				return a_amt < b_amt
			elseif a_amt or b_amt then
				return -(a_amt or 0) < -(b_amt or 0)
			else
				return a < b
			end
		else
			if a_amt or b_amt then
				return (a_amt or 0) > (b_amt or 0)
			else
				return a < b
			end
		end
	-- Sort by crit amount
	elseif frame.sortType == "crit" then
		local a_amt, b_amt = db[display][a].CRIT_amount, db[display][b].CRIT_amount
		if frame.sortDir == 1 then
			if a_amt and b_amt then
				return a_amt < b_amt
			elseif a_amt or b_amt then
				return -(a_amt or 0) < -(b_amt or 0)
			else
				return a < b
			end
		else
			if a_amt or b_amt then
				return (a_amt or 0) > (b_amt or 0)
			else
				return a < b
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Create all the event frames
-------------------------------------------------------------------------------
function history:CreateEventFrames()
	if not frame then return end
	
	frame.anchor:SetHeight(Cascade.db.profile.frame.frameHeight + 8)
	local prev = frame.header
	prev:ResizeFrame(Cascade.db.profile.frame.frameHeight)
	frame.totalEvents = math.floor((frame:GetHeight() - (2 * backdrop.insets.top) - frame.anchor:GetHeight() - prev:GetHeight() ) / Cascade.db.profile.frame.frameHeight)
	
	-- Insert all the event frames into the cache.
	for i = #frame.eventFrames, frame.totalEvents + 1, -1 do
		local f = tremove(frame.eventFrames, i)
		if f then
			f:CleanFrame()
			f:Hide()
			tinsert(frameCache, f)
		end
	end
	
	for i = 1, frame.totalEvents do
		local f = frame.eventFrames[i] or getEventFrame()
		f:Show()
		f:ResizeFrame(Cascade.db.profile.frame.frameHeight)
		frame.eventFrames[i] = f

		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", prev, "BOTTOMLEFT")
		f:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT")
		
		prev = f
	end
	
	-- Set Minimum resize for the frame. If the frame is smaller than that, resize it.
	local minWidth = textWidth * 4
	frame:SetMinResize(minWidth, 74)
	if frame:GetWidth() < minWidth then frame:SetWidth(minWidth) end
	
	if frame:IsVisible() then self:ShowHistory() end
end

-- Get the next event frame from the cache. If the cache is empty, create a new frame.
function getEventFrame()
	local f = tremove(frameCache)
	if f then return f end
	
	f = CreateFrame("Frame", nil, frame)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetBackdrop(highlight)
	f:SetBackdropColor(0, 0, 0, 0)
	
	f.CleanFrame = cleanEventFrame
	f.ResizeFrame = resizeEventFrame
		
	f.icon = f:CreateTexture(nil, "OVERLAY")
	f.icon:SetTexCoord(.1, .9, .1, .9)
	f.icon:SetPoint("LEFT")
	
	f.name = f:CreateFontString(nil, "OVERLAY")
	f.name:SetFontObject(CascadeFont)
	f.name:SetJustifyH("LEFT")
	
	f.crit = CreateFrame("Frame", nil, f)
	f.crit.hitType = 2
	f.crit.text = f:CreateFontString(nil, "OVERLAY")
	f.crit.text:SetFontObject(CascadeFont)
	f.crit.text:SetJustifyH("RIGHT")
	f.crit.text:SetAllPoints(f.crit)
	f.crit:SetPoint("TOPRIGHT")
	f.crit:SetPoint("BOTTOMRIGHT")
	
	f.hit = CreateFrame("Frame", nil, f)
	f.hit.hitType = 1
	f.hit.text = f:CreateFontString(nil, "OVERLAY")
	f.hit.text:SetFontObject(CascadeFont)
	f.hit.text:SetJustifyH("RIGHT")
	f.hit.text:SetAllPoints(f.hit)
	f.hit:SetPoint("TOPRIGHT", f.crit, "TOPLEFT")
	f.hit:SetPoint("BOTTOMRIGHT", f.crit, "BOTTOMLEFT")

	f.name:SetPoint("TOPLEFT", f.icon, "TOPRIGHT")
	f.name:SetPoint("BOTTOMRIGHT", f.hit, "BOTTOMLEFT")

	f.hit:RegisterForDrag("LeftButton")
	f.crit:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", frame.startMoving)
	f:SetScript("OnDragStop", frame.stopMoving)
	f.hit:SetScript("OnDragStart", frame.startMoving)
	f.hit:SetScript("OnDragStop", frame.stopMoving)
	f.crit:SetScript("OnDragStart", frame.startMoving)
	f.crit:SetScript("OnDragStop", frame.stopMoving)

	f.hit:EnableMouse()
	f.crit:EnableMouse()
	f.hit:SetScript("OnEnter", onEnter)
	f.crit:SetScript("OnEnter", onEnter)
	f:SetScript("OnEnter", onEnter)
	
	f.hit:SetScript("OnLeave", onLeave)
	f.crit:SetScript("OnLeave", onLeave)
	f:SetScript("OnLeave", onLeave)
	
	f.hit:SetScript("OnMouseUp", onClick)
	f.crit:SetScript("OnMouseUp", onClick)
	f:SetScript("OnMouseUp", onClick)
	
	return f
end

-- Clean the event frame back to near default state.
function cleanEventFrame(f)
	f.name:SetText()
	f.hit.text:SetText()
	f.crit.text:SetText()
	f.icon:SetTexture()
	f:SetBackdropColor(0, 0, 0, 0)
	f.hit_msg, f.crit_msg = nil, nil
	--f.hit_msgClean, f.crit_msgClean = nil, nil
end

-- Resize an event frame to a given size.
function resizeEventFrame(f, size)
	f:SetHeight(size)
	f.icon:SetHeight(size)
	f.icon:SetWidth(size)
	f.hit:SetWidth(textWidth)
	f.crit:SetWidth(textWidth)
end

function onEnter(self)
	if Cascade.db.profile.frame.tooltipAnchor == "NONE" then return end
	local hitType = self.hitType
	local f = hitType and self:GetParent() or self
	if not f then return end
	
	local msg
	if hitType == 1 then
		msg = f.hit_msg
	elseif hitType == 2 then
		msg = f.crit_msg
	end
	if not msg then
		local hit, crit = f.hit_msg, f.crit_msg
		if hit and crit then
			msg = hit .. "\n\n" .. crit
		else
			msg = hit or crit
		end
	end
	
	if not msg then return end
	
	f:SetBackdropColor(1, 1, 1, 0.33)
	GameTooltip:SetOwner(f, Cascade.db.profile.frame.tooltipAnchor)
	GameTooltip:SetText(msg, Cascade.db.profile.colors.misc.text.r, Cascade.db.profile.colors.misc.text.g, Cascade.db.profile.colors.misc.text.b, 1, 1)
end

function onLeave(self)
	GameTooltip:Hide()
	local f = (self.hitType and self:GetParent() or self)
	f:SetBackdropColor(0, 0, 0, 0)
end

function onClick(self, button)
	local hitType = self.hitType
	local f = hitType and self:GetParent() or self
	
	if IsShiftKeyDown() then
		if hitType == 2 then
			Cascade:Announce(f.crit_msg)
		elseif hitType == 1 then
			Cascade:Announce(f.hit_msg)
		elseif button == "RightButton" then
			Cascade:Announce(f.crit_msg)
		else
			Cascade:Announce(f.hit_msg)
		end
	elseif button == "RightButton" then
		-- Check for OnMouseUp bug. Apparently only bugs on right click.
		if GetMouseFocus() ~= self then return end
		showRightClickMenu(f)
	end
end

-------------------------------------------------------------------------------
-- Whenever the font is changed, update the textWidth
-------------------------------------------------------------------------------
function history:OnFontChanged()
	if not frame then return end
	if not hiddenFontString then
		hiddenFontString = frame:CreateFontString(nil, "OVERLAY")
		hiddenFontString:SetFontObject(CascadeFont)
		hiddenFontString:SetText(sampleFontWidth)
		hiddenFontString:Hide()
	end
	textWidth = hiddenFontString:GetStringWidth() + 5
	self:CreateEventFrames()
end

-------------------------------------------------------------------------------
-- Reset history information
-------------------------------------------------------------------------------
function history:ResetHistory(key)
	if key and db[key] then
		wipe(db[key])
	else
		for k, v in pairs(db) do wipe(v) end
	end
	self:UpdateAllEvents()
end

--------------------------------------
---------------Dropdown---------------
--------------------------------------
local menu
local dropdown = CreateFrame("Frame", "CascadeHistoryDropdownMenu")
dropdown.displayMode = "MENU"

dropdown.initialize = function(frame, level, menuList)
	if not level then return end
	if level == 1 then
		if menu.hit.arg1 then
			UIDropDownMenu_AddButton(menu.hit, level)
		end
		if menu.crit.arg1 then
			UIDropDownMenu_AddButton(menu.crit, level)
		end
		if menu.spell.arg1 then
			UIDropDownMenu_AddButton(menu.spell, level)
		end
		if menu.spell2.arg1 then
			UIDropDownMenu_AddButton(menu.spell2, level)
		end
		UIDropDownMenu_AddButton(menu.spacer, level)
		UIDropDownMenu_AddButton(menu.delete, level)
	end
end

menu = {
	hit = {
		text = L["Link Hit"],
		notCheckable = true,
		func = Cascade.Announce,
	},
	crit = {
		text = L["Link Crit"],
		notCheckable = true,
		func = Cascade.Announce,
	},
	spell = {
		text = L["Link Hit Spell"],
		notCheckable = true,
		func = Cascade.Announce,
		arg2 = true,
	},
	spell2 = {
		text = L["Link Crit Spell"],
		notCheckable = true,
		func = Cascade.Announce,
		arg2 = true,
	},
	delete = {
		text = L["Delete Spell"],
		notCheckable = true,
		func = function(self, spell, key) db[key][spell] = nil history:UpdateAllEvents() end,
	},
	spacer = {
		text = "",
		disabled = true,
		notCheckable = true,
	},
}

function showRightClickMenu(f)
	menu.hit.arg1 = f.hit_msg
	menu.crit.arg1 = f.crit_msg

	local id = f.hit_msg and select(3, string_find(f.hit_msg, "|Hspell:(%d+).-|h.-|h"))
	local id2 = f.crit_msg and select(3, string_find(f.crit_msg, "|Hspell:(%d+).-|h.-|h"))
	if id == id2 or not id or not id2 then
		id = id or id2
		id2 = nil
		menu.spell.text = L["Link Spell"]
	else
		menu.spell.text = L["Link Hit Spell"]
	end
	menu.spell.arg1 = id and GetSpellLink(id) or nil
	menu.spell2.arg1 = id2 and GetSpellLink(id2) or nil

	menu.delete.arg2 = display
	menu.delete.arg1 = f.name:GetText()
	
	ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end
