---@class Shop : ISBuildingObject

Shop = ISBuildingObject:derive("Shop")

function Shop:new(owner, isAdmin)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    -- TODO write metavalues for a shop and define player vs admin
end