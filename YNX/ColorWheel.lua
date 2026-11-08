-- YNX colour wheel for Azeroth Survivors (WoW 1.12 / Lua 5.0).
-- Independent of modern Blizzard ColorPicker APIs and other UI addons.
-- Call ABA.OpenYNXColorWheel(hex, onChange, onCancel).
local WHITE="Interface\\Buttons\\WHITE8X8";
local MEDIA="Interface\\AddOns\\YNX\\Media\\UI\\";
local function Clamp(v) return math.max(0,math.min(1,v)) end
local function HSVtoRGB(h,s,v)
    h=h-math.floor(h);s=Clamp(s);v=Clamp(v);
    local k=math.floor(h*6);local f=h*6-k;
    local p=v*(1-s);local q=v*(1-f*s);local t=v*(1-(1-f)*s);
    k=math.mod(k,6);
    if k==0 then return v,t,p elseif k==1 then return q,v,p elseif k==2 then return p,v,t
    elseif k==3 then return p,q,v elseif k==4 then return t,p,v end
    return v,p,q;
end
local function RGBtoHSV(r,g,b)
    local maxc=math.max(r,g,b);local minc=math.min(r,g,b);local diff=maxc-minc;
    local s=maxc==0 and 0 or diff/maxc;
    local h=0;
    if diff>0 then
        if maxc==r then h=(g-b)/diff;if h<0 then h=h+6 end
        elseif maxc==g then h=(b-r)/diff+2
        else h=(r-g)/diff+4 end
        h=h/6;
    end
    return h,s,maxc;
end
local function ToHex(r,g,b)
    return string.format("%02X%02X%02X",math.floor(Clamp(r)*255+0.5),math.floor(Clamp(g)*255+0.5),math.floor(Clamp(b)*255+0.5));
end
local function HexRGB(s)
    if type(s)~="string" then return nil end
    s=string.gsub(s,"#","");
    if string.len(s)~=6 or string.find(s,"[^%x]") then return nil end
    return tonumber(string.sub(s,1,2),16)/255,tonumber(string.sub(s,3,4),16)/255,tonumber(string.sub(s,5,6),16)/255;
end
local function Text(frame,content,size)
    local font=frame:CreateFontString(nil,"OVERLAY");
    font:SetFont("Fonts\\FRIZQT__.TTF",size or 12,"OUTLINE");
    font:SetText(YNX_L(content));YNX_RegisterFont(font,content);font:SetTextColor(0.90,0.95,1);return font;
end
local function PickerButton(parent,caption,x,y,w,onClick)
    local b=CreateFrame("Button",nil,parent);b:SetWidth(w);b:SetHeight(29);
    b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y);
    b:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});
    b:SetBackdropColor(0.06,0.17,0.25,0.98);b:SetBackdropBorderColor(0.27,0.72,0.87,0.94);
    local t=Text(b,caption,12);t:SetPoint("CENTER",b,"CENTER",0,0);
    b:RegisterForClicks("LeftButtonUp");b:SetScript("OnClick",onClick);
    return b;
