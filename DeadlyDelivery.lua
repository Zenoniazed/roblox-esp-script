---------------------------------------------------------------------
-- PLAYER SETUP
---------------------------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

---------------------------------------------------------------------
-- LOOT & RETURN LOCATION
---------------------------------------------------------------------
local LootWorld = workspace.GameSystem.Loots.World
local returnPoint = workspace["\231\148\181\230\162\175"].Left4:GetChildren()[2]

---------------------------------------------------------------------
-- UI GỌN + KÉO THẢ (MOBILE FIX)
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "LootBoard"
gui.Parent = game.CoreGui
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 260, 0, 360)
main.Position = UDim2.new(0, 20, 0, 150)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

-- **MOBILE FIX: Không block Joystick**
main.Active = false
main.Selectable = false
main.ClipsDescendants = false
main.ZIndex = 1

-- HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
header.BorderSizePixel = 0
Instance.new("UICorner", header)

-- **HEADER nhận input để kéo**
header.Active = true
header.Selectable = true
header.ZIndex = 999

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "📦 Loot List"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

---------------------------------------------------------------------
-- DRAG UI (PC + MOBILE FIX)
---------------------------------------------------------------------
local dragging = false
local dragStart, uiStart

local function beginDrag(input)
	dragging = true
	dragStart = input.Position
	uiStart = main.Position
end

local function endDrag() dragging = false end

local function updateDrag(input)
	if dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			uiStart.X.Scale,
			uiStart.X.Offset + delta.X,
			uiStart.Y.Scale,
			uiStart.Y.Offset + delta.Y
		)

		-- **Giới hạn UI trong màn hình (mobile fix mất nút game)**
		local screen = workspace.CurrentCamera.ViewportSize
		local x = main.AbsolutePosition.X
		local y = main.AbsolutePosition.Y
		local w = main.AbsoluteSize.X
		local h = main.AbsoluteSize.Y

		if x < 0 then main.Position = UDim2.new(0,0, main.Position.Y.Scale, main.Position.Y.Offset) end
		if y < 0 then main.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, 0, 0) end
		if x + w > screen.X then main.Position = UDim2.new(0, screen.X - w, main.Position.Y.Scale, main.Position.Y.Offset) end
		if y + h > screen.Y then main.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, 0, screen.Y - h) end
	end
end

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
	or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input)
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		endDrag()
	end
end)

UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input)
	end
end)

---------------------------------------------------------------------
-- SCROLL LIST LOOT
---------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0, 0, 0, 32)
scroll.Size = UDim2.new(1, 0, 1, -82)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder

---------------------------------------------------------------------
-- RETURN BUTTON
---------------------------------------------------------------------
local backBtn = Instance.new("TextButton", main)
backBtn.Size = UDim2.new(1, -20, 0, 38)
backBtn.Position = UDim2.new(0, 10, 1, -42)
backBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
backBtn.TextColor3 = Color3.new(1,1,1)
backBtn.Font = Enum.Font.GothamBold
backBtn.Text = "⬅ Quay lại"
backBtn.BorderSizePixel = 0
Instance.new("UICorner", backBtn)

local function teleportBack()
	local target = returnPoint.PrimaryPart 
				or returnPoint:FindFirstChildWhichIsA("BasePart") 
				or returnPoint
	hrp.CFrame = target.CFrame * CFrame.new(0, 0, -2)
end

backBtn.MouseButton1Click:Connect(teleportBack)

---------------------------------------------------------------------
-- HÀM ĐỌC LOOT UI (TỐI ƯU)
---------------------------------------------------------------------
local function getLootUI(loot)
	local c = loot:FindFirstChild("Folder") or loot:FindFirstChild("Interactable")
	if not c then return end

	if c:FindFirstChild("Interactable") then
		c = c.Interactable
	end

	if c:FindFirstChild("LootUI") and c.LootUI:FindFirstChild("Frame") then
		return c.LootUI.Frame
	end
end

local function extractPrice(str)
	if not str then return nil end
	local num = str:match("%d+")
	return tonumber(num)
end

