-- YNX: class-independent damage-proc tracking.
-- The game's meter identifies real damage proc entries via proc=1.
-- Resolve their artwork from source data and native talents/spellbook if possible.
local FALLBACK="Interface\\AddOns\\YNX\\Media\\Modern\\proc_generic.tga";
local talentIcons={};local talentLastScan=-1000;local talentLastClass=nil;
local function norm(s) return string.gsub(string.lower(tostring(s or "")),"[^%a%d]","") end
local function refreshTalentIcons()
    if type(GetTalentInfo)~="function" then return end
    local now=type(GetTime)=="function" and GetTime() or 0;
    local class=ABA.ClassKey and ABA.ClassKey() or "other";
    if class==talentLastClass and now-talentLastScan<20 then return end
    talentLastClass=class;talentLastScan=now;talentIcons={};
    local tabs=3;
    if type(GetNumTalentTabs)=="function" then
        local ok,n=pcall(GetNumTalentTabs);if ok and type(n)=="number" then tabs=math.min(math.max(n,0),12) end
    end
    for tab=1,tabs do
        local count=48;
        if type(GetNumTalents)=="function" then
            local ok,n=pcall(GetNumTalents,tab);if ok and type(n)=="number" then count=math.min(math.max(n,0),80) end
        end
        for i=1,count do
            local ok,name,icon=pcall(GetTalentInfo,tab,i);
            if ok and type(name)=="string" and type(icon)=="string" and icon~="" then talentIcons[norm(name)]=icon end
        end
    end
end
function ABA.ProcProfile()
    local d=ABA.DB();local class=ABA.ClassKey();
    if type(d.procProfiles)~="table" then d.procProfiles={} end
    if type(d.procProfiles[class])~="table" then d.procProfiles[class]={} end
    return d.procProfiles[class];
end
function ABA.ProcRows()
    local result={};local phase=ABA.Phase();
    if phase=="ready" or not phase then return result end
    local rows=nil;
    if type(AZS_GetMeter)=="function" then
        local ok,lines=pcall(AZS_GetMeter);
        if ok and type(lines)=="table" then rows=lines end
    end
    if not rows and type(AZS_METER)=="table" then rows=AZS_METER end
    if type(rows)~="table" then return result end
    for i=1,table.getn(rows) do
        local r=rows[i];
        if type(r)=="table" and type(r.name)=="string" and r.name~="" and (r.proc==1 or r.proc==true) then
            local icon=r.icon or r.texture or r.tex or r.path or r.spellIcon;
            table.insert(result,{name=r.name,dmg=tonumber(r.dmg) or 0,
                dps=tonumber(r.dps) or 0,share=tonumber(r.share) or 0,proc=1,
                icon=type(icon)=="string" and icon or nil});
        end
    end
    table.sort(result,function(a,b) return a.dmg>b.dmg end);
    return result;
end
function ABA.TrackedProcs()
    local chosen=ABA.ProcProfile();local rows=ABA.ProcRows();local result={};
    for i=1,table.getn(rows) do if chosen[rows[i].name] then table.insert(result,rows[i]) end end
    return result;
end
function ABA.ProcIcon(row)
    local key=norm(row and row.name);
    if type(row)=="table" and type(row.icon)=="string" and row.icon~="" then return row.icon end
    if ABA.bookIcons and ABA.bookIcons[key] then return ABA.bookIcons[key] end
    refreshTalentIcons();if talentIcons[key] then return talentIcons[key] end
    -- A source can share the name of a currently learned automatic spell.
    local spells=type(AZS_SPELLS)=="table" and AZS_SPELLS or {};
    for i=1,table.getn(spells) do
        local sp=spells[i];
        if type(sp)=="table" and sp.key then
            local spellName=ABA.SpellName and ABA.SpellName(sp) or sp.key;
            if norm(spellName)==key or norm(sp.key)==key then
                local icon=ABA.SpellIcon and ABA.SpellIcon(sp) or nil;
                if type(icon)=="string" and icon~="" then return icon end
            end
        end
    end
    for catalogKey,item in pairs(ABA.catalog or {}) do
        if type(item)=="table" and norm(item[1])==key then
            local icon=ABA.Icon and ABA.Icon(catalogKey) or nil;
            if type(icon)=="string" and icon~="" then return icon end
        end
    end
    -- Deliberately neutral: never label an unknown effect with another class's spell.
    return FALLBACK;
end
