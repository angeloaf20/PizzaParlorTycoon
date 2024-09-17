local ParlorLocations = game.Workspace:WaitForChild("ParlorLocations")
local ExistingParlors = {}
local ParlorTemplate = game.ServerStorage.ParlorTemplate
local Parlor = require(game.ReplicatedStorage.Shared.Parlor)
local Owner = require(game.ReplicatedStorage.Shared.Owner)
local Players = game:GetService("Players")
local ComponentManager = require(game.ReplicatedStorage.Shared.ComponentManager)

local function SpawnParlor(location, player: Player)
    local spawnLoc = location.CFrame * CFrame.new(0, 1, 0)
    local building = ParlorTemplate:Clone()
    building.Name = `{player.UserId}`

    local newParlor = Parlor.new(player, building, spawnLoc)
    newParlor:Init()

    local compManager = ComponentManager.new(newParlor)
    compManager:Init()

    ExistingParlors[player.UserId] = building
end

Players.PlayerAdded:Connect(function(player)
    for _, location in pairs(ParlorLocations:GetChildren()) do
        if location:GetAttribute("Occupied") then continue end
        SpawnParlor(location, player)
        location:SetAttribute("Occupied", true)
        location:SetAttribute("Owner", player.Name)
        local owner = Owner.new(player)
        owner:Init()
        return
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ExistingParlors[player.UserId]:Destroy()

    for _, location in pairs(ParlorLocations:GetChildren()) do
        if location:GetAttribute("Owner") == player.Name then
            location:SetAttribute("Occupied", false)
        end
    end
end)