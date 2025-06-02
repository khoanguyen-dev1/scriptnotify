-- Sea Auto Farm Script
-- Handles fruit collection, chest farming, and box collection

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local config = {
    farmEnabled = true,
    collectFruits = true,
    collectChests = true,
    collectBoxes = true,
    teleportSpeed = 50,
    farmRadius = 1000,
    autoRespawn = true
}

-- Storage for tracked items
local trackedItems = {}
local isCollecting = false

-- Utility Functions
local function createTween(target, properties, duration)
    local tweenInfo = TweenInfo.new(
        duration or 1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    return TweenService:Create(target, tweenInfo, properties)
end

local function teleportTo(position)
    if not rootPart then return end
    
    local distance = (rootPart.Position - position).Magnitude
    local duration = distance / config.teleportSpeed
    
    local tween = createTween(rootPart, {
        CFrame = CFrame.new(position)
    }, duration)
    
    tween:Play()
    tween.Completed:Wait()
end

local function findNearestItem(itemType)
    local nearestItem = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        local isTargetItem = false
        
        -- Check for different item types
        if itemType == "fruit" and (obj.Name:lower():find("fruit") or obj.Name:lower():find("berry")) then
            isTargetItem = true
        elseif itemType == "chest" and obj.Name:lower():find("chest") then
            isTargetItem = true
        elseif itemType == "box" and obj.Name:lower():find("box") then
            isTargetItem = true
        end
        
        if isTargetItem and obj:IsA("BasePart") then
            local distance = (rootPart.Position - obj.Position).Magnitude
            
            if distance < config.farmRadius and distance < shortestDistance then
                shortestDistance = distance
                nearestItem = obj
            end
        end
    end
    
    return nearestItem, shortestDistance
end

local function collectItem(item)
    if not item or not item.Parent then return false end
    
    -- Teleport to item
    teleportTo(item.Position + Vector3.new(0, 5, 0))
    wait(0.5)
    
    -- Try different collection methods
    local success = false
    
    -- Method 1: Touch detection
    if item.Touched then
        item:TouchInterest()
        success = true
    end
    
    -- Method 2: Click detector
    local clickDetector = item:FindFirstChild("ClickDetector")
    if clickDetector then
        fireclickdetector(clickDetector)
        success = true
    end
    
    -- Method 3: Proximity prompt
    local proximityPrompt = item:FindFirstChild("ProximityPrompt")
    if proximityPrompt then
        fireproximityprompt(proximityPrompt)
        success = true
    end
    
    -- Method 4: Remote events (common in fruit games)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")
    if remotes then
        local collectRemote = remotes:FindFirstChild("CollectFruit") or 
                             remotes:FindFirstChild("Collect") or
                             remotes:FindFirstChild("PickupItem")
        if collectRemote then
            collectRemote:FireServer(item)
            success = true
        end
    end
    
    wait(1)
    return success
end

local function farmLoop()
    while config.farmEnabled do
        if not isCollecting and rootPart then
            isCollecting = true
            
            local itemCollected = false
            
            -- Collect fruits
            if config.collectFruits then
                local fruit, distance = findNearestItem("fruit")
                if fruit then
                    print("Collecting fruit:", fruit.Name)
                    collectItem(fruit)
                    itemCollected = true
                end
            end
            
            -- Collect chests
            if config.collectChests and not itemCollected then
                local chest, distance = findNearestItem("chest")
                if chest then
                    print("Collecting chest:", chest.Name)
                    collectItem(chest)
                    itemCollected = true
                end
            end
            
            -- Collect boxes
            if config.collectBoxes and not itemCollected then
                local box, distance = findNearestItem("box")
                if box then
                    print("Collecting box:", box.Name)
                    collectItem(box)
                    itemCollected = true
                end
            end
            
            isCollecting = false
        end
        
        wait(2) -- Wait between collection cycles
    end
end

-- Auto respawn function
local function setupAutoRespawn()
    if not config.autoRespawn then return end
    
    player.CharacterRemoving:Connect(function()
        wait(1)
        player:LoadCharacter()
    end)
    
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        
        wait(3) -- Wait for character to fully load
    end)
end

-- GUI Creation
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Sea Auto Farm"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    -- Toggle buttons
    local function createToggle(name, yPos, configKey)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 25)
        button.Position = UDim2.new(0.05, 0, 0, yPos)
        button.Text = name .. ": " .. (config[configKey] and "ON" or "OFF")
        button.TextColor3 = config[configKey] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            config[configKey] = not config[configKey]
            button.Text = name .. ": " .. (config[configKey] and "ON" or "OFF")
            button.TextColor3 = config[configKey] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        end)
    end
    
    createToggle("Auto Farm", 40, "farmEnabled")
    createToggle("Collect Fruits", 70, "collectFruits")
    createToggle("Collect Chests", 100, "collectChests")
    createToggle("Collect Boxes", 130, "collectBoxes")
    createToggle("Auto Respawn", 160, "autoRespawn")
end

-- Initialize
local function initialize()
    print("Sea Auto Farm Script Loaded!")
    print("Features: Fruit Collection, Chest Farming, Box Collection")
    
    setupAutoRespawn()
    createGUI()
    
    -- Start farming loop
    spawn(farmLoop)
end

-- Start the script
initialize()
