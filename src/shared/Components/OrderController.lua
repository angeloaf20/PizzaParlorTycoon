local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PizzaStuff = ServerStorage:FindFirstChild("PizzaStuff")
local Ingredients = PizzaStuff:FindFirstChild("Ingredients")
local Order = require(ReplicatedStorage.Shared.PizzaProcess.Order)
local Ingredient = require(ReplicatedStorage.Shared.PizzaProcess.Ingredient)
local TweenService = game:GetService("TweenService")
--local EventManager = require(ReplicatedStorage.Shared.EventManager)
local ManagerRegister = require(game.ReplicatedStorage.Shared.ManagerRegister)

--local CustomerManager = ManagerRegister:GetManager("CustomerManager")

local OrderController = {}
OrderController.__index = OrderController

function OrderController.new(compManager, model: Model)
    local self = setmetatable({}, OrderController)
    self.ComponentManager = compManager
    self.Model = model
    self.OrderList = {}
    ManagerRegister:RegisterManager("OrderController", self)
    return self
end

function OrderController:Init()
    local proxPrompt = Instance.new("ProximityPrompt")
    proxPrompt.MaxActivationDistance = 25
    proxPrompt.Parent = self.Model:FindFirstChild("LED screen"):FindFirstChild("Screen")
    proxPrompt.Enabled = false
end

function OrderController:GenerateOrder()
    local dough = Ingredient.new(Ingredients:FindFirstChild("Dough"))
    local sauce = Ingredient.new(Ingredients:FindFirstChild("Sauce"))
    local cheese = Ingredient.new(Ingredients:FindFirstChild("Cheese"))
    local newOrder = Order.new({dough, sauce, cheese}, math.random(20, 50), math.random(1000, 9990))
    return newOrder
end

function OrderController:SendToScreen(order)
    local screen = self.Model:FindFirstChild("LED screen"):FindFirstChild("Screen")
    local orderScreenGui = screen:FindFirstChild("OrderScreenGui")
    local orderList = orderScreenGui:FindFirstChild("OrderContainer"):FindFirstChild("OrderList")
    local orderFrame = ReplicatedStorage:FindFirstChild("GUIs"):FindFirstChild("OrderScreenGui"):FindFirstChild("Order"):Clone()

    local orderNumberText: TextLabel = orderFrame:FindFirstChild("OrderNumberLabel")
    orderNumberText.Text = `#{order.OrderNumber}`

    orderFrame.Parent = orderList

    local acceptButton: TextButton = orderFrame:FindFirstChild("AcceptOrderButton")
    acceptButton.MouseButton1Click:Connect(function()
        print("accept button clicked")
        self:OrderProcedure(order)
    end)
end

