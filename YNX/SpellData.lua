-- Read spell names/icons and, where possible, the *game's own tooltip text*.
-- Never pass a spell ID to GetSpellTexture: WoW 1.12 expects a spellbook INDEX.
local bookSlots = {};
local actionSlots = {};
local scanTip = nil;
local lastScan = 0;

local function normalize(s)
    return string.gsub(string.lower(tostring(s or "")), "[^%a%d]", "");
end
local function FindBookSpells()
    bookSlots = {};
    ABA.bookIcons = {};
    if type(GetSpellName) ~= "function" then return end
    local b = BOOKTYPE_SPELL or "spell";
    for i = 1, 400 do
        local ok, name = pcall(GetSpellName, i, b);
        if not ok or not name or name == "" then break end
        local k = normalize(name);
        bookSlots[k] = {slot = i, book = b};
        if type(GetSpellTexture) == "function" then
            local ok2, icon = pcall(GetSpellTexture, i, b);
            if ok2 and type(icon) == "string" then ABA.bookIcons[k] = icon end
        end
    end
end
local function GetReader()
    if scanTip then return scanTip end
    if ABA.readerFailed then return nil end
    local parent = CreateFrame("Frame", "ABA_TooltipReaderParent", UIParent);
    parent:Hide();
    local ok, tip = pcall(CreateFrame, "GameTooltip", "ABA_TooltipReader", parent, "GameTooltipTemplate");
    if not ok or not tip or type(tip.SetOwner) ~= "function" then
        ABA.readerFailed = true;
        return nil;
    end
    if tip.EnableMouse then tip:EnableMouse(false) end
    scanTip = tip;
    return tip;
end
local function ReadLines()
    local lines = {};
    local limit = 16;
    if scanTip and scanTip.NumLines then
        local n = scanTip:NumLines();
        if type(n) == "number" and n > 0 then limit = math.min(16, n) end
    end
    for i = 1, limit do
        local left = getglobal("ABA_TooltipReaderTextLeft" .. i);
        local right = getglobal("ABA_TooltipReaderTextRight" .. i);
        local a = left and left.GetText and left:GetText() or nil;
        local b = right and right.GetText and right:GetText() or nil;
        if a and a ~= "" then
            if b and b ~= "" then a = a .. "  " .. b end
            table.insert(lines, a);
        end
    end
    return lines;
end
local function ReadSlot(slot, mode)
    local tt = GetReader();
    if not tt then return nil end
    tt:SetOwner(UIParent, "ANCHOR_NONE");
    if tt.ClearLines then tt:ClearLines() end
    tt:Show();
    local ok;
    if mode == "action" and tt.SetAction then ok = pcall(tt.SetAction, tt, slot.slot);
    elseif mode == "book" and tt.SetSpell then ok = pcall(tt.SetSpell, tt, slot.slot, slot.book);
    end
    if not ok then tt:Hide(); return nil end
    local lines = ReadLines();
    tt:Hide();
    if table.getn(lines) < 2 then return nil end
    return lines;
end

local function FindActionSpells()
    actionSlots = {};
    if type(HasAction) ~= "function" or type(GetActionTexture) ~= "function" then return end
    local tt = GetReader();
    if not tt or not tt.SetAction then return end
    tt:SetOwner(UIParent, "ANCHOR_NONE");
    for slot = 1, 120 do
        if HasAction(slot) then
            if tt.ClearLines then tt:ClearLines() end
            local ok = pcall(tt.SetAction, tt, slot);
            if ok then
                local first = getglobal("ABA_TooltipReaderTextLeft1");
                local title = first and first:GetText();
                if title and title ~= "" then
                    actionSlots[normalize(title)] = {slot = slot};
                    local okIcon, icon = pcall(GetActionTexture, slot);
                    if okIcon and type(icon) == "string" then ABA.bookIcons[normalize(title)] = icon end
                end
            end
        end
    end
    tt:Hide();
end

function ABA.ResetReader()
    ABA.tooltipCache = {};
    ABA.tooltipSource = {};
    ABA.tooltipSample = nil;
    ABA.bookIcons = {};
    ABA.lastTooltipFingerprint = nil;
    ABA.readerFailed = nil;
    FindBookSpells();
    FindActionSpells();
    lastScan = GetTime and GetTime() or 0;
