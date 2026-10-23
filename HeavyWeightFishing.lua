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
local myPlayerHealthTag = tostring(pId) .. "_PlayerHealth"
local pGui = player:WaitForChild("PlayerGui")
local mainGui = pGui:WaitForChild("MainGui")

local function getMainGui()
    if mainGui and mainGui.Parent then
        return mainGui
    end
    mainGui = pGui:FindFirstChild("MainGui") or pGui:WaitForChild("MainGui", 2)
    return mainGui
end

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
    CustomFarmPos = nil, -- {X = 0, Y = 0, Z = 0}
    -- Ticket Quest
    AutoTicketQuest = false,
    TicketHardMode = true,
    -- Daily Quest
    AutoDailyQuest = false,
    -- Essence Orb (Zeng Tianguo Quest)
    AutoEssenceOrb = false,
    -- Fast Bait Quest
    FastBaitQuest = true,
    -- Fish Filter
    FishFilterEnabled = false,
    SelectedFishFilter = {},
    SelectedFishList = {},
    -- Weather Boss Hunter
    AutoWeatherBoss = false,
    SelectedWeatherBoss = "Flame Fish",
    SelectedWeatherBossList = {"Flame Fish"},
    SelectedWeatherBosses = {["Flame Fish"] = true},
    -- Settings (Giảm Đồ Họa)
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
local DEFAULT_BOSS_ISLAND = "Beginning Isle"
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

-- Khôi phục điểm câu tùy chỉnh từ cấu hình đã lưu
if state.CustomFarmPos and type(state.CustomFarmPos) == "table" and state.CustomFarmPos.X then
    CUSTOM_FARM_POS = Vector3.new(state.CustomFarmPos.X, state.CustomFarmPos.Y, state.CustomFarmPos.Z)
end

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
    ["Flame Fish"] = {Island = "Weather Isle", Weather = "Blazing Sun"},
    ["Aquatic Fish"] = {Island = "Weather Isle", Weather = "Rainy"},
    ["Thunder Fish"] = {Island = "Weather Isle", Weather = "Thunderstorm"},
    ["Wind Fish"] = {Island = "Weather Isle", Weather = "Windy"},
    ["Colossal Bull Shark"] = {Island = "Mystic Reef Isle", Weather = "Thunderstorm"},
    ["Crimson Electric Eel"] = {Island = "Bamboo Isle", Weather = "Thunderstorm"},
    ["Dark Lionfish"] = {Island = "Mistpeak Isle", Weather = "Rainy"},
    ["Draconic Koi"] = {Island = "Amber Isle", Weather = "Blazing Sun"},
    ["Golden Dragonfish"] = {Island = "Amber Isle", Weather = "Blazing Sun"},
    ["Sanguine Fish"] = {Island = "Amber Isle", Weather = "Blazing Sun"},
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
local localCharacter = player.Character or workspace:FindFirstChild(player.Name)
player.CharacterAdded:Connect(function(char)
    localCharacter = char
end)
player.CharacterRemoving:Connect(function()
    localCharacter = nil
end)

local cachedPlayerData = nil
local function getPlayerData()
    if cachedPlayerData and cachedPlayerData.Parent then
        return cachedPlayerData
    end
    local dataFolder = ReplicatedStorage:FindFirstChild("Data")
    if dataFolder then
        local pData = dataFolder:FindFirstChild(tostring(pId))
        if pData then
            cachedPlayerData = pData
            return cachedPlayerData
        end
    end
    local ok, res = pcall(function()
        return ReplicatedStorage:WaitForChild("Data", 3):WaitForChild(tostring(pId), 3)
    end)
    if ok and res then
        cachedPlayerData = res
        return cachedPlayerData
    end
    return nil
end

local function getCharacter()
    if localCharacter and localCharacter.Parent then
        return localCharacter
    end
    localCharacter = player.Character or workspace:FindFirstChild(player.Name)
    return localCharacter
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

local function unequipRod()
    if not isHoldingRod() then return end
    local events = ReplicatedStorage:WaitForChild("Events")
    local hotbarRemote = events:WaitForChild("ToggleHotbar")
    pcall(function()
        hotbarRemote:InvokeServer("1", nil)
    end)
    task.wait(0.2)
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

