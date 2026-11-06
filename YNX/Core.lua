-- YNX - Your Numbers eXposed 0.15.4; Lua 5.0 / WoW 1.12.
ABA = { version = "0.15.4", last = nil, statChanged = {}, tooltipCache = {}, spellbook = {} };

function ABA.DB()
    if type(ABASettingsDB) ~= "table" then ABASettingsDB = {} end
    local d = ABASettingsDB;
    if type(d.enabled) ~= "table" then d.enabled = {} end
    if d.mode ~= "smart" and d.mode ~= "custom" and d.mode ~= "crit" and d.mode ~= "all" then d.mode = "custom" end
    -- One-time migration: previous versions were dashboards. Start with a small,
    -- useful tracker; preserve an explicitly configured Custom stat selection.
    if not d.v4Migrated then
        local any=false;
        for _,v in pairs(d.enabled) do if v then any=true end end
        if d.mode ~= "custom" or not any then
            d.enabled = {dmg=true, cd=true, crit=true, cm=true, luck=true, echo=true};
        end
        d.mode = "custom";
        d.statStyle = "icons";
        d.spellVisible = false;
        d.showMilestones = true;
        d.spellCD = true;
        d.spellDPS = false;
        d.hudPos = nil;
        d.v4Migrated = true;
        d.pinned = true;
    end
    if not d.v62Startup then
        -- Upgrade safeguard: a previously hidden HUD must not require /ynx
        -- to discover it. After this one-time migration, respect user toggle.
        d.pinned = true;
        d.v62Startup = true;
    end
    if d.pinned == nil then d.pinned = true end
    -- v0.7 keeps both working gesture handlers, with one lock switch.
    if type(d.editLayout)~="boolean" then d.editLayout = (d.editMove == true or d.editResize == true) end
    d.editMove = d.editLayout; d.editResize = d.editLayout;
    if d.layoutMode ~= "grid" and d.layoutMode ~= "vertical" and d.layoutMode ~= "horizontal" then d.layoutMode="grid" end
    if d.columns ~= 1 and d.columns ~= 2 and d.columns ~= 3 then d.columns=2 end
    if type(d.autoWidth)~="boolean" then d.autoWidth=true end
    if type(d.rowGap)~="number" then d.rowGap=3 end
    if type(d.colGap)~="number" then d.colGap=3 end
    -- v0.10 visual settings: do not reset existing HUD positions, stats or profiles.
    if not d.v10Bars then
        -- Reactivate milestone bars after the older UI buried the toggle.
        -- Players can explicitly turn them off on the dedicated BARS page.
        d.showMilestones=true; d.v10Bars=true;
    end
    if d.frameKind~="float" and d.frameKind~="soft" and
       d.frameKind~="box" and d.frameKind~="round" and d.frameKind~="softround" then d.frameKind="round" end
    if type(d.hudPadding)~="number" then d.hudPadding=5 end
    if type(d.borderWidth)~="number" then d.borderWidth=2 end
    if type(d.iconGap)~="number" then d.iconGap=3 end
    if type(d.gaugeHeight)~="number" then d.gaugeHeight=3 end
    if type(d.barsReady)~="boolean" then d.barsReady=true end
    if d.gaugeColor~="adaptive" and d.gaugeColor~="theme" and d.gaugeColor~="cyan"
       and d.gaugeColor~="green" and d.gaugeColor~="gold" then d.gaugeColor="adaptive" end
    d.hudPadding=math.max(0,math.min(28,d.hudPadding))
    d.borderWidth=math.max(0,math.min(4,d.borderWidth))
    d.iconGap=math.max(0,math.min(20,d.iconGap))
    d.colGap=math.max(0,math.min(24,d.colGap))
    d.gaugeHeight=math.max(2,math.min(7,d.gaugeHeight))
    -- v0.11.1: finer bar controls, without resetting existing visual choices.
    if type(d.gaugeLength)~="number" then d.gaugeLength=0.72 end
    d.gaugeLength=math.max(0.30,math.min(1.20,d.gaugeLength));
    -- The previous default was 100% of the cell. Adopt the shorter v0.15
    -- default on first upgrade only when the old value was unchanged.
    if not d.v15BarDefault then
        if math.abs(d.gaugeLength-1)<0.00001 then d.gaugeLength=0.72 end
        d.v15BarDefault=true
    end
    if type(d.gaugeOffsetX)~="number" then d.gaugeOffsetX=0 end
    if type(d.gaugeOffsetY)~="number" then d.gaugeOffsetY=0 end
    d.gaugeOffsetX=math.max(-40,math.min(40,d.gaugeOffsetX));
    d.gaugeOffsetY=math.max(-16,math.min(16,d.gaugeOffsetY));
    if type(d.gaugeTransition)~="number" then d.gaugeTransition=0.55 end
    d.gaugeTransition=math.max(0.15,math.min(1.5,d.gaugeTransition));
    if type(d.gaugeAnimation)~="boolean" then d.gaugeAnimation=true end
    if type(d.gaugeHighlight)~="boolean" then d.gaugeHighlight=true end
    if d.gaugeGainTint~="green" and d.gaugeGainTint~="cyan" and d.gaugeGainTint~="gold" then d.gaugeGainTint="green" end
    if type(d.orderSeparators)~="table" then d.orderSeparators={} end
    if type(d.layoutExtras)~="table" then
        d.layoutExtras={}
        for key,kind in pairs(d.orderSeparators) do
            if kind=="h" or kind=="v" then d.layoutExtras[key]={kind="separator"} end
        end
    end
    if type(d.separatorThickness)~="number" then d.separatorThickness=2 end
    if type(d.separatorBefore)~="number" then d.separatorBefore=6 end
    if type(d.separatorAfter)~="number" then d.separatorAfter=6 end
    if type(d.separatorLength)~="number" then d.separatorLength=0.90 end
    if type(d.spacerHeight)~="number" then d.spacerHeight=16 end
    if type(d.showGoalMarkers)~="boolean" then d.showGoalMarkers=true end
    if type(d.showConversionMarkers)~="boolean" then d.showConversionMarkers=true end
    -- No verified soft-cap markers exist at present.  Preserve a legacy
    -- saved preference but do not offer a nonfunctional checkbox in Settings.
    if type(d.showSoftCapMarkers)~="boolean" then d.showSoftCapMarkers=false end
    if type(d.showHardCapMarkers)~="boolean" then d.showHardCapMarkers=true end
    if type(d.manualColorsEnabled)~="boolean" then d.manualColorsEnabled=false end
    if type(d.manualColors)~="table" then d.manualColors={} end
    local colors={text="85F5FF",secondary="A3BECF",background="0B2532",border="37C5DE",bar="4BCDE7",gain="53FF91"}
    for name,value in pairs(colors) do
        if type(d.manualColors[name])~="string" then d.manualColors[name]=value end
    end
    d.separatorThickness=math.max(1,math.min(6,d.separatorThickness));
    d.separatorBefore=math.max(0,math.min(24,d.separatorBefore));
    d.separatorAfter=math.max(0,math.min(24,d.separatorAfter));
    d.separatorLength=math.max(0.2,math.min(1,d.separatorLength));
    d.spacerHeight=math.max(2,math.min(80,d.spacerHeight));
    if type(d.showDelta)~="boolean" then d.showDelta=true end
    if type(d.deltaMode)~="string" or (d.deltaMode~="inline" and d.deltaMode~="float") then d.deltaMode="float" end
    if type(d.deltaDuration)~="number" then d.deltaDuration=2.0 end
    d.deltaDuration=math.max(1,math.min(5,d.deltaDuration));
    if d.iconTheme~="modern" and d.iconTheme~="classic" then d.iconTheme="modern" end
    if type(d.iconSize)~="number" then d.iconSize=21 end
    if type(d.fontSize)~="number" then d.fontSize=12 end
    if type(d.opacity)~="number" then d.opacity=0.87 end
    d.rowGap=math.max(0,math.min(24,d.rowGap));
    d.iconSize=math.max(12,math.min(40,d.iconSize));
    d.fontSize=math.max(8,math.min(24,d.fontSize));
    d.opacity=math.max(0.1,math.min(1,d.opacity));
    if d.effectMode~="off" and d.effectMode~="subtle" and d.effectMode~="normal" then d.effectMode="normal" end
    if type(d.glow)~="boolean" then d.glow=true end
    if type(d.milestoneFlash)~="boolean" then d.milestoneFlash=true end
    if type(d.iconBrightness)~="number" then d.iconBrightness=1 end
    if d.valueFont~="clean" and d.valueFont~="classic" and d.valueFont~="fantasy" then d.valueFont="clean" end
    if type(d.valueYOffset)~="number" then d.valueYOffset=0 end
    d.valueYOffset=math.max(-8,math.min(8,d.valueYOffset));
    d.iconBrightness=math.max(0.4,math.min(1,d.iconBrightness));
    if d.accent~= "skin" and d.accent~="blue" and d.accent~="teal" and d.accent~="violet" and
       d.accent~="amber" and d.accent~="rose" and d.accent~="white" then d.accent="teal" end
    if type(d.pulse)~="boolean" then d.pulse=true end
    if d.statStyle~="icons" and d.statStyle~="text" and d.statStyle~="both" then d.statStyle="icons" end
    if type(d.statOrder)~="table" then d.statOrder={} end
    if type(d.customProfiles)~="table" then d.customProfiles={} end
    if type(d.procProfiles)~="table" then d.procProfiles={} end
    if type(d.showProcDPS)~="boolean" then d.showProcDPS=true end
    if type(d.runHistory)~="table" then d.runHistory={} end
    if d.statPage~="core" and d.statPage~="advanced" and d.statPage~="order" and d.statPage~="presets" then d.statPage="core" end
    if d.lookPage=="overview" then d.lookPage="layout" end
    if d.lookPage=="style" or d.lookPage=="colors" then d.lookPage="skins" end
    if d.lookPage=="motion" then d.lookPage="effects" end
    if d.skin=="winged" then d.skin="solar" end
    if d.lookPage~="layout" and d.lookPage~="skins" and d.lookPage~="frame" and d.lookPage~="text" and d.lookPage~="bars" and d.lookPage~="effects" then d.lookPage="layout" end
    if d.statStyle ~= "icons" and d.statStyle ~= "text" and d.statStyle ~= "both" then d.statStyle = "icons" end
    if type(d.spellProfiles) ~= "table" then d.spellProfiles = {} end
    if d.spellVisible == nil then d.spellVisible = false end
    if d.spellCD == nil then d.spellCD = true end
    if d.spellDPS == nil then d.spellDPS = false end
    if d.showMilestones == nil then d.showMilestones = true end
    if type(d.scale) ~= "number" or d.scale < 0.50 or d.scale > 2.00 then d.scale = 1 end
    if type(d.hudWidth) ~= "number" or d.hudWidth < 90 or d.hudWidth > 1000 then d.hudWidth = 232 end
    if d.skin ~= "shadow" and d.skin ~= "glass" and d.skin ~= "classic" and d.skin ~= "bare" and d.skin ~= "arcane" and d.skin ~= "ember" and d.skin ~= "emerald" and d.skin ~= "frost" and d.skin ~= "solar" and d.skin ~= "neon" then d.skin = "glass" end
    if d.frameKind~="float" and d.frameKind~="soft" and d.frameKind~="box" and d.frameKind~="round" and d.frameKind~="softround" then d.frameKind="round" end
    if not d.v5Migrated then
        -- v0.4 stored a TOPLEFT offset relative to screen TOP; convert
        -- to the new absolute UIParent BOTTOMLEFT coordinate system.
        if type(d.hudPos)=="table" and type(d.hudPos[1])=="number" and type(d.hudPos[2])=="number" then
            local h=UIParent and UIParent:GetHeight() or 0;
            d.hudPos={d.hudPos[1],h+d.hudPos[2]};
        end
        d.v5Migrated=true;
    end
    return d;
