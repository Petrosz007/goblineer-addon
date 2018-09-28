local formatted = json.decode("[" .. goblineer_data .. "]")

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

local function write_tooltip(tooltip, i)
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

local function bonusIdsMatch(one, two)
    if tablelength(one) == tablelength(two) then

        for i = 1, tablelength(one), 1
        do
            if not (tonumber(one[i]) == tonumber(two[i])) then
                return false
            end
        end
        
        return true

    else
        return false
    end
end


local lineAdded = false
local function OnTooltipSetItem(tooltip, ...)
	if not lineAdded then
        local name, itemLink = tooltip:GetItem()

        --gets the item ID and bonus IDs of the item
        local _, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, 
        suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, instanceDifficultyID, numBonusIDs = strsplit(":", itemLink)

        

        if not (numBonusIDs == "") then 
            local tempString, unknown1, unknown2, unknown3 = strmatch(itemLink, "item:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:([-:%d]+):([-%d]-):([-%d]-):([-%d]-)|")
            local bonusIDs, upgradeValue
            if upgradeTypeID and upgradeTypeID ~= "" then
                upgradeValue = tempString:match("[-:%d]+:([-%d]+)")
                bonusIDs = {strsplit(":", tempString:match("([-:%d]+):"))}
            else
                bonusIDs = {strsplit(":", tempString)}
            end


            for i = 1,tablelength(formatted),1 
            do 
                if itemID == tostring(formatted[i]["item"]) and bonusIdsMatch(formatted[i]["bonusIds"], bonusIDs) then

                    write_tooltip(tooltip, i)

                end
            end

            lineAdded = true
        else
            for i = 1,tablelength(formatted),1 
            do 
                if itemID == tostring(formatted[i]["item"]) then
                    write_tooltip(tooltip, i)
                end
            end
            lineAdded = true
        end
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



--It can show the ID of items in the bag, but only in the bag
--Work In Progress
-- function DisplayItemID(self)
--     local id = GetContainerItemID(self:GetParent():GetID(), self:GetID())
--     print(id)
-- end

-- for i=1, 13 do --MAX_CONTAINER_FRAMES
--     for j=1, 36 do --MAX_CONTAINER_ITEMS
--         _G["ContainerFrame"..i.."Item"..j]:HookScript("OnEnter", DisplayItemID)
--     end
-- end