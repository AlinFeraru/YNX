-- YNX visual layout items: stat rows plus user-inserted separator/spacer items.
-- All helper functions are public on ABA to keep the WoW 1.12/Lua 5.0
-- main chunk and individual function upvalue counts low.
function ABA.ExtraAfter(key)
    local d=ABA.DB(); local el=d.layoutExtras and d.layoutExtras[key];
    return type(el)=="table" and el or nil
end
function ABA.SetExtraAfter(key,kind)
    local d=ABA.DB();if type(d.layoutExtras)~="table" then d.layoutExtras={} end
    if kind=="separator" or kind=="columnSeparator" or kind=="spacer" then d.layoutExtras[key]={kind=kind}
    else d.layoutExtras[key]=nil end
    if ABA.Update then ABA.Update(true) end
end
function ABA.SequenceForStats(stats)
    local list={};
    for i=1,table.getn(stats) do
        local s=stats[i]; table.insert(list,{kind="stat",stat=s,key=s.key});
        local extra=ABA.ExtraAfter(s.key);
        if extra and (extra.kind=="separator" or extra.kind=="columnSeparator" or extra.kind=="spacer") then
            table.insert(list,{kind=extra.kind,after=s.key});
        end
    end
    return list
end
function ABA.StatGeometry(stats,cols,cellW,rowH,pad,colGap)
    local positions={};local extras={};
    local col=0;local yy=pad; local d=ABA.DB();
    for i=1,table.getn(stats) do
        local s=stats[i];positions[i]={x=pad+col*(cellW+colGap),y=yy};
        col=col+1;
        if col>=cols then yy=yy+rowH;col=0 end
        local el=ABA.ExtraAfter(s.key);
        if el and el.kind=="columnSeparator" then
            -- A full-height column divider is a layout element, not a tiny
            -- rule attached to one stat row. It doesn't consume a row.
            if cols>1 then
                local previous=col==0 and cols-1 or col-1;
                local boundary=math.min(cols-1,previous+1);
                table.insert(extras,{kind="columnSeparator",after=s.key,
                    x=pad+boundary*cellW+(boundary-0.5)*colGap,height=0})
            end
        elseif el and (el.kind=="separator" or el.kind=="spacer") then
            if col~=0 then yy=yy+rowH;col=0 end
            local height=el.kind=="separator" and (d.separatorBefore+d.separatorAfter+math.max(1,d.separatorThickness)) or d.spacerHeight;
            table.insert(extras,{kind=el.kind,after=s.key,y=yy,height=height});
            yy=yy+height
        end
    end
    if col>0 then yy=yy+rowH end
    return positions,extras,yy+pad+2
end
function ABA.ColorFromHex(s)
    if type(s)~="string" then return nil end
    local h=string.gsub(s,"#","");
    if string.len(h)~=6 or string.find(h,"[^0-9a-fA-F]") then return nil end
    local n=tonumber(h,16);if not n then return nil end
    return math.floor(n/65536)/255,math.mod(math.floor(n/256),256)/255,math.mod(n,256)/255
end
function ABA.ManualColor(which)
    local d=ABA.DB();if not d.manualColorsEnabled or type(d.manualColors)~="table" then return nil end
    local r,g,b=ABA.ColorFromHex(d.manualColors[which]);
    if r then return {r,g,b} end
    return nil
end
