ISStove = ISBuildingObject:derive('ISStove')

function ISStove:create(x, y, z, north, sprite)
    local cell = getWorld():getCell()
    self.sq = cell:getGridSquare(x, y, z)
    self.javaObject = IsoStove.new(getCell(), self.sq, getSprite(sprite))
    self.sq:AddSpecialObject(self.javaObject)
    buildUtil.consumeMaterial(self)
    self.javaObject:transmitCompleteItemToServer()
end

function ISStove:isValid(square)
    if not ISBuildingObject.isValid(self, square) then
        return false
    end
    if self.needToBeAgainstWall then
        for i = 0, square:getObjects():size() - 1 do
            local obj = square:getObjects():get(i)
            if self:getSprite() == obj:getTextureName() then
                return false
            end
            if (not self.north and obj:getProperties():Is('WallN')) or (self.northSprite and obj:getProperties():Is('WallW')) then
                return true
            end
        end
        return false
    else
        if buildUtil.stairIsBlockingPlacement(square, true) then
            return false
        end
    end
    return true
end

function ISStove:render(x, y, z, square)
    ISBuildingObject.render(self, x, y, z, square)
end

function ISStove:new(name, sprite)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite(sprite.sprite)
    o:setNorthSprite(sprite.north)
    o:setEastSprite(sprite.east)
    o:setSouthSprite(sprite.south)
    o.dismantable = true
    o.needToBeAgainstWall = true
    o.name = name
    o.maxTime = 500
    return o
end