-- YNX 0.15.4. Azeroth Survivors / WoW 1.12 Lua 5.0-compatible UI.
-- Never depend on modern WoW Mixin, _G, #, or mouse-button polling.
local UIState={};
local WHITE="Interface\\Buttons\\WHITE8X8";
local MEDIA="Interface\\AddOns\\YNX\\Media\\";
local PANEL="Interface\\AddOns\\YNX\\Media\\settings_panel.tga";
local BUTTON_PLATE="Interface\\AddOns\\YNX\\Media\\button_plate.tga";
local GAUGE_TRACK="Interface\\AddOns\\YNX\\Media\\gauge_track.tga";
local GAUGE_FILL="Interface\\AddOns\\YNX\\Media\\gauge_fill.tga";
local MODERN=MEDIA.."Modern\\";
-- Dragon UI offers a selectable font family.  Use similarly available native
-- game fonts without depending on Dragon UI (or redistributing its font files).
local CLEAN_FONT="Fonts\\ARIALN.TTF";
local CLASSIC_FONT="Fonts\\FRIZQT__.TTF";
local function SetYNXFont(obj,size,flags,heading)
    local function canUse(path,modifiers)
        local ok,loaded=pcall(obj.SetFont,obj,path,size,modifiers);
        if not ok or loaded==false then return false end
        if loaded then return true end
        if obj.GetFont then
            local actual=obj:GetFont();return actual==path
        end
        return ok
    end
    flags=flags or "OUTLINE";
    local face=heading and "Fonts\\MORPHEUS.TTF" or CLEAN_FONT;
    if not canUse(face,flags) then
        if not canUse(CLASSIC_FONT,flags) then canUse(CLASSIC_FONT,"") end
    end
    if obj.SetShadowColor then obj:SetShadowColor(0,0,0,0.88) end
    if obj.SetShadowOffset then obj:SetShadowOffset(1,-1) end
end
local function HUDValueFontFace()
    local mode=(ABA and ABA.DB and ABA.DB().valueFont) or "clean";
    if mode=="fantasy" then return "Fonts\\MORPHEUS.TTF" end
    if mode=="classic" then return CLASSIC_FONT end
    return CLEAN_FONT
end
local function SetHUDValueFont(obj,size,flags)
    local function canUse(path,modifiers)
        local ok,loaded=pcall(obj.SetFont,obj,path,size,modifiers);
        if not ok or loaded==false then return false end
        if loaded then return true end
        if obj.GetFont then local actual=obj:GetFont(); return actual==path end
        return ok
    end
    flags=flags or "OUTLINE";
    local face=HUDValueFontFace();
    if not canUse(face,flags) then
        if not canUse(CLASSIC_FONT,flags) then canUse(CLASSIC_FONT,"") end
    end
    if obj.SetShadowColor then obj:SetShadowColor(0,0,0,0.88) end
    if obj.SetShadowOffset then obj:SetShadowOffset(1,-1) end
end
local C={blue={0.42,0.75,1},gold={1,0.79,0.32},green={0.45,0.95,0.58},red={1,0.39,0.40},grey={0.73,0.79,0.83},white={0.98,0.98,0.96}};
local currentText={0.94,0.97,1.0};local currentSecondary={0.65,0.74,0.82};
local function StateColor(on) if on then return {0.12,0.48,0.37} end return {0.18,0.23,0.29} end
ABA.stats={
 {key="dmg",name="Damage",short="Dmg",kind="gain",icon="dmg",tier="core"},
 {key="cd",name="Haste",short="Haste",kind="cooldown",icon="cd",tier="core"},
 {key="crit",name="Critical Chance",short="Crit",kind="percent",icon="crit",tier="core"},
 {key="cm",name="Critical Damage",short="CDmg",kind="critmult",icon="cm",tier="core"},
 {key="arm",name="Armor",short="Armor",kind="percent",icon="arm",tier="core"},
 {key="area",name="Area",short="Area",kind="gain",icon="area",tier="core"},
 {key="cnt",name="Extra Targets",short="Targets",kind="int",icon="cnt",tier="core"},
 {key="echo",name="Echo",short="Echo",kind="percent",icon="echo",tier="core"},
 {key="hp",name="Maximum Health",short="HP",kind="int",icon="hp",tier="core"},
 {key="reg",name="Regeneration",short="Regen",kind="rate",icon="reg",tier="core"},
 {key="spd",name="Movement Speed",short="Speed",kind="gain",icon="spd",tier="core"},
 {key="pick",name="Pickup Radius",short="Pickup",kind="range",icon="pick",tier="core"},
 {key="xp",name="Experience",short="XP",kind="gain",icon="xp",tier="core"},
 {key="gold",name="Gold Gain",short="Gold",kind="gain",icon="gold",tier="core"},
 {key="luck",name="Luck",short="Luck",kind="percent",icon="luck",tier="core"},
 {key="heal",name="Heal on Kill",short="Kill HP",kind="int",icon="heal",tier="core"},
 {key="lch",name="Lifesteal",short="Leech",kind="percent",icon="lch",tier="core"},
 {key="thn",name="Thorns",short="Thorns",kind="percent",icon="thn",tier="core"},
 {key="liv",name="Extra Lives",short="Lives",kind="int",icon="liv",tier="core"},
 {key="bp",name="Buff Power",short="Buff",kind="bonus",icon="bp",tier="advanced"},
 {key="big",name="Boss / Elite Damage",short="Boss",kind="bonus",icon="big",tier="advanced"},
 {key="exe",name="Execute Damage",short="Execute",kind="bonus",icon="exe",tier="advanced"},
 {key="cc",name="CC Damage",short="CC Dmg",kind="bonus",icon="cc",tier="advanced"},
 {key="dotd",name="Afflicted Damage",short="Afflict",kind="bonus",icon="dotd",tier="advanced"},
 {key="doth",name="DoT Haste",short="DoT Spd",kind="bonus",icon="doth",tier="advanced"},
 {key="dots",name="DoT Stacks",short="Stacks",kind="int",icon="dots",tier="advanced"},
 {key="shd",name="Shielded Damage",short="Shield",kind="bonus",icon="shd",tier="advanced"},
 {key="auto",name="Melee Damage",short="Melee",kind="bonus",icon="auto",tier="advanced"},
 {key="pet",name="Pet Damage",short="Pet",kind="bonus",icon="pet",tier="advanced"}
};
local explanations={
 dmg="Multiplies the damage dealt by your abilities. Example: +50% raises a 100 hit to roughly 150 before other modifiers.",
 cd="Reduces the time between automatic ability casts. Example: 25% Haste shortens a 4-sec base interval toward 3 sec.",
 crit="Chance for a hit to critically strike. Above 100%, overflow contributes toward critical damage.",
 cm="Multiplier applied to critical hits. Example: 200% means a critical hit deals 2 times its base damage.",
 arm="Reduces incoming damage; the standard reduction cap is 60%.",
 echo="Chance for an additional spell strike. Above 100%, the excess contributes to a further strike.",
 spd="Your character's movement speed bonus. Example: +20% helps you travel and dodge faster.",
 thn="Reflects a fraction of incoming melee damage back toward attackers.",
 liv="Additional lives available during a run.",
 bp="Strengthens damage, haste, shield and thorns buffs.",
 big="Bonus damage against elites and bosses.",
 exe="Damage bonus against enemies below 30% health.",
 cc="Bonus damage to rooted, stunned, slowed or fleeing enemies.",
 dotd="Bonus damage against enemies suffering one of your DoTs; not a global DoT multiplier.",
 doth="Increases damage-over-time tick frequency.",
 dots="Number of simultaneous stacks of each of your DoTs on one enemy.",
 shd="Bonus damage while you have an absorb shield.",
 auto="Damage bonus for automatic melee swings (racial).",
 pet="Damage bonus for pets.",
 hp="Your maximum health pool.",heal="Health restored per kill.",reg="Health regenerated per second.",
 lch="Health recovered from damage dealt.",cnt="Additional targets acquired by targeting spells.",
 luck="Influences level-up card rarity odds; not a guaranteed rare card.",
 area="Increases spell areas and ranges.",pick="Radius for picking up drops.",
 xp="Experience gained multiplier.",gold="Gold gained multiplier."
};
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
local function Font(p,n,color,align)
    local f=p:CreateFontString(nil,"OVERLAY");SetYNXFont(f,n or 11,"OUTLINE");
    f:SetTextColor(color[1],color[2],color[3]);f:SetJustifyH(align or "LEFT");return f;
end
local function BG(f)
    f:SetBackdrop({bgFile=PANEL,edgeFile=WHITE,edgeSize=1});
    f:SetBackdropColor(1,1,1,0.99);
    f:SetBackdropBorderColor(0.25,0.48,0.64,0.94);
end
local function PaintButton(b)
    local c;
    if b.selected then c={0.16,0.23,0.30}
    elseif b.toggleOn == true then c={0.065,0.25,0.20}
    elseif b.toggleOn == false then c={0.11,0.15,0.21}
    else c={0.06,0.105,0.155} end
    if type(b.navTint)=="table" then
        local t=b.navTint;
        if b.selected then c={t[1]*0.24+0.09,t[2]*0.23+0.14,t[3]*0.24+0.20}
        else c={t[1]*0.08+0.038,t[2]*0.06+0.077,t[3]*0.075+0.116} end
    end
    if b.hover then b:SetBackdropColor(math.min(1,c[1]+0.075),math.min(1,c[2]+0.08),math.min(1,c[3]+0.08),0.99)
    else b:SetBackdropColor(c[1],c[2],c[3],0.98) end
    if b.selected and type(b.navTint)=="table" then b:SetBackdropBorderColor(b.navTint[1],b.navTint[2],b.navTint[3],1)
    elseif b.selected then b:SetBackdropBorderColor(0.98,0.72,0.26,1)
    elseif b.toggleOn==true then b:SetBackdropBorderColor(0.22,0.78,0.59,0.97)
    else b:SetBackdropBorderColor(0.24,0.41,0.54,0.90) end
    if b.activeEdge then
        if b.selected or b.toggleOn==true then
            b.activeEdge:SetVertexColor(b.selected and 0.33 or 0.22,b.selected and 0.84 or 0.94,b.selected and 1 or 0.63,1);b.activeEdge:Show()
        else b.activeEdge:Hide() end
    end
end
local function Button(p,title,w,h,onclick)
    local b=CreateFrame("Button",nil,p);b.checkMark=false;b:SetWidth(w);b:SetHeight(h);
    b:SetBackdrop({bgFile=BUTTON_PLATE,edgeFile=WHITE,edgeSize=1});
    b.activeEdge=b:CreateTexture(nil,"OVERLAY");b.activeEdge:SetTexture(WHITE);
    b.activeEdge:SetPoint("TOPLEFT",b,"TOPLEFT",0,-1);
    b.activeEdge:SetPoint("BOTTOMLEFT",b,"BOTTOMLEFT",0,1);b.activeEdge:SetWidth(3);b.activeEdge:Hide();
    b.txt=Font(b,11,C.white,"CENTER");b.txt:SetAllPoints(b);b.txt:SetText(title or "");
    b:SetScript("OnClick",onclick);
    b:SetScript("OnEnter",function() b.hover=true;PaintButton(b) end);
    b:SetScript("OnLeave",function() b.hover=false;PaintButton(b) end);
    PaintButton(b);return b;
end
local function TogglePaint(b,on)
    b.toggleOn=on == true;b.selected=false;PaintButton(b);
    b.txt:SetTextColor(on and 0.93 or 0.70,on and 0.96 or 0.78,on and 0.90 or 0.83);
    if b.checkMark then
        b.checkMark:SetText(on and "X" or "");
        b.checkBackground:SetVertexColor(on and 0.13 or 0.12,on and 0.62 or 0.23,on and 0.38 or 0.33,1);
        b:SetBackdropBorderColor(0.22,0.42,0.57,0.92);
    end
end
local function Label(p,text,x,y,n,color)
    local f=Font(p,n or 11,color or C.grey);f:SetPoint("TOPLEFT",p,"TOPLEFT",x,-y);f:SetText(text);return f;
end
local function Top(f)
    if type(AZS_SetOnTopOfScreens)=="function" then pcall(AZS_SetOnTopOfScreens,f,true) end
end
local function Selected(b,on)
    if not b or not b.txt then return end
    b.selected=on==true;b.toggleOn=nil;PaintButton(b);
    if on and type(b.navTint)=="table" then b.txt:SetTextColor(0.96,0.99,1)
    elseif on then b.txt:SetTextColor(1,0.81,0.42)
    else b.txt:SetTextColor(0.78,0.85,0.91) end
end
local function Tip(self,title,lines)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetText(title,0.42,0.80,1);
    for i=1,table.getn(lines or {}) do if lines[i] and lines[i]~="" then GameTooltip:AddLine(lines[i],0.93,0.94,0.91,1) end end
    GameTooltip:Show();
end
local function HideTip() if GameTooltip then GameTooltip:Hide() end end
-- IMPORTANT: Lua 5.0 button callbacks must not directly capture a numeric/generic
-- for-loop control variable. Bind a stable per-button argument through a
-- function parameter, whose lifetime is independent of the loop iteration.
local function BindClick(value,action)
    return function() action(value) end
end
local function StatTip(row)
    local s=row.stat;if not s then return end
    local lines={"Current: "..ABA.StatsValue(s),explanations[s.key] or ABA.milestoneInfo[s.key] or "Character statistic."};
    local x=ABA.statChanged[s.key];
    local function delta(num)
        if s.kind=="percent" or s.kind=="gain" or s.kind=="cooldown" or s.kind=="critmult" or s.kind=="bonus" then
            return string.format("%+.1f percentage points",num*100*(s.kind=="cooldown" and -1 or 1))
        end
        return string.format("%+.2f",num)
    end
    if x and ABA.statsLive then
        table.insert(lines,"Last change: "..ABA.ValueFrom(s,x.before).."  "..ABA.ChangeAmount(s,x.before,x.after));
        table.insert(lines,"Result: "..ABA.ValueFrom(s,x.after));
    end
    if ABA.base and type(ABA.base[s.key])=="number" and ABA.statsLive and type(AZS_STATS[s.key])=="number" then
        table.insert(lines,"Since run start: "..delta(AZS_STATS[s.key]-ABA.base[s.key]));
    end
    local info=ABA.GetMilestone and ABA.statsLive and ABA.GetMilestone(s.key);
    if info then table.insert(lines,info.state) end
    if ABA.milestoneInfo[s.key] and explanations[s.key] then table.insert(lines,ABA.milestoneInfo[s.key]) end
    table.insert(lines,"Click to open YNX Settings.");Tip(row,s.name,lines);
end
local function SpellTip(row)
    local sp=row.spell;if not sp then return end
    local lines={"Rank "..tostring(sp.rank or "?")};
    if type(sp.cdmax)=="number" then table.insert(lines,string.format("Cooldown %.2f sec",sp.cdmax)) end
    local m=ABA.FindMeter(sp);if m then table.insert(lines,string.format("Damage %.0f | DPS %.1f",m.dmg or 0,m.dps or 0)) end
    table.insert(lines,"Manage spells in Settings.");Tip(row,ABA.SpellName(sp),lines);
end

-- HUD and old, verified v0.6.3 cursor-based gesture implementation.
local hud=CreateFrame("Frame","YNX_MinimalHUD",UIParent);hud:SetWidth(232);hud:SetHeight(33);hud:SetFrameStrata("DIALOG");BG(hud);
hud:SetMovable(true);hud:SetResizable(true);hud:SetMinResize(85,24);hud:EnableMouse(true);
if hud.SetClampedToScreen then hud:SetClampedToScreen(false) end
local settings=CreateFrame("Frame","YNX_Settings",UIParent);settings:SetFrameStrata("TOOLTIP");settings:SetWidth(1180);settings:SetHeight(650);settings:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=2});settings:SetBackdropColor(0.017,0.046,0.078,0.985);settings:SetBackdropBorderColor(0.24,0.62,0.83,1);settings:Hide();
settings:SetMovable(true);settings:EnableMouse(true);
if settings.SetClampedToScreen then settings:SetClampedToScreen(true) end
local posX,posY,moveDrag,resizeDrag,moveHandle,resizeGrip;
local RefreshHandles;
local function Cursor()
    if type(GetCursorPosition)~="function" then return nil,nil end
    local x,y=GetCursorPosition();if type(x)~="number" or type(y)~="number" then return nil,nil end
    return x,y;
end
local function ParentScale()
    local s=UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1;
    if type(s)~="number" or s<=0 then return 1 end return s;
end
local function HudScale()
    local s=hud:GetScale();if type(s)~="number" or s<=0 then return 1 end return s;
end
local function PositionHandles()
    if moveHandle and not moveDrag then moveHandle:ClearAllPoints();moveHandle:SetPoint("TOPLEFT",hud,"TOPLEFT",1,-1) end
    if resizeGrip and not resizeDrag then resizeGrip:ClearAllPoints();resizeGrip:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT",-1,1) end
end
-- Positions use a TOPLEFT anchor and X/Y UI coordinates.  The older
-- BOTTOMLEFT {x,y} saved format is migrated only when first loaded.
-- Crucially there is NO UIParent-width/height clamp: this client may report a
-- smaller virtual UI rectangle than the part of the viewport the user sees.
-- An off-screen position is always recoverable via RESET POSITION or /ynx reset.
local function PutAt(x,y,save)
    if type(x)~="number" or type(y)~="number" then return end
    if x~=posX or y~=posY then
        posX,posY=x,y;
        hud:ClearAllPoints();hud:SetPoint("TOPLEFT",UIParent,"TOPLEFT",x,-y);
    end
    if save then ABA.DB().hudXY={x,y} end
    PositionHandles();
end
local function DefaultPosition()
    local w=UIParent:GetWidth();
    if type(w)~="number" or w<100 then w=1024 end
    return w-280-hud:GetWidth()*HudScale(),65;
end
local function RestoreHUD()
    local d=ABA.DB();hud:SetScale(d.scale);
    local p=d.hudXY;
    if type(p)=="table" and type(p[1])=="number" and type(p[2])=="number" then
        PutAt(p[1],p[2],false);
    else
        p=d.hudPlacement;
        if type(p)=="table" and type(p[1])=="number" and type(p[2])=="number" then
            local h=UIParent:GetHeight();
            if type(h)~="number" or h<100 then h=768 end
            PutAt(p[1],h-p[2],true);
        else
            local x,y=DefaultPosition();PutAt(x,y,true);
        end
    end
end
ABA.RestorePosition=RestoreHUD;RestoreHUD();
local function SavePosition()
    if posX and posY then ABA.DB().hudXY={posX,posY} end
    PositionHandles();if ABA.DockSettings then ABA.DockSettings() end
end
function ABA.StopInteraction()
    moveDrag=nil;resizeDrag=nil;
    SavePosition();if RefreshHandles then RefreshHandles() end
end
function ABA.GetHudXY()
    return posX or 0,posY or 0;
end
function ABA.SetHudXY(x,y)
    ABA.StopInteraction();
    PutAt(x or posX or 0,y or posY or 0,true);
end
function ABA.NudgeHud(dx,dy)
    ABA.SetHudXY((posX or 0)+(dx or 0),(posY or 0)+(dy or 0));
end
function ABA.ResetPosition()
    ABA.StopInteraction();
    local d=ABA.DB();d.hudPos=nil;d.hudPlacement=nil;d.hudXY=nil;
    local x,y=DefaultPosition();PutAt(x,y,true);
end
local function MoveAtCursor()
    if not moveDrag then return end
    local x,y=Cursor();if not x then return end
    PutAt(moveDrag.x+(x-moveDrag.cursorX)/ParentScale(),moveDrag.y-(y-moveDrag.cursorY)/ParentScale(),false);
end
local function BeginMove()
    if moveDrag or resizeDrag then return end local x,y=Cursor();if not x then return end
    moveDrag={cursorX=x,cursorY=y,x=posX,y=posY,lastX=x,lastY=y,idle=0,age=0};HideTip();
end
local function EndMove()
    if not moveDrag then return end MoveAtCursor();moveDrag=nil;SavePosition();
end
local function ResizeAtCursor()
    if not resizeDrag then return end local x=Cursor();if not x then return end
    local d=ABA.DB();local nw=clamp(math.floor(resizeDrag.width+(x-resizeDrag.cursorX)/(ParentScale()*HudScale())+0.5),85,1000);
    if nw~=d.hudWidth or d.autoWidth then
        d.autoWidth=false;d.hudWidth=nw;
        if ABA.Update then ABA.Update(true) end
    end
end
local function BeginResize()
    if moveDrag or resizeDrag then return end local x,y=Cursor();if not x then return end
    resizeDrag={cursorX=x,width=hud:GetWidth(),lastX=x,lastY=y,idle=0,age=0};HideTip();
end
local function EndResize()
    if not resizeDrag then return end ResizeAtCursor();resizeDrag=nil;
    if ABA.Update then ABA.Update(true) end SavePosition();
