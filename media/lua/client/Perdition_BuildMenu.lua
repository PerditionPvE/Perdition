---@class PerditionBuildMenu
PerditionBuildMenu = {}
PerditionBuildMenu.canDoSomething = false

local function predicateWeldingMask(item) --from ISBlacksmithMenu.lua
    return item:hasTag("WeldingMask") or item:getType() == "WeldingMask"
end

Perdition.doBuildMenu = function(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    player = getSpecificPlayer(player) -- gets the specific player this argument is from
    local inv = player:getInventory()

    if playerObj:getVehicle() then return; end -- checks to make sure the player is not in a car

    if (inv:containsTypeRecurse("BlowTorch") and inv:containsEvalRecurse(predicateWeldingMask)) or ISBuildMenu.cheat then
        local weldingMenu = context:addOption("Perdition Welding", worldobjects, nil)
        local subWM = ISContextMenu:getNew(context)
        context:addSubMenu(weldingMenu, subWM)
        local keepMenu = true
        local furnitureOption = subWM:getNew(context)
    end
end

PerditionBuildMenu.checkSkillRequirement = function(player, toolTip, meta)
    setmetatable(meta, {__index={carpentry = 0, farming = 0, firstaid=0, electrical=0, metalworking=0, mechanics=0, tailoring=0}})
    local carpentry, farming, firstaid, electrical, metalworking, mechanics, tailoring =
    meta[1] or meta.carpentry,
    meta[2] or meta.farming,
    meta[3] or meta.firstaid,
    meta[4] or meta.electrical,
    meta[5] or meta.metalworking,
    meta[6] or meta.mechanics,
    meta[7] or meta.tailoring

    local checks = {}
    if carpentry > 0 then
        if player:getPerkLevel(Perks.WoodWork) >= carpentry then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_WoodWork") .. " " .. player:getPerkLevel(Perks.WoodWork) .. "/" .. carpentry
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_WoodWork") .. " " .. player:getPerkLevel(Perks.WoodWork) .. "/" .. carpentry
        end
    end
    if farming > 0 then
        if player:getPerkLevel(Perks.Farming) >= farming then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Farming") .. " " .. player:getPerkLevel(Perks.Farming) .. "/" .. farming
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Farming") .. " " .. player:getPerkLevel(Perks.Farming) .. "/" .. farming
        end
    end
    if firstaid > 0 then
        if player:getPerkLevel(Perks.Doctor) >= firstaid then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Doctor") .. " " .. player:getPerkLevel(Perks.Doctor) .. "/" .. firstaid
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Doctor") .. " " .. player:getPerkLevel(Perks.Doctor) .. "/" .. firstaid
        end
    end
    if electrical > 0 then
        if player:getPerkLevel(Perks.Electricity) >= electrical then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Electricity") .. " " .. player:getPerkLevel(Perks.Electricity) .. "/" .. electrical
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Electricity") .. " " .. player:getPerkLevel(Perks.Electricity) .. "/" .. electrical
        end
    end
    if metalworking > 0 then
        if player:getPerkLevel(Perks.MetalWelding) >= metalworking then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. metalworking
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. metalworking
        end
    end
    if mechanics > 0 then
        if player:getPerkLevel(Perks.Mechanics) >= mechanics then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Mechanics") .. " " .. player:getPerkLevel(Perks.Mechanics) .. "/" .. mechanics
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Mechanics") .. " " .. player:getPerkLevel(Perks.Mechanics) .. "/" .. mechanics
        end
    end
    if tailoring > 0 then
        if player:getPerkLevel(Perks.Tailoring) >= tailoring then
            toolTip.description = toolTip.description .. "<LINE> <RGB:0,1,0> " .. getText("IGUI_perks_Tailoring") .. " " .. player:getPerkLevel(Perks.Tailoring) .. "/" .. tailoring
        else
            toolTip.description = toolTip.description .. "<LINE> <RGB:1,0,0> " .. getText("IGUI_perks_Tailoring") .. " " .. player:getPerkLevel(Perks.Tailoring) .. "/" .. tailoring
        end
    end

    checks.append(player:getPerkLevel(Perks.WoodWork) >= carpentry)
    checks.append(player:getPerkLevel(Perks.Farming) >= farming)
    checks.append(player:getPerkLevel(Perks.Doctor) >= firstaid)
    checks.append(player:getPerkLevel(Perks.Electricity) >= electrical)
    checks.append(player:getPerkLevel(Perks.MetalWelding) >= metalworking)
    checks.append(player:getPerkLevel(Perks.Mechanics) >= mechanics)
    checks.append(player:getPerkLevel(Perks.Tailoring) >= tailoring)

    for _, val in ipairs(checks) do
        if not val then
            return false
        end
    end
    return true
end

PerditionBuildMenu.checkWeldingMaterials = function(player, torchUse)
    -- from ISBlacksmithMenu L613
    local inv = player:getInventory();
    local isOk = true;
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
    if blowTorch then
        if torchUse > 0 then
            if blowTorchUseLeft >= torchUse then
                hasUsableTorch = true
            end
        end
    end
    local rodUse = ISBlacksmithMenu.weldingRodUses(torchUse)
    local weldingRods = ISBlacksmithMenu.getMaterialUses(player, "Base.WeldingRods")
    local enoughWeldingRods = false
    if rodUse > 0 then
        if weldingRods >= rodUse then
            enoughWeldingRods = true
        end
    end
    -- local weldingMask = ISBlacksmithMenu.getMaterialCount(player, "WeldingMask")
    if not inv:containsEvalRecurse(predicateWeldingMask) then
        local weldingMask = 0
        isOk = false;
    else
        local weldingMask = 1
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.WeldingMask") .. " " .. weldingMask .. "/1" ;
    end
end

PerditionBuildMenu.checkMetalMaterials = function(player, meta)
    setmetatable(meta, {__index={metalPipes=0, smallMetalSheet=0, metalSheet=0, hinge=0, scrapMetal=0, wire=0, metalBar=0}})
    local metalPipes, smallMetalSheet, metalSheet, hinge, scrapMetal, wire, metalBar =
    meta[1] or meta.metalPipes,
    meta[2] or meta.smallMetalSheet,
    meta[3] or meta.metalSheet,
    meta[4] or meta.hinge,
    meta[5] or meta.scrapMetal,
    meta[6] or meta.wire,
    meta[7] or meta.metalBar

    local inv = player:getInventory()
    local blowTorch = inv:getFirstTypeRecurse("Base.BlowTorch")
    local blowTorchUsesLeft = inv:getUseTypesRecurse("Base.BlowTorch")

    -- copy/pasted from ISBlacksmithMenu.lua because this is too much work
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
    if blowTorch then
        if torch > 0 then
            if torch > blowTorchUsesLeft then
                
            end
        end
    end
end