---------------------------------------------------------------------
-- TẠO BUTTON LOOT
---------------------------------------------------------------------
local function createButton(txt)
	local b = Instance.new("TextButton")
	b.Parent = scroll
	b.Size = UDim2.new(1, -20, 0, 34)
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Text = txt
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

---------------------------------------------------------------------
-- UPDATE LOOT LIST UI
---------------------------------------------------------------------
local function updateList()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local items = {}

	for _, loot in ipairs(LootWorld:GetChildren()) do
		local ui = getLootUI(loot)
		if ui then
			local nameObj = ui:FindFirstChild("ItemName")
			local priceObj = ui:FindFirstChild("Price")
			if nameObj and priceObj then
				local name = nameObj.Text
				local price = extractPrice(priceObj.Text)
				if price then
					table.insert(items, {loot=loot, name=name, price=price})
				end
			end
		end
	end

	table.sort(items, function(a,b)
		return a.price > b.price
	end)

	for _, item in ipairs(items) do
		local btn = createButton(item.name .. " | $" .. item.price)
		btn.MouseButton1Click:Connect(function()
			local part = item.loot.PrimaryPart or item.loot:FindFirstChildWhichIsA("BasePart")
			if part then
				hrp.CFrame = part.CFrame * CFrame.new(0, 2, 0)
			end
		end)
	end
end

-- Auto refresh
LootWorld.ChildAdded:Connect(function() task.wait(0.2) updateList() end)
LootWorld.ChildRemoved:Connect(function() task.wait(0.2) updateList() end)
task.spawn(function()
	while true do updateList() task.wait(1) end
end)
updateList()

---------------------------------------------------------------------
-- PRESS E (KHÔNG NHÂN ĐÔI)
---------------------------------------------------------------------
local function pressE()
	VIM:SendKeyEvent(true, "E", false, game)
	task.wait(0.05)
	VIM:SendKeyEvent(false, "E", false, game)
end

local function getSafePart(obj)
	if not obj then return nil end

	-- 1. Nếu bản thân obj là BasePart
	if obj:IsA("BasePart") then
		return obj
	end

	-- 2. Nếu có PrimaryPart
	if obj.PrimaryPart then
		return obj.PrimaryPart
	end

	-- 3. Tìm BasePart trực tiếp
	local first = obj:FindFirstChildWhichIsA("BasePart")
	if first then return first end

	-- 4. Tìm BasePart trong mọi con
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("BasePart") then
			return d
		end
	end

	return nil
end

local function safeTeleportPro(targetCFrame)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- TẮT ragdoll
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	end)

	-- RESET speed
	hrp.Velocity = Vector3.zero
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- ANCHOR
	hrp.Anchored = true

	-- NẾU VỊ TRÍ QUÁ THẤP → TỰ SỬA
	if targetCFrame.Y < 6 then
		targetCFrame = CFrame.new(targetCFrame.X, 6, targetCFrame.Z)
	end

	-- ĐẶT NHÂN VẬT
	hrp.CFrame = targetCFrame

	task.wait(0.05)

	-- GỠ ANCHOR
	hrp.Anchored = false

	-- CHỐNG RƠI SAU KHI TP
	task.wait(0.02)
	hrp.Velocity = Vector3.zero
	hrp.AssemblyLinearVelocity = Vector3.zero
end


local SUPER_FAST_DELAY = 0.2
local NO_ROTATION = false 

-----------------------------------------------------------------
-- TELE AN TOÀN (KHÔNG XOAY)
-----------------------------------------------------------------
local function safeTeleport(part)
	local pos = part.CFrame * CFrame.new(0, 0, 0)  -- Cao 4, lùi 4 → không bao giờ ngã

	hrp.Anchored = true
	hrp.CFrame = pos
	task.wait(0.03)
	hrp.Anchored = false

	if NO_ROTATION == false then
		task.wait(0.03)
		hrp.CFrame = CFrame.new(hrp.Position, part.Position)
	end