end

function ABA.ClassKey()
    if type(AZS_ZONE) == "table" and type(AZS_ZONE.class) == "string" and AZS_ZONE.class ~= "" then
        return string.lower(AZS_ZONE.class);
    end
    if type(UnitClass) == "function" then
        local ok, _, key = pcall(UnitClass, "player");
        if ok and type(key) == "string" and key ~= "" then return string.lower(key) end
    end
    return "other";
end
function ABA.SpellProfile()
    local d = ABA.DB(); local key=ABA.ClassKey();
    if type(d.spellProfiles[key]) ~= "table" then d.spellProfiles[key] = {} end
    return d.spellProfiles[key];
end
function ABA.SetStat(key, enabled)
    local d=ABA.DB();
    if d.mode ~= "custom" then
        local current={};
        if ABA.stats then
            for i=1,table.getn(ABA.stats) do
                local s=ABA.stats[i];
                if ABA.IsEnabled(s) then current[s.key]=true end
            end
        end
        d.enabled=current;
        d.mode="custom";
    end
    d.enabled[key] = enabled == true;d.activeProfileSlot=nil;
    if ABA.Update then ABA.Update(true) end
end

function ABA.Phase()
    if type(AZS_GetPhase) == "function" then
        local ok, value = pcall(AZS_GetPhase);
        if ok then return value end
    end
    return nil;
