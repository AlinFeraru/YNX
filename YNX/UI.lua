-- YNX 0.8.0. Azeroth Survivors / WoW 1.12 Lua 5.0-compatible UI.
-- Never depend on modern WoW Mixin, _G, #, or mouse-button polling.
local WHITE="Interface\\Buttons\\WHITE8X8";
local MEDIA="Interface\\AddOns\\YNX\\Media\\";
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
    local f=p:CreateFontString(nil,"OVERLAY");f:SetFont("Fonts\\FRIZQT__.TTF",n or 11,"OUTLINE");
    f:SetTextColor(color[1],color[2],color[3]);f:SetJustifyH(align or "LEFT");return f;
end
local function BG(f)
    f:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    f:SetBackdropColor(0.014,0.022,0.035,0.985);
    f:SetBackdropBorderColor(0.20,0.32,0.43,0.92);
end
local function PaintButton(b)
    local c;
    if b.selected then c={0.16,0.23,0.30}
    elseif b.toggleOn == true then c={0.065,0.25,0.20}
    elseif b.toggleOn == false then c={0.11,0.15,0.21}
    else c={0.06,0.105,0.155} end
    if b.hover then b:SetBackdropColor(c[1]+0.075,c[2]+0.08,c[3]+0.08,0.99)
    else b:SetBackdropColor(c[1],c[2],c[3],0.98) end
    if b.selected then b:SetBackdropBorderColor(0.98,0.72,0.26,1)
    elseif b.toggleOn==true then b:SetBackdropBorderColor(0.22,0.78,0.59,0.97)
    else b:SetBackdropBorderColor(0.24,0.41,0.54,0.90) end
end
local function Button(p,title,w,h,onclick)
    local b=CreateFrame("Button",nil,p);b:SetWidth(w);b:SetHeight(h);
    b:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    b.txt=Font(b,11,C.white,"CENTER");b.txt:SetAllPoints(b);b.txt:SetText(title or "");
    b:SetScript("OnClick",onclick);
    b:SetScript("OnEnter",function() b.hover=true;PaintButton(b) end);
    b:SetScript("OnLeave",function() b.hover=false;PaintButton(b) end);
    PaintButton(b);return b;
end
local function TogglePaint(b,on)
    b.toggleOn=on == true;b.selected=false;PaintButton(b);
    b.txt:SetTextColor(on and 0.55 or 0.69,on and 1 or 0.76,on and 0.77 or 0.83)
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
    if on then b.txt:SetTextColor(1,0.81,0.42)
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
local settings=CreateFrame("Frame","YNX_Settings",UIParent);settings:SetFrameStrata("TOOLTIP");settings:SetWidth(390);settings:SetHeight(545);BG(settings);settings:Hide();
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
    local d=ABA.DB();local nw=clamp(math.floor(resizeDrag.width+(x-resizeDrag.cursorX)/(ParentScale()*HudScale())+0.5),85,700);
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
moveHandle=Button(hud,"MOVE",40,17,function() EndMove() end);
moveHandle:SetFrameLevel(hud:GetFrameLevel()+9);moveHandle:RegisterForDrag("LeftButton");
moveHandle:SetScript("OnMouseDown",function() if arg1=="LeftButton" then BeginMove() end end);
moveHandle:SetScript("OnDragStart",BeginMove);moveHandle:SetScript("OnDragStop",EndMove);
moveHandle:SetScript("OnMouseUp",function() if arg1=="LeftButton" then EndMove() end end);
moveHandle:SetScript("OnHide",function() if moveDrag then ABA.StopInteraction() end end);
moveHandle:SetScript("OnEnter",function() Tip(moveHandle,"Move YNX",{"Drag to move. Lock in LOOK when finished."}) end);
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
    local enabled=d.frameKind=="round";
    for _,piece in pairs(roundedParts.background) do
        if enabled then piece:Show();piece:SetVertexColor(c[1],c[2],c[3],c[4]*opacity)
        else piece:Hide() end
    end
    for key,piece in pairs(roundedParts.stroke) do
        if enabled then
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
local function ApplySkin()
    local d=ABA.DB();local c=skins[d.skin] or skins.shadow;
    -- Opacity only affects the panel, not text. Bare is intentionally faint.
    local pal=skinText[d.skin] or skinText.shadow;
    currentText=pal[1];currentSecondary=pal[2];
    local opacity=clamp(d.opacity,0.05,1);
    local accent=accentColors[d.accent] or {c[5],c[6],c[7]};
    if d.frameKind=="box" then
        hud:SetBackdropColor(c[1],c[2],c[3],c[4]*opacity);
        hud:SetBackdropBorderColor(accent[1],accent[2],accent[3],c[8]*opacity);
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
    row.icon:SetPoint("LEFT",row,"LEFT",2,0);row.icon:SetTexCoord(0.08,0.92,0.08,0.92);
    row.name=Font(row,11,C.grey);row.name:SetPoint("LEFT",row,"LEFT",2,0);
    row.value=Font(row,12,C.white);row.value:SetPoint("LEFT",row.icon,"RIGHT",3,0);
    row.flash=row:CreateTexture(nil,"BACKGROUND");row.flash:SetTexture(WHITE);row.flash:SetAllPoints(row);row.flash:SetVertexColor(0.10,0.75,0.29,0);
    row.track=row:CreateTexture(nil,"BACKGROUND");row.track:SetTexture(WHITE);row.track:SetVertexColor(0.26,0.39,0.47,0.82);row.track:SetHeight(2);
    row.track:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",2,2);
    row.fill=row:CreateTexture(nil,"ARTWORK");row.fill:SetTexture(WHITE);row.fill:SetHeight(2);row.fill:SetPoint("BOTTOMLEFT",row.track,"BOTTOMLEFT",0,0);
    row.hRule=row:CreateTexture(nil,"OVERLAY");row.hRule:SetTexture(WHITE);row.hRule:SetHeight(2);row.hRule:Hide();
    row.vRule=row:CreateTexture(nil,"OVERLAY");row.vRule:SetTexture(WHITE);row.vRule:SetWidth(2);row.vRule:Hide();
    row.marker=row:CreateTexture(nil,"OVERLAY");row.marker:SetTexture(WHITE);row.marker:SetWidth(2);row.marker:SetHeight(5);row.marker:SetVertexColor(1,0.86,0.46,1);
    row:SetScript("OnClick",function() ABA.ToggleSettings() end);
    row:SetScript("OnEnter",function() StatTip(row) end);row:SetScript("OnLeave",HideTip);
    row:Hide();statWidgets[i]=row;
