local Order = {}
Order.__index = Order

function Order.new(ingredients: table, price: number, orderNumber: number)
    local self = setmetatable({}, Order)
    self.Ingredients = ingredients
    self.Price = price
    self.OrderNumber = orderNumber
    --// TODO: create customer class and assign them as member of this order
    return self
end

return Order