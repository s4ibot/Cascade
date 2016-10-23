-- zhCN locales kindly provided by:
--		wowui.cn
--
-- Last updated: 2010-02-02T15:36:53Z

local L = LibStub("AceLocale-3.0"):NewLocale("Cascade", "zhCN")
if not L then return end

L.Cascade_tooltip = "|cffeda55f点击|r - 打开历史框体.\n|cffeda55f右键点击|r - 打开选项."

-- COMBAT_LOG_EVENT_UNFILTERED
L.DISPELLED = "驱散: "

-- Combat Summary
L.CombatEnded = "战斗结束于 %s"
L.dmgIn = "承受伤害: %s (%.1f)"
L.dmgOut = "输出伤害: %s (%.1f)"
L.healIn = "接受治疗: %s (%.1f)"
L.healOut = "输出治疗: %s (%.1f)"

-- Right click menu
L["Link Event"] = "链接事件"
L["Link Clean Event"] = "链接洁淨事件"
L["Link Spell"] = "链接法术"
L["Link Hit"] = "链接命中"
L["Link Crit"] = "链接暴击"
L["Link Hit Spell"] = "链接命中法术"
L["Link Crit Spell"] = "链接暴击法术."
L["Delete Spell"] = "删除法术"

-- Cascade History
L.RESET = RESET
L.DAMAGE_IN = "承受伤害"
L.DAMAGE_OUT = "输出伤害"
L.HEAL_IN = "接受治疗"
L.HEAL_OUT = "输出治疗"


---------------------------------------------------
--------------------- Options ---------------------
---------------------------------------------------

-- Headers
L.options_general = GENERAL
L.options_frame = "框体"
L.options_events = EVENTS_LABEL
L.options_colors = COLORS
L.options_spamControl = "垃圾讯息控制"
L.options_auraFilter = "光环过滤器"

-- General --
L.Cascade_desc = "Cascade是一款类似于Grayhoof的EavesDrop的战斗记录增强插件."
L.general_includeSpellLinks = "包括法术链接"
L.general_includeSpellLinks_desc = "当链接事件到聊天框时包含可点击的法术链接."
L.general_test = "测试"
L.general_test_desc = "测试Cascade."
L.general_trackHistory = "追踪历史"
L.general_trackHistory_desc = "追踪和保存最多的伤害和治疗事件."
L.general_history = "历史"
L.general_history_desc = "显示历史框体."
L.general_timestamp = "时间戳"
L.general_timestamp_desc = "发送战斗事件到聊天框时包含时间."
L.general_milliseconds = "精确到毫秒"
L.general_milliseconds_desc = "时间戳精确到毫秒."

-- Frame --
L.frame_configure = "配置框体"
L.frame_advanced = "高级"
L.frame_locked = "锁定框体"
L.frame_locked_desc = "锁定框体."
L.frame_showLabels = "显示标籤"
L.frame_showLabels_desc = "显示团队/小队标籤."
L.frame_flipEventSides = "翻转事件显示到另侧"
L.frame_flipEventSides_desc = "翻转事件显示到另一侧, 目标事件显示在左边, 玩家事件显示在右边."
L.frame_reverseScrollDir = "反转滚动方向"
L.frame_reverseScrollDir_desc = "反转事件的滚动方向."
L.frame_frameHeight = "框体高"
L.frame_frameHeight_desc = "框体的高度."
L.frame_font = "字体"
L.frame_fontSize = "字体尺寸"
L.frame_overrideFontSize = "覆盖字体尺寸"
L.frame_overrideFontSize_desc = "覆盖字体尺寸. 预设情况下, Cascade将依据框体的高度自动缩放字体尺寸."
L.frame_petOffset = "宠物事件的座标"
L.frame_petOffset_desc = "缩进宠物事件的位置."
L.frame_petAlpha = "宠物事件的透明度"
L.frame_petAlpha_desc = "宠物事件的透明度."
L.frame_tooltips = "提示讯息"
L.frame_tooltips_desc = "在事件框体开启提示讯息."
L.frame_tooltipAnchor = "提示讯息锚点"
L.frame_font_header = "字体"
L.frame_pet_header = PET
L.frame_fading_header = "渐隐"
L.frame_fadeDelay = "渐隐延迟"
L.frame_fadeDelay_desc = "设定超过一定秒数后开始渐隐框体. 设定 0 为禁用渐隐事件."
L.frame_fadeOutOfCombat = "战斗状态渐隐"
L.frame_fadeOutOfCombat_desc = "当你不在战斗中时渐隐整个框体."
L.frame_alpha = "框体透明度"
L.frame_alpha_desc = "设置框体的透明度."
L.frame_bgTexture = "背景材质"
L.frame_borderTexture = "边框材质"
L.frame_tile = "平铺背景"
L.frame_tileSize = "平铺大小"
L.frame_edgeSize = "边框厚度"
L.frame_inset = "边框内距"

