--====================================================
-- LOAD UI FRAMEWORK
--====================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/Framework.lua"))()

local Window = Library:Window({
    Title  = "⚒ Hover System",
    Desc   = "Mob Farm + Rock Mining + NoClip",
    Theme  = "Amethyst",
    Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 520, 0, 380) },
    CloseUIButton = { Enabled = true, Text = "CLOSE" }
})

--====================================================
-- SERVICES + CHARACTER
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local VirtualUser = game:GetService("VirtualUser")

-- Bắt sự kiện Idled
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Vòng lặp định kỳ (5 phút)
task.spawn(function()
    while true do
        task.wait(300) -- chỉnh số giây nếu muốn nhanh/chậm hơn
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

local state = {
    AutoMob     = false,
    AutoRock    = false,
    AutoSell    = false,
	IgnoreGoblin = false,

    MOVE_MOB    = 60,
    MOVE_ROCK   = 60,
    SELL_DELAY  = 0.5,

    SelectedMobs  = {},
    SelectedRocks = {},
    SelectedOres  = {},
    SellList      = {},
	SelectedRarity  = {},
	SellRarity = {}

}

local CONFIG = "hover_config.json"

local function save()
    if writefile then
        writefile(CONFIG, HttpService:JSONEncode(state))
        print("💾 Config Saved!")
    end
end

local function load()
    if isfile and isfile(CONFIG) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG))
        end)
        if ok and type(data)=="table" then
            for k,v in pairs(data) do state[k] = v end
        end
    end
end

load()

AutoMob      = state.AutoMob
AutoRock     = state.AutoRock
AutoSell     = state.AutoSell

MOVE_MOB     = state.MOVE_MOB
MOVE_ROCK    = state.MOVE_ROCK
SELL_DELAY   = state.SELL_DELAY

--Bảo vệ giữ liệu json
state.SelectedMobs   = state.SelectedMobs   or {}
state.SelectedRocks  = state.SelectedRocks  or {}
state.SelectedOres   = state.SelectedOres   or {}
state.SellList       = state.SellList       or {}
state.SelectedRarity = state.SelectedRarity or {}
state.IgnoreGoblin = state.IgnoreGoblin or false
state.SellRarity = state.SellRarity or {}


SelectedMobs     = state.SelectedMobs
SelectedRocks    = state.SelectedRocks
SelectedOres     = state.SelectedOres
SelectedRarity   = state.SelectedRarity
sellList         = state.SellList
IgnoreGoblin = state.IgnoreGoblin
SellRarity = state.SellRarity



-- Dialogue activation
local ProximityService = ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService
local DialogueRF = ProximityService.RF.Dialogue

-- SellConfirm
local DialogueService = ReplicatedStorage.Shared.Packages.Knit.Services.DialogueService
local RunCommandRF = DialogueService.RF.RunCommand
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetBackpack()
    return player:WaitForChild("Backpack")
end

--====================================================
-- NOCLIP
--====================================================
local NoClipON = false

local function setNoClip(state)
    NoClipON = state
    if not state then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end