--// 🌊 HÀM KIỂM TRA BỜ BIỂN HỢP LỆ (LOẠI TRỪ 100% CÁC HỐ NƯỚC NHỎ, AO, VŨNG NƯỚC NỘI ĐỊA)
local function isValidOceanShoreSpot(standPos, dir, waterLevel, rayParams, origin)
    -- 1. Khoảng cách tới tâm đảo: bỏ qua các vũng ao trung tâm đảo
    local distToSpawn = (standPos - origin).Magnitude
    if distToSpawn < 25 then
        return false
    end

    -- 2. Kiểm tra mặt đất dưới chân chỗ đứng
    local groundRay = workspace:Raycast(standPos + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), rayParams)
    if not groundRay then return false end

    local groundY = groundRay.Position.Y
    -- Đất phải cao hơn mặt nước biển ít nhất 1.0 studs, nhưng không được là vách núi quá cao (> 22 studs)
    if groundY < (waterLevel + 1.0) or groundY > (waterLevel + 22) then
        return false
    end

    -- 3. Kiểm tra đất phía sau lưng (hướng về tâm đảo 8 studs): phải có nền đất vững chắc của hòn đảo
    local backPos = standPos - dir * 8 + Vector3.new(0, 5, 0)
    local backRay = workspace:Raycast(backPos, Vector3.new(0, -15, 0), rayParams)
    if not backRay or backRay.Position.Y < (waterLevel + 0.8) then
        return false
    end

    -- 4. KIỂM TRA MẶT NƯỚC PHÍA TRƯỚC MẶT (BẮT BUỘC LÀ ĐẠI DƯƠNG RỘNG MỞ, KHÔNG PHẢI HỐ/AO NHỎ)
    -- Nếu là hố nước nhỏ / ao suối trong lòng đảo:
    -- Chỉ cần đi ra trước mặt 15 - 45 studs là sẽ va phải bờ đất phía bên kia của cái hố!
    -- Biển lớn thật sự thì phía trước mặt 18m, 40m, 70m ĐỀU LÀ NƯỚC BIỂN MÊNH MÔNG (không có đất nổi lên)!
    local checkDists = {18, 40, 70}
    for _, fDist in ipairs(checkDists) do
        local forwardSample = standPos + dir * fDist + Vector3.new(0, 15, 0)
        local fHit = workspace:Raycast(forwardSample, Vector3.new(0, -45, 0), rayParams)

        if fHit then
            -- Nếu phát hiện có vật thể/đất nổi cao hơn mặt nước biển -> Bị chắn bởi bờ đất hoặc vách đá bên kia!
            if fHit.Position.Y > (waterLevel + 1.5) then
                return false -- ❌ Đây là hố nước/ao nhỏ hoặc bị chắn bờ đối diện!
            end

            -- Nếu trúng Part nước: kiểm tra kích thước Part nước đó
            local hitPart = fHit.Instance
            if hitPart and hitPart:IsA("BasePart") then
                -- Nếu là part nước có kích thước quá nhỏ (vũng nước/puddle nhân tạo)
                if hitPart.Size.X < 20 and hitPart.Size.Z < 20 then
                    return false -- ❌ Vũng nước nhỏ
                end
            end
        end
    end

    -- 5. Kiểm tra tầm ném cần ngang ngực người chơi ra 25 studs xem có vách đá dựng đứng chắn không
    local chestRay = workspace:Raycast(standPos + Vector3.new(0, 2.5, 0), dir * 25, rayParams)
    if chestRay and chestRay.Position.Y > (waterLevel + 1.5) then
        return false -- ❌ Vách đá chắn tầm ném
    end

    return true
end

--// 🌊 MULTI-SHORELINE ENGINE (TỰ ĐỘNG DÒ TÌM BỜ BIỂN ĐẠI DƯƠNG, BỎ QUA HỐ NƯỚC NHỎ)
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
        if waterLevel == 0 then
            local anyWater = ocean:FindFirstChildWhichIsA("BasePart", true)
            if anyWater then
                waterLevel = anyWater.Position.Y + (anyWater.Size.Y * 0.5)
            end
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {}
    local char = getCharacter()
    if char then table.insert(filterList, char) end
    local fishes = workspace:FindFirstChild("Fishes")
    if fishes then table.insert(filterList, fishes) end
    local boat = workspace:FindFirstChild("Boat")
    if boat then table.insert(filterList, boat) end
    rayParams.FilterDescendantsInstances = filterList

    local spots = {}

    -- Quét 16 góc quay quanh hòn đảo (mỗi góc 22.5 độ)
    for angleDeg = 0, 337.5, 22.5 do
        local rad = math.rad(angleDeg)
        local dir = Vector3.new(math.cos(rad), 0, math.sin(rad))
        local foundSpot = nil

        -- PHƯƠNG PHÁP 1: QUÉT TỪ NGOÀI ĐẠI DƯƠNG VÀO TÂM ĐẢO (Reverse Scan từ 420 studs về 30 studs)
        -- Quét từ đại dương xa đi vào đất liền sẽ gặp mép đất NGOÀI CÙNG của đảo đầu tiên.
        -- Đảm bảo tuyệt đối không bao giờ bị dừng lại ở các hố nước hay vũng ao trong lòng đảo!
        for dist = 420, 30, -10 do
            local samplePos = origin + dir * dist + Vector3.new(0, 30, 0)
            local hit = workspace:Raycast(samplePos, Vector3.new(0, -80, 0), rayParams)

            if hit and hit.Position.Y > (waterLevel + 1.2) then
                local candidatePos = hit.Position + Vector3.new(0, 3.2, 0)
                if isValidOceanShoreSpot(candidatePos, dir, waterLevel, rayParams, origin) then
                    local lookTarget = candidatePos + dir * 30
                    foundSpot = CFrame.lookAt(candidatePos, Vector3.new(lookTarget.X, candidatePos.Y, lookTarget.Z))
                    break
                end
            end
        end

        -- PHƯƠNG PHÁP 2: Nếu quét ngoài vào không tìm thấy, quét từ trong ra ngoài kết hợp bộ lọc đại dương
        if not foundSpot then
            local lastLand = nil
            for dist = 30, 380, 10 do
                local samplePos = origin + dir * dist + Vector3.new(0, 30, 0)
                local hit = workspace:Raycast(samplePos, Vector3.new(0, -80, 0), rayParams)
                if hit and hit.Position.Y > (waterLevel + 1.2) then
                    lastLand = hit.Position
                else
                    if lastLand then
                        local candidatePos = lastLand + Vector3.new(0, 3.2, 0)
                        if isValidOceanShoreSpot(candidatePos, dir, waterLevel, rayParams, origin) then
                            local lookTarget = candidatePos + dir * 30
                            foundSpot = CFrame.lookAt(candidatePos, Vector3.new(lookTarget.X, candidatePos.Y, lookTarget.Z))
                            break
                        end
                    end
                end
            end
        end

        if foundSpot then
            table.insert(spots, foundSpot)
        end
    end

    -- Fallback nếu không quét được điểm nào: tạo các điểm an toàn quanh Spawn hướng ra xa
    if #spots == 0 then
        for angleDeg = 0, 315, 90 do
            local rad = math.rad(angleDeg)
            local dir = Vector3.new(math.cos(rad), 0, math.sin(rad))
            local standPos = origin + dir * 45 + Vector3.new(0, 4, 0)
            local lookTarget = standPos + dir * 30
            table.insert(spots, CFrame.lookAt(standPos, Vector3.new(lookTarget.X, standPos.Y, lookTarget.Z)))
        end
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
            unequipRod()
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
        unequipRod()
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
            unequipRod()
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
    unequipRod()
    if currentFishingLocation.Type == "Boss" then
        if currentFishingLocation.Name then
            teleportToIslandShore(currentFishingLocation.Name, true)
        else
            teleportToIslandShore(state.SelectedIsland or "Beginning Isle", true)
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

        local data = getPlayerData()
        if not data then return end

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
            Destination = state.SelectedIsland or "Beginning Isle",
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

    if CUSTOM_FARM_POS then
        return {
            TargetType = "Default",
            Destination = "Điểm câu tùy chỉnh",
            Position = CUSTOM_FARM_POS,
            CanFishNow = true
        }
    else
        return {
            TargetType = "Island",
            Destination = state.SelectedIsland or "Beginning Isle",
            CanFishNow = true
        }
    end
