---@class PerditionBuildMenu
PerditionBuildMenu = {}
PerditionBuildMenu.canDoSomething = false

local weldingRodUses = ISBlacksmithMenu.weldingRodUses
local getItemNameFromFullType = getItemNameFromFullType

local function predicateWeldingMask(item) --from ISBlacksmithMenu.lua
    return item:hasTag("WeldingMask") or item:getType() == "WeldingMask"
end

local function predicateScrewdriver(item)
    return item:hasTag("Screwdriver") or item:getType() == "Screwdriver"
end

local function predicateHammer(item)
    return item:hasTag("Hammer") or item:getType() == "Hammer"
end

function PerditionBuildMenu.addToolTip(option, name, texture)
    local toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip = toolTip;
    toolTip:setName(name);
    toolTip.description = getText("Tooltip_craft_Needs") .. ": ";
    toolTip:setTexture(texture);
    toolTip.footNote = getText("Tooltip_craft_pressToRotate", Keyboard.getKeyName(getCore():getKey("Rotate building")))
    return toolTip;
end


local function getGreenOvenSprite()
    local sprite = {}
    sprite.sprite = "appliances_cooking_01_0"
    sprite.north = "appliances_cooking_01_1"
    sprite.east  = "appliances_cooking_01_2"
    sprite.south = "appliances_cooking_01_3"
    return sprite
end

local function getModernOvenSprite()
    local sprite = {}
    sprite.sprite = "appliances_cooking_01_12"
    sprite.north = "appliances_cooking_01_13"
    sprite.east = "appliances_cooking_01_14"
    sprite.south = "appliances_cooking_01_15"
    return sprite
end

local function getGrayOvenSprite()
    local sprite = {}
    sprite.sprite = "appliances_cooking_01_4"
    sprite.north  = "appliances_cooking_01_5"
    sprite.east   = "appliances_cooking_01_6"
    sprite.south  = "appliances_cooking_01_7"
    return sprite
end

