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
-- Tạo nút nhỏ ON/OFF
local ScreenGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- đỏ = Off
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.12, 0, 0.1, 0)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Draggable = true
ImageButton.AutoButtonColor = false
ImageButton.Image = "" -- bỏ hình ảnh

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ImageButton

-- Trạng thái
local isOn = true -- mặc định hiển thị window

ImageButton.MouseButton1Click:Connect(function()
    isOn = not isOn
    if isOn then
        ImageButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- xanh = On
        Window:Minimize(false) -- hiện lại Window
    else
        ImageButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- đỏ = Off
        Window:Minimize(true) -- ẩn Window
    end
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
    -- Các button cho Main Tab
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

    Tabs.Main:AddButton({
        Title = "Buy Basic bait",
        Description = "Craft Basic Bait",
        Callback = function()
            local args = {
                [1] = "Craft",
                [2] = "Basic Bait",
                [3] = {}
            }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Modules")
                :WaitForChild("Net")
                :WaitForChild("RF")
                :WaitForChild("Craft")
                :InvokeServer(unpack(args))
        end
    })
end

-- Token Display (Simple version)
if Tabs.Token then
    local oni = Tabs.Token:AddParagraph({
        Title = "Oni Token",
        Content = "Đang tải..."
    })

    local summer = Tabs.Token:AddParagraph({
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
        while task.wait(0.5) do -- refresh mỗi 0.5s cho nhẹ
            UpdateTokens()
        end
    end)
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
            topos(Vector3.new(-689.4838, 15.3933, 1582.8720))
            task.wait(0.1)
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
end




-- Farm Variables
_G.FarmEnabled = false

-- Add farm toggle
if Tabs.Farm then
   local Toggle = Tabs.Farm:AddToggle("MyToggle", {Title = "Auto Farm Oni Soldier", Default = false })
    Toggle:OnChanged(function(Value)
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
