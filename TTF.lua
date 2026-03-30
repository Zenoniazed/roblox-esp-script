task.wait(3)

--================ SERVICES ================
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

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
local distanceFrame = healthFrame:WaitForChild("DistanceFrame") -- Thay đổi ở đây
local fishNameLabel = healthFrame:WaitForChild("FishName")

local chargeMain = playerGui:WaitForChild("Charge"):WaitForChild("Main")
local luckBar = chargeMain:WaitForChild("Back"):WaitForChild("Fill")


local sellGUI = playerGui:WaitForChild("SellGUI")
local buttonMain = sellGUI:WaitForChild("Main")
local buttonAll = buttonMain:WaitForChild("All") -- ImageButton
local buttonClose = buttonMain:WaitForChild("Close")

local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events
local castPressRemote = eventsFolder:GetChildren()[12]  -- Index 9: Nhấn
local castReleaseRemote = eventsFolder:GetChildren()[60] -- Index 20: Thả


-- Thông báo đầy rương
local notificationFrame = playerGui:WaitForChild("Notification"):WaitForChild("Frame")
local gachaUI = player.PlayerGui:WaitForChild("GachaUI")
local chargeUI = player.PlayerGui:WaitForChild("Charge"):WaitForChild("Main")


--================ STATE ================
local CONFIG = "TitanFishing.json"

local state = {
    AutoFish = false,
	AutoBoss = false,
	EnableSpam2=false,
    LuckThreshold = 0.1,
    SpamDelay = 0.04,
    WaitNext = 2,
    SelectedRarity = {"Rare","Epic","Legendary","Mythic","Divine"},
	AutoGacha = false,
    GachaDelay = 1,
    RodSettings = {
		["Taoist Rod"] = {},
		["Spirit Wood Rod"] = {},
		["Ice Rod"] = {},
		["Diamond Dragon Rod"] = {},
		["Abyssal Rod"] = {},
		["Phi Thien Rod"] = {},
		["3 in 1 Diamond Threaded Steel Rod"] = {},
		["3 in 1 Gold Threaded Steel Rod"] = {},
		["3 in 1 Threaded Steel Rod"] = {},
		["Titanium Steel Rod"] = {},
		["Steel Rod"] = {},
		["Bamboo Rod"] = {},
		["Golden Rod"] = {},
		["Stone Rod"] = {},
		["Gold Plated Rod"] = {},
		["Rusty Iron Rod"] = {},
		["Upgraded Wooden Rod"] = {},
        ["Wooden Rod"] = {},
    },
	AutoScanSubmit = false,
	AutoSubmit = false,
	SubmitDelay = 5,
	ScanMethod="Animation",
}

local IslandPositions = {
    ["Island 1"] = CFrame.new(271, 22, 53),
    ["Island 2"] = CFrame.new(1749, 19, -383),
    ["Island 3"] = CFrame.new(897, 20, 1241),
    ["Island 4"] = CFrame.new(791, 21, -985),
    ["Island 5"] = CFrame.new(-423, 22, 961)
}

local isHuntingBoss = false
local originalPos = nil        -- Lưu vị trí câu cũ
local originalRarities = {}
local isSelling = false 
local isMoving = false  

local function save()
    if writefile then
        local success, err = pcall(function()
            writefile(CONFIG, HttpService:JSONEncode(state))
        end)
        if success then print("💾 Config Saved!") else warn("❌ Save Error:", err) end
    end
end

local function load()
    if isfile and isfile(CONFIG) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG))
        end)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                -- Chỉ ghi đè nếu state cũ có phím đó để tránh lỗi dữ liệu rác
                if state[k] ~= nil then
                    state[k] = v
                end
            end
            print("📂 Config Loaded!")
        end
    end
end

-- Gọi load ngay lập tức trước khi tạo UI
load()

local ALL_RARITIES = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine"}
local SKILL_OPTIONS = {"Skill 4", "Skill 3", "Skill 2", "Skill 1"}
local MY_RODS = {"Taoist Rod","Spirit Wood Rod","Ice Rod","Diamond Dragon Rod","Abyssal Rod","Phi Thien Rod","3 in 1 Diamond Threaded Steel Rod","3 in 1 Gold Threaded Steel Rod","3 in 1 Threaded Steel Rod","Titanium Steel Rod","Steel Rod","Bamboo Rod","Golden Rod","Stone Rod","Gold Plated Rod","Rusty Iron Rod","Upgraded Wooden Rod","Wooden Rod"}

