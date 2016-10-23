-- Default locales
--
--
-- Last updated: 2010-01-31T20:02:15Z

local L = LibStub("AceLocale-3.0"):NewLocale("Cascade", "enUS", true)
--if not L then return end

L.Cascade_tooltip = "|cffeda55fClick|r to open history frame.\n|cffeda55fRight-click|r to open options."

-- COMBAT_LOG_EVENT_UNFILTERED
L.DISPELLED = "Dispelled: "

-- Combat Summary
L.CombatEnded = "Combat ended after %s"
L.dmgIn = "Incoming Damage: %s (%.1f)"
L.dmgOut = "Outgoing Damage: %s (%.1f)"
L.healIn = "Incoming Heals: %s (%.1f)"
L.healOut = "Outgoing Heals: %s (%.1f)"

-- Right click menu
L["Link Event"] = true
L["Link Clean Event"] = true
L["Link Spell"] = true
L["Link Hit"] = true
L["Link Crit"] = true
L["Link Hit Spell"] = true
L["Link Crit Spell"] = true
L["Delete Spell"] = true

-- Cascade History
L.RESET = RESET
L.DAMAGE_IN = "Damage In"
L.DAMAGE_OUT = "Damage Out"
L.HEAL_IN = "Heal In"
L.HEAL_OUT = "Heal Out"


---------------------------------------------------
--------------------- Options ---------------------
---------------------------------------------------

-- Headers
L.options_general = GENERAL
L.options_frame = "Frame"
L.options_events = EVENTS_LABEL
L.options_colors = COLORS
L.options_spamControl = "Spam Control"
L.options_auraFilter = "Aura Filters"

-- General --
L.Cascade_desc = "Cascade is a compact combat log addon inspired by Grayhoof's EavesDrop."
L.general_includeSpellLinks = "Include Spell Links"
L.general_includeSpellLinks_desc = "Include clickable spell links when linking events to chat."
L.general_test = "Test"
L.general_test_desc = "Add some test events to the Cascade frame."
L.general_trackHistory = "Track History"
L.general_trackHistory_desc = "Track and store the largest damage and heal events."
L.general_history = "History"
L.general_history_desc = "Show the history frame."
L.general_timestamp = "Timestamps"
L.general_timestamp_desc = "Display the timestamp for combat log events in the tooltip as well as when events are sent to chat."
L.general_milliseconds = "Milliseconds"
L.general_milliseconds_desc = "Add millisecond percision to timestamps."

-- Frame --
L.frame_configure = "Configure Frame"
L.frame_advanced = "Advanced"
L.frame_locked = "Lock Frame"
L.frame_locked_desc = "Lock the frame so that it can't be moved or resized."
L.frame_showLabels = "Show Labels"
L.frame_showLabels_desc = "Show the Player/Target labels."
L.frame_flipEventSides = "Flip Event Sides"
L.frame_flipEventSides_desc = "Flip event sides so that Target events appear on the left and Player events appear on the right."
L.frame_reverseScrollDir = "Reverse Scroll"
L.frame_reverseScrollDir_desc = "Reverse scroll direction so events scroll from the top to the bottom."
L.frame_frameHeight = "Frame Height"
L.frame_frameHeight_desc = "Set the height of individual event frames."
L.frame_font = "Font"
L.frame_fontSize = "Font Size"
L.frame_overrideFontSize = "Override Font Size"
L.frame_overrideFontSize_desc = "Override the font size. By default, Cascade will automatically scale the font size based on frame height."
L.frame_petOffset = "Pet Offset"
L.frame_petOffset_desc = "Indent pet events based upon the offset."
L.frame_petAlpha = "Pet Alpha"
L.frame_petAlpha_desc = "Set the alpha of pet events."
L.frame_tooltips = "Tooltips"
L.frame_tooltips_desc = "Enable tooltips on event frames."
L.frame_tooltipAnchor = "Tooltip Anchor"
L.frame_font_header = "Font"
L.frame_pet_header = PET
L.frame_fading_header = "Fading"
L.frame_fadeDelay = "Fade Delay"
L.frame_fadeDelay_desc = "Set the time in seconds to wait before beginning to fade the frame. Setting to 0 will disable fading of events."
L.frame_fadeOutOfCombat = "Combat Fading"
L.frame_fadeOutOfCombat_desc = "Fade the entire frame when you are not in combat."
L.frame_alpha = "Frame Alpha"
L.frame_alpha_desc = "Set the alpha value of the frame to control it's transperency."
L.frame_bgTexture = "Background Texture"
L.frame_borderTexture = "Border Texture"
L.frame_tile = "Tiled Background"
L.frame_tileSize = "Tile Size"
L.frame_edgeSize = "Border Thickness"
L.frame_inset = "Border Inset"