end
moveHandle=Button(hud,"DONE",46,17,function()
    local d=ABA.DB();d.editLayout=false;d.editMove=false;d.editResize=false;
    ABA.StopInteraction();
    if not settings:IsShown() then ABA.ToggleSettings(); if ABA.SelectTab then ABA.SelectTab("LOOK") end end
end);
moveHandle:SetFrameLevel(hud:GetFrameLevel()+9);
moveHandle:SetScript("OnHide",function() if moveDrag then ABA.StopInteraction() end end);
moveHandle:SetScript("OnEnter",function() Tip(moveHandle,"Finish layout editing",{"Drag the HUD from anywhere.","Use the bottom-right grip to resize.","Click DONE to return to Settings."}) end);
moveHandle:SetScript("OnLeave",HideTip);
resizeGrip=Button(hud,"\\",16,16,function() EndResize() end);
resizeGrip:SetFrameLevel(hud:GetFrameLevel()+9);resizeGrip:RegisterForDrag("LeftButton");
resizeGrip:SetScript("OnMouseDown",function() if arg1=="LeftButton" then BeginResize() end end);
resizeGrip:SetScript("OnDragStart",BeginResize);resizeGrip:SetScript("OnDragStop",EndResize);
resizeGrip:SetScript("OnMouseUp",function() if arg1=="LeftButton" then EndResize() end end);
resizeGrip:SetScript("OnHide",function() if resizeDrag then ABA.StopInteraction() end end);
resizeGrip:SetScript("OnEnter",function() Tip(resizeGrip,"Resize YNX",{"Drag to set manual width.","Lock in LOOK when finished."}) end);
resizeGrip:SetScript("OnLeave",HideTip);
moveHandle:Hide();resizeGrip:Hide();PositionHandles();
RefreshHandles=function()
    local d=ABA.DB();
    if d.editLayout or moveDrag then moveHandle:Show() else moveHandle:Hide() end
    if d.editLayout or resizeDrag then resizeGrip:Show() else resizeGrip:Hide() end
end
local function GestureTick(g,finish,elapsed)
    if not g then return false end local x,y=Cursor();if not x then finish();return true end
    elapsed=type(elapsed)=="number" and elapsed or 0.033;g.age=g.age+elapsed;
    if math.abs(x-g.lastX)+math.abs(y-g.lastY)>0.5 then g.idle=0 else g.idle=g.idle+elapsed end
    g.lastX=x;g.lastY=y;
    if type(IsMouseButtonDown)=="function" and not IsMouseButtonDown("LeftButton") then finish();return true end
    if g.age>4 or (g.age>0.25 and g.idle>0.75) then finish();return true end
    return false;
end

local accentColors={
 blue={0.35,0.65,1},teal={0.30,0.89,0.83},violet={0.78,0.45,1},
 amber={1,0.75,0.33},rose={1,0.44,0.64},white={0.88,0.92,1}
};
local skins={
 shadow={0.011,0.019,0.031,0.98,0.27,0.45,0.57,0.88},
 glass={0.039,0.105,0.141,0.80,0.23,0.70,0.79,0.89},
 classic={0.12,0.079,0.035,0.96,0.85,0.64,0.30,0.95},
 bare={0.012,0.016,0.025,0.32,0.18,0.24,0.34,0.10},
 arcane={0.082,0.048,0.155,0.93,0.70,0.45,1.00,0.96},
 ember={0.135,0.043,0.029,0.93,1,0.43,0.26,0.94},
 emerald={0.017,0.103,0.081,0.91,0.22,0.91,0.68,0.93},
 frost={0.025,0.085,0.145,0.92,0.43,0.84,1.0,0.96},
 solar={0.13,0.085,0.025,0.96,1,0.79,0.33,0.95},
 neon={0.05,0.029,0.105,0.94,0.27,0.96,0.90,0.94}
};
local skinText={
 shadow={{0.95,0.97,1},{0.67,0.76,0.85}},glass={{0.50,0.97,1},{0.46,0.76,0.82}},
 classic={{1,0.87,0.53},{0.89,0.70,0.47}},bare={{0.95,0.97,1},{0.67,0.76,0.85}},
 arcane={{0.92,0.72,1},{0.73,0.53,0.92}},ember={{1,0.69,0.37},{0.94,0.49,0.33}},
 emerald={{0.52,1,0.77},{0.36,0.75,0.60}},frost={{0.59,0.89,1},{0.46,0.69,0.89}},
 solar={{1,0.83,0.40},{0.90,0.70,0.41}},neon={{0.48,1,0.91},{0.76,0.59,1}}
};
-- Real rounded corners built from nine-slice-like frame parts (not stretched corners).
-- A pre-rendered 12px alpha mask lets the legacy client draw rounded geometry.
local roundedParts={background={},stroke={}};
local roundR=16;
local function Part(layer,asset)
    local t=hud:CreateTexture(nil,layer);t:SetTexture(asset or WHITE);t:Hide();return t;
end
local function CreateRoundParts()
    local bg=roundedParts.background;
    bg.middle=Part("BACKGROUND");
    bg.middle:SetPoint("TOPLEFT",hud,"TOPLEFT",roundR,0);
    bg.middle:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT",-roundR,0);
    bg.left=Part("BACKGROUND");bg.left:SetWidth(roundR);
    bg.left:SetPoint("TOPLEFT",hud,"TOPLEFT",0,-roundR);
    bg.left:SetPoint("BOTTOMLEFT",hud,"BOTTOMLEFT",0,roundR);
    bg.right=Part("BACKGROUND");bg.right:SetWidth(roundR);
    bg.right:SetPoint("TOPRIGHT",hud,"TOPRIGHT",0,-roundR);
    bg.right:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT",0,roundR);
    for _,name in ipairs({"tl","tr","bl","br"}) do
        local corner=Part("BACKGROUND",MEDIA.."round_bg_"..name..".tga");
        corner:SetWidth(roundR);corner:SetHeight(roundR);bg[name]=corner;
    end
    bg.tl:SetPoint("TOPLEFT",hud,"TOPLEFT");bg.tr:SetPoint("TOPRIGHT",hud,"TOPRIGHT");
    bg.bl:SetPoint("BOTTOMLEFT",hud,"BOTTOMLEFT");bg.br:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT");
    local st=roundedParts.stroke;
    for _,name in ipairs({"tl","tr","bl","br"}) do
        local corner=Part("ARTWORK",MEDIA.."round_stroke_"..name..".tga");
        corner:SetWidth(roundR);corner:SetHeight(roundR);st[name]=corner;
    end
    st.tl:SetPoint("TOPLEFT",hud,"TOPLEFT");st.tr:SetPoint("TOPRIGHT",hud,"TOPRIGHT");
    st.bl:SetPoint("BOTTOMLEFT",hud,"BOTTOMLEFT");st.br:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT");
    st.top=Part("ARTWORK");st.top:SetPoint("TOPLEFT",hud,"TOPLEFT",roundR,-1);
    st.top:SetPoint("TOPRIGHT",hud,"TOPRIGHT",-roundR,-1);
    st.bottom=Part("ARTWORK");st.bottom:SetPoint("BOTTOMLEFT",hud,"BOTTOMLEFT",roundR,1);
    st.bottom:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT",-roundR,1);
    st.left=Part("ARTWORK");st.left:SetPoint("TOPLEFT",hud,"TOPLEFT",1,-roundR);
    st.left:SetPoint("BOTTOMLEFT",hud,"BOTTOMLEFT",1,roundR);
    st.right=Part("ARTWORK");st.right:SetPoint("TOPRIGHT",hud,"TOPRIGHT",-1,-roundR);
    st.right:SetPoint("BOTTOMRIGHT",hud,"BOTTOMRIGHT",-1,roundR);
end
CreateRoundParts();
local function DrawRound(d,c,accent,opacity)
    local enabled=(d.frameKind=="round" or d.frameKind=="softround");
    for _,piece in pairs(roundedParts.background) do
        if enabled then piece:Show();piece:SetVertexColor(c[1],c[2],c[3],c[4]*opacity)
        else piece:Hide() end
    end
    for key,piece in pairs(roundedParts.stroke) do
        if enabled and d.frameKind=="round" and d.borderWidth>0 then
            if key=="tl" or key=="tr" or key=="bl" or key=="br" then
                if piece.strokeWidth~=d.borderWidth then
                    piece:SetTexture(MEDIA.."round_stroke_"..d.borderWidth.."_"..key..".tga");
                    piece.strokeWidth=d.borderWidth;
                end
            end
            piece:Show();piece:SetVertexColor(accent[1],accent[2],accent[3],c[8]*opacity)
        else piece:Hide() end
    end
    for _,key in ipairs({"top","bottom"}) do roundedParts.stroke[key]:SetHeight(d.borderWidth) end
    for _,key in ipairs({"left","right"}) do roundedParts.stroke[key]:SetWidth(d.borderWidth) end
end
-- One palette resolver for the real HUD and every preview.  The selected skin
-- supplies alpha; optional manual colours override RGB only.
local function ResolvedFrameColors(d)
    local skin=skins[d.skin] or skins.shadow;
    local custom=ABA.ManualColor("background");
    local c={skin[1],skin[2],skin[3],skin[4],skin[5],skin[6],skin[7],skin[8]};
    if custom then c[1]=custom[1];c[2]=custom[2];c[3]=custom[3] end
    local accent=ABA.ManualColor("border") or accentColors[d.accent] or {skin[5],skin[6],skin[7]};
    return c,accent;
end
local function ApplySkin()
    local d=ABA.DB();local c,accent=ResolvedFrameColors(d);
    -- Opacity only affects the panel, not text. Bare is intentionally faint.
    local pal=skinText[d.skin] or skinText.shadow;
    currentText=ABA.ManualColor("text") or pal[1];currentSecondary=ABA.ManualColor("secondary") or pal[2];
    local opacity=clamp(d.opacity,0.05,1);
    if d.frameKind=="box" then
        hud:SetBackdropColor(c[1],c[2],c[3],c[4]*opacity);
        hud:SetBackdropBorderColor(accent[1],accent[2],accent[3],d.borderWidth>0 and c[8]*opacity or 0);
    elseif d.frameKind=="soft" then
        hud:SetBackdropColor(c[1],c[2],c[3],c[4]*opacity);
        hud:SetBackdropBorderColor(0,0,0,0);
    else
        -- float = truly borderless, with no rectangle behind the data.
        -- round = separate background/corner masks, never a square backdrop.
        hud:SetBackdropColor(0,0,0,0);hud:SetBackdropBorderColor(0,0,0,0);
    end
    DrawRound(d,c,accent,opacity);
end
local function SortedSpecs()
    local result={};local d=ABA.DB();local used={};
    for i=1,table.getn(d.statOrder) do
        local key=d.statOrder[i];
        for j=1,table.getn(ABA.stats) do
            local spec=ABA.stats[j];
            if spec.key==key and not used[key] then table.insert(result,spec);used[key]=true end
        end
    end
    for i=1,table.getn(ABA.stats) do
        local spec=ABA.stats[i];if not used[spec.key] then table.insert(result,spec) end
    end
    return result;
end
local function CurrentStats()
    local all=SortedSpecs();local result={};
    for i=1,table.getn(all) do if ABA.IsEnabled(all[i]) then table.insert(result,all[i]) end end
    return result;
end
local function CurrentSpells()
    local result={};local d=ABA.DB();if not d.spellVisible then return result end
    local prof=ABA.SpellProfile();local src=type(AZS_SPELLS)=="table" and AZS_SPELLS or {};
    for i=1,table.getn(src) do
        local s=src[i];if type(s)=="table" and type(s.key)=="string" and prof[s.key] then table.insert(result,s) end
    end
    return result;
end
local emptyHint=Font(hud,11,C.grey,"CENTER");emptyHint:SetPoint("CENTER",hud,"CENTER",0,0);
emptyHint:SetText("YNX  -  click to configure");emptyHint:Hide();
local statWidgets={};
for i=1,table.getn(ABA.stats) do
    local row=CreateFrame("Button",nil,hud);row:SetWidth(90);row:SetHeight(28);row:EnableMouse(true);
    row.icon=row:CreateTexture(nil,"ARTWORK");row.icon:SetWidth(19);row.icon:SetHeight(19);
    row.halo=row:CreateTexture(nil,"BACKGROUND");row.halo:SetTexture(MEDIA.."icon_halo.tga");
    row.halo:SetPoint("CENTER",row.icon,"CENTER",0,0);row.halo:Hide();
    row.icon:SetPoint("LEFT",row,"LEFT",2,0);row.icon:SetTexCoord(0.08,0.92,0.08,0.92);
    row.name=Font(row,11,C.grey);row.name:SetPoint("LEFT",row,"LEFT",2,0);
    row.value=Font(row,12,C.white);row.value:SetPoint("LEFT",row.icon,"RIGHT",3,0);
    row.delta=Font(row,10,C.green);row.delta:SetWidth(58);row.delta:SetJustifyH("RIGHT");row.delta:Hide();
    -- Independent text measurer: the animated "+gain" preview must NEVER
    -- affect automatic cell widths or shift unrelated milestone bars.
    row.measure=Font(row,12,C.white);row.measure:Hide();
    row.flash=row:CreateTexture(nil,"BACKGROUND");row.flash:SetTexture(WHITE);row.flash:SetAllPoints(row);row.flash:SetVertexColor(0.10,0.75,0.29,0);
    row.track=row:CreateTexture(nil,"BACKGROUND");row.track:SetTexture(GAUGE_TRACK);row.track:SetVertexColor(0.26,0.39,0.47,0.82);row.track:SetHeight(2);
    row.track:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",2,2);
    row.fill=row:CreateTexture(nil,"ARTWORK");row.fill:SetTexture(GAUGE_FILL);row.fill:SetHeight(2);row.fill:SetPoint("BOTTOMLEFT",row.track,"BOTTOMLEFT",0,0);
    row.hRule=row:CreateTexture(nil,"OVERLAY");row.hRule:SetTexture(WHITE);row.hRule:SetHeight(2);row.hRule:Hide();
    row.vRule=row:CreateTexture(nil,"OVERLAY");row.vRule:SetTexture(WHITE);row.vRule:SetWidth(2);row.vRule:Hide();
    row.gain=row:CreateTexture(nil,"OVERLAY");row.gain:SetTexture(GAUGE_FILL);row.gain:Hide();
    row.glint=row:CreateTexture(nil,"OVERLAY");row.glint:SetTexture(WHITE);row.glint:SetWidth(3);row.glint:Hide();
    row.marker=row:CreateTexture(nil,"OVERLAY");row.marker:SetTexture(WHITE);row.marker:SetWidth(2);row.marker:SetHeight(5);row.marker:SetVertexColor(1,0.86,0.46,1);
    row:SetScript("OnMouseDown",function() if ABA.DB().editLayout and arg1=="LeftButton" then BeginMove() end end);
    row:SetScript("OnMouseUp",function() if moveDrag then EndMove() end end);
    row:SetScript("OnClick",function() if not ABA.DB().editLayout then ABA.ToggleSettings() end end);
    row:SetScript("OnEnter",function() StatTip(row) end);row:SetScript("OnLeave",HideTip);
    row:Hide();statWidgets[i]=row;
end
local spellWidgets={};
for i=1,12 do
    local row=CreateFrame("Button",nil,hud);row:SetWidth(36);row:SetHeight(40);row:EnableMouse(true);
    row.icon=row:CreateTexture(nil,"ARTWORK");row.icon:SetWidth(28);row.icon:SetHeight(28);row.icon:SetPoint("TOP",row,"TOP",0,-1);
    row.iconFrame=row:CreateTexture(nil,"OVERLAY");row.iconFrame:SetTexture(MODERN.."ability_frame.tga");row.iconFrame:SetAllPoints(row.icon);
    row.detail=Font(row,9,C.grey,"CENTER");row.detail:SetPoint("TOP",row.icon,"BOTTOM",0,0);row.detail:SetWidth(38);
    row:SetScript("OnMouseDown",function() if ABA.DB().editLayout and arg1=="LeftButton" then BeginMove() end end);
    row:SetScript("OnMouseUp",function() if moveDrag then EndMove() end end);
    row:SetScript("OnClick",function() if not ABA.DB().editLayout then ABA.ToggleSettings() end end);
    row:SetScript("OnEnter",function() SpellTip(row) end);row:SetScript("OnLeave",HideTip);
    row:Hide();spellWidgets[i]=row;
end
local procWidgets={};
for i=1,14 do
    local r=CreateFrame("Button",nil,hud);r:SetWidth(115);r:SetHeight(25);r:EnableMouse(true);
    r.ico=r:CreateTexture(nil,"ARTWORK");r.ico:SetWidth(19);r.ico:SetHeight(19);
    r.ico:SetPoint("LEFT",r,"LEFT",1,0);
    r.icoFrame=r:CreateTexture(nil,"OVERLAY");r.icoFrame:SetTexture(MODERN.."ability_frame.tga");r.icoFrame:SetAllPoints(r.ico);
    r.txt=Font(r,11,C.blue);r.txt:SetPoint("LEFT",r.ico,"RIGHT",4,0);r.txt:SetWidth(93);
    r:SetScript("OnMouseDown",function() if ABA.DB().editLayout and arg1=="LeftButton" then BeginMove() end end);
    r:SetScript("OnMouseUp",function() if moveDrag then EndMove() end end);
    r:SetScript("OnClick",function() if not ABA.DB().editLayout then ABA.ToggleSettings();if ABA.SelectTab then ABA.SelectTab("SPELLS") end end end);
    r:SetScript("OnEnter",function()
        if r.procRow then Tip(r,r.procRow.name,{
            string.format("Proc damage: %.0f",r.procRow.dmg or 0),
            string.format("Run DPS: %.1f",r.procRow.dps or 0),
            string.format("Share: %.1f%%",(r.procRow.share or 0)*100),
            "From game damage meter; activation count not available."}) end
    end);r:SetScript("OnLeave",HideTip);r:Hide();procWidgets[i]=r;
end
hud:SetScript("OnMouseDown",function()
    local d=ABA.DB();
    if d.editLayout and arg1=="LeftButton" and not resizeDrag then BeginMove() end
end);
hud:SetScript("OnMouseUp",function()
    local d=ABA.DB();
    if moveDrag then EndMove(); return end
    if resizeDrag then EndResize(); return end
    if d.editLayout then return end
    if arg1=="LeftButton" or arg1=="RightButton" then ABA.ToggleSettings() end
end);

-- Independently positioned settings window (never anchors to HUD scale).
local settingsDragging=false;
local function DockSettings()
    -- Preserve the user-selected Settings position. It never follows the HUD.
    if settingsDragging then return end
    local w=UIParent:GetWidth();local h=UIParent:GetHeight();
    if type(w)~="number" or w<100 then w=1024 end
    if type(h)~="number" or h<100 then h=768 end
    local scale=math.min(1,(w-14)/settings:GetWidth(),(h-14)/settings:GetHeight());
    scale=math.max(0.35,scale);settings:SetScale(scale);
    local d=ABA.DB();
    local offX=type(d.settingsOffsetX)=="number" and d.settingsOffsetX or 0;
    local offY=type(d.settingsOffsetY)=="number" and d.settingsOffsetY or 0;
    -- Refuse obviously invalid saved coordinates after a screen-resolution change.
    local maxX=math.max(0,(w-settings:GetWidth()*scale)/2-8);
    local maxY=math.max(0,(h-settings:GetHeight()*scale)/2-8);
    offX=clamp(offX,-maxX,maxX);offY=clamp(offY,-maxY,maxY);
    settings:ClearAllPoints();settings:SetPoint("CENTER",UIParent,"CENTER",offX,offY);
end
ABA.DockSettings=DockSettings;
local headerTex=settings:CreateTexture(nil,"ARTWORK");headerTex:SetTexture(MEDIA.."title_plate.tga");
headerTex:SetPoint("TOPLEFT",settings,"TOPLEFT",6,-6);
headerTex:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-6,-6);headerTex:SetHeight(31);
headerTex:SetVertexColor(1,1,1,0.98);
SetYNXFont(Label(settings,"YNX   /   Your Numbers eXposed",14,11,15,C.blue),15,"OUTLINE",true);
local settingsDrag=CreateFrame("Button",nil,settings);
settingsDrag:SetPoint("TOPLEFT",settings,"TOPLEFT",8,-7);
-- Keep the drag surface wholly OUTSIDE the title-bar controls. A 1080px
-- hitbox overlapped MOVE HUD after its width increased to 105px in v0.15.3;
-- that invisible Button could swallow clicks in the actual client.
-- Drag area: x=8..968. MOVE HUD begins at x=991 in the 1180px dialog.
settingsDrag:SetWidth(960);settingsDrag:SetHeight(29);settingsDrag:EnableMouse(true);
settingsDrag:SetFrameLevel(settings:GetFrameLevel()+1);
settingsDrag:RegisterForDrag("LeftButton");
settingsDrag:SetScript("OnDragStart",function()
    settingsDragging=true;settings:StartMoving();
end);
settingsDrag:SetScript("OnHide",function()
    if settingsDragging then settings:StopMovingOrSizing();settingsDragging=false end
end);
settingsDrag:SetScript("OnDragStop",function()
    settings:StopMovingOrSizing();settingsDragging=false;
    local cx,cy=settings:GetCenter();local ux,uy=UIParent:GetCenter();
    if type(cx)=="number" and type(ux)=="number" then
        local d=ABA.DB();d.settingsOffsetX=cx-ux;d.settingsOffsetY=cy-uy;
    end
    DockSettings();
end);
settingsDrag:SetScript("OnEnter",function() Tip(settingsDrag,"Move YNX Settings",{"Drag this title bar to reposition the window.","Use R to return to screen centre."}) end);
settingsDrag:SetScript("OnLeave",HideTip);
local topAccent=settings:CreateTexture(nil,"ARTWORK");topAccent:SetTexture(WHITE);
topAccent:SetPoint("TOPLEFT",settings,"TOPLEFT",7,-37);topAccent:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-7,-37);topAccent:SetHeight(2);
topAccent:SetVertexColor(0.91,0.64,0.25,0.95);
local resetMenu=Button(settings,"R",30,27,function()
    local d=ABA.DB();d.settingsOffsetX=0;d.settingsOffsetY=0;DockSettings();
end);resetMenu:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-45,-6);
resetMenu:SetScript("OnEnter",function() Tip(resetMenu,"Reset Settings position",{"Move the Settings window back to the centre."}) end);
resetMenu:SetScript("OnLeave",HideTip);
local moveMenu=Button(settings,"MOVE HUD",105,27,function()
    local d=ABA.DB();d.editLayout=true;d.editMove=true;d.editResize=true;
    settings:Hide();RefreshHandles();if ABA.Update then ABA.Update(true) end
end);moveMenu:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-84,-6);
-- All three title-bar actions take priority over any draggable header layer.
moveMenu:SetFrameLevel(settingsDrag:GetFrameLevel()+2);
resetMenu:SetFrameLevel(settingsDrag:GetFrameLevel()+2);
moveMenu.navTint={0.25,0.95,0.77};moveMenu.selected=true;PaintButton(moveMenu);
SetYNXFont(moveMenu.txt,12,"OUTLINE");moveMenu.txt:SetTextColor(0.86,1,0.95);
moveMenu:SetScript("OnEnter",function() Tip(moveMenu,"Edit HUD layout",{"Close settings and enter direct move/resize mode.","Drag the HUD from anywhere, then click DONE on the HUD to return."}) end);
moveMenu:SetScript("OnLeave",HideTip);
local exit=Button(settings,"X",30,27,function() settings:Hide() end);exit:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-8,-6);
exit:SetFrameLevel(settingsDrag:GetFrameLevel()+2);
exit.navTint={0.95,0.33,0.38};PaintButton(exit);
resetMenu.navTint={0.45,0.78,1};PaintButton(resetMenu);
local sectionKeys={"STATS","SPELLS","LOOK","INSIGHTS"};local tabButtons,pages={},{};local currentTab="LOOK";
local function SelectTab(k)
    currentTab=k;
    for i=1,table.getn(sectionKeys) do
        local id=sectionKeys[i];if id==k then pages[id]:Show() else pages[id]:Hide() end
        Selected(tabButtons[i],id==k);
    end
    if ABA.UpdateSettings then ABA.UpdateSettings() end
