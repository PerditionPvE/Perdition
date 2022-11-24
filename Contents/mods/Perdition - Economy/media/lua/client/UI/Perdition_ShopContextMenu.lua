---@class idk
idk = {}

---@param player IsoPlayer
---@param context ISContextMenu
---@param worldobjects table
---@param test boolean
idk.doShopMenu = function(player, context, worldobjects, test)
    local player = getSpecificPlayer(player)
    local square = player:getSquare()
    local region = square:getIsoWorldRegion()
    local room = square:getRoom()
    if room ~= nil or region:isPlayerRoom() then
        local option = context:addOption("Shop", worldobjects, nil)
        local submenu = ISContextMenu:getNew(context)
        context:addSubMenu(option, submenu)
        local addOption = submenu:addOption("Setup Shop", worldobjects, sendShopMenu, player)
    end
end

function sendShopMenu(worldobjects, player)
    local ui = ShopUI:new(50, 50, 500, 150, player)
    ui:initialise()
    ui:addToUIManager()
end
Events.OnFillWorldObjectContextMenu.Add(idk.doShopMenu)