RunService.Heartbeat:Connect(function()
    if NoClipON then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

--====================================================
-- TOOL EQUIP
--====================================================
local function EquipTool(toolName)
    local char = GetChar()
    local backpack = GetBackpack()

    local tool = backpack:FindFirstChild(toolName)
    if not tool then return false end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then item.Parent = backpack task.wait(0.02) end
    end

    tool.Parent = char
    task.wait(0.1)
    return true
end

------------------------------------------------------
-- REMOTE SWING (Thay cho swingTool)
------------------------------------------------------

local ToolService = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Packages"):WaitForChild("Knit")
    :WaitForChild("Services"):WaitForChild("ToolService")

local ToolActivatedRF = ToolService:WaitForChild("RF"):WaitForChild("ToolActivated")

local function SwingRemote(toolName)
    pcall(function()
        ToolActivatedRF:InvokeServer(toolName)
    end)
end

--====================================================
-- MODULE 1 — AUTO MOB
--====================================================
local Living = workspace:WaitForChild("Living")

-- AUTO MOB
local BV_MOB = nil
local currentMob = nil
local OFFSET_Y = 8
local STOP_DIST = 1.5
local AutoMobAttack = true

-- AUTO ROCK
local BV_ROCK = nil
local currentRock = nil
local MINEOFFSET_Y = -5
local rockBlacklist = {}
local BLACKLIST_TIME = 5
local AutoDig = true

-- AUTO SELL
local BV_SELL = nil
local SELL_OFFSET_Y = 2
local SELL_STOP_DIST = 2
local DialogueOpened = false




local MOB_LIST = {
    "Skeleton Rogue",
    "Axe Skeleton",
    "Deathaxe Skeleton",
	"Bomber",
    "Elite Deathaxe Skeleton",
    "Elite Rogue Skeleton",
    "Reaper",
    "Blazing Slime",
    "Slime",
}

local function ensureBV_Mob()
    if not BV_MOB then
        BV_MOB = Instance.new("BodyVelocity")
        BV_MOB.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_MOB.P = 1e4
        BV_MOB.Parent = hrp
    end
end

local function clearBV_Mob()
    if BV_MOB then BV_MOB:Destroy() BV_MOB = nil end
end

local function isMobAlive(m)
    if not m or not m.Parent then return false end
    if m:GetAttribute("IsNpc") ~= true then return false end
    local status = m:FindFirstChild("Status")
    if status and (status:FindFirstChild("dead") or status:FindFirstChild("Dead")) then
        return false
    end
    return true
end

local function mobAllowed(name)
    local base = name:gsub("%d+",""):gsub("%s+$","")
    if next(SelectedMobs) == nil then return true end
    return table.find(SelectedMobs, base) ~= nil
end

local function getNearestMob()
    local nearest, minDist = nil, math.huge
    for _, mob in ipairs(Living:GetChildren()) do
        if isMobAlive(mob)
            and mob:FindFirstChild("HumanoidRootPart")
            and mobAllowed(mob.Name) then

            local d = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < minDist then
                nearest = mob
                minDist = d
            end
        end
    end
    return nearest
end

local function autoEquipWeapon()
    local char = GetChar()
    if not char:FindFirstChild("Weapon") then
        EquipTool("Weapon")
    end
    return "Weapon"
end

------------------------------------------------------
-- MOB MOVEMENT LOOP
------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not AutoMob then
        if BV_MOB then BV_MOB.Velocity = Vector3.new(0,0,0) end
        return
    end

    ensureBV_Mob()

    if not currentMob or not isMobAlive(currentMob) then
        currentMob = getNearestMob()
        if not currentMob then
            BV_MOB.Velocity = Vector3.new(0,0,0)
            return
        end
    end

    local hr = currentMob:FindFirstChild("HumanoidRootPart")
    if not hr then currentMob = nil return end

    hrp.CFrame = CFrame.new(hrp.Position, hr.Position)

    local targetPos = hr.Position + Vector3.new(0, OFFSET_Y, 0)
    local diff = targetPos - hrp.Position
    local dist = diff.Magnitude

    if dist > STOP_DIST then
        BV_MOB.Velocity = diff.Unit * MOVE_MOB
    else
        BV_MOB.Velocity = Vector3.new(0,0,0)
    end
end)

--====================================================
-- UI MOB
--====================================================
local TabMain = Window:Tab({ Title = "Main", Icon = "sword" })

TabMain:Section({ Title = "⚔ Auto Farm Mob" })

TabMain:Toggle({
    Title = "Enable Auto Farm",
    Value = state.AutoMob,
    Callback = function(v)
        state.AutoMob = v
        AutoMob = v
        save()
        if v then
            ensureBV_Mob()
            setNoClip(true)
        else
            clearBV_Mob()
			setNoClip(false)
        end
    end
})