end
for i=1,4 do
    local k=sectionKeys[i];local b=Button(settings,k,280,30,BindClick(k,SelectTab));
    b:SetPoint("TOPLEFT",settings,"TOPLEFT",9+(i-1)*291,-48);tabButtons[i]=b;
    local ico=b:CreateTexture(nil,"ARTWORK");ico:SetTexture(MODERN..({"dmg","echo","area","crit"})[i]..".tga");
    ico:SetWidth(19);ico:SetHeight(19);ico:SetPoint("LEFT",b,"LEFT",11,0);
    b.txt:ClearAllPoints();b.txt:SetPoint("LEFT",ico,"RIGHT",10,0);
    b.txt:SetJustifyH("LEFT");b.txt:SetWidth(200);
    b.navTint=({{1,0.73,0.31},{0.70,0.43,0.96},{0.31,0.84,0.98},{0.44,0.90,0.70}})[i];PaintButton(b);
    pages[k]=CreateFrame("Frame",nil,settings);pages[k]:SetPoint("TOPLEFT",settings,"TOPLEFT",9,-87);
    pages[k]:SetWidth(1162);pages[k]:SetHeight(551);pages[k]:Hide();
    pages[k]:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    local panelShade=({STATS={0.023,0.064,0.069},SPELLS={0.035,0.044,0.077},LOOK={0.017,0.057,0.083},INSIGHTS={0.020,0.066,0.064}})[k];
    pages[k]:SetBackdropColor(panelShade[1],panelShade[2],panelShade[3],0.91);
    pages[k]:SetBackdropBorderColor(b.navTint[1]*0.38,b.navTint[2]*0.45,b.navTint[3]*0.52,0.86);
    local rail=pages[k]:CreateTexture(nil,"BACKGROUND");rail:SetTexture(WHITE);
    rail:SetPoint("TOPLEFT",pages[k],"TOPLEFT",0,0);rail:SetWidth(1162);rail:SetHeight(2);
    rail:SetVertexColor(0.94,0.72,0.32,0.9);
end
local function Subpage(parent,key,x,width,click)
    local b=Button(parent,key,width,23,click);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-2);
    local file=nil;
    if key=="CORE" or key=="LAYOUT" or key=="ABILITIES" then file="dmg"
    elseif key=="FRAME" or key=="BARS" then file="area"
    elseif key=="ADVANCED" or key=="EFFECTS" then file="echo"
    elseif key=="PRESETS" or key=="SKINS" then file="cm"
    elseif key=="ORDER" or key=="TEXT" or key=="TRENDS" then file="spd"
    elseif key=="PROCS" or key=="SPELLS" then file="crit"
    elseif key=="COLORS" or key=="NOTES" then file="area"
    end
    if file then
        local icon=b:CreateTexture(nil,"ARTWORK");icon:SetTexture(MODERN..file..".tga");
        icon:SetWidth(13);icon:SetHeight(13);icon:SetPoint("LEFT",b,"LEFT",4,0);
        b.txt:ClearAllPoints();b.txt:SetPoint("LEFT",icon,"RIGHT",7,0);
        b.txt:SetJustifyH("LEFT");b.txt:SetWidth(width-34);
        local navHues={dmg={1,0.77,0.38},echo={0.72,0.43,0.97},area={0.29,0.79,1},crit={0.96,0.58,0.85},cm={0.92,0.58,0.98},spd={0.42,0.82,0.85}};
        b.navTint=navHues[file] or {0.38,0.72,0.90};PaintButton(b);
    end
    return b;
end
local function DimButton(parent,text,x,y,w,fn)
    local b=Button(parent,text,w,25,fn);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y);return b;
end
local function MakeCheck(b,label)
    b:SetHeight(29);b.txt:SetText(label);b.txt:ClearAllPoints();b.txt:SetPoint("LEFT",b,"LEFT",35,0);
    b.txt:SetJustifyH("LEFT");b.txt:SetWidth(b:GetWidth()-42);
    b.checkBackground=b:CreateTexture(nil,"ARTWORK");b.checkBackground:SetTexture(WHITE);
    b.checkBackground:SetPoint("LEFT",b,"LEFT",10,0);b.checkBackground:SetWidth(17);b.checkBackground:SetHeight(17);
    b.checkMark=Font(b,12,C.white,"CENTER");b.checkMark:SetPoint("CENTER",b.checkBackground,"CENTER",0,0);
    return b;
end
local function StepRow(parent,title,y,key,step,min,max,format,change)
    Label(parent,title,6,y,11);
    local minus=DimButton(parent,"-",5,y+18,54,function()
        ABA.StopInteraction();local d=ABA.DB();d[key]=clamp(math.floor((d[key]-step)*100+0.5)/100,min,max);
        if change then change(d) end ABA.Update(true);
    end);
    local plus=DimButton(parent,"+",309,y+18,54,function()
        ABA.StopInteraction();local d=ABA.DB();d[key]=clamp(math.floor((d[key]+step)*100+0.5)/100,min,max);
        if change then change(d) end ABA.Update(true);
    end);
    local center=Font(parent,12,C.gold,"CENTER");center:SetPoint("TOPLEFT",parent,"TOPLEFT",65,-(y+23));center:SetWidth(238);
    return {minus=minus,plus=plus,value=center,key=key,format=format};
end
local function TextTip(b,text) b:SetScript("OnEnter",function() Tip(b,text,{"Click to change."}) end);b:SetScript("OnLeave",HideTip) end

local Gauge;  -- shared by the live HUD and the preview renderer
local function BuildGhostRows(host,maxRows)
    host.rows={};
    for i=1,maxRows do
        local row=CreateFrame("Frame",nil,host);row:SetFrameLevel(host:GetFrameLevel()+2);
        row.flash=row:CreateTexture(nil,"BACKGROUND");row.flash:SetTexture(WHITE);row.flash:SetAllPoints(row);row.flash:SetVertexColor(0,0,0,0);
        row.icon=row:CreateTexture(nil,"ARTWORK");row.icon:SetWidth(19);row.icon:SetHeight(19);row.icon:SetPoint("LEFT",row,"LEFT",2,0);
        row.halo=row:CreateTexture(nil,"BACKGROUND");row.halo:SetTexture(MEDIA.."icon_halo.tga");row.halo:SetPoint("CENTER",row.icon,"CENTER",0,0);row.halo:Hide();
        row.name=Font(row,10,C.grey);row.name:SetPoint("LEFT",row,"LEFT",2,0);
        row.value=Font(row,12,C.white);row.value:SetPoint("LEFT",row.icon,"RIGHT",3,0);
        row.delta=Font(row,10,C.green);row.delta:SetWidth(60);row.delta:SetJustifyH("RIGHT");row.delta:Hide();
        row.measure=Font(row,12,C.white);row.measure:Hide();
        row.track=row:CreateTexture(nil,"BACKGROUND");row.track:SetTexture(GAUGE_TRACK);row.track:SetVertexColor(0.26,0.39,0.47,0.82);row.track:SetHeight(2);row.track:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",2,2);row.track:Hide();
        row.fill=row:CreateTexture(nil,"ARTWORK");row.fill:SetTexture(GAUGE_FILL);row.fill:SetHeight(2);row.fill:SetPoint("BOTTOMLEFT",row.track,"BOTTOMLEFT",0,0);row.fill:Hide();
        row.marker=row:CreateTexture(nil,"OVERLAY");row.marker:SetTexture(WHITE);row.marker:SetWidth(2);row.marker:SetHeight(5);row.marker:SetVertexColor(1,0.86,0.46,1);row.marker:Hide();
        row.hRule=row:CreateTexture(nil,"OVERLAY");row.hRule:SetTexture(WHITE);row.hRule:SetHeight(2);row.hRule:Hide();
        row.vRule=row:CreateTexture(nil,"OVERLAY");row.vRule:SetTexture(WHITE);row.vRule:SetWidth(2);row.vRule:Hide();
        row.gain=row:CreateTexture(nil,"OVERLAY");row.gain:SetTexture(GAUGE_FILL);row.gain:Hide();
        row.glint=row:CreateTexture(nil,"OVERLAY");row.glint:SetTexture(WHITE);row.glint:SetWidth(3);row.glint:Hide();
        row:Hide();host.rows[i]=row;
    end
end

-- Full-row layout items: real separators/spacers (not per-stat border hacks).
function UIState.DrawExtras(host,extras,width,overallHeight)
    local lines=rawget(host,"extraLines");if type(lines)~="table" then lines={};host.extraLines=lines end
    for i=1,table.getn(extras) do
        local item=extras[i];local line=lines[i];
        if not line then line=host:CreateTexture(nil,"OVERLAY");line:SetTexture(WHITE);lines[i]=line end
        local d=ABA.DB();local c=ABA.ManualColor("border") or currentSecondary;
        if item.kind=="columnSeparator" then
            line:ClearAllPoints();line:SetPoint("TOPLEFT",host,"TOPLEFT",item.x,-d.hudPadding);
            line:SetWidth(d.separatorThickness);
            line:SetHeight(math.max(3,(overallHeight or 50)-2*d.hudPadding));
            line:SetVertexColor(c[1],c[2],c[3],0.75);line:Show();
        elseif item.kind=="separator" then
            line:ClearAllPoints();line:SetPoint("TOP",host,"TOPLEFT",width/2,-item.y-d.separatorBefore);
            line:SetWidth(math.max(6,(width-2*d.hudPadding)*d.separatorLength));
            line:SetHeight(d.separatorThickness);line:SetVertexColor(c[1],c[2],c[3],0.75);line:Show()
        else line:Hide() end
    end
    for i=table.getn(extras)+1,table.getn(lines) do lines[i]:Hide() end
end

local function PreviewWidthOf(label,fallback)
    if label and type(label.GetStringWidth)=="function" then local w=label:GetStringWidth();if type(w)=="number" and w>0 then return w end end
    return fallback;
end

local function PreviewRowWidth(row,spec,d)
    local size=d.iconSize;local width=4;
    local stable=ABA.ValueFrom(spec,(type(AZS_STATS)=="table" and AZS_STATS[spec.key]) or nil);
    if d.statStyle~="text" then width=width+size+3 end
    if d.statStyle=="both" or d.statStyle=="text" then width=width+PreviewWidthOf(row.name,string.len(spec.short)*6.6)+4 end
    width=width+math.max(PreviewWidthOf(row.measure,string.len(stable)*d.fontSize*0.67),d.fontSize*4.5)+d.iconGap+6;
    return math.max(44,math.ceil(width));
end

local function PopulateGhostHUD(host,stats,availableWidth,forceHeight)
    local d=ABA.DB(); local total=table.getn(stats); local size=d.iconSize; local pad=d.hudPadding; local colGap=d.colGap or 3;
    local rowH=math.max(size,d.fontSize)+7+d.rowGap+(d.showMilestones and d.gaugeHeight+3 or 0);
    local requiredCell=50;
    for i=1,table.getn(host.rows) do
        local row=host.rows[i]; local spec=stats[i];
        if spec then
            row.stat=spec; row.icon:SetTexture((d.iconTheme=="modern" and MODERN or MEDIA)..spec.icon..".tga");
            row.icon:SetTexCoord(d.iconTheme=="modern" and 0 or 0.08,d.iconTheme=="modern" and 1 or 0.92,d.iconTheme=="modern" and 0 or 0.08,d.iconTheme=="modern" and 1 or 0.92);
            row.icon:SetWidth(size); row.icon:SetHeight(size); row.halo:SetWidth(size+7); row.halo:SetHeight(size+7);
            if d.iconTheme=="modern" and d.frameKind~="float" then row.halo:SetVertexColor(0.28,0.72,0.95,0.38);row.halo:Show() else row.halo:Hide() end
            local lum=d.iconBrightness; row.icon:SetVertexColor(lum,lum,lum,1);
            SetHUDValueFont(row.value,d.fontSize,"OUTLINE"); row.value:SetText(ABA.DisplayValue(spec));
            SetHUDValueFont(row.delta,math.max(9,d.fontSize-2),"OUTLINE");
            SetHUDValueFont(row.measure,d.fontSize,"OUTLINE"); row.measure:SetText(ABA.ValueFrom(spec,(type(AZS_STATS)=="table" and AZS_STATS[spec.key]) or nil));
            row.value:SetTextColor(currentText[1],currentText[2],currentText[3]);
            row.name:SetTextColor(currentSecondary[1],currentSecondary[2],currentSecondary[3]);
            row.name:SetText(spec.short); SetYNXFont(row.name,math.max(9,d.fontSize-2),"OUTLINE");
            local required=PreviewRowWidth(row,spec,d); row.required=required; requiredCell=math.max(requiredCell,required);
        else row.stat=nil; row:Hide() end
    end
    -- Calculate in HUD coordinates, never in preview viewport coordinates.
    -- Preview scaling happens AFTER these calculations, so a 2-column HUD
    -- never silently turns into one column just because the preview is narrow.
    local cols=1;
    if d.layoutMode=="grid" then cols=d.columns
    elseif d.layoutMode=="horizontal" then
        cols=math.max(1,math.floor(((d.autoWidth and 440 or d.hudWidth)-pad*2+colGap)/(requiredCell+colGap)))
    end
    cols=math.max(1,math.min(total>0 and total or 1,cols));
    local width;
    if d.autoWidth then width=math.max(54,cols*requiredCell+math.max(0,cols-1)*colGap+pad*2+2)
    else
        width=math.max(d.hudWidth,requiredCell+pad*2+2);
        if d.layoutMode=="horizontal" then cols=math.max(1,math.floor((width-pad*2+colGap)/(requiredCell+colGap)));cols=math.min(total>0 and total or 1,cols)
        else cols=math.min(cols,math.max(1,math.floor((width-pad*2+colGap)/(requiredCell+colGap)))) end
    end
    width=clamp(width,54,1000);host:SetWidth(width);
    local coords,extras,overallHeight=ABA.StatGeometry(stats,cols,requiredCell,rowH,pad,colGap);
    for i=1,table.getn(host.rows) do
        local row=host.rows[i]; local spec=stats[i];
        if spec then
            local at=coords[i];
            row:SetWidth(requiredCell); row:SetHeight(rowH-1); row:ClearAllPoints();
            row:SetPoint("TOPLEFT",host,"TOPLEFT",at.x,-at.y);
            row.icon:Hide(); row.name:Hide(); row.value:ClearAllPoints();
            local anchor=row; local pos="LEFT";
            if d.statStyle~="text" then row.icon:Show(); row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT",row,"LEFT",2,0); anchor=row.icon; pos="RIGHT"; end
            if d.statStyle=="both" or d.statStyle=="text" then row.name:Show(); row.name:ClearAllPoints(); row.name:SetPoint("LEFT",anchor,pos,d.statStyle=="text" and 2 or d.iconGap,0); anchor=row.name; pos="RIGHT"; end
            row.value:SetPoint("LEFT",anchor,pos,d.iconGap,d.valueYOffset);
            row.delta:ClearAllPoints(); row.delta:SetPoint("RIGHT",row,"RIGHT",-4,6+d.valueYOffset);
            Gauge(row,spec,requiredCell-3);
            row.hRule:Hide();row.vRule:Hide();
            row:Show();
        end
    end
    UIState.DrawExtras(host,extras,width,overallHeight);
    local height=total==0 and 0 or overallHeight;
    host:SetHeight(math.max(forceHeight or 0,height));
    return width,height;
end

-- STATS page: Core, Advanced, Presets. 29 stats, each individually toggled.
local statPage="core";local statPane=pages.STATS;
local statTabButtons={};
for i,key in ipairs({"core","advanced","order","presets"}) do
    local b=Subpage(statPane,string.upper(key),2+(i-1)*93,89,BindClick(key,function(which)
        statPage=which;ABA.DB().statPage=which;ABA.Update(true)
    end));
    statTabButtons[i]=b;
end
local statGroups={};for _,key in ipairs({"core","advanced","order","presets"}) do
    local page=CreateFrame("Frame",nil,statPane);page:SetPoint("TOPLEFT",statPane,"TOPLEFT",0,-35);page:SetWidth(368);page:SetHeight(392);page:Hide();statGroups[key]=page;
end
local statSelect={};local statSelectByKey={};local tierCounts={core=0,advanced=0};
for i=1,table.getn(ABA.stats) do
    local s=ABA.stats[i];local tier=s.tier;tierCounts[tier]=tierCounts[tier]+1;
    local index=tierCounts[tier];local col=math.mod(index-1,2);local row=math.floor((index-1)/2);
    local page=statGroups[tier];local x=col*184;local y=row*29+2;
    local b=Button(page,"",181,26,BindClick(s,function(spec)
        ABA.DB().activePreset="custom";ABA.SetStat(spec.key,not ABA.IsEnabled(spec));
    end));
    b:SetPoint("TOPLEFT",page,"TOPLEFT",x,-y);
    b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetWidth(19);b.icon:SetHeight(19);b.icon:SetTexture(MODERN..s.icon..".tga");b.icon:SetPoint("LEFT",b,"LEFT",3,0);
    b.label=Font(b,10,C.grey);b.label:SetPoint("LEFT",b,"LEFT",25,0);b.label:SetWidth(121);
    b.state=Font(b,9,C.grey,"RIGHT");b.state:SetWidth(27);b.state:SetPoint("RIGHT",b,"RIGHT",-5,0);
    b:SetScript("OnEnter",function() Tip(b,s.name,{ABA.StatsValue(s),explanations[s.key] or ABA.milestoneInfo[s.key] or "Click to track or hide.","Change ordering and add dividers in ORDER."}) end);
    b:SetScript("OnLeave",HideTip);
    statSelect[i]={btn=b,spec=s};statSelectByKey[s.key]=b;
end
Label(statGroups.core,"Select which stats appear; arrange them in ORDER.",5,306,10,C.grey);
Label(statGroups.advanced,"Advanced bonuses may remain 0 until upgraded.",5,157,10,C.grey);
-- ORDER: exact global HUD order, including both CORE and ADVANCED stats.
local orderPane=statGroups.order;local orderIndex=1;local orderRows={};
Label(orderPane,"HUD ORDER  /  STATS + LAYOUT ELEMENTS",6,2,11,C.gold);
Label(orderPane,"Move stats, or insert a full-width line/spacer after any stat.",6,21,10,C.grey);
-- A single insert chooser handles all stat rows: no dozens of nested menus.
UIState.insertAfter=nil;
UIState.insertMenu=CreateFrame("Frame",nil,orderPane);UIState.insertMenu:SetWidth(354);UIState.insertMenu:SetHeight(48);
UIState.insertMenu:SetPoint("TOPLEFT",orderPane,"TOPLEFT",7,-270);
UIState.insertMenu:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
UIState.insertMenu:SetBackdropColor(0.045,0.12,0.17,1);UIState.insertMenu:SetBackdropBorderColor(0.27,0.73,0.82,1);
local inserts={{"ROW LINE","separator"},{"COL LINE","columnSeparator"},{"SPACER","spacer"},{"CANCEL",false}};
for i,option in ipairs(inserts) do
    local b=DimButton(UIState.insertMenu,option[1],3+(i-1)*88,8,85,BindClick(option[2],function(kind)
        local after=UIState.insertAfter; UIState.insertAfter=nil;UIState.insertMenu:Hide();
        if after and kind then ABA.SetExtraAfter(after,kind) end
    end));
end
UIState.insertMenu:Hide();
for i=1,8 do
    local b=Button(orderPane,"",357,30,function() end);
    b:SetPoint("TOPLEFT",orderPane,"TOPLEFT",5,-(42+(i-1)*34));
    b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetWidth(18);b.icon:SetHeight(18);b.icon:SetPoint("LEFT",b,"LEFT",6,0);
    b.title=Font(b,10,C.white);b.title:SetPoint("LEFT",b,"LEFT",29,0);b.title:SetWidth(192);
    b.up=Button(b,"^",24,22,function() if type(b.spec)=="table" then ABA.MoveStat(b.spec.key,-1) end end);
    b.up:SetPoint("RIGHT",b,"RIGHT",-63,0);
    b.down=Button(b,"v",24,22,function() if type(b.spec)=="table" then ABA.MoveStat(b.spec.key,1) end end);
    b.down:SetPoint("RIGHT",b,"RIGHT",-36,0);
    b.add=Button(b,"+",29,22,function()
        if b.spec then
            UIState.insertAfter=b.spec.key;UIState.insertMenu:Show();
        elseif b.extra then
            ABA.SetExtraAfter(b.extra.after,nil)
        end
    end);b.add:SetPoint("RIGHT",b,"RIGHT",-4,0);
    b:SetScript("OnEnter",function()
        if b.spec then Tip(b,b.spec.name,{"Move this stat or insert a layout element after it.","Row line, column line or spacer."})
        elseif b.extra then Tip(b,b.extra.kind,{"This is a real layout element.","Click X to remove it."}) end
    end);b:SetScript("OnLeave",HideTip);
    b:Hide();orderRows[i]=b;
