-- ============================================================================
-- FISHING MASTER: fishing, boat boss patrol, inventory and weather
-- ============================================================================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 1. TẢI STARDUST FRAMEWORK & CONTROLLERS
local Stardust = require(ReplicatedStorage:WaitForChild("Stardust"))
local Fishing = Stardust.Client.GetController("FishingController")
local Rod = Stardust.Client.GetController("RodController")
local Sell = Stardust.Client.GetController("SellController")
local Data = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("PlayerDataV2Controller"))

local Equipment = Stardust.Client.GetController("EquipmentsController")
local AuraGacha = Stardust.Client.GetController("AuraGachaController")
local SkillGacha = Stardust.Client.GetController("SkillGachaController")

local StateEnum = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Enums"):WaitForChild("FishingEnums")).State
local SellStatus = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Enums"):WaitForChild("SellEnums")).Status
local Catalog = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Catalog"))
local Storage = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lib"):WaitForChild("FishStorageRules"))

-- Danh sách độ hiếm cá hỗ trợ khóa
local RARITY_LIST = {"Mythical", "Legendary", "Epic", "Rare", "Uncommon", "Common"}

-- 2. CẤU HÌNH & TRẠNG THÁI (CONFIG MANAGEMENT)
local CONFIG = "LightHack_Fishing.json"

local State = {
    AutoFish = false,
    AutoBoss = false,
    TeleportUseBoat = false,
    DiscordWeather = false,
    DiscordWebhook = "",
    MovementMode = "WalkTo",            -- WalkTo hoặc Tween
    TweenSpeed = 16,                    -- studs/giây
    AutoSell = true,                    -- Tự động bán cá khi đầy túi
    AutoLock = true,                    -- Bật/Tắt tự động khóa cá
    SelectedRarity = {"Mythical", "Legendary"}, -- Chọn nhiều độ hiếm cá cần khóa
    CastDelay = 1,                      -- Khoảng chờ giữa các lần ném cần
    TapDelay = 0.03,                     -- Tốc độ nhấp kéo cá (reeling)
    HoldTime = 0.6,                     -- Thời gian giữ chuột khi ném cần
    Luck = 1,                           -- Chỉ số Luck khi quăng cần
}

local function save()
    if writefile then
        writefile(CONFIG, HttpService:JSONEncode(State))
    end
end

local function load()
    if isfile and isfile(CONFIG) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG))
        end)

        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                State[k] = v
            end
        end
    end
end

load()
-- Require an explicit toggle each run; retain the webhook locally with other settings.
State["BossUse" .. "Portal"] = nil -- Xóa tùy chọn cũ khi đọc cấu hình
State.BoatSpeed=nil -- Dùng tốc độ động cơ của game
State.DiscordWeather = false
if type(State.DiscordWebhook) ~= "string" then State.DiscordWebhook = "" end
if State.MovementMode ~= "WalkTo" and State.MovementMode ~= "Tween" then
    State.MovementMode = "WalkTo"
end
local loadedTweenSpeed = tonumber(State.TweenSpeed)
State.TweenSpeed = (loadedTweenSpeed and loadedTweenSpeed == loadedTweenSpeed)
    and math.clamp(loadedTweenSpeed, 5, 150) or 40

-- 3. CÁC BIẾN QUẢN LÝ AUTO LOCK & PATHFINDING
local Boss
local manualTravelBusy = false
local manualTravelStatus = "Sẵn sàng"
local sequence = 0
local firstPullSent = false
local isCasting = false
local isSelling = false
local FishingHome = nil -- Điểm câu gốc của phiên Auto Fishing; không thay đổi khi bán cá
local pendingCast = false
local nextCastAt = os.clock()

local SafePathsCache = {} -- Bộ nhớ đường đi
local currentPathId = 0
local attemptedLock = {}   -- Lịch sử các UID cá đã thử khóa

local QTE_KEYS = {
    Left = "A",
    Up = "W",
    Right = "D",
    Down = "S",
}

local packet = Fishing.FishCast

-- 4. HÀM TỰ ĐỘNG KHÓA CÁ (MULTI-RARITY AUTO LOCK SYSTEM)
local function InspectAndLockFish(tool)
    if not State.AutoLock or not tool:IsA("Tool") then return end
    local id = tool:GetAttribute("id")
    local uid = tool:GetAttribute("uid")
    if type(id) ~= "string" or type(uid) ~= "string" or attemptedLock[uid] then return end
    local fish = Catalog.Fish.GetById(id)
    if not fish then return end

    local isTargetRarity = false
    if type(State.SelectedRarity) == "table" then
        for _, rarity in ipairs(State.SelectedRarity) do
            if fish.rarity == rarity then
                isTargetRarity = true
                break
            end
        end
    elseif type(State.SelectedRarity) == "string" and fish.rarity == State.SelectedRarity then
        isTargetRarity = true
    end

    if not isTargetRarity then return end

    local data = Data:Fetch()
    local fishes = data and data.Inventory and data.Inventory.Fishes
    local record = fishes and fishes[uid]
    if type(record) ~= "table" or record.fishId ~= id then return end
    if record.locked ~= false then return end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if tool.Parent ~= backpack and tool.Parent ~= LocalPlayer.Character then return end

    attemptedLock[uid] = true
    local ok, status, locked = pcall(function()
        return Sell:ToggleLock(uid)
    end)
    task.wait(0.2)
end

