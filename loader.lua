repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local API_URL = "https://bot-key-api.onrender.com/api/verify"
local SCRIPT_URL = "https://raw.githubusercontent.com/megumi668/AMETHYSTHUB/refs/heads/main/AMETHYSTHUB.lua"

-- Tự động lấy HWID máy
local hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
if not hwid or hwid == "" then
    hwid = tostring(game.Players.LocalPlayer.UserId)
end

-- Hàm hiện thông báo trong game
local function ShowNotif(msg)
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Text = Instance.new("TextLabel")
    local Close = Instance.new("TextButton")

    ScreenGui.Name = "KeyNotif"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    Frame.Size = UDim2.new(0, 400, 0, 120)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -60)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    Text.Size = UDim2.new(1, -20, 0.7, 0)
    Text.Position = UDim2.new(0, 10, 0, 10)
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(255, 80, 80)
    Text.TextScaled = true
    Text.Font = Enum.Font.GothamBold
    Text.Text = msg
    Text.Parent = Frame

    Close.Size = UDim2.new(0.4, 0, 0.25, 0)
    Close.Position = UDim2.new(0.3, 0, 0.72, 0)
    Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "Đóng"
    Close.TextScaled = true
    Close.Parent = Frame
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    task.delay(5, function()
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    end)
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
    ShowNotif("❌ Không thể kết nối server!\nThử lại sau.")
    return
end

local data = game:GetService("HttpService"):JSONDecode(res.Body)

if data.success then
    print("✅ Key hợp lệ! Đang load Amethyst Hub...")
    loadstring(game:HttpGet(SCRIPT_URL))()
else
    local msg = data.message or ""
    if msg:find("does not exist") then
        ShowNotif("❌ Key không tồn tại!")
    elseif msg:find("expired") then
        ShowNotif("❌ Key đã hết hạn!")
    elseif msg:find("not redeemed") then
        ShowNotif("❌ Chưa redeem key!\nVào Discord dùng /redeem")
    elseif msg:find("limit reached") then
        ShowNotif("❌ Máy khác đã dùng key!\nVào Discord dùng /resethwid")
    elseif msg:find("blacklisted") then
        ShowNotif("❌ Key bị khóa! Liên hệ admin.")
    else
        ShowNotif("❌ " .. msg)
    end
end
