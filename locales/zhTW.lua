-- zhTW locales kindly provided by:
--		wowui.cn
--
-- Last updated: 2010-02-02T15:36:53Z

local L = LibStub("AceLocale-3.0"):NewLocale("Cascade", "zhTW")
if not L then return end

L.Cascade_tooltip = "|cffeda55f點擊|r - 打開歷史框體.\n|cffeda55f右鍵點擊|r - 打開選項."

-- COMBAT_LOG_EVENT_UNFILTERED
L.DISPELLED = "驅散: "

-- Combat Summary
L.CombatEnded = "戰鬥結束於 %s"
L.dmgIn = "承受傷害: %s (%.1f)"
L.dmgOut = "輸出傷害: %s (%.1f)"
L.healIn = "接受治療: %s (%.1f)"
L.healOut = "輸出治療: %s (%.1f)"

-- Right click menu
L["Link Event"] = "鏈接事件"
L["Link Clean Event"] = "鏈接潔淨事件"
L["Link Spell"] = "鏈接法術"
L["Link Hit"] = "鏈接命中"
L["Link Crit"] = "鏈接暴擊"
L["Link Hit Spell"] = "鏈接命中法術"
L["Link Crit Spell"] = "鏈接暴擊法術."
L["Delete Spell"] = "刪除法術"

-- Cascade History
L.RESET = RESET
L.DAMAGE_IN = "承受傷害"
L.DAMAGE_OUT = "輸出傷害"
L.HEAL_IN = "接受治療"
L.HEAL_OUT = "輸出治療"


---------------------------------------------------
--------------------- Options ---------------------
---------------------------------------------------

-- Headers
L.options_general = GENERAL
L.options_frame = "框體"
L.options_events = EVENTS_LABEL
L.options_colors = COLORS
L.options_spamControl = "垃圾訊息控制"
L.options_auraFilter = "光環過濾器"

-- General --
L.Cascade_desc = "Cascade是壹款類似於Grayhoof的EavesDrop的戰鬥記錄增強插件."
L.general_includeSpellLinks = "包括法術鏈接"
L.general_includeSpellLinks_desc = "當鏈接事件到聊天框時包含可點擊的法術鏈接."
L.general_test = "測試"
L.general_test_desc = "測試Cascade."
L.general_trackHistory = "追蹤歷史"
L.general_trackHistory_desc = "追蹤和保存最多的傷害和治療事件."
L.general_history = "歷史"
L.general_history_desc = "顯示歷史框體."
L.general_timestamp = "時間戳"
L.general_timestamp_desc = "發送戰鬥事件到聊天框時包含時間."
L.general_milliseconds = "精確到毫秒"
L.general_milliseconds_desc = "時間戳精確到毫秒."

-- Frame --
L.frame_configure = "配置框體"
L.frame_advanced = "高級"
L.frame_locked = "鎖定框體"
L.frame_locked_desc = "鎖定框體."
L.frame_showLabels = "顯示標籤"
L.frame_showLabels_desc = "顯示團隊/小隊標籤."
L.frame_flipEventSides = "翻轉事件顯示到另側"
L.frame_flipEventSides_desc = "翻轉事件顯示到另壹側, 目標事件顯示在左邊, 玩家事件顯示在右邊."
L.frame_reverseScrollDir = "反轉滾動方向"
L.frame_reverseScrollDir_desc = "反轉事件的滾動方向."
L.frame_frameHeight = "框體高"
L.frame_frameHeight_desc = "框體的高度."
L.frame_font = "字體"
L.frame_fontSize = "字體尺寸"
L.frame_overrideFontSize = "覆蓋字體尺寸"
L.frame_overrideFontSize_desc = "覆蓋字體尺寸. 預設情況下, Cascade將依據框體的高度自動縮放字體尺寸."
L.frame_petOffset = "寵物事件的座標"
L.frame_petOffset_desc = "縮進寵物事件的位置."
L.frame_petAlpha = "寵物事件的透明度"
L.frame_petAlpha_desc = "寵物事件的透明度."
L.frame_tooltips = "提示訊息"
L.frame_tooltips_desc = "在事件框體開啟提示訊息."
L.frame_tooltipAnchor = "提示訊息錨點"
L.frame_font_header = "字體"
L.frame_pet_header = PET
L.frame_fading_header = "漸隱"
L.frame_fadeDelay = "漸隱延遲"
L.frame_fadeDelay_desc = "設定超過一定秒數後開始漸隱框體. 設定 0 為禁用漸隱事件."
L.frame_fadeOutOfCombat = "戰鬥狀態漸隱"
L.frame_fadeOutOfCombat_desc = "當你不在戰鬥中時漸隱整個框體."
L.frame_alpha = "框體透明度"
L.frame_alpha_desc = "設置框體的透明度."
L.frame_bgTexture = "背景材質"
L.frame_borderTexture = "邊框材質"
L.frame_tile = "平鋪背景"
L.frame_tileSize = "平鋪大小"
L.frame_edgeSize = "邊框厚度"
L.frame_inset = "邊框內距"

