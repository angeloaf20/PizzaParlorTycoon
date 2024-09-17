local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Customers = ServerStorage:FindFirstChild("Customers")
local Customer = require(ReplicatedStorage.Shared.Customer.Customer)
local Queue = require(ReplicatedStorage.Shared.Queue)
local EventManager = require(ReplicatedStorage.Shared.EventManager)
local ManagerRegister = require(game.ReplicatedStorage.Shared.ManagerRegister)

local CustomerManager = {}
CustomerManager.__index = CustomerManager

function CustomerManager.new(compManager, model)
    local self = setmetatable({}, CustomerManager)
    self.ComponentManager = compManager
    self.Model = model
    self.SpawnSpot = self.ComponentManager.Parlor.Building:FindFirstChild("CustomerSpawnSpot"):FindFirstChild("Spawn")
    self.CustomerList = Queue.new()
    ManagerRegister:RegisterManager("CustomerManager", self)
    return self
end

function CustomerManager:Init()
    self:SpawnCustomer()
end

function CustomerManager:SpawnCustomer()
    local randTime = math.random(1, 2)
    task.spawn(function()
        while task.wait(randTime) do
            randTime = math.random(1, 2)
            if self.CustomerList:Length() == self.ComponentManager.Parlor.LineSize then continue end
            local customer = self:GenerateCustomer()
            self:EnterParlor(customer)
        end
    end)
end

function CustomerManager:GenerateCustomer()
    local customerModel = Customers:FindFirstChild("Customer"):Clone()
    local name = "Bob"
    local orderController = ManagerRegister:GetManager("OrderController")
    local order = orderController.GenerateOrder()
    local customer = Customer.new(customerModel, 1, name, order)
    self.CustomerList:Enqueue(customer)
    print("New customer: ", customer)
    return customer
end

function CustomerManager:EnterParlor(customer)
    local parlorModel = self.ComponentManager.Parlor.Building
    local npcSpawnSpot = parlorModel:FindFirstChild("CustomerSpawnSpot")
    local lineSpots = npcSpawnSpot:FindFirstChild("LineSpots"):GetChildren()
    local customerHumanoid = customer.Model:FindFirstChild("Humanoid")
    local customerIndex = self.CustomerList:Length()

    customer.Model.Parent = self.SpawnSpot
    customer.Model.PrimaryPart:PivotTo(self.SpawnSpot.CFrame)

    local pivotPoints = {lineSpots[#lineSpots], lineSpots[customerIndex]}

    for _, point: Part in ipairs(pivotPoints) do
        task.wait()
        customerHumanoid:MoveTo(point.CFrame.Position)
        customerHumanoid.MoveToFinished:Wait()
    end

    if customer == self.CustomerList:Peek() then
        self:FirstInLine(customer)
    end
end

function CustomerManager:FirstInLine(customer)
    --#region Checking for employees and allowing the player 5 seconds to take the order before defaulting to the cashier
    if self:CheckForCashier() then
        local orderTaken = false

        local proxPrompt = Instance.new("ProximityPrompt")
        proxPrompt.ActionText = "Take order"
        proxPrompt.Parent = customer.Model
        proxPrompt.Triggered:Connect(function(playerWhoTriggered)
            if playerWhoTriggered.UserId ~= self.ComponentManager.Parlor.Owner.UserId then return end
            local OrderController = ManagerRegister:GetManager("OrderController")
            orderTaken = true
            print("Customer proximity prompt touched")
            proxPrompt.Enabled = false
            proxPrompt:Destroy()
            OrderController:OrderProcedure(customer.Order)
            self:GiveCustomerPizza(customer)
        end)

        task.delay(5, function()
            proxPrompt.Enabled = false
            if orderTaken then
                return
            end
            print("Talking to the cashier, ", customer)
            self:TalkToCashier(customer.Order)
        end)
        return
    end
    --#endregion

    local proxPrompt = Instance.new("ProximityPrompt")
    proxPrompt.ActionText = "Take order"
    proxPrompt.Parent = customer.Model
    proxPrompt.Triggered:Connect(function(playerWhoTriggered)
        if playerWhoTriggered.UserId ~= self.ComponentManager.Parlor.Owner.UserId then return end
        local OrderController = ManagerRegister:GetManager("OrderController")
        print("Customer proximity prompt touched")
        proxPrompt.Enabled = false
        proxPrompt:Destroy()
        OrderController:OrderProcedure(customer.Order)
        self:GiveCustomerPizza(customer)
    end)
end

function CustomerManager:GiveCustomerPizza(customer)
    local proxPrompt = Instance.new("ProximityPrompt")
    proxPrompt.ActionText = "Give Pizza"
    proxPrompt.Parent = customer.Model
    proxPrompt.Triggered:Wait()
    proxPrompt.Enabled = false
    proxPrompt:Destroy()
    local price = customer.Multiplier * customer.Order.Price
    EventManager.PublishEvent(self.ComponentManager.Parlor.Owner.UserId, "UpdateCash", price)
    self:LeaveParlor(customer)
end

function CustomerManager:TalkToCashier(order)
    local employeeManager = ManagerRegister:GetManager("EmployeeManager")
    local cashier = employeeManager.EmployeeList["Cashier"]
    cashier:TakeOrder(order)
end

function CustomerManager:CheckForCashier()
    print("Good for now")

    local employeeManager = ManagerRegister:GetManager("EmployeeManager")
    if employeeManager:FindEmployee("Cashier") then
        return true
    end
end

function CustomerManager:LeaveParlor(customer)
    customer.Model:FindFirstChild("Humanoid"):MoveTo(self.SpawnSpot.CFrame.Position)
    customer.Model:FindFirstChild("Humanoid").MoveToFinished:Wait()

    customer.Model:Destroy()
    self.CustomerList:Dequeue()

    task.wait(0.5)

    self:ShiftCustomers()
end

function CustomerManager:ShiftCustomers()
    print(self.CustomerList.Data)
    local customerSpawnSpot = self.ComponentManager.Parlor.Building:FindFirstChild("CustomerSpawnSpot")
    local lineSpots = customerSpawnSpot:FindFirstChild("LineSpots"):GetChildren()

    for index, customer in ipairs(self.SpawnSpot:GetChildren()) do
        customer:FindFirstChild("Humanoid"):MoveTo(lineSpots[index].CFrame.Position)
        customer:FindFirstChild("Humanoid").MoveToFinished:Wait()

        if index == 1 then
            self:FirstInLine(self.CustomerList:Peek())
        end
    end
end

return CustomerManager