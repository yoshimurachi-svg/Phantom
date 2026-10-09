--[[
    START SCREEN: "Join our Discord"
    Animated black / gray background with a bright white sheen,
    pure white title and a glowing "Join Discord Server" button.
]]

local DISCORD_LINK = "https://discord.gg/your-invite" -- << put your invite link here
local DISCORD_CODE = "your-invite"                     -- << only the code after discord.gg/

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")

---------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------
local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function getGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local core = game:GetService("CoreGui")
    if pcall(function() return core:GetChildren() end) then
        return core
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function copyToClipboard(text)
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if fn then
        return pcall(fn, text)
    end
    return false
end

-- opens the invite in the Discord desktop app (works in most executors)
local function openInDiscordApp(code)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return false end
    return pcall(function()
        req({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com",
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = { code = code },
                nonce = HttpService:GenerateGUID(false),
            }),
        })
    end)
end

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------
local parent = getGuiParent()
local old = parent:FindFirstChild("DiscordStartScreen")
if old then old:Destroy() end

local gui = new("ScreenGui", {
    Name = "DiscordStartScreen",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 1000,
}, parent)

-- animated black / gray background
local bg = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, gui)

local bgGradient = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(3, 3, 4)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(52, 52, 58)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(135, 135, 144)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(34, 34, 38)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(3, 3, 4)),
    }),
}, bg)

-- bright white sheen sliding over the background (makes the white clearly visible)
local sheen = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, bg)

local sheenGradient = new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1),
        NumberSequenceKeypoint.new(0.50, 0.84),
        NumberSequenceKeypoint.new(1.00, 1),
    }),
}, sheen)

-- title
local title = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.42),
    Size = UDim2.new(0.9, 0, 0, 100),
    BackgroundTransparency = 1,
    Text = "Join our Discord",
    Font = Enum.Font.GothamBlack,
    TextColor3 = Color3.new(1, 1, 1),
    TextScaled = true,
    TextTransparency = 1,
    ZIndex = 3,
}, bg)
new("UITextSizeConstraint", { MaxTextSize = 72 }, title)
local titleStroke = new("UIStroke", {
    Color = Color3.new(0, 0, 0),
    Thickness = 2.5,
    Transparency = 1,
}, title)

-- button (bottom)
local btn = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -70),
    Size = UDim2.fromOffset(300, 60),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 3,
}, bg)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)
local btnStroke = new("UIStroke", {
    Color = Color3.new(1, 1, 1),
    Thickness = 2,
    Transparency = 1,
}, btn)

local fill = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 3,
}, btn)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
local btnGradient = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242)),
    }),
}, fill)

local label = new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "Join Discord Server",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.new(1, 1, 1),
    TextTransparency = 1,
    ZIndex = 4,
}, btn)

-- small close button (top right) so the screen doesn't block your script
local closeBtn = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -24, 0, 24),
    Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.45,
    Text = "X",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.new(1, 1, 1),
    AutoButtonColor = true,
    ZIndex = 5,
}, bg)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)
new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.4 }, closeBtn)

---------------------------------------------------------------------
-- animation
---------------------------------------------------------------------
local t0 = os.clock()
local conn = RunService.Heartbeat:Connect(function()
    local t = os.clock() - t0
    bgGradient.Rotation    = (t * 10) % 360
    bgGradient.Offset      = Vector2.new(math.sin(t * 0.5) * 0.3, math.cos(t * 0.4) * 0.3)
    sheenGradient.Rotation = (-t * 16) % 360
    sheenGradient.Offset   = Vector2.new(math.sin(t * 0.7 + 1) * 0.45, 0)
    btnGradient.Rotation   = (t * 45) % 360
end)

-- intro
tween(title, 1.0, { TextTransparency = 0 })
tween(titleStroke, 1.0, { Transparency = 0.3 })
task.delay(0.4, function()
    tween(fill, 0.8, { BackgroundTransparency = 0 })
    tween(label, 0.8, { TextTransparency = 0 })
    tween(btnStroke, 0.8, { Transparency = 0.15 })
end)

-- hover
btn.MouseEnter:Connect(function()
    tween(btn, 0.2, { Size = UDim2.fromOffset(322, 64) })
    tween(btnStroke, 0.2, { Thickness = 3, Transparency = 0 })
end)
btn.MouseLeave:Connect(function()
    tween(btn, 0.2, { Size = UDim2.fromOffset(300, 60) })
    tween(btnStroke, 0.2, { Thickness = 2, Transparency = 0.15 })
end)

-- click
local busy = false
btn.MouseButton1Click:Connect(function()
    if busy then return end
    busy = true

    local copied = copyToClipboard(DISCORD_LINK)
    openInDiscordApp(DISCORD_CODE)
    label.Text = copied and "Link copied!" or DISCORD_LINK

    task.delay(2.5, function()
        if label.Parent then
            label.Text = "Join Discord Server"
        end
        busy = false
    end)
end)

-- close
closeBtn.MouseButton1Click:Connect(function()
    conn:Disconnect()
    gui:Destroy()
    -- >> https://discord.gg/s6nKDC5HUg <<<
end)