end

local function travelToFarmSpot()
    if CUSTOM_FARM_POS then
        currentFishingLocation = {
            Type = "Default",
            Name = "Điểm câu tùy chỉnh",
            Position = CUSTOM_FARM_POS
        }
        teleportToPos(CUSTOM_FARM_POS)
    else
        local farmIsland = state.SelectedIsland or "Beginning Isle"
        currentFishingLocation = {
            Type = "Island",
            Name = farmIsland
        }
        teleportToIslandShore(farmIsland)
    end
end

local function travelToQuestSpot(targetData)
    currentFishingLocation = {
        Type = targetData.TargetType,
        Name = targetData.Destination,
        Position = targetData.Position
    }
    if targetData.TargetType == "Boss" then
        local targetIsl = targetData.Destination or state.SelectedIsland or "Beginning Isle"
        currentFishingLocation = {
            Type = "Island",
            Name = targetIsl
        }
        teleportToIslandShore(targetIsl)
    elseif targetData.TargetType == "Default" then
        local pos = targetData.Position or CUSTOM_FARM_POS
        if pos then
            teleportToPos(pos)
        else
            teleportToIslandShore(state.SelectedIsland or "Beginning Isle")
        end
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
    -- 1. Ưu tiên tra cứu trực tiếp qua FishID của LocalPlayer (chuẩn ClientModule Fishing, tức thì cho cả Boss Enzo & Long Diaohai)
    local fishId = player:GetAttribute("FishID")
    if fishId and fishId ~= "" then
        local target = fishes:FindFirstChild(fishId)
        if target then return target end
    end
    local children = fishes:GetChildren()
    -- 2. Tra cứu trực tiếp O(1) qua tên chính xác UserId_PlayerHealth
    for _, f in ipairs(children) do
        if f:FindFirstChild(myPlayerHealthTag) then
            return f
        end
    end
    -- 3. Fallback dự phòng trường hợp game đổi tiền tố
    for _, f in ipairs(children) do
        for _, c in ipairs(f:GetChildren()) do
            if string.find(c.Name, tostring(pId)) and string.find(c.Name, "PlayerHealth") then
                return f
            end
        end
    end
    return nil
end