TabMain:Dropdown({
    Title = "Select Mobs",
    Multi = true,
    List = MOB_LIST,
    Value = state.SelectedMobs,
    Callback = function(list)
        state.SelectedMobs = list
        SelectedMobs = list
        save()
    end
})


TabMain:Slider({
    Title = "Mob Fly Speed",
    Min = 20, Max = 200,
    Value = state.MOVE_MOB,
    Callback = function(v)
        state.MOVE_MOB = v
        MOVE_MOB = v
        save()
    end
})


--====================================================
-- AUTO ROCK MINING
--====================================================


local ROCK_TYPES = {
    "Basalt","Basalt Core","Basalt Rock","Basalt Vein",
    "Earth Crystal","Cyan Crystal","Violet Crystal",
    "Lava Rock","Volcanic Rock",
}


local ORE_TYPES = {
    "Volcanic Rock","Uranium","Topaz","Titanium","Tin","Stone",
    "Starite","Slimite","Silver","Sapphire","Sand Stone","Ruby",
    "Rivalite","Rainbow Crystal","Quartz","Poopite","Platinum",
    "Orange Crystal","Obsidian","Mythril","Mushroomite","Meteorite",
    "Magmaite","Magenta Crystal","Lightite","Lapis Lazuli","Jade",
    "Iron","Iceite","Green Crystal","Grass","Gold","Galaxite",
    "Fireite","Fichillum","Fichillumorite","Eye Ore","Emerald",
    "Diamond","Demonite","Darkryte","Dark Boneite","Cuprite",
    "Crimson Crystal","Copper","Cobalt","Cardboardite","Boneite",
    "Blue Crystal","Bananite","Arcane Crystal","Amethyst","Aite"
}

-- COMMON
local COMMON_RARITY = {
    "Stone","Sand Stone","Copper","Iron","Cardboardite"
}

-- UNCOMMON
local UNCOMMON_RARITY = {
    "Tin","Silver","Gold","Bananite","Cobalt","Titanium","Lapis Lazuli"
}

-- RARE
local RARE_RARITY = {
    "Mushroomite","Platinum","Volcanic Rock","Quartz",
    "Amethyst","Topaz","Diamond","Sapphire"
}

-- EPIC
local EPIC_RARITY = {
    "Aite","Poopite","Cuprite","Obsidian","Emerald","Ruby","Rivalite",
    "Orange Crystal Ore","Green Crystal Ore","Blue Crystal Ore",
    "Magenta Crystal Ore","Arcane Crystal Ore","Crimson Crystal Ore"
}

-- LEGENDARY
local LEGENDARY_RARITY = {
    "Fichillum","Uranium","Mythril","Eye Ore","Fireite",
    "Magmaite","Lightite","Rainbow Crystal Ore"
}

-- MYTHICAL
local MYTHICAL_RARITY = {
    "Demonite","Darkryte"
}

local ORE_RARITY = {}

local function registerGroup(list, rarity)
    for _, ore in ipairs(list) do
        ORE_RARITY[ore] = rarity
    end
end

registerGroup(COMMON_RARITY, "Common")
registerGroup(UNCOMMON_RARITY, "Uncommon")
registerGroup(RARE_RARITY, "Rare")
registerGroup(EPIC_RARITY, "Epic")
registerGroup(LEGENDARY_RARITY, "Legendary")
registerGroup(MYTHICAL_RARITY, "Mythical")


local function ensureBV_Rock()
    if not BV_ROCK then
        BV_ROCK = Instance.new("BodyVelocity")
        BV_ROCK.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_ROCK.P = 1e4
        BV_ROCK.Parent = hrp
    end
end



local function clearBV_Rock()
    if BV_ROCK then BV_ROCK:Destroy() BV_ROCK = nil end
end

--====================================================
-- GOBLIN CAVE REGION (FLOOR LIMIT)
--====================================================