local dangSpam = false
local fishHooked = false
local lastCastTime = 0
local scanning = false
local globalTargetBoss = nil

--================ LOGIC NHẢY (JUMP LOGIC) ================
task.spawn(function()
    while true do
        -- CHỈ nhảy khi AutoFish đang BẬT và đang có lệnh di chuyển (isMoving)
        if state.AutoFish and isMoving then
            local s = humanoid:GetState()
            if s ~= Enum.HumanoidStateType.Jumping and s ~= Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        task.wait(0.5) -- Kiểm tra mỗi 0.5s để không bị spam quá mức
    end
end)

local function getActiveBossIsland()
    local BossZones = workspace:FindFirstChild("BossZones")
    if not BossZones then return nil end
    
    for _, island in pairs(BossZones:GetChildren()) do
        local zone = island:FindFirstChild("BossSpawnZone")
        -- Nếu Zone có chứa vật thể (Boss/Model) bên trong
        if zone and #zone:GetChildren() > 0 then
            return island.Name
        end
    end
    return nil
end

task.spawn(function()
    while true do
        globalTargetBoss = getActiveBossIsland() -- Luôn cập nhật tên Boss mỗi 1 giây
        task.wait(1)
    end
end)

local function clickGui(guiObject)
    if not guiObject then return end
    
    -- 1. Ưu tiên firesignal (Cực mượt nếu executor hỗ trợ)
    if firesignal then
        firesignal(guiObject.MouseButton1Click)
        firesignal(guiObject.MouseButton1Down)
        firesignal(guiObject.Activated)
        if guiObject:IsA("ImageButton") or guiObject:IsA("TextButton") then
            firesignal(guiObject.TouchTap)
        end
    else
        -- 2. Dùng VirtualInputManager giả lập theo tọa độ nhưng không cộng 36
        -- Cách này dùng AbsolutePosition nên PC hay Mobile đều trúng tâm nút
        local pos = guiObject.AbsolutePosition
        local size = guiObject.AbsoluteSize
        local centerX = pos.X + (size.X / 2)
        local centerY = pos.Y + (size.Y / 2) + (game:GetService("GuiService"):GetGuiInset().Y)
        
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
end

--================ DI CHUYỂN THÔNG MINH ================
local function smartMoveTo(targetPos)
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
    path:ComputeAsync(hrp.Position, targetPos)
    if path.Status ~= Enum.PathStatus.Success then return end

    isMoving = true
    for _, waypoint in ipairs(path:GetWaypoints()) do
        if not state.AutoFish then break end -- Dừng nếu tắt Auto
        humanoid:MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid.MoveToFinished:Wait()
    end
    isMoving = false
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

local savedCastPos = nil


local PRESS_IDX = 9   
local RELEASE_IDX = 22
local GACHA_IDX = 3
local SUBMIT_IDX = 1

-- ========== HÀM TRANG BỊ (TÌM VÀ CẦM) ================
--================ VỆ SĨ TRANG BỊ (CHẠY RIÊNG BIỆT) ================
local function forceEquipRod()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    if not humanoid or not backpack then return end

    -- 1. Kiểm tra xem trên tay đã có cần câu chưa (tìm item có tên chứa "Rod")
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and string.find(string.lower(currentTool.Name), "rod") then
        return -- Đã cầm đúng cần rồi, không làm gì thêm
    end

    -- 2. Nếu chưa cầm, tìm trong Backpack và trang bị ngay
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "rod") then
            humanoid:EquipTool(tool)
            break 
        end
    end
end

-- Vòng lặp kiểm tra liên tục (Tách biệt hoàn toàn với logic câu cá)
task.spawn(function()
    while true do
        -- ĐIỀU KIỆN: Chỉ cầm khi bật Auto Fishing HOẶC đang bật Dò Skill
        -- Lưu ý: Kiểm tra lại biến state.AutoFish của bạn xem có đúng tên không
        if state.AutoFish then
            forceEquipRod()
        end
        task.wait(0.5) -- Kiểm tra mỗi 0.5 giây
    end
end)

local function teleCastPost()
	if savedCastPos then
		local distance = (hrp.Position - savedCastPos.Position).Magnitude
		if distance > 3 then
		local targetPos = savedCastPos.Position 
			
			hrp.CFrame = CFrame.new(targetPos, targetPos + savedCastPos.LookVector)

			task.wait(0.2)
		end
		isMoving = false 
		elseif not savedCastPos then
			savedCastPos = hrp.CFrame
		end
