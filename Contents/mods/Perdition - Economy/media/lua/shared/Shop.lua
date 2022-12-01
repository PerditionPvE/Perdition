---@class Shop
Shop = {}
Shop.list = {}
Shop.directory = "perdition/shops"
Shop.scanSize = 100
Shop.component = {}
Shop.component.core = 1
Shop.component.stockpile = 2
Shop.component.display = 3


---@return number the nearest available ID
local function getAvailableID()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_meta.txt")
    if #file.lines == 0 then
        file.lines[1] = "recentID=0"
        file:save()
    end
    local recentID = tonumber(parseLine(file.lines[1])['recentID'])
    return recentID + 1
end

local function updateRecentID()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_meta.txt")
    file:editLine("recentID=" .. getAvailableID(), 1)
    file:save()
end

---@param owner IsoPlayer the player starting the shop
---@param isAdmin boolean is this shop only editable by admins?
function Shop:new(owner, isAdmin)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = "Shop"
    ---@type number
    o.id = getAvailableID()
    o.owner = owner:getUsername()
    o.isAdmin = isAdmin
    local square = owner:getSquare()
    o.core = { -- this is the core grid square of the store, is set to the register when it is created.  If the core is not in a room it will not work
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
    }
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
    Shop.list[o.id] = o
    updateRecentID()
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

---@param object IsoObject|IsoThumpable
function Shop:setRegister(object)
    local modData = object:getModData()
    if modData then
        modData.ShopID = self.id
        modData.ShopComponent = Shop.component.core
    end
end

---@param object IsoObject|IsoThumpable
function Shop:setStockpile(object)
    local modData = object:getModData()
    if modData then
        modData.ShopID = self.id
        modData.ShopComponent = Shop.component.stockpile
    end
end

function Shop:getSquare()
    return getCell():getGridSquare(self.core.x, self.core.y, self.core.z)
end

function Shop:isValid()
    -- check if shop is in valid location
    local square = self:getSquare()
    local region = square:getIsoWorldRegion()
    local room = square:getRoom()
    return room ~= nil or region:isPlayerRoom()
end

function Shop:getStock()
    local building = Shop:getBuilding()
    local core = getCell():getGridSquare(self.core.x, self.core.y, self.core.z)
    local coreRoom = building.rooms[core:getIsoWorldRegion():getID()]
    local stockpiles = {}
    if coreRoom then
        local objects = building:getContainers()
        for _, table in ipairs(objects) do
            local object = table.object
            local containers = table.containers
            if #containers > 0 then
                local modData = object:getModData()
                local id = modData["ShopID"]
                local objectType = modData["Shop"]
                if id and objectType then
                    if id == self.id and objectType == Shop.component.stockpile then
                        table.insert(stockpiles, containers)
                    end
                end
            end
        end
        return stockpiles
    end
end

function Shop:getItemStock(item)
    local stock = Shop:getStock()
    local all = {}
    for _, t in ipairs(stock) do
        for _, container in ipairs(t) do
            local items = container:findAll(item:getType())
            for i=0, items:size()-1 do
                local thing = items:get(i)
                table.insert(all, thing)
            end
        end
    end
    return all
end

function Shop:getBuilding()
    return Building:get(self.core.x, self.core.y, self.core.z)
end

---@param player IsoPlayer the player trying to add the item
---@param item Item
---@param price number the cost in dollars of the item
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

---@param player IsoPlayer the owner to look for
function Shop.fromPlayer(player)
    return Shop.list[player]
end

function table.slice(t, start, stop, step)
    local sliced = {}
    for i=start or 1, stop or #t, step or 1 do
        sliced[#sliced+1] = t[i]
    end
    return sliced
end

local function split(input, separator)
    separator = separator or "%s"
    local result = {}
    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(result, str)
    end
    return result
end

---@param line string
---@return table
local function parseLine(line)
    if string.match(line, ".") then
        local data = split(line, ".")
        local node = data[1]
        local newline = table.concat(table.slice(data, 2))
        return {[node]=parseLine(newline)}
    elseif string.match(line, ":") then
        local data = split(line, ":")
        local node = data[1]
        local list = table.concat(table.slice(data, 2))
        return {[node]=parseLine(list)}
    elseif string.match(line, "=") then -- this is a key value
        local data = split(line, "=")
        local node = data[1]
        local value = data[2]
        return {[node]=value}
    elseif string.match(line, ";") then
        local data = split(line, ";")
        local result = {}
        for _, v in ipairs(data) do
            table.insert(result, v)
        end
        return result
    end
end

local function parseTable(t)
    local result = ""
    for key, value in pairs(t) do
        if type(key) == "string" then
            if type(value) == "table" then
                for k,_ in pairs(value) do
                    if type(k) == "number" then -- this is a list
                        return key .. ":" .. parseTable(value) -- EOL
                    elseif type(k) == "string" then -- this is an object
                        return key .. "." .. parseTable(value)
                    end
                end
            else
                return key .. "=" .. tostring(value) -- EOL
            end
        elseif type(key) == "number" then -- process a list
            result = result .. tostring(value) .. ";"
        end
    end
    return result -- this does not return to origin, but when parsing a list of values
end

---load the instance from a file
function Shop:load()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_"..tostring(self.id)..".txt")
    local data = {}
    for _, line in ipairs(file.lines) do
        table.insert(data, parseLine(line))
    end
    for key, value in pairs(data) do
        self[key] = value
    end
end

function Shop:save()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_"..tostring(self.id)..".txt")
    if not self.isAdmin then -- admin shops go into a special file
        for line in parseTable{owner=self.owner, name=self.name, permissions=self.permissions, core=self.core} do
            file:editLine(line .. "\n")
        end
        file:save()
    end
end

Events.OnTick.Add(function()
    -- prevent player from siphoning cash registers and stockpiles
    for _, queue in pairs(ISTimedActionQueue.queues) do
        if instanceof(queue, "ISInventoryTransferAction") then -- this should catch the crafting menu as well
            if queue.srcContainer and queue.destContainer then
                -- must be an inventory transfer queue
                local srcData = queue.srcContainer:getModData()
                local destData = queue.srcContainer:getModData()
                if srcData["ShopID"] ~= nil or destData["ShopID"] ~= nil then
                    local id = srcData["ShopID"] or destData["ShopID"]
                    local component = srcData["ShopComponent"] or destData["ShopComponent"]
                    if Shop.list[id] then
                        ---@type IsoPlayer
                        local player = getSpecificPlayer(queue.character)
                        if player:getUsername() then
                            local shop = Shop.list[id]
                            if shop.owner ~= player:getUsername() then
                                if component == Shop.component.register then
                                    if not self:hasPermission(player, "takeMoney") then
                                        queue:stop()
                                    end
                                elseif component == Shop.component.stockpile then
                                    if not self:hasPermission(player, "takeFromStockpiles") then
                                        queue:stop()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

Events.OnGameStart.Add(function()
    -- TODO: load all store metadata
end)