-- Hàm xác định người chơi có đang trong một trận kéo cá / đánh Boss hay không
local function isPlayerInFishingFight()
    -- 1. Ưu tiên kiểm tra FishID từ LocalPlayer attribute (chuẩn ClientModule, tức thì khi câu cá hoặc đánh Boss Enzo/Long Diaohai)
    local fishId = player:GetAttribute("FishID")
    if fishId and fishId ~= "" then
        return true
    end

    -- 2. Kiểm tra UI Fishing đang mở
    local mGui = getMainGui()
    local fGui = mGui and mGui:FindFirstChild("Fishing")
    if fGui and fGui.Visible then
        local bBar = fGui:FindFirstChild("BossFightBar")
        if bBar and bBar.Visible then return true end
        local pBar = fGui:FindFirstChild("ProgressionBar")
        if pBar and pBar.Visible then return true end
        local rBar = fGui:FindFirstChild("Rhythm")
        if rBar and rBar.Visible then return true end
        return true
    end

    -- 3. Kiểm tra đối tượng cá / boss trong workspace.Fishes
    if findMyFish() then
        return true
    end

    -- 4. Kiểm tra character attribute
    local char = getCharacter()
    if char then
        if char:GetAttribute("Phase2") == true or char:GetAttribute("Fishing") == true then
            return true
        end
    end

    return false
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
    local data = getPlayerData()
    if not data then return 0 end
    local cd = data:FindFirstChild("TicketQuestCooldown")
    if not cd then return 0 end
    local rem = cd.Value - workspace:GetServerTimeNow()
    return math.max(0, math.floor(rem))
end

local function getActiveTicketQuestInfo()
    local data = getPlayerData()
    if not data then return nil end
    
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
    local data = getPlayerData()
    if not data then return nil end

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
    local data = getPlayerData()
    if not data then return nil end
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
    local data = getPlayerData()
    if not data then return end
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

-- Hàm kiểm tra xem có đang làm nhiệm vụ dùng mồi (Use Bait) và đủ điều kiện skip kéo cá hay không
local function shouldFastSkipForBaitQuest()
    if not state.FastBaitQuest then return false end

    -- 1. Tuyệt đối không skip nếu đang săn Boss Thời Tiết
    if state.AutoWeatherBoss and weatherBossActive then
        return false
    end

    -- 2. Kiểm tra Daily Quest (Nhiệm vụ mồi thường là task 3)
    if state.AutoDailyQuest then
        local dStatus = getDailyQuestStatus()
        -- Nếu Daily Quest đang cần mồi và KHÔNG cần Boss hay câu cá cụ thể khác
        if dStatus and dStatus.NeedBait and not dStatus.NeedFishing and not dStatus.NeedBoss then
            return true
        end
    end

    -- 3. Kiểm tra Ticket Quest
    if state.AutoTicketQuest then
        local qInfo = getActiveTicketQuestInfo()
        if qInfo and not qInfo.IsCompleted and qInfo.Text then
            local lower = string.lower(qInfo.Text)
            if string.find(lower, "use bait") or string.find(lower, "bait") then
                -- Kiểm tra xem có yêu cầu bắt cá (catch fish) nào chưa hoàn thành không
                local needsCatch = false
                local parts = string.split(qInfo.Text, "|")
                for _, part in ipairs(parts) do
                    local pLower = string.lower(part)
                    if not string.find(pLower, "bait") then
                        local cur, maxVal = part:match("(%d+)/(%d+)")
                        if cur and maxVal and tonumber(cur) < tonumber(maxVal) then
                            needsCatch = true
                            break
                        end
                    end
                end
                if not needsCatch then
                    return true
                end
            end
        end
    end

    -- 4. Kiểm tra Zeng Tianguo Quest (Essence Orb)
    if state.AutoEssenceOrb then
        local qInfo = getActiveZengQuestInfo()
        if qInfo and not qInfo.IsCompleted and qInfo.Text then
            local lower = string.lower(qInfo.Text)
            if string.find(lower, "use bait") or (string.find(lower, "bait") and not string.find(lower, "catch") and not string.find(lower, "fish")) then
                return true
            end
        end
    end

    return false
end

--// HỆ THỐNG GIẢM ĐỒ HỌA
local Lighting = game:GetService("Lighting")
local graphicsConn = nil

local OPTIMIZE_CLASSES = {
    Part = true, MeshPart = true, UnionOperation = true, BasePart = true,
    Decal = true, Texture = true, SurfaceAppearance = true,
    ParticleEmitter = true, Trail = true, Beam = true, Smoke = true,
    Fire = true, Sparkles = true, Highlight = true, SpecialMesh = true,
    Model = true, Sound = true
}

local function isProtectedInstance(v)
    if not v or not v.Parent then return true end
    
    -- 1. Kiểm tra nhân vật của mình
    local myChar = getCharacter()
    if myChar and (v == myChar or v:IsDescendantOf(myChar)) then
        return true
    end

    -- 2. Kiểm tra nếu thuộc nhân vật người chơi khác hoặc NPC có Humanoid
    local model = v:IsA("Model") and v or v:FindFirstAncestorOfClass("Model")
    if model then
        if model:FindFirstChildOfClass("Humanoid") then
            return true
        end
        local mName = string.lower(model.Name)
        if mName == "npc" or mName == "spawnpoint" or mName == "fishes" or mName == "boat" then
            return true
        end
    end

    -- 3. Kiểm tra các thư mục đặc biệt quan trọng
    local pName = v.Parent and v.Parent.Name or ""
    if pName == "NPC" or pName == "Spawnpoint" or pName == "Fishes" or pName == "Boat" or pName == "Ocean" then
        return true
    end

    if v:IsA("BasePart") and (v.Name == "Water" or v:GetAttribute("WaterType")) then
        return true
    end
    if v:IsA("Terrain") then
        return true
    end

    return false
