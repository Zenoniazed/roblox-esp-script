task.wait(1)
--// SESSION GUARD (Hủy toàn bộ thread ngầm của các lần chạy script trước)
local currentSession = tick()
_G.FishingMasterSession = currentSession

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

--// CONFIG & STATE
local CONFIG = "HeavyWeightFishing_Config.json"
local player = Players.LocalPlayer
local pId = player.UserId
local pGui = player:WaitForChild("PlayerGui")
local mainGui = pGui:WaitForChild("MainGui")

local state = {
    AutoFishing = false,
    AutoSkill = true,
    AutoHealSkill = false,
    HealSkillKey = "Z",
    HealHPThreshold = 40,
    LockBar = true,
    MinigameMode = "Safe", -- "Safe" (An Toàn) hoặc "Fast" (Siêu Tốc)
    AutoRhythm = true,
    AutoBossPhase2 = true,
    AutoSlam = true, -- Auto Slam & Charge
    AutoSell = false,
    SelectedIsland = "Beginning Isle",
    -- Ticket Quest
    AutoTicketQuest = false,
    TicketHardMode = true,
    -- Daily Quest
    AutoDailyQuest = false,
    -- Essence Orb (Zeng Tianguo Quest)
    AutoEssenceOrb = false,
    -- Fish Filter
    FishFilterEnabled = false,
    SelectedFishFilter = {},
    SelectedFishList = {},
    -- Weather Boss Hunter
    AutoWeatherBoss = false,
    SelectedWeatherBoss = "Flame Fish",
    SelectedWeatherBossList = {"Flame Fish"},
    SelectedWeatherBosses = {["Flame Fish"] = true},
    -- Settings (FPS & Graphics)
    HighFPS = false,
    GraphicsLevel = "Tắt",
}

-- Cờ điều khiển nội bộ cho Quest & Boss
local ticketQuestWantsFishing = false
local dailyQuestWantsFishing = false
local essenceOrbWantsFishing = false
local isInteractingNPC = false
local weatherBossActive = false
local weatherBossWantsFishing = false
local weatherBossLastIsland = nil
local currentHuntingBoss = nil
local activeWeatherBossTargets = {}
local setWeatherBossStatus = function(msg) end

-- Bãi Boss mặc định
local DEFAULT_BOSS_ISLAND = "Battlefield Isle"
local CUSTOM_FARM_POS = nil

-- Vị trí câu hiện tại
local currentFishingLocation = {
    Type = "Island",
    Name = "Beginning Isle"
}

-- Bộ nhớ bờ biển đa điểm của các đảo
local ShorelineSpots = {}
local ShorelineIndex = {}

--// SAVE/LOAD LOGIC
local function save()
    if writefile then
        pcall(function()
            writefile(CONFIG, HttpService:JSONEncode(state))
        end)
    end
end

local function load()
    if isfile and isfile(CONFIG) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG))
        end)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                if state[k] ~= nil then state[k] = v end
            end
        end
    end
end

load()

-- Đồng bộ danh sách Boss Thời Tiết (Hỗ trợ cấu hình cũ & đa chọn)
if state.SelectedWeatherBossList and #state.SelectedWeatherBossList > 0 then
    state.SelectedWeatherBosses = {}
    for _, b in ipairs(state.SelectedWeatherBossList) do
        state.SelectedWeatherBosses[b] = true
    end
    state.SelectedWeatherBoss = state.SelectedWeatherBossList[1]
elseif state.SelectedWeatherBoss then
    state.SelectedWeatherBossList = {state.SelectedWeatherBoss}
    state.SelectedWeatherBosses = {[state.SelectedWeatherBoss] = true}
else
    state.SelectedWeatherBossList = {"Flame Fish"}
    state.SelectedWeatherBosses = {["Flame Fish"] = true}
    state.SelectedWeatherBoss = "Flame Fish"
end

--// DATABASE: VÙNG BIỂN & THỜI TIẾT
local IslandFishDatabase = {
    ["Beginning Isle"] = {"Trout", "Arrogant Fish", "Catfish", "Crimson Carp", "Crimson Catfish", "Emerald Carp", "Golden Carp", "Platinum Carp", "Royal Carp", "Tilapia", "Volt Grass Carp", "Azure Carp"},
    ["Bamboo Isle"] = {"Azurefin Grass Carp", "Blackfin Grass Carp", "Crimsonfin Grass Carp", "Dragonhead Tilapia", "Elder Dragonhead Tilapia", "Goldfin Grass Carp", "Horned Silver Carp", "Rosefin Grass Carp", "Sovereign Grass Carp", "Jiaolong Dragonfish"},
    ["Fallout Isle"] = {"Spiked Salmon", "Sunscale Salmon", "Azure Salmon", "Platescale Tilapia", "Runic Horn Grouper", "Ironhorn Flounder", "Chainbound Shark"},
    ["Sovereign Isle"] = {"Dragonstride Carp", "Terratiger Depthfish III", "Terratiger Depthfish II", "Terratiger Depthfish I", "Boundeye Fish", "Baby Jiaolong Dragonfish", "Gold Crucian Carp", "Elder Chainbound Shark", "Adult Jiaolong Dragonfish", "Trueform Jiaolongfish", "Elder Jiaolong Dragonfish"},
    ["Perch Isle"] = {"Elder Perch VIII", "Elder Perch VII", "Elder Perch VI", "Elder Perch V", "Elder Perch IV", "Elder Perch III", "Elder Perch II", "Elder Perch I", "Ascended Perch", "Trueform Perch"},
    ["Frost Isle"] = {"Fleshripper Fish", "Kunfish III", "Kunfish II", "Kunfish I", "Adult Kunfish", "Elder Kunfish", "Primordial Kunfish", "Primordial Kunfish Overlord"},
    ["Coconut Isle"] = {"Armored Battlefish", "Darkness Battlefish", "Phantom Battlefish", "Dragon Battlefish", "Crimson War Carp", "Emerald War Carp", "Warbringer Shark", "Dreadscale Grouper", "Mutated Koi Whale"},
    ["Amber Isle"] = {"Sand Anchovy", "Abyssal Glow Fish", "Lapis Fish", "Grass Tilapia", "Scarlet Fringehead", "Stormscale Tautog", "Darkscale Fish", "Radiant Goldfish", "Serpent Fish", "Dreadmare Eel", "Chromatic Koi", "Toxic Chromatic Koi"},
    ["Battlefield Isle"] = {"Colossal Tigerfish", "Silver Bream Sovereign", "Crimson Bream Sovereign", "Golden Guardian Fish"},
    ["Mistpeak Isle"] = {"Mountain Fish", "Tiger Mirefish", "Octoparasitic Fish"},
    ["World Angler Isle"] = {"Dark Kingfish", "Golden Shark", "Darkness Shark", "Crimson Bonefiend", "Dragonfish Devourer", "White Heaven Kunfish"},
    ["Weather Isle"] = {"Yinfish Sovereign", "Yangfish Sovereign", "Yangfish Empress"},
    ["Mystic Reef Isle"] = {"Apollo Swordfish", "Killer Sawshark", "Demon Bladefish"}
}

local WeatherFishDatabase = {
    ["Flame Fish"] = {Island = "Weather Isle", Weather = "BlazingSun"},
    ["Aquatic Fish"] = {Island = "Weather Isle", Weather = "Rainy"},
    ["Thunder Fish"] = {Island = "Weather Isle", Weather = "Thunderstorm"},
    ["Wind Fish"] = {Island = "Weather Isle", Weather = "Windy"},
    ["Colossal Bull Shark"] = {Island = "Mystic Reef Isle", Weather = "Thunderstorm"},
    ["Crimson Electric Eel"] = {Island = "Bamboo Isle", Weather = "Thunderstorm"},
    ["Dark Lionfish"] = {Island = "Mistpeak Isle", Weather = "Rainy"},
    ["Draconic Koi"] = {Island = "Amber Isle", Weather = "BlazingSun"},
    ["Golden Dragonfish"] = {Island = "Amber Isle", Weather = "BlazingSun"},
    ["Sanguine Fish"] = {Island = "Amber Isle", Weather = "BlazingSun"},
    ["Flying Fish Emperor"] = {Island = "Perch Isle", Weather = "Windy"},
    ["Flying Fish Empress"] = {Island = "Perch Isle", Weather = "Windy"},
    ["Frost Kingfish"] = {Island = "Frost Isle", Weather = "Snowy"},
    ["Reborn Puffer Beast"] = {Island = "Frost Isle", Weather = "Snowy"},
    ["Heavenpiercer Turtle"] = {Island = "Coconut Isle", Weather = "Foggy"},
    ["Mirage Lanternfish"] = {Island = "Mistpeak Isle", Weather = "Foggy"},
    ["Mountain Dragonwhale"] = {Island = "Battlefield Isle", Weather = "Windy"},
}

local WeatherBossList = {}
for fishName, _ in pairs(WeatherFishDatabase) do
    table.insert(WeatherBossList, fishName)
end
table.sort(WeatherBossList)

-- Hàm tìm boss phù hợp với thời tiết hiện tại trong danh sách đa chọn
local function findMatchedWeatherBoss(currentServerWeather, currentIsland)
    local selectedList = state.SelectedWeatherBossList or {}
    if #selectedList == 0 and state.SelectedWeatherBoss then
        selectedList = {state.SelectedWeatherBoss}
    end

    -- 1. Ưu tiên: Nếu đang ở một đảo săn boss và đảo đó vẫn có boss trùng thời tiết hiện tại -> Tiếp tục ở lại câu
    if currentIsland then
        for _, bossName in ipairs(selectedList) do
            local info = WeatherFishDatabase[bossName]
            if info and info.Island == currentIsland then
                if string.find(string.lower(currentServerWeather), string.lower(info.Weather)) ~= nil then
                    return bossName, info
                end
            end
        end
    end

    -- 2. Tìm boss đầu tiên trong danh sách chọn trùng khớp với thời tiết hiện tại của server
    for _, bossName in ipairs(selectedList) do
        local info = WeatherFishDatabase[bossName]
        if info then
            if string.find(string.lower(currentServerWeather), string.lower(info.Weather)) ~= nil then
                return bossName, info
            end
        end
    end

    return nil, nil
end

-- Hàm lấy tất cả các boss hợp lệ trên một hòn đảo theo thời tiết hiện tại
local function getActiveBossTargetsOnIsland(islandName, currentServerWeather)
    local targets = {}
    local selectedList = state.SelectedWeatherBossList or {}
    if #selectedList == 0 and state.SelectedWeatherBoss then
        selectedList = {state.SelectedWeatherBoss}
    end
    for _, bossName in ipairs(selectedList) do
        local info = WeatherFishDatabase[bossName]
        if info and info.Island == islandName then
            if string.find(string.lower(currentServerWeather), string.lower(info.Weather)) ~= nil then
                targets[bossName] = true
            end
        end
    end
    return targets
end

-- Danh sách đảo hiển thị trên Dropdown theo thứ tự chuẩn
local OrderedIslandList = {
    "Beginning Isle",
    "Bamboo Isle",
    "Fallout Isle",
    "Sovereign Isle",
    "Perch Isle",
    "Frost Isle",
    "Coconut Isle",
    "Amber Isle",
    "Battlefield Isle",
    "Mistpeak Isle",
    "World Angler Isle",
    "Weather Isle",
    "Mystic Reef Isle"
}
local IslandList = OrderedIslandList

-- Danh sách toàn bộ cá trong game (không trùng lặp, sắp xếp A-Z)
local AllFishNames = {}
local fishSet = {}
for _, fishArr in pairs(IslandFishDatabase) do
    for _, f in ipairs(fishArr) do
        if not fishSet[f] then
            fishSet[f] = true
            table.insert(AllFishNames, f)
        end
    end
end
for f, _ in pairs(WeatherFishDatabase) do
    if not fishSet[f] then
        fishSet[f] = true
        table.insert(AllFishNames, f)
    end
end
table.sort(AllFishNames)

local setFishFilterStatus = function(msg) end

--// HELPER FUNCTIONS (CHARACTER & INVENTORY)
local function getCharacter()
    return workspace:FindFirstChild(player.Name) or player.Character
end

local function isHoldingRod()
    local char = getCharacter()
    if not char then return false end
    return char:FindFirstChild("Tool") ~= nil
