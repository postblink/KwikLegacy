-- Minimal full-manifest load and lifecycle harness with synthetic APIs.
local frames={}
local allFrames={}
local already=arg[1]=='already'
local reads=0
local clicked
local opened=0
local completed=false
local messages={}
local methods={}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:HookScript(k,v) self.scripts[k]=v end
function methods:RegisterEvent(e) if e=='PLAYER_LEVEL_UP' then error('fixture event failure') end; self.events[e]=true end
function methods:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:IsShown() return self.shown end
function methods:SetPoint(...) self.point={...} end
function methods:SetText(text) self.text=text end
function methods:CreateTexture() local _=self; return CreateFrame('Texture') end
function methods:CreateFontString() local _=self; return CreateFrame('FontString') end
function CreateFrame(_,name,parent)
    local f={scripts={},events={},parent=parent}
    setmetatable(f,{__index=function(_,k) if methods[k] then return methods[k] end; if type(k)=='string' and k:match('^[A-Z]') then return function() end end end})
    if name then frames[name]=f end
    if name=='LegacySystemFrame' then f.LegacyRewardTrackTab={GetWidth=function() return 70 end} end
    allFrames[#allFrames+1]=f
    return f
end
UIParent=CreateFrame('Frame')
SlashCmdList={}
local tooltipLines={}
GameTooltip={SetOwner=function(self,owner) self.owner=owner end, SetText=function(_,text) tooltipLines={text} end,
    AddLine=function(_,text) tooltipLines[#tooltipLines+1]=text end, Show=function() end,
    IsOwned=function(self,owner) return self.owner==owner end, Hide=function() end}
DEFAULT_CHAT_FRAME={AddMessage=function(_,msg) messages[#messages+1]=msg end}
C_AddOns={IsAddOnLoaded=function() return false end}
UnitClass=function() return 'Druid','DRUID' end
UnitLevel=function() return 43 end
UnitXP=function() return 60 end
UnitXPMax=function() return 100 end
GetBuildInfo=function() return '1.60.1','71037','date',16001 end
GetServerTime=function() return 1 end
C_SkillInfo={GetNumSkillLines=function() return 0 end, GetSkillLineInfo=function() end,
    GetSkillLineInfoByID=function(id) if id==197 then return {skillID=197,name='Tailoring',rank=225,maxRank=225} end end}
Constants={LegacyConsts={LEGACY_DEFAULT_CATEGORY_DRUID=1,LEGACY_DEFAULT_CATEGORY_MAGE=2,LEGACY_POINTS_TRAIT_CURRENCY_ID=3}}
GetCategoryList=function() reads=reads+1; return {1} end
ShowLegacyChallenge=function(id) clicked=id end
ToggleLegacySystemUI=function() opened=opened+1; if LegacySystemFrame then LegacySystemFrame:Show() end end
GetCategoryInfo=function() return 'Druid',-1 end
GetCategoryNumAchievements=function() return 1 end
GetAchievementInfo=function() return 11,'Druid',1,completed,nil,nil,nil,'Reach level 45',nil,123,nil,nil,false end
GetAchievementNumCriteria=function() return 1 end
GetAchievementCriteriaInfo=function() return 'Reach level 45',0,false,0,0,nil,0,197 end
C_Traits={GetTraitCurrencyForAchievement=function() return 1 end}
bit={band=function() return 0 end}
EVALUATION_TREE_FLAG_PROGRESS_BAR=1
if already then LegacySystemFrame=CreateFrame('Frame','LegacySystemFrame') end
local addon={}
for line in io.lines('KwikLegacy.toc') do if line:match('%.lua$') then assert(loadfile(line))('KwikLegacy',addon) end end
local event=assert(frames.KwikLegacyEventFrame)
local function fire(e,...) assert(event.events[e],e); event.scripts.OnEvent(event,e,...) end
fire('ADDON_LOADED','KwikLegacy')
assert(SLASH_KWIKLEGACY1=='/kwiklegacy' and SLASH_KWIKLEGACY2=='/kl')
SlashCmdList.KWIKLEGACY('status')
assert(messages[#messages]:find('PLAYER_LEVEL_UP',1,true), 'failed registration not reported')
SlashCmdList.KWIKLEGACY('dump')
assert(KwikLegacyDB.dump and KwikLegacyDB.dump.categories[1].challenges[1].criteria[1], 'dump missing')
assert(KwikLegacyDB.dump.build[2]=='71037' and KwikLegacyDB.dump.class[2]=='DRUID')
assert(KwikLegacyDB.dump.categories[1].challenges[1].info[8]=='Reach level 45')
assert(KwikLegacyDB.dump.categories[1].challenges[1].criteria[1][1]=='Reach level 45')
assert(KwikLegacyDB.dump.assetSkills[1].id==197 and KwikLegacyDB.dump.assetSkills[1].raw[1].rank==225)
local cat=KwikLegacyDB.dump.categories[1]
KwikLegacyDB.dump.categories[2]={id=2, challenges=cat.challenges}
assert(#addon.Records(KwikLegacyDB.dump)==1, 'non-player class not excluded')
KwikLegacyDB.dump.categories[2]=nil
if not already then
    LegacySystemFrame=CreateFrame('Frame','LegacySystemFrame')
    fire('ADDON_LOADED','Blizzard_LegacySystem')
end
assert(addon.panel, 'load-on-demand hook missing')
assert(addon.panel.point[4]==78, 'panel did not clear tab width')
SlashCmdList.KWIKLEGACY(''); assert(opened==1, 'slash did not open Legacy UI')
assert(addon.panel:IsShown(), 'panel did not follow parent')
local row
for _,f in ipairs(allFrames) do if f.record then row=f; break end end
assert(row and row.record.id==11, 'row missing')
assert(row.detail.text:find('Awards Point',1,true) and not row.detail.text:find('pts',1,true), 'points label')
row.scripts.OnClick(row); assert(clicked==11, 'row click not routed')
row.scripts.OnEnter(row); assert(tooltipLines[2]=='Reach level 45', 'missing tooltip criteria')
row.scripts.OnLeave(row)
completed=true; fire('ACHIEVEMENT_EARNED'); addon.panel.scripts.OnUpdate(addon.panel,.5)
assert(not row:IsShown(), 'completed record not hidden')
SlashCmdList.KWIKLEGACY('earned'); addon.panel.scripts.OnUpdate(addon.panel,.5)
assert(row:IsShown() and row.name.text:find('earned elsewhere',1,true), 'earned elsewhere not labelled')
assert(not row.detail.text:find('Awards',1,true), 'banked challenge must not claim a point')
local before=reads
fire('PLAYER_XP_UPDATE'); addon.panel.scripts.OnUpdate(addon.panel,.2); assert(reads==before, 'throttle')
addon.panel.scripts.OnUpdate(addon.panel,.3); assert(reads==before+1, 'refresh timer')
LegacySystemFrame:Hide(); before=reads; fire('SKILL_LINES_CHANGED'); assert(reads==before, 'hidden recompute')
LegacySystemFrame:Show(); assert(reads==before+1, 'dirty on show')
local title
for _,f in ipairs(allFrames) do
    if f.parent==addon.panel and f.scripts.OnClick and not f.bar then title=f; break end
end
assert(title, 'collapse button missing')
title.scripts.OnClick(); assert(KwikLegacyDB.collapsed and not row:IsShown(), 'collapse failed')
title.scripts.OnClick(); assert(not KwikLegacyDB.collapsed and row:IsShown(), 'expand failed')
print('full TOC lifecycle: PASS')
