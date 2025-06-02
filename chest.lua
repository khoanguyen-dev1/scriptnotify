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
    collectFruits = false,
    collectChests = true,
    collectBoxes = false,
    teleportSpeed = 100,
    farmRadius = math.huge, -- Farm toàn bộ server
    autoRespawn = true,
    chestFarmMode = true -- Chế độ farm chest chuyên dụng
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

local function findAllChests()
    local chests = {}
    
    -- Tìm tất cả chest trong server
    for _, obj in pairs(workspace:GetDescendants()) do
        local isChest = false
        
        -- Kiểm tra nhiều loại chest khác nhau
        if obj.Name:lower():find("chest") or 
           obj.Name:lower():find("treasure") or
           obj.Name:lower():find("box") or
           obj.Name:lower():find("crate") or
           obj.Name == "Chest" then
            isChest = true
        end
        
        if isChest and obj:IsA("BasePart") and obj.Parent then
            table.insert(chests, obj)
        end
    end
    
    -- Sắp xếp theo khoảng cách gần nhất
    table.sort(chests, function(a, b)
        local distA = (rootPart.Position - a.Position).Magnitude
        local distB = (rootPart.Position - b.Position).Magnitude
        return distA < distB
    end)
    
    return chests
end

local function collectItem(item)
    if not item or not item.Parent then return false end
    
    print("Đang thu thập: " .. item.Name .. " tại vị trí: " .. tostring(item.Position))
    
    -- Try different collection methods với nhiều cách hơn
    local success = false
    
    -- Method 1: Direct touch
    if item.Touched then
        local connection
        connection = item.Touched:Connect(function(hit)
            if hit.Parent == character then
                connection:Disconnect()
                success = true
            end
        end)
        
        -- Force touch
        firetouchinterest(rootPart, item, 0)
        wait(0.1)
        firetouchinterest(rootPart, item, 1)
        wait(0.5)
        
        if connection then connection:Disconnect() end
    end
    
    -- Method 2: Click detector
    local clickDetector = item:FindFirstChild("ClickDetector") or item:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        fireclickdetector(clickDetector)
        success = true
        wait(0.5)
    end
    
    -- Method 3: Proximity prompt
    local proximityPrompt = item:FindFirstChild("ProximityPrompt") or item:FindFirstChildOfClass("ProximityPrompt")
    if proximityPrompt then
        fireproximityprompt(proximityPrompt)
        success = true
        wait(0.5)
    end
    
    -- Method 4: Remote events (nhiều tên remote khác nhau)
    local function tryFireRemote(remoteName, ...)
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(...)
            return true
        end
        return false
    end
    
    -- Thử nhiều tên remote khác nhau
    local remoteNames = {
        "CollectChest", "Collect", "PickupItem", "TakeChest", 
        "OpenChest", "ClaimChest", "ChestCollect", "GetChest"
    }
    
    for _, remoteName in pairs(remoteNames) do
        if tryFireRemote(remoteName, item) then
            success = true
            break
        end
    end
    
    -- Method 5: Thử tìm remote trong các folder khác nhau
    local remoteFolders = {"Remotes", "Events", "Remote", "RemoteEvents", "Game"}
    for _, folderName in pairs(remoteFolders) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            for _, remoteName in pairs(remoteNames) do
                local remote = folder:FindFirstChild(remoteName)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer(item)
                    success = true
                    break
                end
            end
        end
        if success then break end
    end
    
    print("Thu thập " .. (success and "thành công" or "thất bại") .. ": " .. item.Name)
    wait(0.5)
    return success
end

local function farmAllChests()
    while config.farmEnabled and config.chestFarmMode do
        if not isCollecting and rootPart then
            isCollecting = true
            
            print("Đang tìm kiếm tất cả chest trong server...")
            local allChests = findAllChests()
            
            print("Tìm thấy " .. #allChests .. " chest trong server")
            
            for i, chest in pairs(allChests) do
                if not config.farmEnabled or not config.chestFarmMode then 
                    break 
                end
                
                if chest and chest.Parent then
                    print("Farm chest " .. i .. "/" .. #allChests .. ": " .. chest.Name)
                    
                    -- Teleport đến chest
                    local success = pcall(function()
                        teleportTo(chest.Position + Vector3.new(0, 10, 0))
                    end)
                    
                    if success then
                        wait(0.5)
                        collectItem(chest)
                        wait(1)
                    else
                        print("Không thể teleport đến chest: " .. chest.Name)
                    end
                else
                    print("Chest đã biến mất: " .. tostring(chest))
                end
            end
            
            print("Hoàn thành farm tất cả chest! Chờ chest mới spawn...")
            isCollecting = false
            wait(10) -- Chờ chest mới spawn
        else
            wait(1)
        end
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
    
    createToggle("Farm Tất Cả Chest", 40, "chestFarmMode")
    createToggle("Auto Farm", 70, "farmEnabled")
    createToggle("Thu Thập Fruits", 100, "collectFruits")
    createToggle("Thu Thập Boxes", 130, "collectBoxes")
    createToggle("Auto Respawn", 160, "autoRespawn")
end

-- Initialize
local function initialize()
    print("=== SEA CHEST FARM SCRIPT LOADED ===")
    print("Chế độ: Farm tất cả chest trong server")
    print("Tính năng: Thu thập toàn bộ chest có thể")
    
    setupAutoRespawn()
    createGUI()
    
    -- Start chest farming loop
    spawn(farmAllChests)
end

-- Start the script
initialize()
