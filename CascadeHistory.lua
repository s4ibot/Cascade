

local history = Cascade:NewModule("History")

local defaults = {DAMAGE_IN = {}, DAMAGE_OUT = {}, HEAL_IN = {}, HEAL_OUT = {}}
local HIT, CRIT = "HIT_", "CRIT_"
local opp = {[HIT] = CRIT, [CRIT] = HIT}
local db

local CombatLog_String_SchoolString = CombatLog_String_SchoolString
local string_gsub = string.gsub
local time = time

local MELEE_ATTACK = MELEE_ATTACK

local clean, storeEvent

-------------------------------------------------------------------------------
-- Prepare the history tracking tables
-------------------------------------------------------------------------------
function history:OnInitialize()
	CascadeDBPC = CascadeDBPC or defaults
	-- Make sure it's initialized correctly
	for k, v in pairs(defaults) do if not CascadeDBPC[k] then CascadeDBPC[k] = {} end end

	db = CascadeDBPC
	self.HISTORY = db
	
	-- Clean database
	for _, data in pairs(db) do
		for _, v in pairs(data) do
			v[HIT.."msgClean"], v[CRIT.."msgClean"] = nil, nil
		end
	end
end

-------------------------------------------------------------------------------
-- Clean up the string a bit to save some memory when it is stored
-------------------------------------------------------------------------------
function clean(text)
	if not text then return end
	text = string_gsub(string_gsub(text, "|r", ""), "|c%w%w%w%w%w%w%w%w", "")
	text = string_gsub(text, "|Hunit:.-|h(.-)|h", "%1")
	text = string_gsub(text, "|Haction:.-|h(.-)|h", "%1")
	text = string_gsub(text, "|Hitem:.-|h(.-)|h", "%1")
	text = string_gsub(text, "|Hicon:%d+:%a+|h|TInterface.-|t|h", "")
	text = string_gsub(text, "^[%d:]+>%s", "")
	return text
end

-------------------------------------------------------------------------------
-- Update the history information
-------------------------------------------------------------------------------
function history:CheckHistory(eventType, incoming, outgoing, amount, spell, school, icon, crit, msg)
	if not (incoming or outgoing) then return end
	if (incoming and outgoing) then
		-- If we're healing ourselves, update both incoming and outgoing.
		local i = self:CheckHistory(eventType, incoming, nil, amount, spell, school, icon, crit, msg)
		local o = self:CheckHistory(eventType, nil, outgoing, amount, spell, school, icon, crit, msg)
		return (i or o)
	end
		
	local key = eventType..(incoming and "_IN" or "_OUT")

	-- Incoming damage, we track only hits/crits of each school
	if (key == "DAMAGE_IN") then spell = CombatLog_String_SchoolString(school) end
	-- If there's no spell, it's a melee attack.
	if not spell then spell = MELEE_ATTACK end
	
	-- If a new high hit/crit is found, be sure to update the history frame if it's open.
	if storeEvent(db, key, spell, (crit and CRIT or HIT), amount, icon, msg) then self:UpdateAllEvents() return true end
end

-------------------------------------------------------------------------------
-- Check to see if the given event is a bigger hit/crit than what is stored
-------------------------------------------------------------------------------
function storeEvent(storage, key, spell, hitType, amount, icon, msg)
	if not storage[key][spell] then storage[key][spell] = {} end

	if (not storage[key][spell][hitType.."amount"]) or (amount > storage[key][spell][hitType.."amount"]) then
		-- Use the icon of the highest incoming damage, regardless of whether it is a crit or not.
		if key == "DAMAGE_IN" then
			if amount > (storage[key][spell][opp[hitType].."amount"] or 0) then
				storage[key][spell].icon = icon
			end
		else
			storage[key][spell].icon = icon
		end
		storage[key][spell][hitType.."amount"] = amount
		storage[key][spell][hitType.."msg"] = clean(msg)
		storage[key][spell][hitType.."time"] = time()
		--storage[key][spell][hitType.."msgClean"] = clean(msgClean)
		return true
	end
end