end
local picker=CreateFrame("Frame","YNX_ColorWheel",UIParent);
picker:SetWidth(368);picker:SetHeight(430);picker:SetFrameStrata("TOOLTIP");picker:SetFrameLevel(250);
picker:SetPoint("CENTER",UIParent,"CENTER",0,0);picker:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=2});
picker:SetBackdropColor(0.018,0.045,0.079,1);picker:SetBackdropBorderColor(0.25,0.76,0.91,1);
picker:Hide();
local heading=Text(picker,"CHOOSE A COLOUR",17);heading:SetPoint("TOPLEFT",picker,"TOPLEFT",19,-17);
local instruction=Text(picker,"Click or drag the wheel, then adjust brightness.",11);
instruction:SetPoint("TOPLEFT",picker,"TOPLEFT",19,-48);
local ring=CreateFrame("Button",nil,picker);ring:SetWidth(256);ring:SetHeight(256);
ring:SetPoint("TOPLEFT",picker,"TOPLEFT",19,-76);ring:RegisterForDrag("LeftButton");ring:RegisterForClicks("LeftButtonUp");
local art=ring:CreateTexture(nil,"ARTWORK");art:SetAllPoints(ring);art:SetTexture(MEDIA.."color_wheel.tga");
local cursor=ring:CreateTexture(nil,"OVERLAY");cursor:SetTexture(WHITE);cursor:SetWidth(8);cursor:SetHeight(8);
cursor:SetVertexColor(0.05,0.11,0.17,1);
local brightness=CreateFrame("Button",nil,picker);brightness:SetWidth(28);brightness:SetHeight(256);
brightness:SetPoint("TOPLEFT",picker,"TOPLEFT",293,-76);brightness:RegisterForDrag("LeftButton");
local gradient=brightness:CreateTexture(nil,"ARTWORK");gradient:SetAllPoints(brightness);gradient:SetTexture(MEDIA.."brightness_gradient.tga");
local brightnessMarker=brightness:CreateTexture(nil,"OVERLAY");brightnessMarker:SetTexture(WHITE);brightnessMarker:SetWidth(34);brightnessMarker:SetHeight(3);
brightnessMarker:SetVertexColor(1,0.76,0.26,1);
local preview=picker:CreateTexture(nil,"ARTWORK");preview:SetTexture(WHITE);
preview:SetPoint("TOPLEFT",picker,"TOPLEFT",19,-345);preview:SetWidth(54);preview:SetHeight(29);
local label=Text(picker,"HEX",11);label:SetPoint("LEFT",preview,"RIGHT",12,0);
local hex=CreateFrame("EditBox",nil,picker);hex:SetAutoFocus(false);hex:SetWidth(104);hex:SetHeight(28);
hex:SetPoint("LEFT",label,"RIGHT",9,0);hex:SetFont("Fonts\\FRIZQT__.TTF",13,"OUTLINE");hex:SetMaxLetters(7);
hex:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});hex:SetBackdropColor(0.03,0.11,0.16,1);
hex:SetBackdropBorderColor(0.25,0.59,0.72,1);
if hex.SetTextInsets then hex:SetTextInsets(5,2,0,0) end
local cancel=PickerButton(picker,"CANCEL",19,387,156,function() picker:Hide();if picker.cancelCallback then picker.cancelCallback() end end);
local done=PickerButton(picker,"USE COLOUR",187,387,162,function() picker:Hide() end);
local hue,saturation,value=0,1,1;
local function Redraw(fire)
    local r,g,b=HSVtoRGB(hue,saturation,value);
    local angle=hue*math.pi*2;local px=math.cos(angle)*saturation*119;local py=math.sin(angle)*saturation*119;
    cursor:ClearAllPoints();cursor:SetPoint("CENTER",ring,"BOTTOMLEFT",128+px,128+py);
    brightnessMarker:ClearAllPoints();brightnessMarker:SetPoint("CENTER",brightness,"BOTTOM",14,256*value);
    preview:SetVertexColor(r,g,b,1);art:SetVertexColor(value,value,value,1);
    hex:SetText("#"..ToHex(r,g,b));
    if fire and picker.changeCallback then picker.changeCallback(ToHex(r,g,b)) end
end
local function WheelPointer()
    local x,y=GetCursorPosition();local scale=ring:GetEffectiveScale() or 1;
    if not x then return end
    local left=ring:GetLeft();local bottom=ring:GetBottom();if not left or not bottom then return end
    local dx=x/scale-left-128;local dy=y/scale-bottom-128;
    local radius=math.sqrt(dx*dx+dy*dy);saturation=Clamp(radius/119);
    local a=0;
    if dx>0 then a=math.atan(dy/dx)
    elseif dx<0 and dy>=0 then a=math.atan(dy/dx)+math.pi
    elseif dx<0 and dy<0 then a=math.atan(dy/dx)-math.pi
    elseif dy>0 then a=math.pi/2
    elseif dy<0 then a=-math.pi/2 end
    hue=math.mod(a/(2*math.pi)+1,1);Redraw(true);
end
local function BrightnessPointer()
    local x,y=GetCursorPosition();local scale=brightness:GetEffectiveScale() or 1;
    local bottom=brightness:GetBottom();if not y or not bottom then return end
    value=Clamp((y/scale-bottom)/256);Redraw(true);
end
local activeDrag=nil;
ring:SetScript("OnMouseDown",function() WheelPointer();activeDrag="wheel" end);
ring:SetScript("OnMouseUp",function() WheelPointer();activeDrag=nil end);
ring:SetScript("OnDragStart",function() activeDrag="wheel" end);
ring:SetScript("OnDragStop",function() WheelPointer();activeDrag=nil end);
brightness:SetScript("OnMouseDown",function() BrightnessPointer();activeDrag="brightness" end);
brightness:SetScript("OnMouseUp",function() BrightnessPointer();activeDrag=nil end);
brightness:SetScript("OnDragStart",function() activeDrag="brightness" end);
brightness:SetScript("OnDragStop",function() BrightnessPointer();activeDrag=nil end);
picker:SetScript("OnUpdate",function()
    if activeDrag=="wheel" then WheelPointer() elseif activeDrag=="brightness" then BrightnessPointer() end
end);
picker:SetScript("OnHide",function() activeDrag=nil end);
hex:SetScript("OnEnterPressed",function()
    local r,g,b=HexRGB(hex:GetText());
    if r then hue,saturation,value=RGBtoHSV(r,g,b);Redraw(true);hex:ClearFocus()
    else hex:SetText("#"..ToHex(HSVtoRGB(hue,saturation,value)));hex:ClearFocus() end
end);
hex:SetScript("OnEscapePressed",function() hex:ClearFocus();Redraw(false) end);
function ABA.OpenYNXColorWheel(originalHex,onChange,onCancel)
    local r,g,b=HexRGB(originalHex);
    if not r then r,g,b=1,1,1 end
    hue,saturation,value=RGBtoHSV(r,g,b);
    picker.changeCallback=onChange;picker.cancelCallback=onCancel;
    Redraw(false);picker:Show();
    return picker;
end
