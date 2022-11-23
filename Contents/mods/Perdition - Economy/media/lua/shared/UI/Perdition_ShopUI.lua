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
