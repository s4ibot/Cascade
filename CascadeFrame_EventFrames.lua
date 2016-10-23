

local frame
local frameCache = {}

local L = LibStub("AceLocale-3.0"):GetLocale("Cascade")

local highlight = {bgFile = "Interface/QuestFrame/UI-QuestTitleHighlight", insets = {left = 1, right = 1, top = 1, bottom = 1}}

local GetMouseFocus = GetMouseFocus
local IsShiftKeyDown = IsShiftKeyDown
local string_find = string.find

-------------------------------------------------------------------
--------------------------- Event Frames --------------------------
-------------------------------------------------------------------

-- Local event frame methods
local getEventFrame, cleanEventFrame, resizeEventFrame, onEnter, onLeave, onClick, showRightClickMenu

-------------------------------------------------------------------------------
-- Create all the event frames
-------------------------------------------------------------------------------
function Cascade:CreateEventFrames()
	frame = frame or self.Frame
	
	local prev = self:CreateLabels()
	local inset = self.backdrop.insets.left + 1
	local vertOffset = inset -- Vertical offset. Will be different from inset variable if we scroll the opposite direction.

	-- Determine how many frames we need to show
	frame.totalEvents = math.floor((frame:GetHeight() - (2 * inset) - (prev and prev:GetHeight() or 0)) / self.db.profile.frame.frameHeight)
	
	-- Insert any extra event frames into the cache.
	for i = #frame.eventFrames, frame.totalEvents + 1, -1 do
		local f = tremove(frame.eventFrames, i)
		if f then
			f:CleanFrame()
			f:Hide()
			tinsert(frameCache, f)
		end
	end
	
	-- Determine where to anchor the first frame.
	local TOP, BOTTOM
	if self.db.profile.frame.reverseScrollDir then
		TOP, BOTTOM = "BOTTOM", "TOP"
	else
		TOP, BOTTOM = "TOP", "BOTTOM"
		vertOffset = - inset
	end
	
	-- Anchor the labels if they exist
	if prev then
		prev:ClearAllPoints()
		prev:SetPoint(TOP.."LEFT", inset, vertOffset)
		prev:SetPoint(TOP.."RIGHT", -inset, vertOffset)
	end
	
	-- Anchor the remaining event frames
	for i = 1, frame.totalEvents do
		local f = frame.eventFrames[i] or getEventFrame()
		f:Show()
		f:ResizeFrame(self.db.profile.frame.frameHeight)
		frame.eventFrames[i] = f

		f:ClearAllPoints()
		if not prev then
			f:SetPoint(TOP.."LEFT", inset, vertOffset)
			f:SetPoint(TOP.."RIGHT", -inset, vertOffset)
		else
			f:SetPoint(TOP.."LEFT", prev, BOTTOM.."LEFT")
			f:SetPoint(TOP.."RIGHT", prev, BOTTOM.."RIGHT")
		end
		prev = f
	end

	self:AutoUpdateFontSize()
	self:UpdateAllEvents()
end

-------------------------------------------------------------------------------
-- Automatically update the font size whenever frameHeight is changed
-------------------------------------------------------------------------------
function Cascade:AutoUpdateFontSize()
	if self.db.profile.frame.overrideFontSize then return end
	self.db.profile.frame.fontSize = self.db.profile.frame.frameHeight - 2
	self:SetFont()
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
	
	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetFontObject(CascadeFont)
	
	f.leftIcon = f:CreateTexture(nil, "OVERLAY")
	f.leftIcon:SetTexCoord(.1, .9, .1, .9)
	f.leftIcon:SetPoint("LEFT")

	f.rightIcon = f:CreateTexture(nil, "OVERLAY")
	f.rightIcon:SetTexCoord(.1, .9, .1, .9)
	f.rightIcon:SetPoint("RIGHT")
	
	f.text:SetPoint("LEFT", f.leftIcon, "RIGHT", 5, 0)
	f.text:SetPoint("RIGHT", f.rightIcon, "LEFT", -5, 0)
	
	f:SetScript("OnEnter", onEnter)
	f:SetScript("OnLeave", onLeave)
	f:SetScript("OnMouseUp", onClick)
	f:SetScript("OnDragStart", frame.startMoving)
	f:SetScript("OnDragStop", frame.stopMoving)
	
	return f
end

-- Clean the event frame back to near default state.
function cleanEventFrame(f)
	f.text:SetText()
	f.leftIcon:SetTexture()
	f.rightIcon:SetTexture()
	f.spellID = nil
	f.tooltipText = nil
	f.tooltipTextClean = nil
	f:SetBackdropColor(0, 0, 0, 0)
end

-- Resize an event frame to a given size.
function resizeEventFrame(f, size)
	f:SetHeight(size)
	f.leftIcon:SetHeight(size)
	f.leftIcon:SetWidth(size)
	f.rightIcon:SetHeight(size)
	f.rightIcon:SetWidth(size)
end

function onEnter(self)
	frame:onEnter()
	if not self.tooltipText then return end
	if Cascade.db.profile.frame.tooltipAnchor == "NONE" then return end
	GameTooltip:SetOwner(self, Cascade.db.profile.frame.tooltipAnchor)
	GameTooltip:SetText(self.tooltipText, Cascade.db.profile.colors.misc.text.r, Cascade.db.profile.colors.misc.text.g, Cascade.db.profile.colors.misc.text.b, 1, 1)
	self:SetBackdropColor(1, 1, 1, 0.33)
end

function onLeave(self)
	frame:onLeave()
	GameTooltip:Hide()
	self:SetBackdropColor(0, 0, 0, 0)
end

function onClick(self, button)
	if IsShiftKeyDown() then
		Cascade:Announce(self.tooltipText)
	elseif button == "LeftButton" and self.spellID then
		ShowUIPanel(ItemRefTooltip)
		ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		ItemRefTooltip:SetHyperlink(GetSpellLink(self.spellID))
	elseif button == "RightButton" then
		-- Check for OnMouseUp bug. Apparently only bugs on right click.
		if GetMouseFocus() ~= self then return end
		showRightClickMenu(self)
	end
end

--------------------------------------
---------------Dropdown---------------
--------------------------------------

local menu
local dropdown = CreateFrame("Frame", "CascadeDropdownMenu")
dropdown.displayMode = "MENU"

dropdown.initialize = function(frame, level, menuList)
	if not level then return end
	if level == 1 then
		if menu.link.arg1 then
			UIDropDownMenu_AddButton(menu.link, level)
		end
		if menu.linkClean.arg1 then
			UIDropDownMenu_AddButton(menu.linkClean, level)
		end
		if menu.spell.arg1 then
			UIDropDownMenu_AddButton(menu.spell, level)
		end
	end
end

menu = {
	link = {
		text = L["Link Event"],
		notCheckable = true,
		func = Cascade.Announce,
	},
	linkClean = {
		text = L["Link Clean Event"],
		notCheckable = true,
		func = Cascade.Announce,
	},
	spell = {
		text = L["Link Spell"],
		notCheckable = true,
		func = Cascade.Announce,
		arg2 = true,
	},
}

function showRightClickMenu(f)
	menu.link.arg1 = f.tooltipText
	if not f.tooltipText or f.tooltipText == "" or string_find(f.tooltipText, "^|c%w%w%w%w%w%w%w%w[%d:/%s]+|r\n$") then
		menu.link.disabled = true
	else
		menu.link.disabled = nil
	end
	
	menu.linkClean.arg1 = f.tooltipTextClean
	menu.spell.arg1 = f.spellID and GetSpellLink(f.spellID) or nil
	
	ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end

