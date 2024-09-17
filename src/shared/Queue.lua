local Queue = {}
Queue.__index = Queue

function Queue.new()
    local self = setmetatable({}, Queue)
    self.Data = {}
    return self
end

function Queue:Enqueue(value)
    table.insert(self.Data, value)
end

function Queue:Dequeue()
    table.remove(self.Data, 1)
end

function Queue:Peek()
    return self.Data[1]
end

function Queue:Length()
    return #self.Data
end

return Queue