--====================================================
-- 🔐 KEY SYSTEM
--====================================================

local Http = game:GetService("HttpService")
local Players = game:GetService("Players")

local API = "https://roblox-key-api.zenoniazed.workers.dev"
local GET_KEY = "https://discord.gg/pGvbThCdX3"
local FILE = "keylighthub.json"

-- Dùng table để tránh lỗi state sau khi obfuscate
local State = {
    Key = "",
    Verified = false,
    Verifying = false
}

local function trim(s)
    return tostring(s or ""):match("^%s*(.-)%s*$") or ""
end

local function saveKey(key)
    State.Key = trim(key)

    if writefile then
        pcall(function()
            writefile(FILE, Http:JSONEncode({
                Key = State.Key
            }))
        end)
    end
end

local function loadKey()
    if isfile and readfile and isfile(FILE) then
        local ok, data = pcall(function()
            return Http:JSONDecode(readfile(FILE))
        end)

        if ok and type(data) == "table" then
            State.Key = trim(data.Key)
        end
    end
end

local function clearKey()
    State.Key = ""

    if delfile and isfile and isfile(FILE) then
        pcall(function()
            delfile(FILE)
        end)
    elseif writefile then
        saveKey("")
    end
end

local function verifyKey(key)
    local userId = Players.LocalPlayer.UserId

    local url =
        API ..
        "/verify?key=" .. Http:UrlEncode(key) ..
        "&userId=" .. Http:UrlEncode(tostring(userId))

    local ok, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok then
        return false, {
            status = "HTTP_ERROR",
            message = tostring(response)
        }
    end

    local decodeOk, data = pcall(function()
        return Http:JSONDecode(response)
    end)

    if not decodeOk then
        return false, {
            status = "JSON_ERROR",
            message = "Server response invalid"
        }
    end

    return data.success == true, data
end
local function remaining(sec)
    sec = tonumber(sec) or 0

    local d = math.floor(sec / 86400)
    local h = math.floor((sec % 86400) / 3600)
    local m = math.floor((sec % 3600) / 60)

    if d > 0 then
        return string.format("%d ngày %d giờ", d, h)
    elseif h > 0 then
        return string.format("%d giờ %d phút", h, m)
    end

    return string.format("%d phút", m)
end

--====================================================
-- AUTO VERIFY key.json
--====================================================

loadKey()

if State.Key ~= "" then
    local valid, data = verifyKey(State.Key)

    if valid then
        State.Verified = true
        print("✔ Auto Verify thành công")
    else
        local status = data and data.status

        if status == "INVALID"
        or status == "EXPIRED"
        or status == "DISABLED" then
            clearKey()
        end
    end
end

--====================================================
-- KEY UI
--====================================================

if not State.Verified then

    local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/UiRoblox.lua"
    ))()

    local Window = Library:Window({
        Title = "🔐 Key System",
        Desc = "Nhập key để mở khoá Script",
        Icon = 71051887760757,
        Theme = "Dark",

        Config = {
            Keybind = Enum.KeyCode.K,
            Size = UDim2.new(0, 520, 0, 260)
        },

        CloseUIButton = {
            Enabled = true,
            Icon = 71051887760757
        }
    })

    local Tab = Window:Tab({
        Title = "Key",
        Icon = "key"
    })

    local Status = Tab:Label({
        Title = "⏳ Vui lòng nhập key",
        Desc = ""
    })

    -- Dùng State.Key trực tiếp
    Tab:Textbox({
        Title = "Key",
        Desc = "Dán key vào đây",
        Placeholder = "Nhập key...",
        Value = "",

        Callback = function(value)
            State.Key = trim(value)
            print("KEY INPUT:", State.Key)
        end
    })

    Tab:Button({
        Title = "📥 Lấy Key",
        Desc = "Copy link lấy key",

        Callback = function()
            if setclipboard then
                setclipboard(GET_KEY)
                Status:SetDesc("🔗 Đã copy link!")
            end
        end
    })

    Tab:Button({
        Title = "✅ VERIFY",
        Desc = "Kiểm tra key",

        Callback = function()

            if State.Verifying then
                return
            end

            local key = trim(State.Key)

            print("VERIFY KEY:", key)

            if key == "" then
                Status:SetTitle("🔴 Chưa nhập key!")
                Status:SetDesc("Vui lòng nhập key.")
                return
            end

            State.Verifying = true

            Status:SetTitle("🟡 Đang kiểm tra...")
            Status:SetDesc("Đang kết nối server.")

            local valid, data = verifyKey(key)

            State.Verifying = false

            if valid then

                State.Key = key
                saveKey(key)

                State.Verified = true

                Status:SetTitle("🟢 Key hợp lệ!")

                if data.lifetime then
                    Status:SetDesc("⭐ Key vĩnh viễn")
                else
                    Status:SetDesc(
                        "⏳ Còn " .. remaining(data.remainingSeconds)
                    )
                end

                task.delay(0.5, function()
                    if Library.ScreenGui then
                        Library.ScreenGui:Destroy()
                    end
                end)

                return
            end

            local s = data and data.status or "UNKNOWN"

            if s == "INVALID" then
                Status:SetTitle("🔴 Key không tồn tại!")
            elseif s == "EXPIRED" then
                Status:SetTitle("🔴 Key đã hết hạn!")
            elseif s == "DISABLED" then
                Status:SetTitle("🔴 Key đã bị khóa!")
            elseif s == "NETWORK_ERROR" then
                Status:SetTitle("🟠 Lỗi kết nối!")
            else
                Status:SetTitle("🔴 Verify thất bại!")
            end
        end
    })

    repeat task.wait(0.1) until State.Verified
end

--====================================================
-- LOAD MAIN
--====================================================

print("🎉 KEY HỢP LỆ → LOAD SCRIPT CHÍNH!")

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Zenoniazed/roblox-esp-script/main/FishingMaster.lua",
    true
))()
