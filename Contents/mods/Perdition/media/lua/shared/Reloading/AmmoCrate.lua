require "Reloading/ISReloadUtil"
---@class AmmoCrate
AmmoCrate = {}
AmmoCrate.sizes = {
    small = {
        weight = 0.5, -- the initial weight of the crate when there is no ammo
        weightReduction = 0.3, -- the percentile reduction to bullet weight
        maxCapacity = 300 -- the number of bullets the crate can hold
    },
    medium = {
        weight = 0.7,
        weightReduction = 0.3,
        maxCapacity = 500
    },
    large = {
        weight = 0.9,
        weightReduction = 0.3,
        maxCapacity = 700
    }
}

function AmmoCrate:initialise()
end

---@param size string: the crate size
function AmmoCrate:new(size)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.size = size
    o.currentCapacity = 0
    o.ammoType = nil
    return o
end

local function predicateAmmo(item)
    return item:getCount() > 0
end


---@param character IsoGameCharacter the character loading the bullet
function AmmoCrate:loadBullet(character)
    if self.currentCapacity >= self.maxCapacity then return; end
    local inv = character:getInventory()
    if self.currentCapacity == 0 then
        local allAmmo = inv:getAllEval(predicateAmmo)
        if allAmmo:size() > 0 then
            local ammoTypes = {}
            ---@param item Item
            local isUnique = function(item)
                for _, value in ipairs(ammoTypes) do
                    if value == item:getFullName() then
                        return false
                    end
                end
                return true
            end
            for i=0, allAmmo:size() - 1 do
                local item = allAmmo:get(i)
                if isUnique(item) then table.insert(ammoTypes, item:getFullName()) end
            end
            -- TODO: register context menus
        end
    end
end