end
local spellWidgets={};
for i=1,12 do
    local row=CreateFrame("Button",nil,hud);row:SetWidth(36);row:SetHeight(40);row:EnableMouse(true);
    row.icon=row:CreateTexture(nil,"ARTWORK");row.icon:SetWidth(28);row.icon:SetHeight(28);row.icon:SetPoint("TOP",row,"TOP",0,-1);
    row.detail=Font(row,9,C.grey,"CENTER");row.detail:SetPoint("TOP",row.icon,"BOTTOM",0,0);row.detail:SetWidth(38);
    row:SetScript("OnClick",function() ABA.ToggleSettings() end);
    row:SetScript("OnEnter",function() SpellTip(row) end);row:SetScript("OnLeave",HideTip);
    row:Hide();spellWidgets[i]=row;
end
local procWidgets={};
for i=1,14 do
    local r=CreateFrame("Button",nil,hud);r:SetWidth(115);r:SetHeight(25);r:EnableMouse(true);
    r.ico=r:CreateTexture(nil,"ARTWORK");r.ico:SetWidth(19);r.ico:SetHeight(19);
    r.ico:SetPoint("LEFT",r,"LEFT",1,0);
    r.txt=Font(r,11,C.blue);r.txt:SetPoint("LEFT",r.ico,"RIGHT",4,0);r.txt:SetWidth(93);
    r:SetScript("OnClick",function() ABA.ToggleSettings();if ABA.SelectTab then ABA.SelectTab("SPELLS") end end);
    r:SetScript("OnEnter",function()
        if r.procRow then Tip(r,r.procRow.name,{
            string.format("Proc damage: %.0f",r.procRow.dmg or 0),
            string.format("Run DPS: %.1f",r.procRow.dps or 0),
            string.format("Share: %.1f%%",(r.procRow.share or 0)*100),
            "From game damage meter; activation count not available."}) end
    end);r:SetScript("OnLeave",HideTip);r:Hide();procWidgets[i]=r;
end
hud:SetScript("OnMouseUp",function()
    if moveDrag or resizeDrag then return end
    if arg1=="LeftButton" or arg1=="RightButton" then ABA.ToggleSettings() end
end);

-- Independently positioned settings window (never anchors to HUD scale).
local function DockSettings()
    -- Center Settings independently of the HUD.  Never chase the HUD cursor.
    local w=UIParent:GetWidth();local h=UIParent:GetHeight();
    if type(w)~="number" or w<100 then w=1024 end
    if type(h)~="number" or h<100 then h=768 end
    local scale=math.min(1,(w-14)/settings:GetWidth(),(h-14)/settings:GetHeight());
    scale=math.max(0.35,scale);settings:SetScale(scale);
    settings:ClearAllPoints();settings:SetPoint("CENTER",UIParent,"CENTER",0,0);
end
ABA.DockSettings=DockSettings;
local headerTex=settings:CreateTexture(nil,"ARTWORK");headerTex:SetTexture(WHITE);
headerTex:SetPoint("TOPLEFT",settings,"TOPLEFT",6,-6);
headerTex:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-6,-6);headerTex:SetHeight(31);
headerTex:SetVertexColor(0.055,0.10,0.16,0.98);
Label(settings,"YNX  /  Your Numbers eXposed",14,12,14,C.blue);
local topAccent=settings:CreateTexture(nil,"ARTWORK");topAccent:SetTexture(WHITE);
topAccent:SetPoint("TOPLEFT",settings,"TOPLEFT",7,-37);topAccent:SetWidth(376);topAccent:SetHeight(2);
topAccent:SetVertexColor(0.91,0.64,0.25,0.95);
local exit=Button(settings,"X",22,22,function() settings:Hide() end);exit:SetPoint("TOPRIGHT",settings,"TOPRIGHT",-9,-9);
local sectionKeys={"STATS","SPELLS","LOOK","INSIGHTS"};local tabButtons,pages={},{};local currentTab="STATS";
local function SelectTab(k)
    currentTab=k;
    for i=1,table.getn(sectionKeys) do
        local id=sectionKeys[i];if id==k then pages[id]:Show() else pages[id]:Hide() end
        Selected(tabButtons[i],id==k);
    end
    if ABA.UpdateSettings then ABA.UpdateSettings() end
end
for i=1,4 do
    local k=sectionKeys[i];local b=Button(settings,k,88,26,BindClick(k,SelectTab));
    b:SetPoint("TOPLEFT",settings,"TOPLEFT",9+(i-1)*94,-48);tabButtons[i]=b;
    local ico=b:CreateTexture(nil,"ARTWORK");ico:SetTexture(MEDIA..({"dmg","echo","area","crit"})[i]..".tga");
    ico:SetWidth(13);ico:SetHeight(13);ico:SetPoint("LEFT",b,"LEFT",4,0);
    b.txt:ClearAllPoints();b.txt:SetPoint("CENTER",b,"CENTER",7,0);
    pages[k]=CreateFrame("Frame",nil,settings);pages[k]:SetPoint("TOPLEFT",settings,"TOPLEFT",9,-86);
    pages[k]:SetWidth(372);pages[k]:SetHeight(447);pages[k]:Hide();
    pages[k]:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    pages[k]:SetBackdropColor(0.024,0.045,0.070,0.82);
    pages[k]:SetBackdropBorderColor(0.25,0.39,0.49,0.82);
    local rail=pages[k]:CreateTexture(nil,"BACKGROUND");rail:SetTexture(WHITE);
    rail:SetPoint("TOPLEFT",pages[k],"TOPLEFT",0,0);rail:SetWidth(372);rail:SetHeight(2);
    rail:SetVertexColor(0.94,0.72,0.32,0.9);
    local side=pages[k]:CreateTexture(nil,"BACKGROUND");side:SetTexture(WHITE);
    side:SetPoint("TOPLEFT",pages[k],"TOPLEFT",0,0);side:SetWidth(2);side:SetHeight(445);
    side:SetVertexColor(0.32,0.60,0.78,0.82);
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
        local icon=b:CreateTexture(nil,"ARTWORK");icon:SetTexture(MEDIA..file..".tga");
        icon:SetWidth(13);icon:SetHeight(13);icon:SetPoint("LEFT",b,"LEFT",4,0);
        b.txt:ClearAllPoints();b.txt:SetPoint("CENTER",b,"CENTER",7,0)
    end
    return b;
