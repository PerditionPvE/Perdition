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

    self.no = ISButton:new(10, self:getHigh() - padBottom - btnHgt, btnWid, "Cancel", self, ShopUI.onClick)
    self.no.internal = "CANCEL"
    self.no:initialise()
    self.no:instantiate()
    self.no.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.no)

    self.yes = ISButton:new(120, self:getHigh() - padBottom - btnHgt, btnWid, "Confirm", self, shopUI.onClick)
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
    self:addChild(slf.cart)

    self.edititems = nil -- button to edit shop listing

    self.playercash = nil -- shows how much money the player has total
    self.cartcost = nil -- how much the cart costs total

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