end
---------------------------------------------------------------------
-- AUTO OPEN TỦ / CRATE
---------------------------------------------------------------------
local autoOpening = false
local autoOpenBtn = Instance.new("TextButton", main)
autoOpenBtn.Size = UDim2.new(1, -20, 0, 38)
autoOpenBtn.Position = UDim2.new(0, 10, 1, -84)
autoOpenBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
autoOpenBtn.TextColor3 = Color3.new(1,1,1)
autoOpenBtn.Font = Enum.Font.GothamBold
autoOpenBtn.Text = "▶ Auto Mở"
autoOpenBtn.BorderSizePixel = 0
Instance.new("UICorner", autoOpenBtn)

local function getAllInteractables()
	local t = {}
	for _, obj in ipairs(workspace.GameSystem.InteractiveItem:GetChildren()) do
		if obj:FindFirstChild("Interactable") then
			table.insert(t, obj)
		end
	end
	return t
end

local function getInteractPart(obj)
	-- Interactable trực tiếp có BasePart
	if obj:FindFirstChildWhichIsA("BasePart") then
		return obj:FindFirstChildWhichIsA("BasePart")
	end

	-- Interactable chứa Folder hoặc SubParts
	for _, child in ipairs(obj:GetDescendants()) do
		if child:IsA("BasePart") then
			return child
		end
	end

	return nil
end


local function autoOpen()
	if autoOpening then return end
	if autoLooting then return end -- chống xung đột

	autoOpening = true
	autoOpenBtn.Text = "⏹ Dừng"

	for _, obj in ipairs(getAllInteractables()) do
		if not autoOpening then break end

		local interactPart = obj:FindFirstChild("Interactable")
		if interactPart then

			-- TELE NHANH
			safeTeleport(interactPart)

			-- NHẤN E
			pressE()

			-- SIÊU NHANH
			task.wait(SUPER_FAST_DELAY)
		end
	end

	autoOpening = false
	teleportBack()
	autoOpenBtn.Text = "▶ Auto Mở"
end

autoOpenBtn.MouseButton1Click:Connect(function()
	if autoOpening then
		autoOpening = false
	else
		task.spawn(autoOpen)
	end
end)

---------------------------------------------------------------------
-- AUTO LOOT (MAIN)
---------------------------------------------------------------------

-- UI HANDS FULL
local function getHandsFullUI()
	local pg = player:WaitForChild("PlayerGui")
	local main = pg:WaitForChild("Main")
	local home = main:WaitForChild("HomePage")
	local hf = home:WaitForChild("HandsFull")
	return hf:WaitForChild("HandsFull")
end

local HandsFullUI = getHandsFullUI()

local function isHandsFull()
	return HandsFullUI.Parent.Visible
end

-- CHECK SLOT
local function slotHasItem(slot)
	local i = slot:FindFirstChild("ItemDetails")
	if not i then return false end
	local name = i:FindFirstChild("ItemName")
	return name and name.Text ~= ""
end

local function isInventoryFull()
	local bottom = player.PlayerGui.Main.HomePage.Bottom
	local c = 0
	for i=1,4 do
		local s = bottom:FindFirstChild(tostring(i))
		if s and slotHasItem(s) then
			c += 1
		end
	end
	return c >= 4
end

local function waitForInventoryClear()
	while isInventoryFull() do
		task.wait(1)
	end
end

local function waitForHandsFree()
	while isHandsFull() do
		task.wait(1)
	end
end

-- DANH SÁCH LOẠI TRỪ
local excludeItems = {
	["Cash"] = true,
	["Bloxy Cola"] = true,
	["Bandage"] = true,
}

-- FILTER GIÁ NÂNG CAO
local priceFilters = {
	["ALL"] = 0,
	["≥ 10$"] = 10,
	["≥ 30$"] = 30,
	["≥ 50$"] = 50,
	["≥ 100$"] = 100,
	["MAX ONLY"] = "MAX"
}

local filterOrder = {"ALL","≥ 10$","≥ 30$","≥ 50$","≥ 100$","MAX ONLY"}
local filterIndex = 1
local currentFilter = "ALL"

local filterBtn = Instance.new("TextButton", main)
filterBtn.Size = UDim2.new(1, -20, 0, 38)
filterBtn.Position = UDim2.new(0, 10, 1, -168)
filterBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
filterBtn.TextColor3 = Color3.new(1,1,1)
filterBtn.Font = Enum.Font.GothamBold
filterBtn.Text = "🎚 Lọc giá: ALL"
filterBtn.BorderSizePixel = 0
Instance.new("UICorner", filterBtn)

