local Employee = {}
Employee.__index = Employee

function Employee.new(model: Model, cost: number)
    local self = setmetatable({}, Employee)
    self.Model = model
    self.Cost = cost
    self.Speed = 1
    return self
end

function Employee:IncreaseSpeed(newSpeed)
    self.Speed = newSpeed
end

return Employee