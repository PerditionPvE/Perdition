---@class ShopMenu
ShopMenu = {}

---@param player IsoPlayer
---@param context ISContextMenu
---@param worldobjects KahluaTable
---@param test boolean
ShopMenu.doShopMenu = function(player, context, worldobjects, test)
    local player = getSpecificPlayer(player)
    local square = player:getSquare()
    local region = square:getIsoWorldRegion()
    local room = square:getRoom()
    if room ~= nil or region:isPlayerRoom() then
        local option = context:addOption("Shop", worldobjects, nil)
        local submenu = ISContextMenu:getNew(context)
        context:addSubMenu(option, submenu)
        local setup = submenu:addOption("Setup Shop", worldobjects, ShopMenu.setupShop, player, region)
    end
end

ShopMenu.setupShop = function(worldobjects, player, region)
    local shop = Shop:new(player, region, false)
end

function sendShopMenu(worldobjects, player)
    print(ShopUI)
    local ui = ShopUI:new(50, 50, 500, 150, player)
    ui:initialise()
    ui:addToUIManager()
end
Events.OnFillWorldObjectContextMenu.Add(ShopMenu.doShopMenu)