end
local function DimButton(parent,text,x,y,w,fn)
    local b=Button(parent,text,w,25,fn);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y);return b;
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
    b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetWidth(19);b.icon:SetHeight(19);b.icon:SetTexture(MEDIA..s.icon..".tga");b.icon:SetPoint("LEFT",b,"LEFT",3,0);
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
Label(orderPane,"HUD ORDER   /   DRAG-FREE CUSTOMIZATION",6,2,11,C.gold);
Label(orderPane,"Arrange tracked stats. Add a line AFTER any stat.",6,21,10,C.grey);
for i=1,8 do
    local b=Button(orderPane,"",357,30,function() end);
    b:SetPoint("TOPLEFT",orderPane,"TOPLEFT",5,-(42+(i-1)*34));
    b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetWidth(18);b.icon:SetHeight(18);b.icon:SetPoint("LEFT",b,"LEFT",6,0);
    b.title=Font(b,10,C.white);b.title:SetPoint("LEFT",b,"LEFT",29,0);b.title:SetWidth(178);
    b.up=Button(b,"^",23,22,function() if type(b.spec)=="table" then ABA.MoveStat(b.spec.key,-1) end end);
    b.up:SetPoint("RIGHT",b,"RIGHT",-88,0);
    b.down=Button(b,"v",23,22,function() if type(b.spec)=="table" then ABA.MoveStat(b.spec.key,1) end end);
    b.down:SetPoint("RIGHT",b,"RIGHT",-62,0);
    b.ruleH=Button(b,"-",26,22,function()
        if b.spec then local d=ABA.DB();local k=b.spec.key;
            if d.orderSeparators[k]=="h" then d.orderSeparators[k]=nil else d.orderSeparators[k]="h" end
            ABA.Update(true) end
    end);b.ruleH:SetPoint("RIGHT",b,"RIGHT",-33,0);
    b.ruleV=Button(b,"|",26,22,function()
        if b.spec then local d=ABA.DB();local k=b.spec.key;
            if d.orderSeparators[k]=="v" then d.orderSeparators[k]=nil else d.orderSeparators[k]="v" end
            ABA.Update(true) end
    end);b.ruleV:SetPoint("RIGHT",b,"RIGHT",-4,0);
    b:SetScript("OnEnter",function() if b.spec then Tip(b,b.spec.name,{"Move up/down or add a divider after this stat.","- : horizontal line    | : vertical line", "Tap the divider again to remove it."}) end end);
    b:SetScript("OnLeave",HideTip);
    b:Hide();orderRows[i]=b;
end
local orderPrev=DimButton(orderPane,"< BACK",5,316,104,function() orderIndex=math.max(1,orderIndex-1);ABA.Update(true) end);
local orderNext=DimButton(orderPane,"NEXT >",257,316,105,function() orderIndex=orderIndex+1;ABA.Update(true) end);
local orderPageLabel=Label(orderPane,"",158,322,11,C.gold);
local gapRow=StepRow(orderPane,"ROW SPACING",349,"rowGap",1,0,12,function(v) return tostring(v).." px" end);

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
    if ChatFontNormal then edit:SetFontObject(ChatFontNormal) else edit:SetFont("Fonts\\FRIZQT__.TTF",11,"OUTLINE") end;
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


-- LOOK: four pages to prevent controls clipping at bottom of the menu.
local lookPane=pages.LOOK;local lookPage="layout";
local lookTabs={};local lookGroups={};
for i,k in ipairs({"layout","skins","frame","text","effects","bars"}) do
    local titles={layout="LAYOUT",skins="THEMES",frame="FRAME",text="TEXT",effects="FX",bars="BARS"};
    lookTabs[i]=Subpage(lookPane,titles[k],2+(i-1)*61,59,BindClick(k,function(which)
        lookPage=which;ABA.DB().lookPage=which;ABA.Update(true)
    end));
    lookTabs[i].txt:SetFont("Fonts\\FRIZQT__.TTF",9,"OUTLINE");
    local pane=CreateFrame("Frame",nil,lookPane);pane:SetPoint("TOPLEFT",lookPane,"TOPLEFT",0,-35);
    pane:SetWidth(368);pane:SetHeight(394);pane:Hide();lookGroups[k]=pane;
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
local scaleRow=StepRow(lay,"HUD SCALE",149,"scale",0.05,0.65,1.5,function(v) return tostring(math.floor(v*100+0.5)).."%" end);
local widthRow=StepRow(lay,"MANUAL WIDTH",203,"hudWidth",20,85,700,function(v) return tostring(math.floor(v+0.5)).." px" end,function(d) d.autoWidth=false end);
-- Direct XY positioning shares the same coordinate domain as mouse dragging.
-- Signed values are intentional: some AZS clients have a smaller virtual
-- UIParent area than the visible game window, so offsets can be negative.
Label(lay,"X  /  FROM LEFT",6,249,10,C.grey);
Label(lay,"Y  /  FROM TOP",190,249,10,C.grey);
local coordFields={};
local function CoordBox(axis,x)
    local box=CreateFrame("EditBox",nil,lay);
    box:SetWidth(78);box:SetHeight(25);
    box:SetPoint("TOPLEFT",lay,"TOPLEFT",x,-266);
    if ChatFontNormal then box:SetFontObject(ChatFontNormal)
    else box:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE") end
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
    local minus=DimButton(lay,"-",x,266,31,BindClick(axis,function(a)
        local dx,dy=0,0;
        if a=="x" then dx=-10 else dy=-10 end
        ABA.NudgeHud(dx,dy);ABA.Update(true)
    end));
    local plus=DimButton(lay,"+",x+133,266,31,BindClick(axis,function(a)
        local dx,dy=0,0;
        if a=="x" then dx=10 else dy=10 end
        ABA.NudgeHud(dx,dy);ABA.Update(true)
    end));
    xyMinus[axis]=minus;xyPlus[axis]=plus;
    coordFields[axis]=CoordBox(axis,x+44);
end
local layoutToggle=DimButton(lay,"EDIT LAYOUT: OFF",5,306,359,function()
    ABA.StopInteraction();local d=ABA.DB();d.editLayout=not d.editLayout;d.editMove=d.editLayout;d.editResize=d.editLayout;ABA.Update(true)
end);
local resetPosition=DimButton(lay,"RESET POSITION",5,343,174,function() ABA.ResetPosition();ABA.Update(true) end);
local resetSize=DimButton(lay,"RESET SIZE",189,343,175,function()
    local d=ABA.DB();d.scale=1;d.hudWidth=232;d.autoWidth=true;ABA.Update(true)
end);

