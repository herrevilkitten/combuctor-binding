local CombuctorSet = Combuctor:GetModule("Sets")
local L = {}
L.Binding = "Binding"
L.All = "All"
L.Account = "Account"
L.Equip = "On Equip"
L.Use = "On Use"
L.Pickup = "On Pickup"
L.Soulbound = "Soulbound"

local tooltipCache = setmetatable({}, {__index = function(t, k) local v = {} t[k] = v return v end})
local tooltipScanner = _G['LibItemSearchTooltipScanner'] or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')
--
-- Copied pretty much wholesale from LibItemSearch 1.2
-- 
local function link_FindSearchInTooltip(itemLink, search, bag, slot)
    local itemID = itemLink:match('item:(%d+)')
    if not itemID then
		return false
    end

    local cachedResult = tooltipCache[search][itemID]
    if cachedResult ~= nil then
		return cachedResult
    end

    tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
	tooltipScanner:SetBagItem(bag, slot)

	if _G[tooltipScanner:GetName() .. 'TextLeft1']:GetText() == nil then
		return false
	end
		
    local result = false
    if tooltipScanner:NumLines() > 1 and _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText() == search then
		result = true
    elseif tooltipScanner:NumLines() > 2 and _G[tooltipScanner:GetName() .. 'TextLeft3']:GetText() == search then
		result = true
    elseif tooltipScanner:NumLines() > 3 and _G[tooltipScanner:GetName() .. 'TextLeft4']:GetText() == search then
		result = true
    elseif tooltipScanner:NumLines() > 4 and _G[tooltipScanner:GetName() .. 'TextLeft5']:GetText() == search then
		result = true
    elseif tooltipScanner:NumLines() > 5 and _G[tooltipScanner:GetName() .. 'TextLeft6']:GetText() == search then
		result = true
    end

	tooltipCache[search][itemID] = result
	return result
end

local function isBindToAccount(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_BIND_TO_BNETACCOUNT, bag, slot)
		or link_FindSearchInTooltip(link, ITEM_BNETACCOUNTBOUND, bag, slot)
		or link_FindSearchInTooltip(link, ITEM_BIND_TO_ACCOUNT, bag, slot)
		or link_FindSearchInTooltip(link, ITEM_ACCOUNTBOUND, bag, slot)
end

local function isBindOnEquip(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_BIND_ON_EQUIP, bag, slot) and not link_FindSearchInTooltip(link, ITEM_SOULBOUND, bag, slot)
end

local function isBindOnUse(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_BIND_ON_USE, bag, slot) and not link_FindSearchInTooltip(link, ITEM_SOULBOUND, bag, slot)
end

local function isBindOnPickup(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_BIND_ON_PICKUP, bag, slot)
end

local function isSoulbound(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_SOULBOUND, bag, slot)
end

local function isBinding(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
    if not link then
        return false
    end
    return isBindToAccount(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
		or isBindOnEquip(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
		or isBindOnUse(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
		or isSoulbound(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc, bag, slot)
end

CombuctorSet:Register(L.Binding, "Interface/Icons/Achievement_Reputation_ArgentChampion", isBinding);
CombuctorSet:RegisterSubSet(L.All, L.Binding);
CombuctorSet:RegisterSubSet(L.Account, L.Binding, nil, isBindToAccount);
CombuctorSet:RegisterSubSet(L.Equip, L.Binding, nil, isBindOnEquip);
CombuctorSet:RegisterSubSet(L.Use, L.Binding, nil, isBindOnUse);
CombuctorSet:RegisterSubSet(L.Soulbound, L.Binding, nil, isSoulbound);
