-- Blox Fruits Chest Farm Script với UI
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Variables
local ChestCount = 0
local CollectedChests = {}
local Sea2 = true
local CurrentIsland = 1
local VisitedIslands = {}
local FinishedCycle = false
local AutoFarmEnabled = false
local desiredTeam = "Marines"

-- UI Creation
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TeamFrame = Instance.new("Frame")
    local TeamLabel = Instance.new("TextLabel")
    local MarinesButton = Instance.new("TextButton")
    local PiratesButton = Instance.new("TextButton")
    local ControlFrame = Instance.new("Frame")
    local StartButton = Instance.new("TextButton")
    local StopButton = Instance.new("TextButton")
    local HopServerButton = Instance.new("TextButton")
    local StatusFrame = Instance.new("Frame")
    local StatusLabel = Instance.new("TextLabel")
    local ChestCountLabel = Instance.new("TextLabel")
    local CurrentTeamLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local MinimizeButton = Instance.new("TextButton")
    
    -- Properties
    ScreenGui.Name = "ChestFarmUI"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Corner rounding
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, -80, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🏴‍☠️ Blox Fruits Chest Farm"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    
    -- Close Button
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    CloseButton.Position = UDim2.new(1, -70, 0, 10)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton
    
    -- Minimize Button
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = MainFrame
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    MinimizeButton.Position = UDim2.new(1, -110, 0, 10)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 14
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 5)
    MinimizeCorner.Parent = MinimizeButton
    
    -- Team Selection Frame
    TeamFrame.Name = "TeamFrame"
    TeamFrame.Parent = MainFrame
    TeamFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TeamFrame.Position = UDim2.new(0, 20, 0, 70)
    TeamFrame.Size = UDim2.new(1, -40, 0, 100)
    
    local TeamCorner = Instance.new("UICorner")
    TeamCorner.CornerRadius = UDim.new(0, 8)
    TeamCorner.Parent = TeamFrame
    
    TeamLabel.Parent = TeamFrame
    TeamLabel.BackgroundTransparency = 1
    TeamLabel.Position = UDim2.new(0, 10, 0, 5)
    TeamLabel.Size = UDim2.new(1, -20, 0, 25)
    TeamLabel.Font = Enum.Font.Gotham
    TeamLabel.Text = "🎯 Chọn Phe:"
    TeamLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamLabel.TextSize = 14
    TeamLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Marines Button
    MarinesButton.Name = "MarinesButton"
    MarinesButton.Parent = TeamFrame
    MarinesButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    MarinesButton.Position = UDim2.new(0, 10, 0, 35)
    MarinesButton.Size = UDim2.new(0.45, -5, 0, 50)
    MarinesButton.Font = Enum.Font.GothamBold
    MarinesButton.Text = "⚓ Hải Quân"
    MarinesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MarinesButton.TextSize = 14
    
    local MarinesCorner = Instance.new("UICorner")
    MarinesCorner.CornerRadius = UDim.new(0, 5)
    MarinesCorner.Parent = MarinesButton
    
    -- Pirates Button
    PiratesButton.Name = "PiratesButton"
    PiratesButton.Parent = TeamFrame
    PiratesButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    PiratesButton.Position = UDim2.new(0.55, 5, 0, 35)
    PiratesButton.Size = UDim2.new(0.45, -15, 0, 50)
    PiratesButton.Font = Enum.Font.GothamBold
    PiratesButton.Text = "🏴‍☠️ Hải Tặc"
    PiratesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PiratesButton.TextSize = 14
    
    local PiratesCorner = Instance.new("UICorner")
    PiratesCorner.CornerRadius = UDim.new(0, 5)
    PiratesCorner.Parent = PiratesButton
    
    -- Control Frame
    ControlFrame.Name = "ControlFrame"
    ControlFrame.Parent = MainFrame
    ControlFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ControlFrame.Position = UDim2.new(0, 20, 0, 190)
    ControlFrame.Size = UDim2.new(1, -40, 0, 120)
    
    local ControlCorner = Instance.new("UICorner")
    ControlCorner.CornerRadius = UDim.new(0, 8)
    ControlCorner.Parent = ControlFrame
    
    -- Start Button
    StartButton.Name = "StartButton"
    StartButton.Parent = ControlFrame
    StartButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
    StartButton.Position = UDim2.new(0, 10, 0, 10)
    StartButton.Size = UDim2.new(1, -20, 0, 30)
    StartButton.Font = Enum.Font.GothamBold
    StartButton.Text = "🚀 Bắt Đầu Farm"
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.TextSize = 14
    
    local StartCorner = Instance.new("UICorner")
    StartCorner.CornerRadius = UDim.new(0, 5)
    StartCorner.Parent = StartButton
    
    -- Stop Button
    StopButton.Name = "StopButton"
    StopButton.Parent = ControlFrame
    StopButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    StopButton.Position = UDim2.new(0, 10, 0, 50)
    StopButton.Size = UDim2.new(1, -20, 0, 30)
    StopButton.Font = Enum.Font.GothamBold
    StopButton.Text = "⏹️ Dừng Farm"
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.TextSize = 14
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 5)
    StopCorner.Parent = StopButton
    
    -- Hop Server Button
    HopServerButton.Name = "HopServerButton"
    HopServerButton.Parent = ControlFrame
    HopServerButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    HopServerButton.Position = UDim2.new(0, 10, 0, 90)
    HopServerButton.Size = UDim2.new(1, -20, 0, 25)
    HopServerButton.Font = Enum.Font.Gotham
    HopServerButton.Text = "🔄 Đổi Server"
    HopServerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HopServerButton.TextSize = 12
    
    local HopCorner = Instance.new("UICorner")
    HopCorner.CornerRadius = UDim.new(0, 5)
    HopCorner.Parent = HopServerButton
    
    -- Status Frame
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Parent = MainFrame
    StatusFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    StatusFrame.Position = UDim2.new(0, 20, 0, 330)
    StatusFrame.Size = UDim2.new(1, -40, 0, 150)
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 10, 0, 10)
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "📊 Trạng Thái: Đang chờ..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ChestCountLabel.Name = "ChestCountLabel"
    ChestCountLabel.Parent = StatusFrame
    ChestCountLabel.BackgroundTransparency = 1
    ChestCountLabel.Position = UDim2.new(0, 10, 0, 40)
    ChestCountLabel.Size = UDim2.new(1, -20, 0, 25)
    ChestCountLabel.Font = Enum.Font.Gotham
    ChestCountLabel.Text = "📦 Rương đã nhặt: 0"
    ChestCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChestCountLabel.TextSize = 12
    ChestCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    CurrentTeamLabel.Name = "CurrentTeamLabel"
    CurrentTeamLabel.Parent = StatusFrame
    CurrentTeamLabel.BackgroundTransparency = 1
    CurrentTeamLabel.Position = UDim2.new(0, 10, 0, 70)
    CurrentTeamLabel.Size = UDim2.new(1, -20, 0, 25)
    CurrentTeamLabel.Font = Enum.Font.Gotham
    CurrentTeamLabel.Text = "🏴‍☠️ Phe hiện tại: Chưa chọn"
    CurrentTeamLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentTeamLabel.TextSize = 12
    CurrentTeamLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        MarinesButton = MarinesButton,
        PiratesButton = PiratesButton,
        StartButton = StartButton,
        StopButton = StopButton,
        HopServerButton = HopServerButton,
        StatusLabel = StatusLabel,
        ChestCountLabel = ChestCountLabel,
        CurrentTeamLabel = CurrentTeamLabel,
        CloseButton = CloseButton,
        MinimizeButton = MinimizeButton
    }
