local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

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
