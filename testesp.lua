-- 🟢 Tạo GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local NoclipButton = Instance.new("TextButton")     -- 🟢 Nút Noclip
local AimbotButton = Instance.new("TextButton")
local FullbrightButton = Instance.new("TextButton") -- 🟢 Nút Fullbright
local IsPersonButton = Instance.new("TextButton")
local OptionsFrame = Instance.new("Frame")



local options = {
    { name = "Vật phẩm", enabled = false },
    { name = "Enemies bán được", enabled = false },
    { name = "Mob", enabled = false },
    { name = "Zombies", enabled = false },
    { name = "Vũ khí", enabled = false },
}

ScreenGui.Parent = game.CoreGui

-- 🟢 Khung chính (Nhỏ gọn hơn)
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 540, 0, 50) -- 🟢 Tăng chiều cao để chứa Noclip
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
local MainFrameCorner = Instance.new("UICorner", MainFrame)
MainFrameCorner.CornerRadius = UDim.new(0, 10)

-- 🟢 Nút ESP (Chiếm toàn bộ MainFrame)
ESPButton.Parent = MainFrame
ESPButton.Size = UDim2.new(0, 60, 0, 40) -- 🟢 Giữ nguyên kích thước
ESPButton.Position = UDim2.new(0, 15, 0, 5)
ESPButton.Text = "👁️\nESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
local ESPButtonCorner = Instance.new("UICorner", ESPButton)
ESPButtonCorner.CornerRadius = UDim.new(0, 10)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 12
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
local ESPButtonstroke = Instance.new("UIStroke", ESPButton)
ESPButtonstroke.Thickness = 1
ESPButtonstroke.Color = Color3.fromRGB(120, 120, 120)
ESPButtonstroke.Transparency = 0.3

-- 🟢 Nút Noclip (Mới thêm vào)
NoclipButton.Parent = MainFrame
NoclipButton.Size = UDim2.new(0, 60, 0, 40)
NoclipButton.Position = UDim2.new(0, 76, 0, 5)
NoclipButton.Text = "🚪\nNoclip"
NoclipButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40) -- Màu đỏ khi tắt
local NoclipButtonCorner = Instance.new("UICorner", NoclipButton)
NoclipButtonCorner.CornerRadius = UDim.new(0, 10)
NoclipButton.Font = Enum.Font.GothamBold
NoclipButton.TextSize = 12
NoclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
local NoclipButtonstroke = Instance.new("UIStroke", NoclipButton)
NoclipButtonstroke.Thickness = 1
NoclipButtonstroke.Color = Color3.fromRGB(120, 120, 120)
NoclipButtonstroke.Transparency = 0.3

-- 🟢 Nút Aimbot
AimbotButton.Parent = MainFrame
AimbotButton.Size = UDim2.new(0, 60, 0, 40)
AimbotButton.Position = UDim2.new(0, 137, 0, 5)           -- Đặt dưới Noclip
AimbotButton.Text = "🎯\nAimbot"
AimbotButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40) -- Mặc định là tắt
local AimbotButtonCorner = Instance.new("UICorner", AimbotButton)
AimbotButtonCorner.CornerRadius = UDim.new(0, 10)
AimbotButton.Font = Enum.Font.GothamBold
AimbotButton.TextSize = 12
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
local AimbotButtonstroke = Instance.new("UIStroke", AimbotButton)
AimbotButtonstroke.Thickness = 1
AimbotButtonstroke.Color = Color3.fromRGB(120, 120, 120)
AimbotButtonstroke.Transparency = 0.3

-- 🟢 Nút Fullbright
FullbrightButton.Parent = MainFrame
FullbrightButton.Size = UDim2.new(0, 60, 0, 40)
FullbrightButton.Position = UDim2.new(0, 198, 0, 5)
FullbrightButton.Text = "💡\nBright"
FullbrightButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
local FullbrightButtonCorner = Instance.new("UICorner", FullbrightButton)
FullbrightButtonCorner.CornerRadius = UDim.new(0, 10)
FullbrightButton.Font = Enum.Font.GothamBold
FullbrightButton.TextSize = 12
FullbrightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
local FullbrightButtonstroke = Instance.new("UIStroke", FullbrightButton)
FullbrightButtonstroke.Thickness = 1
FullbrightButtonstroke.Color = Color3.fromRGB(120, 120, 120)
FullbrightButtonstroke.Transparency = 0.3

