---@class Label : ISUIElement
Label = ISUIElement:derive("Label")
local TextManager = getTextManager()
local isoToScreenX = isoToScreenX
local isoToScreenY = isoToScreenY

---@param object IsoObject the object to attach to
---@param heightOffset number|float the height offset of the ui
---@param text string the label text
function Label:new(object, heightOffset, text)
    local o = {}
    setmetatable(self, o)
    self.__index = self
    self.text = text
    o.textWidth = TextManager:MeasureStringX(UIFont.NewSmall, text)
    o.textHeight = TextManager:MeasureStringY(UIFont.NewSmall, text)
    o.attache = object
    self:initialise()
    self:instantiate()
    self:prerender()
    self:update()
    return o
end

function Label:update()
    local object = self.attache
    --TODO: determine how height offset is used
    self:setX(isoToScreenX(object:getX(), object:getY(), object:getY()))
    self:setY(isoToScreenY(object:getX(), object:getY(), object:getY()))
end

function Label:prerender()
    self:drawRect(0, 0, self.textWidth, self.textHeight)
    self:drawRectBorder(0, 0, self.textWidth, self.textHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawTextCentre(self.text, 0, 0, self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a)
end

function Label:hide()
    self:setVisible(false)
end

function Label:show()
    self:setVisible(true)
end

function Label:initialise()
    ISUIElement:initialise(self)
end