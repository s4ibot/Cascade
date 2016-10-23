
--
-- Cascade - Compact Combat Log Addon
-- 		Written by Turkleton
--
-- Version: 1.0.1-4-gec33f67


Cascade = LibStub("AceAddon-3.0"):NewAddon("Cascade", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Cascade")

local media = LibStub("LibSharedMedia-3.0", true)

-- Positions where messages are displayed
local INCOMING, OUTGOING = -2, 2
local INCOMING_MID, OUTGOING_MID = -1, 1
local NOTIFICATION = 0

-- Local variables for calculating DPS, HPS, DPS in, and HPS in
local enteredCombat, dmgIn, dmgOut, healIn, healOut = 0, 0, 0, 0, 0

-- Character flags for crits/crushing blows etc.
local plusChar = "+"
local minusChar = "-"
local critChar = "*"
local crushChar = "^"
local deathChar = "\226\128\160"
local glanceChar = "~"
local newHighChar = "|cFFFFFF00!|r"
local summarySep = " || "
local overhealFormat = "%d <%d>"
local absorbedFormat = "%s (%d)"
local blockedFormat = "%s (%d)"
local resistedFormat = "%s (%d)"
local timestampFormat = "%1: "

-- Reflect information
local REFLECT_TIME = 3
local SPELL_REFLECT_NAME = GetSpellInfo(23920)
local reflectTable, reflectTimes = {}, {}

-- Local upvalues
local _G = getfenv(0)
local CombatLog_Object_IsA, CombatLog_OnEvent = CombatLog_Object_IsA, CombatLog_OnEvent
local CombatLog_String_PowerType = CombatLog_String_PowerType
local string_find, string_format, string_gsub = string.find, string.format, string.gsub
local GetSpellInfo, GetSpellLink, GetTime = GetSpellInfo, GetSpellLink, GetTime
local UnitGUID = UnitGUID
local bit_band = bit.band
local select = select
local ceil = math.ceil

local Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_CurrentSettings
local ENTERING_COMBAT, LEAVING_COMBAT = ENTERING_COMBAT, LEAVING_COMBAT
local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK
local COMBATLOG_FILTER_ME = COMBATLOG_FILTER_ME
local COMBATLOG_FILTER_MINE = COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = COMBATLOG_FILTER_MY_PET

local INTERRUPT, INTERRUPTED, RESIST = INTERRUPT, INTERRUPTED, RESIST
local DURABILITY, DURABILITY_ABBR = DURABILITY, DURABILITY_ABBR
local DURABILITYDAMAGE_DEATH = DURABILITYDAMAGE_DEATH
local HONOR, XP = HONOR, XP

local UNKNOWN_COLOR = {r = 1, g = 0, b = 0}

-- Local functions
local abbreviate, suppressEvent
-- Local reference to history module
local history

-- Create search patterns for honor, reputation, experience, and skill ups.
local getPattern = function(i) return string_gsub(string_gsub(string_gsub(i, "([%(%)])", "%%%1"), "%%%d?%$?s", "(.+)"), "%%%d?%$?d", "(%%d+)") end

local COMBATLOG_HONORGAIN = getPattern(COMBATLOG_HONORGAIN)
local COMBATLOG_HONORAWARD = getPattern(COMBATLOG_HONORAWARD)
local COMBATLOG_HONORGAIN_NO_RANK = getPattern(COMBATLOG_HONORGAIN_NO_RANK)
local FACTION_STANDING_INCREASED = getPattern(FACTION_STANDING_INCREASED)
local FACTION_STANDING_DECREASED = getPattern(FACTION_STANDING_DECREASED)
local COMBATLOG_XPGAIN_FIRSTPERSON = getPattern(COMBATLOG_XPGAIN_FIRSTPERSON)
local COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = getPattern(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED)
local ERR_ZONE_EXPLORED_XP = getPattern(ERR_ZONE_EXPLORED_XP)
local SKILL_RANK_UP = getPattern(SKILL_RANK_UP)


local db
local defaults = {
	profile = {
		--eventCacheSize = nil,
		includeSpellLinks = true,
		trackHistory = true,
		timestamp = true,
		milliseconds = false,
		colors = {
			spell = {
				bySchool = true,
				[SCHOOL_MASK_PHYSICAL] = {r = 1, g = 1, b = 1},
				[SCHOOL_MASK_ARCANE] = {r = 1, g = 0.725, b = 1},
				[SCHOOL_MASK_FIRE] = {r = 1, g = 0.5, b = 0.5},
				[SCHOOL_MASK_FROST] = {r = 0.5, g = 0.5, b = 1},
				[SCHOOL_MASK_HOLY] = {r = 1, g = 1, b = .627},
				[SCHOOL_MASK_NATURE] = {r = 0.5, g = 1, b = 0.5},
				[SCHOOL_MASK_SHADOW] = {r = 0.628, g = 0, b = 0.628},
			},
			incoming = {
				hit = {r = 1, g = 0, b = 0},
				heal = {r = 0, g = 1, b = 0},
				miss = {r = 0, g = 0, b = 1},
				spell = {r = 1, g = 1, b = 0},
				power = {r = 1, g = 1, b = 0},
				buffs = {r = .7, g = .7, b = 0},
				debuffs = {r = .7, g = 0, b = 0},
			},
			outgoing = {
				hit = {r = 1, g = 1, b = 1},
				heal = {r = 0, g = 1, b = 0},
				miss = {r = 1, g = 1, b = 1},
				spell = {r = 1, g = 1, b = 0},
			},
			misc = {
				frame = {r = 0, g = 0, b = 0, a = .3},
				border = {r = 1, g = 1, b = 1, a = 1},
				text = {r = 1, g = 1, b = 0},
				combat = {r = 1, g = 1, b = 1},
				death = {r = .5, g = .5, b = .5},
				experience = {r = 0.5, g = 0.7, b = 0.5},
				honor = {r = 0.7, g = 0.5, b = 0.7},
				info = {r = .3, g = .3, b = 1},
				interrupt = {r = 1, g = 1, b = 0},
				reputation = {r = 0.5, g = 0.5, b = 1},
			},
		},
		frame = {
			locked = false,
			clampToScreen = true,
			showLabels = true,
			flipEventSides = false,
			reverseScrollDir = false,
			frameHeight = 16,
			--font = nil,
			fontSize = 14,
			overrideFontSize = false,
			petOffset = 20,
			petAlpha = .40,
			tooltipAnchor = "ANCHOR_TOPRIGHT",

			-- Appearance
			Strata = "LOW",
			bgTexture = "Solid",
			borderTexture = "None",
			alpha = 1,
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			inset = 4,
			
			fadeDelay = 10,
			fadeOutOfCombat = false,
		},
		events = {
			PET = false,
			VEHICLE = true,
			BUFF_GAINS = true,
			BUFF_FADES = false,
			DEBUFF_GAINS = true,
			DEBUFF_FADES = false,
			POWER = true,
			OVERHEALING = false,
			DURABILITY = true,
			EXPERIENCE = true,
			HONOR = true,
			REPUTATION = true,
			SKILLUPS = true,
			DISPELS = true,
			INTERRUPTS = true,
			KILLS = true,
			COMBAT = true,
			COMBAT_SUMMARY = true,
		},
		spamControl = {
			blacklistSpells = {},
			DAMAGE = 0, HEAL = 0, POWER = 0,
			abbreviate = (GetLocale() == "enUS" or GetLocale == "enGB"), -- Abbreviate is disabled by default for non english locales
			buffFilter = 6, -- 0110 filter party/raid
			debuffFilter = 0, -- 0000 filter none
		},
	},
}

-- Blend multi-school spells into one color such as Frostfire or Shadowfrost
local BLENDED_COLORS = setmetatable({}, {__index = function(t, school)
	if db.colors.spell[school] then return db.colors.spell[school] end
	local r, g, b, count = 0, 0, 0, 0
	for k, v in pairs(COMBATLOG_DEFAULT_COLORS.schoolColoring) do
		if db.colors.spell[k] and bit_band(school, k) > 0 then
			count = count + 1
			r = r + db.colors.spell[k].r
			g = g + db.colors.spell[k].g
			b = b + db.colors.spell[k].b
		end
	end
	
	local c
	if count > 0 then
		c = {r = r / count, g = g / count, b = b / count}
	else
		c = {r = UNKNOWN_COLOR.r, g = UNKNOWN_COLOR.g, b = UNKNOWN_COLOR.b}
	end
	return c
end})
Cascade.BLENDED_COLORS = BLENDED_COLORS

local COMBAT_EVENT_TYPES = {
	-- Damage events.
	SWING_DAMAGE = "DAMAGE",
	RANGE_DAMAGE = "DAMAGE",
	SPELL_DAMAGE = "DAMAGE",
	SPELL_PERIODIC_DAMAGE = "DAMAGE",
	SPELL_BUILDING_DAMAGE = "DAMAGE",
	--SPELL_PERIODIC_BUILDING_DAMAGE = "DAMAGE", -- No spells like this exist?
	DAMAGE_SHIELD = "DAMAGE",
	ENVIRONMENTAL_DAMAGE = "DAMAGE",
	DAMAGE_SPLIT = "DAMAGE",

	-- Heal events.
	SPELL_HEAL = "HEAL",
	SPELL_PERIODIC_HEAL = "HEAL",

	-- Miss events.
	SWING_MISSED = "MISS",
	RANGE_MISSED = "MISS",
	SPELL_MISSED = "MISS",
	SPELL_PERIODIC_MISSED = "MISS",
	DAMAGE_SHIELD_MISSED = "MISS",

	-- Power events.
	SPELL_ENERGIZE = "POWER",
	SPELL_PERIODIC_ENERGIZE = "POWER", -- Judgement of Wisdom, Replenishment, Innervate, Divine Plea
	SPELL_LEECH = "POWER",
	SPELL_PERIODIC_LEECH = "POWER", -- Drain Mana, Viper Sting
	
	-- Drain events.
	SPELL_DRAIN = "POWER",
	SPELL_PERIODIC_DRAIN = "POWER",

	-- Interrupt events.
	SPELL_INTERRUPT = "INTERRUPT",

	-- Aura events.
	SPELL_AURA_APPLIED = "AURA_APPLIED",
	SPELL_AURA_REMOVED = "AURA_REMOVED",
	--SPELL_AURA_REFRESH = "AURA_APPLIED",
	--SPELL_AURA_APPLIED_DOSE = "AURA_APPLIED", -- Stacking buffs/debuffs
	--SPELL_AURA_REMOVED_DOSE = "AURA_REMOVED",

	-- Enchant events.
	ENCHANT_APPLIED = "ENCHANT_APPLIED",
	ENCHANT_REMOVED = "ENCHANT_REMOVED",

	-- Dispel events.
	SPELL_DISPEL = "DISPEL",
	SPELL_STOLEN = "DISPEL",
	SPELL_DISPEL_FAILED = "DISPEL_FAILED",

	-- Kill events.
	PARTY_KILL = "KILL",
	UNIT_DIED = "KILL",
}



function Cascade:OnInitialize()
	history = self:GetModule("History", true)
	-- Initialize our DB
	self.db = LibStub("AceDB-3.0"):New("CascadeDB", defaults, true)
	db = self.db.profile
	
	-- Default font settings copied from GameFontHighlightSmall
	local font = CreateFont("CascadeFont")
	font:SetFont(GameFontHighlightSmall:GetFont())
	font:SetShadowOffset(GameFontHighlightSmall:GetShadowOffset())
	font:SetShadowColor(GameFontHighlightSmall:GetShadowColor())

	-- CALLBACKS - http://www.wowace.com/projects/ace3/pages/ace-db-3-0-tutorial/
	self.db.RegisterCallback(self, "OnProfileChanged", "RestoreProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "RestoreProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "RestoreProfile")
end

function Cascade:OnEnable()
	-- Pull user font settings
	self:SetFont()
	
	-- Create the frame
	self:CreateFrame()
	
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN")
	self:FilterCombatEvents()
end

-------------------------------------------------------------------------------
-- Called when a profile is changed and needs to be refreshed.
-------------------------------------------------------------------------------
function Cascade:RestoreProfile(callback, database)
	wipe(BLENDED_COLORS)
	db = database.profile

	self:SetFont()
	self:CreateFrame()
	self:FilterCombatEvents()
	if history and history.Frame then history.Frame:Hide() end
end

-------------------------------------------------------------------------------
-- Updates the events that are being filtered by COMBAT_LOG_EVENT_UNFILTERED
-------------------------------------------------------------------------------
function Cascade:FilterCombatEvents()
	if db.events.POWER then
		COMBAT_EVENT_TYPES["SPELL_ENERGIZE"] = "POWER"
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_ENERGIZE"] = "POWER"
		COMBAT_EVENT_TYPES["SPELL_LEECH"] = "POWER"
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_LEECH"] = "POWER"
		COMBAT_EVENT_TYPES["SPELL_DRAIN"] = "POWER"
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_DRAIN"] = "POWER"
	else
		COMBAT_EVENT_TYPES["SPELL_ENERGIZE"] = nil
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_ENERGIZE"] = nil
		COMBAT_EVENT_TYPES["SPELL_LEECH"] = nil
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_LEECH"] = nil
		COMBAT_EVENT_TYPES["SPELL_DRAIN"] = nil
		COMBAT_EVENT_TYPES["SPELL_PERIODIC_DRAIN"] = nil
	end
	
	if db.events.KILLS then
		COMBAT_EVENT_TYPES["PARTY_KILL"] = "KILL"
		COMBAT_EVENT_TYPES["UNIT_DIED"] = "KILL"
	else
		COMBAT_EVENT_TYPES["PARTY_KILL"] = nil
		COMBAT_EVENT_TYPES["UNIT_DIED"] = nil
	end
	
	if db.events.INTERRUPTS then
		COMBAT_EVENT_TYPES["SPELL_INTERRUPT"] = "INTERRUPT"
	else
		COMBAT_EVENT_TYPES["SPELL_INTERRUPT"] = nil
	end
	
	if db.events.DISPELS then
		COMBAT_EVENT_TYPES["SPELL_DISPEL"] = "DISPEL"
		COMBAT_EVENT_TYPES["SPELL_STOLEN"] = "DISPEL"
		COMBAT_EVENT_TYPES["SPELL_DISPEL_FAILED"] = "DISPEL_FAILED"
	else
		COMBAT_EVENT_TYPES["SPELL_DISPEL"] = nil
		COMBAT_EVENT_TYPES["SPELL_STOLEN"] = nil
		COMBAT_EVENT_TYPES["SPELL_DISPEL_FAILED"] = nil
	end
	
	-- Durability --
	if db.events.DURABILITY then
		self:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO")
	else
		self:UnregisterEvent("CHAT_MSG_COMBAT_MISC_INFO")
	end

	-- Honor --
	if db.events.HONOR then
		self:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
	else
		self:UnregisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
	end
	
	-- Reputation --
	if db.events.REPUTATION then
		self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	else
		self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	end
	
	-- Experience --
	if db.events.EXPERIENCE then
		self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
		self:RegisterEvent("CHAT_MSG_SYSTEM", "CHAT_MSG_COMBAT_XP_GAIN")
	else
		self:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
	end
	
	-- Skillups --
	if db.events.SKILLUPS then
		self:RegisterEvent("CHAT_MSG_SKILL")
	else
		self:UnregisterEvent("CHAT_MSG_SKILL")
	end
end

-------------------------------------------------------------------------------
-- Parse combat log events.
-------------------------------------------------------------------------------
function Cascade:COMBAT_LOG_EVENT_UNFILTERED(e, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	-- First, check if the event is one we should show.
	if not COMBAT_EVENT_TYPES[event] then return end
	
	-- Check for reflect damage. Based on MSBT's reflect code.
	local reflect
	if sourceGUID == destGUID and event == "SPELL_DAMAGE" then
		local id = ...
		if reflectTable[sourceGUID] == id then
			-- Clear old reflect data.
			reflectTable[sourceGUID] = nil
			reflectTimes[sourceGUID] = nil

			-- Parse reflect here.
			sourceGUID = UnitGUID("player")
			sourceName = UnitName("player")
			sourceFlags = COMBATLOG_FILTER_ME
			
			-- Flag this event as a spell reflect event, for tracking purposes.
			reflect = SPELL_REFLECT_NAME
		end
	end
	
	-- Check if the player, a pet, or vehicle is involved.
	local playerOut = CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE)
	local playerIn = CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE)
	local petOut = CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)
	local petIn = CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MY_PET)

	if not (playerIn or playerOut or petIn or petOut) then return end
	
	-- Handle pet events
	if (petIn or petOut) and not (playerIn or playerOut) then
		--if not (db.events.VEHICLE or db.events.PET) then return end
		local vehicleGUID = UnitGUID("vehicle")
		local vehicle = vehicleGUID and (vehicleGUID == sourceGUID or vehicleGUID == destGUID)

		-- If in a vehicle and vehicle events are disabled, stop
		if vehicle and not db.events.VEHICLE then return end
		-- If pets are disabled and not in a vehicle (pet event)
		if not db.events.PET and not vehicle then
			-- If pet is interrupting or dispelling (outgoing only) show the event, regardless of whether or not pet events are enabled.
			if (event == "SPELL_INTERRUPT" or event == "SPELL_DISPEL" or event == "SPELL_DISPEL_FAILED") and petOut then
				playerOut = true
			else
				return
			end
		end
		playerIn = (petIn and vehicle)
		playerOut = playerOut or (petOut and vehicle)
	end
	
	-------------------
	-- Start parsing --
	-------------------

	local eventType = COMBAT_EVENT_TYPES[event]

	local text, location, color, icon, message, messageClean -- messageClean is the combat message without overkill/overheal
	
	local incoming = (playerIn or petIn)
	local outgoing = (playerOut or petOut)

	-- Figure out where the message is going.
	location = (playerIn and INCOMING) or (playerOut and OUTGOING) or (petIn and INCOMING_MID) or (petOut and OUTGOING_MID) or NOTIFICATION
	
	-- prefixes RANGE, SPELL, SPELL_PERIODIC, SPELL_BUILDING
	local spellID, spellName, spellSchool
	--prefix ENVIRONMENTAL
	local environmentalType
	--prefix AURA
	local auraType
	
	-- suffix _DAMAGE
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing
	-- suffix _HEAL
	local overheal
	-- suffix _MISSED
	local missType, amountMissed
	-- suffix _DISPEL_FAILED, _INTERRUPT
	--local extraSpellID, extraSpellName, extraSchool
	-- suffixes _ENERGIZE, _DRAIN, _LEECH
	--local powerType, extraAmount
	local extraSpellID, powerType, alternatePowerType, extraAmount
	
	-- DAMAGE --
	if eventType == "DAMAGE" then
		if event == "SWING_DAMAGE" then
            amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...)
			if overkill and overkill > 0 then
				messageClean = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amount, 0, school, resisted, blocked, absorbed, critical, glancing, crushing)
			end
		elseif event == "ENVIRONMENTAL_DAMAGE" then
            environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...)
			if overkill and overkill > 0 then
				messageClean = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, environmentalType, amount, 0, school, resisted, blocked, absorbed, critical, glancing, crushing)
            end
		else
            spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...)
			if overkill and overkill > 0 then
				messageClean = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, amount, 0, school, resisted, blocked, absorbed, critical, glancing, crushing)
			end
		end
		
		-- EavesDrop color style
		if school ~= SCHOOL_MASK_PHYSICAL and db.colors.spell.bySchool then
			color = db.colors.spell[school] or db.colors.spell[0] or BLENDED_COLORS[school]
		elseif spellID and school == SCHOOL_MASK_PHYSICAL then
			color = incoming and db.colors.incoming.hit or db.colors.outgoing.spell
		elseif incoming then
			color = spellID and db.colors.incoming.spell or db.colors.incoming.hit
		else
			color = spellID and db.colors.outgoing.spell or db.colors.outgoing.hit
		end

		text = amount

		if incoming then
			if not petIn then dmgIn = dmgIn + amount end
		else
			dmgOut = dmgOut + amount
		end
	
	-- HEALS --
	elseif eventType == "HEAL" then
		spellID, spellName, spellSchool, amount, overheal, absorbed, critical = ...
		
		color = incoming and db.colors.incoming.heal or db.colors.outgoing.heal
		
		if outgoing and not petOut then
			healOut = healOut + amount
		end
		if incoming and not petIn then
			healIn = healIn + amount
		end
		
		text = amount
		
		if overheal and overheal > 0 then
			if db.events.OVERHEALING then
				text = string_format(overhealFormat, amount - overheal, overheal)
			end
			messageClean = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, amount, 0, absorbed, critical)
		end
	
	-- MISSES --
	elseif eventType == "MISS" then
		if event == "SWING_MISSED" then
			missType, amountMissed = ...
		else
			spellID, spellName, spellSchool, missType, amountMissed = ...
		end

		-- Store information about reflects.
		if missType == "REFLECT" and playerIn then
			for k, v in pairs(reflectTimes) do
				if (timestamp - v > REFLECT_TIME) then
					reflectTable[k] = nil
					reflectTimes[k] = nil
				end
			end
			reflectTable[sourceGUID] = spellID
			reflectTimes[sourceGUID] = timestamp
		end
		
		if incoming then
			color = db.colors.incoming.miss
		elseif spellID or missType == "IMMUNE" or missType == "ABSORB" or missType == "EVADE" or missType == "REFLECT" then
			color = db.colors.outgoing.spell
		else
			color = db.colors.outgoing.miss
		end
		
		text = _G[missType]
	
	-- POWER --
	elseif eventType == "POWER" then
		if not (playerIn or playerOut) then return end

		if (event == "SPELL_ENERGIZE" or event == "SPELL_PERIODIC_ENERGIZE") then
			amount, powerType, alternatePowerType = select(4, ...);
		else
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);
		end

		color = db.colors.incoming.power

		text = amount .. " " .. CombatLog_String_PowerType(powerType)
		
		if (event == "SPELL_ENERGIZE" or event == "SPELL_PERIODIC_ENERGIZE") then
			if not playerIn then return end
			text = plusChar..text
		else
			if playerIn then
				text = minusChar..text
			elseif playerOut then
				text = plusChar..text
			end
		end
	
	-- AURAS --
	elseif eventType == "AURA_APPLIED" then
		if not playerIn then return end
		spellID, spellName, spellSchool, auraType = ...
	
		if auraType == "BUFF" then
			if not db.events.BUFF_GAINS then return end
			color = db.colors.incoming.buffs
		else
			if not db.events.DEBUFF_GAINS then return end
			color = db.colors.incoming.debuffs
		end

		text = plusChar..abbreviate(spellName)
	elseif eventType == "AURA_REMOVED" then
		if not playerIn then return end
		spellID, spellName, spellSchool, auraType = ...

		if auraType == "BUFF" then
			if not db.events.BUFF_FADES then return end
			color = db.colors.incoming.buffs
		else
			if not db.events.DEBUFF_FADES then return end
			color = db.colors.incoming.debuffs
		end
		text = minusChar..abbreviate(spellName)
	elseif eventType == "ENCHANT_APPLIED" then
		if not playerIn then return end
		text = ...
		text = plusChar..abbreviate(string_gsub(text, "^[%+%-]", ""))
		color = db.colors.incoming.buffs
	elseif eventType == "ENCHANT_REMOVED" then
		if not playerIn then return end

		text = ...
		text = minusChar..abbreviate(string_gsub(text, "^[%+%-]", ""))
		color = db.colors.incoming.buffs
	
	-- DISPELS --
	elseif eventType == "DISPEL" then
		spellID, spellName, spellSchool = select(4, ...)

		if spellID then
			color = incoming and db.colors.incoming.spell or db.colors.outgoing.spell
		else
			color = incoming and db.colors.incoming.miss or db.colors.outgoing.miss
		end
		
		text = L.DISPELLED..abbreviate(spellName)
	elseif eventType == "DISPEL_FAILED" then
		spellID, spellName, spellSchool = select(4, ...)

		color = incoming and db.colors.incoming.spell or db.colors.outgoing.spell
		
		text = RESIST
	
	-- INTERRUPTS --
	elseif eventType == "INTERRUPT" then
		--spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = ...
		spellID, spellName, spellSchool, extraSpellID = ...
		color = db.colors.outgoing.spell
		text = incoming and INTERRUPTED or INTERRUPT
		if extraSpellID then spellID = extraSpellID end
	
	-- DEATHS --
	elseif event == "KILL" then
		if not (playerOut or (eventType == "UNIT_DIED" and playerIn)) then return end
		text = deathChar..destName..deathChar
		color = db.colors.misc.death
		location = NOTIFICATION
	end
	
	if not text then return end

	if spellID then icon = select(3, GetSpellInfo(spellID)) end
	
	-- Flags
	if critical then text = critChar..text..critChar end
	if crushing then text = crushChar..text..crushChar end
	if glancing then text = glanceChar..text..glanceChar end
	if resisted then text = string_format(resistedFormat, text, resisted) end
	if blocked then text = string_format(blockedFormat, text, blocked) end
	if eventType ~= "HEAL" and absorbed and absorbed > 0 then text = string_format(absorbedFormat, text, absorbed) end
	
	if eventType == "DAMAGE" and incoming and not outgoing then text = minusChar..text end
	if eventType == "HEAL" then text = plusChar..text end
	
	message = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

	-- History Tracking
	if db.trackHistory and history and (eventType == "DAMAGE" or eventType == "HEAL") and (playerIn or playerOut) then
		if (history:CheckHistory(eventType, CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE), playerOut, amount, reflect or spellName, school, icon, critical, message)) then
			text = newHighChar..text..newHighChar
		end		
	end

	-- Check if this event should be suppressed.
	if suppressEvent(event, eventType, incoming, outgoing, spellName, spellID, amount, auraType, sourceFlags, sourceRaidFlags, destFlags, destRaidFlags) then return end

	-- Send this event to CascadeFrame
	self:DisplayEvent(text, location, color.r, color.g, color.b, icon, spellID, message, messageClean)
