-- 🌱 Plant Vs Brainrot – Auto Buy + Auto Sell (Brainrot)
--   • Auto Buy Seeds/Items (giữ nguyên)
--   • Auto Sell Brainrot (Equip → ItemSell(true)), auto chạy & xử lý pet mới
--   • Lưu/Load config riêng cho từng tính năng
--   • Size hiển thị dùng thẳng 0–10 (vd 70kg -> 7)

-- ========== UI lib ==========
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/Framework.lua", true))()

--=========Anti AFK=========
-- 🌙 Anti AFK Roblox (luôn chạy)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

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
-- ========== Services ==========
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== (Giữ nguyên) Auto Buy Seeds + Items ==========
-- Danh sách
local SEEDS = {
  "Cactus Seed","Strawberry Seed","Pumpkin Seed","Sunflower Seed",
  "Dragon Fruit Seed","Eggplant Seed","Watermelon Seed","Cocotank Seed",
  "Carnivorous Plant Seed","Mr Carrot Seed","Tomatrio Seed"
}
local ITEMS = { "Water Bucket","Frost Grenade","Banana Gun","Frost Blower","Carrot Launcher" }

-- State
local buyState = { AutoBuySeeds=false, SelectedSeeds={}, AutoBuyItems=false, SelectedItems={} }
local BUY_CONFIG = "AutoBuy_Config.json"

-- Save/load
local function buy_save()
  if writefile then pcall(function() writefile(BUY_CONFIG, HttpService:JSONEncode(buyState)) end) end
end
local function buy_load()
  if readfile and isfile and isfile(BUY_CONFIG) then
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(BUY_CONFIG)) end)
    if ok and type(data)=="table" then for k,v in pairs(data) do buyState[k]=v end end
  end
end
buy_load()

-- Vòng lặp
local function buySeedOnce(name)
  pcall(function()
    ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer({ name, "\a" })
  end)
end
local function buyItemOnce(name)
  pcall(function()
    ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer({ name, " " })
  end)
end

task.spawn(function()
  while true do
    if buyState.AutoBuySeeds then
      local list = (table.find(buyState.SelectedSeeds,"All Seeds") and SEEDS) or buyState.SelectedSeeds
      for _,s in ipairs(list) do buySeedOnce(s); task.wait(0.5) end
    end
    if buyState.AutoBuyItems then
      local list = (table.find(buyState.SelectedItems,"All Items") and ITEMS) or buyState.SelectedItems
      for _,it in ipairs(list) do buyItemOnce(it); task.wait(0.5) end
    end
    task.wait(1)
  end
end)

-- ========== UI chung ==========
local Window = Library:Window({
  Title = "🌱Plant Vs Brainrot",
  Desc  = "By Hải Đẹp Zai",
  Theme = "Amethyst",
  Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 400, 0, 300) },
  CloseUIButton = { Enabled = true, Text = "ZEN" }
})
local Tab = Window:Tab({ Title = "Auto Buy", Icon = "star" })

-- Seeds
Tab:Section({ Title = "Seeds" })
local SeedDropdownList = { "All Seeds" }; for _,s in ipairs(SEEDS) do table.insert(SeedDropdownList,s) end
Tab:Dropdown({
  Title = "Select Seeds",
  List = SeedDropdownList,
  Multi = true,
  Value = buyState.SelectedSeeds,
  Callback = function(opts) buyState.SelectedSeeds=opts; buy_save() end
})
Tab:Toggle({
  Title = "Auto Buy Seeds",
  Value = buyState.AutoBuySeeds,
  Callback = function(v) buyState.AutoBuySeeds=v; buy_save() end
})
-- Items
Tab:Section({ Title = "Items" })
local ItemDropdownList = { "All Items" }; for _,it in ipairs(ITEMS) do table.insert(ItemDropdownList,it) end
Tab:Dropdown({
  Title = "Select Items",
  List = ItemDropdownList,
  Multi = true,
  Value = buyState.SelectedItems,
  Callback = function(opts) buyState.SelectedItems=opts; buy_save() end
})
Tab:Toggle({
  Title = "Auto Buy Items",
  Value = buyState.AutoBuyItems,
  Callback = function(v) buyState.AutoBuyItems=v; buy_save() end
})


-- =================================================================
-- ========== (Thêm mới) AUTO SELL BRAINROT – dưới mục Main =========
-- =================================================================

-- Services bổ sung cho Auto Sell
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(char) character = char end)
local backpack = player:WaitForChild("Backpack")

-- Remote bán
local ItemSell = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemSell")

