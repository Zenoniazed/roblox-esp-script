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
toggleButton.Position = UDim2.new(0, 50, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.Text = "Ẩn"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

local autoRunning = true
local visible = true
-- 🔁 Toggle hiển thị
local visible = true
toggleButton.MouseButton1Click:Connect(function()
    visible = not visible
    mainFrame.Visible = visible
    toggleButton.Text = visible and "Ẩn" or "Hiện"
         autoRunning = visible
end)

-- 🔄 Cập nhật offerings từ WishFountain
local function updateOfferings()
    local basePath = workspace.FairyEvent.WishFountain
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
    local basePath = workspace.FairyEvent.WishFountain
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

-- 🍅 Thu hoạch theo offerings
local function collectByOffering()
    local farm = getMyFarm()
    if not farm then 
        warn("❌ Không tìm thấy farm của bạn")
        return 
    end

    local plantsFolder = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then 
        warn("❌ Không tìm thấy Plants_Physical trong farm")
        return 
    end

    local totalChecked, totalCollected = 0, 0
    local needCollect = false

    for i = 1, 3 do
        local labelText = labels[i].Text
        local plantName, current, total = parseLabelText(labelText)

        if plantName and current < total then
            local need = total - current
            needCollect = true
            print(string.format("🔍 Đang xử lý Offering_%d: %s | Đã có: %d/%d | Cần thêm: %d", i, plantName, current, total, need))

            for _, plant in ipairs(plantsFolder:GetChildren()) do
                if plant.Name == plantName then
                    print("🌱 Đang xử lý cây:", plant.Name)

                    if plant.Name == "Mushroom" then
                        -- 🍄 Mushroom phải có Glimmering
                        if plant:GetAttribute("Glimmering") == true then
                            print("✨ Thu hoạch Mushroom:", plant.Name)
                            local success, err = pcall(function()
                                Collect:FireServer({ plant })
                                task.wait(0.7)
                            end)
                            if success then
                                totalCollected += 1
                                need -= 1
                                print(string.format("✅ Đã thu Mushroom | Còn cần: %d", need))
                            else
                                warn("❌ Lỗi khi thu Mushroom:", err)
                            end
                        else
                            print("⏭️ Bỏ qua Mushroom:", plant.Name, "| Lý do: Không có Glimmering")
                        end
                    
                    elseif plant.Name == "Watermelon" then
                        -- 🍉 Watermelon chỉ cần Glimmering, không cần duyệt Fruits
                        if plant:GetAttribute("Glimmering") == true then
                            print("✨ Thu hoạch Watermelon:", plant.Name)
                            local success, err = pcall(function()
                                Collect:FireServer({ plant })
                                task.wait(0.7)
                            end)
                            if success then
                                totalCollected += 1
                                need -= 1
                                print(string.format("✅ Đã thu Watermelon | Còn cần: %d", need))
                            else
                                warn("❌ Lỗi khi thu Watermelon:", err)
                            end
                        else
                            print("⏭️ Bỏ qua Watermelon:", plant.Name, "| Lý do: Không có Glimmering")
                        end
                    
                    elseif plant:FindFirstChild("Fruits") then
                        -- 🍎 Các cây có trái bình thường
                        for _, fruit in ipairs(plant.Fruits:GetChildren()) do
                            local glimmering = fruit:GetAttribute("Glimmering")
                            local maxAge = fruit:GetAttribute("MaxAge")
                            local growFolder = fruit:FindFirstChild("Grow")
                            local ageValue = growFolder and growFolder:FindFirstChild("Age")
                    
                            if ageValue and maxAge and glimmering and ageValue.Value >= maxAge then
                                print("✨ Thu hoạch trái:", fruit.Name)
                                local success, err = pcall(function()
                                    Collect:FireServer({ fruit })
                                    task.wait(0.7)
                                end)
                                if success then
                                    totalCollected += 1
                                    need -= 1
                                    print(string.format("✅ Đã thu trái %s | Còn cần: %d", fruit.Name, need))
                                    if need <= 0 then break end
                                else
                                    warn("❌ Lỗi khi thu:", err)
                                end
                                task.wait(1.2)
                            end
                        end
                    
                    else
                        -- 🌿 Cây không có Fruits và không phải Mushroom/Watermelon
                        if plant:GetAttribute("Glimmering") == true then
                            print("✨ Thu hoạch cây chính:", plant.Name)
                            local success, err = pcall(function()
                                Collect:FireServer({ plant })
                                task.wait(0.7)
                            end)
                            if success then
                                totalCollected += 1
                                need -= 1
                                print(string.format("✅ Đã thu %s | Còn cần: %d", plant.Name, need))
                            else
                                warn("❌ Lỗi khi thu:", err)
                            end
                            task.wait(1.2)
                        else
                            print("⏭️ Bỏ qua cây:", plant.Name, "| Lý do: Không có Glimmering")
                        end
                    end
                    
                    if need <= 0 then break end
                end
            end
        end
    end

    print(string.format("📊 Tổng kết vòng này: Đã kiểm tra %d trái | Thu hoạch thành công %d", totalChecked, totalCollected))

    if needCollect then
        updateOfferings()
    end
end


-- 🔁 Auto loop
task.spawn(function()
    while true do
        if autoRunning then
            collectByOffering()
        end
        task.wait(5)
    end
end)
