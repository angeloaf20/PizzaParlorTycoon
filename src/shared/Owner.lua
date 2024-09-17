local EventManager = require(game.ReplicatedStorage.Shared.EventManager)

local Owner = {}
Owner.__index = Owner

function Owner.new(player)
    local self = setmetatable({}, Owner)
    self.Player = player
    self.OwnerEvent = Instance.new("BindableEvent")
    self.Money = 0
    self.Connection = nil
    return self
end

function Owner:Init()
    print("Successfully created new owner:", self.Player.UserId)

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = self.Player

    local money = Instance.new("IntValue")
    money.Name = "Money"
    money.Value = self.Money
    money.Parent = leaderstats

    self.Connection = EventManager.SubscribeEvent(self.Player.UserId, "UpdateCash", function(amount)
        self:UpdateCashOnHand(amount)
    end)
end

function Owner:LoadFromServer()
    --// When the owner stuff is done, save the info to the server
    --// and then load it with this function
end

function Owner:UpdateMoneyLeaderstats()
    local money = self.Player.leaderstats.Money
    money.Value = self.Money
end

function Owner:UpdateCashOnHand(amount: number)
    self.Money += amount
    
    self:UpdateMoneyLeaderstats()
end

return Owner