-- Đợi game load
repeat wait() until game:IsLoaded()

-- Hàm tween đến vị trí CFrame
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

-- Bật auto farm ngay khi script chạy
local AutoFarmChest = true
_G.MagnitudeAdd = 0

-- Auto farm loop
spawn(function()
    while wait() do 
        if AutoFarmChest then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local foundChest = false

            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do 
                if v.Name:find("Chest") and v:IsA("BasePart") then
                    local distance = (v.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance <= 5000 + _G.MagnitudeAdd then
                        foundChest = true
                        local chestCFrame = v.CFrame

                        repeat wait()
                            if v and v.Parent then
                                topos(chestCFrame)
                            end
                        until AutoFarmChest == false or not v:IsDescendantOf(game.Workspace)

                        topos(char.HumanoidRootPart.CFrame) -- quay lại vị trí cũ

                        _G.MagnitudeAdd = 0 -- reset nếu tìm được
                        break
                    end
                end
            end

            if not foundChest then
                _G.MagnitudeAdd = _G.MagnitudeAdd + 1500 -- mở rộng phạm vi tìm kiếm nếu không có chest gần
            end
        end
    end
end)
