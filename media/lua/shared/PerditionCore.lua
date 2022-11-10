
---@class Perdition
Perdition = {}
Perdition.OnCreate = {}

function Perdition.OnCreate.DismantleCarBattery(items, result, player)
    for i=1, items:size() do
        local item = items:get(i-1)
        if item:getType() == "CarBattery" then
            player:getInventory():addItem("Base.ElectronicsScrap")
            player:getInventory():addItem("Radio.ElectricWire")
            break
        end
    end
end
