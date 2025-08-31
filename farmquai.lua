_G.SelectWeapon = "Melee"
_G.BringAllMob = true
_G.BringRange = 100
_G.Enabled = false -- Ban đầu tắt

loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")

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

function AutoHaki()
    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

local meleeList = {
    "Combat", "Black Leg", "Electro", "Fishman Karate", "Dragon Claw",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", 
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

local function isMeleeWeapon(toolName)
    for _, name in ipairs(meleeList) do
        if toolName == name then
            return true
        end
    end
    return false
end

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

task.spawn(function()
    while true do
        if _G.Enabled and _G.SelectWeapon == "Melee" then
            local player = game.Players.LocalPlayer
            local backpack = player.Backpack

            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and isMeleeWeapon(tool.Name) then
                    EquipWeapon(tool.Name)
                    break
                end
            end
        end
        task.wait(0.2)
    end
end)

-- ======================================
-- AUTO FARM NPC
-- ======================================
local npcName = "Oni Soldier"
local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

-- Hàm tìm mob gần nhất
function FindNearestMob(npcName)
    local target = nil
    local shortest = math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == npcName 
        and mob:FindFirstChild("Humanoid") 
        and mob:FindFirstChild("HumanoidRootPart") 
        and mob.Humanoid.Health > 0 then
            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                target = mob
            end
        end
    end
    return target
end

-- Platform bay
function CreatePlatform()
    if workspace:FindFirstChild("FlyingPlatform") then return workspace.FlyingPlatform end

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 1, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.WoodPlanks
    platform.Transparency = 1
    platform.Name = "FlyingPlatform"
    platform.CFrame = hrp.CFrame + Vector3.new(0, -5, 0)
    platform.Parent = workspace

    task.spawn(function()
        while _G.Enabled and platform.Parent do
            task.wait(0.1)
            if hrp then
                platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
            end
        end
    end)
    return platform
end

-- Auto farm loop
spawn(function()
    while task.wait(1) do
        if _G.Enabled then
            AutoHaki()
            local mob = FindNearestMob(npcName)
            if mob then
                -- Bay đến mob
                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)

                local platform = CreatePlatform()

                -- Gom mob
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == npcName 
                    and v:FindFirstChild("Humanoid") 
                    and v:FindFirstChild("HumanoidRootPart") 
                    and v.Humanoid.Health > 0 then
                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid:ChangeState(14)
                        if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                        if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)

                        v.HumanoidRootPart.CFrame = platform.CFrame * CFrame.new(0, 3, 0)
                    end
                end
            end
        end
    end
end)

-- ======================================
-- UI BUTTON ON/OFF
-- ======================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton")

ToggleButton.Size = UDim2.new(0, 150, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -75, 0.5, -25)
ToggleButton.Text = "Start Farm"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    _G.Enabled = not _G.Enabled
    if _G.Enabled then
        ToggleButton.Text = "Stop Farm"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "Start Farm"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)
