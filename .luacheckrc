exclude_files = {'media/**'}
std = 'lua51'
max_line_length = 350
read_globals = {
    'C_AddOns', 'C_SkillInfo', 'C_Traits', 'Constants', 'CreateFrame', 'DEFAULT_CHAT_FRAME',
    'EVALUATION_TREE_FLAG_PROGRESS_BAR', 'GameTooltip', 'GetAchievementCriteriaInfo',
    'GetAchievementInfo', 'GetAchievementNumCriteria', 'GetBuildInfo', 'GetCategoryInfo',
    'GetCategoryList', 'GetCategoryNumAchievements', 'GetServerTime', 'LegacySystemFrame',
    'ShowLegacyChallenge', 'ToggleLegacySystemUI', 'UIParent', 'UnitClass', 'UnitLevel',
    'UnitXP', 'UnitXPMax', 'bit',
}
globals = {'KwikLegacyDB', 'SLASH_KWIKLEGACY1', 'SLASH_KWIKLEGACY2', 'SlashCmdList'}
files['tests/*.lua'] = {globals = {
    'C_AddOns','C_SkillInfo','C_Traits','Constants','CreateFrame','DEFAULT_CHAT_FRAME',
    'EVALUATION_TREE_FLAG_PROGRESS_BAR','GetAchievementCriteriaInfo','GetAchievementInfo',
    'GetAchievementNumCriteria','GetBuildInfo','GetCategoryInfo','GetCategoryList',
    'GetCategoryNumAchievements','GetServerTime','KwikLegacyDB','LegacySystemFrame',
    'SlashCmdList','UIParent','UnitClass','UnitLevel','UnitXP','UnitXPMax','bit',
    'ShowLegacyChallenge','ToggleLegacySystemUI','GameTooltip',
}}
