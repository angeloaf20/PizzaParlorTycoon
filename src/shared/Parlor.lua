-- //
--local Components = game.ReplicatedStorage.Shared.Components
--local Unlockable = require(Components.Unlockable)
--local Template = game.ServerStorage.Template:WaitForChild("ParlorTemplate")
--local Button = require(Components.Button)
local ParlorsInServer = game.Workspace:WaitForChild("ParlorsInServer")
-- //

local Parlor = {}
Parlor.__index = Parlor

local function AddModel(model, location)
	local newModel = model
	local spawn = (location * CFrame.new(0, -1, 0))
	newModel:SetPrimaryPartCFrame(spawn)
	newModel.Parent = ParlorsInServer
end

function Parlor.new(owner: Player, building: Instance, location: CFrame)
    local self = setmetatable({}, Parlor)

    self.Owner = owner
    self.Building = building
    self.Location = location
    self.LineSize = 3

    return self
end

function Parlor:Init()
    self.Building:SetAttribute("Owner", self.Owner.Name)
    AddModel(self.Building, self.Location)
end

function Parlor:Destroy()
    self.Building:Destroy()
end

return Parlor