local skinsPane=lookGroups.skins;
Label(skinsPane,"THEME  /  text colours follow each skin",5,2,10,C.gold);
local skinDefs={{"SHADOW","shadow"},{"GLASS","glass"},{"CLASSIC","classic"},{"BARE","bare"},{"ARCANE","arcane"},{"EMBER","ember"},{"EMERALD","emerald"},{"FROST","frost"},{"SOLAR","solar"},{"NEON","neon"}};
local skinButtons={};
for i,skin in ipairs(skinDefs) do
    local col=math.mod(i-1,2);local row=math.floor((i-1)/2);
    local b=Button(skinsPane,skin[1],177,58,BindClick(skin[2],function(name) ABA.DB().skin=name;ABA.Update(true) end));
    b:SetPoint("TOPLEFT",skinsPane,"TOPLEFT",4+col*184,-(62+row*66));
    b.txt:ClearAllPoints();b.txt:SetPoint("TOP",b,"TOP",0,-2);
    local c=skins[skin[2]] or skins.shadow;
    local pal=skinText[skin[2]] or skinText.shadow;
    b.skinTitle=skin[1];b.skinKey=skin[2];
    b.preview=b:CreateTexture(nil,"BACKGROUND");b.preview:SetTexture(WHITE);
    b.preview:SetPoint("TOPLEFT",b,"TOPLEFT",2,-20);b.preview:SetWidth(173);b.preview:SetHeight(36);
    b.preview:SetVertexColor(c[1],c[2],c[3],math.max(0.53,c[4]));
    for j,example in ipairs({{"dmg","2.4k"},{"cd","24%"},{"crit","20.6%"},{"cm","217%"}}) do
        local xpos=5+math.mod(j-1,2)*87;local ypos=j<=2 and 24 or 42;
        local icon=b:CreateTexture(nil,"ARTWORK");icon:SetTexture(MEDIA..example[1]..".tga");
        icon:SetWidth(13);icon:SetHeight(13);icon:SetPoint("TOPLEFT",b,"TOPLEFT",xpos,-ypos);
        local txt=Font(b,9,pal[1]);txt:SetPoint("LEFT",icon,"RIGHT",2,0);txt:SetText(example[2]);
    end
    b:SetScript("OnEnter",function()
        b.hover=true;PaintButton(b);
        Tip(b,b.skinTitle.." theme",{"Preview uses the same number colour as the live HUD.","The chosen accent can override the border.","Click to apply immediately."});
    end);
    b:SetScript("OnLeave",function() HideTip();b.hover=false;PaintButton(b) end);
    skinButtons[i]={btn=b,key=skin[2]};
end

-- FRAME: independent of the selected color theme. Choose actual HUD geometry.
local framePane=lookGroups.frame;
Label(framePane,"FRAME SHAPE  /  choose the silhouette",6,3,11,C.gold);
local frameKinds={{"FLOAT","float"},{"SOFT","soft"},{"BOX","box"},{"ROUND","round"}};
local frameButtons={};
for i,kind in ipairs(frameKinds) do
    local b=DimButton(framePane,kind[1],5+(i-1)*92,28,86,BindClick(kind[2],function(k)
        ABA.DB().frameKind=k;ABA.Update(true);
    end));frameButtons[i]={btn=b,key=kind[2]};
end
Label(framePane,"FLOAT = no background or border. SOFT = background only.",6,64,9,C.grey);
Label(framePane,"BOX = square outline. ROUND = rounded masked corners.",6,81,9,C.grey);
local padRow=StepRow(framePane,"INNER PADDING",116,"hudPadding",1,1,16,function(v) return tostring(v).." px" end);
local opacityRow=StepRow(framePane,"BACKGROUND OPACITY",182,"opacity",0.1,0.1,1,
    function(v) return tostring(math.floor(v*100+0.5)).."%" end);
local borderRow=StepRow(framePane,"BORDER THICKNESS  (ROUND)",248,"borderWidth",1,1,3,
    function(v) return tostring(v).." px" end);
Label(framePane,"ONE-CLICK HUD STYLE PRESETS",6,331,10,C.gold);
local hudStyles={{"COMPACT","compact"},{"READABLE","readable"},{"SHOWCASE","showcase"}};
local hudStyleButtons={};
for i,item in ipairs(hudStyles) do
    local btn=DimButton(framePane,item[1],5+(i-1)*123,349,116,BindClick(item[2],function(v)
        local d=ABA.DB();
        if v=="compact" then
            d.frameKind="float";d.hudPadding=2;d.statStyle="icons";d.iconGap=2;
            d.iconSize=16;d.fontSize=11;d.showMilestones=true;d.gaugeHeight=2;
            d.layoutMode="grid";d.columns=2;
        elseif v=="readable" then
            d.frameKind="round";d.hudPadding=8;d.opacity=0.95;
            d.iconSize=20;d.fontSize=13;d.iconGap=4;
            d.showMilestones=true;d.gaugeHeight=4;
        else
            d.frameKind="soft";d.hudPadding=10;d.opacity=0.85;
            d.iconSize=25;d.fontSize=15;d.iconGap=6;
            d.effectMode="normal";d.showMilestones=true;d.gaugeHeight=5;
            d.layoutMode="vertical";
        end
        ABA.Update(true)
    end));hudStyleButtons[i]=btn;
end

local textPane=lookGroups.text;
Label(textPane,"TYPE  /  icons, labels and numbers",6,5,11,C.gold);
Label(textPane,"LABEL STYLE",6,35,10,C.grey);
local styleButtons={};
for i,mode in ipairs({{"ICONS","icons"},{"TEXT","text"},{"BOTH","both"}}) do
    styleButtons[i]={btn=DimButton(textPane,mode[1],5+(i-1)*123,52,116,BindClick(mode[2],function(name) ABA.DB().statStyle=name;ABA.Update(true) end)),key=mode[2]};
end
local iconRow=StepRow(textPane,"ICON SIZE",98,"iconSize",2,14,32,function(v) return tostring(v).." px" end);
local fontRow=StepRow(textPane,"NUMBER SIZE",160,"fontSize",1,9,18,function(v) return tostring(v).." px" end);
local brightnessRow=StepRow(textPane,"ICON BRIGHTNESS",222,"iconBrightness",0.1,0.4,1,
    function(v) return tostring(math.floor(v*100+0.5)).."%" end);
local iconGapRow=StepRow(textPane,"ICON-TO-NUMBER GAP",284,"iconGap",1,1,12,function(v) return tostring(v).." px" end);
Label(textPane,"Numbers keep the palette of your selected theme.",6,361,10,C.grey);