end

function ABA.Neutral(k)
    if k == "dmg" or k == "cd" or k == "cm" or k == "area" or k == "spd" or
       k == "xp" or k == "gold" or k == "pick" then return 1 end
    return 0;
end

function ABA.IsEnabled(stat)
    local d = ABA.DB();
    if d.mode == "all" then return true end
    if d.mode == "crit" then return stat.key == "crit" or stat.key == "cm" end
    if d.mode == "custom" then return d.enabled[stat.key] == true end
    -- Smart: core metrics are visible even before a run, but never use
    -- stale previous-run values to decide which extra metrics to show.
    if stat.key == "dmg" or stat.key == "cd" or stat.key == "crit" or stat.key == "cm" then return true end
    if ABA.statsLive == false then return false end
    if stat.key == "hp" or stat.key == "reg" or stat.key == "pick" then
        return ABA.base and type(ABA.base[stat.key]) == "number" and
            type(AZS_STATS) == "table" and type(AZS_STATS[stat.key]) == "number" and
            math.abs(AZS_STATS[stat.key] - ABA.base[stat.key]) > 0.0001;
    end
    local value = type(AZS_STATS) == "table" and AZS_STATS[stat.key] or nil;
    return type(value) == "number" and math.abs(value - ABA.Neutral(stat.key)) > 0.0001;
