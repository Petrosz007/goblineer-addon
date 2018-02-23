local formatted = json.decode("[" .. goblineer_data .. "]")

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

local lineAdded = false
local function OnTooltipSetItem(tooltip, ...)
	if not lineAdded then
		local name = tooltip:GetItem()
        
        for i = 1,tablelength(formatted),1 
        do 
            if name == formatted[i]["name"] then
                local itemCount = goblineer_itemCount 

                if(IsShiftKeyDown() and itemCount ~= nil) then
                    goblineer_minPrice = tonumber(formatted[i]["MIN"]) * itemCount
                    goblineer_mvPrice = tonumber(formatted[i]["marketvalue"]) * itemCount
                else 
                    goblineer_minPrice = tonumber(formatted[i]["MIN"])
                    goblineer_mvPrice = tonumber(formatted[i]["marketvalue"])                    
                end

                local min_split = {}
                local min = string.format("%.2f", goblineer_minPrice)
                for w in (min .. "."):gmatch("([^.]*).") do 
                    table.insert(min_split, w) 
                end
                
                local min_gold = "|cFFFFD700" .. min_split[1] .."|r"
                local min_silver = "|cFFC0C0C0" .. min_split[2] .. "|r"




                local mv_split = {}
                local mv = string.format("%.2f", goblineer_mvPrice)
                for w in (mv .. "."):gmatch("([^.]*).") do 
                    table.insert(mv_split, w) 
                end

                local mv_gold = "|cFFFFD700" .. mv_split[1] .."|r"
                local mv_silver = "|cFFC0C0C0" .. mv_split[2] .. "|r"



                    tooltip:AddLine("   ")
                    tooltip:AddLine("Goblineer data:", 58/255, 141/255, 244/255, true)

                    if(IsShiftKeyDown() and itemCount ~= 0) then
                        tooltip:AddDoubleLine("     Min Price |cFFC0C0C0x" .. itemCount .. "|r", min_gold .. "." .. min_silver, 0, 1, 1)
                        tooltip:AddDoubleLine("     Marketvalue |cFFC0C0C0x" .. itemCount .. "|r", mv_gold .. "." .. mv_silver, 0, 1, 1)
                    else
                        tooltip:AddDoubleLine("     Min Price", min_gold .. "." .. min_silver, 0, 1, 1)
                        tooltip:AddDoubleLine("     Marketvalue", mv_gold .. "." .. mv_silver, 0, 1, 1)
                    end

                    tooltip:AddDoubleLine("     Quantity", formatted[i]["quantity"], 0, 1, 1,     255/255, 215/255, 0/255)
                    tooltip:AddLine("   ")

                end
            end

        lineAdded = true
	end
end

local function OnTooltipCleared(tooltip, ...)
   lineAdded = false
end

hooksecurefunc (GameTooltip, "SetBagItem",
    function(tip, whichbag, whichslot)
        goblineer_texture, goblineer_itemCount, goblineer_locked, goblineer_quality, goblineer_readable = GetContainerItemInfo(whichbag, whichslot)
    end
)
 
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)