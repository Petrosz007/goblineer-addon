if string.find(goblineer_data, "bonusIds") == nil then
    ChatFrame1:AddMessage("[Goblineer]: Your updater app is out of date, please download the latest version of the \"Goblineer-updater\" from https://github.com/Petrosz007/goblineer-updater/releases")
end

local formatted = json.decode("[" .. goblineer_data .. "]")
local cache = {}

function tablelength(T)
    if T == nil then
        return 0
    else
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    end
  end

local function write_tooltip(tooltip, item)
    -- If the item was not found in the marketvalues file, skip writing the tooltip
    if item["empty"] then
        return
    end

    local itemCount = goblineer_itemCount 

    if(IsShiftKeyDown() and itemCount ~= nil) then
        goblineer_minPrice = tonumber(item["MIN"]) * itemCount
        goblineer_mvPrice = tonumber(item["marketvalue"]) * itemCount
    else 
        goblineer_minPrice = tonumber(item["MIN"])
        goblineer_mvPrice = tonumber(item["marketvalue"])                    
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

    tooltip:AddDoubleLine("     Quantity", item["quantity"], 0, 1, 1,     255/255, 215/255, 0/255)
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

local function findInCache(itemID)
    -- Starting from the end, so the latest item will be found first => most of the time the item currently hovered over
    for i = tablelength(cache), 1, -1 
    do 
        if itemID == tostring(cache[i]["item"]) then
            return i
        end
    end

    return 0
end

local function findInCacheWithBonus(itemID, bonusIDs)
    -- Starting from the end, so the latest item will be found first => most of the time the item currently hovered over
    for i = tablelength(cache), 1, -1 
    do 
        if itemID == tostring(cache[i]["item"]) and bonusIdsMatch(cache[i]["bonusIds"], bonusIDs) then
            return i
        end
    end

    return 0
end


local lineAdded = false
local function OnTooltipSetItem(tooltip, ...)
	if not lineAdded then
        local _, itemLink = tooltip:GetItem()

        -- GetItem() can return nil, i.e. for recipe tooltips
        if not itemLink then
            lineAdded = true
            return
        end

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

            
            local cacheLocation = findInCacheWithBonus(itemID, bonusIDs)
            if not cacheLocation == 0 then

                write_tooltip(tooltip, cache[cacheLocation])

            else
                local found = false
                for i = 1,tablelength(formatted),1 
                do 
                    if itemID == tostring(formatted[i]["item"]) and bonusIdsMatch(formatted[i]["bonusIds"], bonusIDs) then

                        write_tooltip(tooltip, formatted[i])
                        table.insert(cache, formatted[i])

                        found = true
                        break

                    end
                end

                if not found then
                    tmp = {}
                    tmp["item"] = itemID
                    tmp["bonusIds"] = bonusIDs
                    tmp["empty"] = true
                    table.insert(cache, tmp)
                end
            end

            
            lineAdded = true
            
        else
            local cacheLocation = findInCache(itemID)
            if not cacheLocation == 0 then

                write_tooltip(tooltip, cache[cacheLocation])

            else
                local found = false
                for i = 1,tablelength(formatted),1 
                do 
                    if itemID == tostring(formatted[i]["item"]) then

                        write_tooltip(tooltip, formatted[i])
                        table.insert(cache, formatted[i])

                        break

                    end
                end

                if not found then
                    tmp = {}
                    tmp["item"] = itemID
                    tmp["bonusIds"] = bonusIDs
                    tmp["empty"] = true
                    table.insert(cache, tmp)
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