end
local orderPrev=DimButton(orderPane,"< BACK",5,316,104,function() orderIndex=math.max(1,orderIndex-1);ABA.Update(true) end);
local orderNext=DimButton(orderPane,"NEXT >",257,316,105,function() orderIndex=orderIndex+1;ABA.Update(true) end);
local orderPageLabel=Label(orderPane,"",158,322,11,C.gold);
local gapRow=StepRow(orderPane,"ROW SPACING",349,"rowGap",1,0,24,function(v) return tostring(v).." px" end);
local presetPage=statGroups.presets;
Label(presetPage,"Choose a monitoring preset (not an automatic build advisor):",4,2,10,C.grey);
local presetButtons={};
for i=1,table.getn(ABA.presets) do
    local spec=ABA.presets[i];local col=math.mod(i-1,2);local row=math.floor((i-1)/2);
    local b=DimButton(presetPage,spec.name,4+col*184,25+row*36,178,BindClick(spec.key,ABA.ApplyPreset));
    presetButtons[i]={btn=b,key=spec.key};
end
Label(presetPage,"NAMED PROFILES  |  save current tracked stats + HUD order",5,178,10,C.gold);
local slotButtons={};
local function ProfileRow(slot)
    local d=ABA.DB();local y=201+(slot-1)*48;
    Label(presetPage,tostring(slot)..".",5,y+9,11,C.gold);
    local edit=CreateFrame("EditBox",nil,presetPage);
    edit:SetWidth(155);edit:SetHeight(23);edit:SetPoint("TOPLEFT",presetPage,"TOPLEFT",29,-y);
    SetYNXFont(edit,11,"OUTLINE");
    edit:SetAutoFocus(false);edit:SetMaxLetters(24);
    if edit.SetTextInsets then edit:SetTextInsets(5,3,1,1) end;
    edit:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    edit:SetBackdropColor(0.035,0.08,0.12,0.97);edit:SetBackdropBorderColor(0.33,0.54,0.68,0.85);
    edit:SetScript("OnEscapePressed",function() edit:ClearFocus() end);
    edit:SetScript("OnEnterPressed",function() edit:ClearFocus() end);
    local save=DimButton(presetPage,"SAVE",191,y,79,function()
        edit:ClearFocus();ABA.SaveCustomProfile(slot,edit:GetText());
        ABA.Message("Saved: "..tostring(ABA.DB().customProfiles[slot].name));ABA.Update(true);
    end);
    local load=DimButton(presetPage,"LOAD",278,y,88,function()
        if not ABA.LoadCustomProfile(slot) then ABA.Message("Profile "..slot.." is empty.") end
    end);
    local status=Label(presetPage,"EMPTY",29,y+28,9,C.grey);
    edit:SetScript("OnEnter",function() Tip(edit,"Profile name",{"Type a name (up to 24 characters).","Press SAVE to store current selection + order."}) end);
    edit:SetScript("OnLeave",HideTip);
    save:SetScript("OnEnter",function() Tip(save,"Save profile",{"Save tracked stats and HUD order under this name.","Existing profile in this slot will be replaced."}) end);
    save:SetScript("OnLeave",HideTip);
    load:SetScript("OnEnter",function() Tip(load,"Load profile",{"Restore tracked stats and their HUD order.","Appearance and spells are not changed."}) end);
    load:SetScript("OnLeave",HideTip);
    return {edit=edit,save=save,load=load,status=status,slot=slot};
end
for i=1,3 do slotButtons[i]=ProfileRow(i) end
local share=DimButton(presetPage,"SHARE CURRENT STATS  /ynx export",4,355,359,function()
    ABA.Message("Preset code: "..ABA.ExportCode());
end);
share:SetScript("OnEnter",function() Tip(share,"Share a preset",{
    "The stat order code appears in chat.","To import: /ynx import YNX1:dmg,crit,cm"}) end);
share:SetScript("OnLeave",HideTip);
-- SPELLS: all configuration here, no removal controls on the HUD.
local spPane=pages.SPELLS;local spellPage="abilities";local spellPages={};local spellPageButtons={};
for i,k in ipairs({"abilities","procs"}) do
    local b=Subpage(spPane,string.upper(k),2+(i-1)*186,181,BindClick(k,function(page)
        spellPage=page;ABA.Update(true)
    end));spellPageButtons[i]={btn=b,key=k};
    local pg=CreateFrame("Frame",nil,spPane);pg:SetWidth(368);pg:SetHeight(396);
    pg:SetPoint("TOPLEFT",spPane,"TOPLEFT",0,-31);pg:Hide();spellPages[k]=pg;
end
local abilityPane=spellPages.abilities;
Label(abilityPane,"OWNED ABILITIES  |  choose which ones appear on HUD",4,5,10,C.gold);
local showSpells=DimButton(abilityPane,"SPELL HUD: OFF",4,30,176,function()
    local d=ABA.DB();d.spellVisible=not d.spellVisible;ABA.Update(true)
end);
local clearSpells=DimButton(abilityPane,"CLEAR TRACKING",189,30,175,function()
    local d=ABA.DB();d.spellProfiles[ABA.ClassKey()]={};d.procProfiles[ABA.ClassKey()]={};d.spellVisible=false;ABA.Update(true)
end);
local spellSelect={};
for i=1,12 do
    local col=math.mod(i-1,2);local row=math.floor((i-1)/2);
    -- Two-stage declaration: Lua does not put 'b' in scope inside its initializer.
    local b;
    b=Button(abilityPane,"",179,38,function()
        if type(b.spell)~="table" or not b.spell.key then return end
        local p=ABA.SpellProfile();p[b.spell.key]=not p[b.spell.key];
        if p[b.spell.key] then ABA.DB().spellVisible=true end
        ABA.Update(true);
    end);
    b:SetPoint("TOPLEFT",abilityPane,"TOPLEFT",4+col*184,-(64+row*43));
    b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetWidth(29);b.icon:SetHeight(29);b.icon:SetPoint("LEFT",b,"LEFT",4,0);
    b.iconFrame=b:CreateTexture(nil,"OVERLAY");b.iconFrame:SetTexture(MODERN.."ability_frame.tga");b.iconFrame:SetAllPoints(b.icon);
    b.text=Font(b,10,C.grey);b.text:SetPoint("LEFT",b,"LEFT",36,0);b.text:SetWidth(137);
    b:SetScript("OnEnter",function() if type(b.spell)=="table" then SpellTip(b) end end);
    b:SetScript("OnLeave",HideTip);b:Hide();spellSelect[i]=b;
end
Label(abilityPane,"Spell tracking is remembered separately by class.",4,345,10,C.grey);
local procPane=spellPages.procs;local procPage=1;local procSelect={};
Label(procPane,"DAMAGE PROCS  |  talents and items recorded by the meter",4,5,10,C.gold);
Label(procPane,"Only procs that have dealt damage appear below.",4,26,10,C.grey);
for i=1,12 do
    local col=math.mod(i-1,2);local line=math.floor((i-1)/2);
    local b;
    b=Button(procPane,"",178,40,function()
        if not b.procName then return end
        local p=ABA.ProcProfile();p[b.procName]=not p[b.procName];
        if p[b.procName] then ABA.DB().spellVisible=true end
        ABA.Update(true);
    end);
    b:SetPoint("TOPLEFT",procPane,"TOPLEFT",4+col*184,-(55+line*45));
    b.ico=b:CreateTexture(nil,"ARTWORK");b.ico:SetWidth(25);b.ico:SetHeight(25);
    b.ico:SetPoint("LEFT",b,"LEFT",3,0);
    b.icoFrame=b:CreateTexture(nil,"OVERLAY");b.icoFrame:SetTexture(MODERN.."ability_frame.tga");b.icoFrame:SetAllPoints(b.ico);
    b.main=Font(b,10,C.white);b.main:SetWidth(145);b.main:SetPoint("TOPLEFT",b,"TOPLEFT",32,-6);
    b.sub=Font(b,9,C.grey);b.sub:SetWidth(144);b.sub:SetPoint("TOPLEFT",b,"TOPLEFT",32,-23);
    b:SetScript("OnEnter",function()
        if b.procRow then Tip(b,b.procRow.name,{
            "Talent/item proc damage recorded by the game.",
            string.format("Total: %.0f damage | %.1f DPS",b.procRow.dmg or 0,b.procRow.dps or 0),
            string.format("Damage share: %.1f%%",(b.procRow.share or 0)*100),
            "Select to show its DPS on the compact HUD.",
            "Individual activations and cooldowns are not exposed."}) end
    end);b:SetScript("OnLeave",HideTip);
    b:Hide();procSelect[i]=b;
end
local procPrev=DimButton(procPane,"< PREVIOUS",4,333,173,function() procPage=math.max(1,procPage-1);ABA.Update(true) end);
local procNext=DimButton(procPane,"NEXT >",191,333,173,function() procPage=procPage+1;ABA.Update(true) end);
local procPageLabel=Label(procPane,"",5,373,10,C.grey);


-- LOOK: three consolidated workspaces, two controls cards and a constant preview.
local lookPane=pages.LOOK;local lookPage="layout";
local lookTabs={};local lookGroups={};
local lookPages={{"LAYOUT","layout","dmg"},{"THEMES","skins","cm"},{"FRAME","frame","arm"},{"TEXT","text","xp"},{"BARS","bars","area"},{"FX","effects","echo"}};
for i,info in ipairs(lookPages) do
    local b=Subpage(lookPane,info[1],8+(i-1)*124,119,BindClick(info[2],function(which)
        lookPage=which;ABA.DB().lookPage=which;ABA.Update(true)
    end));
    b:SetHeight(32);b.txt:SetPoint("CENTER",b,"CENTER",8,0);
    local ico=b:CreateTexture(nil,"ARTWORK");ico:SetTexture(MODERN..info[3]..".tga");
    ico:SetWidth(17);ico:SetHeight(17);ico:SetPoint("LEFT",b,"LEFT",7,0);
    lookTabs[i]=b;
end
for _,key in ipairs({"layout","skins","frame","text","effects","bars"}) do
    local pane=CreateFrame("Frame",nil,lookPane);
    pane:SetPoint("TOPLEFT",lookPane,"TOPLEFT",9,-54);
    pane:SetWidth(368);pane:SetHeight(478);pane:Hide();
    pane:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    pane:SetBackdropColor(0.027,0.073,0.113,0.98);
    pane:SetBackdropBorderColor(0.21,0.47,0.64,0.8);
    lookGroups[key]=pane;
end
UIState.lookSides={};
for _,key in ipairs({"layout","skins","frame","text","effects","bars"}) do
    local pane=CreateFrame("Frame",nil,lookPane);
    pane:SetPoint("TOPLEFT",lookPane,"TOPLEFT",388,-54);
    pane:SetWidth(368);pane:SetHeight(478);pane:Hide();
    pane:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    pane:SetBackdropColor(0.027,0.073,0.113,0.98);
    pane:SetBackdropBorderColor(0.21,0.47,0.64,0.8);
    UIState.lookSides[key]=pane;
end
local lay=lookGroups.layout;
local layoutModeButtons={};
Label(lay,"HUD ARRANGEMENT  |  choose how your stats flow",5,3,11,C.gold);
for i,info in ipairs({{"VERTICAL","vertical"},{"GRID","grid"},{"HORIZONTAL","horizontal"}}) do
    local b=DimButton(lay,info[1],5+(i-1)*123,22,116,BindClick(info[2],function(mode) ABA.DB().layoutMode=mode;ABA.Update(true) end));
    layoutModeButtons[i]={btn=b,key=info[2]};
end
local colsButtons={};Label(lay,"GRID COLUMNS",5,57,11,C.grey);
for i=1,3 do
    local b=DimButton(lay,tostring(i),5+(i-1)*123,77,116,BindClick(i,function(cols) ABA.DB().columns=cols;ABA.Update(true) end));
    colsButtons[i]=b;
end
local autoWidth=DimButton(lay,"AUTO WIDTH: ON",5,112,359,function() local d=ABA.DB();d.autoWidth=not d.autoWidth;ABA.Update(true) end);
local gapColRow=StepRow(lay,"COLUMN GAP",149,"colGap",1,0,24,function(v) return tostring(v).." px" end);
local scaleRow=StepRow(lay,"HUD SCALE",203,"scale",0.05,0.50,2.0,function(v) return tostring(math.floor(v*100+0.5)).."%" end);
local widthRow=StepRow(lay,"MANUAL WIDTH",257,"hudWidth",20,85,1000,function(v) return tostring(math.floor(v+0.5)).." px" end,function(d) d.autoWidth=false end);
-- Direct XY positioning shares the same coordinate domain as mouse dragging.
-- Signed values are intentional: some AZS clients have a smaller virtual
-- UIParent area than the visible game window, so offsets can be negative.
Label(lay,"X  /  FROM LEFT",6,303,10,C.grey);
Label(lay,"Y  /  FROM TOP",190,303,10,C.grey);
local coordFields={};
local function CoordBox(axis,x)
    local box=CreateFrame("EditBox",nil,lay);
    box:SetWidth(78);box:SetHeight(25);
    box:SetPoint("TOPLEFT",lay,"TOPLEFT",x,-320);
    SetYNXFont(box,12,"OUTLINE")
    box:SetAutoFocus(false);box:SetMaxLetters(8);
    if box.SetTextInsets then box:SetTextInsets(4,3,1,1) end
    box:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    box:SetBackdropColor(0.035,0.08,0.12,0.97);
    box:SetBackdropBorderColor(0.33,0.54,0.68,0.85);
    local function Commit()
        local n=tonumber(box:GetText());
        if n and n>=-10000 and n<=10000 then
            n=math.floor(n+0.5);
            local px,py=ABA.GetHudXY();
            if axis=="x" then ABA.SetHudXY(n,py) else ABA.SetHudXY(px,n) end
        else ABA.Message("Enter an X/Y number between -10000 and 10000.") end
        box:ClearFocus();ABA.Update(true);
    end
    box:SetScript("OnEnterPressed",Commit);
    box:SetScript("OnEscapePressed",function() box:ClearFocus();ABA.Update(true) end);
    box:SetScript("OnEditFocusGained",function() box.editing=true end);
    box:SetScript("OnEditFocusLost",function() box.editing=false end);
    return box;
end
local xyMinus={};local xyPlus={};
for _,axis in ipairs({"x","y"}) do
    local x=axis=="x" and 5 or 189;
    local minus=DimButton(lay,"-",x,320,31,BindClick(axis,function(a)
        local dx,dy=0,0;
        if a=="x" then dx=-10 else dy=-10 end
        ABA.NudgeHud(dx,dy);ABA.Update(true)
    end));
    local plus=DimButton(lay,"+",x+133,320,31,BindClick(axis,function(a)
        local dx,dy=0,0;
        if a=="x" then dx=10 else dy=10 end
        ABA.NudgeHud(dx,dy);ABA.Update(true)
    end));
    xyMinus[axis]=minus;xyPlus[axis]=plus;
    coordFields[axis]=CoordBox(axis,x+44);
end
local layoutToggle=DimButton(lay,"EDIT HUD ON SCREEN",5,360,359,function()
    local d=ABA.DB();d.editLayout=true;d.editMove=true;d.editResize=true;settings:Hide();RefreshHandles();ABA.Update(true)
end);
local resetPosition=DimButton(lay,"RESET POSITION",5,397,174,function() ABA.ResetPosition();ABA.Update(true) end);
local resetSize=DimButton(lay,"RESET SIZE",189,397,175,function()
    local d=ABA.DB();d.scale=1;d.hudWidth=232;d.autoWidth=true;ABA.Update(true)
end);

local skinsPane=lookGroups.skins;
Label(skinsPane,"THEMES  /  click a card to change the whole HUD",5,2,11,C.gold);
Label(skinsPane,"Use the palette on the right to override individual colours.",5,25,9,C.grey);
local skinDefs={{"SHADOW","shadow"},{"GLASS","glass"},{"CLASSIC","classic"},{"BARE","bare"},{"ARCANE","arcane"},{"EMBER","ember"},{"EMERALD","emerald"},{"FROST","frost"},{"SOLAR","solar"},{"NEON","neon"}};
local skinButtons={};
for i,skin in ipairs(skinDefs) do
    local col=math.mod(i-1,2);local row=math.floor((i-1)/2);
    local b=Button(skinsPane,skin[1],177,58,BindClick(skin[2],function(name)
        local d=ABA.DB();d.skin=name;d.accent="skin";d.manualColorsEnabled=false;ABA.Update(true)
    end));
    b:SetPoint("TOPLEFT",skinsPane,"TOPLEFT",4+col*184,-(53+row*66));
    b.txt:ClearAllPoints();b.txt:SetPoint("TOP",b,"TOP",0,-2);
    local c=skins[skin[2]] or skins.shadow;
    local pal=skinText[skin[2]] or skinText.shadow;
    b.skinTitle=skin[1];b.skinKey=skin[2];
    b.preview=b:CreateTexture(nil,"BACKGROUND");b.preview:SetTexture(WHITE);
    b.preview:SetPoint("TOPLEFT",b,"TOPLEFT",2,-20);b.preview:SetWidth(173);b.preview:SetHeight(36);
    b.preview:SetVertexColor(c[1],c[2],c[3],math.max(0.53,c[4]));
    for j,example in ipairs({{"dmg","2.4k"},{"cd","24%"},{"crit","20.6%"},{"cm","217%"}}) do
        local xpos=5+math.mod(j-1,2)*87;local ypos=j<=2 and 24 or 42;
        local icon=b:CreateTexture(nil,"ARTWORK");icon:SetTexture(MODERN..example[1]..".tga");
        icon:SetWidth(13);icon:SetHeight(13);icon:SetPoint("TOPLEFT",b,"TOPLEFT",xpos,-ypos);
        local txt=Font(b,9,pal[1]);txt:SetPoint("LEFT",icon,"RIGHT",2,0);txt:SetText(example[2]);
    end
    b:SetScript("OnEnter",function()
        b.hover=true;PaintButton(b);
        Tip(b,b.skinTitle.." theme",{"Changes the entire HUD palette: text, panel and frame.","Custom colours can be enabled separately on the right."});
    end);
    b:SetScript("OnLeave",function() HideTip();b.hover=false;PaintButton(b) end);
    skinButtons[i]={btn=b,key=skin[2]};
end

-- FRAME: independent of the selected color theme. Choose actual HUD geometry.
UIState.framePane=lookGroups.frame;
Label(UIState.framePane,"FRAME SHAPE  /  choose the silhouette",6,3,11,C.gold);
UIState.frameKinds={{"FLOAT","float"},{"SOFT","soft"},{"BOX","box"},{"ROUND","round"},{"ROUNDLESS","softround"}};
UIState.frameButtons={};
Label(UIState.framePane,"SELECT A SHAPE  /  visual silhouettes",6,30,10,C.grey);
for i,kind in ipairs(UIState.frameKinds) do
    local x=6+math.mod(i-1,3)*120; local y=56+math.floor((i-1)/3)*78;
    local b=Button(UIState.framePane,kind[1],112,70,BindClick(kind[2],function(k)
        ABA.DB().frameKind=k;ABA.Update(true)
    end));b:SetPoint("TOPLEFT",UIState.framePane,"TOPLEFT",x,-y);
    b.txt:ClearAllPoints();b.txt:SetPoint("BOTTOM",b,"BOTTOM",0,5);
    local symbol=b:CreateTexture(nil,"ARTWORK");symbol:SetTexture(MEDIA.."UI\frame_"..kind[2]..".tga");
    symbol:SetWidth(96);symbol:SetHeight(42);symbol:SetPoint("TOP",b,"TOP",0,-2);
    UIState.frameButtons[i]={btn=b,key=kind[2]};
end
Label(UIState.framePane,"Roundless: smooth background without an outline.",6,220,10,C.grey);
local padRow=StepRow(UIState.framePane,"INNER PADDING",246,"hudPadding",1,0,28,function(v) return tostring(v).." px" end);
local opacityRow=StepRow(UIState.framePane,"BACKGROUND OPACITY",307,"opacity",0.05,0.05,1,
    function(v) return tostring(math.floor(v*100+0.5)).."%" end);
local borderRow=StepRow(UIState.framePane,"BORDER WIDTH",369,"borderWidth",1,0,4,
    function(v) return tostring(v).." px" end);
Label(UIState.lookSides.frame,"VISUAL PRESETS  /  a complete look in one click",6,6,11,C.gold);
UIState.hudStyles={{"ARCANE","arcane"},{"MYTHIC","mythic"},{"NEON","minimal"}};
UIState.hudStyleButtons={};
for i,item in ipairs(UIState.hudStyles) do
    local btn=DimButton(UIState.lookSides.frame,item[1],5+(i-1)*123,44,116,BindClick(item[2],function(v)
        local d=ABA.DB();
        if v=="arcane" then
            d.skin="glass";d.accent="teal";d.frameKind="round";
            d.opacity=0.92;d.iconTheme="modern";d.iconSize=22;
            d.fontSize=13;d.gaugeHeight=4;d.gaugeColor="cyan";
            d.hudPadding=8;d.iconGap=4;d.effectMode="subtle";
        elseif v=="mythic" then
            d.skin="solar";d.accent="amber";d.frameKind="box";
            d.opacity=0.96;d.iconTheme="modern";d.iconSize=22;
            d.fontSize=13;d.gaugeHeight=4;d.gaugeColor="gold";
            d.hudPadding=8;d.iconGap=4;d.effectMode="normal";
        else
            d.skin="neon";d.accent="violet";d.frameKind="float";
            d.iconTheme="classic";d.iconSize=19;d.fontSize=13;
            d.gaugeHeight=2;d.gaugeColor="theme";d.hudPadding=2;
            d.iconGap=3;d.effectMode="subtle";
        end
        d.showMilestones=true;
        ABA.Update(true)
    end));UIState.hudStyleButtons[i]=btn;
