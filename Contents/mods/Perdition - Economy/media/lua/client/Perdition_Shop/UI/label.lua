require "ISUI/ISPanel"
---@class Label : ISPanel
Label = ISPanel:derive("Label")

local TextManager = getTextManager()

---@param worldobject IsoObject the object to track
---@param text string what to write overhead
function Label:new(worldobject, text, offsetX, offsetY)
    local o = {}
    setmetatable(self, o)
    self.__index = self
    ---@type IsoObject|IsoMovingObject
    o.object = worldobject
    o.text = text
    o.offsetX = offsetX
    o.offsetY = offsetY
    return o
end

function Label:initialise()
    ISPanel:initialise(self) -- set up the default metadata for the instance
end

function Label:prerender()
    local x = self.object:getX()
    local y = self.object:getY()
    local z = self.object:getZ()
    local isoX = isoToScreenX(getPlayer():getPlayerIndex(), x, y, z)
    local isoY = isToScreenY(getPlayer():getPlayerIndex(), x, y, z)
    self:drawTextCentre(self.text)
end