end

-- Create UI
local UI = createUI()
local isMinimized = false

-- UI Event Handlers
UI.CloseButton.MouseButton1Click:Connect(function()
    UI.ScreenGui:Destroy()
end)

UI.MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        UI.MainFrame:TweenSize(UDim2.new(0, 400, 0, 50), "Out", "Quad", 0.3, true)
        UI.MinimizeButton.Text = "+"
    else
        UI.MainFrame:TweenSize(UDim2.new(0, 400, 0, 500), "Out", "Quad", 0.3, true)
        UI.MinimizeButton.Text = "−"
    end
end)

-- Team Selection
UI.MarinesButton.MouseButton1Click:Connect(function()
    desiredTeam = "Marines"
    UI.MarinesButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    UI.PiratesButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    UI.CurrentTeamLabel.Text = "🏴‍☠️ Phe đã chọn: ⚓ Hải Quân"
end)

UI.PiratesButton.MouseButton1Click:Connect(function()
    desiredTeam = "Pirates"
    UI.PiratesButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    UI.MarinesButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    UI.CurrentTeamLabel.Text = "🏴‍☠️ Phe đã chọn: 🏴‍☠️ Hải Tặc"
end)

-- Improved Team Joining Function
local function joinTeam()
    UI.StatusLabel.Text = "📊 Trạng Thái: Đang tham gia " .. (desiredTeam == "Marines" and "Hải Quân" or "Hải Tặc") .. "..."
    
    -- Method 1: RemoteFunction
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
    end)
    
    task.wait(2)
    
    -- Method 2: UI Interaction
    repeat
        task.wait(1)
        local chooseTeam = Player:WaitForChild("PlayerGui"):FindFirstChild("ChooseTeam", true)
        local uiController = Player:WaitForChild("PlayerGui"):FindFirstChild("UIController", true)

        if chooseTeam and chooseTeam.Visible and uiController then
            -- Try clicking team buttons directly
            local teamFrame = chooseTeam:FindFirstChild("Container")
            if teamFrame then
                local targetButton = teamFrame:FindFirstChild(desiredTeam)
                if targetButton and targetButton:IsA("TextButton") then
                    firesignal(targetButton.MouseButton1Click)
                end
            end
            
            -- Backup method using getgc
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
        
        -- Method 3: Direct team assignment if player has team
        if Player.Team and Player.Team.Name ~= desiredTeam then
            pcall(function()
                Player.Team = game.Teams:FindFirstChild(desiredTeam)
            end)
        end
        
    until Player.Team and Player.Team.Name == desiredTeam
    
    UI.StatusLabel.Text = "📊 Trạng Thái: Đã tham gia " .. (desiredTeam == "Marines" and "⚓ Hải Quân" or "🏴‍☠️ Hải Tặc")
    UI.CurrentTeamLabel.Text = "🏴‍☠️ Phe hiện tại: " .. (desiredTeam == "Marines" and "⚓ Hải Quân" or "🏴‍☠️ Hải Tặc")