local fx=lookGroups.effects;
Label(fx,"ANIMATION INTENSITY",7,4,11,C.gold);
Label(fx,"SUBTLE = gentle tint + 2px pulse. NORMAL = bolder + 3px.",7,20,9,C.grey);
local effectButtons={};
for i,info in ipairs({{"OFF","off"},{"SUBTLE","subtle"},{"NORMAL","normal"}}) do
    effectButtons[i]={btn=DimButton(fx,info[1],5+(i-1)*123,42,116,BindClick(info[2],function(mode) ABA.DB().effectMode=mode;ABA.Update(true) end)),key=info[2]};
end
Label(fx,"STAT GAINS",7,83,11,C.gold);
local deltaBtn=DimButton(fx,"SHOW PREVIOUS + GAIN",5,100,359,function() local d=ABA.DB();d.showDelta=not d.showDelta;ABA.Update(true) end);
local durationRow=StepRow(fx,"CHANGE PREVIEW DURATION",138,"deltaDuration",0.5,1,5,function(v) return string.format("%.1f sec",v) end);
local pulseBtn=DimButton(fx,"HEARTBEAT PULSE",5,207,176,function() local d=ABA.DB();d.pulse=not d.pulse;ABA.Update(true) end);
local glowBtn=DimButton(fx,"COLOUR FLASH",190,207,174,function() local d=ABA.DB();d.glow=not d.glow;ABA.Update(true) end);
Label(fx,"OTHER FEEDBACK",7,247,11,C.gold);
local milestoneBtn=DimButton(fx,"GOLD MILESTONE",5,270,176,function() local d=ABA.DB();d.milestoneFlash=not d.milestoneFlash;ABA.Update(true) end);
local spellCDBtn=DimButton(fx,"SPELL COOLDOWNS",190,270,174,function() local d=ABA.DB();d.spellCD=not d.spellCD;ABA.Update(true) end);
local spellDPSBtn=DimButton(fx,"SPELL DPS LABELS",5,308,359,function() local d=ABA.DB();d.spellDPS=not d.spellDPS;ABA.Update(true) end);
Label(fx,"Example: 25% +3.4%, then 28.4%.",7,353,10,C.grey);

-- BARS: dedicated visible control panel for crit, echo, haste, armor and speed.
local barsPane=lookGroups.bars;
Label(barsPane,"MILESTONE BARS  /  crit, haste, echo, armor, speed",6,4,10,C.gold);
local gaugeBtn=DimButton(barsPane,"MILESTONE BARS: ON",5,26,359,function()
    local d=ABA.DB();d.showMilestones=not d.showMilestones;ABA.Update(true)
end);
local barsReadyBtn=DimButton(barsPane,"VISIBLE ON READY SCREEN: ON",5,60,359,function()
    local d=ABA.DB();d.barsReady=not d.barsReady;ABA.Update(true)
end);
local gaugeHeightRow=StepRow(barsPane,"BAR THICKNESS",101,"gaugeHeight",1,2,7,function(v) return tostring(v).." px" end);
Label(barsPane,"BAR COLOUR",6,160,11,C.gold);
local gaugeColors={{"SMART","adaptive"},{"THEME","theme"},{"CYAN","cyan"},{"GREEN","green"},{"GOLD","gold"}};
local gaugeColorButtons={};
for i,item in ipairs(gaugeColors) do
    local btn=DimButton(barsPane,item[1],5+(i-1)*73,181,70,BindClick(item[2],function(v)
        ABA.DB().gaugeColor=v;ABA.Update(true)
    end));gaugeColorButtons[i]={btn=btn,key=item[2]};
end
Label(barsPane,"BAR PREVIEW  /  at the values shown below",6,225,10,C.grey);
local gaugePreviews={};
for i,item in ipairs({{"CRIT","25%",0.25},{"ECHO","76%",0.76},{"HASTE","45%",0.60},{"ARMOR","40%",0.67}}) do
    local y=248+(i-1)*28;
    local label=Label(barsPane,item[1].."  "..item[2],7,y,10,C.white);
    local track=barsPane:CreateTexture(nil,"ARTWORK");track:SetTexture(WHITE);
    track:SetWidth(207);track:SetHeight(4);track:SetPoint("TOPLEFT",barsPane,"TOPLEFT",153,-(y+8));
    track:SetVertexColor(0.18,0.31,0.39,0.85);
    local fill=barsPane:CreateTexture(nil,"OVERLAY");fill:SetTexture(WHITE);
    fill:SetPoint("LEFT",track,"LEFT",0,0);fill:SetHeight(4);fill:SetWidth(207*item[3]);
    gaugePreviews[i]={track=track,fill=fill};
end
Label(barsPane,"BARS only show for stats with a defined milestone.",6,365,9,C.grey);

-- Accent palettes now live within THEMES. Size/brightness live within TEXT.
local colorButtons={};
local accentDefs={{"DEFAULT","skin"},{"BLUE","blue"},{"TEAL","teal"},{"VIOLET","violet"},{"GOLD","amber"},{"ROSE","rose"},{"WHITE","white"}};
local skinAccentButtons={};
-- Small accent swatches above the theme preview cards.
for i,item in ipairs(accentDefs) do
    local btn=Button(skinsPane,item[1],49,20,BindClick(item[2],function(name) ABA.DB().accent=name;ABA.Update(true) end));
    btn:SetPoint("TOPLEFT",skinsPane,"TOPLEFT",5+(i-1)*52,-28);
    btn.txt:SetFont("Fonts\\FRIZQT__.TTF",8,"OUTLINE");
    colorButtons[i]={btn=btn,key=item[2]};
