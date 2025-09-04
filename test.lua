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

local Tabs = {
    Main = Window:AddTab({ Title = "Shop", Icon = "" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "" }),
    Token = Window:AddTab({ Title = "Token", Icon = "" })
}

--// Nút toggle UI ngoài màn hình (giống LeftControl)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fluent_ToggleUI"
ScreenGui.Parent = game.CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -17) -- Bên trái, giữa màn hình
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "≡"
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

local function BuyCousin(item)
    local args = {
        [1] = "Cousin",
        [2] = item
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end


Tabs.Main:AddButton({
    Title ="Gacha Summer Token",
    Callback = function() BuyCousin("BuySummer") end
})
Tabs.Main:AddButton({
    Title = "Gacha Fruit",
    Callback = function() BuyCousin("Buy") end
})
Tabs.Main:AddButton({
    Title ="Gacha Oni Token",
    Callback = function() BuyCousin("BuyRedHead") end
})
Tabs.Main:AddButton({
    Title ="Buy Basic bait",
    Callback = function() local args = {
    [1] = "Craft",
    [2] = "Basic Bait",
    [3] = {}
}
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
 end
})
