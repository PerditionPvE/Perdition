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
        },
        counter = {
            rolls = 4,
            items = {
                "Battery", 2,
                "BatteryPack4", 1,
                "BatteryPack8", 1,
                "BatteryPack12", 0.7,
                "BatteryPack16", 0.4,
                "ACDCAdapter", 0.2,
                "BluePen", 8,
                "Book", 10,
                "Eraser", 6,
                "Magazine", 10,
                "Notebook", 10,
                "Paperclip", 20,
                "PaperclipBox", 0.1,
                "Pen", 8,
                "Pencil", 20,
                "RedPen", 8,
                "RubberBand", 6,
                "SheetPaper2", 20,
            },
            junk = {
                rolls = 1,
                items = {
                    "Glue", 2,
                    "HandTorch", 4,
                    "Radio.RadioBlack", 2,
                    "Radio.RadioRed", 1,
                    "Radio.WalkieTalkie2", 1,
                    "Radio.WalkieTalkie3", 0.5,
                    "Scissors", 2,
                    "Scotchtape", 2,
                    "Torch", 2,
                }
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