local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Employee = require(ReplicatedStorage.Shared.Employees.Employee)
local ManagerRegister = require(game.ReplicatedStorage.Shared.ManagerRegister)

local Cashier = setmetatable({}, Employee)
Cashier.__index = Cashier

function Cashier.new(model: Model, cost: number)
    local self = Employee.new(model, cost)
    setmetatable(self, Cashier)
    return self
end

function Cashier:TakeOrder(order)
    print("Taking order...")
    local orderController = ManagerRegister:GetManager("OrderController")
    orderController:SendToScreen(order)
end

return Cashier