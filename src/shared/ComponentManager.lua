local ParlorContainer = game.ServerStorage:WaitForChild("ParlorContainer")
local CollectionService = game:GetService("CollectionService")
local Components = game:GetService("ReplicatedStorage").Shared.Components

local ComponentManager = {}
ComponentManager.__index = ComponentManager

function ComponentManager.new(parlor)
    local self = setmetatable({}, ComponentManager)

    self.Parlor = parlor
    self.CompEvent = Instance.new("BindableEvent")
    self.ComponentList = {}

    return self
end

function ComponentManager:Init()
   self:LockComponents(self.Parlor.Building)
end

function ComponentManager:LockComponents(model)
    for _, child in pairs(model:GetChildren()) do
		if CollectionService:HasTag(child, "Unlockable") then
			self:Lock(child)
		else
			self:CreateAllComponents(child)
		end
	end
end

function ComponentManager:CreateComponent(compScript, instance)
    local module = require(compScript)
    local newComponent = module.new(self, instance)
    newComponent:Init()
end

function ComponentManager:CreateAllComponents(instance)
    for _, tag in ipairs(CollectionService:GetTags(instance)) do
        local compScript = Components:FindFirstChild(tag)
        if compScript then
            self:CreateComponent(compScript, instance)
        end
    end
end

function ComponentManager:Lock(instance)
    instance.Parent = ParlorContainer
    print("locked: ", instance)
    self:CreateComponent(Components.Unlockable, instance)
end

function ComponentManager:Unlock(instance)
    CollectionService:RemoveTag(instance, "Unlockable")
    instance.Parent = self.Parlor.Building
    print("unlocked: ", instance)
    self:CreateAllComponents(instance)
end

function ComponentManager:PublishTopic(topic, ...)
    self.CompEvent:Fire(topic, ...)
end

function ComponentManager:SubscribeTopic(topic, callback)
    local connection = self.CompEvent.Event:Connect(function(name, ...)
		if name == topic then
			callback(...)
		end
	end)
	return connection
end

return ComponentManager