end

function ABA.SpellName(sp)
    return ABA.Pretty(sp and sp.key);
end
function ABA.SpellIcon(sp)
    local name = ABA.SpellName(sp);
    return (ABA.bookIcons and ABA.bookIcons[normalize(name)]) or ABA.Icon(sp.key);
end

-- A tooltip description may contain several numbers and conditional damage
-- figures. We display its actual text; we do not infer a false per-hit DPS.
function ABA.TooltipHeadline(key)
    local lines = ABA.tooltipCache[key];
    if not lines then return nil end
    for i = 2, table.getn(lines) do
        local s = lines[i];
        if s and s ~= "" and
           not string.find(string.lower(s), "cooldown") and
           not string.find(string.lower(s), "rank ") then
            return s;
        end
    end
    return lines[2];
end

local function SampleVisibleTooltip()
    if not GameTooltip or not GameTooltip.IsShown or not GameTooltip:IsShown() then return end
    local title = getglobal("GameTooltipTextLeft1");
    title = title and title.GetText and title:GetText() or nil;
    if not title then return end
    local spells = type(AZS_SPELLS) == "table" and AZS_SPELLS or {};
    for i = 1, table.getn(spells) do
        local sp = spells[i];
        if type(sp) == "table" and normalize(ABA.SpellName(sp)) == normalize(title) then
            local lines = {};
            for j = 1, 16 do
                local f = getglobal("GameTooltipTextLeft" .. j);
                local t = f and f.GetText and f:GetText() or nil;
                if t and t ~= "" then table.insert(lines, t) end
            end
            if table.getn(lines) >= 2 then
                ABA.tooltipCache[sp.key] = lines;
                ABA.tooltipSource[sp.key] = "hover";
                ABA.tooltipSample = lines[2];
            end
            break;
        end
    end
end

function ABA.RefreshTooltipData()
    SampleVisibleTooltip();
    local spells = type(AZS_SPELLS) == "table" and AZS_SPELLS or {};
    local sig = "";
    for i = 1, table.getn(spells) do
        local sp = spells[i];
        if type(sp) == "table" then
            sig = sig .. tostring(sp.key) .. "@" .. tostring(sp.rank) .. ";";
        end
    end
    local now = GetTime();
    if sig == ABA.lastTooltipFingerprint and now - lastScan < 8 then return end
    if now - lastScan > 60 then FindBookSpells(); FindActionSpells() end
    ABA.lastTooltipFingerprint = sig;
    lastScan = now;
    local success = 0;
    for i = 1, table.getn(spells) do
        local sp = spells[i];
        if type(sp) == "table" and sp.key then
            local name = ABA.SpellName(sp);
            local norm = normalize(name);
            local book = bookSlots[norm];
            local action = actionSlots[norm];
            local lines, origin;
            -- Prefer action tooltip, because it may reflect bonuses the game applies.
            if action then lines = ReadSlot(action, "action"); if lines then origin = "action" end end
            if not lines and book then lines = ReadSlot(book, "book"); if lines then origin = "book" end end
            if lines then
                ABA.tooltipCache[sp.key] = lines;
                ABA.tooltipSource[sp.key] = origin;
                ABA.tooltipSample = lines[2];
            end
            if ABA.tooltipCache[sp.key] then success = success + 1 end
        end
    end
    ABA.tooltipStatus = success .. "/" .. table.getn(spells) .. " spells readable";
end

function ABA.FindMeter(sp)
    local name = normalize(ABA.SpellName(sp));
    local list = type(AZS_METER) == "table" and AZS_METER or nil;
    if not list and type(AZS_GetMeter) == "function" then
        local ok, lines = pcall(AZS_GetMeter);
        if ok and type(lines) == "table" then list = lines end
    end
    if type(list) ~= "table" then return nil end
    for i = 1, table.getn(list) do
        local r = list[i];
        if type(r) == "table" and normalize(r.name) == name then return r end
    end
    return nil;
end
