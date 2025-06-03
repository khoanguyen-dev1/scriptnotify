local Player = game.Players.LocalPlayer
local ChestCount = 0
local CollectedChests = {}
local Sea2 = true
local CurrentIsland = 1
local VisitedIslands = {}
local FinishedCycle = false

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
    local tween_s = game:GetService("TweenService")
    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local tween = tween_s:Create(Player.Character.HumanoidRootPart, info, {CFrame = CFrame.new(targetPosition)})
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

-- Auto stand if sitting
task.spawn(function()
    while task.wait(0.5) do
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Sit then
            char.Humanoid.Sit = false
        end
    end
end)

-- Main loop
task.spawn(function()
    while task.wait(0.5) do
        if hasImportantItem() then
            warn("🛑 Đã nhặt được vật phẩm hiếm! Dừng farm.")
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

                print("🌍 Di chuyển sang đảo tiếp theo: ", CurrentIsland)
                topos(PortalPos[CurrentIsland])
                task.wait(2)
            else
                print("🎯 Đã hoàn thành vòng rương các đảo. Đang thực hiện hop server...")
                FinishedCycle = true
                break
            end
        end

        if #chests > 0 then
            local targetChest = chests[1]
            topos(targetChest.CFrame)
            task.wait(0.2)

            if not targetChest.Parent or not targetChest:FindFirstChild("TouchInterest") then
                ChestCount += 1
                CollectedChests[targetChest] = true
                print("✔ Nhặt rương #" .. ChestCount)
            else
                CollectedChests[targetChest] = true
                print("⚠ Không thể nhặt rương, bỏ qua...")
            end
        end
    end
end)

-- Server hop sau khi farm xong
task.spawn(function()
    while not FinishedCycle do task.wait(1) end

    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour

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
end)
