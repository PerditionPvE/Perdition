require "ISBuildingObject"
---@class Shop : ISBuildingObject
Shop = ISBuildingObject:derive("Shop")

---@param owner IsoPlayer the creator of the shop
---@param type string select from Room, Hawk, Dispenser
---@param region IsoWorldRegion the region the shop is part of, only used by Room types
---@param isAdmin boolean is this shop only editable by admins?
function Shop:new(owner, type, region, isAdmin)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.type = type
    o.owner = owner
    o.region = region
    o.isAdmin = isAdmin
    o.register = nil
    o.stockpiles = {}
    o.displays = {}
    o.sellItems = {} -- items that show in the BUY tab
    o.buyItems = {} -- items that show in the SELL tab
    o.permissions = {
        editItemListing = {
            factionAllowed = false,
            whitelist = {}
        },
        takeMoney = {
            factionAllowed = false,
            whitelist = {}
        },
        takeFromStockpiles = {
            factionAllowed = false,
            whitelist = {}
        },
        registerCashier = {
            factionAllowed = false,
            whitelist = {}
        },
        registerStockpile = {
            factionAllowed = false,
            whitelist = {}
        },
        createDisplay = {
            factionAllowed = false,
            whitelist = {}
        },
    }
    return o
    -- TODO write metavalues for a shop and define player vs admin
end


---@param player IsoPlayer can the player edit this?
---@param permission string name of the permission to check
function Shop:hasPermission(player, permission)
    local ownerFaction = Faction.getPlayerFaction(self.owner)
    local playerFaction = Faction.getPlayerFaction(player)
    -- check if player is owner
    if player == self.owner then return true; end
    -- check if player in same faction
    if (self.permissions[permission].factionAllowed
    and playerFaction == ownerFaction) then
        return true
    end
    -- check if player in whitelist
    for _, p in ipairs(self.permissions[permission].whitelist) do
        if p == player then return true; end
    end
    return false
end

---@param player IsoPlayer the player trying to add the item
---@param item Item
---@param price int the cost in dollars of the item
function Shop:addBuyItem(player, item, price)
    -- cancel if player lacks permissions
    if not self:hasPermission(player, "editItemListing") then return; end
    -- check if item is not in listing
    for i,_ in pairs(self.buyItems) do
        if i == item then return; end
    end
    table.insert(self.buyItems, {item = item, cost = price or 0})
end

---@param player IsoPlayer the player trying to add the item
---@param item Item
function Shop:removeBuyItem(player, item)
    if not self:hasPermission(player, "editItemListing") then return; end
    for index, listing in ipairs(self.buyItems) do
        if listing.item == item then
            table.remove(self.buyItems, index)
        end
    end
end

