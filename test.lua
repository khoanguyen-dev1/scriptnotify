_G.SelectWeapon = "Melee"

-- Load FastAttack with error handling
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()
end)

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local LocalPlayer = game.Players.LocalPlayer

-- Auto chọn team Marines
local desiredTeam = "Marines"
pcall(function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
end)

repeat
    task.wait(1)
    local chooseTeam = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ChooseTeam", true)
    local uiController = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("UIController", true)
    if chooseTeam and chooseTeam.Visible and uiController then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and getfenv(v).script == uiController then
                local constant = getconstants(v)
                pcall(function()
                    if (constant[1] == "Pirates" or constant[1] == "Marines") and #constant == 1 then
                        if constant[1] == desiredTeam then
                            v(desiredTeam)
                        end
                    end
                end)
            end
        end
    end
until LocalPlayer.Team and LocalPlayer.Team.Name == desiredTeam

-- Create Simple UI (Backup solution)
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleUI"
    ScreenGui.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Blox Fruits Script"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame
    
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame
    
    return ScreenGui, ScrollFrame
end

-- Try to load Fluent UI, fallback to simple UI
local Window, Tabs = nil, {}
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if success and Fluent then
    -- Try to create Fluent UI
    local windowSuccess = pcall(function()
        Window = Fluent:CreateWindow({
            Title = "Blox Fruits Script",
            SubTitle = "Auto Farm",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true,
            Theme = "Dark",
            MinimizeKey = Enum.KeyCode.LeftControl
        })
        
        if Window then
            Tabs.Main = Window:AddTab({ Title = "Shop", Icon = "" })
            Tabs.Farm = Window:AddTab({ Title = "Farm", Icon = "" })
            Tabs.Token = Window:AddTab({ Title = "Token", Icon = "" })
        end
    end)
    
    if not windowSuccess then
        Window = nil
    end
end

-- Use simple UI if Fluent failed
local SimpleUI, SimpleScrollFrame = nil, nil
if not Window then
    print("Fluent UI failed, using simple UI")
    SimpleUI, SimpleScrollFrame = CreateSimpleUI()
end

-- UI Helper Functions
local function CreateSimpleButton(text, callback)
    if not SimpleScrollFrame then return end
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = text
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.Parent = SimpleScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    -- Update scroll frame size
    SimpleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #SimpleScrollFrame:GetChildren() * 40)
end

local function CreateSimpleToggle(text, callback)
    if not SimpleScrollFrame then return end
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.Parent = SimpleScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 25)
    ToggleButton.Position = UDim2.new(1, -70, 0.5, -12)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Parent = ToggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = ToggleButton
    
    local isToggled = false
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            ToggleButton.Text = "ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            ToggleButton.Text = "OFF"
        end
        callback(isToggled)
    end)
    
    -- Update scroll frame size
    SimpleScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #SimpleScrollFrame:GetChildren() * 40)
end

-- Toggle UI Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -17)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "≡"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 20
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = game.CoreGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = ToggleBtn

local uiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if Window then
        pcall(function() Window:Minimize() end)
    elseif SimpleUI then
        SimpleUI.Enabled = uiVisible
    end
    ToggleBtn.Text = uiVisible and "≡" or "⏷"
end)