end

UIState.textPane=lookGroups.text;
Label(UIState.textPane,"TYPE  /  icons, labels and numbers",6,5,11,C.gold);
Label(UIState.textPane,"LABEL STYLE",6,35,10,C.grey);
UIState.styleButtons={};
for i,mode in ipairs({{"ICONS","icons"},{"TEXT","text"},{"BOTH","both"}}) do
    UIState.styleButtons[i]={btn=DimButton(UIState.textPane,mode[1],5+(i-1)*123,52,116,BindClick(mode[2],function(name) ABA.DB().statStyle=name;ABA.Update(true) end)),key=mode[2]};
end
UIState.iconRow=StepRow(UIState.textPane,"ICON SIZE",98,"iconSize",2,14,32,function(v) return tostring(v).." px" end);
UIState.fontRow=StepRow(UIState.textPane,"NUMBER SIZE",160,"fontSize",1,9,18,function(v) return tostring(v).." px" end);
UIState.brightnessRow=StepRow(UIState.textPane,"ICON BRIGHTNESS",222,"iconBrightness",0.1,0.4,1,
    function(v) return tostring(math.floor(v*100+0.5)).."%" end);
UIState.iconGapRow=StepRow(UIState.textPane,"ICON-TO-NUMBER GAP",284,"iconGap",1,1,12,function(v) return tostring(v).." px" end);
UIState.yOffsetRow=StepRow(UIState.textPane,"NUMBER BASELINE",346,"valueYOffset",1,-8,8,function(v) return tostring(v).." px" end);
UIState.iconThemeBtn=DimButton(UIState.textPane,"ICON ART: MODERN",5,410,176,function()
    local d=ABA.DB();d.iconTheme=d.iconTheme=="modern" and "classic" or "modern";ABA.Update(true)
end);
UIState.fontFaceBtn=DimButton(UIState.textPane,"HUD FONT: CLEAN",188,410,176,function()
    local d=ABA.DB(); d.valueFont = (d.valueFont=="clean" and "classic") or (d.valueFont=="classic" and "fantasy") or "clean"; ABA.Update(true)
end);
Label(UIState.textPane,"Choose jewel-backed art, font family and number alignment.",6,442,9,C.grey);

UIState.fx=lookGroups.effects;
Label(UIState.fx,"ANIMATION INTENSITY",7,4,11,C.gold);
Label(UIState.fx,"SUBTLE = gentle tint + 2px pulse. NORMAL = bolder + 3px.",7,20,9,C.grey);
UIState.effectButtons={};
for i,info in ipairs({{"OFF","off"},{"SUBTLE","subtle"},{"NORMAL","normal"}}) do
    UIState.effectButtons[i]={btn=DimButton(UIState.fx,info[1],5+(i-1)*123,42,116,BindClick(info[2],function(mode) ABA.DB().effectMode=mode;ABA.Update(true) end)),key=info[2]};
end
Label(UIState.fx,"STAT GAINS",7,83,11,C.gold);
UIState.deltaBtn=DimButton(UIState.fx,"SHOW PREVIOUS + GAIN",5,100,359,function() local d=ABA.DB();d.showDelta=not d.showDelta;ABA.Update(true) end);
UIState.durationRow=StepRow(UIState.fx,"CHANGE PREVIEW DURATION",138,"deltaDuration",0.5,1,5,function(v) return string.format("%.1f sec",v) end);
UIState.pulseBtn=DimButton(UIState.fx,"HEARTBEAT PULSE",5,207,176,function() local d=ABA.DB();d.pulse=not d.pulse;ABA.Update(true) end);
UIState.glowBtn=DimButton(UIState.fx,"COLOUR FLASH",190,207,174,function() local d=ABA.DB();d.glow=not d.glow;ABA.Update(true) end);
Label(UIState.fx,"OTHER FEEDBACK",7,247,11,C.gold);
UIState.milestoneBtn=DimButton(UIState.fx,"GOLD MILESTONE",5,270,176,function() local d=ABA.DB();d.milestoneFlash=not d.milestoneFlash;ABA.Update(true) end);
UIState.spellCDBtn=DimButton(UIState.fx,"SPELL COOLDOWNS",190,270,174,function() local d=ABA.DB();d.spellCD=not d.spellCD;ABA.Update(true) end);
UIState.spellDPSBtn=DimButton(UIState.fx,"SPELL DPS LABELS",5,308,359,function() local d=ABA.DB();d.spellDPS=not d.spellDPS;ABA.Update(true) end);
Label(UIState.fx,"Example: 25% +3.4%, then 28.4%.",7,353,10,C.grey);

-- BARS: fit every control on the 392-unit panel without scrolling/clipping.
UIState.barsPane=lookGroups.bars;
Label(UIState.barsPane,"MILESTONE BARS  /  crit, haste, echo, armor, speed",6,4,10,C.gold);
UIState.gaugeBtn=DimButton(UIState.barsPane,"MILESTONE BARS: ON",5,24,359,function()
    local d=ABA.DB();d.showMilestones=not d.showMilestones;ABA.Update(true)
end);
UIState.barsReadyBtn=DimButton(UIState.barsPane,"READY SCREEN BARS: ON",5,56,359,function()
    local d=ABA.DB();d.barsReady=not d.barsReady;ABA.Update(true)
end);
local gaugeHeightRow=StepRow(UIState.barsPane,"BAR THICKNESS",91,"gaugeHeight",1,2,7,function(v) return tostring(v).." px" end);
UIState.barOptions={}
UIState.barOptions.length=StepRow(UIState.barsPane,"BAR LENGTH",148,"gaugeLength",0.05,0.30,1.20,
    function(v) return tostring(math.floor(v*100+0.5)).."% of stat width" end);
Label(UIState.barsPane,"FILL COLOUR",6,202,10,C.gold);
UIState.gaugeColors={{"SMART","adaptive"},{"THEME","theme"},{"CYAN","cyan"},{"GREEN","green"},{"GOLD","gold"}};
UIState.gaugeColorButtons={};
for i,item in ipairs(UIState.gaugeColors) do
    local btn=DimButton(UIState.barsPane,item[1],5+(i-1)*73,219,70,BindClick(item[2],function(v)
        ABA.DB().gaugeColor=v;ABA.Update(true)
    end));UIState.gaugeColorButtons[i]={btn=btn,key=item[2]};
end
UIState.barOptions.animate=DimButton(UIState.barsPane,"ANIMATE FILL",5,253,176,function()
    local d=ABA.DB();d.gaugeAnimation=not d.gaugeAnimation;ABA.Update(true)
end);
UIState.barOptions.highlight=DimButton(UIState.barsPane,"HIGHLIGHT GAIN",190,253,174,function()
    local d=ABA.DB();d.gaugeHighlight=not d.gaugeHighlight;ABA.Update(true)
end);
UIState.barOptions.transition=StepRow(UIState.barsPane,"FILL TRANSITION TIME",288,"gaugeTransition",0.15,0.15,1.5,
    function(v) return string.format("%.2f sec",v) end);
Label(UIState.barsPane,"GAIN HIGHLIGHT COLOUR  /  lasts for FX preview duration",6,341,9,C.gold);
UIState.barOptions.colors={{"GREEN","green"},{"CYAN","cyan"},{"GOLD","gold"}};
UIState.barOptions.buttons={};
for i,item in ipairs(UIState.barOptions.colors) do
    local btn=DimButton(UIState.barsPane,item[1],5+(i-1)*123,358,116,BindClick(item[2],function(v)
        ABA.DB().gaugeGainTint=v;ABA.Update(true)
    end));UIState.barOptions.buttons[i]={btn=btn,key=item[2]};
end
-- The redundant border-only accent chips have been removed.
-- Full theme cards apply a complete palette; individual colours are edited on the right.
UIState.colorButtons={};UIState.accentDefs={};

-- The second column on every LOOK page contains practical tuning, not help-only filler.
Label(UIState.lookSides.layout,"LAYOUT DENSITY",8,9,12,C.gold);
UIState.sideRowGap=StepRow(UIState.lookSides.layout,"ROW GAP",38,"rowGap",1,0,24,function(v)return tostring(v).." px" end);
UIState.sidePad=StepRow(UIState.lookSides.layout,"FRAME INNER PADDING",111,"hudPadding",1,0,28,function(v)return tostring(v).." px" end);
UIState.sideIconGap=StepRow(UIState.lookSides.layout,"ICON / VALUE GAP",184,"iconGap",1,0,20,function(v)return tostring(v).." px" end);
Label(UIState.lookSides.layout,"Drag <> in the preview to change real HUD width.",9,289,10,C.blue);
Label(UIState.lookSides.layout,"Two-column layouts need enough space for your text.",9,316,10,C.grey);
Label(UIState.lookSides.layout,"Insert full-width dividers or spacers in STATS > ORDER.",9,343,10,C.grey);
Label(UIState.lookSides.frame,"Preview tiles show the appearance and corner style.",8,110,10,C.grey);
Label(UIState.lookSides.frame,"Border width and opacity remain independently adjustable.",8,142,10,C.grey);
Label(UIState.lookSides.frame,"Choose a visual preset, then fine-tune the frame.",8,181,10,C.blue);
-- Manual RGB hex fields, independently controlling four primary layers and effects.
Label(UIState.lookSides.skins,"CUSTOM COLOURS  /  click a swatch to pick",8,9,12,C.gold);
UIState.paletteToggle=DimButton(UIState.lookSides.skins,"CUSTOM PALETTE",8,35,351,function()
    local d=ABA.DB();d.manualColorsEnabled=not d.manualColorsEnabled;ABA.Update(true)
end);
MakeCheck(UIState.paletteToggle,"Override selected theme colours");
UIState.paletteFields={};
local paletteLabels={text="MAIN TEXT",secondary="SECONDARY TEXT",background="BACKGROUND",border="BORDER",bar="PROGRESS BARS",gain="GAIN HIGHLIGHT"};
local function PaletteRow(kind,index)
    local y=78+(index-1)*54;
    Label(UIState.lookSides.skins,paletteLabels[kind].."  /  #RRGGBB",10,y,10,C.grey);
    local field=CreateFrame("EditBox",nil,UIState.lookSides.skins);field:SetWidth(171);field:SetHeight(24);
    field:SetPoint("TOPLEFT",UIState.lookSides.skins,"TOPLEFT",10,-(y+17));field:SetAutoFocus(false);field:SetMaxLetters(7);
    SetYNXFont(field,12,"OUTLINE");field:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    field:SetBackdropColor(0.03,0.09,0.14,1);field:SetBackdropBorderColor(0.23,0.46,0.59,1);
    if field.SetTextInsets then field:SetTextInsets(6,4,0,0) end
    field:SetScript("OnEscapePressed",function()field:ClearFocus();ABA.Update(true)end);
    field:SetScript("OnEditFocusGained",function()field.editing=true end);
    field:SetScript("OnEditFocusLost",function()field.editing=false end);
    local swatch=Button(UIState.lookSides.skins,"",58,26,function() end);
    swatch:SetPoint("TOPLEFT",UIState.lookSides.skins,"TOPLEFT",193,-(y+16));
    local sample=swatch:CreateTexture(nil,"ARTWORK");sample:SetTexture(WHITE);
    sample:SetPoint("TOPLEFT",swatch,"TOPLEFT",3,-3);sample:SetPoint("BOTTOMRIGHT",swatch,"BOTTOMRIGHT",-3,3);
    local function CommitHex(value)
        local r,g,b=ABA.ColorFromHex(value);
        if not r then ABA.Message("Use 6 hex digits, e.g. #45D9FF.");return end
        local d=ABA.DB();d.manualColors[kind]=string.upper(string.gsub(value,"#",""));d.manualColorsEnabled=true;
        field:ClearFocus();ABA.Update(true)
    end
    local save=DimButton(UIState.lookSides.skins,"APPLY",263,y+17,97,function() CommitHex(field:GetText()) end);
    swatch:SetScript("OnClick",function()
        local d=ABA.DB();local oldHex=d.manualColors[kind];local oldEnabled=d.manualColorsEnabled;
        ABA.OpenYNXColorWheel(oldHex,function(hex)
            d.manualColors[kind]=hex;d.manualColorsEnabled=true;
            ABA.Update(true)
        end,function()
            d.manualColors[kind]=oldHex;d.manualColorsEnabled=oldEnabled;
            ABA.Update(true)
        end)
    end);
    swatch:SetScript("OnEnter",function() Tip(swatch,"Pick "..paletteLabels[kind].." colour",{"Click to open the colour wheel.","Drag around the wheel; adjust brightness.","Cancel restores the previous colour."}) end);
    swatch:SetScript("OnLeave",HideTip);
    field:SetScript("OnEnterPressed",function() CommitHex(field:GetText()) end);
    UIState.paletteFields[kind]={field=field,swatch=sample,pick=swatch,apply=save};
end
for _,kind in ipairs({"text","secondary","background","border","bar","gain"}) do
    PaletteRow(kind,({text=1,secondary=2,background=3,border=4,bar=5,gain=6})[kind])
end
Label(UIState.lookSides.skins,"Click a coloured box for the wheel, or type HEX and APPLY.",8,434,10,C.blue);
-- Large pictorial icon-pack comparison, not a cryptic toggle.
Label(UIState.lookSides.text,"ICON COLLECTION",8,9,12,C.gold);
UIState.iconTiles={};
for i,def in ipairs({{"MODERN","modern"},{"CLASSIC","classic"}}) do
    local b=Button(UIState.lookSides.text,def[1],165,105,BindClick(def[2],function(v)
        ABA.DB().iconTheme=v;ABA.Update(true)
    end));b:SetPoint("TOPLEFT",UIState.lookSides.text,"TOPLEFT",8+(i-1)*179,-42);
    b.txt:ClearAllPoints();b.txt:SetPoint("BOTTOM",b,"BOTTOM",0,9);
    for j,icon in ipairs({"dmg","cd","crit"}) do
        local t=b:CreateTexture(nil,"ARTWORK");t:SetTexture((def[2]=="modern" and MODERN or MEDIA)..icon..".tga");
        t:SetWidth(37);t:SetHeight(37);t:SetPoint("TOPLEFT",b,"TOPLEFT",8+(j-1)*51,-15)
    end
    UIState.iconTiles[i]={btn=b,key=def[2]};
end
Label(UIState.lookSides.text,"Number typography and icon size are set on the left.",8,183,11,C.grey);
Label(UIState.lookSides.text,"The classic pack is retained for older profiles.",8,212,11,C.grey);
-- Marker controls are explicitly bound per key.  No loop-variable captures:
-- the WoW 1.12 Lua client has different closure semantics from newer Lua.
-- Only expose marker types for which YNX actually has real data.
Label(UIState.lookSides.bars,"CAP & GOAL MARKERS",8,9,12,C.gold);
UIState.barFlags={};
function UIState.MarkerToggle(label,key,y)
    local button;
    button=DimButton(UIState.lookSides.bars,label,8,y,351,function()
        local d=ABA.DB();
        d[key]=not (d[key]==true);
        TogglePaint(button,d[key]); -- immediate visible confirmation
        if ABA.Update then ABA.Update(true) end
    end);
    -- The game can draw overlays above the Settings page; ensure the actual
    -- buttons retain mouse input and explicit left-button click registration.
    button:EnableMouse(true);
    if button.RegisterForClicks then button:RegisterForClicks("LeftButtonUp") end
    if button.SetFrameLevel then button:SetFrameLevel(UIState.lookSides.bars:GetFrameLevel()+4) end
    MakeCheck(button,label);
    table.insert(UIState.barFlags,{btn=button,key=key});
    return button;
end
UIState.MarkerToggle("Build goals  /  Haste 60% and 75%","showGoalMarkers",39);
UIState.MarkerToggle("Conversion  /  Crit and Echo 100%","showConversionMarkers",81);
UIState.MarkerToggle("Hard caps  /  Armor and Speed","showHardCapMarkers",123);
Label(UIState.lookSides.bars,"Soft caps: none verified; no fabricated markers.",12,169,10,C.grey);
UIState.markerStatus=Label(UIState.lookSides.bars,"",12,191,10,C.gold);
Label(UIState.lookSides.bars,"BAR WIDTH PRESETS",8,216,11,C.gold);
UIState.barWidthPresets={};
for i,def in ipairs({{"SHORT",0.55},{"DEFAULT",0.72},{"LONG",1}}) do
    local b=DimButton(UIState.lookSides.bars,def[1],8+(i-1)*119,241,113,BindClick(def[2],function(v)
        ABA.DB().gaugeLength=v;ABA.Update(true)
    end));UIState.barWidthPresets[i]={btn=b,length=def[2]};
end
UIState.barOffsetX=StepRow(UIState.lookSides.bars,"BAR HORIZONTAL OFFSET",286,"gaugeOffsetX",2,-40,40,function(v)return tostring(v).." px" end);
UIState.barOffsetY=StepRow(UIState.lookSides.bars,"BAR VERTICAL OFFSET",351,"gaugeOffsetY",1,-16,16,function(v)return tostring(v).." px" end);
Label(UIState.lookSides.bars,"Changes appear immediately on HUD and preview.",8,441,10,C.blue);
-- FX second panel: purposeful preset selection and animation explanation.
Label(UIState.lookSides.effects,"ANIMATION PRESETS",8,9,12,C.gold);
UIState.fxPresets={};
for i,info in ipairs({{"CALM","subtle",false},{"BALANCED","normal",true},{"SHOWCASE","normal",true}}) do
    local b=DimButton(UIState.lookSides.effects,info[1],8+(i-1)*119,45,112,BindClick(i,function(which)
        local d=ABA.DB();local mode=({"subtle","normal","normal"})[which];
        d.effectMode=mode;d.pulse=which~=1;d.glow=which~=1;d.deltaDuration=which==3 and 3.5 or 2.5;
        ABA.Update(true)
    end));UIState.fxPresets[i]=b;
end
Label(UIState.lookSides.effects,"CALM      Small fades, reduced motion",8,116,11,C.grey);
Label(UIState.lookSides.effects,"BALANCED  Clear feedback without distraction",8,143,11,C.grey);
Label(UIState.lookSides.effects,"SHOWCASE  Longer glow and stronger pulse",8,170,11,C.grey);
Label(UIState.lookSides.effects,"Use PLAY GAIN on the right to compare.",8,239,11,C.blue);
Label(UIState.lookSides.effects,"The demo runs through the same animation code as the HUD.",8,267,10,C.grey);
-- Compact checkbox controls use a consistent small checked square.  The
-- captions never change their length on toggle, so the menu doesn't jump.
MakeCheck(autoWidth,"Auto width");
MakeCheck(showSpells,"Show tracked spells on HUD");
MakeCheck(UIState.deltaBtn,"Floating gain preview");
MakeCheck(UIState.pulseBtn,"Icon and number pulse");
MakeCheck(UIState.glowBtn,"Colour flash");
MakeCheck(UIState.milestoneBtn,"Milestone celebration");
MakeCheck(UIState.spellCDBtn,"Cooldown labels");
MakeCheck(UIState.spellDPSBtn,"Spell DPS labels");
MakeCheck(UIState.gaugeBtn,"Milestone bars");
MakeCheck(UIState.barsReadyBtn,"Show milestone bars on ready screen");
MakeCheck(UIState.barOptions.animate,"Animate progress fill");
MakeCheck(UIState.barOptions.highlight,"Highlight gained progress");

-- Preview now renders from the same selected-stat model as the real HUD,
-- so layout, gaps, bars and order are much closer to what the player will see.
UIState.preview={};
UIState.preview.card=CreateFrame("Frame",nil,lookPane);
UIState.preview.card:SetPoint("TOPLEFT",lookPane,"TOPLEFT",771,-54);
UIState.preview.card:SetWidth(377);UIState.preview.card:SetHeight(478);
UIState.preview.card:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
UIState.preview.card:SetBackdropColor(0.02,0.065,0.10,0.97);
UIState.preview.card:SetBackdropBorderColor(0.25,0.55,0.75,0.91);
Label(UIState.preview.card,"LIVE HUD PREVIEW",14,13,13,C.gold);
Label(UIState.preview.card,"Uses your current tracked stats and active layout.",14,37,10,C.grey);
UIState.preview.stage=CreateFrame("Frame",nil,UIState.preview.card);
UIState.preview.stage:SetPoint("TOPLEFT",UIState.preview.card,"TOPLEFT",14,-62);
UIState.preview.stage:SetWidth(348);UIState.preview.stage:SetHeight(243);
UIState.preview.stage:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
UIState.preview.stage:SetBackdropColor(0.10,0.20,0.10,0.55);
UIState.preview.stage:SetBackdropBorderColor(0.16,0.24,0.14,0.55);
UIState.preview.stage.grass=UIState.preview.stage:CreateTexture(nil,"BACKGROUND");
UIState.preview.stage.grass:SetTexture(MEDIA.."UI\\grass.tga");
UIState.preview.stage.grass:SetAllPoints(UIState.preview.stage);
UIState.preview.stage.grass:SetVertexColor(0.75,0.87,0.76,0.88);
UIState.preview.hud=CreateFrame("Frame",nil,UIState.preview.stage);
UIState.preview.hud:SetPoint("TOPLEFT",UIState.preview.stage,"TOPLEFT",8,-8);
UIState.preview.hud:SetWidth(332);UIState.preview.hud:SetHeight(225);
UIState.preview.hud:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=2});
UIState.preview.hud:SetBackdropColor(0,0,0,0);UIState.preview.hud:SetBackdropBorderColor(0,0,0,0);
UIState.preview.round={background={},stroke={}};
local function PreviewTex(layer,file)
    local t=UIState.preview.hud:CreateTexture(nil,layer);t:SetTexture(file or WHITE);t:Hide();return t
