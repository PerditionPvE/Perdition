---@class ShopUI : ISPanel
ShopUI = ISPanel:derive("ShopUI")


local good = {
    r = getCore():getGoodHighlitedColor():getR(),
    g = getCore():getGoodHighlitedColor():getG(),
    b = getCore():getGoodHighlitedColor():getB(),
}

local bad = {
    r = getCore():getBadHighlitedColor():getR(),
    g = getCore():getBadHighlitedColor():getG(),
    b = getCore():getBadHighlitedColor():getB()
}

function ShopUI:initialise()
    ISPanel.initialise(self)

    -- style
    local buttonWidth = 100
    local buttonHeight = 25
    local padding = {
        top = 5,
        bottom = 5,
        left = 5,
        right = 5
    }
    local listWidth = (self.width / 2) - 15
    local listHeight = 250

    local tabWidth = 40
    local tabHeight = 18

    local defaultZomboidBorder = {r=1, g=1, b=1, a=0.4}


    -- close menu button
    self.no = ISButton:new(10, self:getHeight() - padding.bottom - buttonHeight, buttonWidth, buttonHeight,"Cancel", self, ShopUI.onClick)
    self.no.internal = "CANCEL"
    self.no:initialise()
    self.no:instantiate()
    self.no.borderColor = defaultZomboidBorder
    self:addChild(self.no)

    -- the confirm button buy/sell
    self.yes = ISButton:new(120, self:getHeight() - padding.bottom - buttonHeight, buttonWidth, buttonHeight, "Checkout", self, ShopUI.onClick)
    self.yes.internal = "CONFIRM"
    self.yes:initialise()
    self.yes:instantiate()
    self.yes.borderColor = defaultZomboidBorder
    self:addChild(self.yes)

    -- the item listing
    self.offers = ISScrollingListBox:new(10, 70, listWidth, listHeight)
    self.offers:initialise()
    self.offers:instantiate()
    self.offers.itemheight = 25
    self.offers.selected = 0
    self.offers.joypadParent = self
    self.offers.font = UIFont.NewSmall
    self.offers.drawBorder = true
    self:addChild(self.offers)

    -- the cart
    self.cart = ISScrollingListBox:new(self.offers.x + self.offers.width + 10, self.offers.y, listWidth, listHeight)
    self.cart:initialise()
    self.cart:instantiate()
    self.cart.itemheight = 25
    self.cart.selected = 0
    self.cart.joypadParent = self
    self.cart.font = UIFont.NewSmall
    self:addChild(self.cart)

    -- edit listing tab
    self.edititems = ISButton:new(
            self:getWidth() - padding.right - tabWidth,
            padding.top,
            tabWidth,
            tabHeight,
            "Edit",
            self, ShopUI.onClick)
    self.edititems:initialise()
    self.edititems:instantiate()
    self.edititems.borderColor = defaultZomboidBorder
    self:addChild(self.edititems)

    -- shows how much money the player has total
    self.myCash = ISLabel:new(0,0,
        tabHeight,
            "$",
            good.r, good.g, good.b, 1,
            UIFont.NewSmall)
    self.myCash:initialise()
    self.myCash:instantiate()
    self:addChild(self.myCash)

    self.cost = nil -- how much the cart costs total
end

function ShopUI:new(x, y, width, height, player)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2)
    y = getCore():getScreenHeight() / 2 - (height / 2)
    width = 350
    height = 450
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.width = width
    o.height = height
    o.player = player
    o.moveWithMouse = true
    o.offers = nil
    o.cart = nil
    ShopUI.instance = o
    return o
end

function ShopUI:prerender()
    local z = 15
    local splitPoint = 100
    local x = 10
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    -- draw the shop name
    self:drawText(
            "Shop",
            self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, "Shop") / 2),
            z, 1, 1,1, 1, UIFont.Medium) -- why is this callback so irritatingly long?

    z = z + 30
end

function ShopUI:render()

end

function ShopUI.onClick(button)
    if button.internal == "CANCEL" then
        self:removeFromUIManager()
        self:setVisible(false)
    end
    if button.internal == "CONFIRM" then
        -- TODO add buy/sell to button
    end
    if button.internal == "EDIT" then
        -- TODO wow
    end
    if button.internal == "SETTINGS" then
        -- TODO permission settings menu
    end
end

function ShopUI:getFunds()

end

function ShopUI:onPurchase(option, enabled)
    -- TODO: when a player buys something
end

function ShopUI:onSell(option, enabled)
    -- TODO: idk
end

function ShopUI:populate()
    -- TODO: load all items
end