end

local function equipRod()
    if isHoldingRod() then return end
    local events = ReplicatedStorage:WaitForChild("Events")
    local hotbarRemote = events:WaitForChild("ToggleHotbar")
    pcall(function()
        hotbarRemote:InvokeServer("1", nil)
    end)
end

-- Bộ điều khiển quyết định khi nào ĐƯỢC PHÉP câu
local function isFishingAllowed()
    if state.AutoWeatherBoss and weatherBossActive then
        return weatherBossWantsFishing
    end
    if state.AutoEssenceOrb then
        return essenceOrbWantsFishing and not isInteractingNPC
    end
    if state.AutoTicketQuest then
        return ticketQuestWantsFishing and not isInteractingNPC
    end
    if state.AutoDailyQuest then
        return dailyQuestWantsFishing
    end
    return state.AutoFishing == true
end

--// 🌊 MULTI-SHORELINE ENGINE
local function getAllShorelinesForIsland(islandName)
    if ShorelineSpots[islandName] and #ShorelineSpots[islandName] > 0 then
        return ShorelineSpots[islandName]
    end

    local sp = workspace:FindFirstChild("Spawnpoint")
    local spawnPart = sp and sp:FindFirstChild(islandName)
    if not spawnPart then return {} end

    local origin = spawnPart.Position
    local ocean = workspace:FindFirstChild("Ocean")
    local waterLevel = 0

    if ocean then
        for _, w in ipairs(ocean:GetDescendants()) do
            if w:IsA("BasePart") and w.Name == "Water" then
                local wType = w:GetAttribute("WaterType") or (w:FindFirstChild("WaterType") and w.WaterType.Value)
                if wType == islandName or (w.Position - origin).Magnitude < 1200 then
                    waterLevel = w.Position.Y + (w.Size.Y * 0.5)
                    break
                end
            end
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local char = getCharacter()
    if char then
        rayParams.FilterDescendantsInstances = {char}
    end

    local spots = {}

    for angleDeg = 0, 337.5, 22.5 do
        local rad = math.rad(angleDeg)
        local dir = Vector3.new(math.cos(rad), 0, math.sin(rad))
        local lastLandPos = nil

        for dist = 15, 350, 10 do
            local samplePos = origin + dir * dist + Vector3.new(0, 30, 0)
            local hit = workspace:Raycast(samplePos, Vector3.new(0, -80, 0), rayParams)

            if hit and hit.Position.Y > (waterLevel + 1.2) then
                lastLandPos = hit.Position
            else
                if lastLandPos then
                    local distToSpawn = (lastLandPos - origin).Magnitude
                    if distToSpawn >= 20 then
                        local standPos = lastLandPos + Vector3.new(0, 3.2, 0)
                        local lookTarget = standPos + dir * 30
                        local spotCF = CFrame.lookAt(standPos, Vector3.new(lookTarget.X, standPos.Y, lookTarget.Z))
                        table.insert(spots, spotCF)
                    end
                end
                break
            end
        end
    end

    if #spots == 0 then
        table.insert(spots, spawnPart.CFrame * CFrame.new(0, 5, 25))
    end

    ShorelineSpots[islandName] = spots
    ShorelineIndex[islandName] = 1
    return spots
end

