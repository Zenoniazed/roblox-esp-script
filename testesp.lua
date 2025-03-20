-- 🟢 Tạo GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local NoclipButton = Instance.new("TextButton") -- 🟢 Nút Noclip
local AimbotButton = Instance.new("TextButton")
local FullbrightButton = Instance.new("TextButton") -- 🟢 Nút Fullbright
local OptionsFrame = Instance.new("Frame")

local options = {
    { name = "Vật phẩm", enabled = false },
    { name = "Enemies bán được", enabled = false },
    { name = "Mob hiếm", enabled = false },
    { name = "Zombies", enabled = false },
    { name = "Vũ khí", enabled = false },
}

ScreenGui.Parent = game.CoreGui

-- 🟢 Khung chính (Nhỏ gọn hơn)
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 310, 0, 50) -- 🟢 Tăng chiều cao để chứa Noclip
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true

-- 🟢 Nút ESP (Chiếm toàn bộ MainFrame)
ESPButton.Parent = MainFrame
ESPButton.Size = UDim2.new(0, 60, 0, 40) -- 🟢 Giữ nguyên kích thước
ESPButton.Position = UDim2.new(0, 15, 0, 5)
ESPButton.Text = "ESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

-- 🟢 Nút Noclip (Mới thêm vào)
NoclipButton.Parent = MainFrame
NoclipButton.Size = UDim2.new(0, 60, 0, 40)
NoclipButton.Position = UDim2.new(0, 75, 0, 5)
NoclipButton.Text = "Noclip"
NoclipButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Màu đỏ khi tắt

-- 🟢 Nút Aimbot
AimbotButton.Parent = MainFrame
AimbotButton.Size = UDim2.new(0, 60, 0, 40)
AimbotButton.Position = UDim2.new(0, 135, 0, 5)            -- Đặt dưới Noclip
AimbotButton.Text = "Aimbot"
AimbotButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Mặc định là tắt

-- 🟢 Nút Fullbright
FullbrightButton.Parent = MainFrame
FullbrightButton.Size = UDim2.new(0, 70, 0, 40)
FullbrightButton.Position = UDim2.new(0, 195, 0, 5)
FullbrightButton.Text = "Bright"
FullbrightButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)


-- 🟢 Khung danh sách chọn
OptionsFrame.Parent = ScreenGui
OptionsFrame.Size = UDim2.new(0, 150, 0, #options * 35 + 5)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OptionsFrame.BorderSizePixel = 2
OptionsFrame.Visible = false

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
    optionButton.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
    optionButton.Text = option.name
    optionButton.BackgroundColor3 = option.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    optionButton.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        optionButton.BackgroundColor3 = option.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
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

-- 🟢 Hàm bật/tắt Fullbright
local function toggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    FullbrightButton.BackgroundColor3 = fullbrightEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    if fullbrightEnabled then
        game:GetService("Lighting").Brightness = 1.5
        game:GetService("Lighting").ClockTime = 14.5
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        print("🟢 Fullbright ĐÃ BẬT")
    else
        game:GetService("Lighting").Brightness = 1.5
        game:GetService("Lighting").ClockTime = 14.5
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = true
        print("🔴 Fullbright ĐÃ TẮT")
    end
end

FullbrightButton.MouseButton1Click:Connect(toggleFullbright)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        toggleFullbright()
    end
end)

-- 🟢 Biến điều khiển Noclip
local noclipEnabled = false

-- 🟢 Hàm bật/tắt Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    NoclipButton.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

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
-- 🟢 Biến điều khiển Aimbot
local aimbotEnabled = false
local mouse = game.Players.LocalPlayer:GetMouse()
local enemiesList = {}
local currentTarget = nil
local maxAimbotDistance = 500
local aimbotFOVRadius = 50 -- 🔥 Bán kính FOV hình tròn

-- 🟢 Tạo GUI hiển thị FOV
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local FOVCircle = Instance.new("Frame")

FOVCircle.Parent = ScreenGui
FOVCircle.Size = UDim2.new(0, aimbotFOVRadius * 2, 0, aimbotFOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5) -- 🟢 Căn giữa chính xác
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0) -- 🟢 Luôn đặt ở tâm màn hình
FOVCircle.Visible = false

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1, 0)

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 0)
UIStroke.Transparency = 0.5

-- 🟢 Cập nhật vị trí FOV
game:GetService("RunService").RenderStepped:Connect(function()
    local camera = game.Workspace.CurrentCamera
    if camera then
        local viewportSize = camera.ViewportSize
        FOVCircle.Position = UDim2.new(0.5, 0, 0.46, 0) -- 🔥 Fix tuyệt đối về tâm màn hình
    end
end)

-- 🟢 Kiểm tra mục tiêu có nằm trong FOV không
local function isWithinFOV(target)
    local camera = game.Workspace.CurrentCamera
    local targetScreenPos, onScreen = camera:WorldToViewportPoint(target.Position)

    if onScreen then
        local centerX, centerY = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
        local distanceFromCenter = math.sqrt((targetScreenPos.X - centerX) ^ 2 + (targetScreenPos.Y - centerY) ^ 2)

        return distanceFromCenter <= aimbotFOVRadius
    end

    return false
end