end

-------------------------------------------------------------------------------
-- Check for Durability messages
-------------------------------------------------------------------------------
function Cascade:CHAT_MSG_COMBAT_MISC_INFO(event, msg)
	if msg ~= DURABILITYDAMAGE_DEATH then return end
	self:DisplayEvent(minusChar..(db.spamControl.abbreviate and DURABILITY_ABBR or DURABILITY), NOTIFICATION, db.colors.misc.info.r, db.colors.misc.info.g, db.colors.misc.info.b, nil, nil, msg)
end

-------------------------------------------------------------------------------
-- Handle honor gains
-------------------------------------------------------------------------------
function Cascade:CHAT_MSG_COMBAT_HONOR_GAIN(event, msg)
	local honor = select(5, string_find(msg, COMBATLOG_HONORGAIN)) or select(3, string_find(msg, COMBATLOG_HONORAWARD)) or select(4, string_find(msg, COMBATLOG_HONORGAIN_NO_RANK))
	if not honor then return end
	
	local color = db.colors.misc.honor
	self:DisplayEvent(plusChar..honor.." "..HONOR, NOTIFICATION, color.r, color.g, color.b, nil, nil, msg)
end

-------------------------------------------------------------------------------
-- Handle reputation gains/losses
-------------------------------------------------------------------------------
function Cascade:CHAT_MSG_COMBAT_FACTION_CHANGE(event, msg)
	local decreasing
	local faction, rep = select(3, string_find(msg, FACTION_STANDING_INCREASED))
	
	if not faction then
		decreasing = true
		faction, rep = select(3, string_find(msg, FACTION_STANDING_DECREASED))
	end

	if not rep then return end

	local color = db.colors.misc.reputation
	self:DisplayEvent((decreasing and minusChar or plusChar)..rep.." ".."("..faction..")", NOTIFICATION, color.r, color.g, color.b, nil, nil, msg)