local Regions = workspace:WaitForChild("Debris"):WaitForChild("Regions")
local GoblinPart = Regions:WaitForChild("Goblin Cave")

local gCF = GoblinPart.CFrame
local gSize = GoblinPart.Size
local half = gSize / 2

-- Độ cao an toàn muốn bay phía trên Goblin Cave
local SAFE_OVER_HEIGHT = 40

local function insideGoblinXZ(pos)
    local lp = gCF:PointToObjectSpace(pos)
    return math.abs(lp.X) <= half.X and math.abs(lp.Z) <= half.Z
end

local function avoidGoblin()
    if not IgnoreGoblin then 
        return false 
    end

    local pos = hrp.Position
    ensureBV_Rock()

    -- kiểm tra XZ trong vùng Goblin
    if insideGoblinXZ(pos) then
        local safeY = gCF.Position.Y + SAFE_OVER_HEIGHT

        -- ★ Nếu đã cao hơn mức an toàn → không spam nữa
        if pos.Y >= safeY - 2 then
            -- đã OUT vùng nguy hiểm theo chiều Y
            return false
        end

        -- ★ Nếu còn thấp → bay lên
        local target = Vector3.new(pos.X, safeY, pos.Z)
        BV_ROCK.Velocity = (target - pos).Unit * MOVE_ROCK
        return true
    end

    return false
end