end
--================ HÀM QUĂNG CẦN CHUẨN ================
local function castRod()
    if isSelling or not state.AutoFish then return end

    local remotes = eventsFolder:GetChildren()
    local pRemote = remotes[PRESS_IDX]
    local rRemote = remotes[RELEASE_IDX]

    if pRemote and rRemote then
		fishHooked = false
        lastCastTime = tick()
        pRemote:FireServer()
        
        local start = tick()
        repeat 
            task.wait(0.05)
        until luckBar.Size.Y.Scale >= state.LuckThreshold or (tick() - start) > 3
        
        rRemote:FireServer()
    else
        warn("⚠️ Index Remote đang bị sai! Hãy kiểm tra lại F9.")
    end
end
--================ ĐI BÁN VÀ QUAY LẠI ================
local function sellAndReturn()
    if isSelling or not state.AutoFish then return end
    isSelling = true
    dangSpam = false
    local oldCFrame = hrp.CFrame
    local npc = getNearestFishSeller()
    
    if npc then
	
		
        -- smartMoveTo(npc.Position + Vector3.new(3, 0, 3))
		hrp.CFrame = CFrame.new(npc.Position + Vector3.new(3, 0, 3), npc.Position)
		-- hrp.CFrame = CFrame.new(targetPos, targetPos + savedCastPos.LookVector)
        task.wait(2) -- Đợi bán
		local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            -- Kích hoạt nhấn E
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
        end
		task.wait(1)
		clickGui(buttonAll)
		task.wait(1)
		clickGui(buttonClose)
		task.wait(1)

        hrp.CFrame = oldCFrame
        
    end
    
    isSelling = false
    task.wait(1)

    castRod()
end

local function isFishHooked()
    return healthFrame.Visible 
end
--================ CHECK TARGET FISH ================
local function isTargetFish()
    local name = fishNameLabel.Text
    for _, r in ipairs(state.SelectedRarity) do
        if string.find(name, r) then return true end
    end
    return false
end



local SKILL_IDX = 4 
local skillFound = false
local AutoDoSkill = false
local healthUI = player.PlayerGui:WaitForChild("FishStats"):WaitForChild("HealthFrame"):WaitForChild("HealthText")
local SKILL_IDX_SPAM = 4

function breakVelocity()
    local char = Players.LocalPlayer.Character
    if not char then return end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            -- API mới (QUAN TRỌNG)
            v.AssemblyLinearVelocity = Vector3.zero
            v.AssemblyAngularVelocity = Vector3.zero
            
            -- Backup API cũ (giữ lại cho chắc)
            v.Velocity = Vector3.zero
            v.RotVelocity = Vector3.zero
        end
    end
end

local function startScanningIndex()
    if not scanning then return end
    
    task.spawn(function()

        local remotes = eventsFolder:GetChildren()
        PRESS_IDX = nil
        RELEASE_IDX = nil

        -- GIAI ĐOẠN 1: Tìm PRESS (Làm thanh gồng nhảy Scale > 0)
        print("🔍 Đang dò PRESS_IDX...", "Yellow")
        for i = 1, #remotes do
            if not scanning then return end

			forceEquipRod()
            
            -- Đảm bảo thanh bar về 0 trước khi thử
            if luckBar.Size.Y.Scale > 0 then
                task.wait(0.2) 
            end

            remotes[i]:FireServer()
            task.wait(0.2) -- Đợi server phản hồi Scale
            
            -- Xử lý UI Gacha
            gachaUI.Enabled = false
            if gachaUI:FindFirstChild("Background") then
                gachaUI.Background.Visible = false
            end

            if luckBar.Size.Y.Scale > 0 then
                PRESS_IDX = i
                print("✅ PRESS_IDX là: [" .. i .. "]", "Green")
                break
            end
        end

        -- GIAI ĐOẠN 2: Tìm RELEASE (Làm thanh gồng reset về 0)
        if PRESS_IDX and scanning then
            print("🔍 Đang dò RELEASE_IDX (Reset từ 1)...", "Yellow")
            task.wait(1)
            
            for i = 1, #remotes do
                if not scanning then return end
                if i == PRESS_IDX then continue end 

                -- Phải gồng lên trước khi thử Release
                if luckBar.Size.Y.Scale == 0 then
                    remotes[PRESS_IDX]:FireServer()
                    task.wait(0.2)
                end

                remotes[i]:FireServer()
                task.wait(0.2)

                if luckBar.Size.Y.Scale == 0 then
                    RELEASE_IDX = i
                    print("✅ RELEASE_IDX là: [" .. i .. "]", "Green")
                    scanning = false -- Dừng scan khi đã tìm thấy cả hai
                    break
                end
            end
        end

        if not PRESS_IDX or not RELEASE_IDX then
            if scanning then -- Chỉ in thông báo lỗi nếu người dùng chưa chủ động tắt scan
                print("❌ Thất bại! Hãy thử đứng gần nước hơn.", "Red")
            end
        end
        
        scanning = false
    end)
