require 'Items/ProceduralDistributions'
local function preDistributionMerge()
    local PerditionDistributions = {
        LibraryBooks = {
            rolls = 2,
            items = {
                "Perdition.AxeUpgradeManual", 1,
                "Perdition.CrowbarUpgradeManual", 1,
                "Perdition.KatanaUpgradeManual", 1,
                "Perdition.PickaxeUpgradeManual", 1,
                "Perdition.MacheteUpgradeManual", 1,
                "Perdition.KnifeUpgradeManual", 1,
                "Perdition.SHammerUpgradeManual", 1,
                "Perdition.CleaverUpgradeManual", 1,
                "Perdition.ShovelUpgradeManual", 1,
                }
         GigamartHouseElectronics = {
            rolls = 2,
            items = {
                "Battery", 2,
                "BatteryPack4", 1,
                "BatteryPack8", 1,
                "BatteryPack12", 0.8,
                "BatteryPack4", 0.5,
                }
            },
        }
    }
    for roomDef, list in pairs(PerditionDistributions) do
        -- if not ProceduralDistributions.list[roomDef] then ProceduralDistributions.list[roomDef] = {}; end
        for _, value in ipairs(list.items) do
            print("Inserting " .. value)
            table.insert(ProceduralDistributions.list[roomDef].items, value)
        end
    end
end

Events.OnPreDistributionMerge.Add(preDistributionMerge)
