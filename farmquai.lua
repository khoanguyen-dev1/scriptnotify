_G.SelectWeapon = "Melee"
_G.FarmEnabled = false -- On/Off farm

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

-- Tên NPC
local npcName = "Oni Soldier"

-- Hàm tìm mob gần nhất
local function FindNearestMob()
    local closest, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if mob:FindFirstChild("HumanoidRootPart") and string.find(mob.Name, npcName) then
                local mag = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if mag < dist then
                    closest, dist = mob, mag
                end
            end
        end
    end
    return closest
end

-- Farm loop
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
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not _G.FarmEnabled then
            -- Nếu OFF farm thì platform chỉ giữ nhân vật đứng yên
            if platform and platform.Parent then
                platform.CFrame = hrp.CFrame * CFrame.new(0, -4, 0)
            end
            continue
        end

        AutoHaki()

        local target = FindNearestMob()
        if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
            -- Farm liên tục cho đến khi mob chết hoặc biến mất
            while _G.FarmEnabled 
                and target.Parent 
                and target:FindFirstChild("Humanoid") 
                and target.Humanoid.Health > 0 
                and target:FindFirstChild("HumanoidRootPart") do

                pcall(function()
                    -- Di chuyển player đứng trên đầu mob
                    hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)

                    -- Cập nhật platform để nhân vật không rớt
                    if platform and platform.Parent then
                        platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
                    end
                end)

                task.wait(0.1)
            end
        end
    end
end)

-- GUI On/Off
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FarmGUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 60)
Frame.Position = UDim2.new(0, 20, 0.5, -30)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Bo góc cho frame
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 1, -10)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "🗡️ Farm: OFF"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = Frame

-- Bo góc cho button
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 5)
BtnCorner.Parent = toggleBtn

-- Hiệu ứng khi click
toggleBtn.MouseButton1Click:Connect(function()
    _G.FarmEnabled = not _G.FarmEnabled
    toggleBtn.Text = _G.FarmEnabled and "⚔️ Farm: ON" or "🗡️ Farm: OFF"
    toggleBtn.BackgroundColor3 = _G.FarmEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    -- Hiệu ứng click
    toggleBtn:TweenSize(UDim2.new(0.95, 0, 0.95, 0), "Out", "Quad", 0.1, true)
    wait(0.1)
    toggleBtn:TweenSize(UDim2.new(1, -10, 1, -10), "Out", "Quad", 0.1, true)
end)

print("🚀 Script loaded successfully!")