end

function ABA.StatsValue(stat)
    -- The game's run data can be stale outside the run (skill API note).
    -- Display any numeric stats already supplied, including the ready screen.
    -- Never fabricate missing values; only real incoming numbers are shown.
    local s = type(AZS_STATS) == "table" and AZS_STATS or {};
    local v = s[stat.key];
    if type(v) ~= "number" then return "--" end
    local k = stat.kind;
    if k == "percent" then return string.format("%.1f%%", v * 100) end
    if k == "gain" then return string.format("%.0f%%", (v - 1) * 100) end
    if k == "bonus" then return string.format("%+.0f%%", v * 100) end
    if k == "cooldown" then return string.format("%.1f%%", (1 - v) * 100) end
    if k == "critmult" then return string.format("%.0f%%", v * 100) end
    if k == "int" then return string.format("%.0f", v) end
    if k == "rate" then return string.format("%.1f/s", v) end
    if k == "range" then return string.format("%.0fyd", v) end
    return string.format("%.2f", v);
end

-- Change-preview formatting uses the underlying stat rather than a guessed percent.
-- Value stays stable on the HUD; temporary gain text is rendered separately.
function ABA.ValueFrom(stat,value)
    if type(value)~="number" then return "--" end
    local k=stat.kind;
    if k=="percent" then return string.format("%.1f%%",value*100) end
    if k=="gain" then return string.format("%.0f%%",(value-1)*100) end
    if k=="bonus" then return string.format("%.0f%%",value*100) end
    if k=="cooldown" then return string.format("%.1f%%",(1-value)*100) end
    if k=="critmult" then return string.format("%.0f%%",value*100) end
    if k=="int" then return string.format("%.0f",value) end
    if k=="rate" then return string.format("%.1f/s",value) end
    if k=="range" then return string.format("%.0fyd",value) end
    return string.format("%.2f",value);
