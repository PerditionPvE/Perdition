---@class Shop
Shop = {}
Shop.list = {}
Shop.directory = "perdition/shops"
Shop.scanSize = 100
Shop.component = {}
Shop.component.core = 1
Shop.component.stockpile = 2
Shop.component.display = 3

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

local function parseTable(t)
    local result = ""
    for key, value in pairs(t) do
        print("Parsing table: " .. type(key) == "string")
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

---@param line string
---@return table
local function parseLine(line)
    if string.find(line, "[.]") then
        local data = split(line, ".")
        local node = data[1]
        local newline = table.concat(table.slice(data, 2))
        return {[node]=parseLine(newline)}
    end
    if string.find(line, "[:]") then
        local data = split(line, ":")
        local node = data[1]
        local list = table.concat(table.slice(data, 2))
        return {[node]=parseLine(list)}
    end
    if string.find(line, "[=]") then -- this is a key value
        local data = split(line, "=")
        local node = data[1]
        local value = data[2]
        return {[node]=value}
    end
    if string.find(line, "[;]") then
        local data = split(line, ";")
        local result = {}
        for _, v in ipairs(data) do
            table.insert(result, v)
        end
        return result
    end
end

---@return number the nearest available ID
local function getAvailableID()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_meta.txt")
    assert(file, "Unable to get file")
    if #file.lines == 0 then
        file.lines[1] = "recentID=0"
        file:save()
    end
    local data = parseLine(file.lines[1])
    local recentID = tonumber(data['recentID'])
    return recentID + 1
end

local function updateRecentID()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_meta.txt")
    file:editLine("recentID=" .. getAvailableID(), 1)
    file:save()
end


--[[

        SHOP INSTANCE METHODS

  ]]

---@param owner IsoPlayer the player starting the shop
---@param id number the ID of the shop
---@param isAdmin boolean is this shop only editable by admins?
function Shop:new(owner, id, isAdmin)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = "Shop"
    ---@type number
    o.id = id or getAvailableID() -- gets the next number from shop_meta.txt
    o.owner = owner:getUsername()
    o.isAdmin = isAdmin or false
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
        setStockpile = {
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
    if self.permissions[permission].factionAllowed
    and playerFaction == ownerFaction
    then
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
    local movprops = ISMoveableSpriteProps.fromObject(object) -- this gets the moveable's sprite info, which also contains its name
    print(movprops.name)
    print('ID: ', self.id)
    print('Component: ', Shop.component.core)
    if modData then -- set this moveable to be a register
        modData["ShopID"] = self.id
        modData["ShopComponent"] = Shop.component.core
    end

    -- set the core position to this
    self.core.x = object:getX()
    self.core.y = object:getY()
    self.core.z = object:getZ()
end

---@param object IsoObject|IsoThumpable
function Shop:setStockpile(object)
    local modData = object:getModData()
    if modData then
        modData["ShopID"] = self.id
        modData["ShopComponent"] = Shop.component.stockpile
    end
end

function Shop:getSquare()
    return getCell():getGridSquare(self.core.x, self.core.y, self.core.z)
end

function Shop:getRegister()
    local square = self:getSquare()
    local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            local modData = object:getModData()
            local movprops = ISMoveableSpriteProps.fromObject(object)
            print("=======[OBJECT]=======")
            print("Name: ", movprops.name)
            if modData then
                print("Mod data:")
                for k,v in pairs(modData) do
                    print(k, ": ", v)
                end
                if modData['ShopID'] == self.id and modData['ShopComponent'] == Shop.component.core then
                    return object
                end
            end
        end
    return nil
end

function Shop:isValid()
    -- check if shop is in valid location
    -- a shop must be in a player-built room or world room
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

---@return table
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

---@return Building
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

---load the instance from a file
function Shop:load()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_"..tostring(self.id)..".txt")
    local data = {}
    for _, line in ipairs(file.lines) do
        table.insert(data, parseLine(line))
    end
    for key, value in pairs(data) do
        self[key] = value
        print(key, ": ", value)
    end
end

function Shop:save()
    local file = Perdition.FileManager:open(Shop.directory .. "/shop_"..tostring(self.id)..".txt")
    if not self.isAdmin then -- admin shops go into a special category
        file:setLines(parseTable{owner=self.owner, name=self.name, permissions=self.permissions, core=self.core})
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

--Events.OnGameStart.Add(function()
--    -- TODO: load all store metadata
--    local max = getAvailableID()
--    for i=1, i < max do
--        local file = Perdition.FileManager:open(Shop.directory .. "/shop_" .. tostring(i) .. ".txt")
--        if file then
--            local ownerName = parseLine(file.lines[1])
--            local owner = getPlayerFromUsername(ownerName)
--            local core = parseLine(file.lines[3])
--            if owner then -- if the player is removed from the whitelist, this will catch that
--                local shop = Shop:new(owner, i)
--                shop.core.x = core.x -- make sure this works
--                shop.core.y = core.y -- make sure this works
--                shop.core.z = core.z -- make sure this works
--                shop.name = parseLine(file.lines[2]) or "Shop"
--                shop.permissions = parseLine(files.lines[4])
--            end
--        end
--    end
--end)