ShopUIManager = {}
ShopUIManager.shop = {}

local function validate(shop_id)
    if not ShopUIManager.shop[shop_id] then
        ShopUIManager.shop[shop_id] = {}
    end
end

function ShopUIManager.AddMenu(shop_id, label)
    validate(shop_id)
    ShopUIManager.shop[shop_id].menu = menu
end

function ShopUIManager.AddLabel(shop_id, label)
    validate(shop_id)
    if not ShopUIManager.shop[shop_id].labels then
        ShopUIManager.shop[shop_id].labels = {}
    end
    table.insert(ShopUIManager.shop[shop_id].labels, label)
end

function ShopUIManager.HideAllLabels(shop_id)
    for _, label in pairs(ShopUIManager.shop[shop_id].labels) do
        label:hide()
    end
end

function ShopUIManager.ShowAllLabels(shop_id)
    for _, label in pairs(ShopUIManager.shop[shop_id].labels) do
        label:show()
    end
end

function ShopUIManager.onPlayerUpdated(player)
    local shop = Shop.find(player)
    if shop then
        local register = shop:getRegister()
        assert(register, "No register found for shop?")
        local registerLabel = Label:new(register)
        Label:prerender()
        Label:update()
        Label:show()
        Label:addToUIManager()
    end
end