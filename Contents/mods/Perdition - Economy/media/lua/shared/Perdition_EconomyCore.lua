---@class Economy
Economy = {}

---@param player IsoPlayer the player in question
function checkRoom(player)
    local cell = player:getCell()
    local sq = player:getSquare()
    local region = sq:getIsoWorldRegion()
end

--Events.OnPlayerUpdate.Add(checkRoom)