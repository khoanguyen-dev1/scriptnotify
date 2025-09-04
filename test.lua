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
-- Load Fluent UI
-- Load WindUI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fluent_ToggleUI"
ScreenGui.Parent = game.CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -17) -- Bên trái, giữa màn hình
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "K"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 20
ToggleBtn.BorderSizePixel = 0

-- Bo tròn nút
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = ToggleBtn

-- Trạng thái UI
local uiVisible = true

ToggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    Window:Minimize() -- ẩn/hiện Fluent UI như LeftControl
    ToggleBtn.Text = uiVisible and "≡" or "⏷" -- đổi icon nút
end)

local Tabs = {
    Main = Window:AddTab({ Title = "Shop", Icon = "" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "" }),
    Token = Window:AddTab({ Title = "Token", Icon = "" })
}


local function BuyCousin(item)
    local args = {
        [1] = "Cousin",
        [2] = item
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end


Tabs.Main:AddButton({
    Name ="Gacha Summer Token",
    Callback = function() BuyCousin("BuySummer") end
})
Tabs.Main:AddButton({
    Name = "Gacha Fruit",
    Callback = function() BuyCousin("Buy") end
})
Tabs.Main:AddButton({
    Name ="Gacha Oni Token",
    Callback = function() BuyCousin("BuyRedHead") end
})
Tabs.Main:AddButton({
    Name ="Buy Basic bait",
    Callback = function() local args = {
    [1] = "Craft",
    [2] = "Basic Bait",
    [3] = {}
}
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
 end
})
-- Tạo 2 paragraph
local oni = Tabs:Token:AddParagraph({
    Title = "Oni Token",
    Content = "Đang tải..."
})

local summer = Tabs:Token:AddParagraph({
    Title = "Summer Token",
    Content = "Đang tải..."
})

-- Hàm cập nhật số lượng token
local function UpdateTokens()
    local args = { [1] = "getInventory" }
    local inventory = game:GetService("ReplicatedStorage")
        :WaitForChild("Remotes")
        :WaitForChild("CommF_")
        :InvokeServer(unpack(args))

    local oniCount, summerCount = 0, 0

    for _, item in pairs(inventory) do
        if item.Name == "Oni Token" then
            oniCount = item.Count
        elseif item.Name == "Summer Token" then
            summerCount = item.Count
        end
    end

    oni:SetDesc("Oni Token Count: " .. oniCount)
    summer:SetDesc("Summer Token Count: " .. summerCount)
end

-- Gọi 1 lần khi load
UpdateTokens()

-- Nếu muốn tự động refresh
task.spawn(function()
    while task.wait(0.1) do
        UpdateTokens()
    end
end)

----------------------------------------------------------------
-- Tab Farm
Tabs.Farm:AddButton({
    Name = "Teleport",
    Callback = function()
        -- Teleport đến tọa độ
        topos(Vector3.new(-689.4837646484375, 15.393343925476074, 1582.8719482421875))

        -- Đợi chút cho chắc chắn đã đến nơi
        task.wait(0.1)

        -- Gọi server teleport
        local args = {
            [1] = "InitiateTeleportToTemple"
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("Modules")
            :WaitForChild("Net")
            :WaitForChild("RF/OniTempleTransportation")
            :InvokeServer(unpack(args))
    end
})

_G.FarmEnabled = false

Tabs.Farm:AddToggle({
    Name = "Auto Farm Oni Soldier",
    Callback = function(state)
        _G.FarmEnabled = state
    end
})

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
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        local mobs = GetAllMobs()

        if #mobs > 0 and hrp and humanoid then
            local target = FindNearestMob()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local mobHRP = target.HumanoidRootPart

                -- Di chuyển tới mob
                topos(mobHRP.Position)

                -- Giữ mob đứng yên
                pcall(function() mobHRP.Anchored = true end)

                -- Platform di chuyển theo mob
                platform.Transparency = 1
                platform.CFrame = mobHRP.CFrame * CFrame.new(0, 7, 0)

                -- Anchor người chơi trên platform -> không thể di chuyển
                hrp.Anchored = true
                hrp.CFrame = platform.CFrame * CFrame.new(0, 3.5, 0)

                -- Đợi mob chết
                repeat task.wait(0.2) until not target.Parent or target.Humanoid.Health <= 0

                -- Bỏ anchor mob và người chơi
                if mobHRP then mobHRP.Anchored = false end
                hrp.Anchored = false
            end
        else
            -- Không còn mob -> bay về RestPosition
            if hrp then
                local distance = (hrp.Position - RestPosition).Magnitude
                if distance > 1 then
                    hrp.Anchored = false -- Cho phép player tự di chuyển về RestPosition
                    topos(RestPosition)
                    platform.Transparency = 1
                else
                    -- Đã tới RestPosition -> dừng platform, người chơi tự do
                    platform.Transparency = 1
                    hrp.Anchored = false
                end
            end
        end
    end
end)



