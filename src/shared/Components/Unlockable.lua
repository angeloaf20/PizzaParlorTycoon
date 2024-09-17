local Unlockable = {}
Unlockable.__index = Unlockable

function Unlockable.new(compManager, model)
    local self = setmetatable({}, Unlockable)

    self.ComponentManager = compManager
    self.Model = model

    return self
end

function Unlockable:Init()
    local EventManager = require(game.ReplicatedStorage.Shared.EventManager)
    local playerId = self.ComponentManager.Parlor.Owner.UserId
    self.Subscription = EventManager.SubscribeEvent(playerId, "Button", function(...)
        self:OnButtonPressed(...)
    end)
end

function Unlockable:OnButtonPressed(id)
    if id == self.Model:GetAttribute("UnlockId") then
        self.ComponentManager:Unlock(self.Model)
        self.Subscription:Disconnect()
    end
end

return Unlockable