-- 🌱 Auto Buy Seeds + Items

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"
))()

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONFIG = "AutoBuy_Config.json"

-- Danh sách
local SEEDS = {
  "Cactus Seed","Strawberry Seed","Pumpkin Seed","Sunflower Seed",
  "Dragon Fruit Seed","Eggplant Seed","Watermelon Seed","Cocotank Seed",
  "Carnivorous Plant Seed","Mr Carrot Seed","Tomatrio Seed"
}
local ITEMS = { "Water Bucket","Frost Grenade","Banana Gun","Frost Blower","Carrot Launcher" }

-- State
local state = { AutoBuySeeds=false, SelectedSeeds={}, AutoBuyItems=false, SelectedItems={} }

-- Save/load
local function save() if writefile then writefile(CONFIG, HttpService:JSONEncode(state)) end end
local function load()
  if readfile and isfile and isfile(CONFIG) then
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG)) end)
    if ok and type(data)=="table" then for k,v in pairs(data) do state[k]=v end end
  end
end
load()

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
    if state.AutoBuySeeds then
      local list = table.find(state.SelectedSeeds,"All Seeds") and SEEDS or state.SelectedSeeds
      for _,s in ipairs(list) do buySeedOnce(s); task.wait(0.5) end
    end
    if state.AutoBuyItems then
      local list = table.find(state.SelectedItems,"All Items") and ITEMS or state.SelectedItems
      for _,it in ipairs(list) do buyItemOnce(it); task.wait(0.5) end
    end
    task.wait(1)
  end
end)

-- UI
local Window = Library:Window({
  Title = "🌱Plant Vs Brainrot",
  Desc  = "By Hải Đẹp Zai",
  Theme = "Amethyst",
  Config = { Keybind = Enum.KeyCode.K, Size = UDim2.new(0, 500, 0, 340) },
  CloseUIButton = { Enabled = true, Text = "ZEN" }
})

local Tab = Window:Tab({ Title = "Main", Icon = "star" })

-- Seeds
Tab:Section({ Title = "Seeds" })
Tab:Toggle({
  Title = "Auto Buy Seeds",
  Value = state.AutoBuySeeds,
  Callback = function(v) state.AutoBuySeeds=v; save() end
})
local SeedDropdownList = { "All Seeds" }; for _,s in ipairs(SEEDS) do table.insert(SeedDropdownList,s) end
Tab:Dropdown({
  Title = "Select Seeds",
  List = SeedDropdownList,
  Multi = true,
  Value = state.SelectedSeeds,
  Callback = function(opts) state.SelectedSeeds=opts; save() end
})

-- Items
Tab:Section({ Title = "Items" })
Tab:Toggle({
  Title = "Auto Buy Items",
  Value = state.AutoBuyItems,
  Callback = function(v) state.AutoBuyItems=v; save() end
})
local ItemDropdownList = { "All Items" }; for _,it in ipairs(ITEMS) do table.insert(ItemDropdownList,it) end
Tab:Dropdown({
  Title = "Select Items",
  List = ItemDropdownList,
  Multi = true,
  Value = state.SelectedItems,
  Callback = function(opts) state.SelectedItems=opts; save() end
})