function OrderController:OrderProcedure(order)
    print(order)
    local function waitForStep(parent: Instance, actionText: string)
        local proximityPrompt

        if not parent:FindFirstChild("ProximityPrompt") then
            proximityPrompt = Instance.new("ProximityPrompt")
            proximityPrompt.Parent = parent
        else
            proximityPrompt = parent:FindFirstChild("ProximityPrompt")
        end

        proximityPrompt.Enabled = true
        proximityPrompt.ActionText = actionText
        local player = proximityPrompt.Triggered:Wait()
        if player.UserId ~= self.ComponentManager.Parlor.Owner.UserId then return end

        proximityPrompt.Enabled = false
        return player
    end

    local function createPizzaTool(parent: Instance, plate)
        local tool = Instance.new("Tool")
        tool.Parent = parent
        tool:PivotTo(parent.CFrame * CFrame.new(0, 0.1, 0))
        tool.RequiresHandle = false
        tool.CanBeDropped = false
        plate.Name = "Handle"
        plate.Parent = tool
        tool:FindFirstChild("Handle"):FindFirstChild("TouchInterest"):Destroy()
        tool.Grip = tool.Grip * CFrame.Angles(0, 0, math.rad(-90))

        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.Parent = plate
        proximityPrompt.Enabled = false

        return tool
    end

    local function weldParts(parent, part0, part1)

        if part0.Anchored == true then
            part0.Anchored = false
        end
        if part1.Anchored == true then 
            part1.Anchored = false 
        end

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = part0
        weld.Part1 = part1
        weld.Parent = parent
        return weld
    end

    local function shiftIngredients(plate: Instance, ingredient: Instance, spot: Instance, offset)
        plate.Parent = spot
		plate:PivotTo(spot.CFrame * CFrame.fromEulerAngles(0, 0, math.rad(90)))
		ingredient:PivotTo(spot.CFrame * CFrame.new(0, offset, 0) * CFrame.fromEulerAngles(0, 0, math.rad(90)))
		ingredient.Parent = plate
    end

    local function controlTray(tray: Part, distance: number)
        local targetCFrame  = tray.CFrame *  CFrame.new(0, 0, distance)

        local tweenInfo = TweenInfo.new(
            1.25,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )

        local tween = TweenService:Create(tray, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end

    local CookingStation = self.Model.Parent:FindFirstChild("CookingStation");
    local IngredientsBase = CookingStation:FindFirstChild("IngredientsBase");
    local PlateLocations = CookingStation:FindFirstChild("PlateLocations");

    local defaultSpot = PlateLocations:FindFirstChild("DefaultSpot");
    local doughSpot = PlateLocations:FindFirstChild("DoughSpot");
    local sauceSpot = PlateLocations:FindFirstChild("SauceSpot");
    local cheeseSpot = PlateLocations:FindFirstChild("CheeseSpot");

    local dough = Ingredients:FindFirstChild("Dough"):Clone();
    local sauce = Ingredients:FindFirstChild("Sauce"):Clone();
    local cheese = Ingredients:FindFirstChild("Cheese"):Clone();

    local doughBase = IngredientsBase:FindFirstChild("DoughBase");
    local sauceBase = IngredientsBase:FindFirstChild("SauceBase");
    local cheeseBase = IngredientsBase:FindFirstChild("CheeseBase");

    local oven = CookingStation:FindFirstChild("Oven");
    local tray = oven:FindFirstChild("Tray"):FindFirstChild("OvenTray")

    local plate = PizzaStuff:FindFirstChild("Plate"):Clone();
    plate.Parent = defaultSpot;
    plate:PivotTo(defaultSpot.CFrame * CFrame.fromEulerAngles(0, 0, math.rad(90)));

    waitForStep(doughBase, "Prepare dough");
    shiftIngredients(plate, dough, doughSpot, 0.1);

    waitForStep(sauceBase, "Spread sauce");
    shiftIngredients(plate, sauce, sauceSpot, 0.2);

    waitForStep(cheeseBase, "Sprinkle cheese");
    shiftIngredients(plate, cheese, cheeseSpot, 0.3);

    local plateTool = createPizzaTool(cheeseSpot, plate);
    weldParts(plateTool, plate, dough);
    weldParts(plateTool, dough, sauce);
    weldParts(plateTool, sauce, cheese);

    local player = waitForStep(plateTool:FindFirstChild("Handle"), "Pick up pizza");
    plateTool.Parent = player.Character;

    controlTray(tray, -4.5);
    waitForStep(tray, "Cook Pizza");

    plateTool.Parent = tray
    plateTool:PivotTo(tray.CFrame * CFrame.fromEulerAngles(0, 0, math.rad(90)))
    plateTool:FindFirstChild("Handle"):FindFirstChild("TouchInterest"):Destroy()
    local pizzaTrayWeld = weldParts(tray, plateTool:FindFirstChild("Handle"), tray:FindFirstChild("PizzaSpot"))
    controlTray(tray, 4.5);

    task.wait(1.5);

    controlTray(tray, -4.5);
    waitForStep(plateTool:FindFirstChild("Handle"), "Pick up pizza");
    pizzaTrayWeld:Destroy()
    plateTool.Parent = player.Character;

    task.wait(2.5);

    plateTool:Destroy();
    controlTray(tray, 4.5);
    cheese:Destroy();
    sauce:Destroy();
    dough:Destroy();
    plate:Destroy()
end

function OrderController:Destroy()
    self.Model:Destroy();
end

return OrderController;