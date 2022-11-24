---@class ShopUI : ISPanel
ShopUI = ISPanel:derive("ShopUI")

function ShopUI:initialise()
    ISPanel.initialise(self)
    local btnWid = 100
    local btnHgt = 25
    local btnHgt2 = 18
    local padBottom = 10
    local listWidth = (self.width / 2) - 15
    local listheight = 250

    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,"Cancel", self, ShopUI.onClick)
    self.no.internal = "CANCEL"
    self.no:initialise()
    self.no:instantiate()
    self.no.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.no)

    self.yes = ISButton:new(120, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "Confirm", self, ShopUI.onClick)
    self.yes.internal = "CONFIRM"
    self.yes:initialise()
    self.yes:instantiate()
    self.yes.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.yes)

    self.offers = ISScrollingListBox:new(10, 70, listWidth, listheight)
    self.offers:initialise()
    self.offers:instantiate()
    self.offers.itemheight = 25
    self.offers.selected = 0
    self.offers.joypadParent = self
    self.offers.font = UIFont.NewSmall
    self.offers.drawBorder = true
    self:addChild(self.offers)

    self.cart = ISScrollingListBox:new(self.offers.x + self.offers.width + 10, self.offers.y, listWidth, listheight)
    self.cart:initialise()
    self.cart:instantiate()
    self.cart.itemheight = 25
    self.cart.selected = 0
    self.cart.joypadParent = self
    self.cart.font = UIFont.NewSmall
    self:addChild(self.cart)

    self.edititems = nil -- button to edit shop listing

    self.playercash = nil -- shows how much money the player has total
    self.cartcost = nil -- how much the cart costs total
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

function ShopUI.onClick(button)
    if button.internal == "CANCEL" then
        -- TODO add menu closing
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

function ShopUI:onPurchase(option, enabled)
    -- TODO: when a player buys something
end

function ShopUI:onSell(option, enabled)
    -- TODO: idk
end

function ShopUI:populate()
    -- TODO: load all items
end