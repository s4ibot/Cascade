-- ruRU locales kindly provided by:
--		StingerSoft
--
-- Last updated: 2010-01-31T20:02:15Z

local L = LibStub("AceLocale-3.0"):NewLocale("Cascade", "ruRU")
if not L then return end

L.Cascade_tooltip = "|cffeda55fКлик|r - открывает окно истории.\n|cffeda55fПравый-клик|r - открывает настройки."

-- COMBAT_LOG_EVENT_UNFILTERED
L.DISPELLED = "Рассеяно: "

-- Combat Summary
L.CombatEnded = "Бой закончен спустя %s"
L.dmgIn = "Входящий урон: %s (%.1f)"
L.dmgOut = "Исходящий урон: %s (%.1f)"
L.healIn = "Входящее лечение: %s (%.1f)"
L.healOut = "Исходящее лечение: %s (%.1f)"

-- Right click menu
L["Link Event"] = "Ссылка события"
L["Link Clean Event"] = "Ссылка чистого события"
L["Link Spell"] = "Ссылка заклинания"
L["Link Hit"] = "Ссылка попадания"
L["Link Crit"] = "Ссылка крит.удара"
L["Link Hit Spell"] = "Ссылка попадания заклинанием"
L["Link Crit Spell"] = "Ссылка попадания крит.удара закл."
L["Delete Spell"] = "Удалить заклинание"

-- Cascade History
L.RESET = RESET
L.DAMAGE_IN = "Получено урона"
L.DAMAGE_OUT = "Нанесено урона"
L.HEAL_IN = "Получено лечения"
L.HEAL_OUT = "Нанесено лечения"


---------------------------------------------------
--------------------- Options ---------------------
---------------------------------------------------

-- Headers
L.options_general = GENERAL
L.options_frame = "Окно"
L.options_events = EVENTS_LABEL
L.options_colors = COLORS
L.options_spamControl = "Контроль спама"
L.options_auraFilter = "Фильтры аур"

-- General --
L.Cascade_desc = "Cascade - это компактный журнал боя написанный Grayhoof'ом EavesDrop."
L.general_includeSpellLinks = "Включая ссылки заклинаний"
L.general_includeSpellLinks_desc = "При выводе событий в чат, ссылки на способности будут кликабельными."
L.general_test = "Тест"
L.general_test_desc = "Выводит демонстрационные события в окне Cascade."
L.general_trackHistory = "Вести историю"
L.general_trackHistory_desc = "Вести и хранить историю событий большого урона и лечения."
L.general_history = "История"
L.general_history_desc = "Показать окно истории."
L.general_timestamp = "Время"
L.general_timestamp_desc = "Отображать время для событий журнала боя в подсказках а также, когда события выводятся чат."
L.general_milliseconds = "Миллисекунды"
L.general_milliseconds_desc = "Добавить миллисекунды к времени для точности."

-- Frame --
-- L.frame_configure = "Configure Frame"
L.frame_advanced = "Дополнительно"
L.frame_locked = "Закрепить окно"
L.frame_locked_desc = "Блокировка окна от перемещения и изменения размера."
L.frame_showLabels = "Показать заголовки"
L.frame_showLabels_desc = "Показывать обозначения игрок/цель."
L.frame_flipEventSides = "Сменить стороны"
L.frame_flipEventSides_desc = "Сменяет стороны событий, это значит события цели будут отображаться с лева а события игрока с права."
L.frame_reverseScrollDir = "Обратить прокрутку"
L.frame_reverseScrollDir_desc = "Обращает прокрутку в противоположную сторону, с верха вниз."
L.frame_frameHeight = "Высота окна"
L.frame_frameHeight_desc = "Установка высоты индивидуального окна события."
L.frame_font = "Шрифт"
L.frame_fontSize = "Размер шрифта"
L.frame_overrideFontSize = "Замена размера шрифта"
L.frame_overrideFontSize_desc = "Замещение размера шрифта. По умолчанию, Cascade автоматически устанавливает масштаб шрифта в соответствии с высотой окна."
L.frame_petOffset = "Смещение питомца"
L.frame_petOffset_desc = "Настройка отступа событий питомца."
L.frame_petAlpha = "Прозрачность питомца"
L.frame_petAlpha_desc = "Установка прозрачности событий связанных с питомцем."
L.frame_tooltips = "Подсказки"
L.frame_tooltips_desc = "Включение подсказок в окне событий."
L.frame_tooltipAnchor = "Привязка подсказок"
L.frame_font_header = "Шрифт"
L.frame_pet_header = PET
L.frame_fading_header = "Исчезновение"
L.frame_fadeDelay = "Задержка"
L.frame_fadeDelay_desc = "Установите время в секундах которое должно пройти перед началом исчезновения окна. Значение 0 отключает исчезновение."
L.frame_fadeOutOfCombat = "Вне боя"
L.frame_fadeOutOfCombat_desc = "Исчезновение окна, когда вы находитесь не в бою."
L.frame_alpha = "Прозрачность окна"
L.frame_alpha_desc = "Регулировка прозрачности окна."
L.frame_bgTexture = "Текстура фона"
L.frame_borderTexture = "Текстура границы"
L.frame_tile = "Черепичный фон"
L.frame_tileSize = "Размер черепицы"
L.frame_edgeSize = "Толщина границы"
L.frame_inset = "Вставка границы"

