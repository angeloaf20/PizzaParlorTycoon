local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiFolder = ReplicatedStorage:WaitForChild("GUIs")
local EmployeeGui: Frame = GuiFolder:FindFirstChild("EmployeeGui")
local EmployeeGuiEvent: RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("EmployeeGuiEvent")
local ExitButton: TextButton = EmployeeGui:FindFirstChild("ExitButton")

EmployeeGuiEvent.OnClientEvent:Connect(function(_player)
    local MainGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MainGui")
    EmployeeGui.Parent = MainGui

    for _, item: ImageButton in pairs(EmployeeGui:GetChildren()) do
        if item.Name == "ExitButton" then continue end
        item.MouseButton1Click:Connect(function()

            EmployeeGuiEvent:FireServer(item.Name)
        end)
    end
end)

ExitButton.MouseButton1Click:Connect(function()
    EmployeeGui.Parent = GuiFolder
end)