end
function ABA.ChangeAmount(stat,before,after)
    local delta=after-before;
    if stat.kind=="cooldown" then delta=-delta end
    if stat.kind=="percent" or stat.kind=="gain" or stat.kind=="bonus" or
       stat.kind=="critmult" then return string.format("%+.1f%%",delta*100) end
    if stat.kind=="rate" then return string.format("%+.1f/s",delta) end
    if stat.kind=="range" then return string.format("%+.1fyd",delta) end
    if stat.kind=="int" then return string.format("%+.0f",delta) end
    return string.format("%+.2f",delta)
end
function ABA.DisplayValue(stat)
    local v=type(AZS_STATS)=="table" and AZS_STATS[stat.key] or nil;
    if type(v)~="number" then return "--" end
    local d=ABA.DB();local x=ABA.statChanged[stat.key];
    if d.showDelta and ABA.statsLive and d.effectMode~="off" and x and type(x.at)=="number" then
        local age=GetTime()-x.at;
        if age>=0 and age<d.deltaDuration then return ABA.ChangeAmount(stat,x.before,x.after) end
    end
    return ABA.ValueFrom(stat,v)
end
function ABA.DeltaPreview(stat)
    local v=type(AZS_STATS)=="table" and AZS_STATS[stat.key] or nil;
    if type(v)~="number" then return nil,nil end
    local d=ABA.DB(); local x=ABA.statChanged[stat.key];
    if not (d.showDelta and ABA.statsLive and d.effectMode~="off" and x and type(x.at)=="number") then return nil,nil end
    local age=GetTime()-x.at;
    if age<0 or age>=d.deltaDuration then return nil,nil end
    local up=(stat.kind=="cooldown" and x.after<x.before) or (stat.kind~="cooldown" and x.after>x.before);
    return ABA.ChangeAmount(stat,x.before,x.after),up
end

function ABA.RefreshChanges()
    if type(AZS_STATS) ~= "table" then return end
    local phase = ABA.Phase();
    if not phase or phase == "ready" then
        ABA.last = nil;
        ABA.base = nil;
        return;
    end
    if not ABA.base then
        ABA.base = {};
        for k, v in pairs(AZS_STATS) do if type(v) == "number" then ABA.base[k] = v end end
    end
    if ABA.last then
        for k, v in pairs(AZS_STATS) do
            if type(v) == "number" and type(ABA.last[k]) == "number" and
               math.abs(v - ABA.last[k]) > 0.0001 then
                ABA.statChanged[k] = {before = ABA.last[k], after = v, at = GetTime()};
            end
        end
    end
    ABA.last = {};
    for k, v in pairs(AZS_STATS) do if type(v) == "number" then ABA.last[k] = v end end
end

function ABA.Message(s)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff58c9ffYNX|r " .. s) end
end

local f = CreateFrame("Frame");
local elapsed = 0;
f:RegisterEvent("VARIABLES_LOADED");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("SPELLS_CHANGED");
f:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
        ABA.DB();
        -- Start each client/UI session with the HUD visible, even if it was
        -- hidden in the previous session. /ynx toggle is session-friendly.
        if event == "VARIABLES_LOADED" then ABA.DB().pinned = true end
        -- SavedVariables may become available only when VARIABLES_LOADED fires.
        if event == "VARIABLES_LOADED" and ABA.RestorePosition then ABA.RestorePosition() end
        if ABA.ResetReader then ABA.ResetReader() end
        if ABA.Update then ABA.Update(true) end
    elseif event == "SPELLS_CHANGED" then
        if ABA.ResetReader then ABA.ResetReader() end
    end
end);
f:SetScript("OnUpdate", function()
    elapsed = elapsed + (arg1 or 0);
    if elapsed < 0.45 then return end
    elapsed = 0;
    ABA.RefreshChanges();
    if ABA.TrackRun then ABA.TrackRun() end
    if ABA.RefreshTooltipData then ABA.RefreshTooltipData() end
    if ABA.Update then ABA.Update() end
end);

