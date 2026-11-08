-- Optional Insights panels: read-only snapshots from public AZS_* API.
-- Does not inspect native card offers, private inventory or hidden drop tables.
ABA.runSession=nil;
local function Phase() return ABA.Phase and ABA.Phase() end
local function RunTime()
    local t=type(AZS_GetRunTime)=="function" and AZS_GetRunTime() or nil;
    if type(t)=="number" then return t end
    return type(AZS_RUN)=="table" and (AZS_RUN.t or 0) or 0;
end
local function SnapshotStats()
    local out={};
    if type(AZS_STATS)=="table" then
        for _,spec in ipairs(ABA.stats or {}) do
            if type(AZS_STATS[spec.key])=="number" then out[spec.key]=AZS_STATS[spec.key] end
        end
    end
    return out;
end
local function meterRows()
    if type(AZS_GetMeter)=="function" then
        local ok,rows,total,dps=pcall(AZS_GetMeter);
        if ok and type(rows)=="table" then return rows,total or 0,dps or 0 end
    end
    return type(AZS_METER)=="table" and AZS_METER or {},0,0;
end
local function Round(n)
    n=type(n)=="number" and n or 0;
    if n>=1000000 then return string.format("%.2fM",n/1000000) end
    if n>=1000 then return string.format("%.1fK",n/1000) end
    return string.format("%.0f",n);
end
local function Tm(t)
    t=math.floor(type(t)=="number" and t or 0);
    return string.format("%d:%02d",math.floor(t/60),math.mod(t,60));
end
local function Finalize(result)
    local r=ABA.runSession;if not r or r.finished then return end
    r.finished=true;
    local data=type(AZS_RUN)=="table" and AZS_RUN or {};
    local rows,total,dps=meterRows();local major=nil;
    for i=1,table.getn(rows) do
        local row=rows[i];if type(row)=="table" and (not major or (row.dmg or 0)>(major.dmg or 0)) then major=row end
    end
    local record={result=result,time=RunTime(),class=ABA.ClassKey(),
        kills=data.kills or 0,gold=data.ge or data.gold or 0,
        bosses=data.bk or 0,guardians=data.gk or 0,damage=data.dealt or total or 0,
        dps=dps or 0,highest=major and (major.name or "Unknown") or "--",
        stats=SnapshotStats()};
    local d=ABA.DB();if type(d.runHistory)~="table" then d.runHistory={} end
    table.insert(d.runHistory,1,record);
    while table.getn(d.runHistory)>8 do table.remove(d.runHistory) end
end
function ABA.TrackRun()
    local phase=Phase();local active=phase=="playing" or phase=="choosing" or phase=="paused";
    if active then
        local t=RunTime();
        if not ABA.runSession or ABA.runSession.finished or (ABA.runSession.lastClock and t+5<ABA.runSession.lastClock) then
            ABA.runSession={started=GetTime(),samples={},lastSample=-99,lastClock=t};
        end
        local r=ABA.runSession;r.lastClock=t;
        if t-r.lastSample>=15 and type(AZS_STATS)=="table" then
            table.insert(r.samples,{t=t,stats=SnapshotStats()});r.lastSample=t;
            -- Bounded memory, do not save 1000+ snapshots to SavedVariables.
            while table.getn(r.samples)>90 do table.remove(r.samples,1) end
        end
    elseif phase=="victory" or phase=="dead" then
        Finalize(phase);
    elseif phase=="ready" and ABA.runSession then
        -- No run outcome if the player abandons a run before victory/death.
        ABA.runSession=nil;
    end
end
local function NiceStat(key,val)
    for _,spec in ipairs(ABA.stats or {}) do
        if spec.key==key then
            if spec.kind=="gain" then return string.format("%+.0f%%",(val-1)*100) end
            if spec.kind=="bonus" then return string.format("%+.0f%%",val*100) end
            if spec.kind=="cooldown" then return string.format("%.1f%%",(1-val)*100) end
            if spec.kind=="percent" or spec.kind=="critmult" then return string.format("%.1f%%",val*100) end
            if spec.kind=="int" then return string.format("%.0f",val) end
            return string.format("%.1f",val);
        end
    end
    return string.format("%.2f",val);