-- Config & constants
local SELL_CONFIG = "AutoSell_Config.json"
local ATTR_RARITY, ATTR_MUTATION, ATTR_SIZE = "Rarity", "Mutation", "Size"
local ALL_RARITIES = { "Rare","Epic","Legendary","Mythic","Godly","Secret","Limited" }
local ALL_MUTS     = { "Gold","Diamond","Rainbow","Galactic","Frozen","Neon" }

local sellState = {
  AutoSell         = false,
  OnlyBrainrot     = true,
  KeepRarities     = { "Godly","Secret","Limited" },
  GoodMutations    = { "Gold","Diamond","Rainbow","Galactic","Frozen","Neon"},
  MinSizeCommon    = 7,    -- Rare/Epic/Legendary: giữ nếu size >= 7 (≈ 70kg)
  MinSizeMythic    = 2,    -- Mythic: bán nếu size < 2 và không thuộc GoodMutations
  LoopDelay        = 2,
  PerItemDelay     = 0.15
}

-- Save/Load riêng cho Auto Sell
local function sell_save()
  if writefile then pcall(function() writefile(SELL_CONFIG, HttpService:JSONEncode(sellState)) end) end
end
local function sell_load()
  if readfile and isfile and isfile(SELL_CONFIG) then
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(SELL_CONFIG)) end)
    if ok and type(data)=="table" then for k,v in pairs(data) do sellState[k]=v end end
  end
end
sell_load()

-- Helpers
local function SELL_toSet(list) local s={} for _,v in ipairs(list) do s[v]=true end return s end
local function SELL_getNumberSize(raw)
  if type(raw)=="number" then return raw end
  if type(raw)=="string" then local n=tonumber(string.match(raw,"[%d%.]+")) return n or 0 end
  return 0
end

local function SELL_shouldSell(rarity, mutation, sizeVal)
  local keepR, goodM = SELL_toSet(sellState.KeepRarities), SELL_toSet(sellState.GoodMutations)
  if keepR[rarity] then return false end
  if rarity == "Mythic" then
    return (not goodM[mutation]) and (sizeVal < sellState.MinSizeMythic)
  end
  if  rarity=="Rare" or rarity=="Epic" or rarity=="Legendary" then
    return (sizeVal < sellState.MinSizeCommon)
  end
  return true
end

-- Tìm core chứa attribute (fallback: tool)
local function SELL_findPetCore(tool)
  for _, child in ipairs(tool:GetChildren()) do
    if child:IsA("Model") or child:IsA("Folder") then
      if child:GetAttribute(ATTR_RARITY) or child:GetAttribute(ATTR_MUTATION) or child:GetAttribute(ATTR_SIZE) ~= nil then
        return child
      end
    end
  end
  return tool
end

-- Equip & bán
local function SELL_equipTool(tool)
  if not character or not character.Parent then return false end
  for _, item in ipairs(character:GetChildren()) do
    if item:IsA("Tool") then
      item.Parent = backpack
      task.wait(0.05)
    end
  end
  tool.Parent = character
  task.wait(0.15)
  return true
end

local function SELL_sellEquipped()
  if ItemSell and ItemSell:IsA("RemoteEvent") then
    pcall(function() ItemSell:FireServer(true) end)
  end
end

-- Xử lý từng Tool
local SELL_processing = {}
local function SELL_processTool(tool)
  if SELL_processing[tool] or not tool or not tool.Parent then return end
  SELL_processing[tool] = true
  task.wait(0.1)

  if sellState.OnlyBrainrot and not tool:GetAttribute("Brainrot") then
    SELL_processing[tool] = nil; return
  end

  local core = SELL_findPetCore(tool)
  local rarity   = tostring(core:GetAttribute(ATTR_RARITY) or "Unknown")
  local mutation = tostring(core:GetAttribute(ATTR_MUTATION) or "Normal")
  local size     = SELL_getNumberSize(core:GetAttribute(ATTR_SIZE) or 0)

  local doSell = false
  local ok, res = pcall(function() return SELL_shouldSell(rarity, mutation, size) end)
  if ok then doSell = res end

  if doSell and sellState.AutoSell then
    -- print(("👉 Bán: %s | %s | %s | size=%.2f"):format(tool.Name, rarity, mutation, size))
    if SELL_equipTool(tool) then
      SELL_sellEquipped()
      task.wait(sellState.PerItemDelay)
    end
  else
    -- print(("❌ Giữ: %s | %s | %s | size=%.2f"):format(tool.Name, rarity, mutation, size))
  end
  SELL_processing[tool] = nil
end

-- Event: pet mới thêm
backpack.ChildAdded:Connect(function(obj)
  if sellState.AutoSell and obj:IsA("Tool") then
    task.spawn(function() SELL_processTool(obj) end)
  end
end)