end

local function getCleanID(animString)
    return tostring(animString):match("%d+") 
end

local function startSpamming()
    if dangSpam then return end
    dangSpam = true
    
    task.spawn(function()
        local allEvents = eventsFolder:GetChildren()
        local player = game.Players.LocalPlayer
        local EXCLUDE_ANIMS = {
            [getCleanID("rbxassetid://122883590821614")] = true,
            [getCleanID("rbxassetid://108204492506097")] = true,
            [getCleanID("rbxassetid://77480657409571")] = true,
            [getCleanID("http://www.roblox.com/asset/?id=180435571")] = true,
            [getCleanID("http://www.roblox.com/asset/?id=180435792")] = true
        }

        while dangSpam and state.AutoFish do
            -- Treo máy đợi cá nếu mất bảng máu
            if not healthFrame.Visible then
                repeat task.wait(1) until healthFrame.Visible or not dangSpam
                if not dangSpam then break end
                task.wait(0.5)
            end

            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid then task.wait(0.5) continue end
            
            if AutoDoSkill and not skillFound then
                -- Ghi lại máu trước khi thử (Dùng cho mode HP)
                local currentHealthStr = healthUI.Text 

                -- GIAI ĐOẠN DÒ: Giữ nguyên đoạn bạn yêu cầu
                local testRemote = allEvents[SKILL_IDX]
				if testRemote then
					-- 2. CHỈ LẤY 1 TÊN CẦN CÂU ĐỂ THỬ (Tránh spam 18 lần cho 1 Index)
					local firstRodName = next(state.RodSettings) 
					
					if firstRodName then
						pcall(function()
							-- CHỈ GỌI 1 LẦN DUY NHẤT Ở ĐÂY
							testRemote:FireServer("Wooden Rod", 1) 
							task.wait(0.05)
							-- Giữ nguyên logic ẩn UI Gacha
							gachaUI.Enabled = false
							if gachaUI:FindFirstChild("Background") then
								gachaUI.Background.Visible = false
							end
						end)
					end
				end
                -- if testRemote then
                --     for rodName, _ in pairs(state.RodSettings) do
                --         pcall(function()
                --             testRemote:FireServer(rodName, 1) 
                --             -- Xử lý UI Gacha (Giữ nguyên)
                --             gachaUI.Enabled = false
                --             if gachaUI:FindFirstChild("Background") then
                --                 gachaUI.Background.Visible = false
                --             end
                --         end)
                --     end
                -- end

                -- Đợi tùy theo mode (HP cần đợi lâu hơn để server trừ máu)
                task.wait(state.ScanMethod == "HP" and 0.4 or 0.12) 

                local hasDetected = false

                -- CHẾ ĐỘ 1: DÒ THEO HP
                if state.ScanMethod == "HP" then
                    if healthUI.Text ~= currentHealthStr then
                        hasDetected = true
                    end
                -- CHẾ ĐỘ 2: DÒ THEO ANIMATION (Mặc định)
                else
                    local tracks = humanoid:GetPlayingAnimationTracks()
                    for _, track in ipairs(tracks) do
                        local cleanID = getCleanID(track.Animation.AnimationId)
                        if cleanID and not EXCLUDE_ANIMS[cleanID] then
                            hasDetected = true
                            break
                        end
                    end
                end

                if hasDetected then
                    skillFound = true
                    SKILL_IDX_SPAM = SKILL_IDX
                    print("🎯 Đã tìm thấy Remote! Index: [" .. SKILL_IDX .. "]")
                else
                    SKILL_IDX = SKILL_IDX + 1
                    if SKILL_IDX > #allEvents then SKILL_IDX = 1 end
                end
            else
                -- GIAI ĐOẠN SPAM: Đã tìm thấy Remote
                local skillRemote = allEvents[SKILL_IDX_SPAM]
                if skillRemote then
                    for rodName, selectedSkills in pairs(state.RodSettings) do
                        for _, skillText in ipairs(selectedSkills) do
                            local skillID = tonumber(string.match(skillText, "%d+"))
                            if skillID then
                                pcall(function() 
                                    skillRemote:FireServer(rodName, skillID) 
                                end)
								task.wait(state.SpamDelay)
                            end
                        end
                    end
					
                end
                
            end
            
            if not skillFound then task.wait(0.05) end
        end
        dangSpam = false
    end)
