do
    local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))(); local Window =
    Library:Window({ Title = "🌱 CHONI Hub", Desc = "Auto Farm Tools", Icon = 105059922903197, Theme = "Dark", Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 500, 0, 400) }, CloseUIButton = { Enabled = true, Text = "CHONI" } }); local MainTab =
    Window:Tab({ Title = "Main Features", Icon = "star" }); do
        MainTab:Section({ Title = "Plant Features" }); local PlantOptions = { "Cactus Seed", "Strawberry Seed",
            "Pumpkin Seed", "Sunflower Seed", "Dragon Fruit Seed", "Eggplant Seed", "Watermelon Seed", "Cocotank Seed",
            "Carnivorous Plant Seed", "Mr Carrot Seed","Tomatrio Seed" }; local SelectedPlants = {}; local AutoBuyingPlants = false; MainTab
            :Dropdown({ Title = "Select Plants", List = PlantOptions, Multi = true, Value = {}, Callback = function(
                options) SelectedPlants = options; end }); MainTab:Toggle({ Title = "Auto Buy Plants", Desc =
        "Automatically buys selected seeds", Value = false, Callback = function(v)
            AutoBuyingPlants = v; if AutoBuyingPlants then task.spawn(function() while AutoBuyingPlants do
                        for _, plant in ipairs(SelectedPlants) do
                            game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild(
                            "dataRemoteEvent"):FireServer({ plant, "\a" }); task.wait(0.5);
                        end
                        task.wait(1);
                    end end); end
        end }); MainTab:Section({ Title = "Item Features" }); local ItemOptions = { "Water Bucket","Forst Grenade", "Banana Gun",
            "Frost Blower", "Carrot Launcher" }; local SelectedItems = {}; local AutoBuyingItems = false; MainTab
            :Dropdown({ Title = "Select Items", List = ItemOptions, Multi = true, Value = {}, Callback = function(
                options) SelectedItems = options; end }); MainTab:Toggle({ Title = "Auto Buy Items", Desc =
        "Automatically buys selected items", Value = false, Callback = function(v)
            AutoBuyingItems = v; if AutoBuyingItems then task.spawn(function() while AutoBuyingItems do
                        for _, item in ipairs(SelectedItems) do
                            game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild(
                            "dataRemoteEvent"):FireServer({ item, " " }); task.wait(0.5);
                        end
                        task.wait(1);
                    end end); end
        end }); MainTab:Section({ Title = "Combat Tools" }); local KillAuraEnabled = false; local AuraRange = 25; local SelectedWeapon =
        "Banana Gun"; MainTab:Dropdown({ Title = "Kill Aura Weapon", List = { "Banana Gun", "Frost Blower", "Carrot Launcher" }, Value =
        SelectedWeapon, Callback = function(choice) SelectedWeapon = choice; end }); MainTab:Toggle({ Title =
        "Kill Aura (SOON)", Desc = "Automatically attacks all Brainrot variants", Value = false, Callback = function(
            state)
            KillAuraEnabled = state; if KillAuraEnabled then task.spawn(function()
                    local player = game.Players.LocalPlayer; while KillAuraEnabled do
                        local char = player.Character; local backpack = player:FindFirstChild("Backpack"); if (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then
                            local root = char.HumanoidRootPart; local humanoid = char.Humanoid; local tool = char
                            :FindFirstChildOfClass("Tool"); if (not tool or (tool.Name ~= SelectedWeapon)) then if backpack then
                                    local item = backpack:FindFirstChild(SelectedWeapon); if item then
                                        humanoid:EquipTool(item); tool = item;
                                    end
                                end end
                            for _, mob in ipairs(workspace:GetChildren()) do if (mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and not game.Players:FindFirstChild(mob.Name)) then
                                    local MobKeywords = { "brainrot", "brain", "rot" }; local mobName = mob.Name:lower(); local isTarget = false; for _, keyword in ipairs(MobKeywords) do if mobName:find(keyword) then
                                            isTarget = true; break;
                                        end end
                                    if isTarget then
                                        local dist = (mob.HumanoidRootPart.Position - root.Position).Magnitude; if ((dist <= AuraRange) and tool) then
                                            pcall(function() tool:Activate(); end); end
                                    end
                                end end
                        end
                        task.wait(0.05);
                    end
                end); end
        end }); MainTab:Slider({ Title = "Aura Range", Min = 10, Max = 60, Value = AuraRange, Callback = function(v) AuraRange =
            v; end }); MainTab:Section({ Title = "Auto Collect Tools" }); local function OpenAutoCollectUI()
            local Players = game:GetService("Players"); local player = Players.LocalPlayer; local char = player
            .Character or player.CharacterAdded:Wait(); local root = char:WaitForChild("HumanoidRootPart"); local ScreenGui =
            Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "ChoniHubUI"; local MainFrame = Instance.new(
            "Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 400, 0, 350); MainFrame.Position = UDim2.new(0.5, -200,
                0.5, -175); MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; Instance.new("UICorner", MainFrame).CornerRadius =
            UDim.new(0, 12); local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, 0, 0, 40); Title.BackgroundTransparency = 1; Title.Text =
            "🌱 CHONI Auto Collect"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 20; Title.TextColor3 = Color3
            .fromRGB(0, 200, 0); local savedLocations = {}; local autoTP = false; local tpDelay = 1; local selectedLocation = nil; local function makeButton(
                text, order, callback)
                local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, -20, 0, 35); btn.Position =
                UDim2.new(0, 10, 0, 50 + (order * 40)); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 =
                Color3.fromRGB(255, 255, 255); btn.Text = text; btn.Font = Enum.Font.Gotham; btn.TextSize = 16; Instance.new("UICorner", btn).CornerRadius =
                UDim.new(0, 8); btn.MouseButton1Click:Connect(callback); return btn;
            end
            local DropFrame = Instance.new("Frame", MainFrame); DropFrame.Size = UDim2.new(1, -20, 0, 100); DropFrame.Position =
            UDim2.new(0, 10, 0, 280); DropFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", DropFrame).CornerRadius =
            UDim.new(0, 8); local function refreshDropdown()
                for _, child in ipairs(DropFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy(); end end
                for i, loc in ipairs(savedLocations) do
                    local opt = Instance.new("TextButton", DropFrame); opt.Size = UDim2.new(1, -10, 0, 25); opt.BackgroundColor3 =
                    Color3.fromRGB(35, 35, 35); opt.TextColor3 = Color3.fromRGB(255, 255, 255); opt.Text = loc.Name; opt.Font =
                    Enum.Font.Gotham; opt.TextSize = 14; Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6); opt
                        .MouseButton1Click:Connect(function() selectedLocation = loc; end);
                end
            end
            makeButton("📌 Save Current Location", 0,
                function() if (char and root) then
                        local locName = "Loc" .. tostring(#savedLocations + 1); table.insert(savedLocations,
                            { Name = locName, Position = root.Position }); refreshDropdown();
                    end end); makeButton("⚡ Teleport to Selected", 1,
                function() if selectedLocation then root.CFrame = CFrame.new(selectedLocation.Position +
                        Vector3.new(0, 3, 0)); end end); makeButton("🔁 Toggle Auto Teleport", 2,
                function()
                    autoTP = not autoTP; if autoTP then task.spawn(function() while autoTP do for _, loc in ipairs(savedLocations) do
                                    if not autoTP then break; end
                                    root.CFrame = CFrame.new(loc.Position + Vector3.new(0, 3, 0)); task.wait(tpDelay);
                                end end end); end
                end); makeButton("⏱️ Increase Delay (+0.5s)", 3, function() tpDelay = tpDelay + 0.5; end); makeButton(
            "⏱️ Decrease Delay (-0.5s)", 4, function() tpDelay = math.max(0.1, tpDelay - 0.5); end); makeButton(
            "❌ Close", 5, function() ScreenGui:Destroy(); end);
        end
        MainTab:Button({ Title = "Open Auto Collect UI", Callback = OpenAutoCollectUI });
    end
    local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" }); do
        PlayerTab:Section({ Title = "Movement" }); local WalkSpeed = 16; local JumpPower = 50; local WalkSpeedEnabled = false; local JumpEnabled = false; local NoClipEnabled = false; PlayerTab
            :Toggle({ Title = "WalkSpeed Hack", Desc = "Enable / Disable custom WalkSpeed", Value = false, Callback = function(
                state)
                WalkSpeedEnabled = state; if WalkSpeedEnabled then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed =
                    WalkSpeed; else game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16; end
            end }); PlayerTab:Slider({ Title = "WalkSpeed Value", Min = 16, Max = 200, Value = WalkSpeed, Callback = function(
            val)
            WalkSpeed = val; if WalkSpeedEnabled then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed; end
        end }); PlayerTab:Toggle({ Title = "Jump Hack", Desc = "Enable / Disable custom JumpPower", Value = false, Callback = function(
            state)
            JumpEnabled = state; if JumpEnabled then game.Players.LocalPlayer.Character.Humanoid.JumpPower = JumpPower; else game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50; end
        end }); PlayerTab:Slider({ Title = "JumpPower Value", Min = 50, Max = 300, Value = JumpPower, Callback = function(
            val)
            JumpPower = val; if JumpEnabled then game.Players.LocalPlayer.Character.Humanoid.JumpPower = JumpPower; end
        end }); PlayerTab:Toggle({ Title = "NoClip", Desc = "Walk through walls", Value = false, Callback = function(
            state)
            NoClipEnabled = state; local char = game.Players.LocalPlayer.Character; task.spawn(function() while NoClipEnabled do
                    for _, part in ipairs(char:GetDescendants()) do if (part:IsA("BasePart") and part.CanCollide) then part.CanCollide = false; end end
                    task.wait(0.2);
                end end);
        end });
    end
    local ExtraTab = Window:Tab({ Title = "Extra", Icon = "info" }); do
        ExtraTab:Section({ Title = "Credits" }); ExtraTab:Label("🌱 CHONI Hub"); ExtraTab:Label("Inspired by Hedan"); ExtraTab
            :Label("Powered by Dummy UI (x2zu Stellar)");
    end
end
