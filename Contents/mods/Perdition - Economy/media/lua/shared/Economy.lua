---@class Economy
Economy = {}
Economy.bills = {
    [10000] = "10000bill",
    [5000] = "5000bill",
    [1000] = "1000bill",
    [100] = "100bill",
    [50] = "50bill",
    [20] = "20bill",
    [10] = "10bill",
    [5] = "5bill",
    [1] = "Money"
}

---@param item Item the iterated item
local function predicateMoney(item)
    for value, bill in pairs(Economy.bills) do
        -- gets the base name
        print(item:getType())
        print(item:getType() == bill)
        if item:getType() == bill then
            return true
        end
    end
    return false
end

---@param cost int the "cost" to calculate
---@return table
Economy.getBillsByCost = function(cost)
    local remainder = cost
    local result = {}
    for value, name in pairs(Economy.bills) do
        local all = math.floor(remainder / value) -- get the total divisable
        remainder = remainder % value
        result[name] = all
        print(getItemNameFromFullType("Base." .. name), "s: ", all)
    end
    return result
end

---@param player IsoPlayer
---@return int
Economy.getWorth = function(player)
    local inv = player:getInventory()
    local items = inv:getAllEvalRecurse(predicateMoney)
    local total = 0
    for i=0, items:size() - 1 do
        local item = items:get(i)
        if item:getType() == "Money" then
            total = total + 1
        else
            for value, name in pairs(Economy.bills) do
                if item:getType() == name then
                    total = total + value
                end
            end
        end
    end
    return total
end