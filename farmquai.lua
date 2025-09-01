_G.SelectWeapon = "Melee"
_G.BringAllMob = true
_G.BringRange = 100 
_G.FarmEnabled = false -- Trạng thái On/Off

-- Load FastAttack
loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
local LocalPlayer = game.Players.LocalPlayer

-- Chọn team Marines
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


-- Hàm bật Haki
function AutoHaki()
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
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

function EquipWeapon(ToolSe)
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

-- Tên NPC cần farm
local npcName = "Oni Soldier"
local hrp = LocalPlayer.Character.HumanoidRootPart
-- Platform bay
local platform = Instance.new("Part")
platform.Size = Vector3.new(6,1,6)
platform.Anchored = true
platform.CanCollide = true
platform.Material = Enum.Material.WoodPlanks
platform.Transparency = 1
platform.Name = "FlyingPlatform"
platform.CFrame = hrp.CFrame + Vector3.new(0,-5,0)
platform.Parent = workspace

-- Giữ platform theo player
task.spawn(function()
    while task.wait(0.1) do
        if platform and platform.Parent and hrp then
            platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y -5, hrp.Position.Z)
        end
    end
end)

-- Farm loop
task.spawn(function()
    while task.wait(0.5) do
        if not _G.FarmEnabled then continue end
        AutoHaki()

        local char = LocalPlayer.Character
        if not char or not hrp then continue end

        -- Tìm NPC
        local target = nil
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob.Name == npcName and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                target = mob
                break
            end
        end

        if target then
            -- Teleport tới mob
            hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,20,0)

            -- Gom mob lại
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name == npcName 
                and mob:FindFirstChild("Humanoid") 
                and mob:FindFirstChild("HumanoidRootPart") 
                and mob.Humanoid.Health > 0 then
                    mob.HumanoidRootPart.Size = Vector3.new(50,50,50)
                    mob.HumanoidRootPart.CanCollide = false
                    mob.Humanoid:ChangeState(14)
                    if mob:FindFirstChild("Head") then mob.Head.CanCollide = false end
                    if mob.Humanoid:FindFirstChild("Animator") then mob.Humanoid.Animator:Destroy() end
                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)

                    -- Giữ mob ngay dưới platform, không bay lung tung
                    mob.HumanoidRootPart.CFrame = platform.CFrame * CFrame.new(0,5,0)
                    mob.HumanoidRootPart.Anchored = true
                end
            end
        end
    end
end)

-- GUI On/Off
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Size = UDim2.new(0,120,0,40)
toggleBtn.Position = UDim2.new(0.5,-60,0.5,-20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Text = "Farm: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

toggleBtn.MouseButton1Click:Connect(function()
    _G.FarmEnabled = not _G.FarmEnabled
    toggleBtn.Text = _G.FarmEnabled and "Farm: ON" or "Farm: OFF"
    toggleBtn.BackgroundColor3 = _G.FarmEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)
