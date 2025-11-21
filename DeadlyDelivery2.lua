--===========================================================
--     DEADLY DELIVERY – FULL ESP + WARNING + RADAR v6
--===========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local MonstersFolder = workspace:WaitForChild("GameSystem"):WaitForChild("Monsters")

------------------------------------------------------------
-- UI CẢNH BÁO
------------------------------------------------------------
local WarningGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
WarningGui.IgnoreGuiInset = true
WarningGui.ResetOnSpawn = false

local Warn = Instance.new("TextLabel", WarningGui)
Warn.Position = UDim2.new(0.41, 0, 0.1, 0)
Warn.Size = UDim2.new(0.18,0,0.045,0)
Warn.BackgroundTransparency = 0.4
Warn.BackgroundColor3 = Color3.fromRGB(180,40,40)
Warn.TextColor3 = Color3.new(1,1,1)
Warn.Font = Enum.Font.GothamBold
Warn.TextScaled = true
Warn.Visible = false
Instance.new("UICorner", Warn).CornerRadius = UDim.new(0, 8)

local function showWarning(text)
	Warn.Text = text
	Warn.Visible = true
	Warn.BackgroundTransparency = 0.4
	Warn.TextTransparency = 0

	task.spawn(function()
		task.wait(0.8)
		for i = 0, 1, 0.05 do
			Warn.BackgroundTransparency = 0.4 + i
			Warn.TextTransparency = i
			task.wait(0.03)
		end
		Warn.Visible = false
	end)
end

------------------------------------------------------------
-- ESP + HIGHLIGHT
------------------------------------------------------------
local ESP_Objects = {}

local function getMonsterPart(monster)
	return monster.PrimaryPart
		or monster:FindFirstChild("HumanoidRootPart")
		or monster:FindFirstChild("Hitbox")
		or monster:FindFirstChildWhichIsA("BasePart")
end

local DISTANCE_OFFSET_Y = 3

local function createESP(monster)
	if ESP_Objects[monster] then return end

	local part = getMonsterPart(monster)
	if not part then return end

	local hl = Instance.new("Highlight")
	hl.FillColor = Color3.fromRGB(255,60,60)
	hl.OutlineColor = Color3.new(1,1,1)
	hl.FillTransparency = 0.6
	hl.Parent = monster

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0,80,0,20)
	bb.AlwaysOnTop = true
	bb.Adornee = part
	bb.StudsOffset = Vector3.new(0, DISTANCE_OFFSET_Y, 0)
	bb.Parent = monster

	local txt = Instance.new("TextLabel", bb)
	txt.BackgroundTransparency = 1
	txt.Size = UDim2.new(1,0,1,0)
	txt.Font = Enum.Font.GothamBold
	txt.TextColor3 = Color3.fromRGB(255,80,80)
	txt.TextScaled = true
	txt.Text = ""

	ESP_Objects[monster] = {
		part = part,
		text = txt,
		highlight = hl
	}
end

local function removeESP(monster)
	if ESP_Objects[monster] then
		local d = ESP_Objects[monster]
		if d.text then d.text.Parent:Destroy() end
		if d.highlight then d.highlight:Destroy() end
		ESP_Objects[monster] = nil
	end
end

for _, m in ipairs(MonstersFolder:GetChildren()) do
	createESP(m)
end
MonstersFolder.ChildAdded:Connect(function(m) task.wait(0.1); createESP(m) end)
MonstersFolder.ChildRemoved:Connect(removeESP)

------------------------------------------------------------
-- RADAR SYSTEM
------------------------------------------------------------
local MAP_SIZE = 150
local SCALE = 1
local MONSTER_DOT_SIZE = 3
local ARROW_SIZE = 3
local ALERT_DISTANCE = 30

local RadarGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
RadarGui.IgnoreGuiInset = true
RadarGui.ResetOnSpawn = false

local RadarFrame = Instance.new("Frame", RadarGui)
RadarFrame.Size = UDim2.new(0, MAP_SIZE, 0, MAP_SIZE)
RadarFrame.Position = UDim2.new(1, -MAP_SIZE - 20, 0.5, -MAP_SIZE/2)
RadarFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
RadarFrame.BackgroundTransparency = 0.45
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1,0)

local Arrow = Instance.new("Frame", RadarFrame)
Arrow.Size = UDim2.new(0, ARROW_SIZE, 0, ARROW_SIZE)
Arrow.AnchorPoint = Vector2.new(0.5,0.5)
Arrow.Position = UDim2.new(0.5,0,0.5,0)
Arrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
Arrow.BorderSizePixel = 0
Arrow.ZIndex = 50
Instance.new("UICorner", Arrow).CornerRadius = UDim.new(0.3, 0)

local MonsterDots = {}

local function createMonsterDotRadar(monster)
	local dot = Instance.new("Frame", RadarFrame)
	dot.Size = UDim2.new(0, MONSTER_DOT_SIZE, 0, MONSTER_DOT_SIZE)
	dot.BackgroundColor3 = Color3.fromRGB(255,60,60)
	dot.AnchorPoint = Vector2.new(0.5,0.5)
	dot.ZIndex = 30
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

	MonsterDots[monster] = dot
end

MonstersFolder.ChildAdded:Connect(function(m)
	task.wait(0.1)
	createESP(m)
	createMonsterDotRadar(m)
end)

MonstersFolder.ChildRemoved:Connect(function(m)
	removeESP(m)
	if MonsterDots[m] then MonsterDots[m]:Destroy() end
	MonsterDots[m] = nil
end)

for _, m in ipairs(MonstersFolder:GetChildren()) do
	createMonsterDotRadar(m)
end

------------------------------------------------------------
-- UPDATE LOOP (ESP + WARNING + RADAR)
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not HRP then return end

	local camCF = Camera.CFrame
	local forward = camCF.LookVector
	local right = camCF.RightVector
	local angle = math.deg(math.atan2(forward.X, forward.Z))

	-- Radar xoay theo camera
	RadarFrame.Rotation = angle
	Arrow.Rotation = angle + 45

	for monster, data in pairs(ESP_Objects) do
		local part = data.part
		if monster.Parent and part then

			-- ========= ESP khoảng cách =========
			local dist = (part.Position - HRP.Position).Magnitude
			data.text.Text = math.floor(dist) .. "m"

			-- ========= Cảnh báo =============
			if dist < ALERT_DISTANCE then
				local dir = (part.Position - HRP.Position).Unit
				local fDot = forward:Dot(dir)
				local rDot = right:Dot(dir)

				if fDot > 0.6 then showWarning("⚠ TRƯỚC")
				elseif fDot < -0.6 then showWarning("⚠ SAU")
				elseif rDot > 0.4 then showWarning("⚠ PHẢI")
				elseif rDot < -0.4 then showWarning("⚠ TRÁI")
				end
			end

			-- ========= RADAR dot =========
			local dot = MonsterDots[monster]
			if dot then
				local offset = part.Position - HRP.Position
				local x = -offset.X * SCALE
				local y = -offset.Z * SCALE

				x = math.clamp(x, -MAP_SIZE/2, MAP_SIZE/2)
				y = math.clamp(y, -MAP_SIZE/2, MAP_SIZE/2)

				dot.Position = UDim2.new(0.5, x, 0.5, y)
			end
		end
	end
end)

print("🔥 FULL ESP + WARNING + RADAR v6 Loaded!")
