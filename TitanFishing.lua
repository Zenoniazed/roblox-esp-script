task.wait(3)

--================ SERVICES ================
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

--================ ANTI AFK ================
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--================ UI PATH ================
local playerGui = player:WaitForChild("PlayerGui")
local fishStats = playerGui:WaitForChild("FishStats")
local healthFrame = fishStats:WaitForChild("HealthFrame")
local distanceFrame = fishStats:WaitForChild("DistanceFrame")
local fishNameLabel = healthFrame:WaitForChild("FishName")
local chargeMain = playerGui:WaitForChild("Charge"):WaitForChild("Main")
local luckBar = chargeMain:WaitForChild("CanvasGroup"):WaitForChild("Bar")
local buttonClose = player.PlayerGui:WaitForChild("SellGUI").Canvas.Main.Close
local buttonAll = player.PlayerGui:WaitForChild("SellGUI").Canvas.Main.All

local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events
local castPressRemote = eventsFolder:GetChildren()[9]  -- Index 9: Nhấn
local castReleaseRemote = eventsFolder:GetChildren()[22] -- Index 20: Thả


-- Thông báo đầy rương
local notificationFrame = playerGui:WaitForChild("Notification"):WaitForChild("Frame")
local gachaUI = player.PlayerGui:WaitForChild("GachaUI")

--================ STATE ================
local state = {
    AutoFish = false,
    LuckThreshold = 0.95,
    SpamDelay = 0.04,
    WaitNext = 3,
    SelectedRarity = {"Rare","Epic","Legendary","Mythic","Divine"},
    isSelling = false, 
    isMoving = false,
	AutoGacha = false,
    GachaDelay = 1,
    RodSettings = {
		["Titanium Steel Rod"] = {},
		["Steel Rod"] = {},
		["Bamboo Rod"] = {},
		["Golden Rod"] = {},
		["Stone Rod"] = {},
		["Gold Plated Rod"] = {},
		["Rusty Iron Rod"] = {},
		["Upgraded Wooden Rod"] = {},
        ["Wooden Rod"] = {},
    }
}

local ALL_RARITIES = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine"}
local SKILL_OPTIONS = {"Skill 1", "Skill 2", "Skill 3", "Skill 4"}
local MY_RODS = {"Titanium Steel Rod","Steel Rod","Bamboo Rod","Golden Rod","Stone Rod","Gold Plated Rod","Rusty Iron Rod","Upgraded Wooden Rod","Wooden Rod"}

local dangSpam = false
local fishHooked = false
local lastCastTime = 0

--================ LOGIC NHẢY (JUMP LOGIC) ================
task.spawn(function()
    while true do
        if state.isMoving then
            local s = humanoid:GetState()
            if s ~= Enum.HumanoidStateType.Jumping and s ~= Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        task.wait(0.5)
    end
end)

local function getButtonCenter(guiObject)
    local pos = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    local centerX = pos.X + (size.X / 2)
    local centerY = pos.Y + (size.Y / 2) + 36 
    
    return centerX, centerY
end

-- Định nghĩa hàm click gọn ở đầu script
local function clickGui(guiObject)
    if not guiObject then return end
    local x, y = getButtonCenter(guiObject)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

--================ DI CHUYỂN THÔNG MINH ================
local function smartMoveTo(targetPos)
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    path:ComputeAsync(hrp.Position, targetPos)
    if path.Status ~= Enum.PathStatus.Success then return end

    state.isMoving = true
    for _, waypoint in ipairs(path:GetWaypoints()) do
        if not state.AutoFish then break end -- Dừng nếu tắt Auto
        humanoid:MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid.MoveToFinished:Wait()
    end
    state.isMoving = false
end

--================ TÌM NPC BÁN CÁ ================
local function getNearestFishSeller()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    local nearest, shortest = nil, math.huge
    for _, npc in pairs(npcFolder:GetChildren()) do
        if npc.Name == "bluewaterrobux" then
            local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = part
                end
            end
        end
    end
    return nearest
end


--================ ĐI BÁN VÀ QUAY LẠI ================
local function sellAndReturn()
    if state.isSelling or not state.AutoFish then return end
    state.isSelling = true
    dangSpam = false
    local oldPos = hrp.Position
    local npc = getNearestFishSeller()
    
    if npc then
        smartMoveTo(npc.Position + Vector3.new(3, 0, 3))
        task.wait(2) -- Đợi bán
		local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            -- Kích hoạt nhấn E
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
        end
		task.wait(0.3)
		clickGui(buttonAll)
		task.wait(0.3)
		clickGui(buttonClose)
		task.wait(0.5)

        smartMoveTo(oldPos)
        
        -- Tự trang bị lại cần câu (Tool)
        local tool = player.Backpack:FindFirstChildWhichIsA("Tool") or player.Character:FindFirstChildWhichIsA("Tool")
        if tool and tool.Parent ~= player.Character then
            humanoid:EquipTool(tool)
        end
    end
    
    state.isSelling = false
    task.wait(1)
    castRod()
end

--================ CHECK FISH HOOKED ================
local function isFishHooked()
    return healthFrame.Visible and distanceFrame.Visible
end