-- 🟢 Cập nhật danh sách enemy mỗi giây
task.spawn(function()
    while true do
        if not aimbotEnabled then
            task.wait(1)
        else
            enemiesList = {}
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
                    local enemyHumanoid = obj:FindFirstChild("Humanoid")
                    local enemyHead = obj:FindFirstChild("Head")

                    if enemyHumanoid and enemyHumanoid.Health > 0 and enemyHead then
                        table.insert(enemiesList, enemyHead)
                    end
                end
            end
            print("🔍 Cập nhật danh sách kẻ địch:", #enemiesList)
            task.wait(0.5)
        end
    end
end)

-- 🟢 Tìm kẻ địch gần nhất trong FOV
local function getNearestEnemy()
    if not aimbotEnabled then return nil end

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearestEnemy = nil
    local minDistance = math.huge

    -- 🟢 Duyệt danh sách kẻ địch đã cache thay vì toàn bộ Workspace
    for _, enemy in pairs(enemiesList) do
        if enemy.head and enemy.head.Parent and enemy.humanoid.Health > 0 then -- 🟢 Kiểm tra mob còn sống
            local distance = (hrp.Position - enemy.head.Position).Magnitude
            if distance < minDistance and distance <= maxAimbotDistance then
                nearestEnemy = enemy.head
                minDistance = distance
            end
        end
    end

    return nearestEnemy
end

-- 🟢 Kích hoạt Aimbot (Chỉ aim vào kẻ địch trong FOV)
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
         if not currentTarget or not currentTarget.Parent or currentTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health <= 0 then
            currentTarget = getNearestEnemy()
        end

        if currentTarget then
            local camera = game.Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position + Vector3.new(0, 0.5, 0))
        end
    else
        currentTarget = nil
    end
end)

-- 🟢 Nút bật/tắt Aimbot
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled -- 🔥 Cập nhật hiển thị FOV
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    print(aimbotEnabled and "🟢 Aimbot ĐÃ BẬT" or "🔴 Aimbot ĐÃ TẮT")
end

AimbotButton.MouseButton1Click:Connect(toggleAimbot)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        toggleAimbot()
    end
end)

-- 🟢 Danh sách màu ESP theo danh mục
local espTargets = {
    ["GoldBar"] = { color = Color3.fromRGB(255, 238, 0), category = "Vật phẩm" },
    ["Coal"] = { color = Color3.fromRGB(235, 121, 72), category = "Vật phẩm" },
    ["Bond"] = { color = Color3.fromRGB(246, 14, 76), category = "Vật phẩm" },
    ["Horse"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob hiếm" },
    ["Wolf"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob hiếm" },
    ["Unicorn"] = { color = Color3.fromRGB(205, 0, 255), category = "Mob hiếm" },
    ["RifleOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["ShotgunOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["RevolverOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["Runner"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["Walker"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["Vampire Knife"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Revolver"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Rifle"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Bolt Action Rifle"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Shotgun"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Cavalry Sword"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Crucifix"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Molotov"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["Holy Water"] = { color = Color3.fromRGB(85, 200, 255), category = "Vũ khí" },
    ["RifleAmmo"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },
    ["ShotgunShells"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },
    ["RevolverAmmo"] = { color = Color3.fromRGB(12, 154, 111), category = "Vũ khí" },

}

-- 🟢 Hàm tạo ESP (Text hiển thị trên đầu)
local function createESP(obj, color)
    if obj:FindFirstChild("ESP_Tag") then return end

    local esp = Instance.new("BillboardGui", obj)
    esp.Name = "ESP_Tag"
    esp.Size = UDim2.new(2, 0, 1, 0)         -- Nhỏ hơn trước
    esp.StudsOffset = Vector3.new(0, 2.5, 0) -- Giảm độ cao ESP để vừa hơn
    esp.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    esp.AlwaysOnTop = true
    esp.MaxDistance = 1000

    local text = Instance.new("TextLabel", esp)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Text = obj.Name
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.BackgroundTransparency = 1
    text.TextSize = 10
    text.TextStrokeTransparency = 0.5
end

local function getObjectPosition(obj)
    if obj:IsA("Tool") then
        return nil -- 🟢 Bỏ qua Tool hoàn toàn
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position -- 🟢 Nếu Model có PrimaryPart, lấy vị trí
        else
            for _, part in pairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    return part.Position -- 🟢 Nếu Model không có PrimaryPart, lấy vị trí của Part đầu tiên
                end
            end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position -- 🟢 Nếu là BasePart (Part, MeshPart), lấy Position
    else
        return nil -- 🛑 Không có vị trí hợp lệ
    end
end


-- 🟢 Cập nhật ESP theo khoảng cách
game:GetService("RunService").RenderStepped:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        local objName = obj.Name
        if espTargets[objName] then
            local category = espTargets[objName].category
            local enabled = false
            for _, opt in ipairs(options) do
                if opt.name == category then
                    enabled = opt.enabled
                    break
                end
            end

            local itemPosition = getObjectPosition(obj)
            if not itemPosition then continue end -- 🟢 Nếu vị trí là nil, bỏ qua vật thể này

            local distance = (itemPosition - hrp.Position).Magnitude

            if enabled and distance <= 1000 then
                if not obj:FindFirstChild("ESP_Tag") then
                    createESP(obj, espTargets[objName].color)
                end
            else
                if obj:FindFirstChild("ESP_Tag") then
                    obj.ESP_Tag:Destroy()
                end
            end
        end
    end
end)
