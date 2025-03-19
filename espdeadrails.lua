-- 🟢 Tạo GUI Menu
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ESPButton = Instance.new("TextButton")
local DistanceLabel = Instance.new("TextLabel")
local DistanceSlider = Instance.new("TextBox")
local OptionsFrame = Instance.new("Frame")

local options = {
    { name = "Vật phẩm", enabled = false },
    { name = "Enemies bán được", enabled = false },
    { name = "Mob hiếm", enabled = false },
    { name = "Zombies", enabled = false }
}

ScreenGui.Parent = game.CoreGui

-- 🟢 Khung chính
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true

-- 🟢 Nút ESP
ESPButton.Parent = MainFrame
ESPButton.Size = UDim2.new(0, 180, 0, 40)
ESPButton.Position = UDim2.new(0, 10, 0, 5)
ESPButton.Text = "ESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

-- 🟢 Khung danh sách chọn
OptionsFrame.Parent = ScreenGui
OptionsFrame.Size = UDim2.new(0, 200, 0, #options * 40 + 10)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OptionsFrame.BorderSizePixel = 2
OptionsFrame.Visible = false

-- 🟢 Cập nhật vị trí OptionsFrame theo MainFrame
local function updateOptionsFramePosition()
    OptionsFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 10, 0, MainFrame.Position.Y.Offset)
end

ESPButton.MouseButton1Click:Connect(function()
    OptionsFrame.Visible = not OptionsFrame.Visible
    updateOptionsFramePosition()
end)

-- 🟢 Tạo danh sách nút trong OptionsFrame
for i, option in ipairs(options) do
    local optionButton = Instance.new("TextButton")
    optionButton.Parent = OptionsFrame
    optionButton.Size = UDim2.new(0, 180, 0, 40)
    optionButton.Position = UDim2.new(0, 10, 0, (i - 1) * 40)
    optionButton.Text = option.name
    optionButton.BackgroundColor3 = option.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    optionButton.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        optionButton.BackgroundColor3 = option.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- 🟢 Hỗ trợ kéo thả GUI (MainFrame + OptionsFrame)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, startPos, dragStart

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    updateOptionsFramePosition()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- 🟢 Danh sách màu ESP theo danh mục
local espTargets = {
    ["GoldBar"] = { color = Color3.fromRGB(255, 215, 0), category = "Vật phẩm" },
    ["Horse"] = { color = Color3.fromRGB(255, 165, 0), category = "Mob hiếm" },
    ["Unicorn"] = { color = Color3.fromRGB(0, 255, 255), category = "Mob hiếm" },
    ["RifleOutlaw"] = { color = Color3.fromRGB(255, 0, 0), category = "Enemies bán được" },
    ["ShotgunOutlaw"] = { color = Color3.fromRGB(0, 0, 255), category = "Enemies bán được" },
    ["Runner"] = { color = Color3.fromRGB(255, 0, 0), category = "Zombies" },
    ["Walker"] = { color = Color3.fromRGB(0, 0, 255), category = "Zombies" }
}


-- 🟢 Hàm tạo ESP (Text hiển thị trên đầu)
local function createESP(obj, color)
    if obj:FindFirstChild("ESP_Tag") then return end

    local esp = Instance.new("BillboardGui", obj)
    esp.Name = "ESP_Tag"
    esp.Size = UDim2.new(3, 0, 1.5, 0)
    esp.StudsOffset = Vector3.new(0, 3, 0) -- Đẩy ESP lên trên đầu vật phẩm
    esp.Adornee = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    esp.AlwaysOnTop = true
    esp.MaxDistance = 2000

    local text = Instance.new("TextLabel", esp)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Text = obj.Name
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextStrokeTransparency = 0.5 -- Giúp chữ rõ hơn
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

            local itemPosition = obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position or obj.Position
            local distance = (itemPosition - hrp.Position).Magnitude

            if enabled and distance <= tonumber(DistanceSlider.Text) then
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

