---@class Building
Building = {}

--- binary search to find all the squares in a building including player made rooms
---@param startSquare IsoGridSquare starting square
local function bloom(startSquare)
    local result = {}
    ---@param square IsoGridSquare
    local function petal(square)
        result[square:getID()] = square
        local squares = luautils.getNextTiles(getCell(), square, 1)
        for _, sq in ipairs(squares) do
            if result[square:getID()] == nil and sq:getIsoWorldRegion():isEnclosed() then
                result[square:getID()] = sq
                petal(square)
            end
        end
    end
    petal(startSquare)
    return result
end

---@param startSquare IsoGridSquare the starting square
local function getRooms(startSquare)
    local rooms = {}
    local squares = bloom(startSquare)
    for _, square in pairs(squares) do
        local region = square:getIsoWorldRegion()
        if rooms[region:getID()] == nil then rooms[region:getID()] = {} end
        table.insert(rooms[region:getID()], square)
    end
    return rooms
end

function Building:get(x, y, z)
    local b = {}
    setmetatable(b, self)
    self.__index = self
    local square = getCell():getGridSquare(x, y, z)
    b.rooms = getRooms(square) -- agony
    return b
end

---@param room_id number the ID of the room, optional
function Building:getContainers(room_id)
    local function parseContainers(room)
        local result = {}
        for _, sq in ipairs(room) do
            local objects = sq:getObjects()
            for i=0, objects:size()-1 do
                local object = objects:get(i)
                local container = object:getContainer()
                if container then
                    local subcon = {object=object, containers={}}
                    local items = container:getItems()
                    for c=0, items:size()-1 do
                        local item = items:get(c)
                        local inv = item:getContainer()
                        if inv then
                            table.insert(subcon.containers, inv)
                        end
                    end
                    table.insert(result, subcon)
                end
            end
        end
        return result
    end
    if room_id then return parseContainers(self.rooms[room_id]) end
    local cons = {}
    for room_id, room in pairs(self.rooms) do
        cons[room_id] = parseContainers(room)
    end
    return cons
end