--================ CHECK TARGET FISH ================
local function isTargetFish()
    local name = fishNameLabel.Text
    for _, r in ipairs(state.SelectedRarity) do
        if string.find(name, r) then return true end
    end
    return false
end

local function castRod()
    if state.isSelling or not state.AutoFish then return end
    
    fishHooked = false
    lastCastTime = tick()
    eventsFolder:GetChildren()[9]:FireServer()
    
    local startGong = tick()
    repeat 
        task.wait(0.1) 
    until luckBar.Size.Y.Scale >= state.LuckThreshold or (tick() - startGong) > 3

    eventsFolder:GetChildren()[22]:FireServer()
end

--================ SPAM SKILLS ================
local function startSpamming()
    if dangSpam then return end
    dangSpam = true
    task.spawn(function()
        local skillRemote = eventsFolder:GetChildren()[4]
        
        while dangSpam and state.AutoFish and not state.isSelling do
            if not isFishHooked() then break end

            for rodName, selectedSkills in pairs(state.RodSettings) do
                -- selectedSkills là bảng dạng {"Skill 1", "Skill 3"}
                for _, skillText in ipairs(selectedSkills) do
                    if not isFishHooked() or state.isSelling then break end
                    
                    -- Lấy con số từ chuỗi "Skill 1" -> 1, "Skill 2" -> 2
                    local skillID = tonumber(string.match(skillText, "%d+"))
                    if skillID then
                        skillRemote:FireServer(rodName, skillID)
                    end
                end
            end
            task.wait(state.SpamDelay)
        end
        dangSpam = false
    end)
end

--================ EVENTS ================
healthFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not state.AutoFish or state.isSelling then return end

    if healthFrame.Visible then
        fishHooked = true
        if isTargetFish() then
            startSpamming()
        end
    else
        dangSpam = false
        task.wait(state.WaitNext)
        if state.AutoFish and not state.isSelling then
            castRod()
        end
        task.wait(0.5)

    end
end)

-- Theo dõi rương đầy
notificationFrame.ChildAdded:Connect(function(child)
    task.wait(0.2)
    local label = child:IsA("TextLabel") and child or child:FindFirstChildOfClass("TextLabel")
    if label and string.find(label.Text, "Full") then
        sellAndReturn()
    end
end)


-- 10s Check
task.spawn(function()
    while true do
        task.wait(1)
        if state.AutoFish then
            if not fishHooked then

                if tick() - lastCastTime > 10 then

                    castRod()
                end

            end
        end
    end
end)

local function startAutoGacha()
    task.spawn(function()
        local gachaRemote = eventsFolder:GetChildren()[3]
        
        while state.AutoGacha do
		 
            gachaRemote:FireServer() 

			gachaUI.Enabled = false
            -- Tắt cả cái khung Background bên trong (nếu có)
            if gachaUI:FindFirstChild("Background") then
                gachaUI.Background.Visible = false
            end
            
            task.wait(state.GachaDelay)
        end
    end)
end

--================ LOAD UI LIBRARY & WINDOW (Giữ nguyên phần UI của bạn) ================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/Framework.lua"))()
local Window = Library:Window({
    Title  = "Botanist Fishing + Auto Sell",
    Desc   = "Auto Farm & Jump",
    Theme  = "Amethyst",
    Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0,520,0,380) },
    CloseUIButton = { Enabled = true, Text = "CLOSE" }
})

local Tab = Window:Tab({ Title = "Fishing", Icon = "fish" })

Tab:Toggle({
    Title = "Auto Fishing",
    Value = false,
    Callback = function(v)
        state.AutoFish = v
        if v then
            task.wait(1)
            castRod()
        else
            dangSpam = false
            state.isMoving = false
        end
    end
})

Tab:Dropdown({
    Title = "Fish Rarity",
    Multi = true,
    List = ALL_RARITIES,
    Value = state.SelectedRarity,
    Callback = function(list) state.SelectedRarity = list end
})


Tab:Slider({
    Title = "Spam Delay (ms)",
    Min = 20, Max = 300,
    Value = state.SpamDelay * 1000,
    Callback = function(v) state.SpamDelay = v / 1000 end
})

local SkillTab = Window:Tab({ Title = "Multi-Rod Skills", Icon = "sword" })

SkillTab:Section({ Title = "Select Rod Skills " })

for _, rodName in ipairs(MY_RODS) do
    SkillTab:Dropdown({
        Title = rodName,
        List = SKILL_OPTIONS,
        Multi = true,
        Value = state.RodSettings[rodName],
        Callback = function(opts)

            state.RodSettings[rodName] = opts 
        end
    })
end

local GachaTab = Window:Tab({ Title = "Gacha", Icon = "star" })

GachaTab:Section({ Title = "Gacha Settings" })

GachaTab:Toggle({
    Title = "Auto Gacha",
    Value = false,
    Callback = function(v)
        state.AutoGacha = v
        if v then
            startAutoGacha()
        end
    end
})

GachaTab:Slider({
    Title = "Gacha Delay (s)",
    Min = 0.5, 
    Max = 10,
    Value = state.GachaDelay,
    Callback = function(v)
        state.GachaDelay = v
    end
})