-- Core Functions
local function BuyCousin(item)
    pcall(function()
        local args = { [1] = "Cousin", [2] = item }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
end

-- Add UI Elements
if Tabs.Main then
    -- Fluent UI
    Tabs.Main:AddButton({
        Title = "Gacha Summer Token",
        Description = "Summer Token",
        Callback = function() BuyCousin("BuySummer") end
    })
    Tabs.Main:AddButton({
        Title = "Gacha Fruit",
        Description = "Money",
        Callback = function() BuyCousin("Buy") end
    })
    Tabs.Main:AddButton({
        Title = "Gacha Oni Token",
        Description = "Oni Token",
        Callback = function() BuyCousin("BuyRedHead") end
    })
else
    -- Simple UI
    CreateSimpleButton("Gacha Summer Token", function() BuyCousin("BuySummer") end)
    CreateSimpleButton("Gacha Fruit", function() BuyCousin("Buy") end)
    CreateSimpleButton("Gacha Oni Token", function() BuyCousin("BuyRedHead") end)
    CreateSimpleButton("Buy Basic Bait", function()
        pcall(function()
            local args = { [1] = "Craft", [2] = "Basic Bait", [3] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
        end)
    end)
end

-- Token Display (Simple version)
if not Tabs.Token then
    -- Create simple token display
    if SimpleScrollFrame then
        local TokenFrame = Instance.new("Frame")
        TokenFrame.Size = UDim2.new(1, 0, 0, 60)
        TokenFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TokenFrame.Parent = SimpleScrollFrame
        
        local tokenCorner = Instance.new("UICorner")
        tokenCorner.CornerRadius = UDim.new(0, 5)
        tokenCorner.Parent = TokenFrame
        
        local OniLabel = Instance.new("TextLabel")
        OniLabel.Size = UDim2.new(1, -20, 0.5, 0)
        OniLabel.Position = UDim2.new(0, 10, 0, 5)
        OniLabel.BackgroundTransparency = 1
        OniLabel.Text = "Oni Token: Loading..."
        OniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        OniLabel.TextSize = 14
        OniLabel.Font = Enum.Font.SourceSans
        OniLabel.TextXAlignment = Enum.TextXAlignment.Left
        OniLabel.Parent = TokenFrame
        
        local SummerLabel = Instance.new("TextLabel")
        SummerLabel.Size = UDim2.new(1, -20, 0.5, 0)
        SummerLabel.Position = UDim2.new(0, 10, 0.5, 0)
        SummerLabel.BackgroundTransparency = 1
        SummerLabel.Text = "Summer Token: Loading..."
        SummerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SummerLabel.TextSize = 14
        SummerLabel.Font = Enum.Font.SourceSans
        SummerLabel.TextXAlignment = Enum.TextXAlignment.Left
        SummerLabel.Parent = TokenFrame
        
        -- Update tokens function
        local function UpdateTokens()
            pcall(function()
                local args = { [1] = "getInventory" }
                local inventory = game:GetService("ReplicatedStorage")
                    :WaitForChild("Remotes")
                    :WaitForChild("CommF_")
                    :InvokeServer(unpack(args))

                local oniCount, summerCount = 0, 0
                if inventory then
                    for _, item in pairs(inventory) do
                        if item.Name == "Oni Token" then
                            oniCount = item.Count
                        elseif item.Name == "Summer Token" then
                            summerCount = item.Count
                        end
                    end
                end

                OniLabel.Text = "Oni Token: " .. oniCount
                SummerLabel.Text = "Summer Token: " .. summerCount
            end)
        end

        UpdateTokens()
        task.spawn(function()
            while task.wait(5) do
                UpdateTokens()
            end
        end)
    end
end

-- Teleport and Farm Functions
local TweenService = game:GetService("TweenService")
local function topos(Pos)
    pcall(function()
        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        local rawPosition = typeof(Pos) == "Vector3" and Pos or (Pos.Position or Pos.p)
        local targetPosition = rawPosition + Vector3.new(0, 10, 0)
        local Distance = (targetPosition - HRP.Position).Magnitude
        local Speed = 300
        local tweenInfo = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(targetPosition)})
        tween:Play()
        tween.Completed:Wait()
    end)
end

-- Add teleport button
if Tabs.Farm then
    Tabs.Farm:AddButton({
        Title = "Teleport to Oni Claim",
        Description = "Teleport",
        Callback = function()
            topos(Vector3.new(-689.4837646484375, 15.393343925476074, 1582.8719482421875))
            task.wait(0.1)
            pcall(function()
                local args = { [1] = "InitiateTeleportToTemple" }
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Modules")
                    :WaitForChild("Net")
                    :WaitForChild("RF/OniTempleTransportation")
                    :InvokeServer(unpack(args))
            end)
        end
    })
else
    CreateSimpleButton("Teleport to Oni Claim", function()
        topos(Vector3.new(-689.4837646484375, 15.393343925476074, 1582.8719482421875))
        task.wait(0.1)
        pcall(function()
            local args = { [1] = "InitiateTeleportToTemple" }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Modules")
                :WaitForChild("Net")
                :WaitForChild("RF/OniTempleTransportation")
                :InvokeServer(unpack(args))
        end)
    end)