local function teleportToIslandShore(islandName, forceNext)
    local spots = getAllShorelinesForIsland(islandName)
    if #spots == 0 then return false end

    local idx = ShorelineIndex[islandName] or 1
    if forceNext then
        idx = (idx % #spots) + 1
        ShorelineIndex[islandName] = idx
    end

    local targetCFrame = spots[idx]
    local char = getCharacter()
    if targetCFrame and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if forceNext or (hrp.Position - targetCFrame.Position).Magnitude > 25 then
            hrp.CFrame = targetCFrame
            task.wait(0.5)
            return true
        end
        return true
    end
    return false
end

local function teleportToIslandSpawn(islandName)
    local sp = workspace:FindFirstChild("Spawnpoint")
    local spawnPart = sp and sp:FindFirstChild(islandName)
    local char = getCharacter()
    if spawnPart and char and char:FindFirstChild("HumanoidRootPart") then
        local targetCF = spawnPart:IsA("Model") and spawnPart:GetPivot() or spawnPart.CFrame
        char.HumanoidRootPart.CFrame = targetCF + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

local function teleportToPos(targetPos)
    local char = getCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        if (char.HumanoidRootPart.Position - targetPos).Magnitude > 25 then
            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            task.wait(1)
        end
    end
end

local BossAngleOffset = 0
local function relocateBossOrCustomPos(basePos)
    BossAngleOffset = (BossAngleOffset + 45) % 360
    local rad = math.rad(BossAngleOffset)
    local offset = Vector3.new(math.cos(rad) * 20, 0, math.sin(rad) * 20)
    teleportToPos(basePos + offset)
end

local function relocateCurrentFishingSpot()
    if currentFishingLocation.Type == "Boss" then
        if currentFishingLocation.Name then
            teleportToIslandShore(currentFishingLocation.Name, true)
        else
            teleportToIslandShore("Battlefield Isle", true)
        end
    elseif currentFishingLocation.Type == "Default" then
        relocateBossOrCustomPos(currentFishingLocation.Position or CUSTOM_FARM_POS)
    elseif currentFishingLocation.Name then
        teleportToIslandShore(currentFishingLocation.Name, true)
    else
        teleportToIslandShore(state.SelectedIsland or "Beginning Isle", true)
    end
end

-- TỰ ĐỘNG MUA VÀ TRANG BỊ MỒI CHO NHIỆM VỤ USE BAIT
local lastBaitCheck = 0
local function ensureBaitForQuest(qInfo)
    if not qInfo or not qInfo.Text then return end
    local lower = string.lower(qInfo.Text)

    if string.find(lower, "use bait") or string.find(lower, "bait") then
        if tick() - lastBaitCheck < 3 then return end
        lastBaitCheck = tick()

        local ok, data = pcall(function()
            return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
        end)
        if not ok or not data then return end

        local events = ReplicatedStorage:WaitForChild("Events")
        local buyBaitRem = events:FindFirstChild("BuyBait")
        local equipBaitRem = events:FindFirstChild("EquipBait")

        local baitFolder = data:FindFirstChild("Bait")
        local basicBaitObj = baitFolder and baitFolder:FindFirstChild("Basic Bait")
        local owned = (basicBaitObj and basicBaitObj:IsA("NumberValue")) and basicBaitObj.Value or 0

        local needed = math.max(0, (qInfo.Goal or 100) - (qInfo.Progress or 0))
        if needed <= 0 then needed = 25 end

        if owned < 10 and buyBaitRem then
            local toBuy = math.min(needed, 100)
            pcall(function()
                buyBaitRem:FireServer("Basic Bait", toBuy)
            end)
            task.wait(0.5)
        end

        local equippedBaitObj = data:FindFirstChild("EquippedBait")
        local currentEquipped = equippedBaitObj and equippedBaitObj.Value or ""

        if currentEquipped ~= "Basic Bait" and equipBaitRem then
            pcall(function()
                equipBaitRem:InvokeServer("Basic Bait")
            end)
            task.wait(0.3)
        end
    end
end

local function analyzeQuestTarget(questText)
    local lower = string.lower(questText or "")
    local serverWeather = workspace:GetAttribute("Weather") or "Clear"

    if string.find(lower, "boss") then
        for _, isl in ipairs(OrderedIslandList) do
            if string.find(lower, string.lower(isl)) then
                return {
                    TargetType = "Island",
                    Destination = isl,
                    CanFishNow = true
                }
            end
        end
        return {
            TargetType = "Island",
            Destination = "Battlefield Isle",
            CanFishNow = true
        }
    end

    for fishName, info in pairs(WeatherFishDatabase) do
        if string.find(lower, string.lower(fishName)) then
            local weatherMatched = string.find(string.lower(serverWeather), string.lower(info.Weather)) ~= nil
            return {
                TargetType = "WeatherFish",
                Destination = info.Island,
                FishName = fishName,
                RequiredWeather = info.Weather,
                CurrentWeather = serverWeather,
                CanFishNow = weatherMatched
            }
        end
    end

    for islandName, _ in pairs(IslandFishDatabase) do
        if string.find(lower, string.lower(islandName)) then
            return {
                TargetType = "Island",
                Destination = islandName,
                CanFishNow = true
            }
        end
    end

    for islandName, list in pairs(IslandFishDatabase) do
        for _, fishName in ipairs(list) do
            if string.find(lower, string.lower(fishName)) then
                return {
                    TargetType = "IslandFish",
                    Destination = islandName,
                    FishName = fishName,
                    CanFishNow = true
                }
            end
        end
    end

    return {
        TargetType = "Island",
        Destination = state.SelectedIsland or "Beginning Isle",
        CanFishNow = true
    }
end

local function travelToQuestSpot(targetData)
    currentFishingLocation = {
        Type = targetData.TargetType,
        Name = targetData.Destination,
        Position = targetData.Position
    }
    if targetData.TargetType == "Boss" then
        teleportToIslandShore("Battlefield Isle")
    elseif targetData.TargetType == "Default" then
        teleportToPos(CUSTOM_FARM_POS)
    elseif targetData.Destination then
        teleportToIslandShore(targetData.Destination)
    end
end

-- Hàm hỗ trợ click tọa độ ảo VIM
local function doVimClick(guiObject)
    if not guiObject then return end
    pcall(function()
        local pos = guiObject.AbsolutePosition
        local size = guiObject.AbsoluteSize
        local inset = GuiService:GetGuiInset()
        local centerX = pos.X + (size.X / 2)
        local centerY = pos.Y + (size.Y / 2) + inset.Y
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end)
end

local function findMyFish()
    local fishes = workspace:FindFirstChild("Fishes")
    if not fishes then return nil end
    for _, f in ipairs(fishes:GetChildren()) do
        for _, c in ipairs(f:GetChildren()) do
            if string.find(c.Name, tostring(pId)) and string.find(c.Name, "PlayerHealth") then
                return f
            end
        end
    end
    return nil
end

local cachedTicketNPC = nil
local function getTicketNPC()
    if cachedTicketNPC and cachedTicketNPC.Parent then
        return cachedTicketNPC
    end
    local npc = workspace:FindFirstChild("NPC")
    if npc then
        local func = npc:FindFirstChild("Function")
        if func and func:FindFirstChild("Ticket Quest Giver") then
            cachedTicketNPC = func["Ticket Quest Giver"]
            return cachedTicketNPC
        end
    end
    local found = workspace:FindFirstChild("Ticket Quest Giver", true)
    if found then
        cachedTicketNPC = found
        return cachedTicketNPC
    end
    return nil
end

local function getQuestCooldown()
    local ok, data = pcall(function()
        return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
    end)
    if not ok or not data then return 0 end
    local cd = data:FindFirstChild("TicketQuestCooldown")
    if not cd then return 0 end
    local rem = cd.Value - workspace:GetServerTimeNow()
    return math.max(0, math.floor(rem))
end

local function getActiveTicketQuestInfo()
    local ok, data = pcall(function()
        return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
    end)
    if not ok or not data then return nil end
    
    local mainQuestFolder = data:FindFirstChild("Quest") and data.Quest:FindFirstChild("Main")
    if not mainQuestFolder then return nil end
    
    local qName = state.TicketHardMode and "Hard Ticket Quest" or "Easy Ticket Quest"
    local questObj = mainQuestFolder:FindFirstChild(qName)
    if not questObj then return nil end
    
    local progress = 0
    local goal = 0
    local questText = ""
    local isCompleted = false
    local hasFoundInfo = false

    local objFolder = questObj:FindFirstChild("Objective")
    if objFolder and #objFolder:GetChildren() > 0 then
        local allCompleted = true
        local totalProg = 0
        local totalGoal = 0
        local descList = {}

        for _, objChild in ipairs(objFolder:GetChildren()) do
            local rawVal = tostring(objChild.Value or "")
            local parts = string.split(rawVal, ",")
            local desc = parts[1] or rawVal
            local targetVal = tonumber(parts[2]) or 0

            local valChild = questObj:FindFirstChild(objChild.Name)
            local curProg = (valChild and valChild:IsA("NumberValue")) and valChild.Value or 0

            table.insert(descList, desc .. " (" .. curProg .. "/" .. targetVal .. ")")
            totalProg = totalProg + curProg
            totalGoal = totalGoal + targetVal

            if targetVal > 0 and curProg < targetVal then
                allCompleted = false
            end
        end

        if totalGoal > 0 then
            progress = totalProg
            goal = totalGoal
            questText = table.concat(descList, " | ")
            isCompleted = allCompleted
            hasFoundInfo = true
        end
    end

    if not hasFoundInfo or goal == 0 then
        pcall(function()
            local qMenu = pGui.MainGui.Menu.Quest.Menu
            local mainUi = qMenu:FindFirstChild("Main_Quest") or qMenu:FindFirstChild("MainQuest")
            if mainUi and mainUi:FindFirstChild(qName) then
                local card = mainUi[qName]
                local questFrame = card:FindFirstChild("Quest")
                if questFrame then
                    for _, child in ipairs(questFrame:GetChildren()) do
                        if child:IsA("TextLabel") and child.Name ~= "Title" and child.Name ~= "Stats" and child.Visible then
                            local t = child.Text
                            local p, g = t:match("(%d+)/(%d+)")
                            if p and g then
                                progress = tonumber(p) or progress
                                goal = tonumber(g) or goal
                                questText = t
                                isCompleted = (goal > 0 and progress >= goal)
                                hasFoundInfo = true
                                break
                            end
                        end
                    end
                end
            end
        end)
    end

    if not hasFoundInfo or goal == 0 then
        local val1 = questObj:FindFirstChild("1")
        if val1 and val1:IsA("NumberValue") then
            progress = val1.Value
        end
        goal = math.huge
        isCompleted = false
    end

    return {
        Progress = progress,
        Goal = goal,
        Text = questText,
        IsCompleted = isCompleted
    }
end

--// 🔮 ESSENCE ORB (ZENG TIANGUO QUEST) HELPERS
local cachedZengNPC = nil
local function getZengNPC()
    if cachedZengNPC and cachedZengNPC.Parent then
        return cachedZengNPC
    end
    local npc = workspace:FindFirstChild("NPC")
    if npc then
        local func = npc:FindFirstChild("Function")
        if func and func:FindFirstChild("Zeng Tianguo") then
            cachedZengNPC = func["Zeng Tianguo"]
            return cachedZengNPC
        end
    end
    local found = workspace:FindFirstChild("Zeng Tianguo", true)
    if found then
        cachedZengNPC = found
        return cachedZengNPC
    end
    return nil
end

local function getActiveZengQuestInfo()
    local ok, data = pcall(function()
        return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
    end)
    if not ok or not data then return nil end

    local mainQuestFolder = data:FindFirstChild("Quest") and data.Quest:FindFirstChild("Main")
    if not mainQuestFolder then return nil end

    local questObj = mainQuestFolder:FindFirstChild("Zeng Tianguo Quest") 
        or mainQuestFolder:FindFirstChild("Zeng Tianguo")
        or mainQuestFolder:FindFirstChild("ZengTianguoQuest")
    
    if not questObj then
        for _, child in ipairs(mainQuestFolder:GetChildren()) do
            local lName = string.lower(child.Name)
            if string.find(lName, "zeng") or string.find(lName, "tianguo") then
                questObj = child
                break
            end
        end
    end

    if not questObj then return nil end

    local progress = 0
    local goal = 0
    local questText = ""
    local isCompleted = false
    local hasFoundInfo = false

    local objFolder = questObj:FindFirstChild("Objective")
    if objFolder and #objFolder:GetChildren() > 0 then
        local allCompleted = true
        local totalProg = 0
        local totalGoal = 0
        local descList = {}

        for _, objChild in ipairs(objFolder:GetChildren()) do
            local rawVal = tostring(objChild.Value or "")
            local parts = string.split(rawVal, ",")
            local desc = parts[1] or rawVal
            local targetVal = tonumber(parts[2]) or 0

            local valChild = questObj:FindFirstChild(objChild.Name)
            local curProg = (valChild and valChild:IsA("NumberValue")) and valChild.Value or 0

            table.insert(descList, desc .. " (" .. curProg .. "/" .. targetVal .. ")")
            totalProg = totalProg + curProg
            totalGoal = totalGoal + targetVal

            if targetVal > 0 and curProg < targetVal then
                allCompleted = false
            end
        end

        if totalGoal > 0 then
            progress = totalProg
            goal = totalGoal
            questText = table.concat(descList, " | ")
            isCompleted = allCompleted
            hasFoundInfo = true
        end
    end

    if not hasFoundInfo or goal == 0 then
        pcall(function()
            local qMenu = pGui.MainGui.Menu.Quest.Menu
            local mainUi = qMenu:FindFirstChild("Main_Quest") or qMenu:FindFirstChild("MainQuest")
            if mainUi then
                for _, card in ipairs(mainUi:GetChildren()) do
                    local lName = string.lower(card.Name)
                    local questFrame = card:FindFirstChild("Quest")
                    local title = questFrame and questFrame:FindFirstChild("Title")
                    local tLower = title and string.lower(title.Text) or ""
                    if string.find(lName, "zeng") or string.find(lName, "tianguo") or string.find(tLower, "zeng") or string.find(tLower, "tianguo") then
                        if questFrame then
                            for _, child in ipairs(questFrame:GetChildren()) do
                                if child:IsA("TextLabel") and child.Name ~= "Title" and child.Name ~= "Stats" and child.Visible then
                                    local t = child.Text
                                    local p, g = t:match("(%d+)/(%d+)")
                                    if p and g then
                                        progress = tonumber(p) or progress
                                        goal = tonumber(g) or goal
                                        questText = t
                                        isCompleted = (goal > 0 and progress >= goal)
                                        hasFoundInfo = true
                                        break
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end
        end)
    end

    if not hasFoundInfo or goal == 0 then
        local val1 = questObj:FindFirstChild("1")
        if val1 and val1:IsA("NumberValue") then
            progress = val1.Value
        end
        goal = 25
        isCompleted = (progress >= goal)
    end

    return {
        Progress = progress,
        Goal = goal,
        Text = questText,
        IsCompleted = isCompleted
    }
end

local function getDailyQuestStatus()
    local ok, data = pcall(function()
        return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
    end)
    if not ok or not data then return nil end
    local dailyFolder = data:FindFirstChild("Quest") and data.Quest:FindFirstChild("Daily")
    if not dailyFolder then return nil end

    local goals = { ["1"] = 100, ["2"] = 10, ["3"] = 25, ["4"] = 1800 }
    local result = {
        NeedFishing = false,
        NeedBoss = false,
        NeedBait = false,
        AllCompleted = true,
        Summary = ""
    }

    local sumList = {}
    for id, goal in pairs(goals) do
        local taskObj = dailyFolder:FindFirstChild(id)
        if taskObj then
            local prog = taskObj:FindFirstChild("Progression") and taskObj.Progression.Value or 0
            local isClaimed = taskObj:FindFirstChild("Claim") and taskObj.Claim.Value or false
            local qType = taskObj:FindFirstChild("QuestType") and taskObj.QuestType.Value or id

            if not isClaimed then
                result.AllCompleted = false
                if qType == "Fishing" or qType == "FishingSpecific" then
                    result.NeedFishing = true
                elseif qType == "BossQuest" then
                    result.NeedBoss = true
                elseif qType == "Bait" and prog < goal then
                    result.NeedBait = true
                end
            end

            local tag = isClaimed and "[Xong]" or (prog .. "/" .. goal)
            table.insert(sumList, qType .. ": " .. tag)
        end
    end

    result.Summary = table.concat(sumList, " | ")
    return result
end

local function processDailyQuestClaims()
    local ok, data = pcall(function()
        return ReplicatedStorage:WaitForChild("Data"):WaitForChild(player.UserId)
    end)
    if not ok or not data then return end
    local dailyFolder = data:FindFirstChild("Quest") and data.Quest:FindFirstChild("Daily")
    if not dailyFolder then return end

    local events = ReplicatedStorage:WaitForChild("Events")
    local claimRem = events:FindFirstChild("ClaimQuest")
    local buyBaitRem = events:FindFirstChild("BuyBait")
    local dailyRewardRem = events:FindFirstChild("DailyReward")

    if data:FindFirstChild("DailyReward") and dailyRewardRem then
        for i = 1, 7 do
            local dayObj = data.DailyReward:FindFirstChild(tostring(i))
            if dayObj and dayObj.Value == false then
                pcall(function() dailyRewardRem:FireServer(i) end)
            end
        end
    end

    local goals = { ["1"] = 100, ["2"] = 10, ["3"] = 25, ["4"] = 1800 }
    for id, goal in pairs(goals) do
        local taskObj = dailyFolder:FindFirstChild(id)
        if taskObj then
            local prog = taskObj:FindFirstChild("Progression") and taskObj.Progression.Value or 0
            local isClaimed = taskObj:FindFirstChild("Claim") and taskObj.Claim.Value or false
            local qType = taskObj:FindFirstChild("QuestType") and taskObj.QuestType.Value or id

            if qType == "Bait" and prog < goal and not isClaimed and buyBaitRem then
                local needed = goal - prog
                pcall(function() buyBaitRem:FireServer("Basic Bait", needed) end)
                task.wait(0.3)
            end

            if prog >= goal and not isClaimed and claimRem then
                pcall(function() claimRem:FireServer(id) end)
                task.wait(0.3)
            end
        end
    end
end

--// HỆ THỐNG TỐI ƯU FPS & GIẢM ĐỒ HỌA
local Lighting = game:GetService("Lighting")
local graphicsConn = nil

local function setFPSBoost(enabled)
    pcall(function()
        if setfpscap then
            if enabled then
                setfpscap(240)
            else
                setfpscap(60)
            end
        end
    end)
    pcall(function()
        if enabled then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

local function isProtectedInstance(v)
    if not v or not v.Parent then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (v == plr.Character or v:IsDescendantOf(plr.Character)) then
            return true
        end
    end
    local npcFolder = workspace:FindFirstChild("NPC")
    if npcFolder and (v == npcFolder or v:IsDescendantOf(npcFolder)) then return true end
    local sp = workspace:FindFirstChild("Spawnpoint")
    if sp and (v == sp or v:IsDescendantOf(sp)) then return true end
    local fishes = workspace:FindFirstChild("Fishes")
    if fishes and (v == fishes or v:IsDescendantOf(fishes)) then return true end
    local boat = workspace:FindFirstChild("Boat")
    if boat and (v == boat or v:IsDescendantOf(boat)) then return true end
    if v:IsA("BasePart") and (v.Name == "Water" or v:GetAttribute("WaterType") or (v.Parent and v.Parent.Name == "Ocean")) then
        return true
    end
    if v:IsA("Terrain") then
        return true
    end
    return false
end

local function isDecorOrFoliage(v)
    if isProtectedInstance(v) then return false end

    local name = string.lower(v.Name)
    -- Giữ an toàn cho toàn bộ đảo, mặt đất, bờ biển, đường đi, khu vực spawn
    if string.find(name, "isle") or string.find(name, "island") or string.find(name, "ground") 
        or string.find(name, "floor") or string.find(name, "shore") or string.find(name, "base") 
        or string.find(name, "terrain") or string.find(name, "water") or string.find(name, "ocean")
        or string.find(name, "spawn") or string.find(name, "sand") or string.find(name, "dirt") then
        return false
    end

    local parentName = v.Parent and string.lower(v.Parent.Name) or ""
    local checkParent = not (string.find(parentName, "isle") or string.find(parentName, "island") or string.find(parentName, "workspace"))

    local keywords = {
        "tree", "leaves", "leaf", "trunk", "branch", "bark", "wood",
        "bush", "bushes", "plant", "plants", "grass", "flower", "flowers",
        "foliage", "flora", "vegetation", "bamboo", "mushroom", "vine",
        "decor", "decoration", "decorations", "prop", "props", "detail", "details",
        "rock", "rocks", "stone", "boulder", "pebble", "pebbles",
        "fence", "bench", "lamp", "lantern", "streetlamp", "torch", "statue",
        "coral", "seaweed", "kelp", "grasspatch", "flowerbed", "clutter",
        "house", "building", "roof", "pillar", "gate", "bridge", "barrel", "box", "crate"
    }

    for _, kw in ipairs(keywords) do
        if string.find(name, kw) then
            return true
        end
        if checkParent and string.find(parentName, kw) then
            return true
        end
    end

    return false
end

local function applyGraphicsReduction(level)
    if graphicsConn then
        graphicsConn:Disconnect()
        graphicsConn = nil
    end

    if level == "Tắt" then
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            for _, eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA("PostEffect") or eff:IsA("Atmosphere") then
                    eff.Enabled = true
                end
            end
            if workspace.Terrain then
                workspace.Terrain.WaterWaveSize = 0.15
                workspace.Terrain.WaterWaveSpeed = 10
                workspace.Terrain.WaterReflectance = 1
                workspace.Terrain.Decoration = true
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
        return
    end

    -- 1. Cấp độ "Trung bình": Tắt bóng, khử sương mù, tắt hiệu ứng chói/mờ, giảm sóng nước
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, eff in ipairs(Lighting:GetChildren()) do
            if eff:IsA("BloomEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") or eff:IsA("BlurEffect") then
                eff.Enabled = false
            end
        end
        if workspace.Terrain then
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterReflectance = 0
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- 2. Cấp độ "Cao", "Cực cao", "Siêu cực đại"
    if level == "Cao" or level == "Cực cao" or level == "Siêu cực đại" then
        pcall(function()
            for _, eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA("PostEffect") or eff:IsA("Atmosphere") or eff:IsA("Clouds") then
                    eff.Enabled = false
                end
            end
            if workspace.Terrain then
                workspace.Terrain.Decoration = false
            end
            if level == "Siêu cực đại" then
                Lighting.Brightness = 1.5
                Lighting.ClockTime = 14
            end
        end)

        local function optimizeObj(v)
            pcall(function()
                if isProtectedInstance(v) then return end

                if level == "Siêu cực đại" then
                    -- Xóa bỏ hoàn toàn cây cối, thực vật, hoa cỏ, đồ decor trang trí, đá sỏi
                    if isDecorOrFoliage(v) then
                        v:Destroy()
                        return
                    end

                    -- Xóa bỏ PBR SurfaceAppearance và Decal/Texture
                    if v:IsA("SurfaceAppearance") or v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                        return
                    end

                    -- Xóa bỏ toàn bộ Particle, Beam, Trail, Smoke, Fire, Highlight
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") then
                        v:Destroy()
                        return
                    end

                    -- Tắt âm thanh môi trường không cần thiết trong workspace
                    if v:IsA("Sound") and not (v.Parent and v.Parent.Name == "SFX") then
                        v.Volume = 0
                    end

                    -- Chuyển toàn bộ địa hình/vật thể còn lại về SmoothPlastic tối giản tuyệt đối, gỡ bỏ TextureID của MeshPart
                    if v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Reflectance = 0
                        v.Material = Enum.Material.SmoothPlastic
                        if v:IsA("MeshPart") then
                            v.TextureID = ""
                        end
                    elseif v:IsA("SpecialMesh") then
                        v.TextureId = ""
                    end
                elseif level == "Cực cao" then
                    if v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Reflectance = 0
                        v.Material = Enum.Material.SmoothPlastic
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Highlight") then
                        v.Enabled = false
                    end
                elseif level == "Cao" then
                    if v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Reflectance = 0
                        if v.Material ~= Enum.Material.SmoothPlastic then
                            v.Material = Enum.Material.Plastic
                        end
                    elseif v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
            end)
        end

        for _, v in ipairs(workspace:GetDescendants()) do
            optimizeObj(v)
        end

        graphicsConn = workspace.DescendantAdded:Connect(function(v)
            if _G.FishingMasterSession ~= currentSession then
                if graphicsConn then graphicsConn:Disconnect() end
                return
            end
            task.wait()
            optimizeObj(v)
        end)
    end
end

-- Tự động áp dụng cài đặt lưu từ trước nếu có
if state.HighFPS then
    task.spawn(function()
        setFPSBoost(true)
    end)
end
if state.GraphicsLevel and state.GraphicsLevel ~= "Tắt" then
    task.spawn(function()
        task.wait(1.5)
        applyGraphicsReduction(state.GraphicsLevel)
    end)
end

--// UI INITIALIZATION
local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/UiRoblox.lua"
    ))()

