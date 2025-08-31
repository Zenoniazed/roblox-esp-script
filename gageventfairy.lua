local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Collect = ReplicatedStorage.GameEvents.Crops.Collect

-- 📺 Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OfferingDisplay"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 🧱 Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0, 70, 0, 130)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- 📦 Frame chứa labels
local labelFrame = Instance.new("Frame")
labelFrame.Size = UDim2.new(1, -20, 0, 120)
labelFrame.Position = UDim2.new(0, 10, 0, 10)
labelFrame.BackgroundTransparency = 1
labelFrame.Parent = mainFrame

-- 📐 Layout cho labels
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = labelFrame

-- 🏷️ Tạo label
local function createLabel()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 220, 120)
    label.TextStrokeTransparency = 0.3
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = "..."
    label.Parent = labelFrame
    return label
end

-- 🏷️ Tạo 3 label
local labels = {}
for i = 1, 3 do
    labels[i] = createLabel()
end

-- 🔘 Nút bật/tắt
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 35)
toggleButton.Position = UDim2.new(0.5, -50, 1, -40)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.Text = "Ẩn"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- 🔁 Toggle hiển thị
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    labelFrame.Visible = visible
    toggleButton.Text = visible and "Ẩn" or "Hiện"
end)

-- 🧠 Đánh dấu cây đã thu
local collectedFlags = {}

-- 🔄 Cập nhật offerings từ WishFountain
local function updateOfferings()
    collectedFlags = {} -- reset trạng thái thu mỗi khi offerings thay đổi
    local basePath = workspace.Interaction.UpdateItems.FairyEvent.WishFountain
    for i = 1, 3 do
        local offering = basePath:FindFirstChild("Offering_" .. i)
        if offering and offering:FindFirstChild("GUI") then
            local surfaceGui = offering.GUI:FindFirstChild("SurfaceGui")
            if surfaceGui and surfaceGui:FindFirstChild("TextLabel") then
                labels[i].Text = surfaceGui.TextLabel.Text
            else
                labels[i].Text = "(Không thấy TextLabel)"
            end
        else
            labels[i].Text = "(Không có Offering_" .. i .. ")"
        end
    end
end

updateOfferings()

-- 👂 Theo dõi thay đổi text
local basePath = workspace.Interaction.UpdateItems.FairyEvent.WishFountain
for i = 1, 3 do
    local offering = basePath:FindFirstChild("Offering_" .. i)
    if offering and offering:FindFirstChild("GUI") then
        local surfaceGui = offering.GUI:FindFirstChild("SurfaceGui")
        if surfaceGui then
            local tl = surfaceGui:FindFirstChild("TextLabel")
            if tl then
                tl:GetPropertyChangedSignal("Text"):Connect(updateOfferings)
            end
        end
    end
end

-- 📤 Tách tên cây từ label
local function parseLabelText(text)
    local _, _, rawName = string.match(text, "^(%d+)/(%d+)%s+(.+)$")
    if rawName then
        local cleanName = string.gsub(rawName, "^Glimmering%s+", "")
        return cleanName
    end
    return nil
end

-- 🌱 Tìm farm của người chơi
local function getMyFarm()
    local farmFolder = workspace:FindFirstChild("Farm")
    if not farmFolder then return nil end

    for _, farm in ipairs(farmFolder:GetChildren()) do
        local sign = farm:FindFirstChild("Sign")
        if sign and sign:GetAttribute("_owner") == player.Name then
            return farm
        end
    end
    return nil
end

-- 🍅 Thu hoạch đúng 1 lần duy nhất
local function collectByOffering()
    local farm = getMyFarm()
    if not farm then return end

    local plantsFolder = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then return end

    for i = 1, 3 do
        local labelText = labels[i].Text
        local plantName = parseLabelText(labelText)

        if not plantName or collectedFlags[plantName] then
            continue
        end

        print("🌿 Đang xử lý:", plantName)

        for _, plant in ipairs(plantsFolder:GetChildren()) do
            if plant.Name == plantName then
                local fruitsFolder = plant:FindFirstChild("Fruits")
                local targets = {}

                if fruitsFolder and #fruitsFolder:GetChildren() > 0 then
                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                        if fruit:GetAttribute("Glimmering") == true then
                            table.insert(targets, fruit)
                        end
                    end
                elseif plant:GetAttribute("Glimmering") == true then
                    table.insert(targets, plant)
                end

                for _, target in ipairs(targets) do
                    local success, err = pcall(function()
                        Collect:FireServer({ target })
                    end)
                    if success then
                        print("✅ Đã thu:", target.Name)
                    else
                        warn("❌ Lỗi khi thu:", err)
                    end
                    task.wait(3)
                end

                collectedFlags[plantName] = true
                print("🎉 Đã hoàn thành:", plantName)
            end
        end
    end
end

-- 🔁 Vòng lặp tự động
while task.wait(3) do
    collectByOffering()
end
