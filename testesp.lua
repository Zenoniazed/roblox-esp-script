-- 🟢 Tạo GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local NoclipButton = Instance.new("TextButton")     -- 🟢 Nút Noclip
local AimbotButton = Instance.new("TextButton")
local FullbrightButton = Instance.new("TextButton") -- 🟢 Nút Fullbright
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
AimbotButton.Position = UDim2.new(0, 135, 0, 5)           -- Đặt dưới Noclip
AimbotButton.Text = "Aimbot"
AimbotButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Mặc định là tắt

-- 🟢 Nút Fullbright
FullbrightButton.Parent = MainFrame
FullbrightButton.Size = UDim2.new(0, 60, 0, 40)
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
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")

-- 🟢 Hàm áp dụng cấu hình Fullbright
local function applyFullbright()
    lighting.Brightness = 1.5
    lighting.ClockTime = 14.5
    lighting.FogStart = 0
    lighting.FogEnd = 100000
    lighting.FogColor = Color3.new(0.752941, 0.752941, 0.752941)
    lighting.Ambient = Color3.new(0.611765, 0.611765, 0.611765)
    lighting.OutdoorAmbient = Color3.new(0.611765, 0.611765, 0.611765)
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
    FullbrightButton.BackgroundColor3 = fullbrightEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

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
-- 🟢 Biến điều khiển
local aimbotEnabled = false
local mouse = game.Players.LocalPlayer:GetMouse()
local enemiesList = {}
local currentTarget = nil
local maxAimbotDistance = 750
local aimbotFOVRadius = 75

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

local function isWithinFOV(target)
    local camera = game.Workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)
    if not onScreen then return false end
    local center = camera.ViewportSize / 2
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(center.X, center.Y)).Magnitude
    return dist <= aimbotFOVRadius
end

-- 🟢 Cập nhật danh sách enemy
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

-- 🟢 Tìm enemy gần nhất có thể nhìn thấy
local function getNearestEnemy()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, minDistance = nil, math.huge
    local camera = game.Workspace.CurrentCamera
    local origin = camera.CFrame.Position

    for _, enemy in pairs(enemiesList) do
        if enemy.head and enemy.head.Parent and enemy.humanoid.Health > 0 and isWithinFOV(enemy.head) then
            local distance = (hrp.Position - enemy.head.Position).Magnitude
            if distance <= maxAimbotDistance and distance < minDistance then
                -- 🔍 Raycast kiểm tra vật cản
                local direction = (enemy.head.Position - origin)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = { character }
                rayParams.IgnoreWater = true
                local hit = game.Workspace:Raycast(origin, direction, rayParams)

                if not hit or (hit.Instance and hit.Instance:IsDescendantOf(enemy.model)) then
                    nearest = enemy.head
                    minDistance = distance
                end
            end
        end
    end

    return nearest
end

-- 🟢 Cập nhật mục tiêu mỗi 0.1s
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

-- 🟢 Aim vào mục tiêu đã chọn (mỗi frame)
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled and currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health > 0 then
        local camera = game.Workspace.CurrentCamera
        local aimPosition = currentTarget.Position + Vector3.new(0, 0.5, 0)
        camera.CFrame = CFrame.new(camera.CFrame.Position, aimPosition)
    end
end)

-- 🟢 Nút bật/tắt Aimbot (với T hoặc GUI)
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    FOVCircle.Visible = aimbotEnabled
    if AimbotButton then
        AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
    print(aimbotEnabled and "🟢 Aimbot ĐÃ BẬT" or "🔴 Aimbot ĐÃ TẮT")
end

if AimbotButton then
    AimbotButton.MouseButton1Click:Connect(toggleAimbot)
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.T then
        toggleAimbot()
    end
end)


local CollectionService = game:GetService("CollectionService")

-- 🟢 Danh sách màu ESP theo danh mục
-- 🟢 Danh sách màu ESP theo danh mục
local espTargets = {
    ["GoldBar"] = { color = Color3.fromRGB(255, 238, 0), category = "Vật phẩm" },
    ["Coal"] = { color = Color3.fromRGB(235, 121, 72), category = "Vật phẩm" },
    ["Bond"] = { color = Color3.fromRGB(246, 14, 76), category = "Vật phẩm" },
    ["Bandage"] = { color = Color3.fromRGB(255, 153, 255), category = "Vật phẩm" },
    ["Snake Oil"] = { color = Color3.fromRGB(255, 153, 255), category = "Vật phẩm" },
    
    ["Horse"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob" },
    ["Wolf"] = { color = Color3.fromRGB(255, 255, 255), category = "Mob" },
    ["Unicorn"] = { color = Color3.fromRGB(205, 0, 255), category = "Mob" },
    
    ["RifleOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["ShotgunOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    ["RevolverOutlaw"] = { color = Color3.fromRGB(0, 213, 255), category = "Enemies bán được" },
    
    ["Runner"] = { color = Color3.fromRGB(155, 103, 232), category = "Zombies" },
    ["Walker"] = { color = Color3.fromRGB(155, 103, 232), category = "Zombies" },
    ["Banker"] = { color = Color3.fromRGB(155, 103, 100), category = "Zombies" },
    ["ArmoredZombie"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["ZombieMiner"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["ZombieSheriff"] = { color = Color3.fromRGB(85, 0, 255), category = "Zombies" },
    ["WereWolf"] = { color = Color3.fromRGB(141, 75, 240), category = "Zombies" },
    ["Dracula"] = { color = Color3.fromRGB(141, 75, 240), category = "Zombies" },
    
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

        if enabled and distance <= 1000 then
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

