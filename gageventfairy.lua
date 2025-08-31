local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

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

-- 🏷️ Hàm tạo label
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
toggleButton.Position = UDim2.new(0, 30, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.Text = "Ẩn"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- 🔁 Toggle hiển thị
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    mainFrame.Visible = visible
    toggleButton.Text = visible and "Ẩn" or "Hiện"
end)

-- 🔄 Cập nhật offerings từ WishFountain
local function updateOfferings()
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
do
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
end

-- 🌽 Remote thu hoạch
local Collect = ReplicatedStorage.GameEvents.Crops.Collect

-- 📌 Parse text "0/1 Glimmering Corn" → "Corn", 0, 1
local function parseLabelText(text)
    local current, total, rawName = string.match(text, "^(%d+)/(%d+)%s+(.+)$")
    if current and total and rawName then
        local cleanName = string.gsub(rawName, "^Glimmering%s+", "")
        return cleanName, tonumber(current), tonumber(total)
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

-- 📌 Hàm check trái đã "ổn định" chưa (Age không đổi trong 0.1s)
local function isFruitStable(fruit)
    local grow = fruit:FindFirstChild("Grow")
    if not grow then return true end

    local age = grow:FindFirstChild("Age")
    if not age or not age:IsA("NumberValue") then return true end

    local oldValue = age.Value
    local changed = false

    local conn
    conn = age.Changed:Connect(function(newVal)
        if newVal ~= oldValue then
            changed = true
        end
    end)

    task.wait(0.5) -- chỉ chờ rất ngắn
    conn:Disconnect()

    return not changed
end

-- 🍅 Thu hoạch theo offerings (dùng check nhanh)
local function collectByOffering()
    local farm = getMyFarm()
    if not farm then 
        warn("⚠️ Không tìm thấy farm của bạn") 
        return 
    end

    local plantsFolder = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then 
        warn("⚠️ Không tìm thấy Plants_Physical trong farm") 
        return 
    end

    local needCollect = false

    for i = 1, 3 do
        local labelText = labels[i].Text
        local plantName, current, total = parseLabelText(labelText)

        if plantName and current < total then
            local need = total - current
            needCollect = true
            print("🔍 Đang tìm cây:", plantName, "| Cần thu:", need)

            for _, plant in ipairs(plantsFolder:GetChildren()) do
                if plant.Name == plantName then
                    local targets = {}

                    -- Ưu tiên trái glimmering ổn định
                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                            if fruit:GetAttribute("Glimmering") == true and isFruitStable(fruit) then
                                table.insert(targets, fruit)
                            end
                        end
                    end

                    -- Nếu không có trái nào ổn định, thử thu hoạch cây chính
                    if #targets == 0 and plant:GetAttribute("Glimmering") == true then
                        table.insert(targets, plant)
                    end

                    -- Thu hoạch đúng số lượng cần
                    local collected = 0
                    for _, target in ipairs(targets) do
                        if collected >= need then break end

                        local success, err = pcall(function()
                            Collect:FireServer({ target })
                        end)

                        if success then
                            collected += 1
                            print("✅ Đã thu:", target.Name)
                        else
                            warn("❌ Lỗi khi thu:", err)
                        end

                        task.wait(1.2) -- delay nhỏ để server nhận kịp
                    end

                    -- Xong cây này thì qua cây tiếp theo
                    break
                end
            end
        end
    end

    if needCollect then
        updateOfferings()
    end
end

-- 🔁 Vòng lặp tự động
while task.wait(3) do
    collectByOffering()
end



