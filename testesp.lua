-- 🟢 Tạo GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local NoclipButton = Instance.new("TextButton") -- 🟢 Nút Noclip
local AimbotButton = Instance.new("TextButton")
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
MainFrame.Size = UDim2.new(0, 250, 0, 50) -- 🟢 Tăng chiều cao để chứa Noclip
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
-- 🟢 Biến điều khiển Aimbot
local aimbotEnabled = false
local currentTarget = nil
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

-- 🟢 Hàm tìm kẻ địch gần nhất (Chỉ Mob/Zombie, không nhắm vào người chơi)
local function getNearestEnemy()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearestEnemy = nil
    local minDistance = math.huge

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
            -- 🟢 Kiểm tra nếu obj KHÔNG PHẢI là người chơi (bỏ qua Player)
            local enemyHumanoid = obj:FindFirstChild("Humanoid")
            local enemyHead = obj:FindFirstChild("Head") -- 🔹 Kiểm tra Head thay vì HumanoidRootPart

            -- 🟢 Kiểm tra nếu mob còn sống (`Health > 0`)
            if enemyHumanoid and enemyHumanoid.Health > 0 and enemyHead then
                local distance = (hrp.Position - enemyHead.Position).Magnitude
                if distance < minDistance and distance <= 250 then -- 🟢 Giới hạn phạm vi Aimbot
                    nearestEnemy = enemyHead -- 🔹 Nhắm vào Head thay vì RootPart
                    minDistance = distance
                end
            end
        end
    end

    return nearestEnemy
end

-- 🟢 Kích hoạt Aimbot (Tối ưu)
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getNearestEnemy() -- 🔹 Luôn cập nhật mục tiêu
        if target then
            currentTarget = target -- 🔹 Gán mục tiêu mới
        end

        if currentTarget and currentTarget.Parent and currentTarget:IsA("BasePart") then
            -- 🟢 Kiểm tra xem mục tiêu có hợp lệ không trước khi cập nhật camera
            pcall(function()
                camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position + Vector3.new(0, 0.5, 0)) -- 🔹 Nhắm vào đầu
            end)
        end
    else
        currentTarget = nil -- 🔴 Tắt Aimbot thì reset target
    end
end)

-- 🟢 Nút bật/tắt Aimbot
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    print(aimbotEnabled and "🟢 Aimbot ĐÃ BẬT" or "🔴 Aimbot ĐÃ TẮT")
end

AimbotButton.MouseButton1Click:Connect(toggleAimbot)

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