local Window = Library:Window({
    Title  = "HEAVYWEIGHT_FISHING",
    Desc   = "Con Cu Màu Đen",
    Icon = 71051887760757,
    Theme  = "Amethyst",
   Config = {
            Keybind = Enum.KeyCode.K,
            Size = UDim2.new(0, 520, 0, 490)
        },

        CloseUIButton = {
            Enabled = true,
            Icon = 71051887760757
        }
})

local TabFarm = Window:Tab({ Title = "Main Farm", Icon = "fish" })
local TabQuest = Window:Tab({ Title = "Auto Quest", Icon = "clipboard-list" })
local TabTP = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TabSettings = Window:Tab({ Title = "Cài Đặt", Icon = "settings" })

--// FARMING TAB
TabFarm:Section({Title = "Auto Fishing"})

TabFarm:Toggle({
    Title = "Auto Fishing (Tự Cầm Cần & Câu Tại Chỗ)",
    Value = state.AutoFishing,
    Callback = function(v)
        state.AutoFishing = v
        save()
    end
})

TabFarm:Toggle({
    Title = "Auto Cast Skills (Z, X, C, V)",
    Value = state.AutoSkill,
    Callback = function(v)
        state.AutoSkill = v
        save()
    end
})

TabFarm:Toggle({
    Title = "Bật Tự Động Hồi Máu (Auto Heal Skill)",
    Desc = "Giữ chiêu hồi máu, chỉ dùng khi HP dưới % đã đặt",
    Value = state.AutoHealSkill,
    Callback = function(v)
        state.AutoHealSkill = v
        save()
    end
})

TabFarm:Dropdown({
    Title = "Chọn Chiêu Hồi Máu",
    Multi = false,
    List = {"Z", "X", "C", "V"},
    Value = state.HealSkillKey or "Z",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if val and val ~= "" then
            state.HealSkillKey = tostring(val)
            save()
        end
    end
})

local hpThresholdList = {"20%", "30%", "40%", "50%", "60%", "70%", "80%"}
TabFarm:Dropdown({
    Title = "Ngưỡng Máu Hồi (% HP)",
    Multi = false,
    List = hpThresholdList,
    Value = (state.HealHPThreshold or 40) .. "%",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        local num = tonumber(string.match(tostring(val), "%d+"))
        if num then
            state.HealHPThreshold = num
            save()
        end
    end
})

-- MỤC LỌC CÁ (SKIP CÁ RÁC / ĐỨT DÂY)
local FishFilterStatusLabel = TabFarm:Label({
    Title = "Trạng Thái Lọc Cá",
    Desc = "Chưa kích hoạt"
})

setFishFilterStatus = function(msg)
    if FishFilterStatusLabel and FishFilterStatusLabel.SetDesc then
        FishFilterStatusLabel:SetDesc(msg)
    end
end

TabFarm:Toggle({
    Title = "Bật Lọc Cá (Skip cá không chọn / Đứt dây)",
    Value = state.FishFilterEnabled,
    Callback = function(v)
        state.FishFilterEnabled = v
        save()
        if not v then
            setFishFilterStatus("🔴 Đã tắt lọc cá (Câu mọi loại cá).")
        else
            setFishFilterStatus("🟢 Đã bật lọc cá.")
        end
    end
})

