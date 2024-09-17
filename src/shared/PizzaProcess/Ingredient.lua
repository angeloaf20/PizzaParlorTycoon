local Ingredient = {}
Ingredient.__index = Ingredient

function Ingredient.new(model: Model, station: Part)
    local self = setmetatable({}, Ingredient)
    self.Model = model
    self.Station = station
    self.Name = self.Model.Name
    return self
end

return Ingredient