PerditionBuildMenu.doBuildMenu = function(playerID, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    if test then return ISWorldObjectContextMenu.setTest() end

    if getCore():getGameMode()=="LastStand" then
        return;
    end

    local player = getSpecificPlayer(playerID)
    local inv = player:getInventory()

    local engineerOption = context:addOption("Engineering", worldobjects, nil)
    local submenu = ISContextMenu:getNew(context)
    context:addSubMenu(engineerOption, submenu)
    local ovenOption = submenu:addOption("Ovens", worldobjects, nil)
    local subMenuOven = submenu:getNew(submenu)
    context:addSubMenu(ovenOption, subMenuOven)
    -- ovens

    local ovenGreenOption = subMenuOven:addOption("Green Oven", worldobjects, PerditionBuildMenu.onStove, player, getGreenOvenSprite(), "Green Oven", "2")
    local toolTip = PerditionBuildMenu.addToolTip(ovenGreenOption, "Green Oven", "appliances_cooking_01_0")
    local hasElectricalParts, toolTip = PerditionBuildMenu.checkElectricalMaterials(player, toolTip, {electronicsScrap=10, copperWire=4})
    local hasMetalWeldingParts, toolTip = PerditionBuildMenu.checkMetalWeldingMaterials(player, toolTip, {metalSheet=4, hinge=1})
    local hasTools, toolTip = PerditionBuildMenu.checkTools(player, toolTip, 1, true, false, false)
    local hasSkills, toolTip = PerditionBuildMenu.checkSkillRequirement(player, toolTip, {metalworking=4, electrical=4})
    if not (hasElectricalParts and hasMetalWeldingParts and hasTools and hasSkills) then ovenGreenOption.notAvailable = true end

    local ovenGrayOption = subMenuOven:addOption("Gray Oven", worldobjects, PerditionBuildMenu.onStove, player, getGrayOvenSprite(), "Gray Oven", "2")
    local toolTip = PerditionBuildMenu.addToolTip(ovenGrayOption, "Gray Oven", "appliances_cooking_01_4")
    local hasElectricalParts, toolTip = PerditionBuildMenu.checkElectricalMaterials(player, toolTip, {electronicsScrap=10, copperWire=4})
    local hasMetalWeldingParts, toolTip = PerditionBuildMenu.checkMetalWeldingMaterials(player, toolTip, {metalSheet=4, hinge=1})
    local hasTools, toolTip = PerditionBuildMenu.checkTools(player, toolTip, 1, true, false, false)
    local hasSkills, toolTip = PerditionBuildMenu.checkSkillRequirement(player, toolTip, {metalworking=4, electrical=4})
    if not (hasElectricalParts and hasMetalWeldingParts and hasTools and hasSkills) then ovenGrayOption.notAvailable = true end

    local ovenModernOption = subMenuOven:addOption("Modern Oven", worldobjects, PerditionBuildMenu.onStove, player, getModernOvenSprite(), "Modern Oven", "2")
    local toolTip = PerditionBuildMenu.addToolTip(ovenGrayOption, "Gray Oven", "appliances_cooking_01_4")
    local hasElectricalParts, toolTip = PerditionBuildMenu.checkElectricalMaterials(player, toolTip, {electronicsScrap=10, copperWire=4})
    local hasMetalWeldingParts, toolTip = PerditionBuildMenu.checkMetalWeldingMaterials(player, toolTip, {metalSheet=4, hinge=1})
    local hasTools, toolTip = PerditionBuildMenu.checkTools(player, toolTip, 1, true, false, false)
    local hasSkills, toolTip = PerditionBuildMenu.checkSkillRequirement(player, toolTip, {metalworking=4, electrical=4})
    if not (hasElectricalParts and hasMetalWeldingParts and hasTools and hasSkills) then ovenGrayOption.notAvailable = true end
end

---@param player IsoPlayer
---@param toolTip ISToolTip
---@param torchUse int: the use delta of the blowtorch item
---@param needsScrewdriver boolean
---@param needsHammer boolean
---@param needsSaw boolean
PerditionBuildMenu.checkTools = function(player, toolTip, torchUse, needsScrewdriver, needsHammer, needsSaw)
    local isOk = true
    local inv = player:getInventory()
    -- blowtorch searching, from ISBlacksmithMenu.lua <function> ISBlacksmithMenu.checkMetalWeldingFurnitures
    local blowTorch = inv:getFirstTypeRecurse("Base.BlowTorch")
    local blowTorchUseLeft = inv:getUsesTypeRecurse("Base.BlowTorch")
    if ISBlacksmithMenu.groundItemUses["Base.BlowTorch"] then
        blowTorchUseLeft = blowTorchUseLeft + ISBlacksmithMenu.groundItemUses["Base.BlowTorch"]
        local maxUses = 0
        local blowTorchGround = nil
        for _,item2 in ipairs(ISBlacksmithMenu.groundItems["Base.BlowTorch"]) do
            if item2:getDrainableUsesInt() > maxUses then
                blowTorchGround = item2
                maxUses = item2:getDrainableUsesInt()
            end
        end
        blowTorch = blowTorch or blowTorchGround
    end

    -- check if blowtorch has enough uses
    if torchUse > 0 then
        if blowTorch then
            if blowTorchUseLeft > torchUse then
                toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse;
            else
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse;
                isOk = false
            end
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " 0" .. "/" .. torchUse;
            isOk = false
        end

        -- check if have enough welding rods
        local rodUse = ISBlacksmithMenu.weldingRodUses(torchUse)
        local rods = ISBlacksmithMenu.getMaterialUses(player, "Base.WeldingRods")
        if rodUse > 0 then
            if rods > rodUse then
                toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.WeldingRods") .. " " .. getText("ContextMenu_Uses") .. " " .. rods .. "/" .. rodUse
            else
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingRods") .. " " .. getText("ContextMenu_Uses") .. " " .. rods .. "/" .. rodUse
                isOk = false
            end
        end
        if inv:containsEvalRecurse(predicateWeldingMask) then
            toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " 1/1" ;
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " 0/1" ;
            isOk = false
        end
    end

    if needsScrewdriver then
        if inv:containsEvalRecurse(predicateScrewdriver) then
            toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Screwdriver") .. " 1/1"
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Screwdriver") .. " 0/1"
            isOk = false
        end
    end

    if needsHammer then
        if inv:containsEvalRecurse(predicateHammer) then
            toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Hammer") .. " 1/1"
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Hammer") .. " 0/1"
            isOk = false
        end
    end
    -- with each if statement my sanity drops
    if needsSaw then
        print("you literally don't need a saw for anything fuck you")
    end

    return isOk, toolTip
end

---@param player IsoPlayer
---@param toolTip ISToolTip
---@param materials table: ElectricWire, ElectronicsScrap, Lightbulb, Amplifier, Aluminum, Screws are valid items
PerditionBuildMenu.checkElectricalMaterials = function(player, toolTip, materials)
    local copperWire, electronicsScrap, light, amplifier, aluminum, screws =
    materials.copperWire or 0,
    materials.electronicsScrap or 0,
    materials.light or 0,
    materials.amplifier or 0,
    materials.aluminum or 0,
    materials.screws or 0

    local isOk = true
    local namerefs = {
        {copperWire, "Radio", "ElectricWire"},
        {electronicsScrap, "Base", "ElectronicsScrap"},
        {light, "Base", "Lightbulb"},
        {aluminum, "Base", "Aluminum"},
        {amplifier, "Base", "Amplifier"},
        {screws, "Base", "Screws"}
    }

    for _, group in ipairs(namerefs) do
        local req, module, name = unpack(group)
        if req > 0 then
            local count = ISBlacksmithMenu.getMaterialCount(player, name) or 0
            local thing = string.format("<LINE> <RGB:0,1,0> %s %s/%s", getItemNameFromFullType(module .. "." .. name), count, req)
            print(thing)
            if count >= req then
                print(getItemNameFromFullType(module .. "." .. name) .. " " .. count .. "/" .. req)
                toolTip.description = toolTip.description .. thing
            else
                toolTip.description = toolTip.description .. thing
                isOk = false
            end
        end

    end
    return isOk, toolTip
end

---@param player IsoPlayer
---@param toolTip ISToolTip
---@param materials table: lmao
PerditionBuildMenu.checkMetalWeldingMaterials = function(player, toolTip, materials)
    local metalPipes, smallMetalSheet, metalSheet, hinge, scrapMetal, metalBar, wire =
    materials.metalPipes or 0,
    materials.smallMetalSheet or 0,
    materials.metalSheet or 0,
    materials.hinge or 0,
    materials.scrapMetal or 0,
    materials.metalBar or 0,
    materials.wire or 0;
    local nameref = {
        {metalPipes, "Base", "MetalPipe"},
        {smallMetalSheet, "Base", "SmallSheetMetal"},
        {metalSheet, "Base", "SheetMetal"},
        {hinge, "Base", "Hinge"},
        {scrapMetal, "Base", "ScrapMetal"},
        {metalBar, "Base", "MetalBar"},
        {wire, "Base", "Wire"}
    }

    local isOk = true
    for _, group in ipairs(nameref) do
        local req, module, name = unpack(group)
        if req > 0 then
            local count = ISBlacksmithMenu.getMaterialCount(player, name)
            local thing = getItemNameFromFullType(module .. "." .. name) .. " " .. count .. "/" .. req
            print(thing)
            if count >= req then
                toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. thing
            else
                isOk = false
                toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. thing
            end
        end
    end
    return isOk, toolTip
end
PerditionBuildMenu.checkSkillRequirement = function(player, toolTip, skills)
    local carpentry, farming, firstaid, electrical, metalworking, mechanics, tailoring =
    skills.carpentry or 0,
    skills.farming or 0,
    skills.firstaid or 0,
    skills.electrical or 0,
    skills.metalworking or 0,
    skills.mechanics or 0,
    skills.tailoring or 0
    local isOk = true
    if carpentry > 0 then
        if player:getPerkLevel(Perks.WoodWork) >= carpentry then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_WoodWork") .. " " .. player:getPerkLevel(Perks.WoodWork) .. "/" .. carpentry
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_WoodWork") .. " " .. player:getPerkLevel(Perks.WoodWork) .. "/" .. carpentry
            isOk = false
        end
    end
    if farming > 0 then
        if player:getPerkLevel(Perks.Farming) >= farming then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Farming") .. " " .. player:getPerkLevel(Perks.Farming) .. "/" .. farming
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Farming") .. " " .. player:getPerkLevel(Perks.Farming) .. "/" .. farming
            isOk = false
        end
    end
    if firstaid > 0 then
        if player:getPerkLevel(Perks.Doctor) >= firstaid then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Doctor") .. " " .. player:getPerkLevel(Perks.Doctor) .. "/" .. firstaid
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Doctor") .. " " .. player:getPerkLevel(Perks.Doctor) .. "/" .. firstaid
            isOk = false
        end
    end
    if electrical > 0 then
        if player:getPerkLevel(Perks.Electricity) >= electrical then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Electricity") .. " " .. player:getPerkLevel(Perks.Electricity) .. "/" .. electrical
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Electricity") .. " " .. player:getPerkLevel(Perks.Electricity) .. "/" .. electrical
            isOk = false
        end
    end
    if metalworking > 0 then
        if player:getPerkLevel(Perks.MetalWelding) >= metalworking then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. metalworking
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. metalworking
            isOk = false
        end
    end
    if mechanics > 0 then
        if player:getPerkLevel(Perks.Mechanics) >= mechanics then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Mechanics") .. " " .. player:getPerkLevel(Perks.Mechanics) .. "/" .. mechanics
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Mechanics") .. " " .. player:getPerkLevel(Perks.Mechanics) .. "/" .. mechanics
            isOk = false
        end
    end
    if tailoring > 0 then
        if player:getPerkLevel(Perks.Tailoring) >= tailoring then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Tailoring") .. " " .. player:getPerkLevel(Perks.Tailoring) .. "/" .. tailoring
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Tailoring") .. " " .. player:getPerkLevel(Perks.Tailoring) .. "/" .. tailoring
            isOk = false
        end
    end
    return isOk, toolTip
end
-- oncraft methods
PerditionBuildMenu.onStove = function(worldobjects, player, sprite, name, torchUse)
    local stove = ISStove:new(name, sprite)
    stove.firstItem = "BlowTorch"
    stove.secondItem = "WeldingMask"
    stove.modData["xp:MetalWelding"] = 30
    stove.modData["need:Base.ElectronicsScrap"] = "10"
    stove.modData["need:Base.ElectricWire"] = "4"
    stove.modData["need:Base.SheetMetal"] = "4"
    stove.modData["need:Base.Hinge"] = "1"
    stove.modData["use:Base.BlowTorch"] = torchUse
    stove.modData["use:Base.WeldingRods"] = ISBlacksmithMenu.weldingRodUses(torchUse)
    stove.player = player
    getCell():setDrag(stove, player)
end

Events.OnFillWorldObjectContextMenu.Add(PerditionBuildMenu.doBuildMenu)