end

-------------------------------------------------------------------------------
-- Handle experience gains
-------------------------------------------------------------------------------
function Cascade:CHAT_MSG_COMBAT_XP_GAIN(event, msg)
	local xp = select(4, string_find(msg, COMBATLOG_XPGAIN_FIRSTPERSON)) or select(3, string_find(msg, COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED))
				or select(4, string_find(msg, ERR_ZONE_EXPLORED_XP))
	if not xp then return end

	local color = db.colors.misc.experience
	self:DisplayEvent(plusChar..xp.." "..XP, NOTIFICATION, color.r, color.g, color.b, nil, nil, msg)
end

-------------------------------------------------------------------------------
-- Handle weapon/profession skill gains
-------------------------------------------------------------------------------
function Cascade:CHAT_MSG_SKILL(event, msg)
	local skill, amount = select(3, string_find(msg, SKILL_RANK_UP))
	if not skill then return end

	local color = db.colors.misc.info
	self:DisplayEvent(skill..": "..amount, NOTIFICATION, color.r, color.g, color.b, nil, nil, msg)
end

-- Convert RGB to a hex string
local RGBtoHEX = function(r, g, b)
	if type(r) == "table" then
		return string_format("|cFF%02x%02x%02x", ceil(r.r * 255), ceil(r.g * 255), ceil(r.b * 255))
	else
		return string_format("|cFF%02x%02x%02x", ceil(r * 255), ceil(g * 255), ceil(b * 255))
	end