end

-- Farm Variables
_G.FarmEnabled = false

-- Add farm toggle
if Tabs.Farm then
    local Toggle = Tabs.Farm:AddToggle({
        Title = "Auto Farm Oni Soldier",
        Default = false
    })
    Toggle:OnChanged(function(Value)
        _G.FarmEnabled = Value
    end)
else
    CreateSimpleToggle("Auto Farm Oni Soldier", function(Value)
        _G.FarmEnabled = Value
    end)
end

-- Auto Haki Function
local function AutoHaki()
    pcall(function()
        if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

-- Melee Functions
local meleeList = {
    "Combat","Black Leg","Electro","Fishman Karate","Dragon Claw",
    "Superhuman","Death Step","Sharkman Karate","Electric Claw",
    "Dragon Talon","Godhuman","Sanguine Art"
}

local function isMeleeWeapon(toolName)
    for _, name in ipairs(meleeList) do
        if toolName == name then return true end
    end
    return false
end

local function EquipWeapon(ToolSe)
    pcall(function()
        if not ToolSe or not isMeleeWeapon(ToolSe) then return end
        local backpack = LocalPlayer.Backpack
        local tool = backpack:FindFirstChild(ToolSe)
        if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
        end
    end)
end

-- Auto Equip
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.SelectWeapon == "Melee" and _G.FarmEnabled then
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and isMeleeWeapon(tool.Name) then
                        EquipWeapon(tool.Name)
                        break
                    end
                end
            end
        end)
    end
end)

-- Mob Functions
local npcName = "Oni Soldier"

local function GetAllMobs()
    local mobs = {}
    pcall(function()
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                if mob:FindFirstChild("HumanoidRootPart") and string.find(mob.Name, npcName) then
                    table.insert(mobs, mob)
                end
            end
        end
    end)
    return mobs
end

local function FindNearestMob()
    local closest, dist = nil, math.huge
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, mob in pairs(GetAllMobs()) do
            local mag = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if mag < dist then
                closest, dist = mob, mag
            end
        end
    end)
    return closest
end

-- Main Farm Loop
local RestPosition = Vector3.new(-5501.65625, -4166.60205078125, 4013.425048828125)
task.spawn(function()
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 1, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.WoodPlanks
    platform.Transparency = 1
    platform.Name = "FlyingPlatform"
    platform.Parent = workspace

    while task.wait(0.2) do
        pcall(function()
            if not _G.FarmEnabled then
                platform.Transparency = 1
                return
            end

            if not LocalPlayer.Character then return end
            
            AutoHaki()
            local character = LocalPlayer.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if not hrp or not humanoid then return end
            
            local mobs = GetAllMobs()

            if #mobs > 0 then
                local target = FindNearestMob()
                if target and target.Parent and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
                    local mobHRP = target.HumanoidRootPart
                    local mobHumanoid = target.Humanoid
                    
                    if mobHumanoid.Health <= 0 then return end

                    topos(mobHRP.Position)

                    pcall(function() 
                        if mobHRP then mobHRP.Anchored = true end
                    end)

                    pcall(function()
                        platform.Transparency = 1
                        platform.CFrame = mobHRP.CFrame * CFrame.new(0, 7, 0)
                    end)

                    pcall(function()
                        if hrp then
                            hrp.Anchored = true
                            hrp.CFrame = platform.CFrame * CFrame.new(0, 3.5, 0)
                        end
                    end)

                    local timeout = 0
                    repeat 
                        task.wait(0.2)
                        timeout = timeout + 0.2
                        if timeout > 30 then break end
                    until not target.Parent or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0

                    pcall(function() 
                        if mobHRP and mobHRP.Parent then mobHRP.Anchored = false end
                    end)
                    pcall(function() 
                        if hrp and hrp.Parent then hrp.Anchored = false end
                    end)
                end
            else
                if hrp then
                    local distance = (hrp.Position - RestPosition).Magnitude
                    if distance > 1 then
                        pcall(function() hrp.Anchored = false end)
                        topos(RestPosition)
                        platform.Transparency = 1
                    else
                        platform.Transparency = 1
                        pcall(function() hrp.Anchored = false end)
                    end
                end
            end
        end)
    end
end)

print("Script loaded successfully!")