-- Events --
L.events_info = "Настройка отображаемых событий в окне Cascade."
L.events_PET = PET
L.events_PET_desc = "Отображать весь урон и лечение питомца игрока или временного питомца."
L.events_VEHICLE = "Транспорт"
L.events_VEHICLE_desc = "Отображать весь урон и лечение управляемого игроком транспорта."
L.events_OVERHEALING = "Избыточное лечение"
L.events_OVERHEALING_desc = "Отображать значение избыточного лечения (если таковые имеются) при отображении событий лечения."
L.events_POWER = "Энергия"
L.events_POWER_desc = "Отображать все события в которых упоминается тип энергии. (Мана, Ярость, и т.д.)"
L.events_DISPELS = DISPELS
L.events_DISPELS_desc = "Отображать все события рассеивания."
L.events_INTERRUPTS = INTERRUPTS
L.events_INTERRUPTS_desc = "Отображать все события прерывания."
L.events_KILLS = KILLS
L.events_KILLS_desc = "Отображать события смерти и события смертельного удара."
L.events_auras_spacer = AURAS
L.events_BUFF_GAINS = "Получение баффа"
L.events_BUFF_FADES = " Спадение баффа"
L.events_DEBUFF_GAINS = "Получение дебаффа"
L.events_DEBUFF_FADES = " Спадение дебаффа"
L.events_misc_spacer = "Различные события"
L.events_COMBAT = COMBAT
L.events_COMBAT_desc = "Отображать метки начала(входа) в бой и окончание боя (выход)."
L.events_COMBAT_SUMMARY = "Итог боя"
L.events_COMBAT_SUMMARY_desc = "Отображать суммарный итог боя, сколько было получено/нанесено урона и лечения за последней бой."
L.events_DURABILITY = DURABILITY
L.events_EXPERIENCE = "Опыт"
L.events_HONOR = HONOR
L.events_REPUTATION = REPUTATION
L.events_SKILLUPS = SKILLUPS

-- Colors --
L.colors_spell = SPELLS
L.colors_incoming = "Входящее"
L.colors_outgoing = "Исходящее"
L.colors_misc = "Разное"
L.colors_frame = "Окно"

L.colors_spell_bySchool = COLOR_BY_SCHOOL
L.colors_spell_bySchool_desc = "Окраска событий в соответствии с школой заклинания."
-- L.colors_spell_addSchool = "Add School"
-- L.colors_spell_remSchool = "Remove School"
-- L.colors_multischool = "Multi-school"
-- L.colors_multischool_info = "Adding a school from the dropdown below will allow you to override Cascade's default color behavior for multi-school spells."

L.colors_hit = HIT
L.colors_heal = "Лечение"
L.colors_spell = SPELLS
L.colors_miss = MISS
L.colors_buffs = "Бафф"
L.colors_debuffs = "Дебафф"
L.colors_power = "Энергия"

L.colors_frame = "Фон"
L.colors_border = "Края фона"
L.colors_text = "Цвет текста"
L.colors_combat = COMBAT
L.colors_death = "Умер"
L.colors_experience = "Опыт"
L.colors_honor = HONOR
L.colors_info = "Инфо"
L.colors_interrupt = INTERRUPTS
L.colors_reputation = REPUTATION

-- Spam Control --
L.spamControl_info = "Спам контроль позволяет отфильтровать различные события основываясь на количестве заклинания.\n\nЗаклинания в черном списке не будут отображаться."
L.spamControl_DAMAGE = DAMAGE
L.spamControl_HEAL = "Лечение"
L.spamControl_POWER = "Энергия"
L.spamControl_abbreviate = "Сокращать заклинания"
L.spamControl_blacklist_label = "Черный список"
L.spamControl_addBlacklistSpell = "Добавить заклинание в черный список"
L.spamControl_addBlacklistSpell_desc = "Если хотите добавить заклинание в черный список, введите его название или его ID."
L.spamControl_delBlacklistSpell = "Удалить заклинание из черного списка"

L.spamControl_addBlacklistSpell_noid_msg = "ID заклинания %d найдено."
L.spamControl_addBlacklistSpell_msg = "Заклинание %s добавлено в черный список."
L.spamControl_delBlacklistSpell_msg = "Заклинание %s удалено из черного списка."

-- Aura Filter --
L.auraFilter_info = "Фильтрация аур позволяет отфильтровать баффы/дебаффы основываясь на оригинальных баффах/дебаффах заклинателя."
L.auraFilter_buffFilters = "Скрыть баффы от:"
L.auraFilter_debuffFilters = "Скрыть дебаффы от:"
L.auraFilter_self = "Свои"
L.auraFilter_party_raid = "Группа/Рейд"
L.auraFilter_outsider = "Со стороны"
