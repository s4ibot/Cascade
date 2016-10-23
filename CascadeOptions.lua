

--
-- Advanced Options
-- 		Some options do not have a GUI setting.
--		For more information check the following link.
--
--		http://www.wowace.com/addons/cascade/pages/advanced-options/
--

local mod = Cascade:NewModule("Options")


-- Locales
local L = LibStub("AceLocale-3.0"):GetLocale("Cascade")

-- Libs
local media = LibStub("LibSharedMedia-3.0", true)
local gui = LibStub("AceGUI-3.0")

-- Local reference to history module
local history

-- AceConfig options table
local options, suboptions

-- List of multischool schools. One list of available schools and the other is a list of schools to remove.
local multischool, multischool_remove = {[0] = STRING_SCHOOL_UNKNOWN}, {}


-- LSM-3.0 lists
local bgList, borderList, fontList = {}, {}, {[""] = ""}
local function updateList(callback, mediaType, key)
	if mediaType == "font" then
		fontList[key] = key
	elseif mediaType == "border" then
		borderList[key] = key
	elseif mediaType == "background" then
		bgList[key] = key
	end
end

-- http://www.wowwiki.com/API_GameTooltip_SetOwner
local anchorValues = {
	ANCHOR_TOPRIGHT = "TOPRIGHT",
	ANCHOR_RIGHT = "RIGHT",
	ANCHOR_BOTTOMRIGHT = "BOTTOMRIGHT",
	ANCHOR_TOPLEFT = "TOPLEFT",
	ANCHOR_LEFT = "LEFT",
	ANCHOR_BOTTOMLEFT = "BOTTOMLEFT",
	NONE = NONE,
	--ANCHOR_CURSOR = "CURSOR",
}

-- Blacklisted spells list
local blacklistSpellsTable
local function blacklistSpells()
	if blacklistSpellsTable then wipe(blacklistSpellsTable) else blacklistSpellsTable = {} end
	for k, v in pairs(Cascade.db.profile.spamControl.blacklistSpells) do
		blacklistSpellsTable[tostring(k)] = v
	end
	return blacklistSpellsTable
end

-- Color Handlers
local function colorHandler(info, r, g, b)
	local c = Cascade.db.profile.colors[info[#info-1]][info.arg or info[#info]]
	if r then c.r, c.g, c.b = r, g, b else return c.r, c.g, c.b end
end

local function miscColorHandler(info, r, g, b, a)
	local c = Cascade.db.profile.colors.misc[info[#info]]
	if r then c.r, c.g, c.b, c.a = r, g, b, a else return c.r, c.g, c.b, c.a end
end

local function schoolColorHandler(info, r, g, b)
	local c = Cascade.db.profile.colors.spell[info.arg]
	if r then c.r, c.g, c.b = r, g, b else return c.r, c.g, c.b end
end

-------------------------------------------------------------------------------
-- Initialize options table and register with AceConfig-3.0.
-- Add to Blizzard Options
-------------------------------------------------------------------------------
function mod:OnInitialize()
	history = Cascade:GetModule("History", true)
	-- Find all multi-school spells
	for i = 1, 127 do
		local school = CombatLog_String_SchoolString(i)
		if school ~= STRING_SCHOOL_UNKNOWN and not COMBATLOG_DEFAULT_COLORS.schoolColoring[i] then
			multischool[i] = school
		end
	end
	
	-- Register callbacks
	Cascade.db.RegisterCallback(self, "OnProfileChanged", "AddColorOptions")
	Cascade.db.RegisterCallback(self, "OnProfileCopied", "AddColorOptions")
	Cascade.db.RegisterCallback(self, "OnProfileReset", "AddColorOptions")

	if media then
		media.RegisterCallback(self, "LibSharedMedia_Registered", updateList)
		for k, v in pairs(media:List("background")) do bgList[v] = v end
		for k, v in pairs(media:List("border")) do borderList[v] = v end
		for k, v in pairs(media:List("font")) do fontList[v] = v end
	end

	-- Colors
	self:AddColorOptions()
	
	-- Profiles
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Cascade.db)
	options.args.profiles.order = -1
	
	-- Register our options table.
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade", options)
	
	-- Register slash command.
	Cascade:RegisterChatCommand("Cascade", function(msg)
		if msg and msg:lower() == "history" and history and Cascade.db.profile.trackHistory then
			Cascade:ToggleHistory()
		else
			mod:OpenOptions()
		end
	end)
	
	-- Register smaller tables for the Blizzard Options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-events", options.args.events)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-colors", options.args.colors)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-spamControl", options.args.spamControl)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-auraFilter", options.args.auraFilter)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-profiles", options.args.profiles)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-frame", suboptions.frame)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cascade-multischool", suboptions.multischool)
	
	-- Add options to Blizzard Options
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade", "Cascade", nil, "general")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade-events", options.args.events.name, "Cascade")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade-colors", options.args.colors.name, "Cascade")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade-spamControl", options.args.spamControl.name, "Cascade")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade-auraFilter", options.args.auraFilter.name, "Cascade")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cascade-profiles", options.args.profiles.name, "Cascade")
end

