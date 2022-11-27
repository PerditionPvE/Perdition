---@class Building
Building = {}

local function bloom(x, y, z)
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
    return result
end

local function getRooms(x, y, z)
    local rooms = {}
    local squares = bloom(x, y, z)
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
    b.rooms = getRooms(x, y, z) -- agony
    return b
end

---@param room_id number the ID of the room, optional
function Building:getContainers(room_id)
    local function parseContainers(room)
        local containers = {}
        for _, sq in ipairs(room) do
            local objects = sq:getObjects()
            for i=0, objects:size()-1 do
                local object = objects:get(i)
                local subcon = {object=object, containers={}}
                for c=0, object:getContainerCount()-1 do
                    table.insert(subcon.containers, object:getContainerByIndex(c))
                end
                table.insert(containers, subcon)
            end
        end
        return containers
    end
    if room_id then return parseContainers(self.rooms[id]) end
    local cons = {}
    for room_id, room in pairs(self.rooms) do
        cons[room_id] = parseContainers(room)
    end
    return cons
end