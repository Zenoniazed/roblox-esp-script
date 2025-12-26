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
-- SERVICES + CORE
--====================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local VIM               = game:GetService("VirtualInputManager")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local char   = player.Character or player.CharacterAdded:Wait()
local hrp    = char:WaitForChild("HumanoidRootPart")

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHRP()
    local c = GetChar()
    return c:WaitForChild("HumanoidRootPart")
end

local function GetBackpack()
    return player:WaitForChild("Backpack")
end

--====================================================
-- ANTI AFK
--====================================================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while true do
        task.wait(300)
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

--====================================================
-- STATE + CONFIG
--====================================================
local state = {
    AutoMob          = false,
    AutoRock         = false,
    AutoSell         = false,
    IgnoreGoblin     = false,
    AutoBuyPotion    = false,
    AutoUsePotion    = false,
    MOVE_MOB         = 60,
    MOVE_ROCK        = 60,
    SELL_DELAY       = 0.5,
    USE_DELAY        = 300,
    BUY_DELAY        = 300,
    SelectedMobs     = {},
    SelectedRocks    = {},
    SelectedOres     = {},
    SelectedBuyPotion = {},
    SelectedUsePotion = {},
    SellList          = {},
    SelectedRarity    = {},
    SellRarity        = {},
    SelectedRunes     = {},
    MineAreas         = {},
    PriorityRocks     = {},
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
        if ok and type(data) == "table" then
            for k,v in pairs(data) do
                state[k] = v
            end
        end
    end
end

load()

-- bảo vệ nil
state.SelectedMobs       = state.SelectedMobs       or {}
state.SelectedRocks      = state.SelectedRocks      or {}
state.SelectedOres       = state.SelectedOres       or {}
state.SellList           = state.SellList           or {}
state.SelectedRarity     = state.SelectedRarity     or {}
state.SellRarity         = state.SellRarity         or {}
state.SelectedRunes      = state.SelectedRunes      or {}
state.MineAreas          = state.MineAreas          or {}
state.PriorityRocks      = state.PriorityRocks      or {}
state.SelectedBuyPotion  = state.SelectedBuyPotion  or {}
state.SelectedUsePotion  = state.SelectedUsePotion  or {}
state.IgnoreGoblin       = state.IgnoreGoblin       or false
state.AutoBuyPotion      = state.AutoBuyPotion      or false
state.AutoUsePotion      = state.AutoUsePotion      or false

-- biến runtime
local AutoMob         = state.AutoMob
local AutoRock        = state.AutoRock
local AutoSell        = state.AutoSell
local MOVE_MOB        = state.MOVE_MOB
local MOVE_ROCK       = state.MOVE_ROCK
local SELL_DELAY      = state.SELL_DELAY
local USE_DELAY       = state.USE_DELAY
local BUY_DELAY       = state.BUY_DELAY
local IgnoreGoblin    = state.IgnoreGoblin
local SelectedMobs    = state.SelectedMobs
local SelectedRocks   = state.SelectedRocks
local SelectedOres    = state.SelectedOres
local SelectedRarity  = state.SelectedRarity
local SellRarity      = state.SellRarity
local SelectedRunes   = state.SelectedRunes
local MineAreas       = state.MineAreas
local PriorityRocks   = state.PriorityRocks
local AutoBuyPotion   = state.AutoBuyPotion
local AutoUsePotion   = state.AutoUsePotion
local SelectedBuyPotion = state.SelectedBuyPotion
local SelectedUsePotion = state.SelectedUsePotion


--====================================================
-- KNIT SERVICES / RF
--====================================================
local Shared   = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Knit     = require(Packages.Knit)

local ProximityService = Shared.Packages.Knit.Services.ProximityService
local DialogueService  = Shared.Packages.Knit.Services.DialogueService
local ToolService      = Shared.Packages.Knit.Services.ToolService

local DialogueRF       = ProximityService.RF.Dialogue
local PurchaseRF       = ProximityService.RF.Purchase
local RunCommandRF     = DialogueService.RF.RunCommand
local ToolActivatedRF  = ToolService.RF.ToolActivated

--====================================================
-- NOCLIP
--====================================================
local NoClipON = false

local function setNoClip(v)
    NoClipON = v
end


RunService.RenderStepped:Connect(function()
    if NoClipON then
        local c = GetChar()
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end)


--====================================================
-- TOOL SWING (remote-only)
--====================================================
local function SwingRemote(toolName)
    pcall(function()
        ToolActivatedRF:InvokeServer(toolName)
    end)
end

--====================================================
-- MODULE 1 — AUTO MOB (BodyVelocity)
--====================================================
local Living = workspace:WaitForChild("Living")

local BV_MOB       = nil
local currentMob   = nil
local OFFSET_Y     = 8
local STOP_DIST_M  = 1.5
local AutoMobAttack = true

local MOB_LIST = {
    "Slime", "Blazing Slime", "Delver Zombie", "Skeleton Rogue", "Axe Skeleton", "Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Deathaxe Skeleton", "Bomber", "Reaper", "Blight Pyromancer", "Common Orc", "Crystal Spider", "Diamond Spider", "Prismarine Spider", "Yeti", "Demonic Queen Spider", "Demonic Spider", "Mini Demonic Spider", "Crystal Golem", "Crystal_Golem", "Golem", "Elite Orc", "Zombie3", "EliteZombie", "MinerZombie", "Zombie", "Brute Zombie",
}

local function ensureBV_Mob()
    if not BV_MOB then
        BV_MOB = Instance.new("BodyVelocity")
        BV_MOB.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        BV_MOB.P = 1e4
        BV_MOB.Velocity = Vector3.zero
        BV_MOB.Parent = hrp
    elseif BV_MOB.Parent ~= hrp then
        BV_MOB.Parent = hrp
    end
end

local function clearBV_Mob()
    if BV_MOB then
        BV_MOB:Destroy()
        BV_MOB = nil
    end
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
    local root = GetHRP()
    for _, mob in ipairs(Living:GetChildren()) do
        if isMobAlive(mob) and mob:FindFirstChild("HumanoidRootPart") and mobAllowed(mob.Name) then
            local d = (mob.HumanoidRootPart.Position - root.Position).Magnitude
            if d < minDist then
                nearest = mob
                minDist = d
            end
        end
    end
    return nearest
end

-- MOB MOVEMENT LOOP
RunService.Heartbeat:Connect(function()
    if not AutoMob then
        if BV_MOB then BV_MOB.Velocity = Vector3.new(0,0,0) end
        return
    end

    -- -- đảm bảo không chạy song song với Rock
    -- if AutoRock then
    --     if BV_MOB then BV_MOB.Velocity = Vector3.new(0,0,0) end
    --     return
    -- end

    ensureBV_Mob()
    local root = GetHRP()

    if not currentMob or not isMobAlive(currentMob) then
        currentMob = getNearestMob()
        if not currentMob then
            BV_MOB.Velocity = Vector3.new(0,0,0)
            return
        end
    end

    local hr = currentMob:FindFirstChild("HumanoidRootPart")
    if not hr then
        currentMob = nil
        BV_MOB.Velocity = Vector3.new(0,0,0)
        return
    end

    -- quay mặt nhìn mob
    root.CFrame = CFrame.new(root.Position, hr.Position)

    local targetPos = hr.Position + Vector3.new(0, OFFSET_Y, 0)
    local diff      = targetPos - root.Position
    local dist      = diff.Magnitude

    if dist > STOP_DIST_M then
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

        AutoMob = v
        state.AutoMob = v
        save()

        if v then
            -- TẮT ROCK HOÀN TOÀN
            AutoRock = false
            state.AutoRock = false
            clearBV_Rock()
            currentRock = nil

            -- BẬT NOCIP
            setNoClip(true)

            -- KHỞI TẠO BV MOB
            ensureBV_Mob()
            currentMob = nil

        else
            clearBV_Mob()
            currentMob = nil
        end
    end
})