local function getAllRocks()
    local list = {}

    for _, folder in ipairs(workspace.Rocks:GetChildren()) do
        for _, spawn in ipairs(folder:GetChildren()) do
		if IgnoreGoblin and folder.Name == "Island2GoblinCave" then
            -- print("Skip Goblin Cave folder")
            continue
        end
            for _, obj in ipairs(spawn:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Hitbox") then
                    if table.find(SelectedRocks, obj.Name) then
                        table.insert(list, obj)
                    end
                end
            end
        end
    end
    return list
end

local function getNearestRock()
    local minDist = math.huge
    local nearest = nil

    for _, rock in ipairs(getAllRocks()) do

        if rockBlacklist[rock] and tick() - rockBlacklist[rock] < BLACKLIST_TIME then
            continue
        end

        local hit = rock:FindFirstChild("Hitbox")
        if hit then
            local d = (hit.Position - hrp.Position).Magnitude
            if d < minDist then
                minDist = d
                nearest = rock
            end
        end
    end

    return nearest
end

local function detectOreInRock(rock)
    local ores = {}
    for _, child in ipairs(rock:GetChildren()) do
        local ore = child:GetAttribute("Ore")
        if ore then
            table.insert(ores, ore)
        end
    end
    return ores
end



local function autoEquipPickaxe()
    local char = GetChar()
    if not char:FindFirstChild("Pickaxe") then
        EquipTool("Pickaxe")
    end
    return "Pickaxe"
end


local lastErrorTick = 0
local ERROR_COOLDOWN = 0.25

workspace.Debris.DescendantAdded:Connect(function(obj)
	if obj:IsA("Sound") and obj.Name == "Error Notification" then
		
		obj:GetPropertyChangedSignal("Playing"):Connect(function()
			if obj.Playing then
				lastErrorTick = tick()
				-- print("❗ SERVER BLOCKED DIG → Error Notification Sound!")
			end
		end)
	end
end)

local function getRockHP(rock)
    if not rock then return nil end

    local info = rock:FindFirstChild("infoFrame")
    if not info then return nil end

    local frame = info:FindFirstChild("Frame")
    if not frame then return nil end

    local hpLabel = frame:FindFirstChild("rockHP")
    if not hpLabel then return nil end

    -- Lấy số trong chuỗi '80 HP' hoặc '0 HP'
    local num = hpLabel.Text:match("%d+")
    local hp = tonumber(num)

    return hp
end


local function oreHasSelectedRarity(ore)
    local r = ORE_RARITY[ore]
    if not r then return false end
    return table.find(SelectedRarity, r) ~= nil
end



--====================================================
-- ROCK MOVEMENT LOOP
--====================================================
RunService.Heartbeat:Connect(function()

    ------------------------------------------------------------------
    -- AUTO OFF
    ------------------------------------------------------------------
    if not AutoRock then
        if BV_ROCK then BV_ROCK.Velocity = Vector3.zero end
        return
    end

    ensureBV_Rock()

	 ----------------------------------------------------
    -- ⭐ AVOID GOBLIN CAVE REGION ⭐
    ----------------------------------------------------
    if avoidGoblin() then
        return -- stop xử lý các bước đào nếu đang né vùng
    end

    ------------------------------------------------------------------
    -- FIX: đảm bảo không biến nào là nil
    ------------------------------------------------------------------
    SelectedOres = SelectedOres or {}
    SelectedRarity = SelectedRarity or {}

    local useOreFilter    = next(SelectedOres) ~= nil
    local useRarityFilter = next(SelectedRarity) ~= nil


    ------------------------------------------------------------------
    -- SERVER ERROR COOLDOWN (Error Notification)
    ------------------------------------------------------------------
    if tick() - lastErrorTick < ERROR_COOLDOWN then
        if currentRock then
            rockBlacklist[currentRock] = tick()
            currentRock = nil
            BV_ROCK.Velocity = Vector3.zero
        end
        return
    end


    ------------------------------------------------------------------
    -- FIND NEW ROCK
    ------------------------------------------------------------------
    if not currentRock then
        currentRock = getNearestRock()

        if not currentRock then
            BV_ROCK.Velocity = Vector3.zero
            return
        end
    end


    ------------------------------------------------------------------
    -- CHECK HITBOX
    ------------------------------------------------------------------
    local hit = currentRock:FindFirstChild("Hitbox")
    if not hit then
        rockBlacklist[currentRock] = tick()
        currentRock = nil
        BV_ROCK.Velocity = Vector3.zero
        return
    end


    ------------------------------------------------------------------
    -- CHECK HP
    ------------------------------------------------------------------
    local hp = getRockHP(currentRock)

    if hp and hp <= 0 then
        rockBlacklist[currentRock] = tick()
        currentRock = nil
        BV_ROCK.Velocity = Vector3.zero
        return
    end


    ------------------------------------------------------------------
    -- DETECT ORE(S)
    ------------------------------------------------------------------
    local ores = detectOreInRock(currentRock)
    -- print("💎 Ores:", (#ores > 0 and table.concat(ores, ", ")) or "(none)")


    ------------------------------------------------------------------
    -- FILTER
    ------------------------------------------------------------------
    if useOreFilter or useRarityFilter then

        if #ores == 0 then
            -- print("⏳ Ore not spawned yet.")
        else
            local ok = false

            for _, ore in ipairs(ores) do
                
                -- Filter by Ore Name
                if useOreFilter and table.find(SelectedOres, ore) then
                    ok = true
                    break
                end

                -- Filter by Rarity
                if useRarityFilter and oreHasSelectedRarity(ore) then
                    ok = true
                    break
                end
            end

            if not ok then
                rockBlacklist[currentRock] = tick()
                currentRock = nil
                BV_ROCK.Velocity = Vector3.zero
                return
            end
        end
    else
    end


    ------------------------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------------------------
    local target = hit.Position + Vector3.new(0, MINEOFFSET_Y, 0)
    local diff = target - hrp.Position
    local dist = diff.Magnitude

    if dist > STOP_DIST then
        BV_ROCK.Velocity = diff.Unit * MOVE_ROCK
    else
        BV_ROCK.Velocity = Vector3.zero
    end
end)



--====================================================
-- MINING UI
--====================================================
local TabMining = Window:Tab({ Title = "Mining", Icon = "pickaxe" })

TabMining:Section({ Title = "⛏ Auto Rock Mining" })

TabMining:Toggle({
    Title = "Enable Auto Rock",
    Value = state.AutoRock,
    Callback = function(v)
        state.AutoRock = v
        AutoRock = v
        save()
        if v then
            ensureBV_Rock()
            setNoClip(true)
            currentRock = nil
        else
            clearBV_Rock()
			setNoClip(false)
        end
    end
})

TabMining:Dropdown({
    Title = "Select Rock Types",
    List = ROCK_TYPES,
    Multi = true,
    Value = state.SelectedRocks,
    Callback = function(list)
        state.SelectedRocks = list
        SelectedRocks = list
        save()
    end
})



------------------------------------------------------
-- ⭐ ORE FILTER UI (đã thêm useFilter)
------------------------------------------------------
TabMining:Dropdown({
    Title = "Select Ore Types",
    List = ORE_TYPES,
    Multi = true,
    Value = state.SelectedOres,
    Callback = function(list)
        state.SelectedOres = list
        SelectedOres = list
        save()
    end
})

local RARITY_LIST = {
    "Common","Uncommon","Rare","Epic","Legendary","Mythical"
}

TabMining:Dropdown({
    Title = "Select Ore Rarity",
    Multi = true,
    List = RARITY_LIST,
    Value = SelectedRarity,
    Callback = function(list)
        SelectedRarity = list
        state.SelectedRarity = list
        save()
    end
})

TabMining:Toggle({
    Title = "Ignore Goblin Cave",
    Value = state.IgnoreGoblin,
    Callback = function(v)
        state.IgnoreGoblin = v
        IgnoreGoblin = v
        save()
        currentRock = nil
    end
})


TabMining:Slider({
    Title = "Rock Fly Speed",
    Min = 20, Max = 200,
    Value = state.MOVE_ROCK,
    Callback = function(v)
        state.MOVE_ROCK = v
        MOVE_ROCK = v
        save()
    end
})


--====================================================
-- AUTO REMOTE SWING TIMER (0.5s)
--====================================================
local nextMobSwingTime = 0
local nextRockSwingTime = 0

local function RemoteSwingDelay(toolName, active, nextTime)
    local t = tick()
    if active and t >= nextTime then
        SwingRemote(toolName)
        return t + 0.05
    end
    return nextTime
end

task.spawn(function()
    while true do
        task.wait(0.05)

        if AutoMob and AutoMobAttack and currentMob then
            local tool = autoEquipWeapon()
            nextMobSwingTime = RemoteSwingDelay(tool, true, nextMobSwingTime)
        end

        if AutoRock and AutoDig and currentRock then
            local tool = autoEquipPickaxe()
            nextRockSwingTime = RemoteSwingDelay(tool, true, nextRockSwingTime)
        end
    end
end)

--====================================================
-- RESPAWN HANDLER
--====================================================
player.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
	clearBV_Mob()
    currentMob = nil
    if AutoMob then ensureBV_Mob() end

    -- RESET MINING
    clearBV_Rock()
    currentRock = nil
    if AutoRock then ensureBV_Rock() end	
end)

--====================================================
-- MODULE 3 — AUTO SELL (FIXED + OPTIMIZED)
--====================================================

local SellNPC = workspace:WaitForChild("Proximity"):WaitForChild("Greedy Cey")

local function ensureBV_Sell()
    if not BV_SELL then
        BV_SELL = Instance.new("BodyVelocity")
        BV_SELL.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_SELL.P = 1e4
        BV_SELL.Velocity = Vector3.zero
        BV_SELL.Parent = hrp
    end
end
----------------------------------------------------
-- BODYVELOCITY
----------------------------------------------------


local function clearBV_Sell()
    if BV_SELL then
        BV_SELL:Destroy()
        BV_SELL = nil
    end
end


----------------------------------------------------
-- MOVE TO NPC
----------------------------------------------------
local function moveToNPC()
    ensureBV_Sell()

    local npcPart = SellNPC:FindFirstChild("HumanoidRootPart")
        or SellNPC:FindFirstChild("Hitbox")
        or SellNPC.PrimaryPart

    if not npcPart then return false end

    local target = npcPart.Position + Vector3.new(0, SELL_OFFSET_Y, 0)
    local diff = target - hrp.Position
    local dist = diff.Magnitude

    if dist > SELL_STOP_DIST then
        BV_SELL.Velocity = diff.Unit * 50
        return false
    else
        BV_SELL.Velocity = Vector3.zero
        return true
    end
end


----------------------------------------------------
-- OPEN DIALOG (ONLY ONCE)
----------------------------------------------------
local function OpenDialogue()
    if DialogueOpened then return true end  -- đã mở rồi

    local ok, result = pcall(function()
        return DialogueRF:InvokeServer(SellNPC)
    end)

	DialogueOpened = true

end

local SELL_RARITY = {
    "Common","Uncommon","Rare","Epic","Legendary","Mythical"
}

local function oreMatchesSellRarity(ore)
    local r = ORE_RARITY[ore]
    if not r then return false end
    return table.find(state.SellRarity, r) ~= nil
end
----------------------------------------------------
-- SELL FUNCTION
----------------------------------------------------
-- local function SellOresNow()
--     if not OpenDialogue() then return end

--     local basket = {}
--     for _, ore in ipairs(state.SellList) do
--         basket[ore] = 1
--     end

--     if next(basket) == nil then return end

--     pcall(function()
--         RunCommandRF:InvokeServer("SellConfirm", { Basket = basket })
--     end)
-- end

local function SellOresNow()
    if not OpenDialogue() then return end

    local basket = {}

    for _, ore in ipairs(state.SellList) do
        basket[ore] = 1
    end

    for oreName, rarity in pairs(ORE_RARITY) do
        if oreMatchesSellRarity(oreName) then
            basket[oreName] = 1
        end
    end
    if next(basket) == nil then return end

    pcall(function()
        RunCommandRF:InvokeServer("SellConfirm", { Basket = basket })
    end)
end



----------------------------------------------------
-- LOOP AUTO SELL
----------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)

        if AutoSell then

            if not DialogueOpened then
                local arrived = moveToNPC()

                if arrived then
                    clearBV_Sell()     -- 👉 tới NPC rồi thì tắt bay
                    SellOresNow()
                    task.wait(SELL_DELAY)
                end

            else
                -- Đã mở Dialogue → không bay nữa
                SellOresNow()
                task.wait(SELL_DELAY)
            end

        else
            clearBV_Sell()
        end
    end
end)




