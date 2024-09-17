local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ManagerRegister = require(ReplicatedStorage.Shared.ManagerRegister)

local EmployeeManager = {}
EmployeeManager.__index = EmployeeManager

function EmployeeManager.new(compManager, model)
    local self = setmetatable({}, EmployeeManager)
    self.ComponentManager = compManager
    self.Model = model

    self.EmployeeList = {
        Cashier = require(ReplicatedStorage.Shared.Employees["Cashier"]).new(
            ServerStorage:FindFirstChild("Employees"):FindFirstChild("Cashier"), 500
        )
    }

    ManagerRegister:RegisterManager("EmployeeManager", self)
    return self
end

function EmployeeManager:Init()
    print("Initialized employee manager")
end

function EmployeeManager:HireEmployee(role: string)
    local employeeModelFolder = game:GetService("ServerStorage"):FindFirstChild("Employees")
    local employee = require(ReplicatedStorage.Shared.Employees[role])
    if not self.EmployeeList[role] then
        local employeeModel = employeeModelFolder:FindFirstChild(role)
        self.EmployeeList[role] = employee.new(employeeModel, employeeModel:GetAttribute("Cost"))
    end
end

function EmployeeManager:FindEmployee(role)
    return table.find(self.EmployeeList, role) ~= nil
end

return EmployeeManager