end
local function BuildPreviewRound()
    local pr=UIState.preview;local t=pr.round.background;local f=pr.hud;local r=16;
    t.middle=PreviewTex("BACKGROUND");t.middle:SetPoint("TOPLEFT",f,"TOPLEFT",r,0); t.middle:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-r,0);
    t.left=PreviewTex("BACKGROUND");t.left:SetWidth(r); t.left:SetPoint("TOPLEFT",f,"TOPLEFT",0,-r);t.left:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,r);
    t.right=PreviewTex("BACKGROUND");t.right:SetWidth(r); t.right:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,-r);t.right:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,r);
    for _,key in ipairs({"tl","tr","bl","br"}) do local c=PreviewTex("BACKGROUND",MEDIA.."round_bg_"..key..".tga"); c:SetWidth(r);c:SetHeight(r); c:SetPoint((key=="tl" and "TOPLEFT") or (key=="tr" and "TOPRIGHT") or (key=="bl" and "BOTTOMLEFT") or "BOTTOMRIGHT",f,(key=="tl" and "TOPLEFT") or (key=="tr" and "TOPRIGHT") or (key=="bl" and "BOTTOMLEFT") or "BOTTOMRIGHT"); t[key]=c; end
    local out=pr.round.stroke;
    for _,key in ipairs({"tl","tr","bl","br"}) do local c=PreviewTex("ARTWORK",MEDIA.."round_stroke_1_"..key..".tga"); c:SetWidth(r);c:SetHeight(r); c:SetPoint((key=="tl" and "TOPLEFT") or (key=="tr" and "TOPRIGHT") or (key=="bl" and "BOTTOMLEFT") or "BOTTOMRIGHT",f,(key=="tl" and "TOPLEFT") or (key=="tr" and "TOPRIGHT") or (key=="bl" and "BOTTOMLEFT") or "BOTTOMRIGHT"); out[key]=c; end
    out.top=PreviewTex("ARTWORK");out.top:SetPoint("TOPLEFT",f,"TOPLEFT",r,-1);out.top:SetPoint("TOPRIGHT",f,"TOPRIGHT",-r,-1);
    out.bottom=PreviewTex("ARTWORK");out.bottom:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",r,1);out.bottom:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-r,1);
    out.left=PreviewTex("ARTWORK");out.left:SetPoint("TOPLEFT",f,"TOPLEFT",1,-r);out.left:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",1,r);
    out.right=PreviewTex("ARTWORK");out.right:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,-r);out.right:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,r);
end
BuildPreviewRound();
BuildGhostRows(UIState.preview.hud,29);
-- This handle edits the real HUD width (SavedVariables), not a mock-up width.
-- Dragging or using +/- switches off Auto Width, exactly like resizing in-game.
UIState.preview.resize=Button(UIState.preview.stage,"<>",23,23,function() end);
UIState.preview.resize:SetFrameLevel(UIState.preview.hud:GetFrameLevel()+10);
UIState.preview.resize:RegisterForDrag("LeftButton");
UIState.preview.widthLabel=Label(UIState.preview.card,"HUD WIDTH",112,314,11,C.gold);
UIState.preview.widthLabel:SetWidth(163);
UIState.preview.widthLabel:SetJustifyH("CENTER");
UIState.preview.widthLess=Button(UIState.preview.card,"-",77,25,function()
    local d=ABA.DB();local base=d.autoWidth and UIState.preview.hud:GetWidth() or d.hudWidth;
    d.autoWidth=false;d.hudWidth=clamp(math.floor((base or 232)-20+0.5),90,1000);ABA.Update(true)
end);
UIState.preview.widthLess:SetPoint("TOPLEFT",UIState.preview.card,"TOPLEFT",14,-308);
UIState.preview.widthMore=Button(UIState.preview.card,"+",77,25,function()
    local d=ABA.DB();local base=d.autoWidth and UIState.preview.hud:GetWidth() or d.hudWidth;
    d.autoWidth=false;d.hudWidth=clamp(math.floor((base or 232)+20+0.5),90,1000);ABA.Update(true)
end);
UIState.preview.widthMore:SetPoint("TOPRIGHT",UIState.preview.card,"TOPRIGHT",-14,-308);
UIState.preview.test=Button(UIState.preview.card,"PLAY HUD GAIN ANIMATION",348,30,function()
    local pr=UIState.preview;local candidate=nil;
    -- Prefer a tracked statistic with a real milestone bar, when available.
    for i=1,table.getn(pr.hud.rows) do
        local row=pr.hud.rows[i];
        if row.stat and row:IsShown() and ABA.GetMilestone(row.stat.key) then candidate=row;break end
    end
    if not candidate then
        for i=1,table.getn(pr.hud.rows) do
            local row=pr.hud.rows[i];if row.stat and row:IsShown() then candidate=row;break end
        end
    end
    if not candidate then return end
    local stat=candidate.stat;local d=ABA.DB();
    local current=type(AZS_STATS)=="table" and AZS_STATS[stat.key] or nil;
    if type(current)~="number" then current=1 end
    local shift=0.03;
    if stat.kind=="int" then shift=1 elseif stat.kind=="rate" then shift=0.3 end
    if stat.kind=="cooldown" then shift=-0.03 end
    pr.sample={key=stat.key,before=current,after=current+shift,at=GetTime()};
    if UIState.RefreshPreview then UIState.RefreshPreview(d) end
end);
UIState.preview.test:SetPoint("TOPLEFT",UIState.preview.card,"TOPLEFT",14,-345);
Label(UIState.preview.card,"Drag the <> handle to resize the real HUD.",14,389,10,C.grey);
Label(UIState.preview.card,"Preview is scaled to fit; width stays synchronized.",14,411,10,C.grey);
Label(UIState.preview.card,"Gain demo uses the real HUD animation renderer.",14,437,10,C.gold);
local previewResizeDrag=nil;
local function PreviewResizeTick()
    if not previewResizeDrag then return end
    local px=Cursor();if not px then return end
    local pr=UIState.preview;local d=ABA.DB();
    local effective=pr.hud.GetEffectiveScale and pr.hud:GetEffectiveScale() or (ParentScale()*pr.hud:GetScale());
    if type(effective)~="number" or effective<0.01 then effective=1 end
    local width=clamp(math.floor(previewResizeDrag.width+(px-previewResizeDrag.x)/effective+0.5),90,1000);
    if width~=d.hudWidth or d.autoWidth then
        d.autoWidth=false;d.hudWidth=width;
        ABA.Update(true)
    end
end
local function PreviewResizeStart()
    local x=Cursor();if not x then return end
    previewResizeDrag={x=x,width=UIState.preview.hud:GetWidth()};HideTip()
end
local function PreviewResizeStop()
    if not previewResizeDrag then return end
    PreviewResizeTick();previewResizeDrag=nil
end
UIState.preview.resize:SetScript("OnMouseDown",function() if arg1=="LeftButton" then PreviewResizeStart() end end);
UIState.preview.resize:SetScript("OnDragStart",PreviewResizeStart);
UIState.preview.resize:SetScript("OnDragStop",PreviewResizeStop);
UIState.preview.resize:SetScript("OnMouseUp",function() if arg1=="LeftButton" then PreviewResizeStop() end end);
UIState.preview.resize:SetScript("OnHide",function() previewResizeDrag=nil end);
UIState.preview.resize:SetScript("OnEnter",function()
    Tip(UIState.preview.resize,"Resize HUD width",{"Drag left or right to resize the real HUD.","Switches Auto Width off; use LOOK > Overview to restore it."})
end);
UIState.preview.resize:SetScript("OnLeave",HideTip);
UIState.preview.stage:SetScript("OnUpdate",function() if previewResizeDrag then PreviewResizeTick() end end);
local function PaintPreviewFrame(pr,d)
    -- The live HUD and preview MUST use the same colour and alpha equations.
    local c,accent=ResolvedFrameColors(d);
    local opacity=clamp(d.opacity,0.05,1);
    local bgAlpha=c[4]*opacity;
    local borderAlpha=c[8]*opacity;
    if d.frameKind=="box" then
        pr.hud:SetBackdropColor(c[1],c[2],c[3],bgAlpha);
        pr.hud:SetBackdropBorderColor(accent[1],accent[2],accent[3],d.borderWidth>0 and borderAlpha or 0);
    elseif d.frameKind=="soft" then
        pr.hud:SetBackdropColor(c[1],c[2],c[3],bgAlpha);
        pr.hud:SetBackdropBorderColor(0,0,0,0);
    else
        pr.hud:SetBackdropColor(0,0,0,0);pr.hud:SetBackdropBorderColor(0,0,0,0);
    end
    local rounded=(d.frameKind=="round" or d.frameKind=="softround");
    for _,piece in pairs(pr.round.background) do
        if rounded then piece:Show();piece:SetVertexColor(c[1],c[2],c[3],bgAlpha)
        else piece:Hide() end
    end
    for key,piece in pairs(pr.round.stroke) do
        if d.frameKind=="round" and d.borderWidth>0 then
            if key=="tl" or key=="tr" or key=="bl" or key=="br" then
                piece:SetTexture(MEDIA.."round_stroke_"..d.borderWidth.."_"..key..".tga")
            elseif key=="left" or key=="right" then piece:SetWidth(d.borderWidth)
            else piece:SetHeight(d.borderWidth) end
            piece:Show();piece:SetVertexColor(accent[1],accent[2],accent[3],borderAlpha)
        else piece:Hide() end
    end
end
function UIState.RefreshPreview(d)
    local pr=UIState.preview; PaintPreviewFrame(pr,d);
    local stats=CurrentStats(); if table.getn(stats)==0 then stats={{key="dmg",icon="dmg",short="DMG"},{key="cd",icon="cd",short="HASTE"},{key="crit",icon="crit",short="CRIT"},{key="cm",icon="cm",short="CRIT DMG"},{key="luck",icon="luck",short="LUCK"},{key="echo",icon="echo",short="ECHO"}} end
    local usable={}; for i=1,table.getn(stats) do usable[i]=stats[i] end
    local w,h=PopulateGhostHUD(pr.hud,usable,332,0);
    local naturalH=math.max(58,h+d.hudPadding*2+2);
    -- The viewport only scales the *whole* HUD, never changes its columns.
    local fit=math.min(d.scale or 1,332/math.max(1,w),225/naturalH);
    pr.hud:SetScale(math.max(0.12,fit));
    pr.hud:ClearAllPoints();pr.hud:SetPoint("TOPLEFT",pr.stage,"TOPLEFT",8,-8);
    pr.hud:SetWidth(w);pr.hud:SetHeight(naturalH);
    pr.resize:ClearAllPoints();pr.resize:SetPoint("RIGHT",pr.hud,"RIGHT",7,0);
    pr.widthLabel:SetText("HUD WIDTH: "..tostring(math.floor(w+0.5)).." px"..(d.autoWidth and " (AUTO)" or ""));
    -- A Settings refresh can rebuild the preview while a sample is running.
    -- Restore the synthetic bar change so the same renderer keeps its timing.
    if pr.sample and GetTime()-pr.sample.at<(d.deltaDuration or 2) then
        for i=1,table.getn(pr.hud.rows) do
            local row=pr.hud.rows[i];
            if row.stat and row.stat.key==pr.sample.key then
                local old=ABA.GetMilestone(row.stat.key,{[row.stat.key]=pr.sample.before});
                local now=ABA.GetMilestone(row.stat.key,{[row.stat.key]=pr.sample.after});
                if old and now and row.gaugeLength then
                    row.gaugeStart=old.progress;row.gaugeShown=old.progress;
                    row.gaugeTarget=now.progress;row.gaugeTargetPrevious=now.progress;
                    row.gaugeAt=pr.sample.at;row.gainUntil=pr.sample.at+d.deltaDuration;
                end
                break
            end
        end
    end
end
-- No independent preview animation code.  Both HUDs call UIState.AnimateRow.
UIState.preview.hud:SetScript("OnUpdate",function()
    local pr=UIState.preview;local sample=pr.sample;if not sample then return end
    local d=ABA.DB();
    if GetTime()-sample.at > d.deltaDuration then
        pr.sample=nil;
        if UIState.RefreshPreview then UIState.RefreshPreview(d) end
        return
    end
    for i=1,table.getn(pr.hud.rows) do
        local row=pr.hud.rows[i];
        if row.stat and row.stat.key==sample.key and row:IsShown() and UIState.AnimateRow then
            UIState.AnimateRow(row,0,sample)
            break
        end
    end
end);

-- INSIGHTS: read-only game API summaries and historical comparisons.
local insightPane=pages.INSIGHTS;local insightPage="run";local insightTabs={};
for i,info in ipairs({{"RUN","run"},{"SPELLS","spells"},{"TRENDS","trends"},{"NOTES","notes"}}) do
    insightTabs[i]={btn=Subpage(insightPane,info[1],2+(i-1)*93,89,BindClick(info[2],function(page) insightPage=page;ABA.Update(true) end)),key=info[2]};
end
local insightLines={};
for i=1,14 do
    local txt=Label(insightPane,"",5,38+(i-1)*26,11,i==1 and C.gold or C.white);
    txt:SetWidth(360);insightLines[i]=txt;
end

-- Supplemental reference panels fill the expanded window on the original
-- STATS, SPELLS and INSIGHTS tabs while keeping their working controls intact.
UIState.helpCards={};
for _,group in ipairs({"STATS","SPELLS","INSIGHTS"}) do
    local card=CreateFrame("Frame",nil,pages[group]);
    card:SetPoint("TOPLEFT",pages[group],"TOPLEFT",395,-24);
    card:SetWidth(742);card:SetHeight(488);
    card:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    card:SetBackdropColor(0.024,0.071,0.105,0.95);
    card:SetBackdropBorderColor(0.22,0.49,0.64,0.9);
    local headline=(group=="STATS" and "BUILD OVERVIEW") or (group=="SPELLS" and "ABILITY & PROC TRACKING") or "RUN INTELLIGENCE";
    Label(card,headline,19,17,15,C.gold);
    local sub=(group=="STATS" and "Choose stats on the left. Organize their order in ORDER.") or
        (group=="SPELLS" and "Choose learned abilities and actual recorded damage procs.") or
        "Review current-run details and previously stored summaries.";
    Label(card,sub,19,46,12,C.grey);
    card.counter=Label(card,"",19,93,13,C.blue);
    UIState.helpCards[group]=card;
end
for _,group in ipairs({"STATS","SPELLS"}) do
    local card=UIState.helpCards[group];
    card.previewStage=CreateFrame("Frame",nil,card);
    card.previewStage:SetPoint("TOPLEFT",card,"TOPLEFT",19,-132);
    card.previewStage:SetWidth(660);card.previewStage:SetHeight(292);
    card.previewStage:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    card.previewStage:SetBackdropColor(0.10,0.20,0.10,0.55);
    card.previewStage:SetBackdropBorderColor(0.16,0.24,0.14,0.55);
    card.previewStage.grass=card.previewStage:CreateTexture(nil,"BACKGROUND");
    card.previewStage.grass:SetTexture(MEDIA.."UI\\grass.tga");
    card.previewStage.grass:SetAllPoints(card.previewStage);
    card.previewStage.grass:SetVertexColor(0.75,0.87,0.76,0.88);
    card.previewHUD=CreateFrame("Frame",nil,card.previewStage);
    card.previewHUD:SetPoint("TOPLEFT",card.previewStage,"TOPLEFT",9,-9);
    card.previewHUD:SetWidth(640);card.previewHUD:SetHeight(270);
    card.previewHUD:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=2});
    card.previewHUD:SetBackdropColor(0.035,0.09,0.13,0.93);
    card.previewHUD:SetBackdropBorderColor(0.23,0.65,0.85,0.7);
    BuildGhostRows(card.previewHUD,29);
end
-- ORDER can tune the actual divider/spacer elements while watching the HUD.
UIState.orderOptions=CreateFrame("Frame",nil,UIState.helpCards.STATS);
UIState.orderOptions:SetPoint("TOPLEFT",UIState.helpCards.STATS,"TOPLEFT",357,-135);
UIState.orderOptions:SetWidth(374);UIState.orderOptions:SetHeight(327);
UIState.orderOptions:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
UIState.orderOptions:SetBackdropColor(0.025,0.075,0.12,0.98);
UIState.orderOptions:SetBackdropBorderColor(0.26,0.63,0.75,0.9);
Label(UIState.orderOptions,"ELEMENT APPEARANCE",9,7,12,C.gold);
UIState.elementRows={
    StepRow(UIState.orderOptions,"LINE THICKNESS",34,"separatorThickness",1,1,6,function(v)return tostring(v).." px" end),
    StepRow(UIState.orderOptions,"LINE LENGTH",93,"separatorLength",0.1,0.2,1,function(v)return tostring(math.floor(v*100+0.5)).."%" end),
    StepRow(UIState.orderOptions,"SPACE BEFORE LINE",152,"separatorBefore",2,0,24,function(v)return tostring(v).." px" end),
    StepRow(UIState.orderOptions,"SPACE AFTER LINE",211,"separatorAfter",2,0,24,function(v)return tostring(v).." px" end),
    StepRow(UIState.orderOptions,"SPACER HEIGHT",270,"spacerHeight",2,2,80,function(v)return tostring(v).." px" end)
};
UIState.orderOptions:Hide();
Label(UIState.helpCards.STATS,"Selected-stat preview",19,436,12,C.blue);
Label(UIState.helpCards.STATS,"The preview uses your real order, spacing, bars and selected icons.",19,458,11,C.grey);
Label(UIState.helpCards.SPELLS,"Spell choices affect the compact spell HUD below the main stat block.",19,436,11,C.grey);
Label(UIState.helpCards.SPELLS,"Proc icons prefer the game's spell and talent artwork.",19,458,12,C.blue);
UIState.helpCards.INSIGHTS.previewStage=CreateFrame("Frame",nil,UIState.helpCards.INSIGHTS);
UIState.helpCards.INSIGHTS.previewStage:SetPoint("TOPLEFT",UIState.helpCards.INSIGHTS,"TOPLEFT",19,-120);
UIState.helpCards.INSIGHTS.previewStage:SetWidth(660);UIState.helpCards.INSIGHTS.previewStage:SetHeight(212);
UIState.helpCards.INSIGHTS.previewStage:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
UIState.helpCards.INSIGHTS.previewStage:SetBackdropColor(0.10,0.20,0.10,0.55);
UIState.helpCards.INSIGHTS.previewStage:SetBackdropBorderColor(0.16,0.24,0.14,0.55);
UIState.helpCards.INSIGHTS.previewStage.grass=UIState.helpCards.INSIGHTS.previewStage:CreateTexture(nil,"BACKGROUND");
UIState.helpCards.INSIGHTS.previewStage.grass:SetTexture(MEDIA.."UI\\grass.tga");
UIState.helpCards.INSIGHTS.previewStage.grass:SetAllPoints(UIState.helpCards.INSIGHTS.previewStage);
UIState.helpCards.INSIGHTS.previewStage.grass:SetVertexColor(0.75,0.87,0.76,0.88);
UIState.helpCards.INSIGHTS.previewHUD=CreateFrame("Frame",nil,UIState.helpCards.INSIGHTS.previewStage);
UIState.helpCards.INSIGHTS.previewHUD:SetPoint("TOPLEFT",UIState.helpCards.INSIGHTS.previewStage,"TOPLEFT",9,-9);
UIState.helpCards.INSIGHTS.previewHUD:SetWidth(640);UIState.helpCards.INSIGHTS.previewHUD:SetHeight(194);
UIState.helpCards.INSIGHTS.previewHUD:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=2});
BuildGhostRows(UIState.helpCards.INSIGHTS.previewHUD,29);
Label(UIState.helpCards.INSIGHTS,"INSIGHTS  /  measured from the game",19,342,14,C.gold);
Label(UIState.helpCards.INSIGHTS,"RUN: current totals    SPELLS: damage    TRENDS: stat changes",19,376,12,C.white);
Label(UIState.helpCards.INSIGHTS,"The game's damage meter remains the authoritative source.",19,405,11,C.blue);





function UIState.RefreshSideCards(d)
    local total=0;
    for i=1,table.getn(ABA.stats) do if ABA.IsEnabled(ABA.stats[i]) then total=total+1 end end
    UIState.helpCards.STATS.counter:SetText(tostring(total).." of 29 statistics selected");
    UIState.helpCards.SPELLS.counter:SetText("Current class: "..tostring(ABA.ClassKey()));
    UIState.helpCards.INSIGHTS.counter:SetText("Explore the left-side categories to read live data.");
    local stats=CurrentStats();
    local c=skins[d.skin] or skins.shadow;
    if statPage=="order" and currentTab=="STATS" then
        UIState.orderOptions:Show();UIState.helpCards.STATS.previewStage:SetWidth(330);
        for _,row in ipairs(UIState.elementRows) do row.value:SetText(row.format(d[row.key])) end
    else UIState.orderOptions:Hide();UIState.helpCards.STATS.previewStage:SetWidth(660) end
    for _,key in ipairs({"STATS","SPELLS","INSIGHTS"}) do
        local p=UIState.helpCards[key].previewHUD;
        local bg=ABA.ManualColor("background") or c;local br=ABA.ManualColor("border") or {c[5],c[6],c[7]};
        p:SetBackdropColor(bg[1],bg[2],bg[3],d.frameKind=="float" and 0 or (c[4]*d.opacity));
        p:SetBackdropBorderColor(br[1],br[2],br[3],d.frameKind=="box" and 0.7 or 0);
        local w,h=PopulateGhostHUD(p,stats,640,0);
        local totalH=math.max(30,h+d.hudPadding*2+2);
        p:SetScale(math.max(0.20,math.min(d.scale or 1,((key=="STATS" and statPage=="order") and 310 or 640)/math.max(1,w),(key=="INSIGHTS" and 194 or 270)/totalH)));
    end