-- Loop dự phòng
task.spawn(function()
  while true do
    if sellState.AutoSell then
      for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then task.spawn(SELL_processTool, tool) end
      end
    end
    task.wait(sellState.LoopDelay)
  end
end)

-- === UI: TAB RIÊNG CHO AUTO SELL ===
local SellTab = Window:Tab({ Title = "Auto Sell", Icon = "recycle" })

SellTab:Section2({ Title = "Auto Sell Brainrot" })
SellTab:Toggle({
  Title = "Auto Sell",
  Value = sellState.AutoSell,
  Callback = function(v)
    sellState.AutoSell = v; sell_save()
    if v then
      task.spawn(function()
        for _, tool in ipairs(backpack:GetChildren()) do
          if tool:IsA("Tool") then SELL_processTool(tool) end
        end
      end)
    end
  end
})

SellTab:Dropdown({
  Title = "Dont Sell Rarity",
  List = ALL_RARITIES,
  Multi = true,
  Value = sellState.KeepRarities,
  Callback = function(opts) sellState.KeepRarities = opts; sell_save() end
})

SellTab:Dropdown({
  Title = "Mutations For Mythic",
  List = ALL_MUTS,
  Multi = true,
  Value = sellState.GoodMutations,
  Callback = function(opts) sellState.GoodMutations = opts; sell_save() end
})

SellTab:Textbox({
  Title = "Size Rare/Epic/Legendary (Below) ",
  Placeholder = tostring(sellState.MinSizeCommon),
  Value = "",
  Callback = function(txt)
    local v = tonumber(txt)
    if v then
      if v < 0 then v = 0 end
      if v > 10000 then v = 10000 end
      local z = v/10
      sellState.MinSizeCommon = tonumber(string.format("%.2f", z))
      sell_save()
    end
  end
})

SellTab:Textbox({
  Title = "Size Mythic (Below)",
  Placeholder = tostring(sellState.MinSizeMythic),
  Value = "",
  Callback = function(txt)
    local v = tonumber(txt)
    if v then
      if v < 0 then v = 0 end
      if v > 10000 then v = 10000 end
      local z = v/10
      sellState.MinSizeMythic = tonumber(string.format("%.2f", z))
      sell_save()
    end
  end
})

SellTab:Textbox({
  Title = "Delay(s)",
  Placeholder = tostring(sellState.PerItemDelay),
  Value = "",
  Callback = function(txt)
    local v = tonumber(txt)
    if v then
      if v < 0.05 then v = 0.05 end
      if v > 5 then v = 5 end
      sellState.PerItemDelay = tonumber(string.format("%.2f", v))
      sell_save()
    end
  end
})

-- =============================================================
-- ========== SELL BY PRICE (Brainrot-only option) ==============
-- =============================================================

local selectedRarities = {}
local maxPrice = nil
local onlyBrainrot = true

local function PRICE_isBrainrot(tool, core)
    local v = tool and tool.GetAttribute and tool:GetAttribute("Brainrot")
    if v == nil and core and core.GetAttribute then
        v = core:GetAttribute("Brainrot")
    end
    return v and true or false
end

local function PRICE_shouldSell(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local core = SELL_findPetCore(tool); if not core then return false end

    if onlyBrainrot and not PRICE_isBrainrot(tool, core) then return false end

    local rarity = core:GetAttribute("Rarity")
    local worth  = core:GetAttribute("Worth")
    if not rarity or not worth then return false end

    local rarSet = {}
    for _,r in ipairs(selectedRarities) do rarSet[r]=true end

    return rarSet[rarity] and (tonumber(worth) or 0) < maxPrice
end

local function PRICE_sellNow()
    for _, tool in ipairs(backpack:GetChildren()) do
        if PRICE_shouldSell(tool) then
            if SELL_equipTool(tool) then
                pcall(function() ItemSell:FireServer(true) end)
                task.wait(0.1)
            end
        end
    end
end

-- ===================== UI trong SellTab =====================

local SecPrice = SellTab:Section({ Title = "Sell by price" })

SellTab:Dropdown({
    Title = "Rarity",
    List = ALL_RARITIES,
    Multi = true,
    Value = {},
    Callback = function(opts)
        selectedRarities = opts
    end
})

SellTab:Textbox({
    Title = "Min Price",
    Placeholder = "0",
    Value = "",
    Callback = function(txt)
        local v = tonumber(txt)
        if v then maxPrice = v end
    end
})

SellTab:Button({
    Title = "Sell Now",
    Callback = function()
        if not maxPrice or #selectedRarities == 0 then
            warn("[SELL BY PRICE] Vui lòng chọn Rarity và nhập giá hợp lệ!")
            return
        end
        PRICE_sellNow()
    end
})



