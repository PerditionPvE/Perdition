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

function Perdition.GetItemTypes.Sack(scriptItems)
    scriptItems:addAll(getScriptManager():getItemsTag("HoldDirt"))
end

-- definitions
DismantleCarBattery_OnCreate = Perdition.OnCreate.DismantleCarBattery