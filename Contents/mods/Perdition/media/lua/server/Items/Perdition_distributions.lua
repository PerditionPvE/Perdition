local function preDistributionMerge()
    local PerditionDistributions = {
        LibraryBooks = {
            rolls = 2,
            items = {
                "AxeUpgradeManual", 1,
                "CrowbarUpgradeManual", 1,
                "KatanaUpgradeManual", 1,
                "PickaxeUpgradeManual", 1,
                "MacheteUpgradeManual", 1,
                "KnifeUpgradeManual", 1,
                "SHammerUpgradeManual", 1,
                "CleaverUpgradeManual", 1,
                "ShovelUpgradeManual", 1,
            }
        }
    }
    for roomDef, list in pairs(PerditionDistributions) do
        if not ProceduralDistributions.list[roomDef] then ProceduralDistributions.list[roomDef] = {}; end
        for key, value in pairs(list) do
            -- overwrite the roll multiplier
            if key == "rolls" then ProceduralDistributions.list[roomDef].rolls = value; end
            -- update the list
            if type(value) == type({}) then
                for _, v in ipairs(value) do
                    table.insert(ProceduralDistributions.list[roomDef][key][value], v)
                end
            end
        end
    end
end

Events.OnPreDistributionMerge.Add(preDistributionMerge)