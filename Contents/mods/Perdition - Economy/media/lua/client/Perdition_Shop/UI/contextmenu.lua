---@class ShopMenu
ShopMenu = {}
local shop = nil

---@param player IsoPlayer
---@param context KahluaTable
---@param worldobjects KahluaTable
---@param test boolean
ShopMenu.doShopMenu = function(player, context, worldobjects, test)
    player = getSpecificPlayer(player)
    local square = player:getSquare()
    local region = square:getIsoWorldRegion()
    if region:isEnclosed() then
        shop = Shop.find(square)
        local option = context:addOption("Shop", worldobjects, nil)
        local submenu = ISContextMenu:getNew(context)
        context:addSubMenu(option, submenu)
        if not shop then
            local setup = submenu:addOption("Setup Shop", nil, ShopMenu.setupShop, player, region)
        else
            if shop:getRegister() ~= nil then
                local register = shop:getRegister()
                local goToRegister = submenu:addOption("Go to Register", nil, ShopMenu.goToRegister, player, building)
                if shop:hasPermission(player, "setStockpile") then
                    local addStockpileOption = submenu:addOption("Add to Stockpiles", worldobjects, nil)
                    local stockpileContainer = submenu;getNew(submenu)
                    context:addSubMenu(addStockpileOption, stockpileContainer)
                    for _, object in pairs(worldobjects) do
                        local container = object:getContainer()
                        if container
                        and not instanceof(object, 'IsoDeadBody')
                        and not instanceof(object, 'IsoCompost')
                        and not instanceof(object, 'Clothing')
                        and container:getID() ~= register:getID()
                        then
                            local moveprops = ISMoveableSpriteProps.fromObject(object)
                            stockpileContainer:addOption(moveprops.name, {object}, ShopMenu.onSetStockpile) -- stockpile list
                        end
                    end
                end
            end
            if shop.owner == player:getUsername() then
                local addRegisterOption = submenu:addOption("Set as Register", worldobjects, nil)
                local registerContainer = submenu:getNew(submenu)
                context:addSubMenu(addRegisterOption, registerContainer)
                for _, object in pairs(worldobjects) do
                    local container = object:getContainer()
                    if container
                    and not instanceof(object, "IsoDeadBody")
                    and not instanceof(object, "IsoCompost")
                    and not instanceof(object, "Clothing")
                    then
                        local moveprops = ISMoveableSpriteProps.fromObject(object)
                        registerContainer:addOption(moveprops.name, {object}, ShopMenu.onSetRegister) -- register list
                    end
                end
            end
        end
    end
end

ShopMenu.goToRegister = function(_, player, building)
    for room_id, _ in pairs(building.rooms) do
        local containers = building:getContainers(room_id)
        for _, container in pairs(containers) do
            -- container is the IsoObject that has the containers
            local modData = container:getModData()
            if modData["ShopID"] ~= nil then
                if modData['ShopComponent'] == Shop.component.core then
                    luautils.walkToContainer(container, getSpecificPlayer(player))
                    break
                end
            end
        end
    end
end

ShopMenu.onSetRegister = function(worldobjects)
    if worldobjects and shop then
        local object = worldobjects[1]
        shop:setRegister(object)
        print('Register set')
    end
end

ShopMenu.onSetStockpile = function(worldobjects)
    if worldobjects and shop then
        local object = worldobjects[1]
        shop:setStockpile(object)
        print('Stockpile set')
    end
end

ShopMenu.setupShop = function(worldobjects, player, region)
    shop = Shop:new(player)
    shop:save()
end

function sendShopMenu(worldobjects, player)
    print(ShopMenu)
    local ui = ShopMenu:new(50, 50, 500, 150, player)
    ui:initialise()
    ui:addToUIManager()
end
Events.OnFillWorldObjectContextMenu.Add(ShopMenu.doShopMenu)