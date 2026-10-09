--[[
    KEY SCREEN: "Enter your key"
    Same black / gray animated theme with a bright white sheen.
    As soon as the correct key is typed or pasted, the main script
    starts automatically - no button press needed.
    The key is asked on every launch (it is never saved).
]]

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local VALID_KEYS      = { "Phantom" } -- << your key (case matters)
local KEY_URL         = ""  -- optional: raw link to a text file with keys (one per line)
local MAIN_SCRIPT_URL = ""  -- optional: raw link to your main script (loadstring)

---------------------------------------------------------------------
-- MAIN SCRIPT (runs automatically after a correct key)
---------------------------------------------------------------------
local function loadMainScript()
    if MAIN_SCRIPT_URL ~= "" then
        local ok, err = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        end)
        if not ok then
            warn("[KeyScreen] Main script error: " .. tostring(err))
        end
        return
    end

    -- >>> or put the code of your main script here <<<
    print("[KeyScreen] Key accepted - main script is running")
end

---------------------------------------------------------------------
-- services & helpers
---------------------------------------------------------------------
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

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

local function clean(s)
    return (tostring(s):gsub("%s+", ""))
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

---------------------------------------------------------------------
-- key checking
---------------------------------------------------------------------
local keys = {}
for _, k in ipairs(VALID_KEYS) do
    keys[clean(k)] = true
end

if KEY_URL ~= "" then
    local ok, body = pcall(function() return game:HttpGet(KEY_URL) end)
    if ok and type(body) == "string" then
        for line in body:gmatch("[^\r\n]+") do
            local k = clean(line)
            if k ~= "" then keys[k] = true end
        end
    end
end

local function isValidKey(text)
    local k = clean(text)
    return k ~= "" and keys[k] == true
end

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------
local parent = getGuiParent()
local old = parent:FindFirstChild("KeyScreen")
if old then old:Destroy() end

local gui = new("ScreenGui", {
    Name = "KeyScreen",
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

-- bright white sheen
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
    Position = UDim2.new(0.5, 0, 0.5, -120),
    Size = UDim2.new(0.9, 0, 0, 90),
    BackgroundTransparency = 1,
    Text = "Enter your key",
    Font = Enum.Font.GothamBlack,
    TextColor3 = Color3.new(1, 1, 1),
    TextScaled = true,
    TextTransparency = 1,
    ZIndex = 3,
}, bg)
new("UITextSizeConstraint", { MaxTextSize = 68 }, title)
local titleStroke = new("UIStroke", {
    Color = Color3.new(0, 0, 0),
    Thickness = 2.5,
    Transparency = 1,
}, title)

-- key box
local box = new("TextBox", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.85, 0, 0, 60),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Paste your key here",
    PlaceholderColor3 = Color3.fromRGB(170, 170, 178),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextTransparency = 1,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 3,
}, bg)
new("UISizeConstraint", { MaxSize = Vector2.new(420, 60) }, box)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, box)
local boxStroke = new("UIStroke", {
    Color = Color3.new(1, 1, 1),
    Thickness = 2,
    Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, box)

-- status line
local STATUS_DEFAULT = "Paste your key - it unlocks automatically"
local status = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 58),
    Size = UDim2.new(0.9, 0, 0, 28),
    BackgroundTransparency = 1,
    Text = STATUS_DEFAULT,
    Font = Enum.Font.Gotham,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(215, 215, 222),
    TextTransparency = 1,
    ZIndex = 3,
}, bg)

-- Key button (bottom)
local btn = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -70),
    Size = UDim2.fromOffset(320, 60),
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
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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

local btnLabel = new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "Key",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Color3.new(1, 1, 1),
    TextTransparency = 1,
    ZIndex = 4,
}, btn)

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
task.delay(0.3, function()
    tween(box, 0.8, { BackgroundTransparency = 0.35, TextTransparency = 0 })
    tween(boxStroke, 0.8, { Transparency = 0.1 })
    tween(status, 0.8, { TextTransparency = 0 })
end)
task.delay(0.6, function()
    tween(fill, 0.8, { BackgroundTransparency = 0 })
    tween(btnLabel, 0.8, { TextTransparency = 0 })
    tween(btnStroke, 0.8, { Transparency = 0.15 })
end)

---------------------------------------------------------------------
-- key logic
---------------------------------------------------------------------
local unlocked = false

local function shake(obj)
    local base = obj.Position
    for i = 1, 6 do
        obj.Position = base + UDim2.fromOffset(i % 2 == 0 and -9 or 9, 0)
        task.wait(0.04)
    end
    obj.Position = base
end

local function showInvalid()
    status.Text = "Invalid key - try again"
    status.TextColor3 = Color3.fromRGB(255, 90, 90)
    boxStroke.Color = Color3.fromRGB(255, 90, 90)
    task.spawn(shake, box)
    task.delay(2.5, function()
        if not unlocked then
            status.Text = STATUS_DEFAULT
            status.TextColor3 = Color3.fromRGB(215, 215, 222)
            boxStroke.Color = Color3.new(1, 1, 1)
        end
    end)
end

local function unlock(key)
    if unlocked then return end
    unlocked = true

    box.TextEditable = false
    box:ReleaseFocus()
    status.Text = "Key accepted!"
    status.TextColor3 = Color3.fromRGB(90, 255, 150)
    boxStroke.Color = Color3.fromRGB(90, 255, 150)

    task.wait(0.8)

    -- fade everything out
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("Frame") or d:IsA("TextBox") or d:IsA("TextButton") or d:IsA("TextLabel") then
            tween(d, 0.5, { BackgroundTransparency = 1 })
        end
        if d:IsA("TextBox") or d:IsA("TextButton") or d:IsA("TextLabel") then
            tween(d, 0.5, { TextTransparency = 1 })
        end
        if d:IsA("UIStroke") then
            tween(d, 0.5, { Transparency = 1 })
        end
    end
    task.wait(0.6)

    conn:Disconnect()
    gui:Destroy()

    loadMainScript() -- starts by itself
end

-- correct key typed / pasted -> instantly unlock
box:GetPropertyChangedSignal("Text"):Connect(function()
    if not unlocked and isValidKey(box.Text) then
        task.spawn(unlock, box.Text)
    end
end)

-- wrong key when the box loses focus / Enter is pressed
box.FocusLost:Connect(function()
    if unlocked then return end
    if clean(box.Text) ~= "" and not isValidKey(box.Text) then
        showInvalid()
    end
end)

-- focus glow
box.Focused:Connect(function()
    if not unlocked then tween(boxStroke, 0.2, { Thickness = 3, Transparency = 0 }) end
end)
box.FocusLost:Connect(function()
    if not unlocked then tween(boxStroke, 0.2, { Thickness = 2, Transparency = 0.1 }) end
end)

---------------------------------------------------------------------
-- Key button
---------------------------------------------------------------------
btn.MouseEnter:Connect(function()
    tween(btn, 0.2, { Size = UDim2.fromOffset(342, 64) })
    tween(btnStroke, 0.2, { Thickness = 3, Transparency = 0 })
end)
btn.MouseLeave:Connect(function()
    tween(btn, 0.2, { Size = UDim2.fromOffset(320, 60) })
    tween(btnStroke, 0.2, { Thickness = 2, Transparency = 0.15 })
end)

-- clicking "Key" jumps straight into the key box
btn.MouseButton1Click:Connect(function()
    if not unlocked then
        box:CaptureFocus()
    end
end)
