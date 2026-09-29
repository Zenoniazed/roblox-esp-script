-- ============================================================================
-- LIGHT HACK - AUTO FISHING, VIP PATHFINDING AI, GACHA & MULTI AUTO-LOCK
-- ============================================================================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
    MovementMode = "WalkTo",            -- WalkTo hoặc Tween
    TweenSpeed = 20,                    -- studs/giây
    AutoSell = true,                    -- Tự động bán cá khi đầy túi
    AutoLock = true,                    -- Bật/Tắt tự động khóa cá
    SelectedRarity = {"Mythical", "Legendary"}, -- Chọn nhiều độ hiếm cá cần khóa
    CastDelay = 1,                      -- Khoảng chờ giữa các lần ném cần
    TapDelay = 0.03,                     -- Tốc độ nhấp kéo cá (reeling)
    HoldTime = 0.5,                     -- Thời gian giữ chuột khi ném cần
    Luck = 1,                           -- Chỉ số Luck khi quăng cần
}

local function save()
    if writefile then
        writefile(CONFIG, HttpService:JSONEncode(State))
        print("💾 Saved config successfully.")
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
            print("📂 Loaded config successfully.")
        end
    end
end

load()
if State.MovementMode ~= "WalkTo" and State.MovementMode ~= "Tween" then
    State.MovementMode = "WalkTo"
end
local loadedTweenSpeed = tonumber(State.TweenSpeed)
State.TweenSpeed = (loadedTweenSpeed and loadedTweenSpeed == loadedTweenSpeed)
    and math.clamp(loadedTweenSpeed, 5, 150) or 40

-- 3. CÁC BIẾN QUẢN LÝ AUTO LOCK & PATHFINDING
local Boss
local manualTravelBusy = false
local sequence = 0
local firstPullSent = false
local isCasting = false
local isSelling = false
local pendingCast = false
local nextCastAt = os.clock()

local SafePathsCache = {} -- Bộ nhớ VIP Pathfinding
local currentPathId = 0
local attemptedLock = {}   -- Lịch sử các UID cá đã thử khóa

local QTE_KEYS = {
    Left = "A",
    Up = "W",
    Right = "D",
    Down = "S",
}

local packet = Fishing.FishCast
if type(packet) ~= "table" or table.isfrozen(packet) then
    warn("[LightHack] Không thể hook hàm Fire trên packet FishCast!")
end

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

    if ok and status == SellStatus.Ok and locked == true then
        print(string.format("[AutoLock] ✅ Đã khóa cá %s [%s] | UID: %s", tostring(fish.name or id), tostring(fish.rarity), tostring(uid)))
    else
        warn(string.format("[AutoLock] ❌ Chưa xác nhận khóa UID: %s | Status: %s | Locked: %s", tostring(uid), tostring(status), tostring(locked)))
    end
    task.wait(0.2)
end