SLASH_ABABUILD1 = "/ynx";
SLASH_ABABUILD2 = "/aba";
SlashCmdList["ABABUILD"] = function(message)
    local m = string.lower(tostring(message or ""));
    m = string.gsub(m, "^%s+", ""); m = string.gsub(m, "%s+$", "");
    local d = ABA.DB();
    if m == "" or m == "toggle" then d.pinned = not d.pinned;
    elseif m == "settings" then if ABA.ToggleSettings then ABA.ToggleSettings() end
    elseif m == "stop" or m == "cancel" then
        if ABA.StopInteraction then ABA.StopInteraction() end
        ABA.Message("Drag/resize cancelled. Enable handles in LOOK when needed.")
    elseif m == "crit" then d.mode = "custom"; d.enabled = {crit=true,cm=true};
    elseif m == "smart" or m == "all" then d.mode = m;
    elseif m == "reset" then d.hudPos = nil; d.pinned = true; if ABA.ResetPosition then ABA.ResetPosition() end
    elseif m == "unlock" then d.editLayout=true;d.editMove=true;d.editResize=true
    elseif m == "lock" then
        if ABA.StopInteraction then ABA.StopInteraction() end
        d.editLayout=false;d.editMove=false;d.editResize=false
    elseif m == "tooltip" then
        ABA.Message("Tooltip reader: " .. tostring(ABA.tooltipStatus or "not yet scanned"));
    elseif m == "export" then
        ABA.Message("Preset code: " .. (ABA.ExportCode and ABA.ExportCode() or "unavailable"));
    elseif string.sub(m,1,7)=="import " then
        local code=string.sub(m,8);
        if ABA.ImportCode and ABA.ImportCode(code) then
            ABA.Message("Shared stat preset imported.")
        else ABA.Message("Invalid preset code. Use /ynx export first.") end
    elseif m == "debug" then
        -- Diagnose AZS phase/data availability without assuming that
        -- previous-run tables are current on the ready screen.
        local n = 0;
        if type(AZS_STATS) == "table" then
            for _,v in pairs(AZS_STATS) do if type(v) == "number" then n = n + 1 end end
        end
        ABA.Message("Phase: " .. tostring(ABA.Phase()) ..
            " | numeric stats: " .. tostring(n) ..
            " | HUD: " .. tostring(d.pinned and "on" or "off"));
    else ABA.Message("/ynx settings | stop | reset | lock | unlock | export | import <code> | debug") end
    if ABA.Update then ABA.Update(true) end
end;

-- Presets only change the monitored stats, never layout, appearance, or spells.
ABA.presets={
 {key="crit",name="CRITICAL BURST",keys={"dmg","crit","cm","exe"}},
 {key="echo",name="HASTE + ECHO",keys={"dmg","cd","echo","crit"}},
 {key="tank",name="TANK / SURVIVAL",keys={"arm","hp","reg","lch","heal"}},
 {key="dot",name="DoT SPECIALIST",keys={"dmg","doth","dots","dotd"}},
 {key="aoe",name="AoE CLEARING",keys={"dmg","area","cnt","cd"}},
 {key="boss",name="BOSS KILLER",keys={"dmg","big","exe","crit","cm"}},
 {key="farm",name="FARMING / LUCK",keys={"xp","luck","gold","spd","pick"}},
 {key="balance",name="BALANCED",keys={"dmg","cd","crit","arm","hp"}}
};
function ABA.ApplyPreset(which)
    local d=ABA.DB();
    if which=="all" or which=="smart" then d.mode=which;d.activePreset=which
    elseif which=="none" then d.mode="custom";d.enabled={};d.activePreset="none"
    else
        local chosen=nil;
        for i=1,table.getn(ABA.presets) do
            if ABA.presets[i].key==which then chosen=ABA.presets[i] end
        end
        if chosen then
            d.activeProfileSlot=nil;d.mode="custom";d.enabled={};
            for i=1,table.getn(chosen.keys) do d.enabled[chosen.keys[i]]=true end
            d.activePreset=which;
        end
    end
    if ABA.Update then ABA.Update(true) end
end
function ABA.SaveCustomProfile(slot,name)
    local d=ABA.DB();local keys={};
    if ABA.stats then
        for i=1,table.getn(ABA.stats) do
            local s=ABA.stats[i];if ABA.IsEnabled(s) then keys[s.key]=true end
        end
    end
    local prior=d.customProfiles[slot];
    local title=type(name)=="string" and string.gsub(name,"[%c]","") or "";
    title=string.sub(title,1,24);
    if title=="" and type(prior)=="table" and type(prior.name)=="string" then title=prior.name end
    if title=="" then title="My Profile "..tostring(slot) end
    local rules={};for k,v in pairs(d.orderSeparators) do if v=="h" or v=="v" then rules[k]=v end end
    d.customProfiles[slot]={name=title,enabled=keys,order=ABA.CopyOrder and ABA.CopyOrder() or {},separators=rules};d.activeProfileSlot=slot;
