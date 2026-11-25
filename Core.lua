local addonName, Addon = ...
_G[addonName] = Addon

local event = CreateFrame('Frame', 'KwikLegacyEventFrame')
local dirty, elapsed, hooked = true, 0, false
local failed, counts = {}, {criteria=0, live=0, unknown=0}
local rows = {}
local MAX_ROWS = 8 -- 52 + 8*64 fits the 575px Legacy frame
local function say(message) DEFAULT_CHAT_FRAME:AddMessage('|cffffd100KwikLegacy:|r ' .. message) end
local function pack(...) return {n=select('#', ...), ...} end
local function call(fn, ...)
    if type(fn) ~= 'function' then return {n=0} end
    local result = pack(pcall(fn, ...))
    if not result[1] then return {n=0, error=tostring(result[2])} end
    local out = {n=result.n-1}
    for i=2,result.n do out[i-1]=result[i] end
    return out
end
local function defaults()
    if type(KwikLegacyDB) ~= 'table' then KwikLegacyDB={} end
    local db=KwikLegacyDB
    if db.collapsed == nil then db.collapsed=false end
    if db.showCompleted == nil then db.showCompleted=false end
    if db.showZero == nil then db.showZero=false end
    if type(db.limit) ~= 'number' then db.limit=5 end
    db.limit=math.max(1, math.min(MAX_ROWS, math.floor(db.limit)))