-- Events --
L.events_info = "自定義 Cascade 框體中顯示的事件."
L.events_PET = PET
L.events_PET_desc = "顯示玩家控制的寵物或臨時寵物造成的所有傷害或治療事件."
L.events_VEHICLE = "載具"
L.events_VEHICLE_desc = "顯示玩家控制的載具造成的所有傷害或治療事件."
L.events_OVERHEALING = "過量治療"
L.events_OVERHEALING_desc = "當顯示治療事件時顯示過量治療的總數."
L.events_POWER = "能力"
L.events_POWER_desc = "顯示包含任何能力類型的所有事件. (法力, 怒氣, 等等.)"
L.events_DISPELS = DISPELS
L.events_DISPELS_desc = "顯示所有驅散事件."
L.events_INTERRUPTS = INTERRUPTS
L.events_INTERRUPTS_desc = "顯示所有打斷事件."
L.events_KILLS = KILLS
L.events_KILLS_desc = "顯示死亡或擊殺事件."
L.events_auras_spacer = AURAS
L.events_BUFF_GAINS = "Buff 獲得"
L.events_BUFF_FADES = " Buff 消失"
L.events_DEBUFF_GAINS = "Debuff 獲得"
L.events_DEBUFF_FADES = " Debuff 消失"
L.events_misc_spacer = "雜項事件"
L.events_COMBAT = COMBAT
L.events_COMBAT_desc = "顯示進入戰鬥和離開戰鬥標識."
L.events_COMBAT_SUMMARY = "戰鬥概要"
L.events_COMBAT_SUMMARY_desc = "顯示上壹場戰鬥的所有傷害和治療數據的簡單總結."
L.events_DURABILITY = DURABILITY
L.events_EXPERIENCE = "經驗"
L.events_HONOR = HONOR
L.events_REPUTATION = REPUTATION
L.events_SKILLUPS = SKILLUPS

-- Colors --
L.colors_spell = SPELLS
L.colors_incoming = "承受"
L.colors_outgoing = "輸出"
L.colors_misc = "雜項"
L.colors_frame = "框體"

L.colors_spell_bySchool = COLOR_BY_SCHOOL
L.colors_spell_bySchool_desc = "基於法術系別的著色事件."
L.colors_spell_addSchool = "添加法術系別"
L.colors_spell_remSchool = "移除法術系別"
L.colors_multischool = "多法術系別"
L.colors_multischool_info = "從下拉列表中選擇一個法術系別來覆蓋為多法術系別的預設著色行為."

L.colors_hit = HIT
L.colors_heal = "治療"
L.colors_spell = SPELLS
L.colors_miss = MISS
L.colors_buffs = "Buff"
L.colors_debuffs = "Debuff"
L.colors_power = "能力"

L.colors_frame = "背景"
L.colors_border = "背景邊框"
L.colors_text = "文字顏色"
L.colors_combat = COMBAT
L.colors_death = "死亡"
L.colors_experience = "經驗"
L.colors_honor = HONOR
L.colors_info = "訊息"
L.colors_interrupt = INTERRUPTS
L.colors_reputation = REPUTATION

-- Spam Control --
L.spamControl_info = "垃圾訊息控制器允許妳過濾出總的法術中的不同事件."
L.spamControl_DAMAGE = DAMAGE
L.spamControl_HEAL = "治療"
L.spamControl_POWER = "能力"
L.spamControl_abbreviate = "刪節法術"
L.spamControl_blacklist_label = "黑名單"
L.spamControl_addBlacklistSpell = "添加壹個法術到黑名單"
L.spamControl_addBlacklistSpell_desc = "添加壹個法術名字或法術ID到黑名單."
L.spamControl_delBlacklistSpell = "從黑名單中移除"

L.spamControl_addBlacklistSpell_noid_msg = "法術ID %d 已找到."
L.spamControl_addBlacklistSpell_msg = "添加法術 %s 到黑名單."
L.spamControl_delBlacklistSpell_msg = "從黑名單移除法術 %s ."

-- Aura Filter --
L.auraFilter_info = "光環過濾器允許妳過濾基於施放者的Buff/Debuff."
L.auraFilter_buffFilters = "隱藏Buff:"
L.auraFilter_debuffFilters = "隱藏Debuff:"
L.auraFilter_self = "自身"
L.auraFilter_party_raid = "小隊/團隊"
L.auraFilter_outsider = "戶外"
