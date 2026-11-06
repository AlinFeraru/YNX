-- ABA 0.3.1: researched milestones / true limits, not speculative caps.
-- Based on Survivor UI's 2026-11-02 mechanics guide (game builds 0.131-0.139).
-- The returned object drives BOTH the combat list and the choice-screen strip.
-- Values are percentage POINTS, except spell cooldown floors (seconds).
ABA.milestoneInfo = {
    cd = "Haste has NO global cap. 60% and 75% are YOUR build goals. Cooldowns cannot normally go below 0.25 sec (Hellfire: 0.5 sec; Divine Shield has a separate rule).",
    crit = "At 100% every eligible hit crits. Above 100%, extra crit chance converts 1:1 to bonus critical damage; further crit is not wasted.",
    cm = "Critical damage does not have a known universal hard cap. At 100% critical chance, extra crit converts into this stat.",
    echo = "100% Echo guarantees an extra strike; extra percentages roll another strike. There is no global Echo cap; 200% guarantees two additional strikes. Some mechanics have special interactions.",
    arm = "The default global damage-reduction cap is 60%. Warrior Titan raises it to 70%. Certain talents use armor above the cap, and crowd-specific gear mitigation is applied separately.",
    spd = "Movement speed stops increasing at +120% (2.20x base, normally 15.4 yd/sec). More global movement speed beyond this is ineffective.",
    area = "Area itself has no known global percent cap. Spell REACH over 70 yd has diminishing returns; it is not a +70% Area cap. An 8-yd radius still grows normally.",
    luck = "Luck has no known hard cap, but changes the odds of different rarity cards with diminishing practical returns. No fixed 'stop at X%' threshold is verified.",
    cnt = "Extra Targets is limited by enemies actually available and by how a particular spell selects them; there is no shared global target cap established.",
    dmg = "No verified universal Damage multiplier cap. More damage can still help; practical value depends on the abilities that benefit.",
    hp = "No universal maximum-health cap verified.",
    pick = "Pickup bonuses multiply with other pickup bonuses. No global pickup-radius cap verified.",
    xp = "No universal experience gain cap verified.",
    gold = "No universal gold multiplier cap verified."
};

function ABA.GetMilestone(key, stats)
    local s = stats or AZS_STATS;
    if type(s) ~= "table" then return nil end
    local n = s[key];
    if type(n) ~= "number" then return nil end
    local v, goal, kind, state, marker, tip;
    if key == "cd" then
        v = (1 - n) * 100; goal = 75; marker = 60 / 75; kind = "GOAL";
        if v >= 75 - 0.001 then state = "75% GOAL MET (not cap)";
        elseif v >= 60 - 0.001 then state = "60% GOAL MET / 75% NEXT";
        else state = string.format("%.0f%% TO 60%% GOAL", math.max(0, 60-v)) end
    elseif key == "crit" then
        v = n * 100; goal = 100; kind = "MILESTONE";
        if v >= 100 - 0.001 then
            state = v > 100.001 and string.format("GUARANTEED + %.1f%% OVERFLOW", v-100) or "100% CRITS GUARANTEED";
        else state = string.format("%.1f%% TO GUARANTEED", 100-v) end
    elseif key == "echo" then
        v = n * 100; goal = 100; kind = "MILESTONE";
        if v >= 100 - 0.001 then
            local guaranteed = math.floor((v+0.001)/100);
            local left = v - guaranteed * 100;
            state = string.format("+%d GUARANTEED / %.1f%% NEXT", guaranteed, math.max(0,left));
        else state = string.format("%.1f%% TO EXTRA STRIKE", 100-v) end
    elseif key == "arm" then
        v = n * 100; kind = "HARD";
        -- No publicly documented AZS boolean reliably indicates the Titan capstone.
        -- If the game actually reports >60%, the base 60% cap was extended.
        goal = v > 60.001 and 70 or 60;
        if v >= goal-0.001 then state = goal==70 and "70% TITAN CAP?" or "60% DEFAULT CAP";
        else state = string.format("%.1f%% TO %d%% CAP", goal-v, goal) end
    elseif key == "spd" then
        v = (n-1)*100; goal = 120; kind = "HARD";
        if v >= 120 - 0.001 then state = "+120% SPEED CAP";
        else state = string.format("%.0f%% TO SPEED CAP", 120-v) end
    else return nil end
    local pct = math.max(0, math.min(1, v / goal));
    return {value=v, goal=goal, progress=pct, marker=marker,
        kind=kind, state=state, tooltip=ABA.milestoneInfo[key] or "",
        complete=v>=goal-0.001, overflow=v>goal+0.001};
end

function ABA.SpellFloor(sp)
    if type(sp) ~= "table" or type(sp.cdmax) ~= "number" then return nil end
    local name = ABA.Pretty(sp.key or "");
    local minCD = 0.25;
    if string.lower(name) == "hellfire" then minCD = 0.5 end
    if string.lower(name) == "divine shield" then return nil end
    if sp.cdmax <= minCD + 0.011 then return "CD FLOOR" end
    return nil;
end