end
function ABA.InsightLines(page)
    local result={};local r=ABA.runSession;local d=ABA.DB();local h=d.runHistory or {};
    local data=type(AZS_RUN)=="table" and AZS_RUN or {};
    if page=="run" then
        table.insert(result,"RUN OVERVIEW");
        if ABA.statsLive then
            table.insert(result,YNX_L("Time ")..Tm(RunTime())..YNX_L("     Level ")..tostring(data.lvl or "--"));
            table.insert(result,YNX_L("Kills ")..Round(data.kills)..YNX_L("     Damage ")..Round(data.dealt));
            table.insert(result,YNX_L("Gold ")..Round(data.ge or data.gold)..YNX_L("     Bosses ")..Round(data.bk));
            table.insert(result,YNX_L("Guardians slain ")..Round(data.gk)..YNX_L("     Damage taken ")..Round(data.taken));
        else table.insert(result,"Start a run to see current performance.") end
        table.insert(result,"LAST FINISHED RUNS (up to 8 saved)");
        for i=1,math.min(6,table.getn(h)) do
            local item=h[i];
            table.insert(result,tostring(i)..". "..tostring(item.class or "?").." "..tostring(item.result or "?")..
                "  "..Tm(item.time).."  "..Round(item.damage)..YNX_L(" dmg"));
        end
        if table.getn(h)>1 then
            local a,b=h[1],h[2];
            table.insert(result,YNX_L("Latest vs prior: ")..string.format("%+.0f",(a.damage or 0)-(b.damage or 0))..YNX_L(" damage"));
        end
    elseif page=="spells" then
        table.insert(result,"SPELL PERFORMANCE (run total)");
        local rows,total,dps=meterRows();local sorted={};
        for i=1,table.getn(rows) do
            if type(rows[i])=="table" then table.insert(sorted,rows[i]) end
        end
        table.sort(sorted,function(a,b) return (a.dmg or 0)>(b.dmg or 0) end);
        table.insert(result,YNX_L("Total damage: ")..Round(total)..YNX_L("     DPS: ")..Round(dps));
        for i=1,math.min(10,table.getn(sorted)) do
            local spell=sorted[i];local title=tostring(spell.name or spell.key or "Ability");
            if string.len(title)>18 then title=string.sub(title,1,17).."." end
            table.insert(result,(spell.proc==1 and YNX_L("[PROC] ") or "")..title.."  "..Round(spell.dmg)..YNX_L(" dmg  ")..Round(spell.dps).." DPS");
        end
        if table.getn(sorted)==0 then table.insert(result,"No damage-meter data yet.") end
    elseif page=="trends" then
        table.insert(result,"STAT HISTORY (15-second samples)");
        if not r or table.getn(r.samples)<2 then
            table.insert(result,"Run for at least 15 seconds to start tracking trends.");
        else
            local first=r.samples[1];local last=r.samples[table.getn(r.samples)];
            table.insert(result,YNX_L("From ")..Tm(first.t)..YNX_L(" to ")..Tm(last.t));
            local keys={"dmg","cd","crit","cm","echo","arm","area","hp","doth","big"};
            for _,key in ipairs(keys) do
                local v1=first.stats[key];local v2=last.stats[key];
                if type(v1)=="number" and type(v2)=="number" then
                    local label=key;
                    for _,s in ipairs(ABA.stats) do if s.key==key then label=YNX_L(s.name) end end
                    table.insert(result,label..": "..NiceStat(key,v1).."  ->  "..NiceStat(key,v2));
                end
            end
        end
    elseif page=="notes" then
        table.insert(result,"YNX  |  YOUR NUMBERS EXPOSED");
        table.insert(result,"Created by Ynx");
        table.insert(result,"A compact companion for Azeroth Survivors.");
        table.insert(result,"");
        table.insert(result,"Pick the statistics and abilities that matter.");
        table.insert(result,"Track damage procs as they appear in a run.");
        table.insert(result,"Save named profiles for different builds.");
        table.insert(result,"Choose a skin and keep your HUD uncluttered.");
        table.insert(result,"");
        table.insert(result,"CONTROLS");
        table.insert(result,"Click the HUD to open Settings.");
        table.insert(result,"LOOK > Layout: unlock movement and resize.");
        table.insert(result,"/ynx settings  |  /ynx stop  |  /ynx reset");
        table.insert(result,"");
        table.insert(result,"Designed for your playstyle.  - Ynx");
    end
    for i=1,table.getn(result) do result[i]=YNX_L(result[i]) end
    return result;
end
