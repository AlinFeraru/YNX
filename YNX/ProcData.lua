-- Damage-attributed procs supplied by Azeroth Survivors' own meter.
-- The documented proc=1 marker is authoritative.  No fabricated talent nodes,
-- proc activation counts, chance estimates, cooldowns or talent-tree inference.
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
        if type(r)=="table" and type(r.name)=="string" and r.name~="" and
            (r.proc==1 or r.proc==true) then
            table.insert(result,{name=r.name,dmg=tonumber(r.dmg) or 0,
                dps=tonumber(r.dps) or 0,share=tonumber(r.share) or 0,proc=1});
        end
    end
    table.sort(result,function(a,b) return a.dmg>b.dmg end);
    return result;
end
function ABA.TrackedProcs()
    local chosen=ABA.ProcProfile();local rows=ABA.ProcRows();local result={};
    for i=1,table.getn(rows) do
        if chosen[rows[i].name] then table.insert(result,rows[i]) end
    end
    return result;
end
function ABA.ProcIcon(row)
    -- Use the catalog when a damage source matches a known spell key.
    -- Otherwise show a neutral jewel, not an invented talent icon.
    local name=string.lower(tostring(row and row.name or ""));
    local normalized=string.gsub(name,"[^%a%d]","");
    for key,item in pairs(ABA.catalog or {}) do
        if string.gsub(string.lower(item[1]),"[^%a%d]","")==normalized then
            return ABA.Icon(key)
        end
    end
    return "Interface\\Icons\\INV_Misc_Gem_Amethyst_02";
end
