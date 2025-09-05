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

-- Tạo Simple UI thay vì Fluent
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local FarmToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local TeleportButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

-- Setup ScreenGui
ScreenGui.Name = "BloxFruitsScript"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Setup MainFrame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Blox Fruits Auto Farm"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true

-- Farm Toggle
FarmToggle.Name = "FarmToggle"
FarmToggle.Parent = MainFrame
FarmToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FarmToggle.Position = UDim2.new(0.05, 0, 0.3, 0)
FarmToggle.Size = UDim2.new(0.9, 0, 0, 35)
FarmToggle.Font = Enum.Font.SourceSans
FarmToggle.Text = "Farm: OFF"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.TextScaled = true

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 5)
farmCorner.Parent = FarmToggle

-- Status Label
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Waiting..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true

-- Teleport Button
TeleportButton.Name = "TeleportButton"
TeleportButton.Parent = MainFrame
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
TeleportButton.Position = UDim2.new(0.05, 0, 0.75, 0)
TeleportButton.Size = UDim2.new(0.9, 0, 0, 35)
TeleportButton.Font = Enum.Font.SourceSans
TeleportButton.Text = "Teleport to Oni"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextScaled = true

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 5)
tpCorner.Parent = TeleportButton

-- Minimize Button
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
MinimizeButton.Position = UDim2.new(0.85, 0, 0, 5)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextScaled = true

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = MinimizeButton

-- Farm Variables
_G.FarmEnabled = false
local isMinimized = false

-- Core Functions
local function BuyCousin(item)
    pcall(function()
        local args = { [1] = "Cousin", [2] = item }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
end

-- Teleport Function
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

-- Button Events
FarmToggle.MouseButton1Click:Connect(function()
    _G.FarmEnabled = not _G.FarmEnabled
    if _G.FarmEnabled then
        FarmToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        FarmToggle.Text = "Farm: ON"
        StatusLabel.Text = "Status: Farming..."
    else
        FarmToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        FarmToggle.Text = "Farm: OFF"
        StatusLabel.Text = "Status: Stopped"
    end
end)

TeleportButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Teleporting..."
    topos(Vector3.new(-689.4838, 15.3933, 1582.8720))
    task.wait(0.1)
    pcall(function()
        local args = { [1] = "InitiateTeleportToTemple" }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Modules")
            :WaitForChild("Net")
            :WaitForChild("RF/OniTempleTransportation")
            :InvokeServer(unpack(args))
    end)
    StatusLabel.Text = "Status: Teleported"
end)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 200)
        MinimizeButton.Text = "-"
    end
end)

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
_G.BringRange = 50
local npcName = "Oni Soldier"
local RestPosition = Vector3.new(-5501.65625, -4166.60205078125, 4013.425048828125)

-- Lấy tất cả Oni Soldier
local function GetAllMobs()
    local mobs = {}
    pcall(function()
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("Humanoid") 
               and mob.Humanoid.Health > 0 
               and mob:FindFirstChild("HumanoidRootPart") 
               and string.find(mob.Name, npcName) then
                table.insert(mobs, mob)
            end
        end
    end)
    return mobs
end

-- Bring Mob Function - CHỈ HOẠT ĐỘNG KHI _G.FarmEnabled = true
local function BringMobs(mobs, platform)
    if not _G.FarmEnabled then return end
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        for _, mob in pairs(mobs) do
            local mh = mob:FindFirstChild("Humanoid")
            local mhrp = mob:FindFirstChild("HumanoidRootPart")
            if mh and mh.Health > 0 and mhrp then
                local dist = (mhrp.Position - hrp.Position).Magnitude
                if dist <= _G.BringRange then
                    mhrp.Size = Vector3.new(50, 50, 50)
                    mhrp.CFrame = platform.CFrame * CFrame.new(0, -3, 0)
                    mh:ChangeState(14)
                    mhrp.CanCollide = false
                    if mob:FindFirstChild("Head") then 
                        mob.Head.CanCollide = false 
                    end
                    if mh:FindFirstChild("Animator") then 
                        mh.Animator:Destroy() 
                    end
                    if sethiddenproperty then
                        sethiddenproperty(player, "SimulationRadius", math.huge)
                    end
                end
            end
        end
    end)
end

-- Reset Mob Properties Function
local function ResetMobProperties()
    pcall(function()
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") and string.find(mob.Name, npcName) then
                local mhrp = mob:FindFirstChild("HumanoidRootPart")
                mhrp.Size = Vector3.new(4, 4, 4)
                mhrp.CanCollide = true
                if mob:FindFirstChild("Head") then 
                    mob.Head.CanCollide = true 
                end
            end
        end
    end)
end

-- Main Farm Loop
local returnedToRest = false
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
                ResetMobProperties()
                if StatusLabel then
                    StatusLabel.Text = "Status: Stopped"
                end
                continue
            end

            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char then continue end

            AutoHaki()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if not hrp or not humanoid then continue end

            local mobs = GetAllMobs()
            if #mobs > 0 then
                returnedToRest = false
                local mainMob = mobs[1]
                local mobHRP = mainMob and mainMob:FindFirstChild("HumanoidRootPart")
                if not mobHRP then continue end

                if StatusLabel then
                    StatusLabel.Text = "Status: Fighting " .. #mobs .. " mobs"
                end

                topos(mobHRP.Position)
                platform.Transparency = 0
                platform.CFrame = mobHRP.CFrame * CFrame.new(0, 7, 0)
                hrp.Anchored = true
                hrp.CFrame = platform.CFrame * CFrame.new(0, 3.5, 0)

                BringMobs(mobs, platform)

                local timeout = 0
                repeat
                    task.wait(0.2)
                    timeout += 0.2
                    local alive = false
                    for _, mob in pairs(mobs) do
                        if mob.Parent and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            alive = true
                            break
                        end
                    end
                    if not alive then break end
                    if not _G.FarmEnabled then
                        ResetMobProperties()
                        break
                    end
                until timeout > 30

                if hrp and hrp.Parent then hrp.Anchored = false end
            else
                if not returnedToRest then
                    returnedToRest = true
                    if StatusLabel then
                        StatusLabel.Text = "Status: No mobs, returning..."
                    end
                    if hrp then
                        hrp.Anchored = false
                        topos(RestPosition)
                    end
                else
                    if StatusLabel then
                        StatusLabel.Text = "Status: Waiting for mobs..."
                    end
                    if hrp then hrp.Anchored = false end
                end
            end
        end)
    end
end)

-- Keyboard shortcuts
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- Toggle farm
        _G.FarmEnabled = not _G.FarmEnabled
        if _G.FarmEnabled then
            FarmToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            FarmToggle.Text = "Farm: ON"
            StatusLabel.Text = "Status: Farming..."
        else
            FarmToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            FarmToggle.Text = "Farm: OFF"
            StatusLabel.Text = "Status: Stopped"
        end
    elseif input.KeyCode == Enum.KeyCode.T then
        -- Teleport
        StatusLabel.Text = "Status: Teleporting..."
        topos(Vector3.new(-689.4838, 15.3933, 1582.8720))
        task.wait(0.1)
        pcall(function()
            local args = { [1] = "InitiateTeleportToTemple" }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Modules")
                :WaitForChild("Net")
                :WaitForChild("RF/OniTempleTransportation")
                :InvokeServer(unpack(args))
        end)
        StatusLabel.Text = "Status: Teleported"
    end
end)

print("=== Blox Fruits Script Loaded ===")
print("F - Toggle Farm")
print("T - Teleport to Oni")
print("Bring Mob chỉ hoạt động khi Farm = ON")