-- 🟢 Nút IsPerson
IsPersonButton.Parent = MainFrame
IsPersonButton.Size = UDim2.new(0, 60, 0, 40)
IsPersonButton.Position = UDim2.new(0, 259, 0, 5)
IsPersonButton.Text = "📷\nCamera 3rd"
IsPersonButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
local IsPersonButtonCorner = Instance.new("UICorner", IsPersonButton)
IsPersonButtonCorner.CornerRadius = UDim.new(0, 10)
IsPersonButton.Font = Enum.Font.GothamBold
IsPersonButton.TextSize = 12
IsPersonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
local IsPersonButtontroke = Instance.new("UIStroke", IsPersonButton)
IsPersonButtontroke.Thickness = 1
IsPersonButtontroke.Color = Color3.fromRGB(120, 120, 120)
IsPersonButtontroke.Transparency = 0.3

-- 🟢 Nút Infinite Jump
local infJumpButton = Instance.new("TextButton", MainFrame)
infJumpButton.Size = UDim2.new(0, 60, 0, 40)
infJumpButton.Position = UDim2.new(0, 440, 0, 5)
infJumpButton.Text = "🕴️\nInfJump"
infJumpButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
infJumpButton.TextColor3 = Color3.new(1, 1, 1)
infJumpButton.Font = Enum.Font.GothamBold
infJumpButton.TextSize = 12
Instance.new("UICorner", infJumpButton)


-- 🟢 Khung danh sách chọn
OptionsFrame.Parent = ScreenGui
OptionsFrame.Size = UDim2.new(0, 150, 0, #options * 35 + 5)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OptionsFrame.BorderSizePixel = 2
OptionsFrame.Visible = false
local OptionsFrameCorner = Instance.new("UICorner", OptionsFrame)
OptionsFrameCorner.CornerRadius = UDim.new(0, 10)

local function updateOptionsFramePosition()
    OptionsFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 5, 0,
        MainFrame.Position.Y.Offset)
end

ESPButton.MouseButton1Click:Connect(function()
    OptionsFrame.Visible = not OptionsFrame.Visible
    updateOptionsFramePosition()
end)

for i, option in ipairs(options) do
    local optionButton = Instance.new("TextButton")
    optionButton.Parent = OptionsFrame
    optionButton.Size = UDim2.new(0, 140, 0, 30)
    optionButton.Position = UDim2.new(0, 5, 0, 5 + (i - 1) * (30 + 5))
    optionButton.Text = option.name
    local optionButtonCorner = Instance.new("UICorner", optionButton)
    optionButtonCorner.CornerRadius = UDim.new(0, 10)
    optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionButton.Font = Enum.Font.GothamBold
    optionButton.TextSize = 12
    local optionButtonstroke = Instance.new("UIStroke", optionButton)
    optionButtonstroke.Thickness = 1
    optionButtonstroke.Color = Color3.fromRGB(120, 40, 40)
    optionButtonstroke.Transparency = 0.3
    optionButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)

    optionButton.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        optionButton.BackgroundColor3 = option.enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)
    end)
end

-- 🟢 Hỗ trợ kéo thả GUI (Cả PC & Mobile)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, startPos, dragStart

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    updateOptionsFramePosition()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- 🟢 Biến điều khiển Fullbright
local fullbrightEnabled = false
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")

-- 🟢 Hàm áp dụng cấu hình Fullbright
local function applyFullbright()
    lighting.Brightness = 1.5
    lighting.ClockTime = 8
    lighting.FogStart = 0
    lighting.FogEnd = 100000
    lighting.FogColor = Color3.new(0.452941, 0.452941, 0.452941)
    lighting.Ambient = Color3.new(0.4, 0.4, 0.4)
    lighting.OutdoorAmbient = Color3.new(0.4, 0.4, 0.4)
    lighting.GlobalShadows = false
    lighting.EnvironmentDiffuseScale = 1
    lighting.EnvironmentSpecularScale = 1
    lighting.ColorShift_Top = Color3.new(0, 0, 0)
    lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
    lighting.ExposureCompensation = 0
end

