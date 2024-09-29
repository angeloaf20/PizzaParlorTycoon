local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
--local ServerStorage = game:GetService("ServerStorage")
local ManagerRegister = require(ReplicatedStorage.Shared.ManagerRegister)

local EmployeeManager = {}
EmployeeManager.__index = EmployeeManager

function EmployeeManager.new(compManager, model)
    local self = setmetatable({}, EmployeeManager)
    self.ComponentManager = compManager
    self.Model = model

    self.EmployeeList = {}

    ManagerRegister:RegisterManager("EmployeeManager", self)
    return self
end

function EmployeeManager:Init()
    print("Initialized employee manager")

    local employeeGuiEvent: RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("EmployeeGuiEvent")

    local screen = self.Model:FindFirstChild("LED screen"):FindFirstChild("Screen")
    local proxPrompt: ProximityPrompt = screen:FindFirstChild("ProximityPrompt")


    proxPrompt.Triggered:Connect(function(playerWhoTriggered)
        if playerWhoTriggered ~= self.ComponentManager.Parlor.Owner then return end
        employeeGuiEvent:FireClient(playerWhoTriggered, self.ComponentManager.Parlor.Model)
    end)

    employeeGuiEvent.OnServerEvent:Connect(function(_player, role: string)
        --if player:FindFirstChild("leaderstats"):FindFirstChild("Money").Value == 10 then
            print("Hiring employee...", role)
            self:HireEmployee(role)
        --end
    end)
end

function EmployeeManager:OnScreenPressed(employeeName)
    print(employeeName)
end

function EmployeeManager:HireEmployee(role: string)
    local employeeModelFolder = ServerStorage:FindFirstChild("Employees")
    local employeeSpawnFolder = self.ComponentManager.Parlor.Building:FindFirstChild("EmployeeSpawns")--:GetChildren()
    local employee = require(ReplicatedStorage.Shared.Employees[role])
    if not self.EmployeeList[role] then
        local employeeModel  = employeeModelFolder:FindFirstChild(role):Clone()
        self.EmployeeList[role] = employee.new(employeeModel, employeeModel:GetAttribute("Cost"))
        local spawnPoint = `{role}Spawn`
        employeeModel.Parent = employeeSpawnFolder:FindFirstChild(spawnPoint)
        employeeModel.PrimaryPart:PivotTo(employeeModel.Parent.CFrame)
    end
end

function EmployeeManager:FindEmployee(role)
    return self.EmployeeList[role] ~= false
end

return EmployeeManager