end

-- Tọa độ các đảo trong Sea 2
local PortalPos = {
    Vector3.new(-5880.94677734375,18.357391357421875,-5061.93359375), -- Cursed Ship
    Vector3.new(752.8848876953125,408.3377380371094,-5271.7802734375),
    Vector3.new(-3027.13232421875,319.1231994628906,-10083.7578125),
    Vector3.new(-5536.4873046875,95.15474700927734,-719.123046875) -- Zombie Island
}

-- Tween-based movement
local function topos(Pos)
    local targetPosition = typeof(Pos) == "Vector3" and Pos or (Pos.Position or Pos.p)
    local Distance = (targetPosition - Player.Character.HumanoidRootPart.Position).Magnitude
    local Speed = 350
    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Player.Character.HumanoidRootPart, info, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

-- Get character safely
local function getCharacter()
    while not Player.Character do Player.CharacterAdded:Wait() end
    return Player.Character:WaitForChild("HumanoidRootPart").Parent
end

-- Find uncollected chests
local function getChests()
    local chests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:find("Chest") and obj:FindFirstChild("TouchInterest") then
            if not CollectedChests[obj] then
                table.insert(chests, obj)
            end
        end
    end
    table.sort(chests, function(a, b)
        return (getCharacter().HumanoidRootPart.Position - a.Position).Magnitude <
               (getCharacter().HumanoidRootPart.Position - b.Position).Magnitude
    end)
    return chests
end