end

function ABA.ToggleSettings()
    ABA.StopInteraction();
    if settings:IsShown() then settings:Hide()
    else DockSettings();settings:Show();Top(settings);SelectTab(currentTab);if ABA.UpdateSettings then ABA.UpdateSettings() end end
end
-- Split Settings updates across small closures. Lua 5.0 allows at most
-- 32 captured upvalues per function; a monolithic refresh exceeded that limit.
local function RefreshStatControls(d)
    statPage=d.statPage or statPage;
    for i,key in ipairs({"core","advanced","order","presets"}) do
        if key==statPage then statGroups[key]:Show() else statGroups[key]:Hide() end
        Selected(statTabButtons[i],key==statPage);
    end
    local ordered=SortedSpecs();local counts={core=0,advanced=0};
    for i=1,table.getn(ordered) do
        local spec=ordered[i];local tier=spec.tier;
        counts[tier]=counts[tier]+1;
        local idx=counts[tier];local col=math.mod(idx-1,2);local line=math.floor((idx-1)/2);
        local b=statSelectByKey[spec.key];
        if b then
            b:ClearAllPoints();
            b:SetPoint("TOPLEFT",statGroups[tier],"TOPLEFT",col*184,-(line*29+2));
        end
    end
    for i=1,table.getn(statSelect) do
        local item=statSelect[i];local on=ABA.IsEnabled(item.spec);
        item.btn.label:SetText(item.spec.name);TogglePaint(item.btn,on);
        item.btn.state:SetText(on and "X" or "");
        item.btn.state:SetTextColor(on and 0.47 or 0.52,on and 0.95 or 0.63,on and 0.69 or 0.70);
        item.btn.label:SetTextColor(on and 0.57 or 0.53,on and 0.97 or 0.62,on and 0.66 or 0.66);
    end
    for i=1,table.getn(presetButtons) do Selected(presetButtons[i].btn,d.activePreset==presetButtons[i].key) end
    local chosen={};for i=1,table.getn(ordered) do
        if ABA.IsEnabled(ordered[i]) then table.insert(chosen,ordered[i]) end
    end
    local items=ABA.SequenceForStats(chosen);
    local maxPage=math.max(1,math.ceil(table.getn(items)/8));
    orderIndex=math.min(orderIndex,maxPage);
    orderPageLabel:SetText("Page "..orderIndex.." / "..maxPage);
    for i=1,8 do
        local r=orderRows[i];local item=items[(orderIndex-1)*8+i];
        r.spec=item and item.stat or nil;r.extra=item and item.kind~="stat" and item or nil;
        if item then
            if item.stat then
                r.title:SetText(tostring((orderIndex-1)*8+i)..". "..item.stat.name);
                r.title:SetTextColor(currentText[1],currentText[2],currentText[3]);
                r.icon:SetTexture(MODERN..item.stat.icon..".tga");
                r.up:Show();r.down:Show();r.add.txt:SetText("+");
            else
                r.title:SetText("   "..(item.kind=="separator" and "ROW DIVIDER" or (item.kind=="columnSeparator" and "COLUMN DIVIDER" or "SPACER")));
                r.title:SetTextColor(0.54,0.91,0.95);
                r.icon:SetTexture(MODERN..(item.kind=="separator" and "area" or (item.kind=="columnSeparator" and "cnt" or "pick"))..".tga");
                r.up:Hide();r.down:Hide();r.add.txt:SetText("X");
            end
            r:Show()
        else r:Hide() end
    end
    for i=1,3 do
        local item=type(d.customProfiles[i])=="table" and d.customProfiles[i] or nil;
        local entry=slotButtons[i];
        if not entry.edit.HasFocus or not entry.edit:HasFocus() then
            local text=item and type(item.name)=="string" and item.name or "";
            entry.edit:SetText(text);
        end
        entry.status:SetText(item and ((d.activeProfileSlot==i and "ACTIVE: " or "SAVED: ")..tostring(item.name or "Profile "..i)) or "EMPTY SLOT  - enter a name and save");
        entry.load:SetAlpha(item and 1 or 0.35);
    end
end
local function RefreshSpellControls(d)
    TogglePaint(showSpells,d.spellVisible);
    showSpells.txt:SetText("Show tracked spells on HUD");
    local src=type(AZS_SPELLS)=="table" and AZS_SPELLS or {};local pr=ABA.SpellProfile();
    for i=1,12 do
        local b=spellSelect[i];local sp=src[i];
        if type(sp)=="table" and sp.key then
            b.spell=sp;b.icon:SetTexture(ABA.SpellIcon(sp));
            local name=ABA.SpellName(sp);if string.len(name)>18 then name=string.sub(name,1,17).."." end
            TogglePaint(b,pr[sp.key]);b.text:SetText((pr[sp.key] and "+ " or "- ")..name);
            b.text:SetTextColor(pr[sp.key] and 0.44 or 0.75,pr[sp.key] and 0.95 or 0.79,pr[sp.key] and 0.56 or 0.83);
            b:Show();
        else b.spell=nil;b:Hide() end
    end
end
local function RefreshProcControls(d)
    for i=1,table.getn(spellPageButtons) do
        local item=spellPageButtons[i];Selected(item.btn,spellPage==item.key);
        if item.key==spellPage then spellPages[item.key]:Show() else spellPages[item.key]:Hide() end
    end
    local rows=ABA.ProcRows();local pagesN=math.max(1,math.ceil(table.getn(rows)/12));
    procPage=math.max(1,math.min(procPage,pagesN));
    local active=ABA.ProcProfile();
    for i=1,12 do
        local b=procSelect[i];local r=rows[(procPage-1)*12+i];
        if r then
            b.procRow=r;b.procName=r.name;b.ico:SetTexture(ABA.ProcIcon(r));
            local title=r.name;if string.len(title)>19 then title=string.sub(title,1,18).."." end
            TogglePaint(b,active[r.name]);b.main:SetText((active[r.name] and "+ " or "- ")..title);
            b.main:SetTextColor(active[r.name] and 0.45 or 0.80,active[r.name] and 0.95 or 0.83,active[r.name] and 0.55 or 0.84);
            b.sub:SetText(string.format("%.1f DPS  /  %.0f dmg",r.dps or 0,r.dmg or 0));
            b:Show()
        else b.procRow=nil;b.procName=nil;b:Hide() end
    end
    if table.getn(rows)==0 then
        procPageLabel:SetText("No damage procs detected yet. Start a run and deal damage.")
    else procPageLabel:SetText(tostring(table.getn(rows)).." proc sources observed  |  page "..procPage.." / "..pagesN) end
end
-- Contextual help.  Shared control helper for simple toggles and steppers.
local function Help(b,title,lines)
    if not b then return end
    b:SetScript("OnEnter",function() Tip(b,title,lines) end);
    b:SetScript("OnLeave",HideTip);
end
Help(layoutToggle,"Edit layout",{"Enables MOVE and RESIZE handles together.","Turn off after positioning to keep HUD clean."});
for _,axis in ipairs({"x","y"}) do
    Help(xyMinus[axis],"Position "..string.upper(axis),{"Moves 10 UI units toward the negative direction.","No invisible screen-edge clamp. RESET POSITION recovers an off-screen HUD."});
    Help(xyPlus[axis],"Position "..string.upper(axis),{"Moves 10 UI units toward the positive direction.","X grows right, Y grows down."});
    Help(coordFields[axis],"Exact "..string.upper(axis).." coordinate",{"Enter a signed number and press Enter to apply.","Coordinates are relative to UIParent's top-left origin.","Some clients extend the visible screen beyond that origin."});
end

Help(autoWidth,"Automatic width",{"Fits the HUD to the displayed stat content.","Switch off to resize to a fixed width."});
Help(showSpells,"Spell HUD",{"Shows tracked abilities and selected procs.","The PROCS page lists damage sources seen this run."});
Help(clearSpells,"Clear tracked sources",{"Removes tracked abilities and procs for this class.","Saved named stat profiles are not affected."});
local tabDescriptions={
 "Select, arrange and save monitored statistics.",
 "Show owned abilities and observed damage procs.",
 "Customize layout, skins, typography and feedback effects.",
 "Explore run totals, spell damage, trends and author notes."
};
for i=1,table.getn(tabButtons) do
    Help(tabButtons[i],sectionKeys[i],{tabDescriptions[i]});
end
local statDescriptions={
 "Basic character statistics and their current values.",
 "Situational bonuses, DoT, pets, buffs and shields.",
 "The exact sequence of selected stats in the HUD.",
 "Build templates and your three editable named profiles."
};
for i=1,table.getn(statTabButtons) do
    Help(statTabButtons[i],({"CORE","ADVANCED","ORDER","PRESETS"})[i],{statDescriptions[i]});
end
Help(spellPageButtons[1].btn,"Abilities",{"Select the spells owned by your current class.","Shows their icons on the compact HUD."});
Help(spellPageButtons[2].btn,"Damage procs",{"Shows talent and item damage sources flagged by the meter.","Entries only appear after dealing actual damage."});
for i=1,table.getn(UIState.colorButtons) do
    Help(UIState.colorButtons[i].btn,UIState.accentDefs[i][1].." border",{"Changes border tint only.","The selected skin controls numbers and labels."});
end
for i=1,table.getn(orderRows) do
    local r=orderRows[i];
    Help(r.up,"Move up",{"Moves this tracked stat one position toward the top."});
    Help(r.down,"Move down",{"Moves this tracked stat one position toward the bottom."});
    Help(r.add,"Insert / remove element",{"Insert a full-row divider or spacer after this stat.","On an element row, click X to remove it."});
end
for i=1,table.getn(presetButtons) do
    Help(presetButtons[i].btn,ABA.presets[i].name,{"Choose a monitoring starting point.","This replaces the current selection but not the HUD style.","Use ORDER to change their visible sequence."});
end
local lookDescriptions={
 "HUD arrangement, width and spacing; drag the preview grip to resize.",
 "Choose a theme or use your own RGB hexadecimal colours.",
 "Visual frame silhouettes, borders and ready-made styles.",
 "Choose fonts, label styles and the Modern or Classic icons.",
 "Set bar widths, mark verified caps and customize fill/offsets.",
 "Animation intensity, gain effects, pulses and timing options."
};
for i=1,table.getn(lookTabs) do
    Help(lookTabs[i],lookPages[i][1],{lookDescriptions[i]});
end
for i=1,table.getn(insightTabs) do
    Help(insightTabs[i].btn,({"Run summary","Damage performance","Stat history","About YNX"})[i],
        {({"Your current run and recently finished runs.","Damage from learned spells and observed proc sources.","Stat samples from the current run.","Created by Ynx. Tips and available commands."})[i]});
end
Help(UIState.pulseBtn,"Pulse",{"Briefly enlarges the changed value twice, like a heartbeat.","Subtle = +2px; Normal = +3px. The HUD itself never resizes."});
Help(UIState.deltaBtn,"Preview last increase",{"Temporarily replaces the current value with the short gain.","The original number returns after the animation duration.","The HUD itself should not resize during this effect."});
for i=1,table.getn(UIState.effectButtons) do
    local info=({{"OFF","No highlights or movement."},{"SUBTLE","Soft green/red flash and a light 2px heartbeat."},
        {"NORMAL","Brighter, more noticeable flash and 3px heartbeat."}})[i];
    Help(UIState.effectButtons[i].btn,info[1],{info[2],"Gain preview duration is separately configurable."});
end
Help(UIState.glowBtn,"Value glow",{"Green for increases and red for decreases; a short fade-out.","No animation plays while Effects is OFF."});
Help(UIState.milestoneBtn,"Milestone flash",{"Uses a gold flash when crossing a supported milestone."});
Help(UIState.iconThemeBtn,"Icon art",{"MODERN: luminous framed icons.","CLASSIC: the original unframed stat symbols."});
Help(settingsDrag,"Move Settings",{"Drag the title bar to move this window.","Click R to reset its position."});
Help(UIState.gaugeBtn,"Milestone bars",{"Shows progress for Crit, Haste, Echo, Armor and Speed.","Bars show defined goals or milestones, not always hard caps."});
Help(UIState.barOptions.animate,"Smooth bar animation",{"Fills the progress bar gradually when the stat changes.","The transition speed is controlled below."});
Help(UIState.barOptions.highlight,"Gain highlight",{"New progress glows until the FX gain-preview duration ends.","The glow does not change any other bar or the HUD width."});
Help(UIState.barsReadyBtn,"Bars on ready screen",{"Shows progress before a run starts, using numeric values the game provides.","If there is no real number, no progress bar is invented."});
for i,entry in ipairs(UIState.frameButtons) do
    local names={"FLOAT","SOFT","BOX","ROUND","ROUNDLESS"};
    local lines={
       {"No background or frame. Ideal for floating numbers."},
       {"Background panel without an outline."},
       {"Square panel with a visible border."},
       {"Rounded masked corners and curved outline."},
       {"Rounded background without a visible border."}
    };
    Help(entry.btn,names[i],lines[i]);
end
for i,btn in ipairs(UIState.hudStyleButtons) do
    local notes={
      {"Minimal floating numbers, small icons, slim bars, 2-column grid."},
      {"Rounded and readable: bigger text, opaque panel, visible bars."},
      {"Large vertical layout with vivid feedback and room to read."}
    };
    Help(btn,UIState.hudStyles[i][1].." visual preset",{"Changes icon style, HUD frame, theme, typography and bar colours.","Never changes your tracked stat selection."});
end
for i,entry in ipairs(UIState.gaugeColorButtons) do
    Help(entry.btn,("Bar colour: "..UIState.gaugeColors[i][1]),{"SMART adapts to milestones. THEME matches selected HUD text.","Other colours remain constant across all progress values."});
end
Help(UIState.spellCDBtn,"Cooldown labels",{"Show ability cooldown lengths on the HUD."});
Help(UIState.spellDPSBtn,"Damage per second",{"Show tracked spell run DPS under the icon."});
for _,step in ipairs({scaleRow,widthRow,UIState.iconRow,UIState.fontRow,opacityRow,gapRow,UIState.brightnessRow,UIState.durationRow,
    padRow,borderRow,UIState.iconGapRow,gaugeHeightRow,UIState.barOptions.length,UIState.barOptions.transition}) do
    Help(step.minus,step.key,{"Decrease value. Changes preview immediately."});
    Help(step.plus,step.key,{"Increase value. Changes preview immediately."});
end
-- Dedicated refreshers stay below Lua 5.0's hard 32-upvalue limit.
local function RefreshFrameControls(d)
    for i=1,table.getn(UIState.frameButtons) do
        Selected(UIState.frameButtons[i].btn,d.frameKind==UIState.frameButtons[i].key)
    end
    for _,row in ipairs({padRow,borderRow,opacityRow}) do row.value:SetText(row.format(d[row.key])) end
end
local function RefreshBarsControls(d)
    for i=1,table.getn(UIState.gaugeColorButtons) do
        Selected(UIState.gaugeColorButtons[i].btn,d.gaugeColor==UIState.gaugeColorButtons[i].key)
    end
    for i=1,table.getn(UIState.barOptions.buttons) do
        Selected(UIState.barOptions.buttons[i].btn,d.gaugeGainTint==UIState.barOptions.buttons[i].key)
    end
    TogglePaint(UIState.barsReadyBtn,d.barsReady);

    TogglePaint(UIState.gaugeBtn,d.showMilestones);
    TogglePaint(UIState.barOptions.animate,d.gaugeAnimation);

    TogglePaint(UIState.barOptions.highlight,d.gaugeHighlight);

    for _,row in ipairs({gaugeHeightRow,UIState.barOptions.length,UIState.barOptions.transition}) do
        row.value:SetText(row.format(d[row.key]));
    end
end
local function RefreshTextAndEffects(d)
    for _,row in ipairs({UIState.iconRow,UIState.fontRow,UIState.brightnessRow,UIState.iconGapRow,UIState.yOffsetRow,UIState.durationRow}) do
        row.value:SetText(row.format(d[row.key]));
    end
    for i=1,3 do
        Selected(UIState.styleButtons[i].btn,d.statStyle==UIState.styleButtons[i].key);
        Selected(UIState.effectButtons[i].btn,d.effectMode==UIState.effectButtons[i].key);
    end
    TogglePaint(UIState.iconThemeBtn,d.iconTheme=="modern");
    UIState.iconThemeBtn.txt:SetText("ICON ART: "..(d.iconTheme=="modern" and "MODERN" or "CLASSIC"));
    UIState.fontFaceBtn.txt:SetText("HUD FONT: "..string.upper(d.valueFont or "clean"));
    local states={{UIState.deltaBtn,d.showDelta,"GAIN PREVIEW"},{UIState.pulseBtn,d.pulse,"HEARTBEAT PULSE"},
        {UIState.glowBtn,d.glow,"COLOUR FLASH"},{UIState.milestoneBtn,d.milestoneFlash,"GOLD MILESTONE"},
        {UIState.spellCDBtn,d.spellCD,"SPELL COOLDOWNS"},{UIState.spellDPSBtn,d.spellDPS,"SPELL DPS LABELS"}};
    for i=1,table.getn(states) do
        local v=states[i];TogglePaint(v[1],v[2]);
    end
end
local function RefreshXYFields()
    local x,y=ABA.GetHudXY();
    -- Do not replace partially typed values during the periodic UI refresh.
    local ex=coordFields.x.editing or (coordFields.x.HasFocus and coordFields.x:HasFocus());
    local ey=coordFields.y.editing or (coordFields.y.HasFocus and coordFields.y:HasFocus());
    if not ex then coordFields.x:SetText(tostring(math.floor(x+0.5))) end
    if not ey then coordFields.y:SetText(tostring(math.floor(y+0.5))) end
end
function UIState.RefreshNewLook(d)
    local selected=d.lookPage or lookPage;
    local old={overview="layout",style="skins",motion="effects",colors="skins"};
    selected=old[selected] or selected;
    if not lookGroups[selected] then selected="layout" end
    lookPage=selected;
    for i,info in ipairs(lookPages) do Selected(lookTabs[i],selected==info[2]) end
    for key,pane in pairs(lookGroups) do if key==selected then pane:Show() else pane:Hide() end end
    for key,pane in pairs(UIState.lookSides) do if key==selected then pane:Show() else pane:Hide() end end
    for i=1,3 do
        Selected(layoutModeButtons[i].btn,d.layoutMode==layoutModeButtons[i].key);
        Selected(colsButtons[i],d.columns==i);
    end
    TogglePaint(autoWidth,d.autoWidth);TogglePaint(layoutToggle,d.editLayout);
    gapColRow.value:SetText(gapColRow.format(d.colGap or 3));
    scaleRow.value:SetText(scaleRow.format(d.scale));widthRow.value:SetText(widthRow.format(d.hudWidth));
    UIState.sideRowGap.value:SetText(UIState.sideRowGap.format(d.rowGap));
    UIState.sidePad.value:SetText(UIState.sidePad.format(d.hudPadding));
    UIState.sideIconGap.value:SetText(UIState.sideIconGap.format(d.iconGap));
    RefreshXYFields();
    for i=1,table.getn(skinButtons) do Selected(skinButtons[i].btn,d.skin==skinButtons[i].key) end
    for i=1,table.getn(UIState.colorButtons) do Selected(UIState.colorButtons[i].btn,d.accent==UIState.colorButtons[i].key) end
    for i=1,table.getn(UIState.iconTiles) do Selected(UIState.iconTiles[i].btn,d.iconTheme==UIState.iconTiles[i].key) end
    for i=1,table.getn(UIState.barFlags) do local r=UIState.barFlags[i];TogglePaint(r.btn,d[r.key]) end
    UIState.markerStatus:SetText("GOALS: "..(d.showGoalMarkers and "ON" or "OFF").."   CONVERSION: "..(d.showConversionMarkers and "ON" or "OFF").."   CAPS: "..(d.showHardCapMarkers and "ON" or "OFF"));
    for i=1,table.getn(UIState.barWidthPresets) do
        local entry=UIState.barWidthPresets[i];Selected(entry.btn,math.abs(d.gaugeLength-entry.length)<0.005)
    end
    UIState.barOffsetX.value:SetText(UIState.barOffsetX.format(d.gaugeOffsetX));
    UIState.barOffsetY.value:SetText(UIState.barOffsetY.format(d.gaugeOffsetY));
    TogglePaint(UIState.paletteToggle,d.manualColorsEnabled);
    for kind,item in pairs(UIState.paletteFields) do
        if not item.field.editing then item.field:SetText("#"..d.manualColors[kind]) end
        local r,g,b=ABA.ColorFromHex(d.manualColors[kind]);if r then item.swatch:SetVertexColor(r,g,b,1) end
    end
    RefreshFrameControls(d);RefreshBarsControls(d);RefreshTextAndEffects(d);
    UIState.RefreshPreview(d)
end
local function RefreshLookControls(d) UIState.RefreshNewLook(d) end
local function RefreshInsightControls()
    for i=1,table.getn(insightTabs) do Selected(insightTabs[i].btn,insightPage==insightTabs[i].key) end
    if currentTab=="INSIGHTS" then
        local data=ABA.InsightLines and ABA.InsightLines(insightPage) or {"No live run data yet."};
        for i=1,table.getn(insightLines) do insightLines[i]:SetText(data[i] or "") end
    end
end
local function RefreshSettings()
    if not settings:IsShown() then return end
    local d=ABA.DB();
    for i=1,4 do Selected(tabButtons[i],sectionKeys[i]==currentTab) end
    RefreshStatControls(d);
    RefreshSpellControls(d);
    RefreshProcControls(d);
    RefreshLookControls(d);
    RefreshInsightControls();
    UIState.RefreshSideCards(d);
end
ABA.UpdateSettings=RefreshSettings;