TabFarm:Dropdown({
    Title = "Chọn Cá Muốn Câu (Đa Chọn)",
    Multi = true,
    List = AllFishNames,
    Value = state.SelectedFishList or {},
    Callback = function(selected)
        local filterMap = {}
        local listArr = {}
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v == true then
                    filterMap[k] = true
                    table.insert(listArr, k)
                elseif type(v) == "string" then
                    filterMap[v] = true
                    table.insert(listArr, v)
                end
            end
        elseif type(selected) == "string" and selected ~= "" then
            filterMap[selected] = true
            table.insert(listArr, selected)
        end
        state.SelectedFishFilter = filterMap
        state.SelectedFishList = listArr
        save()
        setFishFilterStatus("🎯 Đã chọn " .. #listArr .. " loài cá mục tiêu.")
    end
})

TabFarm:Section({Title = "Săn Boss Thời Tiết"})

local WeatherBossStatusLabel = TabFarm:Label({
    Title = "Trạng Thái Boss Thời Tiết",
    Desc = "Chưa kích hoạt"
})

setWeatherBossStatus = function(msg)
    if WeatherBossStatusLabel and WeatherBossStatusLabel.SetDesc then
        WeatherBossStatusLabel:SetDesc(msg)
    end
end

TabFarm:Toggle({
    Title = "Bật Săn Boss Thời Tiết",
    Value = state.AutoWeatherBoss,
    Callback = function(v)
        state.AutoWeatherBoss = v
        save()
        if not v then
            setWeatherBossStatus("🔴 Đã tắt săn boss thời tiết.")
        else
            local list = state.SelectedWeatherBossList or {}
            if #list > 1 then
                setWeatherBossStatus("🟢 Đã bật săn " .. #list .. " boss thời tiết mục tiêu.")
            elseif #list == 1 then
                local bName = list[1]
                local bInfo = WeatherFishDatabase[bName]
                if bInfo then
                    setWeatherBossStatus("🎯 Mục tiêu: " .. bName .. " | " .. bInfo.Island .. " (" .. bInfo.Weather .. ")")
                else
                    setWeatherBossStatus("🟢 Đã bật săn boss: " .. bName)
                end
            else
                setWeatherBossStatus("🟢 Đã bật săn boss thời tiết. (Hãy chọn ít nhất 1 boss)")
            end
        end
    end
})

TabFarm:Dropdown({
    Title = "Chọn Boss Thời Tiết (Đa Chọn)",
    Multi = true,
    List = WeatherBossList,
    Value = state.SelectedWeatherBossList or {"Flame Fish"},
    Callback = function(selected)
        local bossMap = {}
        local bossArr = {}
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v == true then
                    bossMap[k] = true
                    table.insert(bossArr, k)
                elseif type(v) == "string" then
                    bossMap[v] = true
                    table.insert(bossArr, v)
                end
            end
        elseif type(selected) == "string" and selected ~= "" then
            bossMap[selected] = true
            table.insert(bossArr, selected)
        end

        state.SelectedWeatherBosses = bossMap
        state.SelectedWeatherBossList = bossArr
        if #bossArr > 0 then
            state.SelectedWeatherBoss = bossArr[1]
        else
            state.SelectedWeatherBoss = nil
        end
        save()

        if #bossArr == 0 then
            setWeatherBossStatus("⚠️ Chưa chọn boss thời tiết nào.")
        elseif #bossArr == 1 then
            local bInfo = WeatherFishDatabase[bossArr[1]]
            if bInfo then
                setWeatherBossStatus("🎯 Mục tiêu: " .. bossArr[1] .. " | " .. bInfo.Island .. " (" .. bInfo.Weather .. ")")
            else
                setWeatherBossStatus("🎯 Đã chọn: " .. bossArr[1])
            end
        else
            setWeatherBossStatus("🎯 Đã chọn " .. #bossArr .. " boss thời tiết mục tiêu.")
        end
    end
})

TabFarm:Section({Title = "Minigame"})

TabFarm:Dropdown({
    Title = "Chế Độ Boss Minigame (Rhythm & Phase 2)",
    Multi = false,
    List = {"Chế độ An Toàn (Safe)", "Chế độ Siêu Tốc (Fast)"},
    Value = (state.MinigameMode == "Fast") and "Chế độ Siêu Tốc (Fast)" or "Chế độ An Toàn (Safe)",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if string.find(tostring(val), "Fast") then
            state.MinigameMode = "Fast"
        else
            state.MinigameMode = "Safe"
        end
        save()
    end
})

TabFarm:Toggle({
    Title = "Auto Rhythm (Nốt Nhạc Boss)",
    Value = state.AutoRhythm,
    Callback = function(v)
        state.AutoRhythm = v
        save()
    end
})

TabFarm:Toggle({
    Title = "Auto Boss Phase 2 (Thanh Trượt Boss)",
    Value = state.AutoBossPhase2,
    Callback = function(v)
        state.AutoBossPhase2 = v
        save()
    end
})

TabFarm:Toggle({
    Title = "Auto Slam & Charge",
    Value = state.AutoSlam,
    Callback = function(v)
        state.AutoSlam = v
        save()
    end
})

TabFarm:Toggle({
    Title = "Lock Fishing Bar (Khóa thanh câu ở tâm)",
    Value = state.LockBar,
    Callback = function(v)
        state.LockBar = v
        save()
    end
})
TabFarm:Section({Title = "Auto Sell"})
TabFarm:Toggle({
    Title = "Auto Sell All (10s)",
    Value = state.AutoSell,
    Callback = function(v)
        state.AutoSell = v
        save()
    end
})

--// AUTO QUEST TAB
local TicketStatusLabel = TabQuest:Label({
    Title = "Trạng Thái Ticket Quest",
    Desc = "Đang chờ..."
})

local DailyStatusLabel = TabQuest:Label({
    Title = "Tiến Trình Daily Quest",
    Desc = "Đang chờ..."
})

local EssenceStatusLabel = TabQuest:Label({
    Title = "Tiến Trình Essence Orb",
    Desc = "Đang chờ..."
})

local function setTicketStatus(msg)
    if TicketStatusLabel and TicketStatusLabel.SetDesc then
        TicketStatusLabel:SetDesc(msg)
    end
end

local function setDailyStatus(msg)
    if DailyStatusLabel and DailyStatusLabel.SetDesc then
        DailyStatusLabel:SetDesc(msg)
    end
end

local function setEssenceStatus(msg)
    if EssenceStatusLabel and EssenceStatusLabel.SetDesc then
        EssenceStatusLabel:SetDesc(msg)
    end
end

TabQuest:Section({Title = "Ticket Quest"})
TabQuest:Dropdown({
    Title = "Chọn chế độ Ticket Quest",
    Multi = false,
    List = {"Hard Ticket Quest", "Easy Ticket Quest"},
    Value = state.TicketHardMode and "Hard Ticket Quest" or "Easy Ticket Quest",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if val == "Hard Ticket Quest" then
            state.TicketHardMode = true
        else
            state.TicketHardMode = false
        end
        save()
        setTicketStatus("Chuyển sang: " .. (state.TicketHardMode and "Hard Ticket Quest" or "Easy Ticket Quest"))
    end
})

TabQuest:Toggle({
    Title = "Bật Auto Ticket Quest",
    Value = state.AutoTicketQuest,
    Callback = function(v)
        state.AutoTicketQuest = v
        save()
        if not v then
            ticketQuestWantsFishing = false
            isInteractingNPC = false
            setTicketStatus("🔴 Đã tắt Auto Ticket Quest.")
        end
    end
})

TabQuest:Section({Title = "Daily Quest"})
TabQuest:Toggle({
    Title = "Bật Auto Daily Quest",
    Value = state.AutoDailyQuest,
    Callback = function(v)
        state.AutoDailyQuest = v
        save()
        if not v then
            dailyQuestWantsFishing = false
            setDailyStatus("🔴 Đã tắt Auto Daily Quest.")
        end
    end
})
TabQuest:Section({Title = "Essence Orb"})
TabQuest:Toggle({
    Title = "Bật Auto Essence Orb",
    Value = state.AutoEssenceOrb,
    Callback = function(v)
        state.AutoEssenceOrb = v
        save()
        if not v then
            essenceOrbWantsFishing = false
            setEssenceStatus("🔴 Đã tắt Auto Essence Orb.")
        end
    end
})

TabQuest:Section({Title = "Position Farming"})
TabQuest:Dropdown({
    Title = "Chọn đảo để Farm",
    Multi = false,
    List = OrderedIslandList,
    Value = state.SelectedIsland or "Beginning Isle",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if val and val ~= "" then
            state.SelectedIsland = val
            save()
        end
    end
})

TabQuest:Button({
    Title = "Đặt vị trí hiện tại làm điểm câu",
    Callback = function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            CUSTOM_FARM_POS = char.HumanoidRootPart.Position
            setTicketStatus("📍 Đã lưu điểm câu: " .. math.floor(CUSTOM_FARM_POS.X) .. ", " .. math.floor(CUSTOM_FARM_POS.Y) .. ", " .. math.floor(CUSTOM_FARM_POS.Z))
        end
    end
})

--// TELEPORT TAB
local function findNPCInstance(npcName)
    local npcFolder = workspace:FindFirstChild("NPC")
    if npcFolder then
        local target = npcFolder:FindFirstChild(npcName, true)
        if target then return target end
    end
    return workspace:FindFirstChild(npcName, true)
end

local function teleportToNPC(npcName)
    local target = findNPCInstance(npcName)
    local char = getCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart

    if target then
        local targetPos = nil
        if target:IsA("Model") then
            local primary = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target:FindFirstChild("UpperTorso") or target:FindFirstChildWhichIsA("BasePart")
            if primary then
                targetPos = primary.Position
            else
                local cf, _ = target:GetBoundingBox()
                targetPos = cf.Position
            end
        elseif target:IsA("BasePart") then
            targetPos = target.Position
        end

        if targetPos then
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 4), targetPos)
            task.wait(0.3)
            return true
        end
    end
    return false
end

local function getAllNPCNames()
    local names = {}
    local seen = {}

    local defaultNPCs = {
        "Ticket Quest Giver",
        "Zeng Tianguo",
        "Blind Grand Angler",
        "Giang Lao",
        "Ha Dieu De",
        "Lao Ngo",
        "Biao Di",
        "Ba Chang",
        "Sage Yijiu",
        "Chu Tianjiao",
        "Taoist",
        "Shi Xing Diao",
        "Duan Gan",
        "Luoya Zhi Wang",
        "Yaxuo"
    }

    local npcFolder = workspace:FindFirstChild("NPC")
    if npcFolder then
        for _, child in ipairs(npcFolder:GetDescendants()) do
            if (child:IsA("Model") and (child:FindFirstChildWhichIsA("Humanoid") or child:FindFirstChild("Head") or child:FindFirstChildWhichIsA("BasePart"))) or (child:IsA("BasePart") and child.Parent == npcFolder) then
                local n = child.Name
                if not seen[n] and n ~= "Model" and n ~= "Part" and n ~= "Function" and n ~= "Quest" then
                    seen[n] = true
                    table.insert(names, n)
                end
            end
        end
    end

    for _, n in ipairs(defaultNPCs) do
        if not seen[n] then
            seen[n] = true
            table.insert(names, n)
        end
    end

    table.sort(names)
    return names
end

TabTP:Section({Title = "Teleport island"})

local selectedTPIsland = OrderedIslandList[1] or "Beginning Isle"
TabTP:Dropdown({
    Title = "Chọn Đảo",
    Multi = false,
    List = OrderedIslandList,
    Value = selectedTPIsland,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if val and val ~= "" then
            selectedTPIsland = val
        end
    end
})

TabTP:Button({
    Title = "Dịch Chuyển Đến Đảo",
    Callback = function()
        if selectedTPIsland then
            teleportToIslandSpawn(selectedTPIsland)
        end
    end
})

TabTP:Section({Title = "Teleport NPC"})

local npcList = getAllNPCNames()
local selectedTPNPC = npcList[1] or "Ticket Quest Giver"
TabTP:Dropdown({
    Title = "Chọn NPC",
    Multi = false,
    List = npcList,
    Value = selectedTPNPC,
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if val and val ~= "" then
            selectedTPNPC = val
        end
    end
})

TabTP:Button({
    Title = "Dịch Chuyển Đến NPC",
    Callback = function()
        if selectedTPNPC then
            teleportToNPC(selectedTPNPC)
        end
    end
})

--// SETTINGS TAB (FPS & ĐỒ HỌA)
TabSettings:Section({Title = "FPS"})
TabSettings:Toggle({
    Title = "Bật FPS Cao & Giảm Lag",
    Value = state.HighFPS,
    Callback = function(v)
        state.HighFPS = v
        save()
        setFPSBoost(v)
    end
})

local graphicsLevels = {"Tắt", "Trung bình", "Cao", "Cực cao", "Siêu cực đại"}
TabSettings:Dropdown({
    Title = "Giảm Đồ Họa (4 Cấp Độ Anti-Lag / Potato Mode)",
    Multi = false,
    List = graphicsLevels,
    Value = state.GraphicsLevel or "Tắt",
    Callback = function(selected)
        local val = type(selected) == "table" and selected[1] or selected
        if table.find(graphicsLevels, val) then
            state.GraphicsLevel = val
            save()
            applyGraphicsReduction(val)
        end
    end
})

TabSettings:Button({
    Title = "Làm Mới / Áp Dụng Lại Cài Đặt Đồ Họa",
    Callback = function()
        setFPSBoost(state.HighFPS)
        applyGraphicsReduction(state.GraphicsLevel or "Tắt")
    end
})

--// LOOPS & LOGIC

-- 1. Lock Bar
local bar = mainGui:WaitForChild("Fishing"):WaitForChild("BarFrame"):WaitForChild("Bar")
local renderConn
renderConn = RunService.RenderStepped:Connect(function()
    if _G.FishingMasterSession ~= currentSession then
        renderConn:Disconnect()
        return
    end
    if state.LockBar and bar and bar.Visible then
        bar.Position = UDim2.fromScale(0.5, 0.5)
    end
end)

-- 2. AUTO MINIGAMES ENGINE (SLAM & CHARGE, RHYTHM, BOSS PHASE 2)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local rhythmHitRem = events:FindFirstChild("RhythmHit")
    local bossActionRem = events:FindFirstChild("BossPhase2Action")
    local mobileFishingBtn = mainGui:WaitForChild("Mobile"):WaitForChild("Fishing")
    local fishingFrame = mainGui:WaitForChild("Fishing")
    local trashCan = fishingFrame:WaitForChild("TrashCan")
    local rhythmFrame = fishingFrame:FindFirstChild("Rhythm")
    local bossFightBar = fishingFrame:FindFirstChild("BossFightBar")

    -- Mapping phím cho các lane của Rhythm Minigame
    local laneKeyMap = {
        ["ProgressionA"] = Enum.KeyCode.A,
        ["ProgressionS"] = Enum.KeyCode.S,
        ["ProgressionD"] = Enum.KeyCode.D,
        ["Progression1"] = Enum.KeyCode.A,
        ["Progression2"] = Enum.KeyCode.S,
        ["Progression3"] = Enum.KeyCode.D,
        ["A"] = Enum.KeyCode.A,
        ["S"] = Enum.KeyCode.S,
        ["D"] = Enum.KeyCode.D,
    }

    local function hitRhythm(lane, keyCode)
        -- Kích hoạt nút bấm trên lane để chạy TryHit() gốc của game
        local btn = lane:FindFirstChild("Button") or lane:FindFirstChildWhichIsA("TextButton", true) or lane:FindFirstChildWhichIsA("ImageButton", true)
        if btn then
            doVimClick(btn)
        end
        -- Gửi sự kiện phím phần cứng A, S, D qua VirtualInputManager
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.04)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end
    end

    -- [A & B]: Xử lý Slam & Charge (Hoạt động độc lập, không phụ thuộc chế độ)
    trashCan.ChildAdded:Connect(function(child)
        if _G.FishingMasterSession ~= currentSession then return end
        if not state.AutoSlam then return end

        -- Auto Charge: Bấm nút Charge ngay
        if child.Name == "Charge" then
            task.wait(0.04)
            local btn = child:FindFirstChild("Button") or child:FindFirstChildWhichIsA("TextButton", true)
            if btn then
                doVimClick(btn)
            end
        end

        -- Auto Slam: Đợi vòng Line co vào vùng Perfect rồi bấm
        if child.Name == "Slam" or string.find(child:GetFullName(), "TrashCan") then
            local line = child:FindFirstChild("Line", true)
            local btn = child:FindFirstChild("Button") or child
            if line and btn then
                local clicked = false
                local conn
                conn = line:GetPropertyChangedSignal("Size"):Connect(function()
                    if (_G.FishingMasterSession ~= currentSession) or clicked then
                        conn:Disconnect()
                        return
                    end
                    if line.Size.X.Scale <= 1.12 and line.Size.X.Scale >= 0.98 then
                        clicked = true
                        doVimClick(btn)
                        conn:Disconnect()
                    end
                end)
            end
        end
    end)

    -- [C & D]: Xử lý Rhythm Minigame & Boss Fight Bar qua RenderStepped
    local lastRhythmHit = 0
    local lastBossHit = 0
    local bossHitCooldown = 0.10

    -- Theo dõi Rhythm
    local rhythmMissCount = 0
    local isRhythmActive = false
    local ignoredRhythmNotes = {}

    -- Theo dõi Boss Phase 2
    local bossMissCount = 0
    local isBossActive = false
    local bossCycleMissed = false
    local lastBarDir = 1
    local prevBarX = 0
    local bossHitIndex = 1
    local lastHitboxPos = nil

    local miniConn
    miniConn = RunService.RenderStepped:Connect(function()
        if _G.FishingMasterSession ~= currentSession then
            miniConn:Disconnect()
            return
        end

        local isSafe = (state.MinigameMode ~= "Fast")

        -- [C] Auto Rhythm Minigame (Nốt nhạc Boss)
        if state.AutoRhythm and rhythmFrame and rhythmFrame.Visible then
            if not isRhythmActive then
                isRhythmActive = true
                rhythmMissCount = 0
                ignoredRhythmNotes = {}
            end

            local now = tick()
            local rhythmCooldown = 0.20

            for _, lane in ipairs(rhythmFrame:GetChildren()) do
                if string.find(lane.Name, "Progression") then
                    local barF = lane:FindFirstChild("BarFrame")
                    local targetY = barF and barF.Position.Y.Scale or 0.85
                    local keyCode = laneKeyMap[lane.Name]

                    for _, child in ipairs(lane:GetChildren()) do
                        if child.Name == "Note_FX" and child.Visible then
                            local curY = child.Position.Y.Scale
                            -- Bỏ qua nốt bẫy (màu đỏ: game đặt Color3.fromRGB(255, 40, 40), bấm trúng sẽ bị tính miss và trừ máu)
                            local bg = child.BackgroundColor3
                            local isTrap = (bg.R > 0.75 and bg.G < 0.45 and bg.B < 0.45)
                            if not isTrap and (child:IsA("ImageLabel") or child:IsA("ImageButton")) then
                                local ic = child.ImageColor3
                                if ic.R > 0.75 and ic.G < 0.45 and ic.B < 0.45 then
                                    isTrap = true
                                end
                            end

                            if isTrap then
                                ignoredRhythmNotes[child] = true -- Tuyệt đối không bấm nốt đỏ, bỏ qua để nốt tự trôi đi
                            else
                                -- Cả 2 chế độ đều bắt buộc nốt phải chạm vạch (targetY) mới hit để tránh server phát hiện ban
                                local hitRangeMin = isSafe and (targetY - 0.08) or (targetY - 0.05)
                                local hitRangeMax = isSafe and (targetY + 0.10) or (targetY + 0.14)

                                if curY >= hitRangeMin and curY <= hitRangeMax then
                                    if not ignoredRhythmNotes[child] then
                                        if not isSafe then
                                            -- Chế độ Siêu Tốc (Fast): Chạm vạch là hit ngay tức khắc, bắn Remote + Click, 0ms delay, 0 lần miss
                                            ignoredRhythmNotes[child] = true
                                            if rhythmHitRem then
                                                rhythmHitRem:FireServer("hit")
                                            end
                                            hitRhythm(lane, keyCode)
                                        else
                                            -- Chế độ An Toàn (Safe): Phản xạ tự nhiên (40ms - 80ms), cho phép miss tối đa 3 lần (không click khi sai)
                                            if rhythmMissCount < 3 and math.random(1, 8) == 1 then
                                                rhythmMissCount = rhythmMissCount + 1
                                                ignoredRhythmNotes[child] = true -- Bỏ qua nốt này, để trôi tự nhiên (không click khi sai)
                                            elseif now - lastRhythmHit >= rhythmCooldown then
                                                lastRhythmHit = now
                                                task.spawn(function()
                                                    local rxDelay = math.random(4, 8) / 100
                                                    task.wait(rxDelay)
                                                    hitRhythm(lane, keyCode)
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            isRhythmActive = false
        end

        -- [D] Auto Boss Fight Bar (Boss Phase 2)
        if state.AutoBossPhase2 and bossFightBar and bossFightBar.Visible then
            if not isBossActive then
                isBossActive = true
                bossMissCount = 0
                bossCycleMissed = false
                prevBarX = 0
                bossHitIndex = 1
                lastHitboxPos = nil
            end

            local bBar = bossFightBar:FindFirstChild("Bar")
            local hitbox = bossFightBar:FindFirstChild("Hitbox")
            local badHitbox = bossFightBar:FindFirstChild("HitboxBad")

            if bBar and hitbox and hitbox.Visible then
                local curHitboxX = hitbox.Position.X.Scale
                if lastHitboxPos == nil then
                    lastHitboxPos = curHitboxX
                elseif math.abs(curHitboxX - lastHitboxPos) > 0.001 then
                    lastHitboxPos = curHitboxX
                    bossHitIndex = bossHitIndex + 1
                end

                local hbSizeX = hitbox.Size.X.Scale
                local hbAnchorX = hitbox.AnchorPoint.X
                local realHbLeft = hitbox.Position.X.Scale - (hbAnchorX * hbSizeX)
                local realHbRight = realHbLeft + hbSizeX

                local barSizeX = bBar.Size.X.Scale
                local barAnchorX = bBar.AnchorPoint.X
                local realBarCenter = bBar.Position.X.Scale + (0.5 - barAnchorX) * barSizeX

                -- Theo dõi hướng di chuyển của thanh trượt để nhận diện chu kỳ lướt mới
                local currentDir = lastBarDir
                if prevBarX ~= 0 then
                    if realBarCenter > prevBarX then
                        currentDir = 1
                    elseif realBarCenter < prevBarX then
                        currentDir = -1
                    end
                end

                if currentDir ~= lastBarDir then
                    lastBarDir = currentDir
                    bossCycleMissed = false -- Đổi chiều di chuyển -> reset chu kỳ
                end
                prevBarX = realBarCenter

                local minX, maxX
                if isSafe then
                    -- Chế độ An Toàn: Chỉ bấm trong vùng an toàn 20% - 80% của hitbox
                    minX = realHbLeft + hbSizeX * 0.20
                    maxX = realHbRight - hbSizeX * 0.20
                else
                    -- Chế độ Siêu Tốc: Bấm ngay khi thanh trượt chạm hitbox (4% - 96%)
                    minX = realHbLeft + hbSizeX * 0.04
                    maxX = realHbRight - hbSizeX * 0.04
                end

                if realBarCenter >= minX and realBarCenter <= maxX then
                    local inBad = false
                    if badHitbox and badHitbox.Visible then
                        local badSizeX = badHitbox.Size.X.Scale
                        local badAnchorX = badHitbox.AnchorPoint.X
                        local realBadLeft = badHitbox.Position.X.Scale - (badAnchorX * badSizeX)
                        local realBadRight = realBadLeft + badSizeX
                        local badMargin = isSafe and 0.02 or 0.005
                        if realBarCenter >= (realBadLeft - badMargin) and realBarCenter <= (realBadRight + badMargin) then
                            inBad = true
                        end
                    end

                    if not inBad then
                        if isSafe then
                            -- Chế độ An Toàn: Cho phép miss tối đa 3 lần, khi miss KHÔNG click gì cả
                            if bossMissCount < 3 and not bossCycleMissed and math.random(1, 6) == 1 then
                                bossMissCount = bossMissCount + 1
                                bossCycleMissed = true -- Bỏ qua lượt này tự nhiên, không click khi sai
                            elseif not bossCycleMissed and tick() - lastBossHit >= bossHitCooldown then
                                lastBossHit = tick()
                                bossHitCooldown = math.random(10, 15) / 100
                                doVimClick(mobileFishingBtn)
                            end
                        else
                            -- Chế độ Siêu Tốc: Dùng Remote BossPhase2Action xử lý nhanh tốc độ (0.04s - 0.06s), không miss
                            if tick() - lastBossHit >= bossHitCooldown then
                                lastBossHit = tick()
                                bossHitCooldown = math.random(4, 6) / 100
                                if bossActionRem then
                                    bossActionRem:FireServer({
                                        Hit = true,
                                        Index = bossHitIndex
                                    })
                                end
                                doVimClick(mobileFishingBtn)
                            end
                        end
                    end
                end
            end
        else
            isBossActive = false
        end
    end)
end)

