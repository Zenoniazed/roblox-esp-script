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

-- 🍅 Thu hoạch tất cả offerings (cây 1 → cây 2 → cây 3)
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

    local needCollect = false

    for i = 1, 3 do
        local labelText = labels[i].Text
        local plantName, current, total = parseLabelText(labelText)

        if plantName and current < total then
            local need = total - current
            needCollect = true
            print(string.format("🔍 Đang tìm cây: %s | Đang có: %d/%d | Cần thu thêm: %d", plantName, current, total, need))

            for _, plant in ipairs(plantsFolder:GetChildren()) do
                if plant.Name == plantName then
                    local targets = {}

                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder and #fruitsFolder:GetChildren() > 0 then
                        for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                            print("🔎 Kiểm tra trái:", fruit.Name)

                            local glimmering = fruit:GetAttribute("Glimmering")
                            local maxAge = fruit:GetAttribute("MaxAge")
                            local growFolder = fruit:FindFirstChild("Grow")
                            local ageValue = growFolder and growFolder:FindFirstChild("Age")

                            if not glimmering then
                                print("⏭️ Bỏ qua:", fruit.Name, "| Lý do: Không có Glimmering")
                                continue
                            end
                            if not maxAge then
                                print("⏭️ Bỏ qua:", fruit.Name, "| Lý do: Không có MaxAge")
                                continue
                            end
                            if not ageValue then
                                print("⏭️ Bỏ qua:", fruit.Name, "| Lý do: Không tìm thấy Age")
                                continue
                            end

                            print(string.format("🧪 Trái %s | Age = %.2f | MaxAge = %.2f | Glimmering = %s", fruit.Name, ageValue.Value, maxAge, tostring(glimmering)))

                            if glimmering == true and ageValue.Value >= maxAge then
                                print("✨ Thêm vào danh sách thu hoạch:", fruit.Name)
                                table.insert(targets, fruit)
                            else
                                print("⏭️ Bỏ qua:", fruit.Name, "| Lý do: Chưa đạt Age >= MaxAge")
                            end
                        end
                    else
                        -- Nếu không có Fruits, kiểm tra cây chính
                        if plant:GetAttribute("Glimmering") == true then
                            print("✨ Cây chính có Glimmering, thêm vào danh sách:", plant.Name)
                            table.insert(targets, plant)
                        else
                            print("⏭️ Bỏ qua cây chính:", plant.Name, "| Lý do: Không có Fruits và không có Glimmering")
                        end
                    end

                    -- ✅ Thu hoạch đúng số lượng cần
                    local collected = 0
                    for _, target in ipairs(targets) do
                        if collected >= need then break end

                        print("🚀 Gửi yêu cầu thu hoạch:", target.Name)
                        local success, err = pcall(function()
                            Collect:FireServer({ target })
                        end)

                        if success then
                            collected += 1
                            print("✅ Đã thu:", target.Name, "| Tổng đã thu:", collected)
                        else
                            warn("❌ Lỗi khi thu:", err)
                        end

                        task.wait(1.2) -- delay nhỏ để server xử lý
                    end

                    print("⏹️ Hoàn thành xử lý cây:", plantName)
                    break -- xong cây này thì qua cây tiếp theo
                end
            end
        else
            print("⏭️ Bỏ qua Offering_"..i.." | Lý do: Không có nhu cầu thu hoạch hoặc label sai")
        end
    end

    if needCollect then
        print("🔄 Đang cập nhật lại Offerings sau khi thu hoạch...")
        updateOfferings()
    else
        print("✅ Không có gì cần thu hoạch trong lượt này")
    end
end


-- 🔁 Vòng lặp tự động
while task.wait(3) do
    collectByOffering()
end