local function WidthOf(label,fallback)
    if label and type(label.GetStringWidth)=="function" then
        local w=label:GetStringWidth();if type(w)=="number" and w>0 then return w end
    end
    return fallback;
end
-- The v0.9 gauge was gated to an active phase and OFF in many saved profiles.
-- We now honour BARS settings and permit real, numeric ready-screen values.
local function GaugeTint(d,info)
    local chosen=ABA.ManualColor("bar");if chosen then return chosen[1],chosen[2],chosen[3] end
    if d.gaugeColor=="cyan" then return 0.31,0.90,0.99 end
    if d.gaugeColor=="green" then return 0.25,0.94,0.62 end
    if d.gaugeColor=="gold" then return 1,0.78,0.29 end
    if d.gaugeColor=="theme" then return currentText[1],currentText[2],currentText[3] end
    if info.kind=="HARD" and info.complete then return 1,0.39,0.37 end
    if info.complete then return 1,0.79,0.33 end
    return 0.36,0.81,1
end
Gauge=function(row,stat,width)
    local d=ABA.DB();
    local ready=ABA.Phase()=="ready";
    local info=d.showMilestones and (not ready or d.barsReady) and ABA.GetMilestone(stat.key) or nil;
    if not info then row.track:Hide();row.fill:Hide();row.marker:Hide();row.gain:Hide();row.glint:Hide();row.gaugeShown=nil;row.gaugeTarget=nil;row.gainUntil=nil;return end
    local length=math.max(12,(width-3)*d.gaugeLength);local height=d.gaugeHeight;
    row.track:Show();row.fill:Show();row.track:SetWidth(length);row.track:SetHeight(height);
    row.track:ClearAllPoints();row.track:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",2+d.gaugeOffsetX,2+d.gaugeOffsetY);
    row.gaugeLength=length;row.gaugeTarget=info.progress;
    row.track:SetVertexColor(currentSecondary[1]*0.48,currentSecondary[2]*0.48,currentSecondary[3]*0.48,0.90);
    row.fill:SetHeight(height);
    if type(row.gaugeShown)~="number" or row.gaugeStat~=stat.key then
        row.gaugeShown=info.progress;row.gaugeStat=stat.key;row.gaugeAt=nil;row.gaugeStart=info.progress;row.gainUntil=nil
    elseif math.abs(row.gaugeShown-info.progress)>0.0001 and row.gaugeTargetPrevious~=info.progress then
        row.gaugeStart=row.gaugeShown;row.gaugeAt=GetTime();row.gainUntil=row.gaugeAt+d.deltaDuration;
        if not d.gaugeAnimation then row.gaugeShown=info.progress;row.gaugeAt=nil end
    end
    row.gaugeTargetPrevious=info.progress;
    row.fill:SetWidth(math.max(1,length*row.gaugeShown));
    local r,g,b=GaugeTint(d,info);row.fill:SetVertexColor(r,g,b,1);
    if info.marker and d.showGoalMarkers then
        row.marker:ClearAllPoints();row.marker:SetPoint("LEFT",row.track,"LEFT",length*info.marker,0);
        row.marker:SetHeight(math.max(5,height+2));row.marker:SetVertexColor(1,0.78,0.36,1);row.marker:Show()
    elseif info.hardCap and d.showHardCapMarkers then
        row.marker:ClearAllPoints();row.marker:SetPoint("RIGHT",row.track,"RIGHT",0,0);
        row.marker:SetHeight(math.max(6,height+3));row.marker:SetVertexColor(1,0.34,0.32,1);row.marker:Show()
    elseif info.milestone and d.showConversionMarkers then
        row.marker:ClearAllPoints();row.marker:SetPoint("RIGHT",row.track,"RIGHT",0,0);
        row.marker:SetHeight(math.max(6,height+3));row.marker:SetVertexColor(0.75,0.50,1,1);row.marker:Show()
    else row.marker:Hide() end
end
local function RowWidth(row,spec,d)
    local size=d.iconSize;local width=4;
    local stable=ABA.ValueFrom(spec,(type(AZS_STATS)=="table" and AZS_STATS[spec.key]) or nil);
    if d.statStyle~="text" then width=width+size+3 end
    if d.statStyle=="both" or d.statStyle=="text" then width=width+WidthOf(row.name,string.len(spec.short)*6.6)+4 end
    -- Reserve enough room for the largest short gain preview, even at the start of a run.
    -- This width does not respond to the temporary animation.
    width=width+math.max(WidthOf(row.measure,string.len(stable)*d.fontSize*0.67),d.fontSize*4.5)+d.iconGap+6;
    return math.max(44,math.ceil(width));
end
local function StatLayout(list)
    local d=ABA.DB();local total=table.getn(list);local size=d.iconSize;
    local rowH=math.max(size,d.fontSize)+7+d.rowGap+(d.showMilestones and d.gaugeHeight+3 or 0);
    local pad=d.hudPadding; local colGap=d.colGap or 3;
    local requiredCell=50;
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];local spec=list[i];
        if spec then
            row.stat=spec;row.icon:SetTexture((d.iconTheme=="modern" and MODERN or MEDIA)..spec.icon..".tga");
            row.icon:SetTexCoord(d.iconTheme=="modern" and 0 or 0.08,d.iconTheme=="modern" and 1 or 0.92,d.iconTheme=="modern" and 0 or 0.08,d.iconTheme=="modern" and 1 or 0.92);
            row.icon:SetWidth(size);row.icon:SetHeight(size);
            row.halo:SetWidth(size+7);row.halo:SetHeight(size+7);
            if d.iconTheme=="modern" and d.frameKind~="float" then
                row.halo:SetVertexColor(0.28,0.72,0.95,0.38);row.halo:Show()
            else row.halo:Hide() end
            local lum=d.iconBrightness;row.icon:SetVertexColor(lum,lum,lum,1);
            SetHUDValueFont(row.value,d.fontSize,"OUTLINE");row.value:SetText(ABA.DisplayValue(spec));
            SetHUDValueFont(row.delta,math.max(9,d.fontSize-2),"OUTLINE");
            -- Measure the normal numeric value, never the temporary long preview.
            SetHUDValueFont(row.measure,d.fontSize,"OUTLINE");
            row.measure:SetText(ABA.ValueFrom(spec,(type(AZS_STATS)=="table" and AZS_STATS[spec.key]) or nil));
            row.value:SetTextColor(currentText[1],currentText[2],currentText[3]);
            row.name:SetTextColor(currentSecondary[1],currentSecondary[2],currentSecondary[3]);
            row.name:SetText(spec.short);SetYNXFont(row.name,math.max(9,d.fontSize-2),"OUTLINE");
            local required=RowWidth(row,spec,d);row.required=required;requiredCell=math.max(requiredCell,required);
        else row.stat=nil;row:Hide() end
    end
    local cols=1;
    if d.layoutMode=="grid" then cols=d.columns
    elseif d.layoutMode=="horizontal" then
        cols=math.max(1,math.floor(((d.autoWidth and 440 or d.hudWidth)-pad*2+colGap)/(requiredCell+colGap)))
    end
    cols=math.max(1,math.min(total>0 and total or 1,cols));
    local width;
    if d.autoWidth then width=math.max(54,cols*requiredCell+math.max(0,cols-1)*colGap+pad*2+2)
    else
        width=math.max(d.hudWidth,requiredCell+pad*2+2);
        if d.layoutMode=="horizontal" then
            cols=math.max(1,math.floor((width-pad*2+colGap)/(requiredCell+colGap)));cols=math.min(total>0 and total or 1,cols)
        else
            cols=math.min(cols,math.max(1,math.floor((width-pad*2+colGap)/(requiredCell+colGap))))
        end
    end
    width=clamp(width,54,1000);hud:SetWidth(width);hud:SetMinResize(85,24);
    local coords,extras,overallHeight=ABA.StatGeometry(list,cols,requiredCell,rowH,pad,colGap);
    -- Paint a compact grid. Content starts at x=4; number immediately follows the icon.
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];local spec=list[i];
        if spec then
            local at=coords[i];
            row:SetWidth(requiredCell);row:SetHeight(rowH-1);row:ClearAllPoints();
            row:SetPoint("TOPLEFT",hud,"TOPLEFT",at.x,-at.y);
            row.icon:Hide();row.name:Hide();row.value:ClearAllPoints();
            local anchor=row;local pos="LEFT";
            if d.statStyle~="text" then
                row.icon:Show();row.icon:ClearAllPoints();row.icon:SetPoint("LEFT",row,"LEFT",2,0);
                anchor=row.icon;pos="RIGHT";
            end
            if d.statStyle~="icons" then
                row.name:Show();row.name:ClearAllPoints();row.name:SetPoint("LEFT",anchor,pos,d.statStyle=="text" and 2 or d.iconGap,0);
                anchor=row.name;pos="RIGHT";
            end
            row.value:SetPoint("LEFT",anchor,pos,d.iconGap,d.valueYOffset);
            row.delta:ClearAllPoints();row.delta:SetPoint("RIGHT",row,"RIGHT",-4,6+d.valueYOffset);
            Gauge(row,spec,requiredCell-3);
            row.hRule:Hide();row.vRule:Hide();
            row:Show();
        end
    end
    UIState.DrawExtras(hud,extras,width,overallHeight);
    if total==0 then return width,0 end
    return width,overallHeight-pad*2-2;
end
local function SpellLayout(spells,y,width)
    local d=ABA.DB();local count=table.getn(spells);local cols=math.max(1,math.floor((width-9)/37));
    local rowH=(d.spellCD or d.spellDPS) and (d.spellCD and d.spellDPS and 54 or 43) or 32;
    for i=1,table.getn(spellWidgets) do
        local row=spellWidgets[i];local sp=spells[i];
        if sp then
            row.spell=sp;row.icon:SetTexture(ABA.SpellIcon(sp));row:SetWidth(35);row:SetHeight(rowH);
            row:ClearAllPoints();row:SetPoint("TOPLEFT",hud,"TOPLEFT",d.hudPadding+math.mod(i-1,cols)*37,-(y+math.floor((i-1)/cols)*rowH));
            local label="";if d.spellCD and type(sp.cdmax)=="number" then label=string.format("%.1fs",sp.cdmax) end
            if d.spellDPS then
                local m=ABA.FindMeter(sp);local txt=m and string.format("%.0fd",m.dps or 0) or "--d";
                label=label~="" and label.."\n"..txt or txt;
            end
            row.detail:SetText(label);row:Show();
        else row.spell=nil;row:Hide() end
    end
    if count==0 then return 0 end return math.ceil(count/cols)*rowH;
end
local function ProcLayout(rows,y,width)
    local count=math.min(table.getn(rows),table.getn(procWidgets));
    local cols=math.max(1,math.floor((width-7)/120));
    cols=math.min(cols,count>0 and count or 1);
    for i=1,table.getn(procWidgets) do
        local r=procWidgets[i];local data=rows[i];
        if data then
            r.procRow=data;r.ico:SetTexture(ABA.ProcIcon(data));
            r.txt:SetText(string.format("%.1f DPS",data.dps or 0));
            r:SetWidth(117);r:ClearAllPoints();
            r:SetPoint("TOPLEFT",hud,"TOPLEFT",ABA.DB().hudPadding+math.mod(i-1,cols)*120,-(y+math.floor((i-1)/cols)*25));
            r:Show();
        else r.procRow=nil;r:Hide() end
    end
    if count==0 then return 0 end
    return math.ceil(count/cols)*25;
end
local lastPhase="";
function ABA.Update(force)
    local phase=ABA.Phase();local d=ABA.DB();
    ABA.statsLive=(phase=="playing" or phase=="choosing" or phase=="paused" or phase=="dead" or phase=="victory");
    if not d.pinned then
        ABA.StopInteraction();hud:Hide();settings:Hide();moveHandle:Hide();resizeGrip:Hide();return
    end
    ApplySkin();local stats=CurrentStats();local spells=ABA.statsLive and CurrentSpells() or {};
    local procs=ABA.statsLive and d.spellVisible and ABA.TrackedProcs() or {};
    if table.getn(stats)==0 and table.getn(spells)==0 and table.getn(procs)==0 then emptyHint:Show() else emptyHint:Hide() end
    local width,statH=StatLayout(stats);local gap=statH>0 and table.getn(spells)>0 and 5 or 0;
    local spellH=SpellLayout(spells,5+statH+gap,width);
    local pGap=(statH+spellH)>0 and table.getn(procs)>0 and 5 or 0;
    if table.getn(procs)>0 then width=math.max(122,width);hud:SetWidth(width) end
    local procH=ProcLayout(procs,5+statH+gap+spellH+pGap,width);
    hud:SetHeight(math.max((d.frameKind=="round" or d.frameKind=="softround") and 36 or 26,statH+spellH+procH+gap+pGap+d.hudPadding*2+2));hud:SetScale(d.scale);
    if not moveDrag then PutAt(posX,posY,false) end
    PositionHandles();ApplySkin();local justShown=not hud:IsShown();hud:Show();RefreshHandles();
    if justShown or lastPhase~=phase then Top(hud) end
    if settings:IsShown() then DockSettings();RefreshSettings() end
    lastPhase=phase;
end
-- Event-driven effects: value text grows briefly, not the frame or its hit area.
local lastFontState={};
function UIState.AnimateRow(row,elapsed,previewEvent)
    if not row.stat then return end
    local d=ABA.DB();local gainTint=ABA.ManualColor("gain");
    row.delta:Hide(); -- single short gain expression replaces the current number for the preview
    if row.gaugeLength and type(row.gaugeShown)=="number" and type(row.gaugeTarget)=="number" then
        local now=GetTime();
        local elapsedSince=row.gaugeAt and math.max(0,now-row.gaugeAt) or 99;
        if d.gaugeAnimation and row.gaugeAt and elapsedSince<d.gaugeTransition then
            local t=math.min(1,elapsedSince/d.gaugeTransition);t=1-(1-t)*(1-t)*(1-t);
            row.gaugeShown=row.gaugeStart+(row.gaugeTarget-row.gaugeStart)*t;
        else row.gaugeShown=row.gaugeTarget;row.gaugeAt=nil end
        row.fill:SetWidth(math.max(1,row.gaugeLength*row.gaugeShown));
        if d.gaugeHighlight and row.gaugeTarget>row.gaugeStart then
            local remaining=type(row.gainUntil)=="number" and (row.gainUntil-now) or -1;
            local fade=math.max(0,math.min(1,remaining/0.3));
            if fade>0 then
                local from=row.gaugeLength*math.max(0,row.gaugeStart or 0);
                local toTarget=row.gaugeLength*math.max(0,row.gaugeTarget or 0);
                local toShown=row.gaugeLength*math.max(0,row.gaugeShown or 0);
                row.gain:SetHeight(d.gaugeHeight);row.gain:SetWidth(math.max(1,toShown-from));
                row.gain:ClearAllPoints();row.gain:SetPoint("LEFT",row.track,"LEFT",from,0);
                local tint=gainTint or (d.gaugeGainTint=="cyan" and {0.26,0.95,1} or (d.gaugeGainTint=="gold" and {1,0.82,0.28} or {0.35,1,0.48}));
                row.gain:SetVertexColor(tint[1],tint[2],tint[3],0.94*fade);row.gain:Show();
                row.glint:SetHeight(d.gaugeHeight+2);row.glint:ClearAllPoints();
                row.glint:SetPoint("LEFT",row.track,"LEFT",row.gaugeAt and toShown or toTarget,0);
                row.glint:SetVertexColor(0.93,1,1,0.63*fade);row.glint:Show();
            else row.gain:Hide();row.glint:Hide() end
        else row.gain:Hide();row.glint:Hide() end
    end
    local x=previewEvent or ABA.statChanged[row.stat.key];local age=x and (GetTime()-x.at) or 999;
    local isUp=x and ((row.stat.kind=="cooldown" and x.after<x.before) or (row.stat.kind~="cooldown" and x.after>x.before));
    if previewEvent then
        -- Identical gain text as ABA.DisplayValue, but without mutating AZS_STATS
        -- or ABA.statChanged; this preview never changes the real HUD.
        if d.showDelta and d.effectMode~="off" and age>=0 and age<d.deltaDuration then
            row.value:SetText(ABA.ChangeAmount(row.stat,x.before,x.after))
        else row.value:SetText(ABA.ValueFrom(row.stat,x.after)) end
    else row.value:SetText(ABA.DisplayValue(row.stat)) end
    if (not previewEvent and not ABA.statsLive) or d.effectMode=="off" or not x or age<0 or age>d.deltaDuration then
        if row.lastPulse~=0 then SetHUDValueFont(row.value,d.fontSize,"OUTLINE");row.lastPulse=0 end
        row.value:SetTextColor(currentText[1],currentText[2],currentText[3]);row.flash:SetVertexColor(0.10,0.75,0.29,0);
        row.delta:Hide();
        row.icon:SetWidth(d.iconSize);row.icon:SetHeight(d.iconSize);
        if d.iconTheme=="modern" and d.frameKind~="float" then row.halo:SetAlpha(1); row.halo:Show() else row.halo:Hide() end
        return
    end
    local extra=0; local iconExtra=0;
    if d.pulse then
        if age<0.16 or (age>0.28 and age<0.44) then extra=d.effectMode=="normal" and 2 or 1; iconExtra=d.effectMode=="normal" and 4 or 2 end
    end
    if row.lastPulse~=extra then SetHUDValueFont(row.value,d.fontSize+extra,"OUTLINE");row.lastPulse=extra end
    if iconExtra>0 then
        row.icon:SetWidth(d.iconSize+iconExtra);row.icon:SetHeight(d.iconSize+iconExtra);
        row.halo:SetWidth(d.iconSize+7+iconExtra);row.halo:SetHeight(d.iconSize+7+iconExtra);
        row.halo:SetVertexColor(isUp and (gainTint and gainTint[1] or 0.28) or 1,
            isUp and (gainTint and gainTint[2] or 0.95) or 0.35,
            isUp and (gainTint and gainTint[3] or 0.55) or 0.35,0.65);
        row.halo:Show();
    else
        row.icon:SetWidth(d.iconSize);row.icon:SetHeight(d.iconSize);
        if d.iconTheme=="modern" and d.frameKind~="float" then row.halo:SetAlpha(1); row.halo:SetVertexColor(0.28,0.72,0.95,0.38); row.halo:Show() else row.halo:Hide() end
    end
    local milestoneHit=false;
    if d.milestoneFlash and x then
        local before=ABA.GetMilestone and ABA.GetMilestone(row.stat.key,{[row.stat.key]=x.before});
        local after=ABA.GetMilestone and ABA.GetMilestone(row.stat.key,{[row.stat.key]=x.after});
        milestoneHit=before and after and not before.complete and after.complete;
    end
    if milestoneHit then row.value:SetTextColor(1,0.80,0.30)
    elseif isUp then row.value:SetTextColor(gainTint and gainTint[1] or 0.42,gainTint and gainTint[2] or 0.98,gainTint and gainTint[3] or 0.54)
    else row.value:SetTextColor(1.0,0.45,0.43) end
    if d.glow then
        local fade=math.max(0,1-age/d.deltaDuration)*(d.effectMode=="normal" and 0.28 or 0.13);
        if isUp then row.flash:SetVertexColor(gainTint and gainTint[1] or 0.12,gainTint and gainTint[2] or 0.90,gainTint and gainTint[3] or 0.36,fade)
        else row.flash:SetVertexColor(0.98,0.15,0.16,fade) end
    else row.flash:SetVertexColor(0.10,0.75,0.29,0) end
end
hud:SetScript("OnUpdate",function()
    local elapsed=arg1;
    if moveDrag then if not GestureTick(moveDrag,EndMove,elapsed) then MoveAtCursor() end end
    if resizeDrag then if not GestureTick(resizeDrag,EndResize,elapsed) then ResizeAtCursor() end end
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];if row.stat and row:IsShown() then UIState.AnimateRow(row,elapsed) end
    end
end);
hud:Hide();ABA.hud=hud;ABA.settingsPanel=settings;ABA.SelectTab=SelectTab;ABA.statWidgets=statWidgets;
ABA.moveHandle=moveHandle;ABA.resizeGrip=resizeGrip;ABA.layoutToggle=layoutToggle;
ABA.scalePlus=scaleRow.plus;ABA.scaleMinus=scaleRow.minus;ABA.widthPlus=widthRow.plus;ABA.widthMinus=widthRow.minus;
ABA.coordFields=coordFields;ABA.xyMinus=xyMinus;ABA.xyPlus=xyPlus;
ABA.resetButton=resetPosition;ABA.lookGroups=lookGroups;ABA.statGroups=statGroups;
ABA.statTabButtons=statTabButtons;ABA.lookTabs=lookTabs;ABA.insightTabs=insightTabs;
ABA.presetButtons=presetButtons;ABA.skinButtons=skinButtons;ABA.spellSelect=spellSelect;
ABA.procSelect=procSelect;ABA.procWidgets=procWidgets;ABA.spellPageButtons=spellPageButtons;
ABA.statSelect=statSelect;ABA.styleButtons=UIState.styleButtons;ABA.effectButtons=UIState.effectButtons;
ABA.layoutModeButtons=layoutModeButtons;ABA.colsButtons=colsButtons;ABA.colorButtons=UIState.colorButtons;
ABA.frameButtons=UIState.frameButtons;ABA.hudStyleButtons=UIState.hudStyleButtons;
ABA.gaugeColorButtons=UIState.gaugeColorButtons;ABA.barsReadyBtn=UIState.barsReadyBtn;
ABA.gaugeBtn=UIState.gaugeBtn;ABA.roundedParts=roundedParts;
ABA.barOptions=UIState.barOptions;
ABA.utilityButtons={};ABA.slotButtons=slotButtons;ABA.orderRows=orderRows;ABA.sectionButtons=tabButtons;
ABA.insightLines=insightLines;ABA.preview=UIState.preview;
SelectTab("LOOK");
