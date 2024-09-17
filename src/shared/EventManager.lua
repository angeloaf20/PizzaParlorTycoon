local EventManager = {}

local GameEvents = {}

function EventManager.PublishEvent(playerId, event, ...)
    if GameEvents[playerId] and GameEvents[playerId][event] then
        GameEvents[playerId][event]:Fire(...)
    end
end

function EventManager.SubscribeEvent(playerId, event, callback)
    if not GameEvents[playerId] then
        GameEvents[playerId] = {}
    end

    if not GameEvents[playerId][event] then
        GameEvents[playerId][event] = Instance.new("BindableEvent")
    end
    
    local connection = GameEvents[playerId][event].Event:Connect(callback)
    return connection
end

function EventManager.UnsubscribeEvent(connection)
    if connection then
        connection:Disconnect()
    end
end

function EventManager.RemoveEvent(playerId, event)
    if GameEvents[playerId] and GameEvents[playerId][event] then
        GameEvents[playerId][event]:Destroy()
        GameEvents[playerId][event] = nil
    end

    if GameEvents[playerId] and next(GameEvents[playerId]) == nil then
        GameEvents[playerId] = nil
    end
end

return EventManager