end

local dangSpam2 = false
--================ SPAM SKILLS 2 (ĐỘC LẬP) ================
local function startSpamming2()
    if dangSpam2 then return end -- Tránh chạy chồng nhiều vòng lặp
    dangSpam2 = true

    task.spawn(function()
        -- Lấy Remote (Dựa trên code cũ của bạn là cái thứ 4)
        local remotes = eventsFolder:GetChildren()
        local skillRemote = remotes[SKILL_IDX_SPAM]
        
        -- Chạy khi biến EnableSpam2 còn bật
        while state.EnableSpam2 do
            -- Duyệt qua danh sách Rod và Skill người dùng chọn
            for rodName, selectedSkills in pairs(state.RodSettings) do
                if not state.EnableSpam2 then break end
                
                for _, skillText in ipairs(selectedSkills) do
                    if not state.EnableSpam2 then break end
                    
                    -- Lấy ID từ chuỗi "Skill 1" -> 1
                    local skillID = tonumber(string.match(skillText, "%d+"))
                    if skillID and skillRemote then
                        pcall(function()
                            skillRemote:FireServer(rodName, skillID)
                        end)
                    end
					task.wait(state.SpamDelay)
                end
            end
             
        end
        
        dangSpam2 = false
        print("🛑 Đã dừng Spam Skill 2")
    end)
end

local function startScanningSubmit()
    task.spawn(function()
        local allEvents = eventsFolder:GetChildren()
        print("🔍 Đang bắt đầu dò tìm chính xác...", "Yellow")
        
        for i = SUBMIT_IDX, #allEvents do
            if not state.AutoScanSubmit then break end
            
            SUBMIT_IDX = i
            local testRemote = allEvents[i]
            
            if testRemote and testRemote:IsA("RemoteEvent") then
                -- Bước 1: Ghi nhận số lượng thông báo cũ trước khi bấm
                local oldNotificationCount = #notificationFrame:GetChildren()
                
                -- Bước 2: Bắn Remote
                pcall(function()
                    testRemote:FireServer() 
                end)
                
                -- Bước 3: Đợi thông báo MỚI xuất hiện (tối đa 0.5s)
                local foundNew = false
                local startWait = tick()
                
                while tick() - startWait < 0.5 do
                    local currentNotifications = notificationFrame:GetChildren()
                    
                    -- Chỉ kiểm tra những thông báo mới xuất hiện sau khi bắn Remote
                    for j = 1, #currentNotifications do
                        local child = currentNotifications[j]
                        local label = child:IsA("TextLabel") and child or child:FindFirstChildOfClass("TextLabel")
                        
                        if label and label.Visible then
                            local text = label.Text
                            -- KIỂM TRA CHÍNH XÁC TEXT TẠI ĐÂY
                            if string.find(text, "No valid fish") or string.find(text, "Event is not active") then
								SUBMIT_IDX = i
                                print("🎯 CHUẨN XÁC! Remote [" .. i .. "] báo: " .. text, "Green")
                                state.AutoScanSubmit = false
                                return -- Dừng toàn bộ vòng lặp khi tìm thấy
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end
            
            -- Tăng delay giữa các lần thử để tránh bị loạn thông báo
            task.wait(0.1)
        end
        print("🏁 Đã quét xong danh sách.")
    end)
end


healthFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not state.AutoFish or isSelling then return end

    if healthFrame.Visible then
       
        fishHooked = true
        if isTargetFish() then
            startSpamming()
        end
    else
        dangSpam = false
		task.wait(state.WaitNext)
        task.wait(0.5)
        if state.AutoBoss and globalTargetBoss and not isHuntingBoss then
            print("⚡ CÂU XONG RỒI! Đi săn Boss tại: " .. globalTargetBoss)
            
            isHuntingBoss = true
			
            local targetPos = IslandPositions[globalTargetBoss]
            local bossZoneFolder = workspace.BossZones:FindFirstChild(globalTargetBoss)
            local spawnZone = bossZoneFolder and bossZoneFolder:FindFirstChild("BossSpawnZone")

            if targetPos and spawnZone then
                -- Teleport và xoay mặt
                local lookAtTarget = Vector3.new(spawnZone.Position.X, targetPos.Y, spawnZone.Position.Z)
                hrp.CFrame = CFrame.lookAt(targetPos.Position, lookAtTarget)
                task.wait(0.2)
                castRod() 
            end

        elseif isHuntingBoss and not globalTargetBoss then
            isHuntingBoss = false
            teleCastPost()
            task.wait(0.5)
            castRod()
            
        elseif isHuntingBoss and globalTargetBoss then
			castRod() 
		else
			teleCastPost()
            castRod()
        end
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
		local gachaEvents = eventsFolder:GetChildren()
		local gachaRemote = gachaEvents[GACHA_IDX]
        
        while state.AutoGacha do
		 
            pcall(function() 
                gachaRemote:FireServer() 
            end) 
			gachaUI.Enabled = false
            -- Tắt cả cái khung Background bên trong (nếu có)
            if gachaUI:FindFirstChild("Background") then
                gachaUI.Background.Visible = false
            end
            
            task.wait(state.GachaDelay)
        end
    end)
end

-- Hàm chạy Auto Submit (Đã sửa lỗi)
local function startAutoSubmit()
    task.spawn(function()
        while state.AutoSubmit do
            local allEvents = eventsFolder:GetChildren()
            local SubmitRemote = allEvents[SUBMIT_IDX] -- Lấy trực tiếp theo Index hiện tại
            
            if SubmitRemote and SubmitRemote:IsA("RemoteEvent") then
                pcall(function() 
                    SubmitRemote:FireServer() 
                end)
            end
            task.wait(state.SubmitDelay)
        end
    end)
end

--================ LOAD UI LIBRARY & WINDOW ================
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
    Value = state.AutoFish, -- Sử dụng giá trị đã load từ file
    Callback = function(v)
        state.AutoFish = v
        save() -- Lưu trạng thái
		isMoving = false
        if v then
			isMoving = false
            task.wait(1)
            castRod()
        else
            dangSpam = false
            isMoving = false    -- Đã sửa thành biến cục bộ
            isSelling = false   -- Reset luôn trạng thái bán cá (nếu đang dở)
            
        end
    end
})

Tab:Toggle({
    Title = "Auto Hunt Boss",
    Description = "Tự động di chuyển đến đảo có Boss khi xuất hiện",
    Value = state.AutoBoss,
    Callback = function(v)
        state.AutoBoss = v
        save() -- Lưu cấu hình để lần sau mở lại vẫn giữ trạng thái
        if not v then
            isHuntingBoss = false -- Reset trạng thái nếu tắt đột ngột
        end
    end
})

Tab:Dropdown({
    Title = "Fish Rarity",
    Multi = true,
    List = ALL_RARITIES,
    Value = state.SelectedRarity, -- Sử dụng giá trị đã load từ file
    Callback = function(list) 
        state.SelectedRarity = list 
        save() -- Lưu danh sách độ hiếm đã chọn
    end
})

Tab:Slider({
    Title = "Spam Delay (ms)",
    Min = 20, Max = 300,
    Value = state.SpamDelay * 1000,
    Callback = function(v) 
        state.SpamDelay = v / 1000 
        save() -- Lưu độ trễ spam
    end
})


Tab:Toggle({
    Title = "🚀 Tự Động Dò Index (LuckBar Logic)",
    Default = false,
    Callback = function(v)
        scanning = v
        if v then
            startScanningIndex() -- Gọi function đã tách
        end
    end
})

Tab:Slider({
    Title = "Press Index (Gồng)",
    Min = 1, Max = 100,
    Value = PRESS_IDX,
    Callback = function(v)
        PRESS_IDX = v
    end
})

Tab:Slider({
    Title = "Release Index (Thả)",
    Min = 1, Max = 100,
    Value = RELEASE_IDX,
    Callback = function(v)
        RELEASE_IDX = v
    end
})

