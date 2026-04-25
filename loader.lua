repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local API_URL = "https://bot-key-api.onrender.com/api/verify"
local SCRIPT_URL = "https://raw.githubusercontent.com/megumi668/AmethystKaitunGhoulAndCyborg/refs/heads/main/AmethystKaitunGhoulAndCyborgbySoda.lua"
local lp = game.Players.LocalPlayer

-- Tự động lấy HWID máy
local hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
if not hwid or hwid == "" then
    hwid = tostring(lp.UserId)
end

-- Hàm kick với lý do
local function KickPlayer(reason)
    lp:Kick("\n\n❌ AMETHYST HUB - XÁC THỰC THẤT BẠI\n\n" .. reason .. "\n\nLiên hệ Discord để được hỗ trợ!")
end

-- Kiểm tra key có được nhập chưa
if not getgenv().Key or getgenv().Key == "" or getgenv().Key == "KEY_CỦA_HỌ" then
    KickPlayer("⚠️ Bạn chưa nhập key!\nHãy nhập key trước khi chạy script.")
    return
end

-- Gửi key + hwid lên server verify
local ok, res = pcall(function()
    return (syn and syn.request or http_request or request)({
        Url = API_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode({
            key = getgenv().Key,
            hwid = hwid
        })
    })
end)

if not ok then
    KickPlayer("⚠️ Không thể kết nối server xác thực!\nVui lòng thử lại sau.")
    return
end

local data = game:GetService("HttpService"):JSONDecode(res.Body)

if data.success then
    print("✅ Key hợp lệ! Đang load Amethyst Hub...")
    loadstring(game:HttpGet(SCRIPT_URL))()
else
    local msg = data.message or ""
    if msg:find("does not exist") then
        KickPlayer("❌ Key không tồn tại!\nKiểm tra lại key bạn đã nhập.")
    elseif msg:find("expired") then
        KickPlayer("❌ Key đã hết hạn!\nLiên hệ admin để gia hạn.")
    elseif msg:find("not redeemed") then
        KickPlayer("❌ Key chưa được kích hoạt!\nVào Discord dùng lệnh /redeem để kích hoạt key.")
    elseif msg:find("limit reached") then
        KickPlayer("❌ Key đã được dùng trên máy khác!\nVào Discord dùng lệnh /resethwid nếu bạn đổi máy.")
    elseif msg:find("blacklisted") then
        KickPlayer("❌ Key của bạn đã bị khóa!\nLiên hệ admin để biết thêm thông tin.")
    else
        KickPlayer("❌ Xác thực thất bại!\n" .. msg)
    end
end