end

local DECOR_KEYWORDS = {
    "tree", "leaves", "leaf", "trunk", "branch", "bark", "wood",
    "bush", "bushes", "plant", "plants", "grass", "flower", "flowers",
    "foliage", "flora", "vegetation", "bamboo", "mushroom", "vine",
    "decor", "decoration", "decorations", "prop", "props", "detail", "details",
    "rock", "rocks", "stone", "boulder", "pebble", "pebbles",
    "fence", "bench", "lamp", "lantern", "streetlamp", "torch", "statue",
    "coral", "seaweed", "kelp", "grasspatch", "flowerbed", "clutter",
    "house", "building", "roof", "pillar", "gate", "bridge", "barrel", "box", "crate"
}

local function isDecorOrFoliage(v)
    if not (v:IsA("BasePart") or v:IsA("Model")) then return false end

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

    for _, kw in ipairs(DECOR_KEYWORDS) do
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
            if OPTIMIZE_CLASSES[v.ClassName] then
                optimizeObj(v)
            end
        end

        graphicsConn = workspace.DescendantAdded:Connect(function(v)
            if _G.FishingMasterSession ~= currentSession then
                if graphicsConn then graphicsConn:Disconnect() end
                return
            end
            if not OPTIMIZE_CLASSES[v.ClassName] then
                return
            end
            optimizeObj(v)
        end)
    end
end

-- Tự động áp dụng cài đặt lưu từ trước nếu có
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
            currentFishingLocation = { Type = "Island", Name = state.SelectedIsland or "Beginning Isle" }
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
            currentFishingLocation = { Type = "Island", Name = state.SelectedIsland or "Beginning Isle" }
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
            currentFishingLocation = { Type = "Island", Name = state.SelectedIsland or "Beginning Isle" }
            setEssenceStatus("🔴 Đã tắt Auto Essence Orb.")
        end
    end
})

TabQuest:Toggle({
    Title = "⚡ Siêu Tốc Nhiệm Vụ Mồi (Cắn câu là hủy & ném lại)",
    Value = state.FastBaitQuest,
    Callback = function(v)
        state.FastBaitQuest = v
        save()
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
    Title = "Đặt vị trí hiện tại làm điểm câu (Ưu tiên Farm)",
    Callback = function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            CUSTOM_FARM_POS = char.HumanoidRootPart.Position
            state.CustomFarmPos = {
                X = math.floor(CUSTOM_FARM_POS.X),
                Y = math.floor(CUSTOM_FARM_POS.Y),
                Z = math.floor(CUSTOM_FARM_POS.Z)
            }
            save()
            local msg = "📍 Đã lưu điểm câu tùy chỉnh: " .. state.CustomFarmPos.X .. ", " .. state.CustomFarmPos.Y .. ", " .. state.CustomFarmPos.Z
            setTicketStatus(msg)
            setEssenceStatus(msg)
        end
    end
})

TabQuest:Button({
    Title = "Hủy điểm câu tùy chỉnh (Quay về dùng Đảo farm)",
    Callback = function()
        CUSTOM_FARM_POS = nil
        state.CustomFarmPos = nil
        save()
        local msg = "🔄 Đã hủy điểm câu tùy chỉnh. Farm tại: " .. (state.SelectedIsland or "Beginning Isle")
        setTicketStatus(msg)
        setEssenceStatus(msg)
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
            unequipRod()
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

--// SETTINGS TAB (GIẢM ĐỒ HỌA)
TabSettings:Section({Title = "Giảm Đồ Họa"})

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
        applyGraphicsReduction(state.GraphicsLevel or "Tắt")
    end
})

--// LOOPS & LOGIC