end
function ABA.LoadCustomProfile(slot)
    local d=ABA.DB();local item=d.customProfiles[slot];
    if type(item)~="table" or type(item.enabled)~="table" then return false end
    local enabled={};for k,v in pairs(item.enabled) do if v then enabled[k]=true end end
    d.enabled=enabled;d.mode="custom";d.activePreset="custom";d.activeProfileSlot=slot;
    if type(item.order)=="table" then
        d.statOrder={};for i=1,table.getn(item.order) do d.statOrder[i]=item.order[i] end
    end
    if type(item.separators)=="table" then
        d.orderSeparators={};for k,v in pairs(item.separators) do
            if v=="h" or v=="v" then d.orderSeparators[k]=v end
        end
    end
    if ABA.Update then ABA.Update(true) end
    return true
end
function ABA.CopyOrder()
    local d=ABA.DB();local order={};
    for i=1,table.getn(d.statOrder) do order[i]=d.statOrder[i] end
    return order
end
function ABA.MoveStat(key,direction)
    local d=ABA.DB();local keys={};local seen={};
    for i=1,table.getn(d.statOrder) do
        local k=d.statOrder[i];if k and not seen[k] then table.insert(keys,k);seen[k]=true end
    end
    if ABA.stats then
        for i=1,table.getn(ABA.stats) do
            local k=ABA.stats[i].key;
            if not seen[k] then table.insert(keys,k);seen[k]=true end
        end
    end
    for i=1,table.getn(keys) do
        if keys[i]==key then
            -- Move against the next TRACKED stat, not an invisible stat.
            local j=i+direction;
            while j>=1 and j<=table.getn(keys) do
                local selected=false;
                if ABA.stats then
                    for z=1,table.getn(ABA.stats) do
                        if ABA.stats[z].key==keys[j] then selected=ABA.IsEnabled(ABA.stats[z]) end
                    end
                end
                if selected then keys[i],keys[j]=keys[j],keys[i];break end
                j=j+direction;
            end
            break
        end
    end
    d.statOrder=keys;d.activeProfileSlot=nil;
    if ABA.Update then ABA.Update(true) end
end

-- Portable text-only stat preset code. No clipboard API or modern Lua needed.
function ABA.ExportCode()
    local ordered={};local seen={};local d=ABA.DB();
    for i=1,table.getn(d.statOrder) do
        local key=d.statOrder[i];
        for j=1,table.getn(ABA.stats) do
            if ABA.stats[j].key==key and ABA.IsEnabled(ABA.stats[j]) and not seen[key] then
                table.insert(ordered,key);seen[key]=true
            end
        end
    end
    for i=1,table.getn(ABA.stats) do
        local spec=ABA.stats[i];
        if ABA.IsEnabled(spec) and not seen[spec.key] then table.insert(ordered,spec.key) end
    end
    return "YNX1:"..table.concat(ordered,",")
end
function ABA.ImportCode(code)
    if type(code)~="string" or string.sub(string.upper(code),1,5)~="YNX1:" then return false end
    local payload=string.sub(string.lower(code),6);local order={};local enabled={};
    local pos=1;
    while pos<=string.len(payload) do
        local comma=string.find(payload,",",pos,true);
        local key;
        if comma then key=string.sub(payload,pos,comma-1);pos=comma+1
        else key=string.sub(payload,pos);pos=string.len(payload)+1 end
        local valid=false;
        for j=1,table.getn(ABA.stats) do if ABA.stats[j].key==key then valid=true end end
        if not valid or enabled[key] or table.getn(order)>=29 then return false end
        enabled[key]=true;table.insert(order,key);
    end
    local d=ABA.DB();d.enabled=enabled;d.statOrder=order;d.mode="custom";d.activePreset="imported";
    if ABA.Update then ABA.Update(true) end
    return true
end
