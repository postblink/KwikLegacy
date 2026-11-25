-- KwikLegacy showcase fixture: synthetic Legacy challenge data for the Forever UI simulator.
-- Challenge names follow the public Legacy guides; every progress value is invented.
local LC = Constants.LegacyConsts
local CLASS_CATS = {WARRIOR=94101, MAGE=94107, DRUID=94109}
for token, id in pairs(CLASS_CATS) do LC['LEGACY_DEFAULT_CATEGORY_' .. token] = id end

local ICON = {
  druid='Interface\\Icons\\ClassIcon_Druid', warrior='Interface\\Icons\\ClassIcon_Warrior', mage='Interface\\Icons\\ClassIcon_Mage',
  tailor='Interface\\Icons\\Trade_Tailoring', enchant='Interface\\Icons\\Trade_Engraving', alch='Interface\\Icons\\Trade_Alchemy',
  dungeon='Interface\\Icons\\INV_Misc_Map_01', dungeon2='Interface\\Icons\\INV_Misc_Map02', raid='Interface\\Icons\\INV_Misc_Head_Dragon_01',
  pvp='Interface\\Icons\\INV_BannerPVP_02', honor='Interface\\Icons\\Achievement_PVP_A_03', explore='Interface\\Icons\\INV_Misc_Spyglass_03',
  quest='Interface\\Icons\\INV_Misc_Book_09', wsg='Interface\\Icons\\INV_Misc_Rune_07',
}
-- c = criterion {text, completed, quantity, required, bar, asset}
local function crit(text, done, q, r, bar, asset) return {text=text, done=done, q=q or (done and 1 or 0), r=r or 1, bar=bar, asset=asset or 0} end
local categories = {
  {id=94100, name='Classes', parent=-1},
  {id=CLASS_CATS.WARRIOR, name='Warrior', parent=94100},
  {id=CLASS_CATS.MAGE, name='Mage', parent=94100},
  {id=CLASS_CATS.DRUID, name='Druid', parent=94100},
  {id=94200, name='Tradeskills', parent=-1},
  {id=94300, name='Player vs. Player', parent=-1},
  {id=94400, name='Adventure', parent=-1},
  {id=94500, name='Dungeons', parent=-1},
  {id=94600, name='Raids', parent=-1},
}
local A = {}
local function add(cat, id, name, desc, icon, completed, mine, criteria)
  A[#A+1] = {cat=cat, id=id, name=name, desc=desc, icon=icon, completed=completed, mine=mine, criteria=criteria}
end
local D = CLASS_CATS.DRUID
add(D, 95001, 'Novice Druid', 'Reach level 25 on a Druid for the first time.', ICON.druid, true, true, {crit('Reach level 25', true)})
add(D, 95002, 'Experienced Druid', 'Reach level 45 on a Druid for the first time.', ICON.druid, false, false, {crit('Reach level 45', false)})
add(D, 95003, 'Master Druid', 'Reach level 60 on a Druid for the first time.', ICON.druid, false, false, {crit('Reach level 60', false)})
add(CLASS_CATS.WARRIOR, 95011, 'Novice Warrior', 'Reach level 25 on a Warrior for the first time.', ICON.warrior, true, false, {crit('Reach level 25', true)})
add(CLASS_CATS.MAGE, 95021, 'Novice Mage', 'Reach level 25 on a Mage for the first time.', ICON.mage, false, false, {crit('Reach level 25', false)})
add(94200, 95101, 'Journeyman Tailor', 'Reach 150 skill in Tailoring for the first time.', ICON.tailor, true, true, {crit('Tailoring 150', true, 1, 1, false, 197)})
add(94200, 95102, 'Expert Tailor', 'Reach 225 skill in Tailoring for the first time.', ICON.tailor, true, true, {crit('Tailoring 225', true, 1, 1, false, 197)})
add(94200, 95103, 'Artisan Tailor', 'Reach 300 skill in Tailoring for the first time.', ICON.tailor, false, false, {crit('Tailoring 300', false, 0, 1, false, 197)})
add(94200, 95111, 'Journeyman Enchanter', 'Reach 150 skill in Enchanting for the first time.', ICON.enchant, true, true, {crit('Enchanting 150', true, 1, 1, false, 333)})
add(94200, 95112, 'Expert Enchanter', 'Reach 225 skill in Enchanting for the first time.', ICON.enchant, false, false, {crit('Enchanting 225', false, 0, 1, false, 333)})
add(94200, 95121, 'Journeyman Alchemist', 'Reach 150 skill in Alchemy for the first time.', ICON.alch, false, false, {crit('Alchemy 150', false, 0, 1, false, 171)})
add(94300, 95201, 'Rank 3', 'Reach the rank of Sergeant in the Player vs. Player Honor System.', ICON.honor, false, false, {crit('Honor rank', false, 2, 3, true)})
add(94300, 95202, 'Field of Honor: Week 4', 'Complete Week 4 of the Field of Honor Journey.', ICON.pvp, false, false, {crit('Weeks completed', false, 3, 4, true)})
add(94300, 95203, 'Master of Warsong Gulch', 'Reach exalted reputation with the Warsong Outriders or Silverwing Sentinels.', ICON.wsg, false, false, {crit('Reputation', false, 21000, 42000, true)})
add(94400, 95301, 'Explorer', 'Have a character with the Explore Azeroth achievement.', ICON.explore, true, false, {crit('Explore Azeroth', true)})
add(94400, 95302, 'Lord Valthalak Laid to Rest', 'Complete the questline beginning with An Earnest Proposition, and ending with Saving the Best for Last.', ICON.quest, false, false,
  {crit('An Earnest Proposition', true), crit('Components of Importance', false), crit('Bodley\'s Unfortunate Fate', false), crit('Saving the Best for Last', false)})
add(94500, 95401, 'Novice Spelunker', 'Complete the following dungeons.', ICON.dungeon, false, false,
  {crit('Ragefire Chasm or Hall of Thanes', true), crit('Wailing Caverns', true), crit('Ruins of Lordaeron', true), crit('The Deadmines', true),
   crit('Excavation Site: Wetlands', true), crit('Shadowfang Keep', false)})
add(94500, 95402, 'Experienced Spelunker', 'Complete the following dungeons.', ICON.dungeon2, false, false,
  {crit('City of Dalaran', true), crit('Gnomeregan', false), crit('Scarlet Monastery: Graveyard', true), crit('Scarlet Monastery: Armory', true),
   crit('Razorfen Kraul', true), crit('Blackfathom Deeps', true), crit('The Drowned City', false), crit('Scarlet Monastery: Library', true),
   crit('Scarlet Monastery: Cathedral', true), crit("Krol'dok Stronghold", false)})
add(94600, 95501, 'Conqueror of the Lair', 'Defeat Onyxia.', ICON.raid, false, false, {crit('Onyxia', false)})

-- Completed challenges first within a category, matching GetChallengeIndices' assumption.
local byCat, byId = {}, {}
for _, a in ipairs(A) do byCat[a.cat] = byCat[a.cat] or {}; byId[a.id] = a end
for _, a in ipairs(A) do if a.completed then table.insert(byCat[a.cat], a) end end
for _, a in ipairs(A) do if not a.completed then table.insert(byCat[a.cat], a) end end
local catById = {}
for _, c in ipairs(categories) do catById[c.id] = c end

local function info(a)
  return a.id, a.name, 10, a.completed, a.completed and 11 or nil, a.completed and 24 or nil, a.completed and 26 or nil,
    a.desc, 0, a.icon, '', false, a.mine, a.completed and (a.mine and 'Elunara' or 'Brakk') or nil, false
end
function GetCategoryList() local ids = {} for _, c in ipairs(categories) do ids[#ids+1] = c.id end return ids end
function GetCategoryInfo(id) local c = catById[id]; if c then return c.name, c.parent, 0 end end
function GetCategoryNumAchievements(id)
  local list = byCat[id] or {}; local done = 0
  for _, a in ipairs(list) do if a.completed then done = done + 1 end end
  return #list, done, #list - done
end
function GetAchievementInfo(a1, a2)
  local a = a2 and (byCat[a1] or {})[a2] or byId[a1]
  if a then return info(a) end
end
function GetAchievementCategory(id) local a = byId[id]; return a and a.cat end
function GetAchievementNumCriteria(id) local a = byId[id]; return a and #a.criteria or 0 end
function GetAchievementCriteriaInfo(id, i)
  local a = byId[id]; local c = a and a.criteria[i]; if not c then return end
  local qs = c.bar and (c.q .. ' / ' .. c.r) or ''
  return c.text, 0, c.done, c.q, c.r, nil, c.bar and 1 or 0, c.asset, qs, id * 100 + i, true
end
function GetAchievementLink(id) local a = byId[id]; return a and ('[' .. a.name .. ']') end
function GetNumFilteredAchievements() return #A end
function GetFilteredAchievementID(i) return A[i] and A[i].id end
C_AchievementInfo.IsValidAchievement = function(id) return byId[id] ~= nil end
C_Traits.GetTraitCurrencyForAchievement = function(_, id) return byId[id] and 1 or 0 end
C_MajorFactions.GetCurrentRenownLevel = function() return 6 end
function UnitClass() return 'Druid', 'DRUID', 11 end
function UnitLevel() return 43 end
function UnitXP() return 6000 end
function UnitXPMax() return 10000 end
local skills = {[197]={skillID=197, name='Tailoring', rank=288, maxRank=300}, [333]={skillID=333, name='Enchanting', rank=150, maxRank=150}}
C_SkillInfo = C_SkillInfo or {}
C_SkillInfo.GetNumSkillLines = function() return 0 end
C_SkillInfo.GetSkillLineInfoByID = function(id) return skills[id] end

assert(C_AddOns.LoadAddOn('Blizzard_LegacySystem'))
assert(LegacySystemFrame and KwikLegacy and KwikLegacy.panel, 'Legacy frame or KwikLegacy hook missing')
ShowUIPanel(LegacySystemFrame)
LegacySystemFrame:SelectPage(2)
LegacySystemFrame:ClearAllPoints(); LegacySystemFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 40, -60)
-- Keep only the Legacy window, the KwikLegacy panel and the tooltip on screen.
local keep = {[LegacySystemFrame]=true, [KwikLegacy.panel]=true, [GameTooltip]=true}
for _, child in ipairs({UIParent:GetChildren()}) do if not keep[child] and child.Hide then child:Hide() end end
function ShowcaseRefresh() LegacySystemFrame:Hide(); LegacySystemFrame:Show() end
function ShowcaseRow(name)
  for _, child in ipairs({KwikLegacy.panel:GetChildren()}) do
    if child.record and child.record.name == name then return child end
  end
end

ShowcaseData = {skills = skills, byId = byId}