-------------------------------------------------------------------------------
-- Add all color options to their respective lists.
-------------------------------------------------------------------------------
local addColor, remColor
function mod:AddColorOptions()
	-- Hide all the old color options
	for k in pairs(multischool_remove) do remColor(k) end
	
	-- Add any colors to options table
	for k, v in pairs(Cascade.db.profile.colors.spell) do
		if type(v) == "table" then addColor(k) end
	end
end

-------------------------------------------------------------------------------
-- Add a color to the options.
-------------------------------------------------------------------------------
local schools, schoolOrder
function addColor(i, v)
	i = v or i

	-- Don't bother adding a core spell.
	if options.args.colors.args.spell.args[tostring(i)] then return end

	-- Update tables for options
	if multischool[i] then multischool_remove[i] = multischool[i] multischool[i] = nil end

	-- Insert color into db
	if not Cascade.db.profile.colors.spell[i] then
		Cascade.db.profile.colors.spell[i] = Cascade.BLENDED_COLORS[i]
		Cascade.BLENDED_COLORS[i] = nil
	end
	
	-- Show the color in the options or create the option if necessary.
	if suboptions.multischool.args[tostring(i)] then suboptions.multischool.args[tostring(i)].hidden = nil return end
	local t = {type = "color", name = CombatLog_String_SchoolString(i), arg = i, order = 11,}
	if COMBATLOG_DEFAULT_COLORS.schoolColoring[i] and i > 0 then
		if i == 1 then t.order = 10 end
		options.args.colors.args.spell.args[tostring(i)] = t
		return
	end
	

	suboptions.multischool.args[tostring(i)] = t
	-- Determine which base schools make up this school.
	if not schools then
		schools, schoolOrder = {}, {SCHOOL_MASK_PHYSICAL, SCHOOL_MASK_ARCANE, SCHOOL_MASK_FIRE, SCHOOL_MASK_FROST, SCHOOL_MASK_HOLY, SCHOOL_MASK_NATURE, SCHOOL_MASK_SHADOW}
	end
	wipe(schools)
	for _, k in pairs(schoolOrder) do
		if bit.band(i, k) > 0 then
			t.order = t.order + 1
			tinsert(schools, CombatLog_String_SchoolString(k))
		end
	end
	t.desc = table.concat(schools, " + ")
end

-------------------------------------------------------------------------------
-- Remove (hide) color from options.
-------------------------------------------------------------------------------
function remColor(i, v)
	i = v or i
	-- Update tables for options
	if multischool_remove[i] then multischool[i] = multischool_remove[i] multischool_remove[i] = nil end
	
	-- Remove color from db
	Cascade.db.profile.colors.spell[i] = nil

	-- Hide the color in the options.
	if suboptions.multischool.args[tostring(i)] then suboptions.multischool.args[tostring(i)].hidden = true end
end