end

local seconds_fmt = string_gsub(SECONDS, "^.+:(.+);$", "%1")
local minutes_fmt = string_gsub(MINUTES, "^.+:(.+);$", "%1")
minutes_fmt = "%1.0f " .. minutes_fmt:lower() .. " %1.0f " .. seconds_fmt:lower()
seconds_fmt = "%1.1f " .. seconds_fmt:lower()

-- Convert seconds into a more readable format.
local function SecondsToTimeDetail(t)
	if t < 60 then
		return string_format(seconds_fmt, t)
	else
		return string_format(minutes_fmt, t/60, t % 60)
	end
end

-- Shorten values
local function shortenValue(v)
	if v >= 1e7 then return string_format("%.1fm", v / 1e6)
	elseif v >= 1e6 then return string_format("%.2fm", v / 1e6)
	elseif v >= 1e5 then return string_format("%.0fk", v / 1000)
	elseif v >= 1e4 then return string_format("%.1fk", v / 1000)
	else return v
	end
end

-------------------------------------------------------------------------------
-- Handle entering and leaving combat
-------------------------------------------------------------------------------
local enteringCombatTag = plusChar..plusChar..plusChar
local leavingCombatTag = minusChar..minusChar..minusChar
function Cascade:PLAYER_REGEN(event)
	if event == "PLAYER_REGEN_DISABLED" then
		-- Entering Combat
		if db.events.COMBAT then
			self:DisplayEvent(enteringCombatTag..COMBAT..enteringCombatTag, NOTIFICATION, db.colors.misc.combat.r, db.colors.misc.combat.g, db.colors.misc.combat.b, nil, nil, ENTERING_COMBAT)
		end

		-- Reset tracking variables
		enteredCombat = GetTime()
		dmgIn, dmgOut, healIn, healOut = 0, 0, 0, 0
		
		-- Fading
		self:StopFading()
		self.inCombat = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- Leaving Combat
		if db.events.COMBAT then
			self:DisplayEvent(leavingCombatTag..COMBAT..leavingCombatTag, NOTIFICATION, db.colors.misc.combat.r, db.colors.misc.combat.g, db.colors.misc.combat.b, nil, nil, LEAVING_COMBAT)
		end
		if not db.events.COMBAT_SUMMARY then return end
		local duration = GetTime() - enteredCombat
		
		local msg = RGBtoHEX(db.colors.misc.combat) .. L.CombatEnded:format(SecondsToTimeDetail(duration)) ..
				"\n" .. RGBtoHEX(db.colors.incoming.hit) ..L.dmgIn:format(dmgIn, dmgIn/duration) ..
				"\n" .. RGBtoHEX(db.colors.incoming.heal) .. L.healIn:format(healIn, healIn/duration) ..
				"\n" .. RGBtoHEX(db.colors.outgoing.heal) .. L.healOut:format(healOut, healOut/duration) ..
				"\n" .. RGBtoHEX(db.colors.outgoing.spell) .. L.dmgOut:format(dmgOut, dmgOut/duration)
		
		local text = RGBtoHEX(db.colors.incoming.hit) .. shortenValue(dmgIn) .. "|r" .. summarySep ..
					RGBtoHEX(db.colors.incoming.heal) .. shortenValue(healIn) .. "|r" .. summarySep ..
					RGBtoHEX(db.colors.outgoing.heal) .. shortenValue(healOut) .. "|r" .. summarySep ..
					RGBtoHEX(db.colors.outgoing.spell) .. shortenValue(dmgOut) .. "|r"
		
		self:DisplayEvent(text, NOTIFICATION, db.colors.misc.combat.r, db.colors.misc.combat.g, db.colors.misc.combat.b, nil, nil, msg)
		
		-- Fading
		self.inCombat = false
		self:StartFading()
	end
