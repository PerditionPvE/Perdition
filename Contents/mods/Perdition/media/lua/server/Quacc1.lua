
local adjustments = {
    Base = {
        Log = {
            Weight = 3
        }
    }
}

for module, table in pairs(adjustments) do
    for _type, t in pairs(table) do
        for key, value in pairs(t) do
            local item = getScriptManager():getItem(module .. "." .. _type)
            if item then
                item:doParam(key .. " = " .. tostring(value))
            end
        end
    end
end

local item = ScriptManager.instance:getItem("Base.Vest_BulletArmy")
if item then 
    item:DoParam("Weight    =    8")
end