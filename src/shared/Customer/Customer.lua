local Customer = {}
Customer.__index = Customer

function Customer.new(model: Model, multiplier: number, name: string, order: table)
    local self = setmetatable({}, Customer)
    self.Model = model
    self.Multiplier = multiplier
    self.Name = name
    self.Order = order
    return self
end

function Customer:Destroy()
    self.Model:Destroy()
    self.Name = nil
    self.Multiplier = nil
end

return Customer