-- 3. Auto Sell
task.spawn(function()
    while _G.FishingMasterSession == currentSession do
        task.wait(10)
        if state.AutoSell then
            local events = ReplicatedStorage:WaitForChild("Events")
            local sellRem = events:FindFirstChild("SellFish")
            if sellRem then sellRem:FireServer("All") end
        end
    end
end)

-- 4. Fishing & Skill Loop
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local skillRem = events:WaitForChild("UseSkill")
    local fishRem = events:WaitForChild("Fishing")
    local hotbarRem = events:WaitForChild("ToggleHotbar")
    local minigameRem = events:WaitForChild("FishingMinigame")
    local skillKeys = {"Z", "X", "C", "V"}

    local currentHookedFishName = nil
    minigameRem.OnClientEvent:Connect(function(u40)
        if type(u40) == "table" and u40.FishName then
            currentHookedFishName = u40.FishName
        end
    end)

    local function getHookedFishName()
        if currentHookedFishName and currentHookedFishName ~= "" then
            return currentHookedFishName
        end
        local fGui = mainGui:FindFirstChild("Fishing")
        local progBar = fGui and fGui:FindFirstChild("ProgressionBar")
        local fishNameLbl = progBar and progBar:FindFirstChild("FishName")
        if fishNameLbl and fishNameLbl.Text ~= "" and fishNameLbl.Text ~= "Fish" then
            return fishNameLbl.Text
        end
        return nil
    end

    -- Hàm kiểm tra kỹ năng Z, X, C, V có đang sẵn sàng (dùng được) hay đang hồi chiêu (cooldown)
    local function isSkillReady(key)
        local char = getCharacter()
        if not char then return false end

        -- Không dùng skill nếu character đang bị khóa chiêu toàn cục
        if char:GetAttribute("SkillLocked") == true then
            return false
        end

        -- 1. Kiểm tra trên UI SkillButton.Frame
        local fGui = mainGui:FindFirstChild("Fishing")
        local skillBtnFrame = fGui and fGui:FindFirstChild("SkillButton") and fGui.SkillButton:FindFirstChild("Frame")
        local btn = skillBtnFrame and skillBtnFrame:FindFirstChild(key)
        if btn then
            -- Nếu nút không visible -> Cần câu không gắn skill ở slot này
            if not btn.Visible then
                return false
            end
            -- Nếu CD frame đang hiển thị -> skill đang trong thời gian hồi chiêu
            local cd = btn:FindFirstChild("CD")
            if cd and cd.Visible then
                return false
            end
        end

        -- 2. Kiểm tra trong Character.Skills
        local skillsFolder = char:FindFirstChild("Skills")
        if skillsFolder then
            for _, skillVal in ipairs(skillsFolder:GetChildren()) do
                if skillVal:IsA("NumberValue") and skillVal:GetAttribute("Key") == key then
                    if skillVal.Value > 0 then
                        return false
                    end
                    local using = skillVal:GetAttribute("UsingSkill")
                    if using and using > 0 then
                        return false
                    end
                end
            end
        end

        return true
    end

    -- Hàm lấy % máu hiện tại của người chơi khi đang kéo cá / boss
    local function getPlayerFishingHealthPercent(fishObj)
        -- 1. Đọc từ NumberValue PlayerHealth trong cá
        if fishObj then
            for _, child in ipairs(fishObj:GetChildren()) do
                if string.find(child.Name, tostring(pId)) and string.find(child.Name, "PlayerHealth") and child:IsA("NumberValue") then
                    local maxHp = child:GetAttribute("MaxHP")
                    if not maxHp or maxHp <= 0 then
                        local fGui = mainGui:FindFirstChild("Fishing")
                        local hpPlayer = fGui and fGui:FindFirstChild("HPPlayer")
                        local progBar = hpPlayer and hpPlayer:FindFirstChild("ProgressionBar")
                        local valText = progBar and progBar:FindFirstChild("Value") and progBar.Value.Text
                        if valText and string.find(valText, "/") then
                            local _, m = valText:match("(%d+)/(%d+)")
                            maxHp = tonumber(m)
                        end
                    end
                    if maxHp and maxHp > 0 then
                        return (child.Value / maxHp) * 100
                    end
                end
            end
        end

        -- 2. Đọc từ UI HPPlayer của Fishing GUI
        local fGui = mainGui:FindFirstChild("Fishing")
        local hpPlayer = fGui and fGui:FindFirstChild("HPPlayer")
        if hpPlayer and hpPlayer.Visible then
            local progBar = hpPlayer:FindFirstChild("ProgressionBar")
            local bar = progBar and progBar:FindFirstChild("Bar")
            if bar then
                local scale = math.clamp(bar.Size.X.Scale, 0, 1)
                return scale * 100
            end
        end

        -- 3. Fallback theo Humanoid
        local char = getCharacter()
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.MaxHealth > 0 then
            return (hum.Health / hum.MaxHealth) * 100
        end

        return 100
    end

    while _G.FishingMasterSession == currentSession do
        local canFish = isFishingAllowed()
        if canFish then
            if not isHoldingRod() then
                equipRod()
                task.wait(0.5)
            end

            if isHoldingRod() and isFishingAllowed() then
                local char = getCharacter()
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- 1. Gửi CFrame chuẩn như client gốc để Server nhận diện đúng hướng mặt/vị trí ném
                fishRem:FireServer(hrp and hrp.CFrame or nil)

                -- 2. Kiểm tra ném cần thành công ngay lập tức (trong 1.5s)
                local castSuccess = false
                local checkStart = tick()
                while (tick() - checkStart) < 1.5 do
                    char = getCharacter()
                    if char then
                        -- Check Attribute "Fishing" hoặc "Retractable" do server cập nhật
                        if char:GetAttribute("Fishing") == true or char:GetAttribute("Retractable") == true then
                            castSuccess = true
                            break
                        end
                        -- Check sự xuất hiện của phao câu "Buoy" trong Character
                        if char:FindFirstChild("Buoy") then
                            castSuccess = true
                            break
                        end
                    end
                    -- Check nếu cá đã cắn câu ngay
                    if findMyFish() then
                        castSuccess = true
                        break
                    end
                    task.wait(0.12)
                end

                if not castSuccess then
                    -- Ném cần thất bại (kẹt góc, lệch bờ nước, hoặc server từ chối)
                    -- Đổi góc/điểm đứng ngay lập tức, không lãng phí 10s chờ đợi
                    task.wait(0.2)
                    if not (state.AutoWeatherBoss and weatherBossActive) then
                        if state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                            relocateCurrentFishingSpot()
                        end
                    end
                    task.wait(0.5)
                else
                    -- Ném cần THÀNH CÔNG -> Chờ cá cắn câu
                    local targetFish = nil
                    local startWait = tick()
                    
                    repeat
                        targetFish = findMyFish()
                        -- Nếu trong lúc chờ mà trạng thái câu bị hủy bất ngờ
                        char = getCharacter()
                        if char and char:GetAttribute("Fishing") == false then
                            break
                        end
                        task.wait(0.3) 
                    until targetFish or not isFishingAllowed() or (tick() - startWait >= 10)

                    -- Có cá cắn câu
                    if isFishingAllowed() and targetFish then
                        -- 1. Xác định loài cá vừa cắn câu
                        local hookedFishName = nil
                        local waitNameStart = tick()
                        while not hookedFishName and (tick() - waitNameStart < 1.0) do
                            hookedFishName = getHookedFishName()
                            if not hookedFishName then task.wait(0.05) end
                        end

                        -- 2. Kiểm tra bộ lọc cá (Fish Filter & Weather Boss)
                        local isWanted = true
                        if weatherBossActive then
                            -- Khi đang săn Boss Thời Tiết: CHỈ CÂU CÁC CON BOSS MỤC TIÊU HỢP LỆ TRÊN ĐẢO NÀY!
                            if hookedFishName and not activeWeatherBossTargets[hookedFishName] then
                                isWanted = false
                            end
                        elseif state.FishFilterEnabled and not (state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb) then
                            local hasSelection = false
                            if state.SelectedFishFilter then
                                for _ in pairs(state.SelectedFishFilter) do
                                    hasSelection = true
                                    break
                                end
                            end

                            if hasSelection then
                                if hookedFishName and not state.SelectedFishFilter[hookedFishName] then
                                    isWanted = false
                                end
                            end
                        end

                        -- Nếu KHÔNG PHẢI CÁ MONG MUỐN -> Đứt dây & Cất cần / Cầm lại
                        if not isWanted then
                            setFishFilterStatus("⏭️ Bỏ qua cá: " .. tostring(hookedFishName or "Không rõ") .. " -> Đứt dây & Thả lại...")
                            if weatherBossActive then
                                local targetBossNames = {}
                                for bName in pairs(activeWeatherBossTargets) do
                                    table.insert(targetBossNames, bName)
                                end
                                local bossNamesStr = #targetBossNames > 0 and table.concat(targetBossNames, ", ") or tostring(currentHuntingBoss or "Boss")
                                setWeatherBossStatus("⏭️ Bỏ qua " .. tostring(hookedFishName or "cá rác") .. " -> Đang đợi: " .. bossNamesStr .. "...")
                            end
                            -- Cất cần (Lúc này đang cầm cần -> gọi ToggleHotbar sẽ cất cần -> game tự hủy minigame / cá biến mất)
                            pcall(function()
                                hotbarRem:InvokeServer("1", nil)
                            end)
                            task.wait(0.3)
                            -- Cầm cần lại để chuẩn bị ném tiếp
                            equipRod()
                            task.wait(0.4)
                            currentHookedFishName = nil
                        else
                            -- ĐÚNG CÁ MONG MUỐN -> Bắt đầu câu & tung skill
                            if hookedFishName then
                                setFishFilterStatus("🎯 Đang câu: " .. hookedFishName)
                                if weatherBossActive then
                                    setWeatherBossStatus("🔥 ĐÃ CẮN CÂU: " .. hookedFishName .. "! Đang kéo boss...")
                                end
                            end

                            local readyObj = targetFish:FindFirstChild("Ready")
                            if readyObj then
                                local waitReady = tick()
                                repeat 
                                    task.wait(0.1) 
                                until readyObj.Value == true or not targetFish.Parent or (tick() - waitReady > 5)
                            else
                                task.wait(3.1)
                            end

                            while targetFish and targetFish.Parent and isFishingAllowed() do
                                if state.AutoSkill then
                                    -- 1. Cơ chế TỰ ĐỘNG HỒI MÁU KHẨN CẤP
                                    if state.AutoHealSkill and state.HealSkillKey and state.HealSkillKey ~= "" then
                                        local currentHPPercent = getPlayerFishingHealthPercent(targetFish)
                                        local threshold = tonumber(state.HealHPThreshold) or 40

                                        if currentHPPercent <= threshold then
                                            -- Máu đang dưới ngưỡng! Kích hoạt ngay chiêu hồi máu nếu đã sẵn sàng
                                            if isSkillReady(state.HealSkillKey) then
                                                skillRem:FireServer(state.HealSkillKey)
                                                task.wait(0.2)
                                            end
                                        end
                                    end

                                    -- 2. Cơ chế THI TRIỂN TẤN CÔNG (theo dõi chiêu nào dùng được, chiêu nào đang hồi)
                                    for _, key in ipairs(skillKeys) do
                                        -- Nếu đang bật hồi máu: Chiêu hồi máu ĐƯỢC GIỮ LẠI, KHÔNG dùng để tấn công
                                        if state.AutoHealSkill and key == state.HealSkillKey then
                                            continue
                                        end

                                        -- Chỉ thi triển chiêu có thể dùng (đã hồi xong, không bị cooldown hay lock)
                                        if isSkillReady(key) then
                                            skillRem:FireServer(key)
                                            task.wait(0.18)
                                        end
                                    end

                                    task.wait(0.15)
                                else
                                    task.wait(0.5)
                                end
                            end
                            currentHookedFishName = nil
                        end
                    -- Quá 10s có ném cần nhưng không có cá cắn -> Đổi điểm đứng khác (chỉ khi làm Quest)
                    elseif isFishingAllowed() and not targetFish then
                        task.wait(0.3)
                        if not (state.AutoWeatherBoss and weatherBossActive) then
                            if state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                                relocateCurrentFishingSpot()
                            end
                        end
                        task.wait(0.8)
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