end

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
        item.btn.state:SetText(on and "ON" or "OFF");
        item.btn.state:SetTextColor(on and 0.47 or 0.52,on and 0.95 or 0.63,on and 0.69 or 0.70);
        item.btn.label:SetTextColor(on and 0.57 or 0.53,on and 0.97 or 0.62,on and 0.66 or 0.66);
    end
    for i=1,table.getn(presetButtons) do Selected(presetButtons[i].btn,d.activePreset==presetButtons[i].key) end
    local chosen={};for i=1,table.getn(ordered) do
        if ABA.IsEnabled(ordered[i]) then table.insert(chosen,ordered[i]) end
    end
    local maxPage=math.max(1,math.ceil(table.getn(chosen)/8));
    orderIndex=math.min(orderIndex,maxPage);
    orderPageLabel:SetText("Page "..orderIndex.." / "..maxPage);
    for i=1,8 do
        local r=orderRows[i];local spec=chosen[(orderIndex-1)*8+i];r.spec=spec;
        if spec then
            r.title:SetText(tostring((orderIndex-1)*8+i)..". "..spec.name);
            r.title:SetTextColor(currentText[1],currentText[2],currentText[3]);
            r.icon:SetTexture(MEDIA..spec.icon..".tga");
            Selected(r.ruleH,d.orderSeparators[spec.key]=="h");
            Selected(r.ruleV,d.orderSeparators[spec.key]=="v");
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
    showSpells.txt:SetText(d.spellVisible and "SPELL HUD: ON" or "SPELL HUD: OFF");
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
for i=1,table.getn(colorButtons) do
    Help(colorButtons[i].btn,accentDefs[i][1].." border",{"Changes border tint only.","The selected skin controls numbers and labels."});
end
for i=1,table.getn(orderRows) do
    local r=orderRows[i];
    Help(r.up,"Move up",{"Moves this tracked stat one position toward the top."});
    Help(r.down,"Move down",{"Moves this tracked stat one position toward the bottom."});
    Help(r.ruleH,"Horizontal rule",{"Draws a thin horizontal line after this HUD stat.","Click again to remove it."});
    Help(r.ruleV,"Vertical rule",{"Draws a vertical divider next to this HUD stat.","Click again to remove it."});
end
for i=1,table.getn(presetButtons) do
    Help(presetButtons[i].btn,ABA.presets[i].name,{"Choose a monitoring starting point.","This replaces the current selection but not the HUD style.","Use ORDER to change their visible sequence."});
end
local lookDescriptions={
 "Arrange columns, width, scale and the move/resize lock.",
 "Select a colour palette with live HUD number previews.",
 "Choose FLOAT (no border), SOFT, BOX or true rounded corners; adjust panel padding.",
 "Control icon and number sizes, brightness and the gap between them.",
 "Tune the gain preview, heartbeat, glow and spell labels.",
 "Enable and customize the crit, haste, echo, armor and speed milestone bars."
};
for i=1,table.getn(lookTabs) do
    Help(lookTabs[i],string.upper(({"layout","skins","frame","text","effects","bars"})[i]),{lookDescriptions[i]});
end
for i=1,table.getn(insightTabs) do
    Help(insightTabs[i].btn,({"Run summary","Damage performance","Stat history","About YNX"})[i],
        {({"Your current run and recently finished runs.","Damage from learned spells and observed proc sources.","Stat samples from the current run.","Created by Ynx. Tips and available commands."})[i]});
end
Help(pulseBtn,"Pulse",{"Briefly enlarges the changed value twice, like a heartbeat.","Subtle = +2px; Normal = +3px. The HUD itself never resizes."});
Help(deltaBtn,"Show gain before new total",{"Before: 25% crit. Upgrade: +3.4 percentage points.","Temporary text: 25% +3.4%. Then final: 28.4%.","Duration is adjustable. Requires a real stat change."});
for i=1,table.getn(effectButtons) do
    local info=({{"OFF","No highlights or movement."},{"SUBTLE","Soft green/red flash and a light 2px heartbeat."},
        {"NORMAL","Brighter, more noticeable flash and 3px heartbeat."}})[i];
    Help(effectButtons[i].btn,info[1],{info[2],"Gain preview duration is separately configurable."});
end
Help(glowBtn,"Value glow",{"Green for increases and red for decreases; a short fade-out.","No animation plays while Effects is OFF."});
Help(milestoneBtn,"Milestone flash",{"Uses a gold flash when crossing a supported milestone."});
Help(gaugeBtn,"Milestone bars",{"Shows real progress for Crit, Haste, Echo, Armor and Speed.","The bar represents a documented milestone or a chosen goal, not always a hard cap."});
Help(barsReadyBtn,"Bars on ready screen",{"Shows progress before a run starts, using numeric values the game provides.","If there is no real number, no progress bar is invented."});
for i,entry in ipairs(frameButtons) do
    local names={"FLOAT", "SOFT", "BOX", "ROUND"};
    local lines={
       {"No background or frame at all. Ideal for floating stat numbers."},
       {"Background panel without an outline. Clean and readable."},
       {"Original square panel with a hard edge."},
       {"Actual rounded alpha-mask corners with a curved outline."}
    };
    Help(entry.btn,names[i],lines[i]);
end
for i,btn in ipairs(hudStyleButtons) do
    local notes={
      {"Minimal floating numbers, small icons, slim bars, 2-column grid."},
      {"Rounded and readable: bigger text, opaque panel, visible bars."},
      {"Large vertical layout with vivid feedback and room to read."}
    };
    Help(btn,hudStyles[i][1].." HUD preset",{notes[i][1],"Changes appearance only, not your tracked stats."});
end
for i,entry in ipairs(gaugeColorButtons) do
    Help(entry.btn,("Bar colour: "..gaugeColors[i][1]),{"SMART adapts to milestones. THEME matches selected HUD text.","Other colours remain constant across all progress values."});
end
Help(spellCDBtn,"Cooldown labels",{"Show ability cooldown lengths on the HUD."});
Help(spellDPSBtn,"Damage per second",{"Show tracked spell run DPS under the icon."});
for _,step in ipairs({scaleRow,widthRow,iconRow,fontRow,opacityRow,gapRow,brightnessRow,durationRow,
    padRow,borderRow,iconGapRow,gaugeHeightRow}) do
    Help(step.minus,step.key,{"Decrease value. Changes preview immediately."});
    Help(step.plus,step.key,{"Increase value. Changes preview immediately."});
end
-- Dedicated refreshers stay below Lua 5.0's hard 32-upvalue limit.
local function RefreshFrameControls(d)
    for i=1,table.getn(frameButtons) do
        Selected(frameButtons[i].btn,d.frameKind==frameButtons[i].key)
    end
    for _,row in ipairs({padRow,borderRow,opacityRow}) do row.value:SetText(row.format(d[row.key])) end
