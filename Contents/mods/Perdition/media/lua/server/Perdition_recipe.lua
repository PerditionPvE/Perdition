---@class Perdition
Perdition = {}
Perdition.OnCreate = {}

function Perdition.OnCreate.DismantleCarBattery(items, result, player)
    player:getInventory():AddItem("Radio.ElectricWire")
    player:getInventory():AddItem("Base.UnusableMetal")
end

-- definitions
DismantleCarBattery_OnCreate = Perdition.OnCreate.DismantleCarBattery