-- 5. AUTO DAILY QUEST
task.spawn(function()
    while _G.FishingMasterSession == currentSession do
        task.wait(3)
        if state.AutoDailyQuest then
            if state.AutoWeatherBoss and weatherBossActive then
                dailyQuestWantsFishing = false
                task.wait(2)
                continue
            end

            processDailyQuestClaims()
            local dStatus = getDailyQuestStatus()
            
            if dStatus then
                setDailyStatus(dStatus.Summary)

                if (dStatus.NeedFishing or dStatus.NeedBoss) and not state.AutoTicketQuest and not state.AutoEssenceOrb then
                    currentFishingLocation = { Type = "Island", Name = "Battlefield Isle" }
                    teleportToIslandShore("Battlefield Isle")
                    dailyQuestWantsFishing = true
                elseif dStatus.AllCompleted and not state.AutoTicketQuest and not state.AutoEssenceOrb then
                    dailyQuestWantsFishing = false
                end
            end
        else
            dailyQuestWantsFishing = false
        end
    end
end)

-- 6. AUTO TICKET QUEST
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local remoteDialogue = events:WaitForChild("ChooseDialogueOption")

    while _G.FishingMasterSession == currentSession do
        task.wait(1.5)
        if state.AutoTicketQuest then
            -- Ưu tiên số 1: Nếu đang săn Boss Thời Tiết -> Tạm dừng Quest hoàn toàn để không giật/ép đảo
            if state.AutoWeatherBoss and weatherBossActive then
                ticketQuestWantsFishing = false
                isInteractingNPC = false
                local bName = currentHuntingBoss or state.SelectedWeatherBoss or "Boss"
                setTicketStatus("⚡ Tạm dừng: Đang ưu tiên Săn Boss Thời Tiết (" .. tostring(bName) .. ")...")
                task.wait(2)
                continue
            end

            if state.AutoEssenceOrb then
                task.wait(2)
                continue
            end

            local npc = getTicketNPC()
            if not npc then
                setTicketStatus("⚠️ Không tìm thấy NPC Ticket Quest Giver.")
                task.wait(3)
                continue
            end

            -- 1. Kiểm tra tiến trình nhiệm vụ trước tiên
            local qInfo = getActiveTicketQuestInfo()
            local modeName = state.TicketHardMode and "Hard Ticket Quest" or "Easy Ticket Quest"
            local acceptAction = state.TicketHardMode and "HardAcceptQuest" or "EasyAcceptQuest"
            local acceptIndex = state.TicketHardMode and 2 or 1

            -- [TRƯỜNG HỢP A]: Đã xong nhiệm vụ -> Trả từ xa (Không tele tới NPC)
            if qInfo and qInfo.IsCompleted then
                isInteractingNPC = true
                ticketQuestWantsFishing = false
                setTicketStatus("🎉 Đã xong (" .. qInfo.Progress .. "/" .. qInfo.Goal .. ")! Đang trả từ xa...")
                
                remoteDialogue:FireServer("Ticket Quest Giver", 1, "Quest", {npc})
                task.wait(1.5)
                isInteractingNPC = false
                continue
            end

            -- [TRƯỜNG HỢP B]: Đang có nhiệm vụ chưa xong -> ĐI LÀM NGAY (Bỏ qua Cooldown)
            if qInfo and not qInfo.IsCompleted then
                ensureBaitForQuest(qInfo)

                local targetData = analyzeQuestTarget(qInfo.Text)
                local statusMsg = qInfo.Text ~= "" and qInfo.Text or (qInfo.Progress .. "/" .. qInfo.Goal)

                if not targetData.CanFishNow then
                    local farmIsland = state.SelectedIsland or "Beginning Isle"
                    setTicketStatus("⏳ [" .. statusMsg .. "] Chờ " .. targetData.RequiredWeather .. " -> Farm tại: " .. farmIsland)
                    currentFishingLocation = { Type = "Island", Name = farmIsland }
                    teleportToIslandShore(farmIsland)
                    isInteractingNPC = false
                    ticketQuestWantsFishing = true
                    task.wait(2)
                    continue
                end

                setTicketStatus("🌊 Đang câu tại: " .. targetData.Destination .. " | " .. statusMsg)
                travelToQuestSpot(targetData)
                isInteractingNPC = false
                ticketQuestWantsFishing = true
                continue
            end

            -- [TRƯỜNG HỢP C]: Không có nhiệm vụ nào trong người -> Lúc này mới kiểm tra Cooldown
            local cd = getQuestCooldown()
            if cd > 0 then
                local farmIsland = state.SelectedIsland or "Beginning Isle"
                setTicketStatus("⏳ Hồi vé: " .. cd .. "s -> Đang farm tại: " .. farmIsland)
                currentFishingLocation = { Type = "Island", Name = farmIsland }
                teleportToIslandShore(farmIsland)
                isInteractingNPC = false
                ticketQuestWantsFishing = true
                task.wait(1.5)
                continue
            end

            -- [TRƯỜNG HỢP D]: Không có nhiệm vụ VÀ đã hết hồi chiêu -> Nhận từ xa (Không tele tới NPC)
            isInteractingNPC = true
            ticketQuestWantsFishing = false
            setTicketStatus("📥 Đang nhận từ xa " .. modeName .. "...")
            
            remoteDialogue:FireServer("Ticket Quest Giver", acceptIndex, acceptAction, {npc, "Ticket Quest"})
            task.wait(1.5)
            isInteractingNPC = false
        else
            ticketQuestWantsFishing = false
            isInteractingNPC = false
        end
    end
