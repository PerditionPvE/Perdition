require "recipecode"
---@class Perdition
Perdition = {}
Perdition.OnCreate = {}
Perdition.GetItemTypes = {}

local function addExistingItemType(scriptItems, type)
    local all = getScriptManager():getItemsByType(type)
    for i=1,all:size() do
        local scriptItem = all:get(i-1)
        if not scriptItems:contains(scriptItem) then
            scriptItems:add(scriptItem)
        end
    end
end

function Perdition.OnCreate.DismantleCarBattery(items, result, player)
    player:getInventory():AddItem("Radio.ElectricWire")
    player:getInventory():AddItem("Base.UnusableMetal")
end

function Perdition.OnCreate.Masterwork(items, result, player)
    local condPerc = ZombRand(50 + (player:getPerkLevel(Perks.Blacksmith) * 5), 80 + (player:getPerkLevel(Perks.Blacksmith) * 2));
    result:setCondition(round(result:getCondition() * (condPerc/100)))
end

function Perdition.GetItemTypes.Sack(scriptItems)
    scriptItems:addAll(getScriptManager():getItemsTag("HoldDirt"))
    addExistingItemType(scriptItems, "EmptySandbag")
end


function Perdition.GetItemTypes.Jewelry(scriptItems)
    local items = getScriptManager():getAllItems()
    for i=0, items:size()-1 do
        local item = items:get(i)
        if string.contains(item:getName(), "Watch")
        or string.contains(item:getName(), "Gold")
        or string.contains(item:getName(), "Silver")
        or string.contains(item:getName(), "Earring")
        then
            if item:isCosmetic() then
                scriptItems:add(item)
            end
        end
    end
end
-- definitions
DismantleCarBattery_OnCreate = Perdition.OnCreate.DismantleCarBattery