task.spawn(function()
    while true do
        if State.AutoLock then
            local ok, err = pcall(function()
                local containers = {}
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then table.insert(containers, backpack) end
                if LocalPlayer.Character then table.insert(containers, LocalPlayer.Character) end

                for _, container in ipairs(containers) do
                    for _, tool in ipairs(container:GetChildren()) do
                        if not State.AutoLock then break end
                        InspectAndLockFish(tool)
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- 5. HÀM KIỂM TRA TÚI CÁ & TÌM NPC
local function bagFull()
    local success, result = pcall(function()
        local data = Data:Fetch(LocalPlayer)
        if not data then return false end
        local storage = Storage.GetState(data)
        if type(storage) == "table" and type(storage.isFull) == "boolean" then
            return storage.isFull
        end
        return false
    end)
    return success and result or false
end

local function FindNPC(npcName)
    local world = workspace:FindFirstChild("World")
    local islands = world and world:FindFirstChild("Islands")

    if islands then
        for _, island in ipairs(islands:GetChildren()) do
            local interactives = island:FindFirstChild("Interactives")
            if interactives then
                local npc = interactives:FindFirstChild(npcName)
                if npc then return npc end
            end
        end
    end

    return workspace:FindFirstChild(npcName, true)
end

local function GetNPCPosition(npc)
    if not npc then return nil end
    if npc:IsA("Model") then
        local primary = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildOfClass("BasePart")
        if primary then return primary.Position, primary.CFrame end
        local pivot = npc:GetPivot()
        return pivot.Position, pivot
    elseif npc:IsA("BasePart") then
        return npc.Position, npc.CFrame
    end
    return nil, nil
end

local function isBadWaypoint(pos)
    return false
end

-- 6. TÌM ĐƯỜNG VÀ BỘ NHỚ LỘ TRÌNH (THUẦN ĐI BỘ - KHÔNG NHẢY)
local function walkTo(position, stopDistance, shouldContinue, retryCount)
    if not position then return false end
    retryCount = retryCount or 0
    if retryCount >= 3 or (shouldContinue and not shouldContinue()) then return false end

    currentPathId = currentPathId + 1
    local myPathId = currentPathId

    if isBadWaypoint(position) then return false end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then return false end

    local destination = position
    local function checkStop()
        if currentPathId ~= myPathId or humanoid.Health <= 0 or root.Parent ~= character
            or (shouldContinue and not shouldContinue()) then
            humanoid:Move(Vector3.zero)
            return false
        end
        if stopDistance and (root.Position - destination).Magnitude <= stopDistance then
            humanoid:Move(Vector3.zero)
            return true
        end
        return nil
    end
    local stopped = checkStop()
    if stopped ~= nil then return stopped end
    -- Project endpoints onto collidable ground instead of the destination height.
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character}
    rayParams.RespectCanCollide = true
    rayParams.IgnoreWater = false
    local function groundAt(point)
        local hit = workspace:Raycast(point + Vector3.new(0,24,0), Vector3.new(0,-96,0), rayParams)
        if hit and hit.Material ~= Enum.Material.Water and hit.Normal.Y >= 0.55 then
            return hit.Position
        end
    end
    local candidates = {}
    if stopDistance then
        local offset = root.Position - destination
        local startAngle = math.atan2(offset.Z, offset.X)
        local rootHeight = humanoid.HipHeight + root.Size.Y * 0.5
        -- Search both sides and behind the destination, nearer candidates first.
        for _, radius in ipairs({6,3,8,0}) do
            for step = 0, (radius == 0 and 0 or 7) do
                local angle = startAngle + step * math.pi / 4
                local point = destination + Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
                local ground = groundAt(point)
                if ground and (ground + Vector3.new(0,rootHeight,0) - destination).Magnitude <= stopDistance - 0.5 then
                    table.insert(candidates, ground)
                end
            end
        end
        table.sort(candidates, function(a,b)
            return (root.Position-a).Magnitude < (root.Position-b).Magnitude
        end)
        if #candidates == 0 then
            return false
        end
    else
        table.insert(candidates, position)
        local ground = groundAt(position)
        if ground then table.insert(candidates, ground) end
    end

    -- 1. DÙNG LỘ TRÌNH ĐÃ LƯU
    for targetPos, savedWaypoints in pairs(SafePathsCache) do
        if not stopDistance and (position - targetPos).Magnitude <= 3
            and savedWaypoints[1] and (root.Position-savedWaypoints[1]).Magnitude <= 12 then

            local completedVIP = false
            for idx, wpPos in ipairs(savedWaypoints) do
                local stop = checkStop()
                if stop ~= nil then return stop end

                humanoid:MoveTo(wpPos)

                local startTime = tick()
                local lastDist = (root.Position - wpPos).Magnitude

                repeat
                    task.wait()
                    local stop = checkStop()
                    if stop ~= nil then return stop end

                    local currentDist = (root.Position - wpPos).Magnitude

                    if currentDist <= 6.5 or (idx < #savedWaypoints and (root.Position - savedWaypoints[idx + 1]).Magnitude < currentDist) then
                        break
                    end

                    if tick() - startTime > 1.2 then
                        SafePathsCache[targetPos] = nil
                        return walkTo(destination, stopDistance, shouldContinue, retryCount + 1)
                    end
                until false

                if idx == #savedWaypoints then
                    completedVIP = true
                end
            end

            if completedVIP then
                return true
            end
        end
    end

    -- 2. TÍNH PATH MỚI BẰNG PATHFINDINGSERVICE
    local path = PathfindingService:CreatePath({
        AgentRadius = 2.0,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
        Costs = { Water = math.huge }
    })

    local success = false
    local groundStart = groundAt(root.Position)
    local starts = {root.Position}
    if groundStart then table.insert(starts, groundStart + Vector3.new(0,0.5,0)) end
    for _, start in ipairs(starts) do
        for _, candidate in ipairs(candidates) do
            stopped = checkStop()
            if stopped ~= nil then return stopped end
            local computed = pcall(function() path:ComputeAsync(start, candidate) end)
            stopped = checkStop()
            if stopped ~= nil then return stopped end
            if computed and path.Status == Enum.PathStatus.Success then
                position, success = candidate, true
                break
            end
        end
        if success then break end
    end
    if not success then
        return false
    end

    local waypoints = path:GetWaypoints()
    local tempWaypointsPositions = {}
    local isStuckDuringPath = false

    for i = 2, #waypoints do
        local stop = checkStop()
        if stop ~= nil then return stop end
        local waypoint = waypoints[i]

        if isBadWaypoint(waypoint.Position) then
            isStuckDuringPath = true
            return walkTo(destination, stopDistance, shouldContinue, retryCount + 1)
        end

        table.insert(tempWaypointsPositions, waypoint.Position)
        humanoid:MoveTo(waypoint.Position)

        -- Chỉ nhảy khi đường đi bắt buộc (vật cản cao cần nhảy qua)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        local startTime = tick()
        local lastDistance = (root.Position - waypoint.Position).Magnitude

        repeat
            task.wait(0.02)
            local stop = checkStop()
            if stop ~= nil then return stop end

            local currentDistance = (root.Position - waypoint.Position).Magnitude

            if currentDistance <= (stopDistance and i == #waypoints and 3 or 6.5) then break end

            if tick() - startTime > 2 then
                isStuckDuringPath = true
                return walkTo(destination, stopDistance, shouldContinue, retryCount + 1)
            end

            if math.abs(lastDistance - currentDistance) > 0.5 then
                startTime = tick()
                lastDistance = currentDistance
            end
        until false

        if isStuckDuringPath then break end
    end

    if stopDistance then
        stopped = checkStop()
        if stopped ~= nil then return stopped end
        humanoid:Move(Vector3.zero)
        return false
    end

    -- 3. LƯU LỘ TRÌNH MỚI NẾU ĐI THÀNH CÔNG
    if not isStuckDuringPath and currentPathId == myPathId and #tempWaypointsPositions > 0 then
        SafePathsCache[position] = tempWaypointsPositions

        local count = 0
        for _ in pairs(SafePathsCache) do count = count + 1 end
        if count > 20 then
            local firstKey = next(SafePathsCache)
            if firstKey then SafePathsCache[firstKey] = nil end
        end
        return true
    end

    return false
end

-- Shared movement selector. A changed mode takes effect on the next move.
local activeTweenCleanup
local function cancelMovementTween()
    if activeTweenCleanup then activeTweenCleanup() end
end

local function tweenTo(position, stopDistance, shouldContinue)
    cancelMovementTween()
    currentPathId = currentPathId + 1
    local pathId = currentPathId
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not position or not root or not humanoid then return false end
    local function allowed()
        return currentPathId == pathId and LocalPlayer.Character == character
            and root.Parent == character and humanoid.Health > 0
            and (not shouldContinue or shouldContinue())
    end
    if not allowed() then return false end
    local radius = stopDistance or 2
    local delta = position - root.Position
    if delta.Magnitude <= radius then return true end

    local tween
    local oldAutoRotate = humanoid.AutoRotate
    local cleaned = false
    local cleanup
    cleanup = function()
        if cleaned then return end
        cleaned = true
        if tween then tween:Cancel() end
        if humanoid.Parent then
            humanoid.AutoRotate = oldAutoRotate
            humanoid:Move(Vector3.zero)
        end
        if activeTweenCleanup == cleanup then activeTweenCleanup = nil end
    end
    activeTweenCleanup = cleanup
    local ok, reached = xpcall(function()
        humanoid.Sit = false
        humanoid:Move(Vector3.zero)
        humanoid.AutoRotate = false
        -- Aim slightly inside the radius to reach the destination reliably.
        local target = position - delta.Unit * math.max(0, radius - 1)
        local duration = math.max(0.05, (target - root.Position).Magnitude / State.TweenSpeed)
        tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(target) * root.CFrame.Rotation
        })
        local deadline = os.clock() + duration + 2
        tween:Play()
        while allowed() and not cleaned and os.clock() < deadline do
            if (root.Position - position).Magnitude <= radius then return true end
            if tween.PlaybackState == Enum.PlaybackState.Completed
                or tween.PlaybackState == Enum.PlaybackState.Cancelled then break end
            task.wait(0.05)
        end
        return not cleaned and allowed() and (root.Position - position).Magnitude <= radius
    end, tostring)
    cleanup()
    if not ok then return false end
    return reached
end

local function moveTo(position, stopDistance, shouldContinue)
    if State.MovementMode == "Tween" then
        return tweenTo(position, stopDistance, shouldContinue)
    end
    cancelMovementTween()
    return walkTo(position, stopDistance, shouldContinue)
end

-- Điểm câu gốc của phiên Auto Fishing. Chỉ tạo lại khi bật Auto Fishing.
local function captureFishingHome(force)
    if FishingHome and not force then return FishingHome end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    FishingHome = {cf = root.CFrame, position = root.Position}
    return FishingHome
end

local function restoreFishingHomeIfDrifted()
    if not State.AutoFish or State.AutoBoss or isSelling or manualTravelBusy or Boss and Boss.busy then return end
    local home = FishingHome
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not home or not root then return end
    local distance = (root.Position - home.position).Magnitude
    if distance > 0.75 then
        -- Ép về đúng tọa độ gốc; chỉ chạy khi không có tác vụ di chuyển khác.
        cancelMovementTween()
        currentPathId = currentPathId + 1
        root.CFrame = home.cf
        local humanoid = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:Move(Vector3.zero) end
    end
end

-- 7. LOGIC AUTO SELL FISH & RETURN (CÓ KHÔI PHỤC HƯỚNG NHÌN CŨ)
local function AutoSellFish()
    if isSelling or manualTravelBusy or (Boss and Boss.busy) or not State.AutoFish then return end
    isSelling = true

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local home = FishingHome or captureFishingHome(false)

    if not root or not home then
        isSelling = false
        return
    end

    local originalCFrame = home.cf
    local originalSpot = home.position

    local npc = FindNPC("npc_fish_seller_1")
    local npcPos, npcCFrame = GetNPCPosition(npc)

    if npcPos then
        local targetPos = npcPos + (npcCFrame and npcCFrame.LookVector * 4 or Vector3.new(0, 0, 4))
        if not moveTo(targetPos) then
            isSelling = false
            return
        end
    else
        isSelling = false
        return
    end

    task.wait(0.5)
    local status, coins, count = Sell:SellAll()
    task.wait(0.5)

    if not State.AutoFish then
        isSelling = false
        return
    end

    local returned = moveTo(originalSpot)
    root = bossCharacter()
    if root then
        -- Không lấy root.Position hiện tại làm gốc; luôn dùng home.cf đã khóa từ lúc bật Auto Fish.
        root.CFrame = originalCFrame
        local humanoid = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:Move(Vector3.zero) end
    end

    task.wait(0.2)
    isSelling = false
end

-- AUTO BOSS: one worker owns movement; scan loaded regions during every patrol step.
Boss = {
    busy = false, fishing = false, home = nil, target = nil,
    weather = false, weatherKey = "", completedWeather = nil,
    cancel = 0, status = "Đang tắt", fault = false,
}
local bossAllowed
local Boat = {model=nil, seat=nil, main=nil, dock=nil, returnDock=nil, stop=nil, departurePending=false}
local SpawnCar = Stardust.Packet("SpawnCarEvent", Stardust.Packet.String)
local bossFindLoaded
local function bossPatrolContinue(token, returning)
    if not returning and Boss.patrolling and bossFindLoaded then
        local fx, spot, island = bossFindLoaded()
        if fx then
            Boss.detected = {fx=fx, spot=spot, island=island}
            return false
        end
        local destination=Boss.patrolDestination
        local observation=destination and Boss.regionObservations and Boss.regionObservations[destination.id]
        if observation and observation.empty then
            Boss.skipDestination=destination.id
            return false
        end
    end
    return true
end
local BOSS_FISH_BY_WEATHER = {
    weather_snowfall = "kun_version_1",
    weather_void_storm = "kun_version_2",
    weather_thunderstorm = "halangu_awakened",
    weather_blood_moon = "halangu_true_form",
    weather_rainbow_rain = "dragon_koi",
}
local BOSS_OPTIONS = {
    -- Chọn điểm đứng gần vùng boss active nhất, không giới hạn khoảng cách.
    DrainSeconds = 120, RegionGoneSeconds = 1,
}
local BOSS_ISLANDS = {
    {id="island_starter", spots={Vector3.new(-4,11,303), Vector3.new(-275,10,490)}},
    {id="island_jungle", spots={Vector3.new(-1164, 7, -152), Vector3.new(-1483,11,-257)}},
    {id="island_desert", spots={Vector3.new(-86,10,-951), Vector3.new(192,10,-1156)}},
    {id="island_snow", spots={Vector3.new(1176,9,-411),Vector3.new(1455, 10, -182)}},
    {id="island_volcano", spots={Vector3.new(1794,9,1031), Vector3.new(2241,9,1147)}},
    {id="island_fossil", spots={Vector3.new(-584,11,2171),Vector3.new(-1128, 9, 2600)}},
}
local function bossStatus(message)
    Boss.status = message
end
local function bossCharacter()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return r, h end
end
local function bossIslandsFolder()
    local w = workspace:FindFirstChild("World")
    return w and w:FindFirstChild("Islands")
end
local function bossCurrentIsland()
    local root = bossCharacter()
    if not root then return nil end
    local ok, islandId = pcall(function()
        return Stardust.Client.GetController("IslandRegionController"):GetCurrentIslandId()
    end)
    if ok then
        for _, island in ipairs(BOSS_ISLANDS) do
            if island.id == islandId then return island end
        end
    end
    local best, distance
    for _, island in ipairs(BOSS_ISLANDS) do
        for _, spot in ipairs(island.spots) do
            local d = (root.Position-spot).Magnitude
            if not distance or d < distance then best, distance = island, d end
        end
    end
    return best
end
-- Shared boat driver with obstacle avoidance.
local function boatBrake()
    if Boat.stop then Boat.stop("Đã hủy di chuyển") end
    if Boat.seat and Boat.seat.Parent then
        Boat.seat.ThrottleFloat=0
        Boat.seat.SteerFloat=0
    end
    if Boat.main and Boat.main.Parent then
        Boat.main.AssemblyLinearVelocity=Vector3.zero
        Boat.main.AssemblyAngularVelocity=Vector3.zero
    end
end
local function boatRelease()
    boatBrake()
    Boat.model,Boat.seat,Boat.main,Boat.dock=nil,nil,nil,nil
    Boat.departurePending=false
    Boat.returnDock=nil
end
local function boatBind()
    local cars=workspace:FindFirstChild("Cars")
    local model=cars and cars:FindFirstChild(tostring(LocalPlayer.UserId))
    local seat=model and model:FindFirstChild("DSeat",true)
    local main=model and model:FindFirstChild("Main",true)
    if not model or not model:IsA("Model") or not seat or not seat:IsA("VehicleSeat")
        or not main or not main:IsA("BasePart") then return false end
    Boat.model,Boat.seat,Boat.main=model,seat,main
    return true
end
local function boatSit(canContinue)
    local deadline=os.clock()+10
    repeat
        if not canContinue() then return false end
        local root,humanoid=bossCharacter()
        if not root or not Boat.seat or not Boat.seat.Parent then return false end
        if humanoid.SeatPart==Boat.seat then return true end
        local prompt=Boat.seat:FindFirstChildWhichIsA("ProximityPrompt",true)
        root.CFrame=Boat.seat.CFrame*CFrame.new(0,2,0)
        if prompt and fireproximityprompt then fireproximityprompt(prompt) end
        task.wait(0.4)
    until os.clock()>deadline
    return false
end
local function boatStandOnDeck(canContinue)
    boatBrake()
    local root,humanoid=bossCharacter()
    if not root or not Boat.model or not Boat.seat then return false end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances={Boat.model}
    params.RespectCanCollide=true
    local standingCF
    for _,offset in ipairs({Vector3.new(0,0,5),Vector3.new(0,0,-5),
        Vector3.new(4,0,0),Vector3.new(-4,0,0)}) do
        local point=Boat.seat.CFrame:PointToWorldSpace(offset)
        local hit=workspace:Raycast(point+Vector3.new(0,16,0),Vector3.new(0,-40,0),params)
        if hit and hit.Instance~=Boat.seat and hit.Instance.CanCollide then
            standingCF=CFrame.new(hit.Position+Vector3.new(0,humanoid.HipHeight+root.Size.Y/2+0.3,0))
                * root.CFrame.Rotation
            break
        end
    end
    if not standingCF then
        bossStatus("Chưa tìm được chỗ đứng trên xe")
        return false
    end
    local deadline=os.clock()+3
    repeat
        if not canContinue() then return false end
        root,humanoid=bossCharacter()
        if not root then return false end
        humanoid.Sit=false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        if not humanoid.SeatPart then
            root.CFrame=standingCF
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
            task.wait(0.2)
            return canContinue() and humanoid.SeatPart==nil
        end
    until os.clock()>deadline
    bossStatus("Chưa rời được ghế lái")
    return false
end
local function boatPrepare(token, canContinue)
    local env=(getgenv and getgenv()) or _G
    if env.BoatAvoidStop then pcall(env.BoatAvoidStop,"Chuyển sang lái xe Auto Boss") end
    local function allowed()
        if canContinue then return canContinue() end
        return bossAllowed(token,false)
    end
    local island=bossCurrentIsland()
    local folder=bossIslandsFolder()
    local node=folder and island and folder:FindFirstChild(island.id)
    local interactives=node and node:FindFirstChild("Interactives")
    local merchant
    if interactives then
        for _, candidate in ipairs(interactives:GetChildren()) do
            if candidate.Name:match("^npc_car_merchant") then merchant=candidate; break end
        end
    end
    if not merchant then error("Không tìm thấy NPC gọi xe trên đảo hiện tại") end
    local position=GetNPCPosition(merchant)
    if not position then error("Không xác định được vị trí NPC gọi xe") end
    bossStatus("Đi tới NPC gọi xe: "..merchant.Name)
    if not moveTo(position,nil,allowed) then error("Không đến được NPC gọi xe") end
    local root=bossCharacter()
    if not allowed() or not root or (root.Position-position).Magnitude>10 then
        error("Chưa đủ gần NPC gọi xe")
    end
    local region=Stardust.Client.GetController("IslandRegionController"):GetCurrentIslandId()
    if not region or region=="" then error("Chưa xác định được đảo để gọi xe") end
    boatRelease()
    bossStatus("Gọi truckred trên "..region)
    SpawnCar:Fire("red_truck/"..region)
    task.wait(1)
    local deadline=os.clock()+3
    repeat
        if not allowed() then error("Đã hủy gọi xe") end
        if boatBind() then break end
        task.wait(0.2)
    until os.clock()>deadline
    if not Boat.model then error("Không thấy xe của người chơi sau khi gọi") end
    -- Save the exact vehicle pose where the player first boards, before driving.
    Boat.dock=Boat.model:GetPivot()
    Boat.returnDock=nil
    Boat.departurePending=true
    if not boatSit(allowed) then error("Không ngồi được ghế lái DSeat") end
    bossStatus("Đã lên xe")
end
local function bossRegionForFX(fx)
    local node=fx
    while node and node~=workspace do
        if node.Parent and node.Parent.Name=="BossRegions" then return node end
        node=node.Parent
    end
end
local function insideBossRegion(region,position,inset)
    if not region or not region:IsDescendantOf(workspace) then return false end
    local cf,size
    if region:IsA("BasePart") then
        cf,size=region.CFrame,region.Size
    elseif region:IsA("Model") then
        cf,size=region:GetBoundingBox()
    else
        return false
    end
    local point=cf:PointToObjectSpace(position)
    local half=size*0.5
    local marginX=math.min(inset or 0,half.X*0.25)
    local marginZ=math.min(inset or 0,half.Z*0.25)
    return math.abs(point.X)<=half.X-marginX and math.abs(point.Y)<=half.Y
        and math.abs(point.Z)<=half.Z-marginZ
end
local function islandZoneInfo(island,position)
    local folder=bossIslandsFolder()
    local node=folder and folder:FindFirstChild(island.id)
    local zones=node and node:FindFirstChild("Zones")
    if not zones then return nil,false,false end
    local parts={}
    if zones:IsA("BasePart") then table.insert(parts,zones) end
    for _,part in ipairs(zones:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(parts,part) end
    end
    local target=zones:FindFirstChild("Part")
    if not target or not target:IsA("BasePart") then target=nil end
    local inside=false
    local nearest,nearestDistance
    for _,part in ipairs(parts) do
        if insideBossRegion(part,position) then inside=true end
        local distance=(part.Position-position).Magnitude
        if not nearestDistance or distance<nearestDistance then
            nearest,nearestDistance=part,distance
        end
    end
    target=target or nearest
    return target and target.Position,inside,target~=nil
end
local islandMapBounds={}
local function islandMapInfo(island,position)
    local folder=bossIslandsFolder()
    local node=folder and folder:FindFirstChild(island.id)
    local map=node and node:FindFirstChild("Map")
    if not map then return nil,false,false end
    local bounds=islandMapBounds[island.id]
    if not bounds or bounds.map~=map or os.clock()-bounds.checkedAt>=1 then
        local cf,size
        if map:IsA("BasePart") then
            cf,size=map.CFrame,map.Size
        elseif map:IsA("Model") and map:FindFirstChildWhichIsA("BasePart",true) then
            cf,size=map:GetBoundingBox()
        else
            -- Folder support: enclose the world-space corners of every map part.
            local low,high
            for _,part in ipairs(map:GetDescendants()) do
                if part:IsA("BasePart") then
                    local half=part.Size*0.5
                    for _,x in ipairs({-1,1}) do
                        for _,y in ipairs({-1,1}) do
                            for _,z in ipairs({-1,1}) do
                                local corner=part.CFrame:PointToWorldSpace(Vector3.new(half.X*x,half.Y*y,half.Z*z))
                                low=low and Vector3.new(math.min(low.X,corner.X),math.min(low.Y,corner.Y),math.min(low.Z,corner.Z)) or corner
                                high=high and Vector3.new(math.max(high.X,corner.X),math.max(high.Y,corner.Y),math.max(high.Z,corner.Z)) or corner
                            end
                        end
                    end
                end
            end
            if low then cf,size=CFrame.new((low+high)*0.5),high-low end
        end
        bounds={map=map,cf=cf,size=size,checkedAt=os.clock()}
        islandMapBounds[island.id]=bounds
    end
    if not bounds.cf then return nil,false,false end
    -- Island arrival uses the map footprint, independent of water/land height.
    local point=bounds.cf:PointToObjectSpace(position)
    local half=bounds.size*0.5
    local inside=math.abs(point.X)<=half.X and math.abs(point.Z)<=half.Z
    local center=bounds.cf.Position
    return Vector3.new(center.X,position.Y,center.Z),inside,true
end
local function boatDrive(position,token,returning,canContinue,arrivalRegion,departureOnly,arrivalIsland,stopDistance,islandInfo)
    local function allowed()
        if canContinue then return canContinue() end
        return bossAllowed(token,returning)
            and (Boat.departurePending or bossPatrolContinue(token,returning))
    end
    if not allowed() or not Boat.model or not Boat.model.Parent then return false end
    if not boatSit(allowed) then return false end
    local player=LocalPlayer
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local boat,seat,main=Boat.model,Boat.seat,Boat.main
    local Input=UserInputService
    local env=(getgenv and getgenv()) or _G
    if env.CarNoclipStop then pcall(env.CarNoclipStop) end
    if env.CarDebugStop then pcall(env.CarDebugStop) end
    local TARGET=position
    islandInfo=islandInfo or islandMapInfo
    local mapCheckAt=-math.huge
    local C={Radius=50,StopDistance=stopDistance or (returning and 20 or 10),Rays=48,ScanInterval=0.15,
        AvoidWeight=1.4,ClearDelay=0.7,Timeout=600}
    local running = true
    local completed=false
    local departureUntil=os.clock()+(Boat.departurePending and 1 or 0)
    local departureDone=not Boat.departurePending

    local driveConnection, keyConnection
    local function stop(reason, success)
        if not running then return end
        running = false
        completed=success==true
        if not success then
            Boat.lastFailure=reason
            if not Boss.detected then bossStatus("Xe dừng: "..tostring(reason)) end
        end
        if Boat.stop==stop then Boat.stop=nil end
        if driveConnection then driveConnection:Disconnect() end
        if keyConnection then keyConnection:Disconnect() end
        if seat.Parent then seat.ThrottleFloat = 0; seat.SteerFloat = 0 end
        if success and main.Parent then
            main.AssemblyLinearVelocity=Vector3.zero
            main.AssemblyAngularVelocity=Vector3.zero
        end
        if env.BoatAvoidStop == stop then env.BoatAvoidStop = nil end
    end
    Boat.stop = stop
    env.BoatAvoidStop = stop
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {boat, char}
    ray.IgnoreWater = true
    ray.RespectCanCollide = true
    ray.CollisionGroup = main.CollisionGroup
    local width = math.max(2, math.min(main.Size.X, main.Size.Z))
    local box = Vector3.new(width, math.max(1, main.Size.Y*0.7), width)
    local function flat(v) return Vector3.new(v.X, 0, v.Z) end
    local avoidSide, lastContact = 0, 0
    local leftScore, rightScore, frontDistance = 0, 0, C.Radius
    local lastScan = -math.huge
    local started = os.clock()
    local progressPosition, progressAt = main.Position, started
    local previousForward = flat(main.CFrame.LookVector).Unit
    local desired = previousForward
    local samples = {}
    local escapeDirection, escapeOrigin
    local boundarySide, directClearAt, boundaryStartDistance
    local movementPosition, movementAt = main.Position, started
    local function scan(now, forward)
        -- Classify left/right relative to the direction towards the target.
        local right = forward:Cross(Vector3.yAxis).Unit
        local center = main.Position
        leftScore, rightScore, frontDistance = 0, 0, C.Radius
        for i = 1, C.Rays do
            local angle = (i-1)*math.pi*2/C.Rays
            local direction = forward*math.cos(angle)+right*math.sin(angle)
            local hit = workspace:Blockcast(CFrame.new(center), box, direction*C.Radius, ray)
            local sample=samples[i]
            if not sample then sample={}; samples[i]=sample end
            sample.direction=direction
            sample.length=hit and hit.Distance or C.Radius
            sample.clear=not hit
            local ahead = direction:Dot(forward)
            local lateral = direction:Dot(right)
            local length = hit and hit.Distance or C.Radius
            if hit and ahead > 0.05 then
                local score = (1-length/C.Radius)*ahead
                if lateral < -0.05 then leftScore = leftScore+score
                elseif lateral > 0.05 then rightScore = rightScore+score
                else
                    leftScore = leftScore+score*0.5
                    rightScore = rightScore+score*0.5
                end
            end
            if hit and direction:Dot(desired) > 0.9 then
                frontDistance = math.min(frontDistance, length)
            end

        end
        if leftScore+rightScore > 0.03 then
            lastContact = now
            if avoidSide == 0 then
                avoidSide = leftScore >= rightScore and 1 or -1
            else
                -- Switch only when the chosen side is substantially more obstructed.
                local chosen = avoidSide == 1 and rightScore or leftScore
                local other = avoidSide == 1 and leftScore or rightScore
                if chosen > other*1.8+0.5 then avoidSide = -avoidSide end
            end
        elseif now-lastContact > C.ClearDelay then
            avoidSide = 0
        end
        local weight = math.clamp(math.max(leftScore,rightScore)*0.6, 0.4, C.AvoidWeight)
        desired = (forward+right*avoidSide*weight).Unit
        local function clearance(direction)
            local minimum = C.Radius
            for _, sample in ipairs(samples) do
                if sample.direction:Dot(direction) > math.cos(math.rad(18)) then
                    minimum = math.min(minimum, sample.length)
                end
            end
            return minimum
        end
        local function chooseBoundary()
            local best, bestScore, bestSide
            local boatForward = flat(main.CFrame.LookVector).Unit
            for i, sample in ipairs(samples) do
                if sample.clear then
                    -- Find the red/green boundary, then move two probes into green
                    -- to leave space for the hull instead of scraping the shoreline.
                    for _, side in ipairs({-1, 1}) do
                        local red = samples[(i-1+side)%C.Rays+1]
                        if not red.clear and (not boundarySide or side == boundarySide) then
                            local candidate = samples[(i-1-side*2)%C.Rays+1]
                            local neighbor = samples[(i-1-side)%C.Rays+1]
                            if candidate.clear and neighbor.clear
                                and clearance(candidate.direction) >= 35 then
                                local continuity = escapeDirection or boatForward
                                local score = candidate.direction:Dot(continuity)*60
                                    + candidate.direction:Dot(forward)*20
                                if not bestScore or score > bestScore then
                                    best, bestScore, bestSide = candidate.direction, score, side
                                end
                            end
                        end
                    end
                end
            end
            if best then
                if not boundarySide then
                    boundaryStartDistance = flat(TARGET-main.Position).Magnitude
                    escapeOrigin = main.Position
                end
                boundarySide, escapeDirection = bestSide, best
                return true
            end
            -- A clear sea has no red/green boundary. Keep travelling instead of stopping.
            if clearance(forward) >= 35 then
                boundarySide,escapeDirection,directClearAt=nil,nil,nil
                avoidSide=0
                desired=forward
                movementPosition,movementAt=main.Position,now
                return true
            end
            -- Preserve the previous heading across temporary missing boundary samples.
            if escapeDirection and clearance(escapeDirection) >= 35 then return true end
            -- A wide clear corridor is usable even when no red/green edge was sampled.
            local openDirection,openScore
            for _,sample in ipairs(samples) do
                if sample.clear and clearance(sample.direction)>=35 then
                    local score=sample.direction:Dot(boatForward)*60+sample.direction:Dot(forward)*20
                    if not openScore or score>openScore then
                        openDirection,openScore=sample.direction,score
                    end
                end
            end
            if openDirection then
                if not boundarySide then
                    boundaryStartDistance=flat(TARGET-main.Position).Magnitude
                    escapeOrigin=main.Position
                end
                boundarySide=boundarySide or 1
                escapeDirection=openDirection
                return true
            end
            return false
        end
        if boundarySide then
            local remaining = flat(TARGET-main.Position).Magnitude
            local directLength = math.min(C.Radius, remaining)
            local directHit = workspace:Blockcast(CFrame.new(main.Position), box,
                forward*directLength, ray)
            local directClear = not directHit and clearance(forward) >= directLength-1
            -- Don't return towards the same obstacle after merely moving away.
            if directClear and remaining < boundaryStartDistance-8
                and flat(main.Position-escapeOrigin).Magnitude >= 25 then
                directClearAt = directClearAt or now
            else
                directClearAt = nil
            end
            if directClearAt and now-directClearAt >= 1.5 then
                boundarySide, escapeDirection, directClearAt = nil, nil, nil
                avoidSide = 0
                desired = forward
                movementPosition, movementAt = main.Position, now
            elseif not chooseBoundary() then
                stop("Không còn hướng xanh đủ rộng ở phía đang vòng; dừng để tránh đâm bờ.")
            end
        elseif clearance(desired) < 35 or now-movementAt > 4 then
            if not chooseBoundary() then
                stop("Không tìm thấy rìa xanh đủ rộng để vòng tránh.")
            end
        end
        if escapeDirection then desired = escapeDirection end
        -- Brake using the actual bow direction as well as the commanded direction.
        frontDistance = math.min(clearance(desired),
            clearance(flat(main.CFrame.LookVector).Unit))
    end
    keyConnection = Input.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.P then stop("Dừng bằng P.") end
    end)
    driveConnection = RunService.PreSimulation:Connect(function()
        local ok, err = xpcall(function()
            if not allowed() then
                if Boss.patrolling and Boss.skipDestination and not Boss.detected then
                    stop("Đã kiểm tra đảo, không có boss",true)
                else
                    stop("Đã hủy hoặc phát hiện boss cần đổi hướng")
                end
                return
            end
            if player.Character ~= char or hum.Health <= 0
                or not main:IsDescendantOf(workspace) or not seat:IsDescendantOf(workspace)
                or hum.SeatPart ~= seat then stop("Đã rời ghế hoặc mất thuyền."); return end
            local now = os.clock()
            local root=char:FindFirstChild("HumanoidRootPart")
            if arrivalIsland and root and now-mapCheckAt>=0.1 then
                mapCheckAt=now
                local mapPosition,inZone=islandInfo(arrivalIsland,root.Position)
                if mapPosition then TARGET=mapPosition end
                -- Finish departure first so its parking point is saved outside the dock.
                if inZone and departureDone then
                    stop("Đã vào phạm vi đảo "..arrivalIsland.id,true)
                    return
                end
            end
            if arrivalRegion and root and insideBossRegion(arrivalRegion,root.Position,12) then
                Boat.departurePending=false
                stop("Đã vào sâu vùng boss "..arrivalRegion.Name,true)
                return
            end
            if not departureDone then
                if now<departureUntil then
                    seat.SteerFloat=0
                    seat.ThrottleFloat=1
                    return
                end
                departureDone=true
                Boat.departurePending=false
                -- Park near this open-water departure point on the return trip.
                if not returning then Boat.returnDock=main.Position end
                if departureOnly then
                    stop("Đã chạy thẳng 3 giây ra khỏi bãi xe",true)
                    return
                end
                started=now
                progressPosition,progressAt=main.Position,now
                movementPosition,movementAt=main.Position,now
                previousForward=flat(main.CFrame.LookVector).Unit
                desired=previousForward
                lastScan=-math.huge
            end
            local delta = flat(TARGET-main.Position)
            local distance = delta.Magnitude
            if not arrivalRegion and not arrivalIsland and distance <= C.StopDistance then
                stop("Đã tới đích",true); return
            end
            if arrivalIsland and distance<0.1 then
                local _,inZone=islandInfo(arrivalIsland,root and root.Position or main.Position)
                if inZone then
                    stop("Đã vào phạm vi đảo "..arrivalIsland.id,true)
                else
                    stop("Đã tới tâm X/Z nhưng nhân vật chưa vào phạm vi đảo "..arrivalIsland.id)
                end
                return
            end
            if arrivalRegion and distance<0.1 then
                stop("Đã tới tâm theo X/Z nhưng nhân vật chưa nằm trong Size vùng boss; kiểm tra độ cao")
                return
            end
            if flat(main.Position-movementPosition).Magnitude >= 2 then
                movementPosition, movementAt = main.Position, now
            end
            local targetForward = delta.Unit
            if now-lastScan >= C.ScanInterval then
                lastScan = now
                scan(now, targetForward)
                if not running then return end
            end
            local forward = flat(main.CFrame.LookVector).Unit
            local yaw = math.atan2(-forward.X,-forward.Z)
            local targetYaw = math.atan2(-desired.X,-desired.Z)
            local error = math.atan2(math.sin(targetYaw-yaw),math.cos(targetYaw-yaw))
            seat.SteerFloat = math.clamp(-error*0.85,-1,1)
            local throttle = math.min(1,distance/70)*math.max(0.2,math.cos(error))
            if math.abs(error) > math.rad(65) or (escapeDirection and math.abs(error) > math.rad(25)) then
                -- Steering needs forward motion; retain slow turning speed in clear water.
                throttle = math.min(throttle,0.25)
            end
            -- Slow down for obstacles; stop translation before imminent collision.
            if avoidSide ~= 0 then throttle = throttle*0.65 end
            throttle = throttle*math.clamp((frontDistance-6)/30,0,1)
            seat.ThrottleFloat = throttle
            if (flat(main.Position-progressPosition)).Magnitude >= 3
                or forward:Dot(previousForward) < math.cos(math.rad(8)) then
                progressPosition, previousForward, progressAt = main.Position, forward, now
            end
            if now-progressAt > 25 then stop("Xe bị kẹt."); return end
            if now-started > C.Timeout then stop("Hết thời gian."); return end
        end, tostring)
        if not ok then stop("Lỗi: "..tostring(err)) end
    end)
    while running do
        if not allowed() then
            if Boss.patrolling and Boss.skipDestination and not Boss.detected then
                stop("Đã kiểm tra đảo, không có boss",true)
            else
                stop("Đã hủy hoặc đổi mục tiêu")
            end
        end
        task.wait(0.05)
    end
    return completed
end
local function bossStopMove()
    boatBrake()
    cancelMovementTween()
    currentPathId = currentPathId + 1
    local root, humanoid = bossCharacter()
    if root then humanoid:Move(Vector3.zero) end
end
local function bossCanCast()
    if manualTravelBusy then return false end
    if Boss.fishing and Boat.seat then
        local _,humanoid=bossCharacter()
        if not humanoid or humanoid.SeatPart then return false end
    end
    return not Boss.busy or (Boss.fishing and not Boss.caught and State.AutoBoss and Boss.weather
        and Boss.target and Boss.target:IsDescendantOf(workspace)
        and Boss.target:GetAttribute("BossSpawnerFXActive") == true)
end
bossAllowed = function(token, returning)
    return token == Boss.cancel and State.AutoFish and bossCharacter() ~= nil
        and (returning or (State.AutoBoss and Boss.weather))
end
-- Auto Boss uses the selected shared movement mode.
local function bossWalk(position, token, returning, exact)
    if not bossAllowed(token, returning) then bossStopMove(); return false end
    local root, humanoid = bossCharacter()
    if humanoid.Sit then humanoid.Sit = false; task.wait(0.3) end
    -- Không truyền stopDistance vào WalkTo: hàm walkTo hiện tại sẽ trả false ở nhánh đó.
    -- Sau khi tới đích, nếu exact=true thì ép CFrame đúng tọa độ yêu cầu.
    local reached = moveTo(position, nil, function()
        return bossAllowed(token, returning) and bossPatrolContinue(token, returning)
    end)
    root = bossCharacter()
    if reached and root and exact then
        root.CFrame = CFrame.new(position) * root.CFrame.Rotation
        humanoid:Move(Vector3.zero)
        return true
    end
    if not reached then bossStopMove() end
    return reached
end
local function bossDrain(waitUntilIdle)
    Boss.fishing = false
    local deadline = os.clock()+BOSS_OPTIONS.DrainSeconds
    while isCasting or Fishing:GetState() ~= StateEnum.Idling do
        if not State.AutoFish or not bossCharacter() then return false end
        if not waitUntilIdle and os.clock()>deadline then return false end
        task.wait(0.1)
    end
    return true
end
local RETURN_RETRY_SECONDS = 10
local function nearestIslandSpot(destination, position)
    local spot = destination.spots[1]
    for _, candidate in ipairs(destination.spots) do
        if (position-candidate).Magnitude < (position-spot).Magnitude then spot=candidate end
    end
    return spot
end
local function bossTravel(destination, token, returning)
    if not bossAllowed(token, returning) then return false end
    local root = bossCharacter()
    if not root then return false end
    local mapPosition,inZone=islandMapInfo(destination,root.Position)
    if inZone then return true end
    local spot=mapPosition or nearestIslandSpot(destination,root.Position)
    bossStatus("Lái xe tới " .. destination.id)
    Boat.lastFailure=nil
    return boatDrive(spot,token,returning,nil,nil,nil,destination)
end
local function bossFind(island)
    local folder = bossIslandsFolder()
    local node = folder and folder:FindFirstChild(island.id)
    local regions=node and node:FindFirstChild("BossRegions")
    if not regions then return nil end
    local bestFX, bestSpot, bestDistance
    for _, fx in ipairs(regions:GetDescendants()) do
        if fx:IsA("BasePart") and fx.Name=="BossSpawnerFX" and fx:GetAttribute("BossSpawnerFXActive")==true then
            for _, spot in ipairs(island.spots) do
                local d = (fx.Position-spot).Magnitude
                if not bestDistance or d<bestDistance then
                    bestFX, bestSpot, bestDistance = fx, spot, d
                end
            end
        end
    end
    return bestFX, bestSpot
end
local function bossObserveRegions()
    local now=os.clock()
    if Boss.regionScanAt and now-Boss.regionScanAt<0.1 then return end
    Boss.regionScanAt=now
    Boss.regionObservations=Boss.regionObservations or {}
    local folder=bossIslandsFolder()
    for _,island in ipairs(BOSS_ISLANDS) do
        local record=Boss.regionObservations[island.id] or {}
        Boss.regionObservations[island.id]=record
        record.fx,record.spot=nil,nil
        local node=folder and folder:FindFirstChild(island.id)
        local regions=node and node:FindFirstChild("BossRegions")
        local regionCount,fxCount=0,0
        local complete=regions~=nil
        if regions then
            for _,region in ipairs(regions:GetChildren()) do
                if region:IsA("BasePart") or region:IsA("Model") or region:IsA("Folder") then
                    regionCount=regionCount+1
                    local known=false
                    for _,fx in ipairs(region:GetDescendants()) do
                        if fx:IsA("BasePart") and fx.Name=="BossSpawnerFX" then
                            fxCount=fxCount+1
                            local active=fx:GetAttribute("BossSpawnerFXActive")
                            if active==true or active==false then known=true else complete=false end
                            if active==true and not record.fx then
                                record.fx=fx
                                record.spot=nearestIslandSpot(island,fx.Position)
                            end
                        end
                    end
                    if not known then complete=false end
                end
            end
        end
        if record.fx then
            record.empty=false
            record.stableAt=nil
        elseif complete and regionCount>0 and fxCount>=regionCount then
            if record.regions~=regions or record.regionCount~=regionCount or record.fxCount~=fxCount then
                record.stableAt=now
            end
            record.stableAt=record.stableAt or now
            -- Brief streaming settle, without driving into the island first.
            if now-record.stableAt>=0.2 then record.empty=true end
        else
            record.stableAt=nil
            -- Retain an already checked empty island for this patrol; active FX overrides it.
        end
        record.regions,record.regionCount,record.fxCount=regions,regionCount,fxCount
    end
end
bossFindLoaded = function()
    bossObserveRegions()
    local current=bossCurrentIsland()
    local records=Boss.regionObservations
    local record=current and records and records[current.id]
    if record and record.fx and record.fx:IsDescendantOf(workspace)
        and record.fx:GetAttribute("BossSpawnerFXActive")==true then
        return record.fx,record.spot,current
    end
    for _,island in ipairs(BOSS_ISLANDS) do
        record=records and records[island.id]
        if record and record.fx and record.fx:IsDescendantOf(workspace)
            and record.fx:GetAttribute("BossSpawnerFXActive")==true then
            return record.fx,record.spot,island
        end
    end
end
local function bossScan(island, token)
    if not bossAllowed(token,false) then return nil end
    bossStatus("Kiểm tra "..island.id)
    -- Arrival in the map footprint is sufficient: check now and move on if nothing is active.
    local fx,spot=bossFind(island)
    if fx then return fx,spot,island end
    return bossFindLoaded()
end
local function bossInventory()
    local data = Data:Fetch()
    return data and data.Inventory and data.Inventory.Fishes or {}
end
local function bossCheckCatch()
    if not Boss.catchBaseline or Boss.caught then return end
    for uid, record in pairs(bossInventory()) do
        if type(record)=="table" and not Boss.catchBaseline[uid]
            and Boss.expectedFish and Boss.expectedFish[record.fishId] then
            Boss.caught = record.fishId
            Boss.fishing = false
            bossStatus("Đã bắt boss " .. tostring(record.fishId) .. "; quay về điểm câu gốc")
            return
        end
    end
end
local function bossFace(position)
    local root = bossCharacter()
    if root then
        local humanoid=root.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then return end
        local target = Vector3.new(position.X,root.Position.Y,position.Z)
        if (target-root.Position).Magnitude>0.1 then root.CFrame=CFrame.lookAt(root.Position,target) end
    end
end
local function bossFight(fx, spot, token)
    bossStatus("Đang tới vùng boss")
    local region=bossRegionForFX(fx)
    local destination
    if region and region:IsA("BasePart") then
        destination=region.Position
    elseif region and region:IsA("Model") then
        local regionCF=region:GetBoundingBox()
        destination=regionCF.Position
    else
        bossStatus("Chưa tìm thấy khối Size của vùng boss đang active")
        return false
    end
    local function activeTarget()
        return bossAllowed(token,false) and fx:IsDescendantOf(workspace)
            and fx:GetAttribute("BossSpawnerFXActive")==true
    end
    if not boatDrive(destination,token,false,activeTarget,region) then return false end
    if not fx:IsDescendantOf(workspace) or fx:GetAttribute("BossSpawnerFXActive")~=true then return false end
    bossStatus("Rời ghế, đứng trên xe")
    if not boatStandOnDeck(activeTarget) then return false end
    Boss.target = fx
    Boss.caught = nil
    Boss.catchBaseline = {}
    for uid in pairs(bossInventory()) do Boss.catchBaseline[uid] = true end
    bossFace(fx.Position)
    Boss.fishing = true
    pendingCast, nextCastAt = true, os.clock()
    bossStatus("Đang câu boss")
    -- No fixed fight timeout: the actual region/weather controls this encounter.
    -- A Caught state alone can belong to an ordinary fish, so do not return on it.
    local goneAt
    local bagWasFull = false
    while bossAllowed(token,false) do
        local _,humanoid=bossCharacter()
        if humanoid and humanoid.SeatPart then
            Boss.fishing=false
            if not boatStandOnDeck(activeTarget) then break end
        end
        bossCheckCatch()
        if Boss.caught then break end
        local regionActive = fx:IsDescendantOf(workspace)
            and fx:GetAttribute("BossSpawnerFXActive") == true
        if not regionActive then
            -- Stop new casts immediately; confirm disappearance across several updates.
            Boss.fishing = false
            goneAt = goneAt or os.clock()
            if os.clock() - goneAt >= BOSS_OPTIONS.RegionGoneSeconds then
                bossStatus("Boss đã mất, chờ thu cần")
                break
            end
        else
            goneAt = nil
            Boss.fishing = true
            local full = bagFull()
            if full and not bagWasFull then
                bossStatus("Túi đầy; ngừng thả mới, chờ vùng boss mất hoặc hết thời tiết")
            elseif not full and bagWasFull then
                bossStatus("Đang câu boss")
            end
            bagWasFull = full
            if Fishing:GetState()==StateEnum.Idling and not isCasting then bossFace(fx.Position) end
        end
        task.wait(0.2)
    end
    Boss.fishing = false
    if not Boss.weather then
        bossStatus("Hết thời tiết, chờ thu cần")
    end
    -- Keep pulling/using skills until Idling; never move away mid-fight.
    if not bossDrain(true) then error("Đã tắt Auto Fishing hoặc mất nhân vật; chưa di chuyển") end
    Boss.target = nil
    Boss.catchBaseline = nil
    return true
end
local function bossReturn()
    Boss.fishing = false
    local home = Boss.home
    if not home then return true end
    if not State.AutoFish then return false end
    if not bossDrain(true) then return false end
    local token = Boss.cancel
    local originalPosition = home.cf.Position
    local parkingPosition=Boat.returnDock or (Boat.dock and Boat.dock.Position)
    if parkingPosition then
        bossStatus("Lái xe về điểm đỗ ngoài bãi")
        if not boatDrive(parkingPosition,token,true) then return false end
        boatBrake()
        local root,humanoid=bossCharacter()
        if not root then return false end
        humanoid.Sit=false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.5)
        if humanoid.SeatPart then
            root.CFrame=Boat.seat.CFrame*CFrame.new(0,6,0)
            task.wait(0.3)
        end
        if humanoid.SeatPart then return false end
        boatRelease()
    end
    bossStatus("Đã đỗ xe; quay lại điểm câu ban đầu")

    while bossAllowed(token,true) do
        local root = bossCharacter()
        if not root then return false end
        local distance = (root.Position-originalPosition).Magnitude
        if distance <= 0.5 then
            root.CFrame = home.cf
            root.Parent:FindFirstChildOfClass("Humanoid"):Move(Vector3.zero)
            Boss.home, Boss.target, Boss.fault = nil, nil, false
            pendingCast, nextCastAt = true, os.clock()+State.CastDelay
            bossStatus("Đã về điểm câu")
            return true
        end

        if not bossWalk(originalPosition,token,true,true) then
        else
            root = bossCharacter()
            if root and (root.Position-originalPosition).Magnitude <= 0.5 then
                root.CFrame = home.cf
                root.Parent:FindFirstChildOfClass("Humanoid"):Move(Vector3.zero)
                Boss.home, Boss.target, Boss.fault = nil, nil, false
                pendingCast, nextCastAt = true, os.clock()+State.CastDelay
                bossStatus("Đã về điểm câu")
                return true
            end
        end

        local waitUntil = os.clock()+RETURN_RETRY_SECONDS
        bossStatus("Chưa đúng điểm câu gốc; kiểm tra lại sau " .. RETURN_RETRY_SECONDS .. "s")
        while os.clock() < waitUntil do
            if not bossAllowed(token,true) then return false end
            root = bossCharacter()
            if root and (root.Position-originalPosition).Magnitude <= 0.5 then
                root.CFrame = home.cf
                root.Parent:FindFirstChildOfClass("Humanoid"):Move(Vector3.zero)
                Boss.home, Boss.target, Boss.fault = nil, nil, false
                pendingCast, nextCastAt = true, os.clock()+State.CastDelay
                bossStatus("Đã về điểm câu")
                return true
            end
            task.wait(0.2)
        end

    end
    return false