-- 🟢 Hàm tắt Fullbright
local function disableFullbright()
    lighting.GlobalShadows = true
    -- Tùy chọn: khôi phục các giá trị gốc nếu muốn
end

-- 🟢 Hàm bật/tắt Fullbright
local function toggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    FullbrightButton.BackgroundColor3 = fullbrightEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)

    if fullbrightEnabled then
        applyFullbright()
        print("🟢 Fullbright ĐÃ BẬT")
    else
        disableFullbright()
        print("🔴 Fullbright ĐÃ TẮT")
    end
end

-- 🟢 Kết nối nút GUI và phím tắt
FullbrightButton.MouseButton1Click:Connect(toggleFullbright)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        toggleFullbright()
    end
end)

-- 🟢 Vòng lặp ép lại Lighting khi đang bật
runService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        applyFullbright()
    end
end)

-- 🟢 Biến điều khiển Noclip
local noclipEnabled = false

-- 🟢 Hàm bật/tắt Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    NoclipButton.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)

    if noclipEnabled then
        print("🟢 Noclip ĐÃ BẬT")
    else
        print("🔴 Noclip ĐÃ TẮT")
    end
end

-- 🟢 Gán sự kiện cho nút Noclip
NoclipButton.MouseButton1Click:Connect(toggleNoclip)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

-- 🟢 Cập nhật trạng thái Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false -- 🟢 Tắt va chạm
                end
            end
        end
    end
end)
-- 🟢 Biến điều khiển
local aimbotEnabled = false
local autoShootEnabled = false
local mouse = game.Players.LocalPlayer:GetMouse()
local enemiesList = {}
local currentTarget = nil
local maxAimbotDistance = 700
local aimbotFOVRadius = 50

-- 🟢 GUI FOV
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local FOVCircle = Instance.new("Frame")
FOVCircle.Parent = ScreenGui
FOVCircle.Size = UDim2.new(0, aimbotFOVRadius * 2, 0, aimbotFOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Visible = false
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 0)
UIStroke.Transparency = 0.5

game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Position = UDim2.new(0.5, 0, 0.46, 0)
end)

-- 🟢 ESP Highlight target
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(0, 255, 0)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.3
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = game.CoreGui

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled and currentTarget and currentTarget.Parent then
        highlight.Adornee = currentTarget.Parent
        highlight.Enabled = true
    else
        highlight.Adornee = nil
        highlight.Enabled = false
    end
end)


-- 🟢 Nâng cấp nút AutoShoot
local AutoShootButton = Instance.new("TextButton")
AutoShootButton.Name = "AutoShoot"
AutoShootButton.Parent = MainFrame
AutoShootButton.Size = UDim2.new(0, 120, 0, 30)
AutoShootButton.Position = UDim2.new(0, 100, 0, 50)
AutoShootButton.Text = "AutoShoot"
AutoShootButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
AutoShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoShootButton.Font = Enum.Font.GothamBold
AutoShootButton.TextSize = 12
AutoShootButton.TextWrapped = true
AutoShootButton.Visible = false
AutoShootButton.AutoButtonColor = false

-- Bo góc
local autoCorner = Instance.new("UICorner", AutoShootButton)
autoCorner.CornerRadius = UDim.new(0, 6)

-- Viền nhẹ
local autoStroke = Instance.new("UIStroke", AutoShootButton)
autoStroke.Thickness = 1
autoStroke.Color = Color3.fromRGB(180, 180, 180)
autoStroke.Transparency = 0.4


-- 🟢 Nút bật/tắt AutoShoot
AutoShootButton.MouseButton1Click:Connect(function()
    autoShootEnabled = not autoShootEnabled
    AutoShootButton.Text = autoShootEnabled and "AutoShoot: ON" or "AutoShoot: OFF"
    AutoShootButton.BackgroundColor3 = autoShootEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)
end)


-- 🟢 Nút bật/tắt Aimbot
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    AutoShootButton.Visible = aimbotEnabled
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)
    print(aimbotEnabled and "🟢 Aimbot ĐÃ BẬT" or "🔴 Aimbot ĐÃ TẮT")
end

AimbotButton.MouseButton1Click:Connect(toggleAimbot)
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.T then
        toggleAimbot()
    end
end)