task.spawn(function()
    local lastWarning = 0
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

            if not ok and os.clock() - lastWarning >= 5 then
                lastWarning = os.clock()
                warn("[AutoLock Error]", err)
            end
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

-- 6. THUẬT TOÁN PATHFINDING AI VIP CACHE (THUẦN ĐI BỘ - KHÔNG NHẢY)
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
    -- Project endpoints onto collidable ground instead of the portal pivot/attachment height.
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
        -- Search both sides and the back of the portal, nearer candidates first.
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
            warn("[walkTo] Không có mặt đất đi được trong 10 studs quanh cổng; kiểm tra vị trí cổng/độ cao.")
            return false
        end
    else
        table.insert(candidates, position)
        local ground = groundAt(position)
        if ground then table.insert(candidates, ground) end
    end

    -- 1. TRUY XUẤT BỘ NHỚ VIP CACHE
    for targetPos, savedWaypoints in pairs(SafePathsCache) do
        if not stopDistance and (position - targetPos).Magnitude <= 3
            and savedWaypoints[1] and (root.Position-savedWaypoints[1]).Magnitude <= 12 then
            print("🧠 AI: Kích hoạt đường VIP mượt cho NPC / Điểm câu...")

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
                        warn("⚡ Đường VIP bị vật cản mới chặn, xóa bộ nhớ, tự động vẽ lại đường...")
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
        warn("[walkTo] NoPath sau khi thử " .. #candidates .. " điểm đích. Có thể đường bị chặn hoặc map chưa tải đủ.")
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
                warn("⚡ Đường mới bị kẹt thực tế! Hủy bỏ và vẽ lại đường...")
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

    -- 3. LƯU LỘ TRÌNH VIP MỚI NẾU ĐI THÀNH CÔNG
    if not isStuckDuringPath and currentPathId == myPathId and #tempWaypointsPositions > 0 then
        warn("💾 AI: Ghi nhớ thành công lộ trình VIP mới mượt mà!")
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
        -- Aim slightly inside the radius so portal distance checks still pass.
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
    end, debug.traceback)
    cleanup()
    if not ok then warn("[Tween] " .. tostring(reached)); return false end
    return reached
end

local function moveTo(position, stopDistance, shouldContinue)
    if State.MovementMode == "Tween" then
        return tweenTo(position, stopDistance, shouldContinue)
    end
    cancelMovementTween()
    return walkTo(position, stopDistance, shouldContinue)
end

-- 7. LOGIC AUTO SELL FISH & RETURN (CÓ KHÔI PHỤC HƯỚNG NHÌN CŨ)
local function AutoSellFish()
    if isSelling or manualTravelBusy or (Boss and Boss.busy) then return end
    isSelling = true

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        isSelling = false
        return
    end

    -- 1. Lưu lại điểm câu cá và HƯỚNG CÂU CÁ BAN ĐẦU (CFrame)
    local originalCFrame = root.CFrame
    local originalSpot = root.Position
    print("[LightHack] Đã lưu vị trí và hướng nhìn câu ban đầu:", tostring(originalCFrame))
    print("[LightHack] Balo cá đầy! Đang tìm NPC npc_fish_seller_1...")

    -- 2. Chạy tới NPC bán cá
    local npc = FindNPC("npc_fish_seller_1")
    local npcPos, npcCFrame = GetNPCPosition(npc)

    if npcPos then
        local targetPos = npcPos + (npcCFrame and npcCFrame.LookVector * 4 or Vector3.new(0, 0, 4))
        print("[LightHack] Đang di chuyển tới NPC bán cá...")
        
        local reached = moveTo(targetPos)
        if not reached then
            warn("[LightHack] Không thể đi tới NPC bán cá!")
            isSelling = false
            return
        end
    else
        warn("[LightHack] Không tìm thấy NPC npc_fish_seller_1!")
        isSelling = false
        return
    end

    task.wait(0.5)

    -- 3. Bán cá & Kiểm tra Status == 0
    local status, coins, count = Sell:SellAll()
    
    if status == 0 then
        print(string.format("[LightHack] ✅ Bán cá THÀNH CÔNG! Coins nhận: %s | Số lượng: %s", tostring(coins), tostring(count)))
    else
        warn(string.format("[LightHack] ❌ Bán cá THẤT BẠI! Status Code: %s", tostring(status)))
    end
    
    task.wait(0.5)

    -- 4. Quay về vị trí cũ bằng Pathfinding và QUAY LẠI HƯỚNG CÂU BAN ĐẦU
    print("[LightHack] Đang di chuyển quay trở lại điểm câu cũ...")
    local returned = moveTo(originalSpot)

    -- Xoay nhân vật quay đúng hướng câu cá ban đầu
    if root and character then
        root.CFrame = CFrame.new(root.Position) * originalCFrame.Rotation
        print("[LightHack] 🔄 Đã khôi phục hướng nhìn câu cá ban đầu!")
    end

    task.wait(0.5)
    isSelling = false
end

-- AUTO BOSS: one worker owns movement; only fast travel changes islands.
Boss = {
    busy = false, fishing = false, home = nil, target = nil,
    weather = false, weatherKey = "", completedWeather = nil,
    cancel = 0, status = "Chờ bật Auto Fishing + Auto Boss", fault = false,
}
local BOSS_OPTIONS = {
    ScanSeconds = 5, StreamSeconds = 15, TravelSeconds = 20,
    -- Chọn điểm đứng gần vùng boss active nhất, không giới hạn khoảng cách.
    DrainSeconds = 120, RegionGoneSeconds = 1,
}
local BOSS_ISLANDS = {
    {id="island_starter", portal="fast_travel_island_1", spots={Vector3.new(-4,11,303), Vector3.new(-275,10,490)}},
    {id="island_jungle", portal="fast_travel_island_2", spots={Vector3.new(-1164, 7, -152), Vector3.new(-1483,11,-257)}},
    {id="island_desert", portal="fast_travel_island_3", spots={Vector3.new(-86,10,-951), Vector3.new(192,10,-1156)}},
    {id="island_snow", portal="fast_travel_island_4", spots={Vector3.new(1176,9,-411),Vector3.new(1455, 10, -182)}},
    {id="island_volcano", portal="fast_travel_island_5", spots={Vector3.new(1794,9,1031), Vector3.new(2241,9,1147)}},
    {id="island_fossil", portal="fast_travel_island_6", spots={Vector3.new(-584,11,2171),Vector3.new(-1128, 9, 2600)}},
}
local function bossStatus(message)
    Boss.status = message
    print("[AutoBoss] " .. message)
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
local function bossPortalPosition(island)
    local folder = bossIslandsFolder()
    local node = folder and folder:FindFirstChild(island.portal, true)
    if not node then return nil end
    local prompt = node:FindFirstChildWhichIsA("ProximityPrompt", true)
    local anchor = prompt and prompt.Parent
    if anchor and anchor:IsA("Attachment") then return anchor.WorldPosition end
    if anchor and anchor:IsA("BasePart") then return anchor.Position end
    return GetNPCPosition(node)
end
local function bossCurrentIsland()
    local root = bossCharacter()
    if not root then return nil end
    local best, distance
    for _, island in ipairs(BOSS_ISLANDS) do
        local p = bossPortalPosition(island)
        if p then
            local d = (root.Position-p).Magnitude
            if not distance or d < distance then best, distance = island, d end
        end
    end
    return best
end
local function bossStopMove()
    cancelMovementTween()
    currentPathId = currentPathId + 1
    local root, humanoid = bossCharacter()
    if root then humanoid:Move(Vector3.zero) end
end
local function bossCanCast()
    if manualTravelBusy then return false end
    return not Boss.busy or (Boss.fishing and State.AutoBoss and Boss.weather
        and Boss.target and Boss.target:IsDescendantOf(workspace)
        and Boss.target:GetAttribute("BossSpawnerFXActive") == true)
end
local function bossAllowed(token, returning)
    return token == Boss.cancel and State.AutoFish and bossCharacter() ~= nil
        and (returning or (State.AutoBoss and Boss.weather))
end
-- Auto Boss uses the selected shared movement mode.
local function bossWalk(position, token, returning, stopDistance)
    if not bossAllowed(token, returning) then bossStopMove(); return false end
    local root, humanoid = bossCharacter()
    if humanoid.Sit then humanoid.Sit = false; task.wait(0.3) end
    local reached = moveTo(position, stopDistance, function()
        return bossAllowed(token, returning)
    end)
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
local TRAVEL_COOLDOWN = 12
local nextTravelAt = 0
local function markTravelArrival()
    nextTravelAt = math.max(nextTravelAt, os.clock() + TRAVEL_COOLDOWN)
end
local function requestIslandTravel(destination, sourcePortal, canContinue)
    local remaining = nextTravelAt - os.clock()
    if remaining > 0 then
        print(string.format("[Travel] Chờ %.1f giây hồi cổng...", remaining))
    end
    while os.clock() < nextTravelAt do
        if not canContinue() then return false, "Đã hủy trong lúc chờ hồi cổng" end
        task.wait(math.min(0.1, nextTravelAt - os.clock()))
    end
    if not canContinue() then return false, "Đã hủy travel" end
    local root = bossCharacter()
    if not root or (root.Position-sourcePortal).Magnitude > 10 then
        return false, "Đã ra ngoài phạm vi 10 studs của cổng"
    end
    local ctrl = require(ReplicatedStorage.Controllers.FastTravelController)
    local ok, result = pcall(function() return ctrl.TravelToIsland:Fire(destination.id) end)
    -- A failed/ambiguous response must not cause rapid repeated requests either.
    nextTravelAt = os.clock() + TRAVEL_COOLDOWN
    if not ok or (result ~= 0 and result ~= 1) then return false, result end
    return true, result
end
-- Status 0 is the successful response used by the normal FastTravel UI.
-- Confirm the relocation independently of the destination portal's streaming/distance.
local function travelArrivalConfirmed(destination, before, result)
    local root = bossCharacter()
    if not root or (root.Position-before).Magnitude <= 100 then return false end
    if result == 0 then return true end
    -- Status 1 is ambiguous: still require destination evidence for this response.
    local portal = bossPortalPosition(destination)
    return portal ~= nil and (root.Position-portal).Magnitude < 100
end
local function bossTravel(destination, token, returning)
    if not bossAllowed(token, returning) then return false end
    local current = bossCurrentIsland()
    if current == destination then return true end
    if not current then error("Không xác định được cổng đảo hiện tại") end
    local portal = bossPortalPosition(current)
    bossStatus("Đi bộ đến " .. current.portal)
    if not portal or not bossWalk(portal, token, returning, 7) then return false end
    if not bossAllowed(token, returning) then return false end
    local root = bossCharacter()
    if not root or (root.Position - portal).Magnitude > 10 then return false end
    local before = root.Position
    local ok, result = requestIslandTravel(destination, portal, function()
        return bossAllowed(token, returning)
    end)
    if not ok or (result ~= 0 and result ~= 1) then
        warn("[AutoBoss] Travel bị từ chối: ", destination.id, result)
        return false
    end
    -- Match the normal UI cleanup; its window otherwise keeps movement locked.
    pcall(function() require(ReplicatedStorage.Controllers.UIController):Close("FastTravel") end)
    local deadline = os.clock()+BOSS_OPTIONS.TravelSeconds
    repeat
        if travelArrivalConfirmed(destination, before, result) then
            markTravelArrival()
            bossStatus("Đã tới " .. destination.id)
            return true
        end
        -- Even on cancellation, settle the in-flight request before returning home.
        task.wait(0.2)
    until os.clock() > deadline or not State.AutoFish
    error("Chưa xác nhận đến đảo " .. destination.id .. "; giữ tạm dừng câu")
end
local function bossFind(island)
    local folder = bossIslandsFolder()
    local node = folder and folder:FindFirstChild(island.id)
    if not node then return nil end
    local bestFX, bestSpot, bestDistance
    for _, fx in ipairs(node:GetDescendants()) do
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
local function bossScan(island, token)
    -- Arrival can precede streaming of the island's BossRegions.
    local deadline = os.clock()+BOSS_OPTIONS.StreamSeconds
    repeat
        if not bossAllowed(token, false) then return nil end
        local folder = bossIslandsFolder()
        local node = folder and folder:FindFirstChild(island.id)
        if node and node:FindFirstChild("BossSpawnerFX", true) then break end
        task.wait(0.25)
    until os.clock()>deadline
    deadline = os.clock()+BOSS_OPTIONS.ScanSeconds
    repeat
        if not bossAllowed(token, false) then return nil end
        local fx, spot = bossFind(island)
        if fx then return fx, spot end
        task.wait(0.25)
    until os.clock()>deadline
end
local function bossFace(position)
    local root = bossCharacter()
    if root then
        local target = Vector3.new(position.X,root.Position.Y,position.Z)
        if (target-root.Position).Magnitude>0.1 then root.CFrame=CFrame.lookAt(root.Position,target) end
    end
end
local function bossFight(fx, spot, token)
    bossStatus("Phát hiện boss; đi tới điểm đứng câu")
    if not bossWalk(spot,token,false) then return false end
    if not fx:IsDescendantOf(workspace) or fx:GetAttribute("BossSpawnerFXActive")~=true then return false end
    Boss.target = fx
    bossFace(fx.Position)
    Boss.fishing = true
    pendingCast, nextCastAt = true, os.clock()
    bossStatus("Đang câu boss")
    -- No fixed fight timeout: the actual region/weather controls this encounter.
    -- A Caught state alone can belong to an ordinary fish, so do not return on it.
    local goneAt
    local bagWasFull = false
    while bossAllowed(token,false) do
        local regionActive = fx:IsDescendantOf(workspace)
            and fx:GetAttribute("BossSpawnerFXActive") == true
        if not regionActive then
            -- Stop new casts immediately; confirm disappearance across several updates.
            Boss.fishing = false
            goneAt = goneAt or os.clock()
            if os.clock() - goneAt >= BOSS_OPTIONS.RegionGoneSeconds then
                bossStatus("Vùng boss đã biến mất/tắt; chờ lượt câu kết thúc rồi quay về")
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
        bossStatus("Thời tiết đã kết thúc; chờ lượt câu hiện tại rồi quay về")
    end
    -- Keep pulling/using skills until Idling; never move away mid-fight.
    if not bossDrain(true) then error("Đã tắt Auto Fishing hoặc mất nhân vật; chưa di chuyển") end
    Boss.target = nil
    return true
end
local function bossReturn()
    Boss.fishing = false
    if not Boss.home then return true end
    if not State.AutoFish then return false end
    if not bossDrain(true) then return false end
    local token = Boss.cancel
    bossStatus("Quay về " .. Boss.home.island.id)
    if not bossTravel(Boss.home.island,token,true) then return false end
    if not bossWalk(Boss.home.cf.Position,token,true) then return false end
    local root = bossCharacter()
    if not root then return false end
    root.CFrame = CFrame.new(root.Position)*Boss.home.cf.Rotation
    Boss.home, Boss.target, Boss.fault = nil, nil, false
    pendingCast, nextCastAt = true, os.clock()+State.CastDelay
    bossStatus("Đã về điểm câu và khôi phục hướng nhìn")
    return true
end
local function bossRun()
    local root = bossCharacter()
    local originalIsland = bossCurrentIsland()
    if not root or not originalIsland then error("Không tìm thấy cổng travel để xác định đảo gốc") end
    Boss.home = {island=originalIsland, cf=root.CFrame}
    bossStatus("Lưu điểm câu; chờ lượt câu hiện tại kết thúc")
    if not bossDrain() then error("Chưa kết thúc lượt câu hiện tại") end
    local token = Boss.cancel
    local MAX_PASSES = 2
    for pass = 1, MAX_PASSES do
        for _, island in ipairs(BOSS_ISLANDS) do
            if not bossAllowed(token,false) then return end
            local data = Data:Fetch()
            local meta = Catalog.Island.GetById(island.id)
            local unlocked = island == originalIsland
                or island.id == "island_starter"   -- đảo mặc định, luôn mở
                or (meta and meta.defaultUnlocked==true)
                or (data and data.UnlockedIslands and data.UnlockedIslands[island.id]==true)
            if not unlocked then
                print(("[AutoBoss] Bỏ qua %s: chưa mở khóa (meta=%s, data=%s)"):format(
                    island.id, tostring(meta and meta.defaultUnlocked),
                    tostring(data and data.UnlockedIslands and data.UnlockedIslands[island.id])))
            elseif not bossTravel(island,token,false) then
                print("[AutoBoss] Travel thất bại tới " .. island.id)
            else
                local fx, spot = bossScan(island,token)
                if fx and bossFight(fx,spot,token) then return end
                print("[AutoBoss] Không có boss ở " .. island.id)
            end
        end
        task.wait(1)
    end
    bossStatus("Đã dò hết các đảo, không có boss; quay về")
end
local function bossUpdateWeather(events)
    if type(events)~="table" then return end
    local keys = {}
    for id, info in pairs(events) do
        if type(id)=="string" and id:sub(1,8)=="weather_" then
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
    if not ok then bossStatus("Không đọc được thời tiết: " .. tostring(err)); return end
    while task.wait(0.5) do
        if State.AutoFish and State.AutoBoss and Boss.weather and not Boss.busy and not isSelling and not manualTravelBusy
            and not Boss.home and Boss.completedWeather~=Boss.weatherKey then
            Boss.busy = true
            local weatherKey = Boss.weatherKey
            local ran, failure = xpcall(bossRun,debug.traceback)
            Boss.fishing = false
            if not ran then warn("[AutoBoss] ", failure) end
            local returned, success = pcall(bossReturn)
            if returned and success then
                Boss.busy = false
                Boss.completedWeather = weatherKey
            else
                Boss.fault = true
                bossStopMove()
                bossStatus("Đang tạm dừng. Bật Auto Fishing rồi bấm Thử quay về điểm câu.")
            end
        end
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

    warn("[LightHack] Không tìm thấy Tool cần câu trong Backpack!")
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
            centerPosition.X, 50, 0, down, game, 0
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

-- 9. KẾT NỐI EVENTS & LOOPS
Fishing.StateChanged:Connect(function(state)
    firstPullSent = false
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

-- 10. GIAO DIỆN UI (LIGHT HACK UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/UiRoblox.lua"))()

local Window = Library:Window({
    Title = "Light Hack",
    Desc = "Auto Fishing, Multi-Lock & VIP Pathfinding",
    Icon = 71051887760757,
    Theme = "Dark",
    Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 520, 0, 420) },CloseUIButton = {
        Enabled = true,
        Icon = 71051887760757
    }
})

local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Chế độ di chuyển"})
    MainTab:Dropdown({
        Title = "Di chuyển: WalkTo / Tween",
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
    MainTab:Label({
        Title = "WalkTo: đi bộ tìm đường | Tween: di chuyển thẳng",
        Desc = "Áp dụng cho Boss, bán cá/quay về và cổng travel. Đổi chế độ có hiệu lực từ lượt di chuyển tiếp theo."
    })

    MainTab:Section({Title = "Fishing System"})

    MainTab:Toggle({
        Title = "Auto Fishing",
        Desc = "Auto Equip Rod, Cast & Pull",
        Value = State.AutoFish,
        Callback = function(v)
            State.AutoFish = v
            if v then pendingCast = true; nextCastAt = os.clock()
            else Boss.cancel = Boss.cancel + 1; bossStopMove() end
            save()
        end
    })

    MainTab:Toggle({
        Title = "Auto Boss",
        Desc = "Bật cùng Auto Fishing: dò boss theo thời tiết, di chuyển + fast travel, quay về",
        Value = State.AutoBoss,
        Callback = function(v)
            State.AutoBoss = v
            if not v then
                Boss.cancel = Boss.cancel + 1
                Boss.fishing = false
                bossStopMove()
            end
            save()
        end
    })
    local bossLabel = MainTab:Label({Title="Auto Boss", Desc=Boss.status})
    task.spawn(function()
        while task.wait(0.5) do
            if bossLabel then bossLabel:SetDesc(Boss.status) end
        end
    end)
    MainTab:Button({
        Title = "Thử quay về điểm câu",
        Callback = function()
            if not Boss.fault or not Boss.home or not State.AutoFish then return end
            Boss.fault = false
            task.spawn(function()
                local ok, returned = pcall(bossReturn)
                if ok and returned then
                    Boss.busy = false
                    Boss.completedWeather = Boss.weatherKey
                else
                    Boss.fault = true
                    bossStopMove()
                    bossStatus("Chưa quay về được; kiểm tra đường/cổng rồi thử lại")
                end
            end)
        end
    })

    MainTab:Toggle({
        Title = "Auto Sell Fish & Return (VIP AI)",
        Desc = "Di chuyển tới NPC bán cá và quay về vị trí câu cũ",
        Value = State.AutoSell,
        Callback = function(v)
            State.AutoSell = v
            save()
        end
    })

    MainTab:Section({Title = "Auto Lock Fish Settings"})

    MainTab:Toggle({
        Title = "Auto Lock Fish",
        Desc = "Tự động khóa các loại cá thuộc độ hiếm đã chọn",
        Value = State.AutoLock,
        Callback = function(v)
            State.AutoLock = v
            save()
        end
    })

    MainTab:Dropdown({
        Title = "Độ Hiếm Cá Khóa (Lock Rarities)",
        List = RARITY_LIST,
        Multi = true,
        Value = State.SelectedRarity,
        Callback = function(list)
            State.SelectedRarity = list
            attemptedLock = {}
            save()
            print("[AutoLock] Đã cập nhật danh sách độ hiếm khóa cá!")
        end
    })

    MainTab:Button({
        Title = "Sell & Return Now",
        Callback = function()
            task.spawn(AutoSellFish)
        end
    })
end

local GachaTab = Window:Tab({Title = "Gacha", Icon = "gift"}) do
    GachaTab:Section({Title = "Aura Gacha"})

    GachaTab:Button({
        Title = "Quay Aura Gacha x1",
        Callback = function()
            local result = AuraGacha.Pull:Fire(1)
            if not (result and result.ok) then warn("[LightHack] Lỗi Quay Aura:", result and result.reason) end
        end
    })

    GachaTab:Button({
        Title = "Quay Aura Gacha x10",
        Callback = function()
            local result = AuraGacha.Pull:Fire(10)
            if not (result and result.ok) then warn("[LightHack] Lỗi Quay Aura x10:", result and result.reason) end
        end
    })

    GachaTab:Section({Title = "Skill Gacha (NpcCoin)"})

    GachaTab:Button({
        Title = "Quay Skill Gacha x1",
        Callback = function()
            local result = SkillGacha.Pull:Fire("NpcCoin", 1)
            if not (result and result.ok) then warn("[LightHack] Lỗi Quay Skill x1:", result and result.reason) end
        end
    })

    GachaTab:Button({
        Title = "Quay Skill Gacha x10",
        Callback = function()
            local result = SkillGacha.Pull:Fire("NpcCoin", 10)
            if not (result and result.ok) then warn("[LightHack] Lỗi Quay Skill x10:", result and result.reason) end
        end
    })
end

-- Manual island travel: nearest loaded portal -> selected movement -> FastTravel packet.
local function travelToSelectedIsland(destination)
    if manualTravelBusy or isSelling or Boss.busy then
        warn("[Teleport] Đang di chuyển/bán cá/Auto Boss; hãy chờ hoàn tất.")
        return
    end
    manualTravelBusy = true
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
                if not canContinue() then error("Đã hủy di chuyển") end
                if os.clock() > deadline then error("Chưa kết thúc lượt câu; hãy thu cần rồi chọn lại đảo") end
                task.wait(0.1)
            end
            if not canContinue() then error("Đã hủy di chuyển") end
            local current = bossCurrentIsland()
            if not current then error("Không tìm thấy cổng travel gần nhất đã được tải") end
            if current == destination then
                print("[Teleport] Bạn đang ở " .. destination.id)
                return
            end
            local portal = bossPortalPosition(current)
            if not portal then error("Cổng chưa được tải") end
            print("[Teleport] Di chuyển tới cổng gần nhất: " .. current.portal)
            if humanoid.Sit then humanoid.Sit = false; task.wait(0.3) end
            if not moveTo(portal, 7, canContinue) then error("Không đi được tới phạm vi 7 studs quanh cổng") end
            root = bossCharacter()
            if not canContinue() or not root or (root.Position - portal).Magnitude > 10 then
                error("Chưa ở trong phạm vi cổng hoặc đã hủy")
            end
            local before = root.Position
            local accepted, result = requestIslandTravel(destination, portal, canContinue)
            if not accepted then
                error("Travel bị từ chối: " .. tostring(result) .. "; kiểm tra đảo đã mở khóa")
            end
            pcall(function() require(ReplicatedStorage.Controllers.UIController):Close("FastTravel") end)
            deadline = os.clock() + BOSS_OPTIONS.TravelSeconds
            repeat
                if travelArrivalConfirmed(destination, before, result) then
                    markTravelArrival()
                    print("[Teleport] Đã đến " .. destination.id)
                    return
                end
                task.wait(0.2)
            until os.clock() > deadline
            error("Chưa xác nhận đến đảo " .. destination.id)
        end, debug.traceback)
        if not ok then
            bossStopMove()
            warn("[Teleport] " .. tostring(err))
        end
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

    local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"}) do
     TeleportTab:Section({Title = "Trạng Thái Boss"})

    local BossStatusUI = TeleportTab:Label({
        Title = "Đang kiểm tra Boss...",
        Desc = "Đang quét danh sách vùng Spawner..."
    })

        TeleportTab:Section({Title = "Travel qua cổng gần nhất"})

        local islandNames = {"Starter", "Jungle", "Desert", "Snow", "Volcano", "Fossil"}
        for index, island in ipairs(BOSS_ISLANDS) do
            TeleportTab:Button({
                Title = "Đảo " .. index .. " - " .. islandNames[index],
                Desc = "Dùng chế độ đã chọn tới cổng trong 10 studs rồi fast travel",
                Callback = function()
                    travelToSelectedIsland(island)
                end
            })
        end
        task.spawn(function()
            while task.wait(1) do
                local found, active = 0, 0
                local activeLocations = {}

                for _, fx in ipairs(workspace:GetDescendants()) do
                    if fx:IsA("BasePart") and fx.Name == "BossSpawnerFX" then
                        found += 1
                        local state = fx:GetAttribute("BossSpawnerFXActive")

                        if state == true then
                            active += 1
                            -- Lấy trực tiếp tên đảo từ hierarchy Workspace
                            local islandName = getIslandName(fx)
                            table.insert(activeLocations, string.format("• Boss đang ở: %s", islandName))
                        end
                    end
                end

                if BossStatusUI then
                    if found == 0 then
                        BossStatusUI:SetTitle("⚠️ Chưa phát hiện vùng Boss")
                        BossStatusUI:SetDesc("Map chưa load ")
                    elseif active > 0 then
                       BossStatusUI:SetTitle(string.format("🔥 BOSS ACTIVE: %s", table.concat(activeLocations, ", ")))
                        BossStatusUI:SetDesc("Đã phát hiện Boss xuất hiện!")
                        
                    else
                        BossStatusUI:SetTitle("🔴 Không có Boss nào Active")
                        BossStatusUI:SetDesc(string.format("Đang quét"))
                    end
                end
            end
        end)
    end
end