-- Events --
L.events_info = "自定义 Cascade 框体中显示的事件."
L.events_PET = PET
L.events_PET_desc = "显示玩家控制的宠物或临时宠物造成的所有伤害或治疗事件."
L.events_VEHICLE = "载具"
L.events_VEHICLE_desc = "显示玩家控制的载具造成的所有伤害或治疗事件."
L.events_OVERHEALING = "过量治疗"
L.events_OVERHEALING_desc = "当显示治疗事件时显示过量治疗的总数."
L.events_POWER = "能力"
L.events_POWER_desc = "显示包含任何能力类型的所有事件. (法力, 怒气, 等等.)"
L.events_DISPELS = DISPELS
L.events_DISPELS_desc = "显示所有驱散事件."
L.events_INTERRUPTS = INTERRUPTS
L.events_INTERRUPTS_desc = "显示所有打断事件."
L.events_KILLS = KILLS
L.events_KILLS_desc = "显示死亡或击杀事件."
L.events_auras_spacer = AURAS
L.events_BUFF_GAINS = "Buff 获得"
L.events_BUFF_FADES = " Buff 消失"
L.events_DEBUFF_GAINS = "Debuff 获得"
L.events_DEBUFF_FADES = " Debuff 消失"
L.events_misc_spacer = "杂项事件"
L.events_COMBAT = COMBAT
L.events_COMBAT_desc = "显示进入战斗和离开战斗标识."
L.events_COMBAT_SUMMARY = "战斗概要"
L.events_COMBAT_SUMMARY_desc = "显示上一场战斗的所有伤害和治疗数据的简单总结."
L.events_DURABILITY = DURABILITY
L.events_EXPERIENCE = "经验"
L.events_HONOR = HONOR
L.events_REPUTATION = REPUTATION
L.events_SKILLUPS = SKILLUPS

-- Colors --
L.colors_spell = SPELLS
L.colors_incoming = "承受"
L.colors_outgoing = "输出"
L.colors_misc = "杂项"
L.colors_frame = "框体"

L.colors_spell_bySchool = COLOR_BY_SCHOOL
L.colors_spell_bySchool_desc = "基于法术系别的著色事件."
L.colors_spell_addSchool = "添加法术系别"
L.colors_spell_remSchool = "移除法术系别"
L.colors_multischool = "多法术系别"
L.colors_multischool_info = "从下拉列表中选择一个法术系别来覆盖为多法术系别的预设著色行为."

L.colors_hit = HIT
L.colors_heal = "治疗"
L.colors_spell = SPELLS
L.colors_miss = MISS
L.colors_buffs = "Buff"
L.colors_debuffs = "Debuff"
L.colors_power = "能力"

L.colors_frame = "背景"
L.colors_border = "背景边框"
L.colors_text = "文字颜色"
L.colors_combat = COMBAT
L.colors_death = "死亡"
L.colors_experience = "经验"
L.colors_honor = HONOR
L.colors_info = "讯息"
L.colors_interrupt = INTERRUPTS
L.colors_reputation = REPUTATION

-- Spam Control --
L.spamControl_info = "垃圾讯息控制器允许你过滤出总的法术中的不同事件."
L.spamControl_DAMAGE = DAMAGE
L.spamControl_HEAL = "治疗"
L.spamControl_POWER = "能力"
L.spamControl_abbreviate = "删节法术"
L.spamControl_blacklist_label = "黑名单"
L.spamControl_addBlacklistSpell = "添加一个法术到黑名单"
L.spamControl_addBlacklistSpell_desc = "添加一个法术名字或法术ID到黑名单."
L.spamControl_delBlacklistSpell = "从黑名单中移除"

L.spamControl_addBlacklistSpell_noid_msg = "法术ID %d 已找到."
L.spamControl_addBlacklistSpell_msg = "添加法术 %s 到黑名单."
L.spamControl_delBlacklistSpell_msg = "从黑名单移除法术 %s ."

-- Aura Filter --
L.auraFilter_info = "光环过滤器允许你过滤基于施放者的Buff/Debuff."
L.auraFilter_buffFilters = "隐藏Buff:"
L.auraFilter_debuffFilters = "隐藏Debuff:"
L.auraFilter_self = "自身"
L.auraFilter_party_raid = "小队/团队"
L.auraFilter_outsider = "户外"