end

-------------------------------------------------------------------------------
-- Determine if an event should be supressed or not
-------------------------------------------------------------------------------
function suppressEvent(event, eventType, incoming, outgoing, spellName, spellID, amount, auraType, sourceFlags, sourceFlags2, destFlags, destFlags2)
	-- Check Auras
	if eventType == "AURA_APPLIED" then
		if auraType == "BUFF" then
			if bit_band(sourceFlags, sourceFlags2, db.spamControl.buffFilter) > 0 then return true end
		else
			if bit_band(sourceFlags, sourceFlags2, db.spamControl.debuffFilter) > 0 then return true end
		end
	elseif eventType == "AURA_REMOVED" then
		if auraType == "BUFF" then
			if bit_band(sourceFlags, sourceFlags2, db.spamControl.buffFilter) > 0 then return true end
		else
			if bit_band(sourceFlags, sourceFlags2, db.spamControl.debuffFilter) > 0 then return true end
		end
	elseif eventType == "ENCHANT_APPLIED" then
		if not db.events.BUFF_GAINS or bit_band(sourceFlags, sourceFlags2, db.spamControl.buffFilter) > 0 then return true end
	elseif eventType == "ENCHANT_REMOVED" then
		if not db.events.BUFF_FADES or bit_band(sourceFlags, sourceFlags2, db.spamControl.buffFilter) > 0 then return true end
	end

	-- Blacklist
	if amount and db.spamControl[eventType] and amount < db.spamControl[eventType] then return true end
	if spellName and db.spamControl.blacklistSpells[spellName:lower()] then return true end
	if spellID and db.spamControl.blacklistSpells[spellID] then return true end
	--if Cascade.CustomSuppressEvent then return Cascade:CustomSuppressEvent(event, eventType, incoming, outgoing, spellName, spellID, amount, auraType, sourceFlags, sourceFlags2, destFlags, destFlags2) end
