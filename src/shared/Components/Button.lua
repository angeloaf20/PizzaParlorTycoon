local Players = game:GetService("Players")
local EventManager = require(game.ReplicatedStorage.Shared.EventManager)

local Button = {}
Button.__index = Button

function Button.new(compManager, model: Model)
    local self = setmetatable({}, Button)
    self.ComponentManager = compManager
    self.Model = model
    self.Price = self.Model:GetAttribute("Price")
    return self
end

function Button:Init()
    self:SetLabel()
    local debounce = false
    self.Model.PressPart.Touched:Connect(function(touchPart)
        if not debounce then
            debounce = true
            self:Press(touchPart)
            
            task.wait(0.2)
            debounce = false
        end
    end)
end

function Button:SetLabel()
    local nameLabel: TextLabel = self.Model.PricingTag.BillboardGui.Frame.Title
    local priceLabel = self.Model.PricingTag.BillboardGui.Frame.Pricing
    nameLabel.Text = self.Model:GetAttribute("Text")
    priceLabel.Text = `${self.Model:GetAttribute("Price")}`
end

function Button:Press(touchPart)
    if Players:GetPlayerFromCharacter(touchPart.Parent) == nil then return end

    local id = self.Model:GetAttribute("Id")
    local player = Players:GetPlayerFromCharacter(touchPart.Parent)
    local money = player.leaderstats.Money.Value

    if player ~= self.ComponentManager.Parlor.Owner then return end
    if money >= self.Price then
        EventManager.PublishEvent(player.UserId, "Button", id)
        EventManager.PublishEvent(player.UserId, "UpdateCash", -self.Price)
        self.Model:Destroy()
    end
end

return Button