end
local function RefreshBarsControls(d)
    for i=1,table.getn(gaugeColorButtons) do
        Selected(gaugeColorButtons[i].btn,d.gaugeColor==gaugeColorButtons[i].key)
    end
    TogglePaint(barsReadyBtn,d.barsReady);
    barsReadyBtn.txt:SetText("READY SCREEN BARS   |   "..(d.barsReady and "ON" or "OFF"));
    TogglePaint(gaugeBtn,d.showMilestones);
    gaugeBtn.txt:SetText("MILESTONE BARS   |   "..(d.showMilestones and "ON" or "OFF"));
    gaugeHeightRow.value:SetText(gaugeHeightRow.format(d.gaugeHeight));
    local pc={0.36,0.81,1};
    if d.gaugeColor=="theme" then pc=currentText
    elseif d.gaugeColor=="cyan" then pc={0.31,0.90,0.99}
    elseif d.gaugeColor=="gold" then pc={1,0.78,0.29}
    elseif d.gaugeColor=="green" then pc={0.25,0.94,0.62} end
    for i=1,table.getn(gaugePreviews) do
        local v=gaugePreviews[i];v.fill:SetHeight(d.gaugeHeight);
        v.track:SetHeight(d.gaugeHeight);
        v.fill:SetVertexColor(pc[1],pc[2],pc[3],1)
    end
end
local function RefreshTextAndEffects(d)
    for _,row in ipairs({iconRow,fontRow,brightnessRow,iconGapRow,durationRow}) do
        row.value:SetText(row.format(d[row.key]));
    end
    for i=1,3 do
        Selected(styleButtons[i].btn,d.statStyle==styleButtons[i].key);
        Selected(effectButtons[i].btn,d.effectMode==effectButtons[i].key);
    end
    local states={{deltaBtn,d.showDelta,"GAIN PREVIEW"},{pulseBtn,d.pulse,"HEARTBEAT PULSE"},
        {glowBtn,d.glow,"COLOUR FLASH"},{milestoneBtn,d.milestoneFlash,"GOLD MILESTONE"},
        {spellCDBtn,d.spellCD,"SPELL COOLDOWNS"},{spellDPSBtn,d.spellDPS,"SPELL DPS LABELS"}};
    for i=1,table.getn(states) do
        local v=states[i];TogglePaint(v[1],v[2]);v[1].txt:SetText(v[3].."   "..(v[2] and "ON" or "OFF"));
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
local function RefreshLookControls(d)
    lookPage=d.lookPage or lookPage;
    for i,key in ipairs({"layout","skins","frame","text","effects","bars"}) do
        if lookPage==key then lookGroups[key]:Show() else lookGroups[key]:Hide() end
        Selected(lookTabs[i],lookPage==key);
    end
    for i=1,3 do
        Selected(layoutModeButtons[i].btn,d.layoutMode==layoutModeButtons[i].key);
        Selected(colsButtons[i],d.columns==i);
    end
    TogglePaint(autoWidth,d.autoWidth);autoWidth.txt:SetText("AUTO WIDTH   |   "..(d.autoWidth and "ON" or "OFF"));
    TogglePaint(layoutToggle,d.editLayout);layoutToggle.txt:SetText("EDIT LAYOUT   |   "..(d.editLayout and "UNLOCKED" or "LOCKED"));
    scaleRow.value:SetText(scaleRow.format(d.scale));
    widthRow.value:SetText(widthRow.format(d.hudWidth));
    RefreshXYFields();
    for i=1,table.getn(skinButtons) do Selected(skinButtons[i].btn,d.skin==skinButtons[i].key) end
    for i=1,table.getn(colorButtons) do Selected(colorButtons[i].btn,d.accent==colorButtons[i].key) end
    RefreshFrameControls(d);RefreshBarsControls(d);RefreshTextAndEffects(d);
end
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
    if d.gaugeColor=="cyan" then return 0.31,0.90,0.99 end
    if d.gaugeColor=="green" then return 0.25,0.94,0.62 end
    if d.gaugeColor=="gold" then return 1,0.78,0.29 end
    if d.gaugeColor=="theme" then return currentText[1],currentText[2],currentText[3] end
    if info.kind=="HARD" and info.complete then return 1,0.39,0.37 end
    if info.complete then return 1,0.79,0.33 end
    return 0.36,0.81,1
end
local function Gauge(row,stat,width)
    local d=ABA.DB();
    local ready=ABA.Phase()=="ready";
    local info=d.showMilestones and (not ready or d.barsReady) and ABA.GetMilestone(stat.key) or nil;
    if not info then row.track:Hide();row.fill:Hide();row.marker:Hide();return end
    local length=math.max(25,width-3);local height=d.gaugeHeight;
    row.track:Show();row.fill:Show();row.track:SetWidth(length);row.track:SetHeight(height);
    row.track:SetVertexColor(currentSecondary[1]*0.48,currentSecondary[2]*0.48,currentSecondary[3]*0.48,0.90);
    row.fill:SetHeight(height);row.fill:SetWidth(math.max(1,length*info.progress));
    local r,g,b=GaugeTint(d,info);row.fill:SetVertexColor(r,g,b,1);
    if info.marker then
        row.marker:ClearAllPoints();row.marker:SetPoint("LEFT",row.track,"LEFT",length*info.marker,0);
        row.marker:SetHeight(math.max(5,height+2));row.marker:Show()
    else row.marker:Hide() end
end
local function RowWidth(row,spec,d)
    local size=d.iconSize;local width=4;
    if d.statStyle~="text" then width=width+size+3 end
    if d.statStyle=="both" or d.statStyle=="text" then width=width+WidthOf(row.name,string.len(spec.short)*6.6)+4 end
    width=width+WidthOf(row.value,string.len(ABA.DisplayValue(spec))*d.fontSize*0.67)+d.iconGap+6;
    return math.max(44,math.ceil(width));