-- Check for rare item
local function hasImportantItem()
    local Backpack = Player.Backpack
    local Char = Player.Character
    return Backpack:FindFirstChild("God's Chalice") or
           Backpack:FindFirstChild("Fist of Darkness") or
           Char:FindFirstChild("God's Chalice") or
           Char:FindFirstChild("Fist of Darkness")
end

-- Server hop function
local function hopServer()
    UI.StatusLabel.Text = "📊 Trạng Thái: Đang đổi server..."
    
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end

        if Site.nextPageCursor then
            foundAnything = Site.nextPageCursor
        end

        for _,v in pairs(Site.data) do
            local ID = tostring(v.id)
            if v.playing < v.maxPlayers and not table.find(AllIDs, ID) then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, Player)
                end)
                task.wait(4)
            end
        end
    end

    while true do
        pcall(function()
            TPReturner()
        end)
        if foundAnything == "" then break end
    end
end

-- Control buttons
UI.StartButton.MouseButton1Click:Connect(function()
    if not AutoFarmEnabled then
        AutoFarmEnabled = true
        UI.StatusLabel.Text = "📊 Trạng Thái: Đang khởi động..."
        joinTeam()
        UI.StatusLabel.Text = "📊 Trạng Thái: Đang farm rương..."
    end
end)

UI.StopButton.MouseButton1Click:Connect(function()
    AutoFarmEnabled = false
    UI.StatusLabel.Text = "📊 Trạng Thái: Đã dừng farm"
end)

UI.HopServerButton.MouseButton1Click:Connect(function()
    hopServer()
end)

-- Auto stand if sitting
task.spawn(function()
    while task.wait(0.5) do
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Sit then
            char.Humanoid.Sit = false
        end
    end
end)

-- Main farming loop
task.spawn(function()
    while task.wait(0.5) do
        if not AutoFarmEnabled then continue end
        
        if hasImportantItem() then
            UI.StatusLabel.Text = "🛑 Tìm thấy vật phẩm hiếm! Đã dừng farm."
            AutoFarmEnabled = false
            break
        end

        local chests = getChests()

        if #chests == 0 and next(CollectedChests) ~= nil then
            CollectedChests = {}
            table.insert(VisitedIslands, CurrentIsland)

            if Sea2 and #VisitedIslands < #PortalPos then
                repeat
                    CurrentIsland = (CurrentIsland % #PortalPos) + 1
                until not table.find(VisitedIslands, CurrentIsland)

                UI.StatusLabel.Text = "🌍 Di chuyển sang đảo " .. CurrentIsland
                topos(PortalPos[CurrentIsland])
                task.wait(2)
            else
                UI.StatusLabel.Text = "🎯 Hoàn thành vòng farm. Đang đổi server..."
                FinishedCycle = true
                hopServer()
                break
            end
        end

        if #chests > 0 then
            local targetChest = chests[1]
            UI.StatusLabel.Text = "📦 Đang di chuyển đến rương..."
            topos(targetChest.CFrame)
            task.wait(0.2)

            if not targetChest.Parent or not targetChest:FindFirstChild("TouchInterest") then
                ChestCount += 1
                CollectedChests[targetChest] = true
                UI.ChestCountLabel.Text = "📦 Rương đã nhặt: " .. ChestCount
                UI.StatusLabel.Text = "✔ Nhặt rương #" .. ChestCount
            else
                CollectedChests[targetChest] = true
                UI.StatusLabel.Text = "⚠ Không thể nhặt rương, bỏ qua..."
            end
        end
    end
end)

-- Update team display
task.spawn(function()
    while task.wait(1) do
        if Player.Team then
            local teamName = Player.Team.Name
            local displayName = teamName == "Marines" and "⚓ Hải Quân" or (teamName == "Pirates" and "🏴‍☠️ Hải Tặc" or teamName)
            UI.CurrentTeamLabel.Text = "🏴‍☠️ Phe hiện tại: " .. displayName
        end
    end
end)

print("🏴‍☠️ Blox Fruits Chest Farm UI đã tải thành công!")
StarterGui:SetCore("SendNotification", {
    Title = "Chest Farm",
    Text = "UI đã tải thành công! Chọn phe và bắt đầu farm.",
    Duration = 3
})