----------------------------------------------------
-- GUI
----------------------------------------------------
local TabSell = Window:Tab({ Title = "Sell", Icon = "dollar" })

TabSell:Toggle({
    Title = "Enable Auto Sell",
    Value =  state.AutoSell,
    Callback = function(v)
       state.AutoSell = v
        AutoSell = v
        save()

        if v then
            ensureBV_Sell()
			setNoClip(true)
        else
            clearBV_Sell()
			setNoClip(false)
        end
    end
})

TabSell:Dropdown({
    Title = "Select Ores To Sell",
    Multi = true,
    List = ORE_TYPES,
    Value = state.SellList,
    Callback = function(list)
        state.SellList = list
        -- sellList = list
        save()
    end
})

TabSell:Dropdown({
    Title = "Sell by Rarity",
    Multi = true,
    List = SELL_RARITY,
    Value = state.SellRarity,
    Callback = function(list)
        state.SellRarity = list
        save()
    end
})

TabSell:Slider({
    Title = "Sell Delay",
    Min = 0.1, Max = 2,
    Value = state.SELL_DELAY,
    Callback = function(v)
        state.SELL_DELAY = v
        SELL_DELAY = v
        save()
    end	
})




print("🔥 FULL SCRIPT HOÀN CHỈNH — Remote Swing + Ore Filter Loaded ✔")