end
local function professionReads()
    local result={}
    if not C_SkillInfo then return result end
    local n=call(C_SkillInfo.GetNumSkillLines)[1] or 0
    for i=1,n do
        local v=call(C_SkillInfo.GetSkillLineInfo,i)[1]
        if type(v)=='table' then result[#result+1]=v end
    end
    return result
end
local function snapshot()
    local build=call(GetBuildInfo)
    local class=call(UnitClass,'player')
    local data={build=build, timestamp=call(GetServerTime), class=class, level=call(UnitLevel,'player'), professions=professionReads(), assetSkills={}, categories={}}
    local seenSkills={}
    local categories=call(GetCategoryList)[1] or {}
    for _, id in ipairs(categories) do
        local cat={id=id, info=call(GetCategoryInfo,id), totals=call(GetCategoryNumAchievements,id), challenges={}}
        data.categories[#data.categories+1]=cat
        for i=1,(cat.totals[1] or 0) do
            local info=call(GetAchievementInfo,id,i)
            local item={info=info,criteria={}}
            cat.challenges[#cat.challenges+1]=item
            if info[1] then
                item.numCriteria=call(GetAchievementNumCriteria,info[1])
                for j=1,(item.numCriteria[1] or 0) do
                    local raw=call(GetAchievementCriteriaInfo,info[1],j)
                    item.criteria[#item.criteria+1]=raw
                    local asset=raw[8]
                    if C_SkillInfo and type(asset)=='number' and asset>0 and not seenSkills[asset] then
                        seenSkills[asset]=true
                        local skill=call(C_SkillInfo.GetSkillLineInfoByID,asset)
                        data.assetSkills[#data.assetSkills+1]={id=asset, raw=skill}
                        if type(skill[1])=='table' then data.professions[#data.professions+1]=skill[1] end
                    end
                end
            end
        end
    end
    return data
end
Addon.Snapshot=snapshot
local function records(data)
    local const=Constants and Constants.LegacyConsts or {}
    local class=data.class[2]
    local classCategory=class and const['LEGACY_DEFAULT_CATEGORY_' .. class]
    local classCategories={}
    for _, token in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'}) do
        local id=const['LEGACY_DEFAULT_CATEGORY_'..token]
        if id then classCategories[id]=true end
    end
    local ctx={classCategory=classCategory, level=data.level[1] or 0, xp=call(UnitXP,'player')[1], xpMax=call(UnitXPMax,'player')[1], professions=data.professions}
    local output={}
    counts={criteria=0, live=0, unknown=0}
    for _, cat in ipairs(data.categories) do
        if not classCategories[cat.id] or cat.id==classCategory then
            for _, item in ipairs(cat.challenges) do
                local info=item.info
                if info[1] then
                    local entry={id=info[1],name=info[2] or '?',completed=info[4],earnedByMe=info[13],description=info[8],icon=info[10],category=cat.id,criteria={}}
                    for _, c in ipairs(item.criteria) do
                        local flag=EVALUATION_TREE_FLAG_PROGRESS_BAR or 1 -- 0x1 in Blizzard Constants; dump verifies
                        local bar=bit and bit.band and type(c[7])=='number' and bit.band(c[7],flag)==flag
                        entry.criteria[#entry.criteria+1]={text=c[1],completed=c[3],quantity=c[4],required=c[5],assetID=c[8],bar=bar}
                    end
                    local progress=Addon.Progress(entry,ctx)
                    for k,v in pairs(progress) do entry[k]=v end
                    if C_Traits and const.LEGACY_POINTS_TRAIT_CURRENCY_ID then entry.points=call(C_Traits.GetTraitCurrencyForAchievement,const.LEGACY_POINTS_TRAIT_CURRENCY_ID,entry.id)[1] end
                    counts[entry.source]=counts[entry.source]+1
                    output[#output+1]=entry
                end
            end
        end
    end
    return output
end
Addon.Records=records
local function makeRow(parent, index)
    local row=CreateFrame('Button',nil,parent)
    row:SetSize(264,64); row:SetPoint('TOPLEFT',parent,'TOPLEFT',10,-48-(index-1)*64)
    row.icon=row:CreateTexture(nil,'ARTWORK'); row.icon:SetSize(30,30); row.icon:SetPoint('TOPLEFT')
    row.name=row:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); row.name:SetPoint('TOPLEFT',row.icon,'TOPRIGHT',5,0); row.name:SetWidth(220); row.name:SetJustifyH('LEFT')
    row.detail=row:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall'); row.detail:SetPoint('TOPLEFT',row.name,'BOTTOMLEFT',0,-5); row.detail:SetWidth(220); row.detail:SetJustifyH('LEFT')
    if row.detail.SetWordWrap then row.detail:SetWordWrap(false) end -- one line; the tooltip lists everything
    row.bar=CreateFrame('StatusBar',nil,row); row.bar:SetPoint('TOPLEFT',row,'TOPLEFT',35,-43); row.bar:SetSize(150,7); row.bar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar'); row.bar:SetMinMaxValues(0,1); row.bar:SetStatusBarColor(0.82,0.62,0.25)
    local track=row.bar:CreateTexture(nil,'BACKGROUND'); track:SetAllPoints(); track:SetColorTexture(0,0,0,0.55) -- shows the unfilled part
    row.points=row:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); row.points:SetPoint('LEFT',row.bar,'RIGHT',6,0); row.points:SetJustifyH('LEFT'); row.points:SetTextColor(0.4,0.9,0.4)
    row:SetScript('OnClick',function(self) if self.record and type(ShowLegacyChallenge)=='function' then ShowLegacyChallenge(self.record.id) end end)
    row:SetScript('OnEnter',function(self)
        if not self.record or not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_RIGHT'); GameTooltip:SetText(self.record.name)
        for _, name in ipairs(self.record.missing) do GameTooltip:AddLine(name,1,1,1,true) end
        GameTooltip:Show()
    end)
    row:SetScript('OnLeave',function(self) if GameTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end end)
    return row
end
local function refresh()
    if not Addon.panel or not Addon.panel:IsShown() or KwikLegacyDB.collapsed then return end
    local list=Addon.Rank(records(snapshot()),KwikLegacyDB.showCompleted,KwikLegacyDB.showZero,KwikLegacyDB.limit)
    for i=1,MAX_ROWS do
        local row=rows[i]
        local r=list[i]
        if r then
            local earned = r.completed and (r.earnedByMe == false and ' (earned elsewhere)' or
                (r.earnedByMe == nil and ' (earned; character unknown)' or ' (earned)')) or ''
            row.record=r; row.icon:SetTexture(r.icon); row.name:SetText(r.name .. (r.source=='live' and ' ~' or '') .. earned)
            row.detail:SetText(r.remaining); row.points:SetText(Addon.PointsLabel(r.points, r.completed))
            if r.fraction then row.bar:SetValue(r.fraction); row.bar:Show() else row.bar:Hide() end
            row:Show()
        else row.record=nil; row:Hide() end
    end
    Addon.panel:SetHeight(52+64*math.max(1,#list))
    dirty=false; elapsed=0
end
local function applyCollapse()
    if KwikLegacyDB.collapsed then
        for _, row in ipairs(rows) do row:Hide() end
        Addon.panel:SetHeight(36)
    else dirty=true; refresh() end
end
local function hook()
    if hooked or not LegacySystemFrame then return end
    local panel=CreateFrame('Frame',nil,UIParent,'BackdropTemplate')
    Addon.panel=panel
    local tab=LegacySystemFrame.LegacyRewardTrackTab
    local width=tab and tab.GetWidth and tab:GetWidth()
    local offset=type(width)=='number' and math.max(50,width+8) or 50
    panel:SetSize(284,100); panel:SetPoint('TOPLEFT',LegacySystemFrame,'TOPRIGHT',offset,0)
    if panel.SetBackdrop then panel:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',edgeSize=16,insets={left=4,right=4,top=4,bottom=4}}) end
    local title=CreateFrame('Button',nil,panel); title:SetSize(264,28); title:SetPoint('TOPLEFT',10,-5)
    local label=title:CreateFontString(nil,'OVERLAY','GameFontNormal'); label:SetAllPoints(); label:SetText('Closest unlocks  +/-')
    title:SetScript('OnClick',function() KwikLegacyDB.collapsed=not KwikLegacyDB.collapsed; applyCollapse() end)
    for i=1,MAX_ROWS do rows[i]=makeRow(panel,i) end
    panel:SetScript('OnUpdate',function(_,dt) if dirty and not KwikLegacyDB.collapsed then elapsed=elapsed+dt; if elapsed>=0.5 then refresh() end end end)
    LegacySystemFrame:HookScript('OnShow',function() panel:Show(); applyCollapse() end)
    LegacySystemFrame:HookScript('OnHide',function() panel:Hide() end)
    hooked=true
    if LegacySystemFrame:IsShown() then panel:Show(); applyCollapse() else panel:Hide() end
end
local function slash(message)
    defaults()
    local cmd,arg=message:match('^%s*(%S*)%s*(.-)%s*$')
    cmd=cmd:lower()
    if cmd=='status' then
        local loaded = C_AddOns and call(C_AddOns.IsAddOnLoaded,'Blizzard_LegacySystem')[1]
        say('Legacy loaded: '..tostring(loaded)..'; hooked: '..tostring(hooked)..'; sources criteria/live/unknown: '..counts.criteria..'/'..counts.live..'/'..counts.unknown..'; failed events: '..(#failed>0 and table.concat(failed,', ') or 'none'))
    elseif cmd=='dump' then KwikLegacyDB.dump=snapshot(); say('Snapshot saved; /reload to write it to disk.')
    elseif cmd=='earned' then KwikLegacyDB.showCompleted=not KwikLegacyDB.showCompleted; dirty=true; say('Show completed: '..tostring(KwikLegacyDB.showCompleted))
    elseif cmd=='zero' then KwikLegacyDB.showZero=not KwikLegacyDB.showZero; dirty=true; say('Show zero: '..tostring(KwikLegacyDB.showZero))
    elseif cmd=='rows' and tonumber(arg) then KwikLegacyDB.limit=math.max(1,math.min(MAX_ROWS,math.floor(tonumber(arg)))); dirty=true; say('Rows: '..KwikLegacyDB.limit)
    elseif cmd=='' then if type(ToggleLegacySystemUI)=='function' then if not LegacySystemFrame or not LegacySystemFrame:IsShown() then ToggleLegacySystemUI() end else say('Legacy UI unavailable.') end
    else say('Commands: status, dump, earned, zero, rows <1-'..MAX_ROWS..'>') end
end
SLASH_KWIKLEGACY1='/kwiklegacy'; SLASH_KWIKLEGACY2='/kl'; SlashCmdList.KWIKLEGACY=slash
for _, name in ipairs({'ADDON_LOADED','PLAYER_LOGIN','PLAYER_ENTERING_WORLD','CRITERIA_UPDATE','ACHIEVEMENT_EARNED','PLAYER_LEVEL_UP','PLAYER_XP_UPDATE','SKILL_LINES_CHANGED'}) do
    local ok=pcall(event.RegisterEvent,event,name)
    if not ok then failed[#failed+1]=name end
end
event:SetScript('OnEvent',function(_,name,arg)
    if name=='ADDON_LOADED' and arg==addonName then defaults(); hook()
    elseif name=='ADDON_LOADED' and arg=='Blizzard_LegacySystem' then defaults(); hook()
    elseif name=='PLAYER_LOGIN' then defaults(); hook()
    else dirty=true end
end)