TabMain:Dropdown({
    Title = "Select Mobs",
    Multi = true,
    List  = MOB_LIST,
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
-- MODULE 2 — AUTO ROCK MINING (BodyVelocity)
--====================================================
local ROCK_TYPES = {
    "Basalt",
    "Basalt Core",
    "Basalt Rock",
    "Basalt Vein",
    "Boulder",
    "Crimson Crystal",
    "Cyan Crystal",
    "Earth Crystal",
    "Lava Rock",
    "Light Crystal",
    "Lucky Block",
    "Pebble",
    "Rock",
    "Violet Crystal",
    "Volcanic Rock"
}

local ORE_TYPES = {
    "Volcanic Rock","Uranium","Topaz","Titanium",
	"Tin","Stone","Starite","Slimite","Silver",
	"Sapphire","Sand Stone","Ruby","Rivalite",
	"Rainbow Crystal","Quartz","Poopite","Platinum","Orange Crystal",
	"Obsidian","Mythril","Mushroomite","Meteorite","Magmaite",
	"Magenta Crystal","Lightite","Lapis Lazuli","Jade","Iron","Iceite",
	"Green Crystal","Grass","Gold","Galaxite","Fireite","Fichillium",
	"Fichilliumorite","Eye Ore","Emerald","Diamond","Demonite","Darkryte","Dark Boneite","Cuprite",
	"Crimson Crystal","Copper","Cobalt","Cardboardite","Boneite","Blue Crystal","Bananite","Arcane Crystal",
	"Amethyst","Aite","Aether Lotus","Aetherit","Aqujade","Ceyite","Crimsonite","Cryptex","Etherealite",
	"Frost Fossil","Galestor","Gargantuan","Graphite","Heavenite","Larimar","Lgarite","Malachite","Marblite",
	"Mistvein","Moltenfrost","Neurotite","Pumice","Sanctis","Scheelite","Sulfur","Suryafal","Tide Carve","Tungsten",
	"Vanegos","Velchire","Voidfractal","Voidstar","Vooite","Zephyte","Snowite","Mosasaursit","Coinite"
}

local RUNE_TYPES = {
    "Drain Edge",
    "Blast Chip",
    "Rage Mark",
    "Briar Notch",
    "Flame Spark",
    "Miner Shard",
	"Venom Crumb",
	"Frost Speck",
}

-- Rarity pools
local COMMON_RARITY = {
    "Stone","Sand Stone","Copper","Iron","Cardboardite"
}
local UNCOMMON_RARITY = {
    "Tin","Silver","Gold","Bananite","Cobalt","Titanium","Lapis Lazuli"
}
local RARE_RARITY = {
    "Mushroomite","Platinum","Volcanic Rock","Quartz",
    "Amethyst","Topaz","Diamond","Sapphire"
}
local EPIC_RARITY = {
    "Aite","Poopite","Cuprite","Obsidian","Emerald","Ruby","Rivalite",
    "Orange Crystal Ore","Green Crystal Ore","Blue Crystal Ore",
    "Magenta Crystal Ore","Arcane Crystal Ore","Crimson Crystal Ore"
}
local LEGENDARY_RARITY = {
    "Fichillum","Uranium","Mythril","Eye Ore","Fireite",
    "Magmaite","Lightite","Rainbow Crystal Ore"
}
local MYTHICAL_RARITY = {
    "Demonite","Darkryte"
}

local ORE_RARITY = {}
local function registerGroup(list, rarity)
    for _, ore in ipairs(list) do
        ORE_RARITY[ore] = rarity
    end
end

registerGroup(COMMON_RARITY,    "Common")
registerGroup(UNCOMMON_RARITY,  "Uncommon")
registerGroup(RARE_RARITY,      "Rare")
registerGroup(EPIC_RARITY,      "Epic")
registerGroup(LEGENDARY_RARITY, "Legendary")
registerGroup(MYTHICAL_RARITY,  "Mythical")

-- BodyVelocity cho rock
local BV_ROCK      = nil
local currentRock  = nil
local MINEOFFSET_Y = -3
local STOP_DIST_R  = 1.5
local rockBlacklist  = {}
local BLACKLIST_TIME = 5
local AutoDig        = true

local function ensureBV_Rock()
    if not BV_ROCK then
        BV_ROCK = Instance.new("BodyVelocity")
        BV_ROCK.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_ROCK.P = 1e4
        BV_ROCK.Velocity = Vector3.zero
        BV_ROCK.Parent = hrp
    elseif BV_ROCK.Parent ~= hrp then
        BV_ROCK.Parent = hrp
    end
end

local function clearBV_Rock()
    if BV_ROCK then
        BV_ROCK:Destroy()
        BV_ROCK = nil
    end
end

-- Goblin region
local Regions     = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Regions")
local GoblinPart  = Regions and Regions:FindFirstChild("Goblin Cave")
local GoblinExists = GoblinPart ~= nil

local gCF, gSize, half = CFrame.new(), Vector3.new(0,0,0), Vector3.new(0,0,0)
if GoblinExists then
    gCF  = GoblinPart.CFrame
    gSize = GoblinPart.Size
    half  = gSize / 2
end

local SAFE_OVER_HEIGHT = 40

local function insideGoblinXZ(pos)
    if not GoblinExists then return false end
    local lp = gCF:PointToObjectSpace(pos)
    return math.abs(lp.X) <= half.X and math.abs(lp.Z) <= half.Z
end

local function avoidGoblin()
    if not IgnoreGoblin then return false end
    if not GoblinExists then return false end

    local root = GetHRP()
    local pos  = root.Position

    if insideGoblinXZ(pos) then
        local safeY = gCF.Position.Y + SAFE_OVER_HEIGHT
        if pos.Y < safeY - 2 then
            local target = Vector3.new(pos.X, safeY, pos.Z)
            local diff   = target - pos
            BV_ROCK.Velocity = diff.Unit * MOVE_ROCK
            return true
        end
    end
    return false
end

local function rockInSelectedAreas(folderName)
    if #MineAreas == 0 then
        return true
    end
    for _, area in ipairs(MineAreas) do
        if area == "VolcanicDepths" and folderName == "Island2VolcanicDepths" then
            return true
        end
        if area == "GoblinCave" and folderName == "Island2GoblinCave" then
            return true
        end
        if area == "Cave" then
            if folderName ~= "Island2VolcanicDepths" and folderName ~= "Island2GoblinCave" then
                return true
            end
        end
    end
    return false
end

local function getAllRocks()
    local list = {}
    local RocksRoot = workspace:FindFirstChild("Rocks")
    if not RocksRoot then return list end

    for _, folder in ipairs(RocksRoot:GetChildren()) do
        if not rockInSelectedAreas(folder.Name) then
            continue
        end
        if IgnoreGoblin and folder.Name == "Island2GoblinCave" then
            continue
        end

        for _, spawn in ipairs(folder:GetChildren()) do
            for _, obj in ipairs(spawn:GetChildren()) do
                if obj:IsA("Model")
                    and obj:FindFirstChild("Hitbox")
                    and table.find(SelectedRocks, obj.Name) then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

local function getNearestRock()
    local allRocks = getAllRocks()
    if #allRocks == 0 then
        return nil
    end

    local priorityList, normalList = {}, {}

    for _, rock in ipairs(allRocks) do
        if rockBlacklist[rock] and tick() - rockBlacklist[rock] < BLACKLIST_TIME then
            continue
        end

        if table.find(PriorityRocks, rock.Name) then
            table.insert(priorityList, rock)
        else
            table.insert(normalList, rock)
        end
    end

    local function pickNearest(list)
        local root = GetHRP()
        local nearest, minDist = nil, math.huge
        for _, rock in ipairs(list) do
            local hit = rock:FindFirstChild("Hitbox")
            if hit then
                local d = (hit.Position - root.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = rock
                end
            end
        end
        return nearest
    end

    if #priorityList > 0 then
        local n = pickNearest(priorityList)
        if n then return n end
    end

    return pickNearest(normalList)
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

local lastErrorTick  = 0
local ERROR_COOLDOWN = 0.25

workspace.Debris.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") and obj.Name == "Error Notification" then
        obj:GetPropertyChangedSignal("Playing"):Connect(function()
            if obj.Playing then
                lastErrorTick = tick()
            end
        end)
    end
end)

local function getRockHP(rock)
    if not rock then return nil end
    local info = rock:FindFirstChild("infoFrame"); if not info then return nil end
    local frame = info:FindFirstChild("Frame");    if not frame then return nil end
    local hpLabel = frame:FindFirstChild("rockHP"); if not hpLabel then return nil end
    local num = hpLabel.Text:match("%d+")
    return tonumber(num)
end

local function oreHasSelectedRarity(ore)
    local r = ORE_RARITY[ore]
    if not r then return false end
    return table.find(SelectedRarity, r) ~= nil
end

-- ROCK MOVEMENT LOOP
RunService.Heartbeat:Connect(function()
    if not AutoRock then
        if BV_ROCK then BV_ROCK.Velocity = Vector3.zero end
        return
    end

    -- -- đảm bảo không chạy song song với Mob
    -- if AutoMob then
    --     if BV_ROCK then BV_ROCK.Velocity = Vector3.zero end
    --     return
    -- end

    ensureBV_Rock()
    local root = GetHRP()

    -- né Goblin
    if avoidGoblin() then
        return
    end

    SelectedOres   = SelectedOres   or {}
    SelectedRarity = SelectedRarity or {}
    local useOreFilter    = next(SelectedOres)   ~= nil
    local useRarityFilter = next(SelectedRarity) ~= nil

    if tick() - lastErrorTick < ERROR_COOLDOWN then
        if currentRock then
            rockBlacklist[currentRock] = tick()
            currentRock = nil
        end
        BV_ROCK.Velocity = Vector3.zero
        return
    end

    if not currentRock then
        currentRock = getNearestRock()
        if not currentRock then
            BV_ROCK.Velocity = Vector3.zero
            return
        end
    end

    local hit = currentRock:FindFirstChild("Hitbox")
    if not hit then
        rockBlacklist[currentRock] = tick()
        currentRock = nil
        BV_ROCK.Velocity = Vector3.zero
        return
    end

    local hp = getRockHP(currentRock)
    if hp and hp <= 0 then
        rockBlacklist[currentRock] = tick()
        currentRock = nil
        BV_ROCK.Velocity = Vector3.zero
        return
    end

    local ores = detectOreInRock(currentRock)

    if useOreFilter or useRarityFilter then
        if #ores > 0 then
            local ok = false
            for _, ore in ipairs(ores) do
                if useOreFilter and table.find(SelectedOres, ore) then
                    ok = true; break
                end
                if useRarityFilter and oreHasSelectedRarity(ore) then
                    ok = true; break
                end
            end

            if not ok then
                rockBlacklist[currentRock] = tick()
                currentRock = nil
                BV_ROCK.Velocity = Vector3.zero
                return
            end
        end
    end

    local target = hit.Position + Vector3.new(0, MINEOFFSET_Y, 0)
    local diff   = target - root.Position
    local dist   = diff.Magnitude

    if dist > STOP_DIST_R then
        BV_ROCK.Velocity = diff.Unit * MOVE_ROCK
    else
        BV_ROCK.Velocity = Vector3.zero
    end
end)

--====================================================
-- AUTO REMOTE SWING LOOP (giữ nguyên nhưng gọn)
--====================================================
local function SwingWeapon()
    SwingRemote("Weapon")
end

local function SwingPickaxe()
    SwingRemote("Pickaxe")
end

task.spawn(function()
    while task.wait(0.05) do
        if AutoMob and currentMob then
            SwingWeapon()
        end
        if AutoRock and currentRock then
            SwingPickaxe()
        end
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

        AutoRock = v
        state.AutoRock = v
        save()

        if v then
            -- TẮT MOB HOÀN TOÀN
            AutoMob = false
            state.AutoMob = false
            clearBV_Mob()
            currentMob = nil

            -- BẬT NOCIP
            setNoClip(true)

            -- KHỞI TẠO BV ROCK
            ensureBV_Rock()
            currentRock = nil

        else
            clearBV_Rock()
            currentRock = nil
        end
    end
})



TabMining:Dropdown({
    Title = "Select Rock Types",
    List  = ROCK_TYPES,
    Multi = true,
    Value = state.SelectedRocks,
    Callback = function(list)
        state.SelectedRocks = list
        SelectedRocks = list
        save()
    end
})

TabMining:Dropdown({
    Title = "Priority Rocks",
    Multi = true,
    List  = ROCK_TYPES,
    Value = state.PriorityRocks,
    Callback = function(list)
        state.PriorityRocks = list
        PriorityRocks = list
        save()
        currentRock = nil
    end
})

TabMining:Dropdown({
    Title = "Select Ore Types",
    List  = ORE_TYPES,
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
    List  = RARITY_LIST,
    Value = SelectedRarity,
    Callback = function(list)
        SelectedRarity = list
        state.SelectedRarity = list
        save()
    end
})

TabMining:Dropdown({
    Title = "Select Mine Areas",
    Multi = true,
    List  = { "VolcanicDepths", "GoblinCave", "Cave" },
    Value = state.MineAreas,
    Callback = function(list)
        state.MineAreas = list
        MineAreas = list
        save()
        currentRock = nil
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
-- RESPAWN HANDLER
--====================================================
player.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")

    clearBV_Mob()
    currentMob = nil
    if AutoMob then ensureBV_Mob() end

    clearBV_Rock()
    currentRock = nil
    if AutoRock then ensureBV_Rock() end
end)

--====================================================
-- MODULE 3 — AUTO SELL (BodyVelocity + ưu tiên lần đầu)
--====================================================
local BV_SELL        = nil
local SELL_OFFSET_Y  = 2
local SELL_STOP_DIST = 2
local DialogueOpened = false
local SellNPC        = workspace:WaitForChild("Proximity"):WaitForChild("Greedy Cey")

local function ensureBV_Sell()
    if not BV_SELL then
        BV_SELL = Instance.new("BodyVelocity")
        BV_SELL.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_SELL.P = 1e4
        BV_SELL.Velocity = Vector3.zero
        BV_SELL.Parent = hrp
    elseif BV_SELL.Parent ~= hrp then
        BV_SELL.Parent = hrp
    end
end

local function clearBV_Sell()
    if BV_SELL then
        BV_SELL:Destroy()
        BV_SELL = nil
    end
end

local function OpenDialogue()
    if DialogueOpened then return true end
    local ok,_ = pcall(function()
        return DialogueRF:InvokeServer(SellNPC)
    end)
    if ok then
        DialogueOpened = true
        return true
    end
    return false
end

local SELL_RARITY = {
    "Common","Uncommon","Rare","Epic","Legendary","Mythical"
}

local function oreMatchesSellRarity(ore)
    local r = ORE_RARITY[ore]
    if not r then return false end
    return table.find(state.SellRarity, r) ~= nil
end

local function GetRunesToSell()
    local runes = {}
    local menu = player.PlayerGui:FindFirstChild("Menu")
    if not menu then return runes end

    local stash = menu.Frame and menu.Frame.Frame and menu.Frame.Frame.Menus
        and menu.Frame.Frame.Menus.Stash
        and menu.Frame.Frame.Menus.Stash.Background

    if not stash then return runes end

    for _, guiItem in ipairs(stash:GetChildren()) do
        if guiItem:IsA("Frame") and guiItem:FindFirstChild("Main") then
            local itemName = guiItem.Main:FindFirstChild("ItemName")
            if itemName then
                local runeType = itemName.Text
                if table.find(SelectedRunes, runeType) then
                    runes[guiItem.Name] = 1
                end
            end
        end
    end
    return runes
end

local function SellOresNow()
    if not OpenDialogue() then return end

    local basket = {}

    for _, ore in ipairs(state.SellList) do
        basket[ore] = 1
    end

    for oreName,_ in pairs(ORE_RARITY) do
        if oreMatchesSellRarity(oreName) then
            basket[oreName] = 1
        end
    end

    local runeList = GetRunesToSell()
    for guid,_ in pairs(runeList) do
        basket[guid] = 1
    end

    if next(basket) == nil then return end

    pcall(function()
        RunCommandRF:InvokeServer("SellConfirm", { Basket = basket })
    end)
end

local function moveToNPC()
    ensureBV_Sell()
    local root = GetHRP()

    local npcPart = SellNPC:FindFirstChild("HumanoidRootPart")
        or SellNPC:FindFirstChild("Hitbox")
        or SellNPC.PrimaryPart

    if not npcPart then
        BV_SELL.Velocity = Vector3.zero
        return true
    end

    local target = npcPart.Position + Vector3.new(0, SELL_OFFSET_Y, 0)
    local diff   = target - root.Position
    local dist   = diff.Magnitude

    if dist > SELL_STOP_DIST then
        BV_SELL.Velocity = diff.Unit * 50
        return false
    else
        BV_SELL.Velocity = Vector3.zero
        return true
    end
end

-- lưu trạng thái farm trước khi bay lần đầu đi sell
local SellInitRunning = false
local SellPrevMob, SellPrevRock

task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoSell then
            -- Lần đầu: bay tới NPC, pause farm, mở thoại
            if not DialogueOpened then
                if not SellInitRunning then
                    SellInitRunning = true
                    SellPrevMob, SellPrevRock = AutoMob, AutoRock
                    AutoMob, AutoRock = false, false
                    clearBV_Mob()
                    clearBV_Rock()
                end

                local arrived = moveToNPC()
                if arrived then
                    SellOresNow() -- sẽ gọi OpenDialogue() bên trong
                    clearBV_Sell()
					task.wait(3)

                    -- resume farm như trước
                    AutoMob  = SellPrevMob  or false
                    AutoRock = SellPrevRock or false
                    SellPrevMob, SellPrevRock = nil, nil
                    SellInitRunning = false
                end
            else
                -- Đã có thoại → bán từ xa, không đụng BV
                SellOresNow()
                task.wait(SELL_DELAY)
            end
        else
            if BV_SELL then BV_SELL.Velocity = Vector3.zero end
            -- nếu đang bay dở mà tắt AutoSell → khôi phục farm
            if SellInitRunning then
                AutoMob  = SellPrevMob  or false
                AutoRock = SellPrevRock or false
                SellPrevMob, SellPrevRock = nil, nil
                SellInitRunning = false
                clearBV_Sell()
            end
        end
    end
end)

--====================================================
-- SELL UI
--====================================================
local TabSell = Window:Tab({ Title = "Sell", Icon = "dollar" })

TabSell:Toggle({
    Title = "Enable Auto Sell",
    Value = state.AutoSell,
    Callback = function(v)
        state.AutoSell = v
        AutoSell = v
        save()
        if not v then
            clearBV_Sell()
            setNoClip(false)
            DialogueOpened = false
        else
            setNoClip(true)
        end
    end
})

TabSell:Dropdown({
    Title = "Select Ores To Sell",
    Multi = true,
    List  = ORE_TYPES,
    Value = state.SellList,
    Callback = function(list)
        state.SellList = list
        save()
    end
})

TabSell:Dropdown({
    Title = "Sell by Rarity",
    Multi = true,
    List  = SELL_RARITY,
    Value = state.SellRarity,
    Callback = function(list)
        state.SellRarity = list
        save()
    end
})

TabSell:Dropdown({
    Title = "Select Runes To Sell",
    Multi = true,
    List  = RUNE_TYPES,
    Value = state.SelectedRunes,
    Callback = function(list)
        state.SelectedRunes = list
        SelectedRunes = list
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

--====================================================
-- MODULE 4 — AUTO BUY / AUTO USE POTION
--====================================================
local LIST_POTION_TYPE = {
    "DamagePotion1",
    "HealthPotion1",
    "HealthPotion2",
    "LuckPotion1",
    "MinerPotion1",
    "SpeedPotion1"
}

-- BV cho buy potion
local BV_BUY = nil
local BUY_OFFSET_Y = 2
local BUY_STOP_DIST = 2

local MariaNPC = nil
pcall(function()
    MariaNPC = workspace:WaitForChild("Proximity"):WaitForChild("Maria")
end)

local function ensureBV_Buy()
    if not BV_BUY then
        BV_BUY = Instance.new("BodyVelocity")
        BV_BUY.MaxForce = Vector3.new(1e6,1e6,1e6)
        BV_BUY.P = 1e4
        BV_BUY.Velocity = Vector3.zero
        BV_BUY.Parent = hrp
    elseif BV_BUY.Parent ~= hrp then
        BV_BUY.Parent = hrp
    end
end

local function clearBV_Buy()
    if BV_BUY then
        BV_BUY:Destroy()
        BV_BUY = nil
    end
end

local function BuyPotion()
    if type(SelectedBuyPotion) ~= "table" then return end
    for _, potion in ipairs(SelectedBuyPotion) do
        pcall(function()
            PurchaseRF:InvokeServer(potion, 1)
        end)
    end
end

local function UsePotion()
    if type(SelectedUsePotion) ~= "table" then return end
    for _, potion in ipairs(SelectedUsePotion) do
        pcall(function()
            ToolActivatedRF:InvokeServer(potion)
        end)
    end
end

-- Auto Buy Potion: khi tới thời gian → tạm dừng farm, bay tới Maria, mua, rồi resume
task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoBuyPotion and #SelectedBuyPotion > 0 and MariaNPC then
            -- lưu trạng thái farm
            local prevMob, prevRock = AutoMob, AutoRock
            AutoMob, AutoRock = false, false
            clearBV_Mob()
            clearBV_Rock()

            ensureBV_Buy()

            -- bay tới Maria
            while AutoBuyPotion do
                local root = GetHRP()
                local npcPart = MariaNPC:FindFirstChild("HumanoidRootPart") or MariaNPC.PrimaryPart
                if not npcPart then break end

                local target = npcPart.Position + Vector3.new(0, BUY_OFFSET_Y, 0)
                local diff   = target - root.Position
                local dist   = diff.Magnitude

                if dist > BUY_STOP_DIST then
                    BV_BUY.Velocity = diff.Unit * 50
                else
                    BV_BUY.Velocity = Vector3.zero
                    break
                end

                task.wait(0.05)
            end

            -- mua
            if AutoBuyPotion then
                BuyPotion()
            end

            clearBV_Buy()

			task.wait(2)
            -- resume farm
            AutoMob  = prevMob
            AutoRock = prevRock

            -- chờ delay mua
            task.wait(BUY_DELAY)
        end
    end
end)

-- Auto Use Potion (dùng remote từ xa)
task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoUsePotion and #SelectedUsePotion > 0 then
            UsePotion()
            task.wait(USE_DELAY)
        end
    end
end)

local TabPotion = Window:Tab({ Title = "Potion", Icon = "flask" })

TabPotion:Dropdown({
    Title = "Select Potion To BUY",
    List  = LIST_POTION_TYPE,
    Multi = true,
    Value = SelectedBuyPotion,
    Callback = function(list)
        SelectedBuyPotion = list
        state.SelectedBuyPotion = list
        save()
    end
})

TabPotion:Toggle({
    Title = "Auto Buy",
    Value = AutoBuyPotion,
    Callback = function(v)
        AutoBuyPotion = v
        state.AutoBuyPotion = v
        save()
    end
})

TabPotion:Textbox({
    Title = "Buy Delay (sec)",
    Placeholder = tostring(BUY_DELAY),
    Value = "",
    Callback = function(txt)
        local v = tonumber(txt)
        if v then
            if v < 0 then v = 0 end
            if v > 9999 then v = 9999 end
            BUY_DELAY = v
            state.BUY_DELAY = v
            save()
        end
    end
})

TabPotion:Dropdown({
    Title = "Select Potion To USE",
    List  = LIST_POTION_TYPE,
    Multi = true,
    Value = SelectedUsePotion,
    Callback = function(list)
        SelectedUsePotion = list
        state.SelectedUsePotion = list
        save()
    end
})

TabPotion:Toggle({
    Title = "Auto Use",
    Value = AutoUsePotion,
    Callback = function(v)
        AutoUsePotion = v
        state.AutoUsePotion = v
        save()
    end
})

TabPotion:Textbox({
    Title = "Use Delay (sec)",
    Placeholder = tostring(USE_DELAY),
    Value = "",
    Callback = function(txt)
        local v = tonumber(txt)
        if v then
            if v < 0 then v = 0 end
            if v > 9999 then v = 9999 end
            USE_DELAY = v
            state.USE_DELAY = v
            save()
        end
    end
})

print("🔥 AUTO FARM + ROCK + SELL + POTION (BodyVelocity + Mutex Mob/Rock + Sell/Buy logic) LOADED ✔")
