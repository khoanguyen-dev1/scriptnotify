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
    pcall(function()
        if not LocalPlayer.Character:FindFirstChild("HasBuso") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end
    end)
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
    pcall(function()
        if not ToolSe then return end
        if not isMeleeWeapon(ToolSe) then return end
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
        if _G.SelectWeapon == "Melee" and _G.FarmEnabled then
            pcall(function()
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and isMeleeWeapon(tool.Name) then
                        EquipWeapon(tool.Name)
                        break
                    end
                end
            end)
        end
    end
end)

-- Tên NPC cần farm
local npcName = "Oni Soldier"
local platform = nil

-- Hàm di chuyển mượt mà
local function topos(Pos)
    local Player = game.Players.LocalPlayer
    local HRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local rawPosition = typeof(Pos) == "Vector3" and Pos or (Pos.Position or Pos.p)
    local targetPosition = rawPosition + Vector3.new(0, 8, 0) -- Player cao hơn quái 8 studs
    local Distance = (targetPosition - HRP.Position).Magnitude
    
    -- Nếu quá gần thì không cần tween
    if Distance < 5 then
        HRP.CFrame = CFrame.new(targetPosition)
        return
    end
    
    local Speed = 300 -- Tốc độ di chuyển
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local tween = tweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    
    tween:Play()
    -- Không wait để không block code
end

-- Hàm tạo platform cho player đứng
local function createStandPlatform()
    if platform and platform.Parent then
        platform:Destroy()
    end
    
    pcall(function()
        local hrp = LocalPlayer.Character.HumanoidRootPart
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 1, 6) -- Đủ rộng để đứng
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.Neon
        platform.BrickColor = BrickColor.new("Bright blue")
        platform.Transparency = 0.7
        platform.Name = "StandPlatform"
        platform.CFrame = hrp.CFrame + Vector3.new(0, -3, 0) -- Dưới chân player
        platform.Parent = workspace
        
        -- Thêm ánh sáng cho đẹp
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(0, 150, 255)
        light.Brightness = 1
        light.Range = 10
        light.Parent = platform
    end)
end

-- Hàm gom mob về dưới platform
local function bringMobs()
    if not _G.BringAllMob or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    pcall(function()
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob.Name == npcName 
            and mob:FindFirstChild("Humanoid") 
            and mob:FindFirstChild("HumanoidRootPart") 
            and mob.Humanoid.Health > 0 then
                
                local distance = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distance <= _G.BringRange then
                    -- Tối ưu hóa mob
                    mob.HumanoidRootPart.Size = Vector3.new(60,60,60)
                    mob.HumanoidRootPart.CanCollide = false
                    mob.Humanoid:ChangeState(14)
                    
                    if mob:FindFirstChild("Head") then 
                        mob.Head.CanCollide = false 
                    end
                    
                    if mob.Humanoid:FindFirstChild("Animator") then 
                        mob.Humanoid.Animator:Destroy() 
                    end
                    
                    -- Đưa mob về DƯỚI platform (player ở trên, mob ở dưới)
                    mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(
                        math.random(-3,3), 
                        -8, -- Dưới platform, tầm đánh của player
                        math.random(-3,3)
                    )
                    mob.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    mob.HumanoidRootPart.Anchored = true -- Giữ cố định
                end
            end
        end
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end

-- Farm loop chính
task.spawn(function()
    while task.wait(0.2) do -- Tăng delay để tween hoạt động mượt
        if not _G.FarmEnabled then 
            if platform and platform.Parent then
                platform:Destroy()
                platform = nil
            end
            continue 
        end
        
        pcall(function()
            AutoHaki()
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then return end

            -- Tìm NPC gần nhất
            local target = nil
            local nearestDistance = math.huge
            
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name == npcName 
                and mob:FindFirstChild("Humanoid") 
                and mob:FindFirstChild("HumanoidRootPart") 
                and mob.Humanoid.Health > 0 then
                    
                    local distance = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        target = mob
                    end
                end
            end

            if target then
                -- Sử dụng topos để di chuyển mượt mà (player sẽ ở cao hơn mob 8 studs)
                if nearestDistance > 10 then -- Chỉ tween khi cần thiết
                    topos(target.HumanoidRootPart.Position)
                end
                
                -- Tạo StandPlatform cho player đứng nếu chưa có
                if not platform or not platform.Parent then
                    createStandPlatform()
                end
                
                -- Cập nhật platform theo vị trí player (platform luôn dưới chân player)
                if platform and platform.Parent then
                    platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
                end
                
                -- Gom tất cả mob về dưới platform (player trên, mob dưới)
                bringMobs()
            else
                -- Không có mob thì xóa platform
                if platform and platform.Parent then
                    platform:Destroy()
                    platform = nil
                end
            end
        end)
    end
end)

-- GUI On/Off với thiết kế đẹp hơn
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
print("📍 Target: " .. npcName)
print("⚡ Click button to toggle farming!")