end
local function bossFinishReturn(weatherKey)
    Boss.returning=true
    Boss.fault=false
    local ok,returned=pcall(bossReturn)
    Boss.returning=false
    if ok and returned then
        Boss.busy=false
        Boss.completedWeather=weatherKey
    else
        Boss.fault=true
        bossStopMove()
        boatBrake()
        bossStatus(Boat.lastFailure and ("Xe dừng: "..Boat.lastFailure) or "Chưa về được, thử quay về")
    end
end
local function bossRun()
    local root = bossCharacter()
    local originalIsland = bossCurrentIsland()
    if not root or not originalIsland then error("Không xác định được đảo gốc từ vị trí nhân vật") end
    local homeCF = (FishingHome and FishingHome.cf) or root.CFrame
    Boss.home = {island=originalIsland, cf=homeCF}
    bossStatus("Chờ lượt câu kết thúc")
    if not bossDrain() then error("Chưa kết thúc lượt câu hiện tại") end
    local token = Boss.cancel
    Boss.regionObservations={}
    Boss.regionScanAt=nil
    Boss.patrolDestination,Boss.skipDestination=nil,nil
    Boss.patrolling=false
    boatPrepare(token)
    -- Leave the parking area immediately, before scanning the current island.
    local main=Boat.main
    local forward=Vector3.new(main.CFrame.LookVector.X,0,main.CFrame.LookVector.Z)
    if forward.Magnitude<0.001 then forward=Vector3.new(0,0,-1) end
    if not boatDrive(main.Position+forward.Unit*500,token,false,nil,nil,true) then
        error("Đã hủy bước chạy ra khỏi bãi xe")
    end
    Boss.caught, Boss.detected, Boss.catchBaseline = nil, nil, nil
    Boss.expectedFish = {}
    for weather, fishId in pairs(BOSS_FISH_BY_WEATHER) do
        if Boss.activeWeather and Boss.activeWeather[weather] then Boss.expectedFish[fishId] = true end
    end
    -- Loaded bosses on the current island are checked immediately by dispatchDetected.
    -- Begin travelling to the next island instead of waiting at the departure dock.
    local ordered = {}
    for _, island in ipairs(BOSS_ISLANDS) do
        if island ~= originalIsland then table.insert(ordered,island) end
    end
    table.insert(ordered,originalIsland)
    local function dispatchDetected()
        local detected = Boss.detected
        Boss.detected = nil
        if not detected then
            local fx, spot, island = bossFindLoaded()
            if fx then detected={fx=fx, spot=spot, island=island} end
        end
        if not detected then return false end
        Boss.patrolling = false
        if detected.fx:IsDescendantOf(workspace)
            and detected.fx:GetAttribute("BossSpawnerFXActive")==true then
            -- Travel only to the detected region; never resume the old destination first.
            if bossFight(detected.fx,detected.spot,token) then return true end
        end
        Boss.patrolling = true
        return false
    end
    Boss.patrolling = true
    for pass = 1, 2 do
        for _, island in ipairs(ordered) do
            if not bossAllowed(token,false) then Boss.patrolling=false; return end
            if dispatchDetected() then return end
            local observation=Boss.regionObservations and Boss.regionObservations[island.id]
            if not observation or not observation.empty then
                Boss.patrolDestination=island
                Boss.skipDestination=nil
                local arrived=bossTravel(island,token,false)
                Boss.patrolDestination=nil
                local skipped=Boss.skipDestination==island.id
                Boss.skipDestination=nil
                if dispatchDetected() then return end
                if arrived and not skipped then
                    local fx,spot,foundIsland=bossScan(island,token)
                    if fx then
                        Boss.detected={fx=fx,spot=spot,island=foundIsland}
                        if dispatchDetected() then return end
                    end
                end
            end
        end
    end
    Boss.patrolling = false
    bossStatus("Không thấy boss, quay về")