-- 1 & 2. AUTO MINIGAMES ENGINE (LOCK BAR, SLAM & CHARGE, RHYTHM, BOSS PHASE 2)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local rhythmHitRem = events:FindFirstChild("RhythmHit")
    local bossActionRem = events:FindFirstChild("BossPhase2Action")
    local mobileFishingBtn = mainGui:WaitForChild("Mobile"):WaitForChild("Fishing")
    local fishingFrame = mainGui:WaitForChild("Fishing")
    local trashCan = fishingFrame:WaitForChild("TrashCan")
    local rhythmFrame = fishingFrame:FindFirstChild("Rhythm")
    local bossFightBar = fishingFrame:FindFirstChild("BossFightBar")
    local bar = fishingFrame:WaitForChild("BarFrame"):WaitForChild("Bar")

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

    -- [C & D]: Xử lý LockBar, Rhythm Minigame & Boss Fight Bar qua một RenderStepped duy nhất
    local lastRhythmHit = 0
    local lastBossHit = 0
    local bossHitCooldown = 0.10

    -- Cache Rhythm
    local rhythmMissCount = 0
    local isRhythmActive = false
    local ignoredRhythmNotes = {}
    local cachedRhythmLanes = {}

    -- Cache Boss Phase 2
    local bossMissCount = 0
    local isBossActive = false
    local bossCycleMissed = false
    local lastBarDir = 1
    local prevBarX = 0
    local bossHitIndex = 1
    local lastHitboxPos = nil
    local cachedBossBar = nil
    local cachedBossHitbox = nil
    local cachedBossBadHitbox = nil

    local miniConn
    miniConn = RunService.RenderStepped:Connect(function()
        if _G.FishingMasterSession ~= currentSession then
            miniConn:Disconnect()
            return
        end

        -- 1. Lock Bar
        if state.LockBar and bar and bar.Visible then
            bar.Position = UDim2.fromScale(0.5, 0.5)
        end

        local rhythmActive = state.AutoRhythm and rhythmFrame and rhythmFrame.Visible
        local bossActive = state.AutoBossPhase2 and bossFightBar and bossFightBar.Visible

        -- Nếu cả 2 minigame đều không bật/hiển thị -> thoát ngay lập tức (tiết kiệm CPU tối đa)
        if not rhythmActive and not bossActive then
            isRhythmActive = false
            isBossActive = false
            return
        end

        local isSafe = (state.MinigameMode ~= "Fast")

        -- [C] Auto Rhythm Minigame (Nốt nhạc Boss)
        if rhythmActive then
            if not isRhythmActive then
                isRhythmActive = true
                rhythmMissCount = 0
                ignoredRhythmNotes = {}
                cachedRhythmLanes = {}
                for _, lane in ipairs(rhythmFrame:GetChildren()) do
                    if string.find(lane.Name, "Progression") then
                        local barF = lane:FindFirstChild("BarFrame")
                        table.insert(cachedRhythmLanes, {
                            Lane = lane,
                            TargetY = barF and barF.Position.Y.Scale or 0.85,
                            Key = laneKeyMap[lane.Name]
                        })
                    end
                end
            end

            local now = tick()
            local rhythmCooldown = 0.20

            for _, laneData in ipairs(cachedRhythmLanes) do
                local lane = laneData.Lane
                local targetY = laneData.TargetY
                local keyCode = laneData.Key

                for _, child in ipairs(lane:GetChildren()) do
                    if child.Name == "Note_FX" and child.Visible then
                        local curY = child.Position.Y.Scale
                        -- Bỏ qua nốt bẫy (màu đỏ)
                        local bg = child.BackgroundColor3
                        local isTrap = (bg.R > 0.75 and bg.G < 0.45 and bg.B < 0.45)
                        if not isTrap and (child:IsA("ImageLabel") or child:IsA("ImageButton")) then
                            local ic = child.ImageColor3
                            if ic.R > 0.75 and ic.G < 0.45 and ic.B < 0.45 then
                                isTrap = true
                            end
                        end

                        if isTrap then
                            ignoredRhythmNotes[child] = true
                        else
                            local hitRangeMin = isSafe and (targetY - 0.08) or (targetY - 0.05)
                            local hitRangeMax = isSafe and (targetY + 0.10) or (targetY + 0.14)

                            if curY >= hitRangeMin and curY <= hitRangeMax then
                                if not ignoredRhythmNotes[child] then
                                    if not isSafe then
                                        ignoredRhythmNotes[child] = true
                                        if rhythmHitRem then
                                            rhythmHitRem:FireServer("hit")
                                        end
                                        hitRhythm(lane, keyCode)
                                    else
                                        if rhythmMissCount < 3 and math.random(1, 8) == 1 then
                                            rhythmMissCount = rhythmMissCount + 1
                                            ignoredRhythmNotes[child] = true
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
        else
            isRhythmActive = false
        end

        -- [D] Auto Boss Fight Bar (Boss Phase 2)
        if bossActive then
            if not isBossActive then
                isBossActive = true
                bossMissCount = 0
                bossCycleMissed = false
                prevBarX = 0
                bossHitIndex = 1
                lastHitboxPos = nil
                cachedBossBar = bossFightBar:FindFirstChild("Bar")
                cachedBossHitbox = bossFightBar:FindFirstChild("Hitbox")
                cachedBossBadHitbox = bossFightBar:FindFirstChild("HitboxBad")
            end

            local bBar = cachedBossBar
            local hitbox = cachedBossHitbox
            local badHitbox = cachedBossBadHitbox

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
                    bossCycleMissed = false
                end
                prevBarX = realBarCenter

                local minX, maxX
                if isSafe then
                    minX = realHbLeft + hbSizeX * 0.20
                    maxX = realHbRight - hbSizeX * 0.20
                else
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
                            if bossMissCount < 3 and not bossCycleMissed and math.random(1, 6) == 1 then
                                bossMissCount = bossMissCount + 1
                                bossCycleMissed = true
                            elseif not bossCycleMissed and tick() - lastBossHit >= bossHitCooldown then
                                lastBossHit = tick()
                                bossHitCooldown = math.random(10, 15) / 100
                                doVimClick(mobileFishingBtn)
                            end
                        else
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

-- ==============================================================================
-- 4. AUTO SKILL & COMBAT ENGINE (Normal Fishing, Weather Bosses & Special Bosses Enzo, Long Diaohai)
-- ==============================================================================

local cachedSkillButtons = {}
local function getSkillButton(key)
    local data = cachedSkillButtons[key]
    if data and data.Btn and data.Btn.Parent then
        return data
    end
    local mGui = getMainGui()
    local fGui = mGui and mGui:FindFirstChild("Fishing")
    local sFrame = fGui and fGui:FindFirstChild("SkillButton") and fGui.SkillButton:FindFirstChild("Frame")
    local btn = sFrame and sFrame:FindFirstChild(key)
    if btn then
        cachedSkillButtons[key] = {
            Btn = btn,
            CD = btn:FindFirstChild("CD")
        }
        return cachedSkillButtons[key]
    end
    return nil
end

-- Hàm kiểm tra kỹ năng Z, X, C, V có đang sẵn sàng (dùng được) hay đang hồi chiêu (cooldown)
local function isSkillReady(key, currentChar)
    local char = currentChar or getCharacter()
    if not char then return false end

    -- Không dùng skill nếu character đang bị khóa chiêu toàn cục (stun / debuff từ server)
    if char:GetAttribute("SkillLocked") == true then
        return false
    end

    -- 1. Kiểm tra trên UI SkillButton.Frame (O(1) từ cache)
    local btnData = getSkillButton(key)
    if btnData then
        -- Nếu nút bị ẩn (cần câu không trang bị chiêu ở slot này) -> bỏ qua
        if btnData.Btn and btnData.Btn.Visible == false then
            return false
        end
        -- Nếu đang đếm ngược hồi chiêu -> bỏ qua
        if btnData.CD and btnData.CD.Visible == true then
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
                break
            end
        end
    end

    return true
end

-- Hàm lấy % máu hiện tại của người chơi khi đang kéo cá / đánh Boss
local cachedFishingGui = nil
local function getPlayerFishingHealthPercent(fishObj, cachedHealthVal, cachedMaxHp)
    -- 1. Đọc trực tiếp từ con trỏ đã cache khi cá cắn câu
    if cachedHealthVal and cachedMaxHp and cachedMaxHp > 0 then
        return (cachedHealthVal.Value / cachedMaxHp) * 100
    end

    -- 2. Tra cứu NumberValue PlayerHealth trực tiếp qua tag O(1)
    local target = fishObj or findMyFish()
    if target then
        local child = cachedHealthVal or target:FindFirstChild(myPlayerHealthTag)
        if child and child:IsA("NumberValue") then
            local maxHp = cachedMaxHp or child:GetAttribute("MaxHP")
            if not maxHp or maxHp <= 0 then
                local mGui = getMainGui()
                local fGui = mGui and mGui:FindFirstChild("Fishing")
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

    -- 3. Đọc từ UI HPPlayer của Fishing GUI
    local mGui = getMainGui()
    local hpPlayer = mGui and mGui:FindFirstChild("Fishing") and mGui.Fishing:FindFirstChild("HPPlayer")
    if hpPlayer and hpPlayer.Visible then
        local progBar = hpPlayer:FindFirstChild("ProgressionBar")
        local bar = progBar and progBar:FindFirstChild("Bar")
        if bar then
            local scale = math.clamp(bar.Size.X.Scale, 0, 1)
            return scale * 100
        end
    end

    -- 4. Fallback theo Humanoid
    local char = getCharacter()
    local hum = char and char:FindFirstChild("Humanoid")
    if hum and hum.MaxHealth > 0 then
        return (hum.Health / hum.MaxHealth) * 100
    end

    return 100
end

-- Kiểm tra trạng thái không thể hồi máu (Poisoned) theo đúng mã nguồn game Fishing Master
local function isPlayerHealBlocked(currentChar)
    local char = currentChar or getCharacter()
    if char and char:GetAttribute("Poisoned") == true then
        return true
    end

    local mGui = getMainGui()
    local fGui = mGui and mGui:FindFirstChild("Fishing")
    local hpPlayer = fGui and fGui:FindFirstChild("HPPlayer")
    local debuff = hpPlayer and hpPlayer:FindFirstChild("Debuff")
    if debuff and debuff:FindFirstChild("Poisoned") then
        return true
    end

    return false
end

-- 4.1. VÒNG LẶP AUTO SKILL & HỒI MÁU ĐỘC LẬP (Hoạt động cho cả Câu Cá thường, Boss Thời Tiết & Boss Enzo, Long Diaohai)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local skillRem = events:WaitForChild("UseSkill")
    local skillKeys = {"Z", "X", "C", "V"}

    while _G.FishingMasterSession == currentSession do
        if state.AutoSkill and isPlayerInFishingFight() then
            local currentFish = findMyFish()
            local char = getCharacter()

            -- 1. Cơ chế TỰ ĐỘNG HỒI MÁU KHẨN CẤP (khi máu dưới ngưỡng cài đặt)
            if state.AutoHealSkill and state.HealSkillKey and state.HealSkillKey ~= "" then
                local currentHPPercent = getPlayerFishingHealthPercent(currentFish)
                local threshold = tonumber(state.HealHPThreshold) or 40
                local shouldHeal = (currentHPPercent <= threshold)

                if shouldHeal then
                    -- Nếu đang dính trạng thái không thể hồi máu (Poisoned) -> Chờ hết Poisoned mới dùng
                    if not isPlayerHealBlocked(char) then
                        if isSkillReady(state.HealSkillKey, char) then
                            skillRem:FireServer(state.HealSkillKey)
                            task.wait(0.2)
                        end
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
                if isSkillReady(key, char) then
                    skillRem:FireServer(key)
                    task.wait(0.18)
                end
            end

            task.wait(0.15)
        else
            task.wait(0.3)
        end
    end
end)

