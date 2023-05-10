local titles = {
    Developer = {
        color = {r=0.8, g=0.1, b=0.9},
        members = {76561198148367157}
    }
}
---@param player IsoPlayer the player to update
local function updateTags(player)
    for title, config in pairs(titles) do
        for _, id in pairs(config.members) do
            if player:getSteamID() == id then
                player:setTagPrefix(title)
                player:setTagColor(Color(config.color.r, config.color.g, config.color.b))
                player:setShowTag(true)
            end
        end
    end
end

Events.OnPlayerUpdate.Add(updateTags)