end
local function StatLayout(list)
    local d=ABA.DB();local total=table.getn(list);local size=d.iconSize;
    local rowH=math.max(size,d.fontSize)+7+d.rowGap+(d.showMilestones and d.gaugeHeight+3 or 0);
    local pad=d.hudPadding;
    local requiredCell=50;
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];local spec=list[i];
        if spec then
            row.stat=spec;row.icon:SetTexture(MEDIA..spec.icon..".tga");row.icon:SetWidth(size);row.icon:SetHeight(size);
            local lum=d.iconBrightness;row.icon:SetVertexColor(lum,lum,lum,1);
            row.value:SetFont("Fonts\\FRIZQT__.TTF",d.fontSize,"OUTLINE");row.value:SetText(ABA.DisplayValue(spec));
            row.value:SetTextColor(currentText[1],currentText[2],currentText[3]);
            row.name:SetTextColor(currentSecondary[1],currentSecondary[2],currentSecondary[3]);
            row.name:SetText(spec.short);row.name:SetFont("Fonts\\FRIZQT__.TTF",math.max(9,d.fontSize-2),"OUTLINE");
            local required=RowWidth(row,spec,d);row.required=required;requiredCell=math.max(requiredCell,required);
        else row.stat=nil;row:Hide() end
    end
    local cols=1;
    if d.layoutMode=="grid" then cols=d.columns
    elseif d.layoutMode=="horizontal" then
        cols=math.max(1,math.floor((d.autoWidth and 440 or d.hudWidth-8)/(requiredCell+3)))
    end
    cols=math.max(1,math.min(total>0 and total or 1,cols));
    local cellW=requiredCell+3;
    local width;
    if d.autoWidth then width=math.max(54,cols*cellW+pad*2+2)
    else
        width=math.max(d.hudWidth,requiredCell+pad*2+2);
        if d.layoutMode=="horizontal" then
            cols=math.max(1,math.floor((width-8)/cellW));cols=math.min(total>0 and total or 1,cols)
        else
            cols=math.min(cols,math.max(1,math.floor((width-8)/cellW)))
        end
    end
    width=clamp(width,54,700);hud:SetWidth(width);hud:SetMinResize(85,24);
    -- Paint a compact grid. Content starts at x=4; number immediately follows the icon.
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];local spec=list[i];
        if spec then
            local col=math.mod(i-1,cols);local line=math.floor((i-1)/cols);
            row:SetWidth(cellW-1);row:SetHeight(rowH-1);row:ClearAllPoints();
            row:SetPoint("TOPLEFT",hud,"TOPLEFT",pad+col*cellW,-(pad+line*rowH));
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
            row.value:SetPoint("LEFT",anchor,pos,d.iconGap,0);
            Gauge(row,spec,cellW-3);
            local rule=d.orderSeparators[spec.key];
            row.hRule:Hide();row.vRule:Hide();
            if rule=="h" then
                row.hRule:ClearAllPoints();row.hRule:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",2,0);
                row.hRule:SetWidth(math.max(15,cellW-6));row.hRule:SetVertexColor(currentSecondary[1],currentSecondary[2],currentSecondary[3],0.9);row.hRule:Show();
            elseif rule=="v" then
                row.vRule:ClearAllPoints();row.vRule:SetPoint("TOPRIGHT",row,"TOPRIGHT",-1,-1);
                row.vRule:SetHeight(math.max(10,rowH-4));row.vRule:SetVertexColor(currentSecondary[1],currentSecondary[2],currentSecondary[3],0.90);row.vRule:Show();
            end
            row:Show();
        end
    end
    if total==0 then return width,0 end
    return width,math.ceil(total/cols)*rowH;
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
    hud:SetHeight(math.max(d.frameKind=="round" and 36 or 26,statH+spellH+procH+gap+pGap+d.hudPadding*2+2));hud:SetScale(d.scale);
    if not moveDrag then PutAt(posX,posY,false) end
    PositionHandles();ApplySkin();local justShown=not hud:IsShown();hud:Show();RefreshHandles();
    if justShown or lastPhase~=phase then Top(hud) end
    if settings:IsShown() then DockSettings();RefreshSettings() end
    lastPhase=phase;
end
-- Event-driven effects: value text grows briefly, not the frame or its hit area.
local lastFontState={};
local function AnimateRow(row,elapsed)
    if not row.stat then return end
    local d=ABA.DB();local x=ABA.statChanged[row.stat.key];local age=x and (GetTime()-x.at) or 999;
    local isUp=x and ((row.stat.kind=="cooldown" and x.after<x.before) or (row.stat.kind~="cooldown" and x.after>x.before));
    if not ABA.statsLive or d.effectMode=="off" or not x or age<0 or age>d.deltaDuration then
        if row.lastPulse~=0 then
            row.value:SetFont("Fonts\\FRIZQT__.TTF",d.fontSize,"OUTLINE");row.lastPulse=0;
        end
        row.value:SetTextColor(currentText[1],currentText[2],currentText[3]);row.flash:SetVertexColor(0.10,0.75,0.29,0);
        return
    end
    local extra=0;
    if d.pulse then
        if age<0.15 or (age>0.28 and age<0.43) then extra=d.effectMode=="normal" and 3 or 2 end
    end
    if row.lastPulse~=extra then row.value:SetFont("Fonts\\FRIZQT__.TTF",d.fontSize+extra,"OUTLINE");row.lastPulse=extra end
    local milestoneHit=false;
    if d.milestoneFlash and x then
        local before=ABA.GetMilestone and ABA.GetMilestone(row.stat.key,{[row.stat.key]=x.before});
        local after=ABA.GetMilestone and ABA.GetMilestone(row.stat.key,{[row.stat.key]=x.after});
        milestoneHit=before and after and not before.complete and after.complete;
    end
    if milestoneHit then row.value:SetTextColor(1,0.80,0.30)
    elseif isUp then row.value:SetTextColor(0.42,0.98,0.54)
    else row.value:SetTextColor(1.0,0.45,0.43) end
    if d.glow then
        local fade=math.max(0,1-age/d.deltaDuration)*(d.effectMode=="normal" and 0.28 or 0.13);
        if isUp then row.flash:SetVertexColor(0.12,0.90,0.36,fade)
        else row.flash:SetVertexColor(0.98,0.15,0.16,fade) end
    else row.flash:SetVertexColor(0.10,0.75,0.29,0) end
end
hud:SetScript("OnUpdate",function()
    local elapsed=arg1;
    if moveDrag then if not GestureTick(moveDrag,EndMove,elapsed) then MoveAtCursor() end end
    if resizeDrag then if not GestureTick(resizeDrag,EndResize,elapsed) then ResizeAtCursor() end end
    for i=1,table.getn(statWidgets) do
        local row=statWidgets[i];if row.stat and row:IsShown() then AnimateRow(row,elapsed) end
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
ABA.statSelect=statSelect;ABA.styleButtons=styleButtons;ABA.effectButtons=effectButtons;
ABA.layoutModeButtons=layoutModeButtons;ABA.colsButtons=colsButtons;ABA.colorButtons=colorButtons;
ABA.frameButtons=frameButtons;ABA.hudStyleButtons=hudStyleButtons;
ABA.gaugeColorButtons=gaugeColorButtons;ABA.barsReadyBtn=barsReadyBtn;
ABA.gaugeBtn=gaugeBtn;ABA.roundedParts=roundedParts;ABA.gaugePreviews=gaugePreviews;
ABA.utilityButtons={};ABA.slotButtons=slotButtons;ABA.orderRows=orderRows;ABA.sectionButtons=tabButtons;
ABA.insightLines=insightLines;
SelectTab("STATS");