end

-- Discord weather notifier: observer is independent of Auto Fishing/Auto Boss.
local WeatherDiscord = {current = nil, queue = {}, generation = 0, status = "Đang tắt"}
local function discordStatus(message)
    WeatherDiscord.status = message
     -- Never print webhook URLs/tokens or response bodies.
end
local function validDiscordWebhook(url)
    if type(url) ~= "string" then return false end
    return url:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
        or url:match("^https://discord%.com/api/v%d+/webhooks/%d+/[%w_%-]+$") ~= nil
        or url:match("^https://discordapp%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
end
local function discordRequestFunction()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
    if type(http) == "table" and type(http.request) == "function" then return http.request end
end
-- Keep canonical event IDs through the observer and renderer.
local function weatherDisplayName(id)
    return id
end
local function discordQueue(title, description)
    if not State.DiscordWeather then return end
    if not validDiscordWebhook(State.DiscordWebhook) then
        discordStatus("Webhook chưa hợp lệ; nhập URL webhook của kênh Discord.")
        return
    end
    if not discordRequestFunction() then
        discordStatus("Môi trường chạy không hỗ trợ HTTP request để gửi Discord.")
        return
    end
    if #WeatherDiscord.queue >= 20 then
        discordStatus("Hàng đợi đầy; bỏ thông báo mới để tránh spam.")
        return
    end
    local styles = {
        weather_rain = {
            name = "Rain", icon = "🌧️", color = 3447003,
            detail = "Chờ cá cắn câu ngắn hơn • May mắn ×1.05",
        },
        weather_blood_moon = {
            name = "Blood Moon", icon = "🌕🩸", color = 15548997, ping = true,
            detail = "Máu cá giảm 20%",
        },
        weather_thunderstorm = {
            name = "Thunderstorm", icon = "⛈️", color = 15844367, ping = true,
            detail = "Sát thương kỹ năng tăng 10%",
        },
        weather_snowfall = {
            name = "Snowfall", icon = "❄️", color = 1146986,
            detail = "Tăng cơ hội chí mạng",
        },
        weather_void_storm = {
            name = "Void Storm", icon = "🌑", color = 10181046, ping = true,
            detail = "Giá bán cá tăng 20%",
        },
        weather_rainbow_rain = {
            name = "Rainbow Rain", icon = "🌈", color = 16738740,
            detail = "May mắn tăng 50%",
        },
    }
    local isStarting = description:sub(1, #"Bắt đầu:") == "Bắt đầu:"
    local weatherText = description:gsub("^Bắt đầu:%s*", "")
    local embeds, seen = {}, {}
    local pingEveryone = false

    for id in weatherText:gmatch("[^,\r\n]+") do
        id = id:match("^%s*(.-)%s*$")
        if not seen[id] and #embeds < 10 then
            seen[id] = true
            local style = styles[id]
            if style then
                table.insert(embeds, {
                    title = style.icon .. "  " .. style.name,
                    description = "**" .. style.detail .. "**",
                    color = style.color,
                    footer = {text = "FISHING • WEATHER"},
                    timestamp = DateTime.now():ToIsoDate(),
                })
                if isStarting and style.ping then pingEveryone = true end
            else
                table.insert(embeds, {
                    title = "🌤️  THÔNG BÁO THỜI TIẾT",
                    description = id,
                    color = 9807270,
                    footer = {text = "FISHING • WEATHER"},
                    timestamp = DateTime.now():ToIsoDate(),
                })
            end
        end
    end
    if #embeds == 0 then
        discordStatus("Không có nội dung để gửi")
        return
    end
    local payload = {
        username = "Con Cu Mau Den",
        content = pingEveryone and "@everyone" or "",
        allowed_mentions = {parse = pingEveryone and {"everyone"} or {}},
        embeds = embeds,
    }

    table.insert(WeatherDiscord.queue, {
        body = HttpService:JSONEncode(payload),
        url = State.DiscordWebhook,
        generation = WeatherDiscord.generation,
    })
    discordStatus("Đã xếp hàng thông báo thời tiết")
    return true
end -- discordQueue

local function discordSnapshot()
    if not State.DiscordWeather then return end
    local names = {}
    for id in pairs(WeatherDiscord.current or {}) do table.insert(names, weatherDisplayName(id)) end
    table.sort(names)
    discordQueue("Thời tiết hiện tại", #names > 0 and table.concat(names, "\n") or "Tin thử kết nối Discord")
end
local function discordObserveWeather(events)
    if type(events) ~= "table" then return end

    local current = {}

    for id, info in pairs(events) do
        if type(id) == "string" and id:sub(1, 8) == "weather_" then
            current[id] = tostring(
                type(info) == "table" and info.started_at or ""
            )
        end
    end

    local previous = WeatherDiscord.current
    WeatherDiscord.current = current

    -- Lần đọc đầu chỉ ghi nhận thời tiết đang có.
    if not previous or not State.DiscordWeather then return end

    local started = {}

    for id, stamp in pairs(current) do
        if previous[id] ~= stamp then
            table.insert(started, weatherDisplayName(id))
        end
    end

    -- Thời tiết kết thúc: cập nhật dữ liệu, không gửi tin.
    if #started == 0 then return end

    table.sort(started)

    discordQueue(
        "Thông báo thời tiết",
        "Bắt đầu: " .. table.concat(started, ", ")
    )
end
local function discordSetEnabled(enabled)
    State.DiscordWeather = enabled == true
    WeatherDiscord.generation = WeatherDiscord.generation + 1
    WeatherDiscord.queue = {}
    if State.DiscordWeather then
        discordStatus("Đang theo dõi; chỉ báo khi thời tiết bắt đầu")
    else
        discordStatus("Đang tắt")
    end
    save()
end
-- One sender prevents overlapping requests; only explicit rate limits are retried.
task.spawn(function()
    while task.wait(0.2) do
        local item = table.remove(WeatherDiscord.queue, 1)
        if item then
            local function valid()
                return State.DiscordWeather and item.generation == WeatherDiscord.generation
                    and item.url == State.DiscordWebhook
            end
            for attempt = 1, 3 do
                if not valid() then break end
                local send = discordRequestFunction()
                if not send then discordStatus("Không có HTTP request"); break end
                local ok, response = pcall(send, {
                    Url = item.url .. "?wait=true", Method = "POST",
                    Headers = {["Content-Type"] = "application/json"}, Body = item.body,
                })
                if not valid() then break end
                local status = ok and type(response) == "table" and tonumber(response.StatusCode or response.Status)
                if status and status >= 200 and status < 300 then
                    discordStatus("Đã gửi thông báo thành công")
                    break
                elseif status == 429 and attempt < 3 then
                    local decoded, data = pcall(function() return HttpService:JSONDecode(response.Body or "") end)
                    local delay = decoded and type(data) == "table" and tonumber(data.retry_after)
                    if not delay or delay ~= delay or delay < 0 or delay > 120 then
                        discordStatus("Discord giới hạn gửi; bỏ thông báo này."); break
                    end
                    discordStatus("Discord giới hạn gửi; đang chờ thử lại")
                    local deadline = os.clock() + delay + 0.5
                    while valid() and os.clock() < deadline do task.wait(0.1) end
                else
                    discordStatus(status and ("Gửi thất bại: HTTP " .. tostring(status))
                        or "Lỗi kết nối HTTP; kiểm tra hỗ trợ request của môi trường chạy.")
                    break
                end
            end
            task.wait(1)
        end
    end
end)

local function bossUpdateWeather(events)
    local notified = pcall(discordObserveWeather, events)
    if not notified then discordStatus("Không xử lý được dữ liệu thông báo thời tiết") end
    if type(events)~="table" then return end
    local keys = {}
    Boss.activeWeather = {}
    for id, info in pairs(events) do
        if type(id)=="string" and id:sub(1,8)=="weather_" then
            Boss.activeWeather[id] = true
            table.insert(keys,id .. ":" .. tostring(type(info)=="table" and info.started_at or ""))
        end
    end
    table.sort(keys)
    Boss.weather, Boss.weatherKey = #keys>0, table.concat(keys,"|")
    if not Boss.weather then Boss.completedWeather=nil end
end
-- Lazy initialization: an unavailable weather controller does not disable normal fishing.
task.spawn(function()
    local ok, err = pcall(function()
        local event = require(ReplicatedStorage.Controllers.EventController)
        event.ActiveEventsChanged:Connect(function() bossUpdateWeather(event:GetActiveEvents()) end)
        bossUpdateWeather(event:GetActiveEvents())
    end)
    if not ok then
        discordStatus("Không đọc được EventController; chưa thể theo dõi thời tiết")
        bossStatus("Không đọc được thời tiết: " .. tostring(err)); return
    end
    while task.wait(0.5) do
        if State.AutoFish and State.AutoBoss and Boss.weather and not Boss.busy and not isSelling and not manualTravelBusy
            and not Boss.home and Boss.completedWeather~=Boss.weatherKey then
            Boss.busy = true
            local weatherKey = Boss.weatherKey
            local ran, failure = xpcall(bossRun,tostring)
            Boss.fishing = false
            Boss.patrolling = false
            Boss.patrolDestination,Boss.skipDestination=nil,nil
            Boss.detected = nil
            Boss.catchBaseline = nil

            if not State.AutoFish then
                Boss.busy=false
                Boss.target=nil
                Boss.home=nil
                Boss.fault=false
                bossStopMove()
                bossStatus("Auto Boss đã dừng")
            else
                bossFinishReturn(weatherKey)
            end
        end
    end
end)

-- Giám sát điểm câu gốc trong suốt phiên Auto Fishing.
-- Không can thiệp khi đang bán cá, Auto Boss, manual travel hoặc có tác vụ di chuyển.
task.spawn(function()
    while task.wait(1) do
        pcall(restoreFishingHomeIfDrifted)
    end
end)

-- 8. CÁC HÀM XỬ LÝ CÂU CÁ
local function EquipRodIfNeeded()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    if not character or not humanoid then return false end

    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and Catalog.Rod.GetById(tool.Name) then
            return true
        end
    end

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and Catalog.Rod.GetById(tool.Name) then
                humanoid:EquipTool(tool)
                task.wait(0.3)
                return true
            end
        end
    end

    return false
end

local function GetCastTarget()
    local character = workspace:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    if Boss.fishing and Boss.target and Boss.target.Parent then
        return Boss.target.Position
    end
    return root.Position + root.CFrame.LookVector * 50
end

local function CastOnce()
    if not State.AutoFish or not bossCanCast() or isCasting or isSelling or Fishing:GetState() ~= StateEnum.Idling then
        return
    end

    if Boss.busy and bagFull() then return end
    if State.AutoSell and bagFull() then
        AutoSellFish()
        return
    end

    if not EquipRodIfNeeded() then
        return
    end

    if not State.AutoFish or not bossCanCast() then return end
    local target = GetCastTarget()
    if not target then return end

    isCasting = true

    local camera = workspace.CurrentCamera
    local centerPosition = camera and (camera.ViewportSize / 2) or Vector2.new(500, 300)

    local originalFire = packet.Fire
    local wrapper
    local sent = false

    local function Mouse(down)
        VirtualInputManager:SendMouseButtonEvent(
            centerPosition.X, 100, 0, down, game, 0
        )
    end

    local function Restore()
        if wrapper and packet.Fire == wrapper then
            packet.Fire = originalFire
        end
    end

    pcall(function()
        Mouse(true)
        local started = os.clock()

        repeat task.wait() until not State.AutoFish or Fishing:GetState() == StateEnum.Throwing or os.clock() - started >= 2
        if not State.AutoFish or not bossCanCast() or Fishing:GetState() ~= StateEnum.Throwing then return end

        while State.AutoFish and os.clock() - started < State.HoldTime do task.wait() end
        if not State.AutoFish or not bossCanCast() or Fishing:GetState() ~= StateEnum.Throwing then return end

        wrapper = function(self, originalLuck, originalTarget, ...)
            sent = true
            Restore()
            return originalFire(self, State.Luck, target, ...)
        end

        packet.Fire = wrapper
        Mouse(false)

        local deadline = os.clock() + 1
        while State.AutoFish and not sent and os.clock() < deadline do task.wait() end
    end)

    Restore()
    pcall(Mouse, false)
    isCasting = false
end

-- Observe inventory independently so a confirmed boss catch blocks the next cast.
task.spawn(function()
    while task.wait(0.05) do
        if Boss.busy and Boss.catchBaseline and not Boss.caught then
            pcall(bossCheckCatch)
        end
    end
end)

-- 9. KẾT NỐI EVENTS & LOOPS
Fishing.StateChanged:Connect(function(state)
    firstPullSent = false
    if state == StateEnum.Caught then pcall(bossCheckCatch) end
    if state == StateEnum.Caught or state == StateEnum.Escaped then
        pendingCast = true
        nextCastAt = os.clock() + State.CastDelay
    end
end)

Fishing.PullBarUpdated:Connect(function(value)
    if not State.AutoFish or firstPullSent or Fishing:GetState() ~= StateEnum.FirstPull then return end
    if value > 0.6769 then
        firstPullSent = true
        Fishing.FishFirstPull:Fire()
    end
end)

Fishing.FishQTEPrompt.OnClientEvent:Connect(function(direction)
    if not State.AutoFish or not Fishing:IsReeling() then return end
    local key = QTE_KEYS[direction]
    if key then
        task.wait(0.2)
        if State.AutoFish and Fishing:IsReeling() then Fishing.FishQTEResponse:Fire(key) end
    end
end)

task.spawn(function()
    while true do
        if State.AutoFish and (pendingCast or Fishing:GetState() == StateEnum.Idling) and not isCasting and not isSelling and bossCanCast() and os.clock() >= nextCastAt then
            pendingCast = false
            CastOnce()
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if State.AutoFish and Fishing:IsReeling() then
            sequence = (sequence % 65535) + 1
            Fishing.FishReelPull:Fire(sequence)
            task.wait(State.TapDelay)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoFish and Fishing:IsReeling() and not Fishing:IsAutoSession() then
            for i = 1, 4 do
                if not State.AutoFish or not Fishing:IsReeling() then break end

                local rodId = Rod:GetEquippedRodId()
                local data = Data:Fetch()
                local rodData = rodId and data and data.Rods and data.Rods[rodId]
                local config = rodId and Catalog.Rod.GetById(rodId)

                local slot = "Slot" .. i
                local skillId = rodData and rodData.BookSlots and rodData.BookSlots[slot]

                if config and i <= config.skillSlots and type(skillId) == "string" and skillId ~= "" then
                    local cooldown = Rod.CooldownActive and Rod.CooldownActive[slot]
                    local canUse = (cooldown == nil) or (cooldown.phase == "Cooldown" and type(cooldown.endTick) == "number" and cooldown.endTick <= tick())

                    if canUse then
                        Rod.Moveset:Fire(slot, skillId)
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- GIAO DIỆN: câu cá, di chuyển, gacha, Discord
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/UiRoblox.lua"))()

local Window = Library:Window({
    Title = "Fishing Master",
    Desc = "Câu cá • Săn boss",
    Icon = 71051887760757,
    Theme = "Dark",
    Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 520, 0, 420) },CloseUIButton = {
        Enabled = true,
        Icon = 71051887760757
    }
})

local MainTab = Window:Tab({Title = "Câu cá", Icon = "star"}) do
    MainTab:Section({Title = "Tự động"})

    MainTab:Toggle({
        Title = "Tự câu cá",
        Desc = "Tự trang bị và câu cá.",
        Value = State.AutoFish,
        Callback = function(v)
            State.AutoFish = v
            if v then
                captureFishingHome(true)
                pendingCast = true
                nextCastAt = os.clock()
            else
                Boss.cancel = Boss.cancel + 1
                Boss.fishing = false
                Boss.target = nil
                Boss.home = nil
                Boss.fault = false
                bossStopMove()
                boatRelease()
                FishingHome = nil
            end
            save()
        end
    })

    MainTab:Toggle({
        Title = "Săn boss",
        Desc = "Cần bật Tự câu cá.",
        Value = State.AutoBoss,
        Callback = function(v)
            State.AutoBoss = v
            if v then
                Boss.fault = false
                Boss.completedWeather = nil
            else
                local retryReturn=Boss.home and (Boss.fault or not Boss.busy)
                if not Boss.returning then
                    Boss.cancel=Boss.cancel+1
                    bossStopMove()
                    boatBrake()
                end
                Boss.fishing=false
                Boss.completedWeather=nil
                if Boss.home and State.AutoFish then
                    bossStatus("Dừng săn boss, chờ thu cần rồi lái về")
                    if retryReturn then
                        Boss.busy=true
                        task.spawn(function() bossFinishReturn(Boss.weatherKey) end)
                    end
                elseif not Boss.busy then
                    Boss.target=nil
                    Boss.fault=false
                    boatRelease()
                    bossStatus("Đang tắt")
                end
            end
            save()
        end
    })
    local bossLabel = MainTab:Label({Title="Trạng thái", Desc=Boss.status})
    task.spawn(function()
        local previous=Boss.status
        while task.wait(0.5) do
            if bossLabel and Boss.status~=previous then
                previous=Boss.status
                bossLabel:SetDesc(previous)
            end
        end
    end)
    MainTab:Button({
        Title = "Thử quay về",
        Callback = function()
            if not Boss.fault or not Boss.home or not State.AutoFish then return end
            Boss.fault=false
            Boss.busy=true
            task.spawn(function() bossFinishReturn(Boss.weatherKey) end)
        end
    })

    MainTab:Toggle({
        Title = "Tự bán cá",
        Desc = "Bán khi túi đầy, rồi quay về.",
        Value = State.AutoSell,
        Callback = function(v)
            State.AutoSell = v
            save()
        end
    })

    MainTab:Section({Title = "Khóa cá"})

    MainTab:Toggle({
        Title = "Tự khóa cá",
        Desc = "Theo độ hiếm đã chọn.",
        Value = State.AutoLock,
        Callback = function(v)
            State.AutoLock = v
            save()
        end
    })

    MainTab:Dropdown({
        Title = "Độ hiếm",
        List = RARITY_LIST,
        Multi = true,
        Value = State.SelectedRarity,
        Callback = function(list)
            State.SelectedRarity = list
            attemptedLock = {}
            save()
        end
    })

    MainTab:Button({
        Title = "Bán cá ngay",
        Callback = function()
            task.spawn(AutoSellFish)
        end
    })
    MainTab:Section({Title = "Cài đặt"})
    MainTab:Dropdown({
        Title = "Di chuyển trong đảo",
        List = {"WalkTo", "Tween"},
        Multi = false,
        Value = State.MovementMode,
        Callback = function(value)
            local mode = type(value) == "table" and value[1] or value
            if mode ~= "WalkTo" and mode ~= "Tween" then return end
            State.MovementMode = mode
            save()
        end
    })
end

local function islandCarSpawnPosition(island)
    local folder=bossIslandsFolder()
    local node=folder and folder:FindFirstChild(island.id)
    local spawn=node and node:FindFirstChild("CarSpawn")
    if not spawn then return nil end
    if spawn:IsA("BasePart") then return spawn.Position end
    if spawn:IsA("Model") then return spawn:GetPivot().Position end
    local part=spawn:FindFirstChildWhichIsA("BasePart",true)
    return part and part.Position
end
-- Manual island movement: selected boat/tween mode; independent of Auto Fish and weather.
local function travelToSelectedIsland(destination)
    if manualTravelBusy or isSelling or Boss.busy then
        manualTravelStatus = manualTravelBusy and "Đang di chuyển" or "Đang bận bán cá / săn boss"
        return
    end
    manualTravelBusy = true
    manualTravelStatus = "Chuẩn bị tới "..destination.id
    local useBoat=State.TeleportUseBoat==true
    local token = Boss.cancel
    task.spawn(function()
        local ok, err = xpcall(function()
            local root, humanoid = bossCharacter()
            if not root then error("Không tìm thấy nhân vật") end
            local originalCharacter = root.Parent
            local function canContinue()
                local currentRoot = bossCharacter()
                return Boss.cancel == token and currentRoot ~= nil
                    and currentRoot.Parent == originalCharacter
            end
            -- Stop new casts; let the existing catch finish before starting to walk.
            local deadline = os.clock() + BOSS_OPTIONS.DrainSeconds
            while isCasting or Fishing:GetState() ~= StateEnum.Idling do
                manualTravelStatus="Chờ thu cần"
                if not canContinue() then error("Đã hủy di chuyển") end
                if os.clock() > deadline then error("Chưa kết thúc lượt câu; hãy thu cần rồi chọn lại đảo") end
                task.wait(0.1)
            end
            if not canContinue() then error("Đã hủy di chuyển") end
            root = bossCharacter()
            if not root then error("Không tìm thấy nhân vật") end
            local mapPosition=islandZoneInfo(destination,root.Position)
            local spot=mapPosition or nearestIslandSpot(destination,root.Position)
            if useBoat then
                -- Reuse an already occupied driver seat; otherwise spawn via the merchant.
                boatRelease()
                Boat.lastFailure=nil
                manualTravelStatus="Chuẩn bị xe"
                if boatBind() and humanoid.SeatPart==Boat.seat then
                    Boat.dock=Boat.model:GetPivot()
                    Boat.departurePending=true
                else
                    boatPrepare(token,canContinue)
                end
                manualTravelStatus="Đang lái tới "..destination.id
                if not boatDrive(spot,token,false,canContinue,nil,nil,destination,nil,islandZoneInfo) then
                    error(Boat.lastFailure or ("Xe chưa đến "..destination.id))
                end
            else
                manualTravelStatus="Đang tới "..destination.id
                local arrived=false
                for attempt=1,3 do
                    if not canContinue() then break end
                    root=bossCharacter()
                    local target,inZone=islandZoneInfo(destination,root.Position)
                    if inZone then arrived=true; break end
                    tweenTo(target or spot,nil,function()
                        local currentRoot=bossCharacter()
                        if not canContinue() or not currentRoot then return false end
                        local _,entered=islandZoneInfo(destination,currentRoot.Position)
                        return not entered
                    end)
                    root=bossCharacter()
                    if not root or not canContinue() then break end
                    local _,entered=islandZoneInfo(destination,root.Position)
                    if entered then arrived=true; break end
                end
                if not arrived then error("Chưa vào Size zone "..destination.id) end
            end
            manualTravelStatus="Đang tới gần CarSpawn"
            local spawnPosition=islandCarSpawnPosition(destination)
            local spawnDeadline=os.clock()+3
            while not spawnPosition and os.clock()<spawnDeadline do
                if not canContinue() then error("Đã hủy di chuyển") end
                task.wait(0.1)
                spawnPosition=islandCarSpawnPosition(destination)
            end
            if not spawnPosition then error("Chưa thấy CarSpawn của "..destination.id) end
            if useBoat then
                Boat.lastFailure=nil
                if not boatDrive(spawnPosition,token,false,canContinue,nil,nil,nil,50) then
                    error(Boat.lastFailure or "Chưa tới gần CarSpawn")
                end
            elseif not tweenTo(spawnPosition,25,canContinue) then
                error("Chưa tới gần CarSpawn")
            end
            -- The selected island becomes the new fishing home after a manual trip.
            if State.AutoFish then captureFishingHome(true) end
            manualTravelStatus="Đã tới gần CarSpawn "..destination.id
        end, tostring)
        if not ok then
            local message=tostring(err):gsub("^.-:%d+:%s*", "")
            manualTravelStatus=message
            bossStopMove()
        end
        if useBoat then boatRelease() end
        manualTravelBusy = false
        nextCastAt = os.clock() + State.CastDelay
    end)
end

do
    local function getIslandName(fx)
        -- Hierarchy: Workspace.World.Islands.island_desert.BossRegions.1.BossSpawnerFX
        local current = fx.Parent
        while current and current ~= workspace do
            if current.Parent and current.Parent.Name == "Islands" then
                return current.Name -- Trả về tên thư mục đảo (ví dụ: island_desert)
            end
            current = current.Parent
        end
        -- Dự phòng nếu không tìm thấy cây thư mục Islands
        return fx.Parent and fx.Parent.Parent and fx.Parent.Parent.Name or "Chưa rõ Đảo"
    end

    local TeleportTab = Window:Tab({Title = "Di chuyển", Icon = "map-pin"}) do
     TeleportTab:Section({Title = "Boss"})

    local BossStatusUI = TeleportTab:Label({
        Title = "Vùng boss",
        Desc = "Đang kiểm tra"
    })

        TeleportTab:Section({Title = "Chọn đảo"})
        local travelLabel=TeleportTab:Label({Title="Di chuyển",Desc=manualTravelStatus})
        task.spawn(function()
            local previous=manualTravelStatus
            while task.wait(0.5) do
                if manualTravelStatus~=previous then
                    previous=manualTravelStatus
                    travelLabel:SetDesc(previous)
                end
            end
        end)
        TeleportTab:Toggle({
            Title = "Đi bằng xe",
            Desc = "Tắt để dùng Tween.",
            Value = State.TeleportUseBoat==true,
            Callback = function(value)
                State.TeleportUseBoat=value==true
                save()
            end,
        })
        TeleportTab:Button({
            Title = "Dừng",
            Callback = function()
                if not manualTravelBusy then return end
                Boss.cancel=Boss.cancel+1
                bossStopMove()
            end,
        })

        local islandNames = {"Starter", "Jungle", "Desert", "Snow", "Volcano", "Fossil"}
        for index, island in ipairs(BOSS_ISLANDS) do
            TeleportTab:Button({
                Title = islandNames[index],
                Desc = "",
                Callback = function()
                    travelToSelectedIsland(island)
                end
            })
        end
        task.spawn(function()
            local previous
            while task.wait(1) do
                local found, active = 0, 0
                local activeLocations = {}

                local folder=bossIslandsFolder()
                for _, fx in ipairs(folder and folder:GetDescendants() or {}) do
                    if fx:IsA("BasePart") and fx.Name == "BossSpawnerFX" then
                        found += 1
                        local state = fx:GetAttribute("BossSpawnerFXActive")

                        if state == true then
                            active += 1
                            -- Lấy trực tiếp tên đảo từ hierarchy Workspace
                            local islandName = getIslandName(fx)
                            table.insert(activeLocations, islandName)
                        end
                    end
                end

                local text
                if active>0 then
                    text="Boss: "..table.concat(activeLocations,", ")
                elseif found==0 then
                    text="Chưa tải vùng boss"
                else
                    text="Chưa có boss"
                end
                if BossStatusUI and text~=previous then
                    previous=text
                    BossStatusUI:SetDesc(text)
                end
            end
        end)
    end
end

local GachaTab = Window:Tab({Title = "Gacha", Icon = "gift"}) do
    GachaTab:Section({Title = "Aura"})

    GachaTab:Button({
        Title = "Aura ×1",
        Callback = function()
            local result = AuraGacha.Pull:Fire(1)

        end
    })

    GachaTab:Button({
        Title = "Aura ×10",
        Callback = function()
            local result = AuraGacha.Pull:Fire(10)

        end
    })

    GachaTab:Section({Title = "Skill"})

    GachaTab:Button({
        Title = "Skill ×1",
        Callback = function()
            local result = SkillGacha.Pull:Fire("NpcCoin", 1)

        end
    })

    GachaTab:Button({
        Title = "Skill ×10",
        Callback = function()
            local result = SkillGacha.Pull:Fire("NpcCoin", 10)

        end
    })
end

local DiscordTab = Window:Tab({Title = "Discord", Icon = "bell"}) do
    DiscordTab:Section({Title = "Thông báo thời tiết"})
    DiscordTab:Textbox({
        Title = "Webhook",
        Desc = "Dán webhook rồi nhấn Enter.",
        Value = State.DiscordWebhook, Placeholder = "https://discord.com/api/webhooks/...",
        ClearText = true,
        Callback = function(value)
            local url = tostring(value):match("^%s*(.-)%s*$")
            if not validDiscordWebhook(url) then
                discordStatus("URL không hợp lệ; giữ webhook cũ."); return
            end
            if url == State.DiscordWebhook then return end
            State.DiscordWebhook = url
            WeatherDiscord.generation = WeatherDiscord.generation + 1
            WeatherDiscord.queue = {}
            save()
            discordStatus("Đã lưu webhook")
        end,
    })
    DiscordTab:Toggle({
        Title = "Báo thời tiết",
        Desc = "Chỉ báo khi thời tiết bắt đầu.",
        Value = false, Callback = discordSetEnabled,
    })
    DiscordTab:Button({
        Title = "Gửi thử",
        Callback = function()
            if not State.DiscordWeather then discordStatus("Hãy bật gửi Discord trước"); return end
            discordStatus("Đang tạo tin gửi thử...")
            local ok = pcall(discordSnapshot)
            if not ok then
                discordStatus("Không gửi được tin thử.")
            end
        end,
    })
    local statusLabel = DiscordTab:Label({Title = "Trạng thái", Desc = WeatherDiscord.status})
    task.spawn(function()
        local previous=WeatherDiscord.status
        while task.wait(0.5) do
            if statusLabel and WeatherDiscord.status~=previous then
                previous=WeatherDiscord.status
                statusLabel:SetDesc(previous)
            end
        end
    end)
end
