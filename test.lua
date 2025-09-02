_G.SelectWeapon = "Melee"

-- Load FastAttack
loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
local LocalPlayer = game.Players.LocalPlayer

-- Auto chọn team Marines
local desiredTeam = "Marines"
game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
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

-- // UI Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Cousin Shop",
    SubTitle = "Fluent UI - khoanguyen-dev",
    TabWidth = 120,
    Size = UDim2.fromOffset(520, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" })
}
local Options = Fluent.Options

-- Hàm gọi server (Main tab)
local function BuyCousin(item)
    local args = {
        [1] = "Cousin",
        [2] = item
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end

Tabs.Main:AddButton({
    Title = "Buy Summer",
    Description = "Mua Cousin Summer",
    Callback = function() BuyCousin("BuySummer") end
})
Tabs.Main:AddButton({
    Title = "Buy Normal",
    Description = "Mua Cousin thường",
    Callback = function() BuyCousin("Buy") end
})
Tabs.Main:AddButton({
    Title = "Buy Red Head",
    Description = "Mua Cousin Red Head",
    Callback = function() BuyCousin("BuyRedHead") end
})

----------------------------------------------------------------
-- Tab Farm

_G.FarmEnabled = false

-- Hàm bật Haki
local function AutoHaki()
    if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

-- Danh sách melee
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
    if not ToolSe then return end
    if not isMeleeWeapon(ToolSe) then return end
    local backpack = LocalPlayer.Backpack
    local tool = backpack:FindFirstChild(ToolSe)
    if tool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

-- Auto Equip
task.spawn(function()
    while task.wait(0.5) do
        if _G.SelectWeapon == "Melee" and _G.FarmEnabled then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and isMeleeWeapon(tool.Name) then
                    EquipWeapon(tool.Name)
                    break
                end
            end
        end
    end
end)

-- Tween function
local TweenService = game:GetService("TweenService")
local function topos(Pos)
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
end

-- Tên NPC farm
local npcName = "Oni Soldier"

-- Lấy mob
local function GetAllMobs()
    local mobs = {}
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if mob:FindFirstChild("HumanoidRootPart") and string.find(mob.Name, npcName) then
                table.insert(mobs, mob)
            end
        end
    end
    return mobs
end

local function FindNearestMob()
    local closest, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, mob in pairs(GetAllMobs()) do
        local mag = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
        if mag < dist then
            closest, dist = mob, mag
        end
    end
    return closest
end

-- Farm loop
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
        if not _G.FarmEnabled then
            platform.Transparency = 1
            continue
        end

        AutoHaki()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local mobs = GetAllMobs()

        if #mobs > 0 and hrp then
            local target = FindNearestMob()
            if target then
                topos(target.HumanoidRootPart.Position)
                pcall(function() target.HumanoidRootPart.Anchored = true end)

                -- Platform bay theo mob
                platform.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                platform.Transparency = 1

                -- Ghép người chơi lên trên platform, khóa vị trí
                hrp.CFrame = platform.CFrame * CFrame.new(0, 3.5, 0)
                hrp.Anchored = true

                -- Đợi mob chết
                repeat task.wait(0.2) until not target.Parent or target.Humanoid.Health <= 0

                -- Bỏ anchor cho mob
                if target and target:FindFirstChild("HumanoidRootPart") then
                    target.HumanoidRootPart.Anchored = false
                end
            end
        else
            if hrp then
                local distance = (hrp.Position - RestPosition).Magnitude
                if distance > 1 then
                    topos(RestPosition)
                    platform.Transparency = 1
                    hrp.CFrame = platform.CFrame * CFrame.new(0, 3.5, 0)
                    hrp.Anchored = true
                else
                    platform.Transparency = 1
                    hrp.Anchored = false -- cho phép tự do khi không farm
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- Gắn UI vào Tab Farm

Tabs.Farm:AddToggle("FarmToggle", {
    Title = "Auto Farm Oni Soldier",
    Default = false,
    Callback = function(state)
        _G.FarmEnabled = state
    end
})

----------------------------------------------------------------
-- Nút On/Off ngoài UI Fluent

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToggleUI"
ScreenGui.Parent = game.CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 60, 0, 30)
ToggleBtn.Position = UDim2.new(1, -80, 0, 120) -- Góc phải trên
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Text = "On"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Active = true
ToggleBtn.Draggable = true -- Kéo thả

local uiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if uiVisible then
        Window:Show()
        ToggleBtn.Text = "On"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
    else
        Window:Hide()
        ToggleBtn.Text = "Off"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    end
end)