filterBtn.MouseButton1Click:Connect(function()
	filterIndex += 1
	if filterIndex > #filterOrder then filterIndex = 1 end

	currentFilter = filterOrder[filterIndex]
	filterBtn.Text = "🎚 Lọc giá: " .. currentFilter
end)

local function getMaxPrice()
    local maxVal = 0
    for _, loot in ipairs(LootWorld:GetChildren()) do
        local ui = getLootUI(loot)
        if ui then
            local p = extractPrice(ui.Price.Text)
            if p and p > maxVal then
                maxVal = p
            end
        end
    end
    return maxVal
end


-- Lấy danh sách loot
local function getAllLootParts()
    local list = {}
    local maxPrice = 0

    if currentFilter == "MAX ONLY" then
        maxPrice = getMaxPrice()
    end

    for _, loot in ipairs(LootWorld:GetChildren()) do
        local ui = getLootUI(loot)
        if ui then
            local name = ui.ItemName.Text
            local price = extractPrice(ui.Price.Text)

            if excludeItems[name] then
                continue
            end

            if price then
                if currentFilter == "MAX ONLY" then
                    if price == maxPrice then
                        table.insert(list, {
                            loot = loot,
                            part = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart"),
                            price = price
                        })
                    end
                elseif price >= priceFilters[currentFilter] then
                    table.insert(list, {
                        loot = loot,
                        part = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart"),
                        price = price
                    })
                end
            end
        end
    end

    table.sort(list, function(a, b)
        return a.price > b.price
    end)

    return list
end


---------------------------------------------------------------------
-- AUTO LOOT UI
---------------------------------------------------------------------
local lootBtn = Instance.new("TextButton", main)
lootBtn.Size = UDim2.new(1, -20, 0, 38)
lootBtn.Position = UDim2.new(0, 10, 1, -126)
lootBtn.BackgroundColor3 = Color3.fromRGB(70,160,70)
lootBtn.TextColor3 = Color3.new(1,1,1)
lootBtn.Font = Enum.Font.GothamBold
lootBtn.Text = "💰 Auto Loot"
lootBtn.BorderSizePixel = 0
Instance.new("UICorner", lootBtn)

autoLooting = false

local function faceCameraTo(part)
	local cam = workspace.CurrentCamera
	local camPos = cam.CFrame.Position
	local look = (part.Position - camPos).Unit
	cam.CFrame = CFrame.new(camPos, camPos + look)
end

---------------------------------------------------------------------
-- AUTO LOOT LOOP
---------------------------------------------------------------------
local function autoLootLoop()
	if autoLooting then return end
	if autoOpening then return end -- chống xung đột

	autoLooting = true
	lootBtn.Text = "⏹ Dừng"

	while autoLooting do
		local loots = getAllLootParts()

		-- ⭐ Nếu không còn loot nào phù hợp → Tele về base
		if #loots == 0 then
			print("[AUTO LOOT] Không còn loot phù hợp → Tele về base")
			teleportBack()
			autoLooting = false    -- tiếp vòng lặp
			lootBtn.Text = "💰 Auto Loot"
		end

		for _, item in ipairs(loots) do
			if not autoLooting then break end

			local safe = getSafePart(item.loot)
			if safe then
				safeTeleportPro(safe.CFrame + Vector3.new(0, 1, 0))
				task.wait(0.1)
				faceCameraTo(safe)
				task.wait(0.25)
				pressE()
			end


			if isHandsFull() then
				teleportBack()
				task.wait(0.5)
				waitForHandsFree()
			end

			if isInventoryFull() then
				teleportBack()
				task.wait(0.5)
				waitForInventoryClear()
			end

			task.wait(0.1)
		end

		task.wait(#loots == 0 and 1 or 0.5)
	end

	lootBtn.Text = "💰 Auto Loot"
end

lootBtn.MouseButton1Click:Connect(function()
	if autoLooting then
		autoLooting = false
	else
		task.spawn(autoLootLoop)
	end
end)