-- 🟢 Kiểm tra FOV
local function isWithinFOV(target)
    local camera = game.Workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)
    if not onScreen then return false end
    local center = camera.ViewportSize / 2
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(center.X, center.Y)).Magnitude
    return dist <= aimbotFOVRadius
end

-- 🟢 Cập nhật enemy list mỗi 0.5s
task.spawn(function()
    while true do
        if aimbotEnabled then
            enemiesList = {}
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                    local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
                    local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")
                    if humanoid and humanoid.Health > 0 and head then
                        table.insert(enemiesList, { head = head, humanoid = humanoid, model = obj })
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 🟢 Tìm enemy hợp lệ + không bị tường cản
local function getNearestEnemy()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local camera = workspace.CurrentCamera
    -- local origin = camera.CFrame.Position
    local origin = hrp.Position
    local nearest, minDistance = nil, math.huge

    for _, enemy in pairs(enemiesList) do
        if enemy.head and enemy.head.Parent and enemy.humanoid.Health > 0 then
            local distance = (hrp.Position - enemy.head.Position).Magnitude
            if distance <= maxAimbotDistance and isWithinFOV(enemy.head) then
                -- 🧠 Danh sách các bộ phận để kiểm tra Raycast
                local partsToCheck = {
                    enemy.model:FindFirstChild("Head"),
                    enemy.model:FindFirstChild("Torso") or enemy.model:FindFirstChild("UpperTorso"),
                    enemy.model:FindFirstChild("HumanoidRootPart")
                }

                for _, part in ipairs(partsToCheck) do
                    if part then
                        local direction = (part.Position - origin).Unit * distance
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = { character, camera }
                        rayParams.IgnoreWater = true

                        local result = workspace:Raycast(origin, direction, rayParams)

                        -- ✅ Nếu Raycast không bị block hoặc chỉ trúng enemy → chọn!
                        if not result or result.Instance:IsDescendantOf(enemy.model) then
                            if distance < minDistance then
                                nearest = part
                                minDistance = distance
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return nearest
end



-- 🟢 Cập nhật target mỗi 0.1s
task.spawn(function()
    while true do
        if aimbotEnabled then
            currentTarget = getNearestEnemy()
        else
            currentTarget = nil
        end
        task.wait(0.1)
    end
end)

-- 🟢 Kích hoạt Aimbot (Fix lỗi nhắm vào mob chết + chỉ aim trong FOV)
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local newTarget = getNearestEnemy() -- 🔥 Kiểm tra mục tiêu gần hơn mỗi frame

        -- 🔹 Nếu có kẻ địch gần hơn, đổi target ngay
        if newTarget and newTarget ~= currentTarget then
            currentTarget = newTarget
        end

        -- 🔹 Chỉ cập nhật `CFrame` nếu có mục tiêu hợp lệ
        if currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health > 0 then
            local camera = game.Workspace.CurrentCamera
            local aimPosition = currentTarget.Position + Vector3.new(0, 0.5, 0)
            camera.CFrame = CFrame.new(camera.CFrame.Position, aimPosition)
        else
            currentTarget = nil -- 🔴 Nếu mục tiêu chết hoặc mất, reset target
        end
    else
        currentTarget = nil -- 🔴 Reset khi tắt Aimbot
    end
end)
-- 🔫 AutoShoot khi đang aim đúng target
task.spawn(function()
    while true do
        if aimbotEnabled and autoShootEnabled and currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health > 0 then
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
        task.wait(0.05)
    end
end)


local CollectionService = game:GetService("CollectionService")