-------------------------------------------------------------------------------
--------------------------------- Options Table -------------------------------
-------------------------------------------------------------------------------
options = {
	type = "group",
	name = "Cascade",
	handler = Cascade,
	args = {
		general = {
			type = "group",
			name = L.options_general,
			order = 1,
			get = function(info) return Cascade.db.profile[info[#info]] end,
			set = function(info, value) Cascade.db.profile[info[#info]] = value end,
			args = {
				info = {type = "description", name = L.Cascade_desc.."\n\n", order = 0},
				includeSpellLinks = {
					type = "toggle",
					name = L.general_includeSpellLinks,
					desc = L.general_includeSpellLinks_desc,
					order = 1,
				},
				test = {
					type = "execute",
					name = L.general_test,
					desc = L.general_test_desc,
					order = 2,
					handler = mod,
					func = "Test",
					width = "half",
				},
				spacer1 = {type = "description", name = "", order = 3,},
				trackHistory = {
					type = "toggle",
					name = L.general_trackHistory,
					desc = L.general_trackHistory_desc,
					order = 4,
					disabled = function() return not history end,
				},
				history = {
					type = "execute",
					name = L.general_history,
					desc = L.general_history_desc,
					order = 5,
					func = "ToggleHistory",
					width = "half",
					disabled = function() return not (history and Cascade.db.profile.trackHistory) end,
				},
				spacer2 = {type = "description", name = "\n\n", order = 6,},
				timestamp = {
					type = "toggle",
					name = L.general_timestamp,
					desc = L.general_timestamp_desc,
					descStyle = "inline",
					width = "full",
					order = 7,
				},
				milliseconds = {
					type = "toggle",
					name = L.general_milliseconds,
					desc = L.general_milliseconds_desc,
					descStyle = "inline",
					width = "full",
					order = 8,
					set = function(info, value) Cascade.db.profile.milliseconds = value Cascade:SetMillisecondPrecision(value) end,
					disabled = function() return not Cascade.db.profile.timestamp end,
				},
				spacer3 = {type = "description", name = "\n\n", order = 9,},
				frame = {
					type = "execute",
					name = L.frame_configure,
					order = 10,
					handler = mod,
					func = "ToggleFrameOptionsWindow",
					width = "double",
				},
			},
		},
		events = {
			type = "group",
			name = L.options_events,
			order = 2,
			get = function(info) return Cascade.db.profile.events[info[#info]] end,
			set = function(info, value) Cascade.db.profile.events[info[#info]] = value Cascade:FilterCombatEvents() end,
			args = {
				info = {type = "description", name = L.events_info.."\n\n", order = 0,},
				PET = {type = "toggle", name = L.events_PET, desc = L.events_PET_desc, order = 1,},
				VEHICLE = {type = "toggle", name = L.events_VEHICLE, desc = L.events_VEHICLE_desc, order = 2,},
				OVERHEALING = {type = "toggle", name = L.events_OVERHEALING, desc = L.events_OVERHEALING_desc, order = 3,},
				POWER = {type = "toggle", name = L.events_POWER, desc = L.events_POWER_desc, order = 4,},
				DISPELS = {type = "toggle", name = L.events_DISPELS, desc = L.events_DISPELS_desc, order = 5,},
				INTERRUPTS = {type = "toggle", name = L.events_INTERRUPTS, desc = L.events_INTERRUPTS_desc, order = 5,},
				KILLS = {type = "toggle", name = L.events_KILLS, desc = L.events_KILLS_desc, order = 5,},
				auras_spacer = {type = "header", name = L.events_auras_spacer, order = 20,},
				BUFF_GAINS = {type = "toggle", name = L.events_BUFF_GAINS, order = 21,},
				BUFF_FADES = {type = "toggle", name = L.events_BUFF_FADES, order = 22,},
				DEBUFF_GAINS = {type = "toggle", name = L.events_DEBUFF_GAINS, order = 23,},
				DEBUFF_FADES = {type = "toggle", name = L.events_DEBUFF_FADES, order = 24,},
				misc_spacer = {type = "header", name = L.events_misc_spacer, order = 30,},
				COMBAT = {type = "toggle", name = L.events_COMBAT, desc = L.events_COMBAT_desc, order = 31,},
				COMBAT_SUMMARY = {type = "toggle", name = L.events_COMBAT_SUMMARY, desc = L.events_COMBAT_SUMMARY_desc, order = 32,},
				DURABILITY = {type = "toggle", name = L.events_DURABILITY,},
				EXPERIENCE = {type = "toggle", name = L.events_EXPERIENCE,},
				HONOR = {type = "toggle", name = L.events_HONOR,},
				REPUTATION = {type = "toggle", name = L.events_REPUTATION,},
				SKILLUPS = {type = "toggle", name = L.events_SKILLUPS,},
			},
		},
		colors = {
			type = "group",
			name = L.options_colors,
			order = 3,
			childGroups = "tab",
			get = colorHandler,
			set = colorHandler,
			args = {
				incoming = {
					type = "group",
					name = L.colors_incoming,
					order = 1,
					args = {
						hit = {type = "color", name = L.colors_hit, order = 1,},
						miss = {type = "color", name = L.colors_miss, order =2,},
						spell = {type = "color", name = L.colors_spell, order = 3,},
						heal = {type = "color", name = L.colors_heal,},
						power = {type = "color", name = L.colors_power,},
						buffs = {type = "color", name = L.colors_buffs, order = 150,},
						debuffs = {type = "color", name = L.colors_debuffs, order = 151,},
					},
				},
				outgoing = {
					type = "group",
					name = L.colors_outgoing,
					order = 2,
					args = {
						hit = {type = "color", name = L.colors_hit, order = 1, disabled = function() return not Cascade.db.profile.colors.spell.bySchool end},
						miss = {type = "color", name = L.colors_miss, order = 2,},
						spell = {type = "color", name = L.colors_spell, order = 3,},
						heal = {type = "color", name = L.colors_heal,},
					},
				},
				spell = {
					type = "group",
					name = L.colors_spell,
					order = 3,
					disabled = function(info) if info[#info] == "spell" then return end return not Cascade.db.profile.colors.spell.bySchool end,
					args = {
						bySchool = {
							type = "toggle",
							name = L.colors_spell_bySchool,
							order = 1,
							get = function(info) return Cascade.db.profile.colors.spell.bySchool end,
							set = function(info, value) Cascade.db.profile.colors.spell.bySchool = value end,
							disabled = false,
						},
						spacer = {type = "description", name = "\n", order = 20,},
						multischool = {
							type = "execute",
							name = L.colors_multischool,
							order = 21,
							func = "ToggleMultischoolWindow",
							width = "double",
							handler = mod,
						},
					},
				},
				misc = {
					type = "group",
					name = L.colors_misc,
					order = 4,
					args = {
						text = {type = "color", name = L.colors_text, order = 3, set = function(...) colorHandler(...) Cascade:UpdateFrameAppearance() end},
						spacer = {type = "header", name = "", order = 4},
						combat = {type = "color", name = L.colors_combat,},
						death = {type = "color", name = L.colors_death,},
						experience = {type = "color", name = L.colors_experience,},
						honor = {type = "color", name = L.colors_honor,},
						info = {type = "color", name = L.colors_info,},
						interrupt = {type = "color", name = L.colors_interrupt,},
						reputation = {type = "color", name = L.colors_reputation,},
					},
				},
			},
		},
		spamControl = {
			type = "group",
			name = L.options_spamControl,
			order = 4,
			get = function(info) return Cascade.db.profile.spamControl[info[#info]] end,
			set = function(info, value) Cascade.db.profile.spamControl[info[#info]] = value end,
			args = {
				info = {type = "description", name = L.spamControl_info.."\n\n", order = 0,},
				DAMAGE = {
					type = "range",
					name = L.spamControl_DAMAGE,
					order = 2,
					step = 1,
					bigStep = 100,
					min = 0,
					max = 10000,
				},
				HEAL = {
					type = "range",
					name = L.spamControl_HEAL,
					order = 3,
					step = 1,
					bigStep = 100,
					min = 0,
					max = 10000,
				},
				POWER = {
					type = "range",
					name = L.spamControl_POWER,
					order = 4,
					step = 1,
					bigStep = 20,
					min = 0,
					max = 2000,
				},
				abbreviate = {
					type = "toggle",
					name = L.spamControl_abbreviate,
					order = 5,
				},
				blacklist_label = {
					type = "header",
					name = L.spamControl_blacklist_label,
					order = 10,
				},
				addBlacklistSpell = {
					type = "input",
					name = L.spamControl_addBlacklistSpell,
					desc = L.spamControl_addBlacklistSpell_desc,
					--usage = L.spamControl_addBlacklistSpell_usage,
					order = 11,
					width = "double",
					set = function(info, value)
						local spellID = tonumber(value)
						local spellName = GetSpellInfo(spellID or value)
						if spellID then
							if not spellName then
								return print(L.spamControl_addBlacklistSpell_noid_msg:format(spellID))
							else
								Cascade.db.profile.spamControl.blacklistSpells[spellID] = string.format("ID: %d (%s)", spellID, spellName)
								print(L.spamControl_addBlacklistSpell_msg:format(Cascade.db.profile.spamControl.blacklistSpells[spellID]))
							end
						else
							spellName = spellName or value
							Cascade.db.profile.spamControl.blacklistSpells[spellName:lower()] = spellName
							print(L.spamControl_addBlacklistSpell_msg:format(spellName))
						end
					end,
				},
				delBlacklistSpell = {
					type = "select",
					name = L.spamControl_delBlacklistSpell,
					order = 12,
					width = "double",
					values = blacklistSpells,
					set = function(info, value)
						print(L.spamControl_delBlacklistSpell_msg:format(Cascade.db.profile.spamControl.blacklistSpells[tonumber(value) or value]))
						Cascade.db.profile.spamControl.blacklistSpells[tonumber(value) or value] = nil
					end,
					disabled = function() for k, v in pairs(Cascade.db.profile.spamControl.blacklistSpells) do return false end return true end,
				},
			},
		},
		auraFilter = {
			type = "group",
			name = L.options_auraFilter,
			order = 5,
			get = function(info, key) return bit.band(key, Cascade.db.profile.spamControl[info[#info]]) > 0 end,
			set = function(info, key, value)
				if value then
					Cascade.db.profile.spamControl[info[#info]] = bit.bor(key, Cascade.db.profile.spamControl[info[#info]])
				else
					Cascade.db.profile.spamControl[info[#info]] = bit.band(bit.bxor(key, 0xF), Cascade.db.profile.spamControl[info[#info]])
				end
			end,
			args = {
				info = {type = "description", name = L.auraFilter_info.."\n\n", order = 0,},
				buffFilter = {
					type = "multiselect",
					name = L.auraFilter_buffFilters,
					order = 1,
					values = {[1] = L.auraFilter_self, [6] = L.auraFilter_party_raid, [8] = L.auraFilter_outsider,},
					
				},
				debuffFilter = {
					type = "multiselect",
					name = L.auraFilter_debuffFilters,
					order = 2,
					values = {[1] = L.auraFilter_self, [6] = L.auraFilter_party_raid, [8] = L.auraFilter_outsider,},
				},
			},
		},
	},
}

suboptions = {
	frame = {
		type = "group",
		name = L.options_frame,
		childGroups = "tab",
		get = function(info) return Cascade.db.profile.frame[info[#info]] end,
		set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:CreateEventFrames() end,
		args = {
			test = {
				type = "execute",
				name = L.general_test,
				desc = L.general_test_desc,
				order = 1,
				func = "Test",
				width = "full",
				handler = mod,
			},
			locked = {
				type = "toggle",
				name = L.frame_locked,
				desc = L.frame_locked_desc,
				order = 2,
				set = function(info, value) Cascade.db.profile.frame.locked = value Cascade:UpdateFrameLock() end,
			},
			general = {
				type = "group",
				name = L.options_general,
				order = 1,
				args = {
					flipEventSides = {
						type = "toggle",
						name = L.frame_flipEventSides,
						desc = L.frame_flipEventSides_desc,
						order = 1,
						set = function(info, value) Cascade:FlipEventSides(value) end,
					},
					reverseScrollDir = {
						type = "toggle",
						name = L.frame_reverseScrollDir,
						desc = L.frame_reverseScrollDir_desc,
						order = 2,
					},
					showLabels = {
						type = "toggle",
						name = L.frame_showLabels,
						desc = L.frame_showLabels_desc,
						order = 3,
					},
					tooltipAnchor = {
						type = "select",
						name = L.frame_tooltipAnchor,
						order = 4,
						values = anchorValues,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value end,
					},
					frameHeight = {
						type = "range",
						name = L.frame_frameHeight,
						desc = L.frame_frameHeight_desc,
						order = 5,
						min = 8,
						max = 50,
						bigStep = 1,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:CreateEventFrames() if history then history:CreateEventFrames() end end,
					},
					font_header = {type = "header", name = L.frame_font_header, order = 10,},
					font = {
						type = "select",
						name = L.frame_font,
						order = 11,
						width = "double",
						values = fontList,
						set = function(info, value) if value == "" then value = nil end Cascade.db.profile.frame.font = value Cascade:SetFont() end,
						disabled = (not media),
					},
					overrideFontSize = {
						type = "toggle",
						name = L.frame_overrideFontSize,
						desc = L.frame_overrideFontSize_desc,
						order = 12,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:AutoUpdateFontSize() end,
					},
					fontSize = {
						type = "range",
						name = L.frame_fontSize,
						order = 13,
						min = 2,
						max = 50,
						bigStep = 1,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:SetFont() end,
						disabled = function() return not Cascade.db.profile.frame.overrideFontSize end,
					},
					fading_header = {type = "header", name = L.frame_fading_header, order = 20,},
					fadeDelay = {
						type = "range",
						name = L.frame_fadeDelay,
						desc = L.frame_fadeDelay_desc,
						order = 21,
						min = 0,
						max = 60,
						bigStep = 1,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value if not Cascade.inCombat then Cascade:StopFading() Cascade:StartFading() end end,
					},
					fadeOutOfCombat = {
						type = "toggle",
						name = L.frame_fadeOutOfCombat,
						desc = L.frame_fadeOutOfCombat_desc,
						order = 22,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value if not Cascade.inCombat then Cascade:StopFading() Cascade:StartFading() end end,
					},
				},
			},
			advanced = {
				type = "group",
				name = L.frame_advanced,
				order = 2,
				set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:UpdateFrameAppearance() Cascade:CreateEventFrames() if history then history:CreateEventFrames() end end,
				args = {
					frame = {type = "color", name = L.colors_frame, order = 2, hasAlpha = true, get = miscColorHandler, set = function(...) miscColorHandler(...) Cascade:UpdateFrameAppearance() end,},
					border = {type = "color", name = L.colors_border, order = 3, hasAlpha = true, get = miscColorHandler, set = function(...) miscColorHandler(...) Cascade:UpdateFrameAppearance() end,},
					alpha = {
						type = "range",
						name = L.frame_alpha,
						desc = L.frame_alpha_desc,
						order = 4,
						min = .2,
						max = 1,
						bigStep = .01,
						isPercent = true,
					},
					spacer1 = {type = "description", name = "", order = 5,},
					bgTexture = {
						type = "select",
						name = L.frame_bgTexture,
						order = 6,
						values = bgList,
						set = function(info, value) Cascade.db.profile.frame.bgTexture = value Cascade:UpdateFrameAppearance() end,
						disabled = (not media),
					},
					borderTexture = {
						type = "select",
						name = L.frame_borderTexture,
						order = 7,
						values = borderList,
						set = function(info, value) Cascade.db.profile.frame.borderTexture = value Cascade:UpdateFrameAppearance() end,
						disabled = (not media),
					},
					tile = {
						type = "toggle",
						name = L.frame_tile,
						order = 11,
					},
					tileSize = {
						type = "range",
						name = L.frame_tileSize,
						order = 12,
						min = 1,
						max = 512,
						bigStep = 4,
						disabled = function() return not Cascade.db.profile.frame.tile end,
					},
					edgeSize = {
						type = "range",
						name = L.frame_edgeSize,
						order = 13,
						min = 1,
						max = 84,
						bigStep = 1,
					},
					inset = {
						type = "range",
						name = L.frame_inset,
						order = 14,
						min = 0,
						max = 84,
						bigStep = 1,
					},
					spacer2 = {type = "description", name = "\n\n", order = 20,},
					pet_header = {type = "header", name = L.frame_pet_header, order = 21,},
					petOffset = {
						type = "range",
						name = L.frame_petOffset,
						desc = L.frame_petOffset_desc,
						order = 22,
						min = 0,
						max = 100,
						bigStep = 1,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:UpdateAllEvents() end,
					},
					petAlpha = {
						type = "range",
						name = L.frame_petAlpha,
						desc = L.frame_petAlpha_desc,
						order = 23,
						min = 0,
						max = 1,
						step = 0.01,
						isPercent = true,
						set = function(info, value) Cascade.db.profile.frame[info[#info]] = value Cascade:UpdateAllEvents() end,
					},
				},
			},
		},
	},
	multischool = {
		type = "group",
		name = L.colors_multischool,
		get = schoolColorHandler,
		set = schoolColorHandler,
		args = {
			multischool_info = {type = "description", name = L.colors_multischool_info.."\n", order = 1,},
			addSchool = {
				type = "select",
				name = L.colors_spell_addSchool,
				order = 2,
				values = multischool,
				get = false,
				set = addColor,
				disabled = function() for k, v in pairs(multischool) do return false end return true end,
			},
			remSchool = {
				type = "select",
				name = L.colors_spell_remSchool,
				order = 3,
				values = multischool_remove,
				get = false,
				set = remColor,
				disabled = function() for k, v in pairs(multischool_remove) do return false end return true end,
			},
		},
	},
}


-------------------------------------------------------------------------------
-- Popup windows
-------------------------------------------------------------------------------
local frame
local function onClose(widget)
	widget:ReleaseChildren()
	widget:Release()
	frame = nil
	
	mod:OpenOptions()
end

local function onColorsClose(widget)
	widget:ReleaseChildren()
	widget:Release()
	frame = nil
	
	mod:OpenOptions(options.args.colors.name)
end

function mod:ToggleFrameOptionsWindow()
	if frame then local appName = frame:GetUserData("appName") frame:Hide() if appName == "Cascade-frame" then return end end
	HideUIPanel(InterfaceOptionsFrame)
	frame = gui:Create("Window")
	frame:Show()
	frame:EnableResize()
	frame:SetCallback("OnClose", onClose)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Cascade-frame", 390, 550)
	LibStub("AceConfigDialog-3.0"):Open("Cascade-frame", frame)

	frame:SetPoint(Cascade.Frame and Cascade.Frame:GetCenter() > UIParent:GetCenter() and "LEFT" or "RIGHT")
end

function mod:ToggleMultischoolWindow()
	if frame then local appName = frame:GetUserData("appName") frame:Hide() if appName == "Cascade-multischool" then return end end
	HideUIPanel(InterfaceOptionsFrame)
	frame = gui:Create("Window")
	frame:Show()
	frame:EnableResize()
	frame:SetCallback("OnClose", onColorsClose)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Cascade-multischool", 365, 530)
	LibStub("AceConfigDialog-3.0"):Open("Cascade-multischool", frame)

	frame:SetPoint(Cascade.Frame and Cascade.Frame:GetCenter() > UIParent:GetCenter() and "RIGHT" or "LEFT", UIParent, "CENTER")
end

-------------------------------------------------------------------------------
-- Open options
-------------------------------------------------------------------------------
function mod:OpenOptions(name)
	local panel
	for i, b in next, InterfaceOptionsFrameAddOns.buttons do
		if b.element then
			if b.element.name == "Cascade" then
				if not b.element.parent and b.element.collapsed then OptionsListButtonToggle_OnClick(b.toggle) end
				panel = b.element
				if not name then break end
			elseif name == b.element.name and b.element.parent == "Cascade" then
				panel = b.element
				break
			end
		end
	end
	
	if panel then
		InterfaceOptionsFrame_OpenToCategory(panel)
	end
end

-------------------------------------------------------------------------------
-- LDB data object for Cascade
-------------------------------------------------------------------------------
local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if ldb then
	ldb:NewDataObject("Cascade", {
		type = "data source",
		text = "Cascade",
		icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
		OnClick = function(self, button)
			if button == "LeftButton" and Cascade.db.profile.trackHistory and history then
				Cascade:ToggleHistory()
			else
				mod:OpenOptions()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("Cascade")
			tooltip:AddLine(L.Cascade_tooltip, 0.2, 1, 0.2, 1)
		end,
	})
end

-------------------------------------------------------------------------------
-- Fills the frame with random spells of random colors
-------------------------------------------------------------------------------
local spells, colors
function mod:Test()
	if not spells then
		spells, colors = {}, {}
		for i = 2, MAX_SKILLLINE_TABS do
			local offset, numSpells = select(3, GetSpellTabInfo(i))
			if not offset then break end
			for s = offset + 1, offset + numSpells do
				local spell = GetSpellBookItemName(s, BOOKTYPE_SPELL)
				tinsert(spells, spell)
			end
		end
		
		for i, colorTypes in pairs(Cascade.db.profile.colors) do
			for k, c in pairs(colorTypes) do
				if type(c) == "table" and not (i == "misc" and (k == "frame" or k == "border" or k == "text")) then
					tinsert(colors, c)
				end
			end
		end
	end

    local spellName
    local spellIcon
    repeat
        local spell = spells[math.random(1, #spells)]
        local name, rank, icon = GetSpellInfo(spell)
        spellName = name
        spellIcon = icon
    until name ~= nil

	local link = GetSpellLink(spellName)

	local spellID = select(3, string.find(link, "|Hspell:(%d+).-|h.-|h"))
	local color = colors[math.random(1, #colors)]
	local loc = math.random(-2, 2)
	Cascade:DisplayEvent(loc == 0 and name or math.random(100, 10000), loc, color.r, color.g, color.b, spellIcon, spellID, spellName)
end
