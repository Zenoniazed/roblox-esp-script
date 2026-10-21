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
    LockBar = true,
    AutoSlam = true,
    AutoMinigames = true, -- Tự động vượt qua tất cả mini game thường & Boss
    AutoSell = false,
    SelectedIsland = "Beginning Isle",
    -- Ticket Quest
    AutoTicketQuest = false,
    TicketHardMode = true,
    -- Daily Quest
    AutoDailyQuest = false,
    -- Essence Orb (Zeng Tianguo Quest)
    AutoEssenceOrb = false,
}

-- Cờ điều khiển nội bộ cho Quest
local ticketQuestWantsFishing = false
local dailyQuestWantsFishing = false
local essenceOrbWantsFishing = false
local isInteractingNPC = false

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

    if (string.find(lower, "fish for") and string.find(lower, "time")) 
        or (string.find(lower, "use bait") and string.find(lower, "time"))
        or string.find(lower, "^fish for") 
        or string.find(lower, "^use bait") then
        return {
            TargetType = "Island",
            Destination = "Beginning Isle",
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

--// UI INITIALIZATION
local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/UiRoblox.lua"
    ))()

local Window = Library:Window({
    Title  = "HEAVYWEIGHT_FISHING",
    Desc   = "Con Cu Màu Đen",
    Theme  = "Amethyst",
   Config = {
            Keybind = Enum.KeyCode.K,
            Size = UDim2.new(0, 520, 0, 260)
        },

        CloseUIButton = {
            Enabled = true,
            Icon = 71051887760757
        }
})

local TabFarm = Window:Tab({ Title = "Main Farm", Icon = "fish" })
local TabQuest = Window:Tab({ Title = "Auto Quest", Icon = "clipboard-list" })
local TabTP = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

--// FARMING TAB
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

-- MỤC AUTO TẤT CẢ MINI GAME
TabFarm:Toggle({
    Title = "Auto All Minigames (Slam, Charge, Rhythm, Boss)",
    Value = state.AutoMinigames,
    Callback = function(v)
        state.AutoMinigames = v
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
    Title = "Tiến Trình Essence Orb (Zeng Tianguo)",
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
for _, islandName in ipairs(OrderedIslandList) do
    TabTP:Button({
        Title = "Bay tới: " .. islandName,
        Callback = function()
            teleportToIslandSpawn(islandName)
        end
    })
end

--// LOOPS & LOGIC

-- 1. Lock Bar
local bar = mainGui:WaitForChild("Fishing"):WaitForChild("BarFrame"):WaitForChild("Bar")
local renderConn
renderConn = RunService.RenderStepped:Connect(function()
    if _G.FishingMasterSession ~= currentSession then
        renderConn:Disconnect()
        return
    end
    if (state.LockBar or state.AutoMinigames) and bar and bar.Visible then
        bar.Position = UDim2.fromScale(0.5, 0.5)
    end
end)

-- 2. AUTO ALL MINIGAMES ENGINE (SLAM, CHARGE, RHYTHM, BOSS PHASE 2)
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events")
    local rhythmHitRem = events:FindFirstChild("RhythmHit")
    local mobileFishingBtn = mainGui:WaitForChild("Mobile"):WaitForChild("Fishing")
    local fishingFrame = mainGui:WaitForChild("Fishing")
    local trashCan = fishingFrame:WaitForChild("TrashCan")
    local rhythmFrame = fishingFrame:FindFirstChild("Rhythm")
    local bossFightBar = fishingFrame:FindFirstChild("BossFightBar")

    -- [A & B]: Xử lý Slam & Charge khi xuất hiện trong TrashCan
    trashCan.ChildAdded:Connect(function(child)
        if _G.FishingMasterSession ~= currentSession then return end
        if not state.AutoMinigames and not state.AutoSlam then return end

        -- Auto Charge: Bấm ngay lập tức
        if child.Name == "Charge" then
            task.wait(0.05)
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

    local miniConn
    miniConn = RunService.RenderStepped:Connect(function()
        if _G.FishingMasterSession ~= currentSession then
            miniConn:Disconnect()
            return
        end
        if not state.AutoMinigames then return end

        -- [C] Auto Rhythm Minigame (Nốt nhạc Boss)
        if rhythmFrame and rhythmFrame.Visible then
            local now = tick()
            for i = 1, 4 do
                local lane = rhythmFrame:FindFirstChild("Progression" .. i)
                if lane then
                    local barF = lane:FindFirstChild("BarFrame")
                    local targetY = barF and barF.Position.Y.Scale or 0.85

                    for _, child in ipairs(lane:GetChildren()) do
                        if child.Name == "Note_FX" and child.Visible then
                            local curY = child.Position.Y.Scale
                            local isTrap = (child.BackgroundColor3.R > 0.95 and child.BackgroundColor3.G > 0.95 and child.BackgroundColor3.B > 0.95)
                            
                            -- Nốt rơi tới vạch đích -> hit ngay & xóa nốt để không bị dính miss
                            if not isTrap and curY >= (targetY - 0.12) and curY <= (targetY + 0.18) then
                                if now - lastRhythmHit >= 0.08 then
                                    lastRhythmHit = now
                                    if rhythmHitRem then
                                        rhythmHitRem:FireServer("hit")
                                    end
                                    pcall(function() child:Destroy() end)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- [D] Auto Boss Fight Bar (Boss Phase 2)
        if bossFightBar and bossFightBar.Visible then
            local bBar = bossFightBar:FindFirstChild("Bar")
            local hitbox = bossFightBar:FindFirstChild("Hitbox")
            local badHitbox = bossFightBar:FindFirstChild("HitboxBad")

            if bBar and hitbox and hitbox.Visible then
                local barCenter = bBar.Position.X.Scale
                local hbLeft = hitbox.Position.X.Scale
                local hbRight = hbLeft + hitbox.Size.X.Scale

                if barCenter >= hbLeft and barCenter <= hbRight then
                    local inBad = false
                    if badHitbox and badHitbox.Visible then
                        local badLeft = badHitbox.Position.X.Scale
                        local badRight = badLeft + badHitbox.Size.X.Scale
                        if barCenter >= badLeft and barCenter <= badRight then
                            inBad = true
                        end
                    end

                    if not inBad and tick() - lastBossHit >= 0.08 then
                        lastBossHit = tick()
                        doVimClick(mobileFishingBtn)
                    end
                end
            end
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
    local skillKeys = {"Z", "X", "C", "V"}

    while _G.FishingMasterSession == currentSession do
        local canFish = isFishingAllowed()
        if canFish then
            if not isHoldingRod() then
                equipRod()
                task.wait(0.5)
            end

            if isHoldingRod() and isFishingAllowed() then
                fishRem:FireServer()
                local targetFish = nil
                local startWait = tick()
                
                repeat
                    targetFish = findMyFish()
                    task.wait(0.3) 
                until targetFish or not isFishingAllowed() or (tick() - startWait >= 10)

                -- Có cá cắn câu
                if isFishingAllowed() and targetFish then
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
                            for _, key in ipairs(skillKeys) do
                                skillRem:FireServer(key)
                                task.wait(0.05)
                            end
                        else
                            task.wait(0.2)
                        end
                    end
                -- Quá 10s không có cá -> Đổi điểm đứng khác (chỉ khi làm Quest)
                elseif isFishingAllowed() and not targetFish then
                    task.wait(0.3)
                    if state.AutoTicketQuest or state.AutoDailyQuest or state.AutoEssenceOrb then
                        relocateCurrentFishingSpot()
                    end
                    task.wait(0.8)
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
