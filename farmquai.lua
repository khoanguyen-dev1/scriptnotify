_G.SelectWeapon = "Melee"
_G.BringAllMob = true
_G.BringRange = 100
_G.ScriptEnabled = false -- ✅ Bật/Tắt toàn bộ script

-- FastAttack
loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")

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

-- Auto Haki
function AutoHaki()
    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

-- Danh sách melee
local meleeList = {
    "Combat", "Black Leg", "Electro", "Fishman Karate", "Dragon Claw",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", 
    "Dragon Talon", "Godhuman", "Sanguine Art"
}
local function isMeleeWeapon(toolName)
    for _, name in ipairs(meleeList) do
        if toolName == name then return true end
    end
    return false
end

-- Equip vũ khí
function EquipWeapon(ToolSe)
    if not ToolSe then return end
    if not isMeleeWeapon(ToolSe) then return end
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local tool = backpack:FindFirstChild(ToolSe)
    if tool and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:EquipTool(tool)
    end
end

-- Auto equip loop
task.spawn(function()
    while task.wait(0.1) do
        if not _G.ScriptEnabled then continue end
        if _G.SelectWeapon == "Melee" then
            local player = game.Players.LocalPlayer
            local backpack = player.Backpack
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and isMeleeWeapon(tool.Name) then
                    EquipWeapon(tool.Name)
                    break
                end
            end
        end
    end
end)

-- Tên quái cần đánh
local npcName = "Oni Soldier [Lv. 3000]"

spawn(function()
    local player = game.Players.LocalPlayer
    local hrp = player.Character:WaitForChild("HumanoidRootPart")

    -- Platform dưới nhân vật
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 1, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.WoodPlanks
    platform.Transparency = 1
    platform.Name = "FlyingPlatform"
    platform.CFrame = hrp.CFrame + Vector3.new(0, -5, 0)
    platform.Parent = workspace

    -- Cập nhật vị trí platform
    task.spawn(function()
        while task.wait(0.1) do
            if not _G.ScriptEnabled then continue end
            if platform and platform.Parent and hrp then
                platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
            else
                break
            end
        end
    end)

    -- BringAllMob loop
    while task.wait(0.5) do
        if not _G.ScriptEnabled then continue end
        pcall(function()
            if not _G.BringAllMob then return end
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name == npcName 
                and mob:FindFirstChild("Humanoid") 
                and mob:FindFirstChild("HumanoidRootPart") 
                and mob.Humanoid.Health > 0 then

                    local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= _G.BringRange then
                        mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        mob.HumanoidRootPart.CanCollide = false
                        mob.Humanoid:ChangeState(14)
                        if mob:FindFirstChild("Head") then mob.Head.CanCollide = false end
                        if mob.Humanoid:FindFirstChild("Animator") then mob.Humanoid.Animator:Destroy() end
                        sethiddenproperty(player, "SimulationRadius", math.huge)

                        mob.HumanoidRootPart.CFrame = platform.CFrame * CFrame.new(0, 3, 0)

                        -- Label "Target"
                        if mob:FindFirstChild("Head") and not mob.Head:FindFirstChild("TargetBillboard") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "TargetBillboard"
                            billboard.Size = UDim2.new(0, 200, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = mob.Head

                            local textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Text = "Target"
                            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextScaled = true
                            textLabel.Parent = billboard
                        end
                    end
                end
            end
        end)
    end
end)

-------------------------------------------------
-- UI Toggle ON/OFF giữa màn hình
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MainToggleUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 160, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -80, 0.5, -25) -- Giữa màn hình
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Script: ON"
ToggleButton.Parent = ScreenGui
ToggleButton.Visible = true

local function updateButton()
    if _G.ScriptEnabled then
        ToggleButton.Text = "Script: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        ToggleButton.Text = "Script: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    _G.ScriptEnabled = not _G.ScriptEnabled
    updateButton()
end)

updateButton()