-- Events --
L.events_info = "Customize which events are displayed in the Cascade frame."
L.events_PET = PET
L.events_PET_desc = "Display all damage and healing done by player-controlled pets and temporary pets."
L.events_VEHICLE = "Vehicle"
L.events_VEHICLE_desc = "Display all damage and healing done by a player-controlled vehicle."
L.events_OVERHEALING = "Overhealing"
L.events_OVERHEALING_desc = "Display the amount of overhealing (if any) when displaying heal events."
L.events_POWER = "Power"
L.events_POWER_desc = "Display all events involving any power type. (Mana, Rage, etc.)"
L.events_DISPELS = DISPELS
L.events_DISPELS_desc = "Display all dispel events."
L.events_INTERRUPTS = INTERRUPTS
L.events_INTERRUPTS_desc = "Display all interrupt events."
L.events_KILLS = KILLS
L.events_KILLS_desc = "Display death events and killing blow events."
L.events_auras_spacer = AURAS
L.events_BUFF_GAINS = "Buff Gains"
L.events_BUFF_FADES = "Buff Fades"
L.events_DEBUFF_GAINS = "Debuff Gains"
L.events_DEBUFF_FADES = "Debuff Fades"
L.events_misc_spacer = "Miscellaneous Events"
L.events_COMBAT = COMBAT
L.events_COMBAT_desc = "Display combat flags for entering or leaving combat."
L.events_COMBAT_SUMMARY = "Combat Summary"
L.events_COMBAT_SUMMARY_desc = "Display a brief summary of the amount of damage and healing that was done or taken in the last combat session."
L.events_DURABILITY = DURABILITY
L.events_EXPERIENCE = "Experience"
L.events_HONOR = HONOR
L.events_REPUTATION = REPUTATION
L.events_SKILLUPS = SKILLUPS

-- Colors --
L.colors_spell = SPELLS
L.colors_incoming = "Incoming"
L.colors_outgoing = "Outgoing"
L.colors_misc = "Misc."
L.colors_frame = "Frame"

L.colors_spell_bySchool = COLOR_BY_SCHOOL
L.colors_spell_bySchool_desc = "Color events based upon the school of the spell."
L.colors_spell_addSchool = "Add School"
L.colors_spell_remSchool = "Remove School"
L.colors_multischool = "Multi-school"
L.colors_multischool_info = "Adding a school from the dropdown below will allow you to override Cascade's default color behavior for multi-school spells."

L.colors_hit = HIT
L.colors_heal = "Heal"
L.colors_spell = SPELLS
L.colors_miss = MISS
L.colors_buffs = "Buff"
L.colors_debuffs = "Debuff"
L.colors_power = "Power"

L.colors_frame = "Background"
L.colors_border = "Background Border"
L.colors_text = "Text Color"
L.colors_combat = COMBAT
L.colors_death = "Death"
L.colors_experience = "Experience"
L.colors_honor = HONOR
L.colors_info = "Info"
L.colors_interrupt = INTERRUPTS
L.colors_reputation = REPUTATION

-- Spam Control --
L.spamControl_info = "Spam Control allows you to filter out different events based upon the amount of the spell.\n\nBlacklisting a spell will prevent it from ever being shown."
L.spamControl_DAMAGE = DAMAGE
L.spamControl_HEAL = "Heal"
L.spamControl_POWER = "Power"
L.spamControl_abbreviate = "Abbreviate Spells"
L.spamControl_blacklist_label = "Blacklist"
L.spamControl_addBlacklistSpell = "Add Spell to Blacklist"
L.spamControl_addBlacklistSpell_desc = "Input a spell name or spell ID that will be added to the blacklist."
L.spamControl_delBlacklistSpell = "Remove Spell from Blacklist"

L.spamControl_addBlacklistSpell_noid_msg = "Spell ID %d was found."
L.spamControl_addBlacklistSpell_msg = "Adding spell %s to blacklist."
L.spamControl_delBlacklistSpell_msg = "Removing spell %s from blacklist."

-- Aura Filter --
L.auraFilter_info = "Aura Filters allow the filtering of buffs/debuffs based upon the original caster of the buff/debuff."
L.auraFilter_buffFilters = "Hide Buffs From:"
L.auraFilter_debuffFilters = "Hide Debuffs From:"
L.auraFilter_self = "Self"
L.auraFilter_party_raid = "Party/Raid"
L.auraFilter_outsider = "Outsider"