Tab:Dropdown({
    Title = "Phương pháp dò",
	Multi = false,
    List = {"Animation", "HP"},
    Value = state.ScanMethod,
    Callback = function(v)
        state.ScanMethod = v
		print("🔄 Đã chuyển sang chế độ dò bằng: " .. v)
        
        -- Reset lại trạng thái dò khi đổi phương pháp để tránh lỗi nhận nhầm
        skillFound = false 
        SKILL_IDX = 1 
        save() -- Lưu vào config
    end
})

 -- Mặc định là 4 như code cũ của bạn
Tab:Toggle({
    Title = "🔍 Chế độ Dò Skill Tự Động",
    Default = false,
    Callback = function(v)
        AutoDoSkill = v
        if v then
            skillFound = false 
            print("Chế độ dò: BẬT (Sẽ nhảy số tìm Remote)", "Yellow")
        else
            print("Chế độ dò: TẮT (Spam cố định Index hiện tại)", "White")
        end
    end
})

Tab:Slider({
    Title = "Skill Remote Index",
    Min = 1, Max = 200,
    Value = SKILL_IDX_SPAM,
    Callback = function(v)
        SKILL_IDX_SPAM = v
    end
})
Tab:Button({
	Title = "⏭️ Bỏ qua Index hiện tại (Dò Tiếp)",
	Callback = function()
		skillFound = false        -- Đưa trạng thái về chưa tìm thấy
		AutoDoSkill = true        -- Ép bật chế độ dò
		SKILL_IDX = SKILL_IDX + 1 -- Nhảy sang số tiếp theo ngay lập tức
			
		if SKILL_IDX > 200 then SKILL_IDX = 1 end
			
		print("⚠️ Đã bỏ qua Index cũ. Đang dò tiếp từ: " .. SKILL_IDX, "Yellow")
	end
})
Tab:Button({
    Title = "📍 Lưu Vị Trí Câu Cá Hiện Tại",
    Callback = function()
        savedCastPos = hrp.CFrame
    end
})

Tab:Button({
    Title = "📍 Quay Lại Lưu Vị Trí Câu",
    Callback = function()
        teleCastPost()
    end
})

--================ MULTI-ROD SKILLS TAB ================
local SkillTab = Window:Tab({ Title = "Multi-Rod Skills", Icon = "sword" })

SkillTab:Section({ Title = "Select Rod Skills" })
SkillTab:Toggle({
    Title = "Enable Spam Skill (Manual)",
    Description = "Spam chiêu mà không cần bật Auto Fish",
    Value = state.EnableSpam2,
    Callback = function(v)
        state.EnableSpam2 = v
        save() 
        
        if v then
           
            startSpamming2()
        else
            
        end
    end
})

for _, rodName in ipairs(MY_RODS) do
    SkillTab:Dropdown({
        Title = rodName,
        List = SKILL_OPTIONS,
        Multi = true,
        Value = state.RodSettings[rodName], -- Quan trọng: Load lại các skill đã tích từ trước
        Callback = function(opts)
            state.RodSettings[rodName] = opts 
            save() -- Lưu cấu hình Skill cho từng loại cần
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
		save()
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
		save()
    end
})
GachaTab:Slider({
    Title = "Gacha Index ",
    Min = 1, Max = 100,
    Value = GACHA_IDX,
    Callback = function(v)
        GACHA_IDX = v
    end
})

GachaTab:Toggle({
    Title = "Auto Scan Submit",
    Value = state.AutoScanSubmit,
    Callback = function(v)
        state.AutoScanSubmit = v
		save()
        if v then startScanningSubmit() end
    end
})

GachaTab:Toggle({
    Title = "Auto Submit",
    Value = state.AutoSubmit,
    Callback = function(v)
        state.AutoSubmit = v
		save()
        if v then startAutoSubmit() end
    end
})

GachaTab:Slider({
    Title = "Submit Delay (s)",
    Min = 0.1, Max = 100, -- Cho phép chỉnh nhanh hơn (0.1s)
    Value = state.SubmitDelay,
    Callback = function(v)
        state.SubmitDelay = v
		save()
    end
})

GachaTab:Slider({
    Title = "Submit Index",
    Min = 1, Max = 200,
    Value = SUBMIT_IDX,
    Callback = function(v)
        SUBMIT_IDX = v
    end
})
