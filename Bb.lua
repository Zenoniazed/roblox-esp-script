local BossZones = workspace:WaitForChild("BossZones")

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0,400,0,50)
label.Position = UDim2.new(0.5,-200,0.1,0)
label.TextScaled = true
label.BackgroundTransparency = 0.3
label.Parent = gui

while true do
    local bossIsland = nil

    for _, island in pairs(BossZones:GetChildren()) do
        local zone = island:FindFirstChild("BossSpawnZone")

        if zone and #zone:GetChildren() > 0 then
            bossIsland = island.Name
            break
        end
    end

    if bossIsland then
        label.Text = "🔥 Boss xuất hiện tại: "..bossIsland
        label.TextColor3 = Color3.fromRGB(255,0,0)
    else
        label.Text = "⏳ Chưa có boss xuất hiện"
        label.TextColor3 = Color3.fromRGB(255,255,255)
    end

    task.wait(2)
end