-- 🟢 Danh sách màu ESP theo danh mục
local espTargets = {
    ["GoldBar"] = { color = Color3.fromRGB(255, 238, 0), category = "Vật phẩm" },
    ["Golden Egg"] = { color = Color3.fromRGB(255, 238, 0), category = "Vật phẩm" },
    ["Coal"] = { color = Color3.fromRGB(235, 121, 72), category = "Vật phẩm" },
    ["Bond"] = { color = Color3.fromRGB(246, 14, 76), category = "Vật phẩm" },
    ["Bandage"] = { color = Color3.fromRGB(255, 153, 255), category = "Vật phẩm" },
    ["Snake Oil"] = { color = Color3.fromRGB(255, 153, 255), category = "Vật phẩm" },

    ["Model_Horse"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob" },
    ["Wolf"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob" },
    ["Unicorn"] = { color = Color3.fromRGB(205, 0, 255), category = "Mob" },

    ["Model_RifleOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["Model_ShotgunOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["Model_RevolverOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },

    ["Model_Runner"] = { color = Color3.fromRGB(155, 103, 232), category = "Zombies" },
    ["Model_Walker"] = { color = Color3.fromRGB(155, 103, 232), category = "Zombies" },
    ["Model_ArmoredZombie"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["Model_ZombieMiner"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["Model_ZombieSheriff"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["Model_Were Wolf"] = { color = Color3.fromRGB(141, 75, 240), category = "Zombies" },
    ["Model_Vampire"] = { color = Color3.fromRGB(141, 75, 240), category = "Zombies" },

    ["Vampire Knife"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Revolver"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Rifle"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Bolt Action Rifle"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Shotgun"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Cavalry Sword"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Crucifix"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Molotov"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Holy Water"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Jade Sword"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },

    ["RifleAmmo"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },
    ["ShotgunShells"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },
    ["RevolverAmmo"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },

}

-- 🟢 Tự động gắn tag cho các đối tượng trong danh sách espTargets
local function autoTagESP(obj)
    if espTargets[obj.Name] and not CollectionService:HasTag(obj, "ESP_Target") then
        CollectionService:AddTag(obj, "ESP_Target")
    end
end

-- 🟢 Gắn tag cho các đối tượng có sẵn
for _, obj in ipairs(game.Workspace:GetDescendants()) do
    autoTagESP(obj)
end

-- 🟢 Gắn tag cho các đối tượng mới
game.Workspace.DescendantAdded:Connect(autoTagESP)

-- 🟢 Hàm tạo ESP
local function createESP(obj, color)
    if obj:FindFirstChild("ESP_Tag") then return end

    local esp = Instance.new("BillboardGui", obj)
    esp.Name = "ESP_Tag"
    esp.Size = UDim2.new(2, 0, 1, 0)
    esp.StudsOffset = Vector3.new(0, 2.5, 0)
    esp.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    esp.AlwaysOnTop = true
    esp.MaxDistance = 2000

    local text = Instance.new("TextLabel", esp)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Text = obj.Name
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.BackgroundTransparency = 1
    text.TextSize = 10
    text.TextStrokeTransparency = 0.5
end

-- 🔍 Hiển thị Vault Code trên đầu mỗi Banker
local function createBankerESP()
    local function updateESPForBanker(banker)
        if not banker:IsA("Model") then return end
        local head = banker:FindFirstChild("Head") or banker:FindFirstChild("HumanoidRootPart")
        local combo = banker:FindFirstChild("Combo")
        if not head or not combo or head:FindFirstChild("VaultESP") then return end

        local esp = Instance.new("BillboardGui")
        esp.Name = "VaultESP"
        esp.Adornee = head
        esp.Size = UDim2.new(2, 0, 1, 0)
        esp.StudsOffset = Vector3.new(0, 2.5, 0)
        esp.AlwaysOnTop = true
        esp.MaxDistance = 1000
        esp.Parent = head

        local label = Instance.new("TextLabel")
        label.Parent = esp
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.TextStrokeTransparency = 0.4
        label.Text = "💰: " .. tostring(combo.Value)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
    end

    -- Gắn ESP cho Banker có sẵn
    for _, banker in ipairs(workspace:WaitForChild("RuntimeEntities"):GetChildren()) do
        if banker.Name == "Model_Banker" then
            updateESPForBanker(banker)
        end
    end

    -- Theo dõi Banker spawn mới
    workspace.RuntimeEntities.ChildAdded:Connect(function(child)
        if child.Name == "Model_Banker" then
            task.wait(0.3) -- Đợi Combo tồn tại
            updateESPForBanker(child)
        end
    end)
end

createBankerESP()
-- 🟢 Lấy vị trí đối tượng (có xử lý Model & BasePart)
local function getObjectPosition(obj)
    if obj:IsA("Tool") then
        return nil
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        else
            for _, part in ipairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    return part.Position
                end
            end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end
game:GetService("RunService").RenderStepped:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(CollectionService:GetTagged("ESP_Target")) do
        local info = espTargets[obj.Name]
        if not info then continue end

        local category = info.category
        local enabled = false
        for _, opt in ipairs(options) do
            if opt.name == category then
                enabled = opt.enabled
                break
            end
        end

        local itemPosition = getObjectPosition(obj)
        if not itemPosition then continue end

        local distance = (itemPosition - hrp.Position).Magnitude

        if enabled and distance <= 2000 then
            if not obj:FindFirstChild("ESP_Tag") then
                createESP(obj, info.color)
            end
        else
            if obj:FindFirstChild("ESP_Tag") then
                obj.ESP_Tag:Destroy()
            end
        end
    end
end)
-- show Hp player
local Players = game:GetService("Players")

local function addNametag(character)
    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    local humanoid = character:WaitForChild("Humanoid")

    if not hrp or hrp:FindFirstChild("ESP_HP") then return end

    local espHP = Instance.new("BillboardGui")
    espHP.Name = "ESP_HP"
    espHP.Size = UDim2.new(2, 0, 2, 0)
    espHP.StudsOffset = Vector3.new(0, 3, 0)
    espHP.Adornee = hrp
    espHP.AlwaysOnTop = true
    espHP.MaxDistance = 1000
    espHP.Parent = hrp
        
    -- Tên người chơi
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 10
    nameLabel.Text = Players:GetPlayerFromCharacter(character) and Players:GetPlayerFromCharacter(character).Name or character.Name
    nameLabel.Parent = espHP

    -- HP %
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0 , 0 , 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    hpLabel.TextStrokeTransparency = 0.5
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextSize = 10
    hpLabel.Text = "❤️ 100%"
    hpLabel.Name = "HPLabel"
    hpLabel.Parent = espHP


    -- Cập nhật HP %
    local function updateHealth()
        local percent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
        hpLabel.Text = "❤️ " .. percent .. "%"
    end

    humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
    updateHealth()
end

local function onCharacterAdded(character)
    addNametag(character)
end

local function setupAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            addNametag(player.Character)
        end
        player.CharacterAdded:Connect(onCharacterAdded)
    end
end

setupAllPlayers()
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end)

local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local isFirstPerson = false

-- Hàm chuyển đổi góc nhìn
local function updateCamera()
    if isFirstPerson then
        plr.CameraMode = Enum.CameraMode.LockFirstPerson
        plr.CameraMinZoomDistance = 0
        plr.CameraMaxZoomDistance = 0
        IsPersonButton.Text = "📷\nCamera 1st"
    else
        plr.CameraMode = Enum.CameraMode.Classic
        plr.CameraMinZoomDistance = 0
        plr.CameraMaxZoomDistance = 50
        IsPersonButton.Text = "📷\nCamera 3rd"
    end
end

-- -- Gán sự kiện nút
-- button.MouseButton1Click:Connect(function()
--     isFirstPerson = not isFirstPerson
--     updateCamera()
-- end)
local function toggleIsPerson()
   isFirstPerson = not isFirstPerson
    updateCamera()
    IsPersonButton.BackgroundColor3 = isFirstPerson and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)
end

-- 🟢 Gán sự kiện cho nút Noclip
IsPersonButton.MouseButton1Click:Connect(toggleIsPerson)

-- Cập nhật camera ban đầu
updateCamera()

-- Đảm bảo camera không bị reset bởi game
game:GetService("RunService").RenderStepped:Connect(function()
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if cam.CameraSubject ~= plr.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = plr.Character:FindFirstChild("Humanoid")
    end
end)

-- Auto Pick
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ✅ Danh sách vật phẩm và loại Remote
local autoPickupItems = {
    ["GoldBar"] = "StoreItem",
    ["Coal"] = "StoreItem",
    ["Bond"] = "C_ActivateObject",
    ["RifleAmmo"] = "C_ActivateObject",
    ["ShotgunShells"] = "C_ActivateObject",
    ["RevolverAmmo"] = "C_ActivateObject",
    ["Snake Oil"] = "PickUpTool",
    ["Shotgun"] = "PickUpTool",
    ["Rifle"] = "PickUpTool",
    ["Revolver"] = "PickUpTool",
    ["Bandage"] = "PickUpTool",
}

-- ✅ Gắn tag cho các vật phẩm
for _, obj in ipairs(workspace:GetDescendants()) do
    if autoPickupItems[obj.Name] and not CollectionService:HasTag(obj, "AutoPickup") then
        CollectionService:AddTag(obj, "AutoPickup")
    end
end
workspace.DescendantAdded:Connect(function(obj)
    if autoPickupItems[obj.Name] and not CollectionService:HasTag(obj, "AutoPickup") then
        CollectionService:AddTag(obj, "AutoPickup")
    end
end)

-- ✅ Remote gọi đến server
local storeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem", 5)

local pickupRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tool")
    :WaitForChild("PickUpTool")

local activateRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("RemotePromise")
    :WaitForChild("Remotes"):WaitForChild("C_ActivateObject")
-- ✅ Nút Auto Pickup
local autoPickupButton = Instance.new("TextButton", MainFrame)
autoPickupButton.Size = UDim2.new(0, 60, 0, 40)
autoPickupButton.Position = UDim2.new(0, 320, 0, 5)
autoPickupButton.Text = "💰\nPickup"
autoPickupButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
autoPickupButton.TextColor3 = Color3.new(1, 1, 1)
autoPickupButton.Font = Enum.Font.GothamBold
autoPickupButton.TextSize = 12
Instance.new("UICorner", autoPickupButton).CornerRadius = UDim.new(0, 10)

-- ✅ Giao diện khung chọn item
local autoPickupFrame = Instance.new("Frame", MainFrame)
autoPickupFrame.Size = UDim2.new(0, 400, 0, 190)
autoPickupFrame.Position = UDim2.new(0, 0, 0, 60)
autoPickupFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
autoPickupFrame.Visible = false
Instance.new("UICorner", autoPickupFrame).CornerRadius = UDim.new(0, 10)

autoPickupButton.MouseButton1Click:Connect(function()
    autoPickupFrame.Visible = not autoPickupFrame.Visible
end)

-- ✅ Danh mục và GUI chọn item
local selectionTable = {}
local categories = {
    ["Vật phẩm"] = {"GoldBar", "Bond", "Coal"},
    ["Vũ khí"] = {"Rifle", "Shotgun","Revolver","RifleAmmo","ShotgunShells","RevolverAmmo",},
     ["Health"] = {"Bandage", "Snake Oil","Loli :)"},
}

local colWidth, spacing, colIndex = 150, 15, 0
for category, items in pairs(categories) do
    local label = Instance.new("TextLabel", autoPickupFrame)
    -- label.Size = UDim2.new(0, colWidth, 0, 0)
    -- label.Position = UDim2.new(0, colIndex * (colWidth + spacing), 0, 5)
    label.Text = " "
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local corner = Instance.new("UICorner", label)
corner.CornerRadius = UDim.new(0, 6)


    for i, item in ipairs(items) do
        local button = Instance.new("TextButton", autoPickupFrame)
        button.Size = UDim2.new(0, 120, 0, 20)
button.Position = UDim2.new(0, colIndex * 130 + 10, 0, 5+(i-1)* 25)
button.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.TextWrapped = true

-- Bo góc
local uicorner = Instance.new("UICorner", button)
uicorner.CornerRadius = UDim.new(0, 6)

-- Viền nhẹ
local stroke = Instance.new("UIStroke", button)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(120, 120, 120)
stroke.Transparency = 0.4

        button.Text = "[ ] " .. item

        button.MouseButton1Click:Connect(function()
            selectionTable[item] = not selectionTable[item]
            button.Text = (selectionTable[item] and "[X] " or "[ ] ") .. item
        end)
    end
    colIndex += 1
end

-- ✅ Hàm lấy tọa độ object an toàn
local function getPos(obj)
    if obj:IsA("Model") then
        return (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
            and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")).Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

-- ✅ Vòng lặp auto nhặt vật phẩm đã chọn
local CHECK_RADIUS = 20
local INTERVAL = 0.3

task.spawn(function()
    while true do
        task.wait(INTERVAL)

        for _, obj in ipairs(CollectionService:GetTagged("AutoPickup")) do
            if selectionTable[obj.Name] then
                local pos = getPos(obj)
                if pos and (pos - hrp.Position).Magnitude <= CHECK_RADIUS then
                    local remoteType = autoPickupItems[obj.Name]
                    if remoteType == "StoreItem" then
                        storeRemote:FireServer(obj)
                    elseif remoteType == "C_ActivateObject" then
                        activateRemote:FireServer(obj)
                    elseif remoteType == "PickUpTool" then
                        pickupRemote:FireServer(obj)
                    end
                end
            end
        end
    end
end)
-- Auto Use
local autoUseButton = Instance.new("TextButton", MainFrame)
autoUseButton.Size = UDim2.new(0, 60, 0, 40)
autoUseButton.Position = UDim2.new(0, 380, 0, 5)
autoUseButton.Text = "🧪\nAuto Use"
autoUseButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
autoUseButton.TextColor3 = Color3.new(1, 1, 1)
autoUseButton.Font = Enum.Font.GothamBold
autoUseButton.TextSize = 12
Instance.new("UICorner", autoUseButton)

local autoUseFrame = Instance.new("Frame", MainFrame)
autoUseFrame.Size = UDim2.new(0, 200, 0, 100)
autoUseFrame.Position = UDim2.new(0, 0, 0, 60)
autoUseFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
autoUseFrame.Visible = false
Instance.new("UICorner", autoUseFrame)

autoUseButton.MouseButton1Click:Connect(function()
	autoUseFrame.Visible = not autoUseFrame.Visible
end)
local autoUseConfig = {
	["Snake Oil"] = { enabled = false, threshold = 30, lastUsed = 0, cooldown = 1 },
	["Bandage"]   = { enabled = false, threshold = 55, lastUsed = 0, cooldown = 0.5 },
}


local y = 5
for itemName, config in pairs(autoUseConfig) do
	local check = Instance.new("TextButton", autoUseFrame)
	check.Size = UDim2.new(0, 100, 0, 25)
	check.Position = UDim2.new(0, 10, 0, y)
	check.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	check.TextColor3 = Color3.new(1,1,1)
	check.Font = Enum.Font.GothamBold
	check.TextSize = 12
	check.Text = "[ ] " .. itemName
	Instance.new("UICorner", check)

	local input = Instance.new("TextBox", autoUseFrame)
	input.Size = UDim2.new(0, 60, 0, 25)
	input.Position = UDim2.new(0, 120, 0, y)
	input.PlaceholderText = tostring(config.threshold)
	input.Text = ""
	input.BackgroundColor3 = Color3.fromRGB(30,30,30)
	input.TextColor3 = Color3.new(1,1,1)
	input.Font = Enum.Font.Gotham
	input.TextSize = 12
	Instance.new("UICorner", input)

	check.MouseButton1Click:Connect(function()
		config.enabled = not config.enabled
		check.Text = (config.enabled and "[X] " or "[ ] ") .. itemName
	end)

	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then config.threshold = val end
	end)

	y += 30
end
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local function tryAutoUse(itemName)
	local containers = { player.Character, player:WaitForChild("Backpack") }
	for _, c in ipairs(containers) do
		local tool = c:FindFirstChild(itemName)
		if tool and tool:FindFirstChild("Use") then
			print("🧪 Auto dùng:", itemName)
			tool.Use:FireServer(tool)
			break
		end
	end
end

humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	local hp = humanoid.Health
	local now = tick()

	for itemName, config in pairs(autoUseConfig) do
		if config.enabled and hp <= config.threshold then
			if now - config.lastUsed >= config.cooldown then
				local containers = { player.Character, player:WaitForChild("Backpack") }
				for _, c in ipairs(containers) do
					local tool = c:FindFirstChild(itemName)
					if tool and tool:FindFirstChild("Use") then
						print("🧪 Auto dùng:", itemName)
						tool.Use:FireServer(tool)
						config.lastUsed = now
						break
					end
				end
			else
				print("⏳ Đợi cooldown cho", itemName)
			end
		end
	end
end)

-- 🟢 Biến và chức năng Infinite Jump
local infJumpEnabled = false
local uis = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")

plr.CharacterAdded:Connect(function(char)
    hum = char:WaitForChild("Humanoid")
end)

-- Bật/Tắt Infinite Jump
infJumpButton.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    infJumpButton.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 40, 40)
end)

-- Jump khi bật
uis.JumpRequest:Connect(function()
    if infJumpEnabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