end)

-- 7. AUTO ESSENCE ORB (ZENG TIANGUO QUEST)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local remoteDialogue = events:WaitForChild("ChooseDialogueOption")

    while _G.FishingMasterSession == currentSession do
        task.wait(1.5)
        if state.AutoEssenceOrb then
            -- Ưu tiên số 1: Nếu đang săn Boss Thời Tiết -> Tạm dừng Quest hoàn toàn để không giật/ép đảo
            if state.AutoWeatherBoss and weatherBossActive then
                essenceOrbWantsFishing = false
                isInteractingNPC = false
                local bName = currentHuntingBoss or state.SelectedWeatherBoss or "Boss"
                setEssenceStatus("⚡ Tạm dừng: Đang ưu tiên Săn Boss Thời Tiết (" .. tostring(bName) .. ")...")
                task.wait(2)
                continue
            end

            local npc = getZengNPC() or (workspace:FindFirstChild("NPC") and workspace.NPC:FindFirstChild("Function") and workspace.NPC.Function:FindFirstChild("Zeng Tianguo"))
            local npcTable = npc and {npc} or {}

            -- 1. Kiểm tra tiến trình nhiệm vụ
            local qInfo = getActiveZengQuestInfo()

            -- [TRƯỜNG HỢP A]: Đã xong nhiệm vụ -> Trả từ xa nhận Essence Orb
            if qInfo and qInfo.IsCompleted then
                isInteractingNPC = true
                essenceOrbWantsFishing = false
                setEssenceStatus("🎉 Đã xong (" .. qInfo.Progress .. "/" .. qInfo.Goal .. ")! Đang trả từ xa nhận Essence Orb...")

                remoteDialogue:FireServer("Zeng Tianguo", 1, "Quest", npcTable)
                task.wait(2)
                isInteractingNPC = false
                continue
            end

            -- [TRƯỜNG HỢP B]: Đang có nhiệm vụ chưa xong -> Tự phân tích yêu cầu nhiệm vụ & đi làm
            if qInfo and not qInfo.IsCompleted then
                ensureBaitForQuest(qInfo)

                local targetData = analyzeQuestTarget(qInfo.Text)
                local statusMsg = qInfo.Text ~= "" and qInfo.Text or (qInfo.Progress .. "/" .. qInfo.Goal)

                if not targetData.CanFishNow then
                    local farmIsland = state.SelectedIsland or "Beginning Isle"
                    setEssenceStatus("⏳ [" .. statusMsg .. "] Chờ " .. (targetData.RequiredWeather or "thời tiết") .. " -> Farm tại: " .. farmIsland)
                    currentFishingLocation = { Type = "Island", Name = farmIsland }
                    teleportToIslandShore(farmIsland)
                    isInteractingNPC = false
                    essenceOrbWantsFishing = true
                    task.wait(2)
                    continue
                end

                setEssenceStatus("🔮 [" .. statusMsg .. "] -> Câu tại: " .. targetData.Destination)
                travelToQuestSpot(targetData)
                isInteractingNPC = false
                essenceOrbWantsFishing = true
                continue
            end

            -- [TRƯỜNG HỢP C]: Không có nhiệm vụ -> Nhận từ xa
            isInteractingNPC = true
            essenceOrbWantsFishing = false
            setEssenceStatus("📥 Đang nhận từ xa Zeng Tianguo Quest...")

            remoteDialogue:FireServer("Zeng Tianguo", 1, "AcceptQuest", {npcTable[1] or npc, "Zeng Tianguo Quest"})
            task.wait(2)
            isInteractingNPC = false
        else
            essenceOrbWantsFishing = false
        end
    end
end)

-- 8. AUTO WEATHER BOSS HUNTER (ĐA CHỌN BOSS THỜI TIẾT)
task.spawn(function()
    while _G.FishingMasterSession == currentSession do
        task.wait(1.5)
        local selectedList = state.SelectedWeatherBossList or {}
        if #selectedList == 0 and state.SelectedWeatherBoss then
            selectedList = {state.SelectedWeatherBoss}
        end

        if state.AutoWeatherBoss and #selectedList > 0 then
            local currentServerWeather = workspace:GetAttribute("Weather") or "Clear"
            local matchedBossName, bossInfo = findMatchedWeatherBoss(currentServerWeather, currentFishingLocation.Name)

            if matchedBossName and bossInfo then
                local targetIsland = bossInfo.Island
                currentHuntingBoss = matchedBossName
                activeWeatherBossTargets = getActiveBossTargetsOnIsland(targetIsland, currentServerWeather)

                -- Ghép danh sách tên các boss đang có thể câu trên đảo này
                local bossNamesOnIsland = {}
                for bName in pairs(activeWeatherBossTargets) do
                    table.insert(bossNamesOnIsland, bName)
                end
                local bossDisplay = table.concat(bossNamesOnIsland, ", ")

                -- Nếu chuyển sang đảo mới hoặc vừa bắt đầu săn
                if not weatherBossActive or currentFishingLocation.Name ~= targetIsland then
                    if not weatherBossActive then
                        weatherBossLastIsland = currentFishingLocation.Name or state.SelectedIsland or "Beginning Isle"
                    end
                    weatherBossActive = true
                    setWeatherBossStatus("⚡ [" .. currentServerWeather .. "] Bay tới " .. targetIsland .. " săn: " .. bossDisplay .. "...")
                    currentFishingLocation = { Type = "Island", Name = targetIsland }
                    teleportToIslandShore(targetIsland)
                    task.wait(2)
                else
                    currentFishingLocation = { Type = "Island", Name = targetIsland }
                    setWeatherBossStatus("🎣 [" .. currentServerWeather .. "] Đang câu: " .. bossDisplay .. " tại " .. targetIsland)
                end
                weatherBossWantsFishing = true
            else
                -- Không có boss nào trong danh sách đã chọn trùng thời tiết hiện tại
                if weatherBossActive then
                    weatherBossActive = false
                    weatherBossWantsFishing = false
                    currentHuntingBoss = nil
                    activeWeatherBossTargets = {}

                    if state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                        setWeatherBossStatus("🌤️ Hết thời tiết boss (hiện tại: " .. currentServerWeather .. ") -> Trả quyền cho Auto Quest...")
                        task.wait(1)
                    else
                        local returnIsland = weatherBossLastIsland or state.SelectedIsland or "Beginning Isle"
                        setWeatherBossStatus("🌤️ Hết thời tiết boss (hiện tại: " .. currentServerWeather .. ") -> Quay về: " .. returnIsland)
                        currentFishingLocation = { Type = "Island", Name = returnIsland }
                        teleportToIslandShore(returnIsland)
                        task.wait(2)
                    end
                else
                    currentHuntingBoss = nil
                    activeWeatherBossTargets = {}
                    weatherBossWantsFishing = false

                    -- Hiển thị thông báo trạng thái chờ
                    if #selectedList == 1 then
                        local bInfo = WeatherFishDatabase[selectedList[1]]
                        local reqW = bInfo and bInfo.Weather or "thời tiết đặc biệt"
                        setWeatherBossStatus("⏳ Chờ thời tiết: " .. reqW .. " cho " .. selectedList[1] .. " (Hiện tại: " .. currentServerWeather .. ")")
                    else
                        setWeatherBossStatus("⏳ Đang chờ thời tiết cho " .. #selectedList .. " boss đã chọn (Hiện tại: " .. currentServerWeather .. ")")
                    end
                end
            end
        else
            if weatherBossActive then
                weatherBossActive = false
                weatherBossWantsFishing = false
                currentHuntingBoss = nil
                activeWeatherBossTargets = {}

                if state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                    setWeatherBossStatus("🔴 Đã tắt săn boss thời tiết. Trả quyền cho Auto Quest...")
                else
                    local returnIsland = weatherBossLastIsland or state.SelectedIsland or "Beginning Isle"
                    setWeatherBossStatus("🔴 Đã tắt săn boss thời tiết. Quay về: " .. returnIsland)
                    currentFishingLocation = { Type = "Island", Name = returnIsland }
                    teleportToIslandShore(returnIsland)
                end
            end
        end
    end
end)

--// 🛡️ ULTRA ANTI-AFK & AUTO RECONNECT (Chống văng 20 phút 100% Bulletproof)
task.spawn(function()
    local getcons = getconnections or get_signal_cons

    -- Hàm vô hiệu hóa triệt để Idled connections từ Roblox CoreScript
    local function disableIdledConnections()
        pcall(function()
            if getcons then
                for _, conn in ipairs(getcons(player.Idled)) do
                    if typeof(conn) == "RBXScriptConnection" or type(conn) == "table" or type(conn) == "userdata" then
                        if conn.Disable then
                            conn:Disable()
                        elseif conn.Disconnect then
                            conn:Disconnect()
                        end
                        if conn.Enabled ~= nil then
                            conn.Enabled = false
                        end
                    end
                end
            end
        end)
    end

    -- Chạy ngay và chạy lặp lại các giây đầu để chặn CoreScript load chậm
    disableIdledConnections()
    task.delay(3, disableIdledConnections)
    task.delay(10, disableIdledConnections)
    task.delay(30, disableIdledConnections)

    -- Lớp 2: Lắng nghe sự kiện Idled và phản hồi tức thì
    player.Idled:Connect(function()
        disableIdledConnections()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            local cam = workspace.CurrentCamera
            if cam then
                VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
                task.wait(0.15)
                VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
            end
        end)
        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(math.random(20, 400), math.random(20, 400), game)
        end)
    end)

    -- Lớp 3: Giả lập input định kỳ mỗi 15-25s (Không làm gián đoạn câu cá)
    while _G.FishingMasterSession == currentSession do
        task.wait(math.random(15, 25))
        disableIdledConnections()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
        pcall(function()
            local rx = math.random(50, 500)
            local ry = math.random(50, 500)
            VirtualInputManager:SendMouseMoveEvent(rx, ry, game)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
        end)
    end
end)

-- Lớp 4: Tự động Reconnect dự phòng nếu server bảo trì / mất mạng
pcall(function()
    local TeleportService = game:GetService("TeleportService")
    GuiService.ErrorMessageChanged:Connect(function()
        task.wait(1.5)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
        task.wait(3)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end)

task.wait(0.5)
if Window and Window.Close then
    pcall(function() Window:Close() end)
end
print("✅ Loaded (Full Auto Minigames: Slam, Charge, Rhythm, Boss Fight Active)!")