end

-------------------------------------------------------------------------------
-- Abbreviate spell names
-------------------------------------------------------------------------------
function abbreviate(text)
	if db.spamControl.abbreviate then
		return string_gsub(text, "(%a)[%l%p]*[%s%-]*", "%1")
	else
		return text
	end
end

-------------------------------------------------------------------------------
-- Update the CascadeFont object
-------------------------------------------------------------------------------
function Cascade:SetFont()
	local f, s, fl = CascadeFont:GetFont()
	local font = media and media:Fetch("font", db.frame.font)
	CascadeFont:SetFont(font or f, db.frame.fontSize or s, db.frame.fontFlags or fl)
	
	if history then history:OnFontChanged() end
end

-------------------------------------------------------------------------------
-- Insert an event or text into the Chat edit box
-------------------------------------------------------------------------------
function Cascade:Announce(text, bypass)
	if not text or text == "" then return end
	if not bypass then
		-- If it's just a timestamp, don't bother displaying it.
		if string_find(text, "^|c%w%w%w%w%w%w%w%w[%d:/%s]+|r\n$") then return end
		
		-- Cleanup string for chat linking.
		text = string_gsub(string_gsub(text, "|r", ""), "|c%w%w%w%w%w%w%w%w", "")
		text = string_gsub(text, "|Hunit:.-|h(.-)|h", "%1")
		text = string_gsub(text, "|Haction:.-|h(.-)|h", "%1")
		local last, id1 = select(2, string_find(text, "|Hspell:(%d+).-|h.-|h"))
		local id2 = select(3, string_find(text, "|Hspell:(%d+).-|h.-|h", last))
		text = string_gsub(text, "|Hspell:%d+:.-|h(.-)|h", (id1 and db.includeSpellLinks) and GetSpellLink(id1) or "%1", 1)
		text = string_gsub(text, "|Hspell:%d+:.-|h(.-)|h", (id2 and db.includeSpellLinks) and GetSpellLink(id2) or "%1", 1)
		text = string_gsub(text, "|Hitem:.-|h(.-)|h", "%1")
		text = string_gsub(text, "|Hicon:%d+:%a+|h|TInterface.-|t|h", "")
		text = string_gsub(text, "^([%d:/%s%.]+)\n", timestampFormat)
		text = string_gsub(text, "\n", ", ")
	end
	if text == "" then return end
	if ChatFrame1EditBox:IsShown() then
		ChatFrame1EditBox:Insert(text)
	else
		ChatFrame_OpenChat(text)
	end
end