-- 4.2. VÒNG LẶP CÂU CÁ (Fishing Loop)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local fishRem = events:WaitForChild("Fishing")
    local hotbarRem = events:WaitForChild("ToggleHotbar")
    local minigameRem = events:WaitForChild("FishingMinigame")

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
        local mGui = getMainGui()
        local fGui = mGui and mGui:FindFirstChild("Fishing")
        local progBar = fGui and fGui:FindFirstChild("ProgressionBar")
        local fishNameLbl = progBar and progBar:FindFirstChild("FishName")
        if fishNameLbl and fishNameLbl.Text ~= "" and fishNameLbl.Text ~= "Fish" then
            return fishNameLbl.Text
        end
        return nil
    end

    while _G.FishingMasterSession == currentSession do
        -- Nếu người chơi đang trong một trận chiến / đánh Boss (Enzo, Long Diaohai, hoặc kéo cá)
        -- thì không ném cần đè lên, kiên nhẫn chờ trận đấu kết thúc
        if isPlayerInFishingFight() then
            task.wait(0.5)
            continue
        end

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
                    -- Ném cần thất bại (kẹt góc, lệch bờ nước, hố cạn hoặc server từ chối)
                    -- Luôn cất cần trước khi đổi vị trí đứng
                    task.wait(0.2)
                    unequipRod()
                    task.wait(0.2)

                    -- CHỈ TỰ ĐỘNG ĐỔI BỜ KHI ĐANG BẬT SĂN BOSS THỜI TIẾT HOẶC AUTO QUEST
                    if state.AutoWeatherBoss and weatherBossActive then
                        local islName = currentFishingLocation.Name or "đảo boss"
                        setWeatherBossStatus("⚠️ Ném cần không tới nước/kẹt vị trí -> Đổi bờ câu khác trên " .. tostring(islName) .. "...")
                        relocateCurrentFishingSpot()
                    elseif state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                        relocateCurrentFishingSpot()
                    end
                    -- Khi CHỈ BẬT AutoFishing thường: Giữ nguyên vị trí tại chỗ, tuyệt đối không tự ý teleport!
                    task.wait(0.6)
                    equipRod()
                    task.wait(0.4)
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

                        -- 1.5. CƠ CHẾ SIÊU TỐC LÀM NHIỆM VỤ DÙNG MỒI (USE BAIT FAST SKIP)
                        -- Cá vừa cắn câu là game đã trừ 1 mồi và tính +1 lần dùng thành công!
                        if shouldFastSkipForBaitQuest() then
                            local msg = "⚡ Fast Bait: Cắn câu tính +1 mồi -> Hủy kéo & Thả lại siêu tốc!"
                            setTicketStatus(msg)
                            setEssenceStatus(msg)
                            setDailyStatus("⚡ Fast Bait: +1 mồi -> Thả lại!")
                            pcall(function()
                                hotbarRem:InvokeServer("1", nil)
                            end)
                            task.wait(0.2)
                            equipRod()
                            task.wait(0.3)
                            currentHookedFishName = nil
                        else
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

                                -- Giữ nhịp kéo cá (kỹ năng & hồi máu được vòng lặp độc lập Auto Skill tự động thi triển song song)
                                while targetFish and targetFish.Parent and isFishingAllowed() do
                                    task.wait(0.2)
                                end
                                currentHookedFishName = nil
                            end
                        end
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
                    if CUSTOM_FARM_POS then
                        travelToFarmSpot()
                    else
                        local farmIsland = state.SelectedIsland or "Beginning Isle"
                        currentFishingLocation = { Type = "Island", Name = farmIsland }
                        teleportToIslandShore(farmIsland)
                    end
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
                    local destName = CUSTOM_FARM_POS and "Điểm câu tùy chỉnh" or (state.SelectedIsland or "Beginning Isle")
                    setTicketStatus("⏳ [" .. statusMsg .. "] Chờ " .. targetData.RequiredWeather .. " -> Farm tại: " .. destName)
                    travelToFarmSpot()
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
                local destName = CUSTOM_FARM_POS and "Điểm câu tùy chỉnh" or (state.SelectedIsland or "Beginning Isle")
                setTicketStatus("⏳ Hồi vé: " .. cd .. "s -> Đang farm tại: " .. destName)
                travelToFarmSpot()
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
                    local destName = CUSTOM_FARM_POS and "Điểm câu tùy chỉnh" or (state.SelectedIsland or "Beginning Isle")
                    setEssenceStatus("⏳ [" .. statusMsg .. "] Chờ " .. (targetData.RequiredWeather or "thời tiết") .. " -> Farm tại: " .. destName)
                    travelToFarmSpot()
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
