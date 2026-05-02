--[[
╔══════════════════════════════════════════════════════════════╗
║                    NOVA UI LIBRARY  v5.0                     ║
║          100% Orion-Compatible · Premium Nova Design         ║
╠══════════════════════════════════════════════════════════════╣
║  Drop-in replacement for Orion Library — same exact API      ║
║  Just swap the loadstring URL, everything works instantly    ║
╠══════════════════════════════════════════════════════════════╣
║  MakeWindow     · MakeTab          · AddSection              ║
║  AddButton      · AddToggle        · AddSlider               ║
║  AddDropdown    · AddColorpicker   · AddBind                 ║
║  AddTextbox     · AddLabel         · AddParagraph            ║
║  AddKeySystem   · MakeNotification · Flags · Config          ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local function safeWrite(p,d)  pcall(writefile, p, d) end
local function safeRead(p)     local ok,d = pcall(readfile,p); return ok and d or nil end
local function safeMkdir(p)    pcall(makefolder, p) end

-- ════════════════════════════════════════════════════════════
--  THEME  — deep violet-dark premium palette
-- ════════════════════════════════════════════════════════════
local T = {
    -- Backgrounds
    Win         = Color3.fromRGB(10,  9,  18),
    Sidebar     = Color3.fromRGB(13, 11,  22),
    Content     = Color3.fromRGB( 8,  7,  16),
    TopBar      = Color3.fromRGB(13, 11,  22),
    Element     = Color3.fromRGB(14, 12,  26),
    ElementHov  = Color3.fromRGB(18, 15,  32),
    Section     = Color3.fromRGB(16, 14,  28),
    Divider     = Color3.fromRGB(28, 24,  48),
    -- Accent
    Accent      = Color3.fromRGB(110, 70, 245),
    AccentSoft  = Color3.fromRGB(140,100, 255),
    AccentDark  = Color3.fromRGB( 48, 28, 110),
    AccentGlow  = Color3.fromRGB( 75, 38, 180),
    -- Active tab gradient colours
    TabActive0  = Color3.fromRGB( 80, 48, 200),
    TabActive1  = Color3.fromRGB( 40, 22, 120),
    -- Text
    Text        = Color3.fromRGB(225, 218, 250),
    TextSub     = Color3.fromRGB(160, 148, 200),
    TextDim     = Color3.fromRGB(100,  88, 140),
    TextMuted   = Color3.fromRGB( 55,  46,  88),
    -- State colours
    Success     = Color3.fromRGB( 65, 210, 130),
    Danger      = Color3.fromRGB(225,  65,  65),
    Warning     = Color3.fromRGB(235, 185,  55),
    -- Toggle
    ToggleOff   = Color3.fromRGB( 25, 20,  44),
    -- Typography
    Font        = Enum.Font.GothamSemibold,
    FontLight   = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,
    -- Radii
    R10         = UDim.new(0,10),
    R8          = UDim.new(0, 8),
    R6          = UDim.new(0, 6),
    R5          = UDim.new(0, 5),
    RFull       = UDim.new(1, 0),
}

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function tw(obj, props, t, es, ed)
    TweenService:Create(obj,
        TweenInfo.new(t or .16, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out),
        props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or T.R6
    return c
end

local function uistroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.Divider
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(p, top, bot, left, right)
    local u = Instance.new("UIPadding", p)
    u.PaddingTop    = UDim.new(0, top   or 0)
    u.PaddingBottom = UDim.new(0, bot   or 0)
    u.PaddingLeft   = UDim.new(0, left  or 0)
    u.PaddingRight  = UDim.new(0, right or 0)
end

local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function vlist(p, spacing)
    return new("UIListLayout",{
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, spacing or 0),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, p)
end

local function hlist(p, spacing)
    return new("UIListLayout",{
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, spacing or 0),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, p)
end

local function gradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient", p)
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    return g
end

-- ════════════════════════════════════════════════════════════
--  LIBRARY
-- ════════════════════════════════════════════════════════════
local Nova   = {}
Nova.__index = Nova
Nova.Flags   = {}
Nova._conns  = {}
Nova._gui    = nil

-- ────────────────────────────────────────────────────────────
--  NOTIFICATION
-- ────────────────────────────────────────────────────────────
local _notifHolder

local function ensureHolder(gui)
    if _notifHolder and _notifHolder.Parent then return end
    _notifHolder = new("Frame",{
        Size = UDim2.new(0,248,1,-12),
        Position = UDim2.new(1,-258,0,6),
        BackgroundTransparency = 1, ZIndex = 100,
    }, gui)
    local ll = vlist(_notifHolder, 5)
    ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

function Nova:MakeNotification(opts)
    opts = opts or {}
    local title   = opts.Name    or "Notification"
    local content = opts.Content or ""
    local image   = opts.Image   or ""
    local time    = opts.Time    or 4

    ensureHolder(self._gui or LocalPlayer.PlayerGui)

    local card = new("Frame",{
        Size = UDim2.new(1,0,0,62),
        BackgroundColor3 = Color3.fromRGB(14,12,26),
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 101,
    }, _notifHolder)
    corner(card, T.R8)
    uistroke(card, Color3.fromRGB(30,24,55), 1)

    -- left accent bar
    local acBar = new("Frame",{
        Size = UDim2.new(0,2,1,0),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 102,
    }, card)
    gradient(acBar, T.AccentSoft, T.AccentGlow, 90)

    local xOff = image ~= "" and 50 or 12
    if image ~= "" then
        local imgFrame = new("Frame",{
            Size = UDim2.new(0,30,0,30),
            Position = UDim2.new(0,12,0.5,-15),
            BackgroundColor3 = T.AccentDark, BorderSizePixel = 0, ZIndex = 102,
        }, card)
        corner(imgFrame, T.RFull)
        new("ImageLabel",{
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, Image = image, ZIndex = 103,
        }, imgFrame)
        corner(new("Frame",{}, imgFrame), T.RFull)
    end

    new("TextLabel",{
        Size     = UDim2.new(1,-(xOff+8),0,18),
        Position = UDim2.new(0,xOff,0,8),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = T.Text, TextSize = 12, Font = T.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    }, card)

    new("TextLabel",{
        Size     = UDim2.new(1,-(xOff+8),0,26),
        Position = UDim2.new(0,xOff,0,28),
        BackgroundTransparency = 1, Text = content,
        TextColor3 = T.TextSub, TextSize = 10, Font = T.FontLight,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 102,
    }, card)

    -- progress bar
    local prog = new("Frame",{
        Size = UDim2.new(1,0,0,2),
        Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = T.AccentGlow, BorderSizePixel = 0, ZIndex = 103,
    }, card)

    card.Position = UDim2.new(1,10,0,0)
    tw(card, {Position = UDim2.new(0,0,0,0)}, .28, Enum.EasingStyle.Back)
    tw(prog, {Size = UDim2.new(0,0,0,2)}, time, Enum.EasingStyle.Linear)
    task.delay(time, function()
        tw(card, {Position = UDim2.new(1,10,0,0)}, .22)
        task.wait(.28); card:Destroy()
    end)
end

-- ════════════════════════════════════════════════════════════
--  MAKE WINDOW
-- ════════════════════════════════════════════════════════════
function Nova:MakeWindow(opts)
    opts = opts or {}
    local title        = opts.Name          or "Nova"
    local hidePremium  = opts.HidePremium   -- nil = show premium
    local saveConfig   = opts.SaveConfig    or false
    local cfgFolder    = opts.ConfigFolder  or "NovaConfig"
    local introEnabled = opts.IntroEnabled  -- kept for compatibility, not used
    local introText    = opts.IntroText     or title
    local introIcon    = opts.IntroIcon     or ""
    local winIcon      = opts.Icon          or ""
    local closeCb      = opts.CloseCallback or nil
    local toggleKey    = opts.Key           or Enum.KeyCode.RightShift

    -- Sidebar / window metrics
    local TOP_H  = 52
    local TAB_W  = 152
    local CARD_H = 82   -- player card at sidebar bottom

    if saveConfig then safeMkdir(cfgFolder) end

    -- ── GUI ROOT ──────────────────────────────────────────
    local gui = new("ScreenGui",{
        Name = "NovaUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, LocalPlayer.PlayerGui)
    self._gui = gui
    ensureHolder(gui)

    -- ── WINDOW (scale-based so it fits any screen) ────────
    local win = new("Frame",{
        Size     = UDim2.new(0.82,0,0.80,0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = T.Win, BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    corner(win, T.R10)
    uistroke(win, Color3.fromRGB(28,22,52), 1)

    -- drop shadow
    new("ImageLabel",{
        Size = UDim2.new(1,50,1,50), Position = UDim2.new(0,-25,0,-25),
        BackgroundTransparency = 1, Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0), ImageTransparency = .55,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450), ZIndex = 0,
    }, win)

    -- ── TOP BAR ───────────────────────────────────────────
    local topbar = new("Frame",{
        Size = UDim2.new(1,0,0,TOP_H),
        BackgroundColor3 = T.TopBar, BorderSizePixel = 0, ZIndex = 2,
    }, win)
    corner(topbar, T.R10)
    new("Frame",{  -- fill bottom-radius gap
        Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,1,-14),
        BackgroundColor3 = T.TopBar, BorderSizePixel = 0, ZIndex = 2,
    }, topbar)

    -- animated accent line under topbar
    local acLine = new("Frame",{
        Size = UDim2.new(0,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 3,
    }, topbar)
    tw(acLine, {Size = UDim2.new(1,0,0,1)}, .7, Enum.EasingStyle.Quad)

    -- window icon / dot
    if winIcon ~= "" then
        new("ImageLabel",{
            Size = UDim2.new(0,24,0,24), Position = UDim2.new(0,12,0.5,-12),
            BackgroundTransparency = 1, Image = winIcon, ZIndex = 3,
        }, topbar)
    else
        local dot = new("Frame",{
            Size = UDim2.new(0,8,0,8), Position = UDim2.new(0,14,0.5,-4),
            BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 3,
        }, topbar)
        corner(dot, T.RFull)
        local ring = new("Frame",{
            Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,11,0.5,-7),
            BackgroundColor3 = T.AccentGlow, BackgroundTransparency = .65,
            BorderSizePixel = 0, ZIndex = 2,
        }, topbar)
        corner(ring, T.RFull)
    end

    -- title
    new("TextLabel",{
        Size = UDim2.new(1,-160,1,0), Position = UDim2.new(0,32,0,0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = T.Text, TextSize = 14, Font = T.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    }, topbar)

    -- toggle key hint
    new("TextLabel",{
        Size = UDim2.new(0,70,1,0), Position = UDim2.new(1,-138,0,0),
        BackgroundTransparency = 1, Text = toggleKey.Name,
        TextColor3 = T.TextMuted, TextSize = 9, Font = T.FontLight,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3,
    }, topbar)

    -- ── CONTROL BUTTONS ───────────────────────────────────
    local function ctrlBtn(text, xOff, hoverCol, cb)
        local b = new("TextButton",{
            Size = UDim2.new(0,26,0,26),
            Position = UDim2.new(1,xOff,0.5,-13),
            BackgroundColor3 = T.Element, Text = text,
            TextColor3 = T.TextDim, TextSize = 10, Font = T.FontBold,
            BorderSizePixel = 0, ZIndex = 4,
        }, topbar)
        corner(b, T.R5)
        b.MouseEnter:Connect(function() tw(b,{BackgroundColor3 = hoverCol}) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundColor3 = T.Element}) end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    -- Close
    ctrlBtn("✕", -10, Color3.fromRGB(195,50,50), function()
        pcall(closeCb or function() end)
        tw(win, {Size=UDim2.new(0.82,0,0,0)}, .26, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(.32, function() gui:Destroy() end)
    end)

    -- Minimize → floating pill bubble
    local minimized = false
    local fullSz    = UDim2.new(0.82,0,0.80,0)

    -- floating restore bubble
    local bubble = new("Frame",{
        Size = UDim2.new(0,40,0,40),
        Position = UDim2.new(1,-50,0,8),
        BackgroundColor3 = Color3.fromRGB(18,14,36),
        BorderSizePixel = 0, ZIndex = 200, Visible = false,
    }, gui)
    corner(bubble, UDim.new(0,11))
    local bubStroke = uistroke(bubble, T.Accent, 1.2)
    gradient(bubble, Color3.fromRGB(72,44,188), Color3.fromRGB(18,12,40), 135)

    -- three bar icon
    for i,yOff in ipairs({-6,0,6}) do
        local bar = new("Frame",{
            Size = UDim2.new(0,16,0,2),
            Position = UDim2.new(0.5,-8,0.5,yOff),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0, ZIndex = 202,
        }, bubble)
        corner(bar, T.RFull)
    end

    local bubBtn = new("TextButton",{
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = "", ZIndex = 203,
    }, bubble)
    bubBtn.MouseEnter:Connect(function()
        tw(bubble,{BackgroundColor3 = Color3.fromRGB(28,18,58)})
        tw(bubStroke,{Color=T.AccentSoft, Thickness=1.8})
    end)
    bubBtn.MouseLeave:Connect(function()
        tw(bubble,{BackgroundColor3 = Color3.fromRGB(18,14,36)})
        tw(bubStroke,{Color=T.Accent, Thickness=1.2})
    end)
    bubBtn.MouseButton1Click:Connect(function()
        minimized = false
        bubble.Visible = false
        win.Visible = true
        tw(win, {Size=fullSz}, .3, Enum.EasingStyle.Back)
    end)

    local function pulseBubble()
        if not bubble.Visible then return end
        tw(bubStroke,{Color=T.AccentSoft, Thickness=1.8},.85)
        task.delay(.9, function()
            if not bubble.Visible then return end
            tw(bubStroke,{Color=T.AccentGlow, Thickness=1.0},.85)
            task.delay(.9, pulseBubble)
        end)
    end

    ctrlBtn("─", -42, T.ElementHov, function()
        minimized = true
        fullSz = win.Size
        tw(win, {Size=UDim2.new(0.82,0,0,0)}, .2, Enum.EasingStyle.Quad)
        task.delay(.25, function()
            win.Visible = false
            bubble.Visible = true
            bubble.Size = UDim2.new(0,0,0,0)
            bubble.Position = UDim2.new(1,-30,0,28)
            tw(bubble,{Size=UDim2.new(0,40,0,40), Position=UDim2.new(1,-50,0,8)},.32,Enum.EasingStyle.Back)
            pulseBubble()
        end)
    end)

    -- drag
    local _drag,_dstart,_wstart = false,nil,nil
    topbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            _drag=true; _dstart=i.Position; _wstart=win.Position
        end
    end)
    topbar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then _drag=false end
    end)
    table.insert(self._conns, UserInputService.InputChanged:Connect(function(i)
        if _drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - _dstart
            win.Position = UDim2.new(_wstart.X.Scale, _wstart.X.Offset+d.X,
                                     _wstart.Y.Scale, _wstart.Y.Offset+d.Y)
        end
    end))
    table.insert(self._conns, UserInputService.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode == toggleKey then
            win.Visible = not win.Visible
        end
    end))

    -- ── SIDEBAR ───────────────────────────────────────────
    -- Premium ID whitelist
    local PREMIUM_IDS = opts.PremiumIds or {}
    local isPremium = false
    for _,id in ipairs(PREMIUM_IDS) do
        if LocalPlayer.UserId == id then isPremium = true; break end
    end

    local tabBar = new("ScrollingFrame",{
        Size = UDim2.new(0,TAB_W,1,-(TOP_H+CARD_H)),
        Position = UDim2.new(0,0,0,TOP_H),
        BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
    }, win)
    vlist(tabBar, 1)
    padding(tabBar,10,4,8,8)

    -- sidebar right divider
    new("Frame",{
        Size = UDim2.new(0,1,1,-TOP_H), Position = UDim2.new(0,TAB_W,0,TOP_H),
        BackgroundColor3 = T.Divider, BorderSizePixel = 0,
    }, win)

    -- content area
    local contentArea = new("Frame",{
        Size = UDim2.new(1,-(TAB_W+1),1,-TOP_H),
        Position = UDim2.new(0,TAB_W+1,0,TOP_H),
        BackgroundColor3 = T.Content, ClipsDescendants = true,
    }, win)

    -- ── PLAYER CARD ───────────────────────────────────────
    new("Frame",{  -- divider above card
        Size = UDim2.new(0,TAB_W,0,1), Position = UDim2.new(0,0,1,-CARD_H),
        BackgroundColor3 = T.Divider, BorderSizePixel = 0,
    }, win)

    local playerCard = new("Frame",{
        Size = UDim2.new(0,TAB_W,0,CARD_H-1),
        Position = UDim2.new(0,0,1,-(CARD_H-1)),
        BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
    }, win)
    padding(playerCard,8,8,10,8)
    vlist(playerCard, 5)

    -- avatar + names row
    local pcRow = new("Frame",{
        Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1,
    }, playerCard)

    local pcAv = new("Frame",{
        Size = UDim2.new(0,30,0,30), Position = UDim2.new(0,0,0.5,-15),
        BackgroundColor3 = T.Element, BorderSizePixel = 0, ZIndex = 2,
    }, pcRow)
    corner(pcAv, T.RFull)
    uistroke(pcAv, T.Accent, 1.5)
    local pcAvImg = new("ImageLabel",{
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId="
            ..tostring(LocalPlayer.UserId).."&width=48&height=48&format=png",
        ZIndex = 3,
    }, pcAv)
    corner(pcAvImg, T.RFull)

    local pcNames = new("Frame",{
        Size = UDim2.new(1,-38,1,0), Position = UDim2.new(0,36,0,0),
        BackgroundTransparency = 1,
    }, pcRow)
    vlist(pcNames, 2)
    padding(pcNames,4,0,0,0)

    new("TextLabel",{
        Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = T.Text, TextSize = 12, Font = T.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, pcNames)
    new("TextLabel",{
        Size = UDim2.new(1,0,0,11), BackgroundTransparency = 1,
        Text = "@"..LocalPlayer.Name,
        TextColor3 = T.TextMuted, TextSize = 10, Font = T.FontLight,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, pcNames)

    -- premium / free badge
    if hidePremium ~= true then
        local badgeBg = new("Frame",{
            Size = UDim2.new(0, isPremium and 78 or 46, 0,17),
            BackgroundColor3 = isPremium
                and Color3.fromRGB(50,28,130)
                or  Color3.fromRGB(22,18,40),
            BorderSizePixel = 0,
        }, playerCard)
        corner(badgeBg, T.RFull)
        uistroke(badgeBg,
            isPremium and Color3.fromRGB(130,90,245) or Color3.fromRGB(38,30,66), 1)
        if isPremium then
            gradient(badgeBg,
                Color3.fromRGB(85,44,215), Color3.fromRGB(50,26,148), 90)
        end
        new("TextLabel",{
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Text = isPremium and "★  Premium" or "Free",
            TextColor3 = isPremium
                and Color3.fromRGB(210,190,255)
                or  Color3.fromRGB(90,80,130),
            TextSize = 9, Font = T.FontBold,
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 2,
        }, badgeBg)
    end

    -- entrance animation
    win.Size = UDim2.new(0.82,0,0,0)
    tw(win, {Size=UDim2.new(0.82,0,0.80,0)}, .4, Enum.EasingStyle.Back)

    -- ════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════════════════════════
    local Window = {
        _tabs    = {},
        _btns    = {},
        _active  = nil,
        _cfgFolder = cfgFolder,
        _saveConfig = saveConfig,
    }

    function Window:_select(name)
        for n,f in pairs(self._tabs) do f.Visible = (n==name) end
        for n,b in pairs(self._btns) do
            local isActive = (n==name)
            local gradFr = b:FindFirstChild("_grad")
            local bar    = b:FindFirstChild("_bar")
            local lbl    = b:FindFirstChildOfClass("TextLabel")
            if isActive then
                tw(b,{BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(28,18,62)})
                if gradFr then gradFr.Visible = true end
                if bar    then tw(bar,{BackgroundTransparency=0}) end
                if lbl    then lbl.TextColor3 = T.Text end
            else
                tw(b,{BackgroundTransparency=1})
                if gradFr then gradFr.Visible = false end
                if bar    then tw(bar,{BackgroundTransparency=1}) end
                if lbl    then lbl.TextColor3 = T.TextDim end
            end
        end
        self._active = name
    end

    function Window:_saveAll()
        if not self._saveConfig then return end
        local data = {}
        for f,obj in pairs(Nova.Flags) do
            if obj._save then data[f] = obj.Value end
        end
        safeWrite(self._cfgFolder.."/config.json", HttpService:JSONEncode(data))
    end

    function Window:_loadAll()
        if not self._saveConfig then return end
        local raw = safeRead(self._cfgFolder.."/config.json")
        if not raw then return end
        local ok,data = pcall(HttpService.JSONDecode,HttpService,raw)
        if not ok or type(data)~="table" then return end
        for f,v in pairs(data) do
            if Nova.Flags[f] and Nova.Flags[f].Set then
                Nova.Flags[f]:Set(v)
            end
        end
    end

    -- ────────────────────────────────────────────────────
    --  MAKE TAB
    -- ────────────────────────────────────────────────────
    function Window:MakeTab(opts)
        opts = opts or {}
        local name        = opts.Name        or "Tab"
        local icon        = opts.Icon        or ""
        local premiumOnly = opts.PremiumOnly or false

        -- sidebar button
        local btn = new("TextButton",{
            Size = UDim2.new(1,0,0,36),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(28,18,62),
            Text = "", BorderSizePixel = 0,
        }, tabBar)
        corner(btn, T.R6)

        -- gradient fill (shown when active — Workly style)
        local gradFr = new("Frame",{
            Name = "_grad",
            Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = T.TabActive0,
            BorderSizePixel = 0, Visible = false, ZIndex = 0,
        }, btn)
        corner(gradFr, T.R6)
        gradient(gradFr, T.TabActive0, T.TabActive1, 90)

        -- left active indicator bar
        local bar = new("Frame",{
            Name = "_bar",
            Size = UDim2.new(0,3,0.55,0),
            Position = UDim2.new(0,-1,0.225,0),
            BackgroundColor3 = T.AccentSoft,
            BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 3,
        }, btn)
        corner(bar, T.RFull)

        -- icon + label
        local hasImg = icon ~= "" and icon:find("rbxassetid")
        if hasImg then
            new("ImageLabel",{
                Size = UDim2.new(0,16,0,16),
                Position = UDim2.new(0,10,0.5,-8),
                BackgroundTransparency = 1, Image = icon, ZIndex = 2,
            }, btn)
        end
        local lbl = new("TextLabel",{
            Size = hasImg
                and UDim2.new(1,-34,1,0)
                or  UDim2.new(1,-14,1,0),
            Position = hasImg
                and UDim2.new(0,32,0,0)
                or  UDim2.new(0,12,0,0),
            BackgroundTransparency = 1,
            Text = (not hasImg and icon~="" and icon.."  " or "")..name,
            TextColor3 = T.TextDim, TextSize = 13, Font = T.Font,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
        }, btn)

        -- premium lock overlay
        if premiumOnly and not isPremium then
            local lockOverlay = new("TextButton",{
                Size = UDim2.new(1,0,1,0), BackgroundColor3 = T.Sidebar,
                BackgroundTransparency = .3, Text = "🔒",
                TextColor3 = T.TextMuted, TextSize = 11,
                Font = T.FontBold, BorderSizePixel = 0, ZIndex = 5,
            }, btn)
            corner(lockOverlay, T.R6)
            lockOverlay.MouseButton1Click:Connect(function()
                Nova:MakeNotification({
                    Name    = "Premium Required",
                    Content = "This tab is for premium users only.",
                    Time    = 3,
                })
            end)
        end

        btn.MouseEnter:Connect(function()
            if self._active ~= name then
                tw(btn,{BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(20,14,42)})
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._active ~= name then tw(btn,{BackgroundTransparency=1}) end
        end)

        -- scroll frame for tab content
        local scroll = new("ScrollingFrame",{
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, contentArea)
        vlist(scroll, 5)
        padding(scroll,8,8,8,8)

        self._tabs[name] = scroll
        self._btns[name] = btn

        btn.MouseButton1Click:Connect(function()
            if premiumOnly and not isPremium then return end
            self:_select(name)
        end)
        if not self._active then self:_select(name) end

        -- ════════════════════════════════════════════════
        --  TAB OBJECT
        -- ════════════════════════════════════════════════
        local Tab = { _scroll = scroll, _override = nil }

        local function target()
            return Tab._override or scroll
        end

        -- base element card
        local function elem(h, bg)
            local f = new("Frame",{
                Size = UDim2.new(1,0,0,h or 40),
                BackgroundColor3 = bg or T.Element,
                BorderSizePixel = 0,
            }, target())
            corner(f, T.R8)
            return f
        end

        -- left-aligned label inside an element
        local function lblLeft(parent, text, wScale)
            return new("TextLabel",{
                Size = UDim2.new(wScale or .58,0,1,0),
                Position = UDim2.new(0,11,0,0),
                BackgroundTransparency = 1, Text = text,
                TextColor3 = T.Text, TextSize = 12, Font = T.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, parent)
        end

        -- ── SECTION ──────────────────────────────────
        function Tab:AddSection(opts)
            local name = type(opts)=="string" and opts
                      or (opts and opts.Name or "Section")

            -- bare caps label, no background (Workly/Orion style)
            new("Frame",{
                Size = UDim2.new(1,0,0,22),
                BackgroundTransparency = 1, BorderSizePixel = 0,
            }, target()):FindFirstChildOfClass("UIListLayout") -- ignored

            local hdr = new("Frame",{
                Size = UDim2.new(1,0,0,22),
                BackgroundTransparency = 1, BorderSizePixel = 0,
            }, target())

            new("TextLabel",{
                Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,6,0,0),
                BackgroundTransparency = 1, Text = name:upper(),
                TextColor3 = Color3.fromRGB(75,64,108),
                TextSize = 9, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, hdr)

            local container = new("Frame",{
                Size = UDim2.new(1,0,0,0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, target())
            vlist(container, 4)

            -- proxy object: any Tab:AddXxx call gets routed into container
            local Section = {}
            setmetatable(Section, {__index = function(_, k)
                return function(self2, ...)
                    if Tab[k] then
                        Tab._override = container
                        local r = Tab[k](Tab, ...)
                        Tab._override = nil
                        return r
                    end
                end
            end})
            return Section
        end

        -- ── LABEL ────────────────────────────────────
        function Tab:AddLabel(text)
            local f = new("Frame",{
                Size = UDim2.new(1,0,0,30),
                BackgroundColor3 = T.Element, BorderSizePixel = 0,
            }, target())
            corner(f, T.R8)
            local lbl = new("TextLabel",{
                Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,11,0,0),
                BackgroundTransparency = 1, Text = text,
                TextColor3 = T.TextSub, TextSize = 11, Font = T.FontLight,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, f)
            local obj = {}
            function obj:Set(t) lbl.Text = t end
            return obj
        end

        -- ── PARAGRAPH ────────────────────────────────
        function Tab:AddParagraph(title, body)
            -- Orion API: AddParagraph(title, body)  OR  {Name,Content}
            local t, b
            if type(title) == "table" then
                t = title.Name or ""; b = title.Content or ""
            else
                t = title or ""; b = body or ""
            end
            local f = new("Frame",{
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Element, BorderSizePixel = 0,
            }, target())
            corner(f, T.R8)
            padding(f,8,8,11,11)
            vlist(f, 4)

            local tl = new("TextLabel",{
                Size = UDim2.new(1,0,0,15),
                BackgroundTransparency = 1, Text = t,
                TextColor3 = T.Text, TextSize = 12, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, f)
            local bl = new("TextLabel",{
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, Text = b,
                TextColor3 = T.TextSub, TextSize = 11, Font = T.FontLight,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, f)

            local obj = {}
            function obj:Set(nt, nb)
                if nt then tl.Text = nt end
                if nb then bl.Text = nb end
            end
            return obj
        end

        -- ── BUTTON ───────────────────────────────────
        function Tab:AddButton(opts)
            local name = type(opts)=="string" and opts
                      or (opts and opts.Name or "Button")
            local cb   = (type(opts)=="table" and opts.Callback) or function() end

            local f = elem(38, T.AccentDark)
            gradient(f, Color3.fromRGB(52,30,118), Color3.fromRGB(36,20,85), 90)

            local b = new("TextButton",{
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = name, TextColor3 = T.Text,
                TextSize = 12, Font = T.Font,
            }, f)
            b.MouseEnter:Connect(function()
                tw(f,{BackgroundColor3 = T.Accent})
            end)
            b.MouseLeave:Connect(function()
                tw(f,{BackgroundColor3 = T.AccentDark})
            end)
            b.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3 = T.AccentSoft}, .05)
                task.wait(.1)
                tw(f,{BackgroundColor3 = T.AccentDark})
                pcall(cb)
            end)
        end

        -- ── TOGGLE ───────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local name = opts.Name     or "Toggle"
            local val  = opts.Default  or false
            local flag = opts.Flag     or nil
            local save = opts.Save     or false
            local cb   = opts.Callback or function() end

            local f = elem(40)
            lblLeft(f, name)

            local track = new("Frame",{
                Size = UDim2.new(0,42,0,22),
                Position = UDim2.new(1,-52,0.5,-11),
                BackgroundColor3 = val and T.Accent or T.ToggleOff,
                BorderSizePixel = 0,
            }, f)
            corner(track, T.RFull)

            local knob = new("Frame",{
                Size = UDim2.new(0,16,0,16),
                Position = val
                    and UDim2.new(1,-19,0.5,-8)
                    or  UDim2.new(0,3,0.5,-8),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, track)
            corner(knob, T.RFull)

            -- click anywhere on element
            new("TextButton",{
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "",
            }, f).MouseButton1Click:Connect(function()
                val = not val
                tw(track,{BackgroundColor3 = val and T.Accent or T.ToggleOff})
                tw(knob,{Position = val
                    and UDim2.new(1,-19,0.5,-8)
                    or  UDim2.new(0,3,0.5,-8)})
                if flag then Nova.Flags[flag].Value = val end
                pcall(cb, val)
                Window:_saveAll()
            end)

            local obj = {Value=val, _save=save}
            function obj:Set(v)
                val = v
                tw(track,{BackgroundColor3 = v and T.Accent or T.ToggleOff})
                tw(knob,{Position = v
                    and UDim2.new(1,-19,0.5,-8)
                    or  UDim2.new(0,3,0.5,-8)})
                self.Value = v
                if flag then Nova.Flags[flag].Value = v end
                pcall(cb, v)
            end
            if flag then Nova.Flags[flag] = obj end
            return obj
        end

        -- ── SLIDER ───────────────────────────────────
        function Tab:AddSlider(opts)
            opts = opts or {}
            local name  = opts.Name      or "Slider"
            local min   = opts.Min       or 0
            local max   = opts.Max       or 100
            local inc   = opts.Increment or 1
            local val   = math.clamp(opts.Default or min, min, max)
            local vname = opts.ValueName or ""
            local flag  = opts.Flag      or nil
            local save  = opts.Save      or false
            local col   = opts.Color     or T.Accent
            local cb    = opts.Callback  or function() end

            local f = elem(54)
            lblLeft(f, name, .58)

            local vlbl = new("TextLabel",{
                Size = UDim2.new(0,70,0,20),
                Position = UDim2.new(1,-80,0,5),
                BackgroundTransparency = 1,
                Text = tostring(val)..(vname~="" and " "..vname or ""),
                TextColor3 = col, TextSize = 11, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, f)

            local track = new("Frame",{
                Size = UDim2.new(1,-22,0,4),
                Position = UDim2.new(0,11,0,38),
                BackgroundColor3 = T.ToggleOff, BorderSizePixel = 0,
            }, f)
            corner(track, T.RFull)

            local fill = new("Frame",{
                Size = UDim2.new((val-min)/(max-min),0,1,0),
                BackgroundColor3 = col, BorderSizePixel = 0,
            }, track)
            corner(fill, T.RFull)

            local handle = new("Frame",{
                Size = UDim2.new(0,12,0,12),
                Position = UDim2.new((val-min)/(max-min),-6,0.5,-6),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, track)
            corner(handle, T.RFull)

            local dragging = false
            local function upd(x)
                local rel = math.clamp(
                    (x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = min + math.floor(rel*(max-min)/inc+.5)*inc
                val = math.clamp(val, min, max)
                rel = (val-min)/(max-min)
                vlbl.Text = tostring(val)..(vname~="" and " "..vname or "")
                tw(fill,  {Size=UDim2.new(rel,0,1,0)},         .05)
                tw(handle,{Position=UDim2.new(rel,-6,0.5,-6)}, .05)
                if flag then Nova.Flags[flag].Value = val end
                pcall(cb, val)
                Window:_saveAll()
            end

            local hb = new("TextButton",{
                Size = UDim2.new(1,0,0,24),
                Position = UDim2.new(0,0,0.5,-12),
                BackgroundTransparency = 1, Text = "", ZIndex = 2,
            }, track)
            hb.MouseButton1Down:Connect(function() dragging=true; upd(Mouse.X) end)
            table.insert(Nova._conns, UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end))
            table.insert(Nova._conns, UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                    upd(Mouse.X)
                end
            end))

            local obj = {Value=val, _save=save}
            function obj:Set(v)
                val = math.clamp(v, min, max)
                local rel = (val-min)/(max-min)
                vlbl.Text = tostring(val)..(vname~="" and " "..vname or "")
                tw(fill,  {Size=UDim2.new(rel,0,1,0)})
                tw(handle,{Position=UDim2.new(rel,-6,0.5,-6)})
                self.Value = val
                if flag then Nova.Flags[flag].Value = val end
                pcall(cb, val)
            end
            if flag then Nova.Flags[flag] = obj end
            return obj
        end

        -- ── DROPDOWN ─────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local name    = opts.Name     or "Dropdown"
            local options = opts.Options  or {}
            local sel     = opts.Default  or (options[1] or "")
            local flag    = opts.Flag     or nil
            local save    = opts.Save     or false
            local cb      = opts.Callback or function() end
            local isOpen  = false

            local f = elem(40)
            f.ClipsDescendants = false; f.ZIndex = 2
            lblLeft(f, name, .40)

            local dbtn = new("TextButton",{
                Size = UDim2.new(0,155,0,28),
                Position = UDim2.new(1,-165,0.5,-14),
                BackgroundColor3 = Color3.fromRGB(12,10,22),
                Text = sel.."  ▾",
                TextColor3 = T.TextSub, TextSize = 11, Font = T.Font,
                BorderSizePixel = 0, ZIndex = 3,
            }, f)
            corner(dbtn, T.R6)
            uistroke(dbtn, T.Divider, 1)

            -- dropdown list (parented to contentArea so it floats above)
            local list = new("Frame",{
                Size = UDim2.new(0,155,0,0),
                BackgroundColor3 = Color3.fromRGB(14,12,26),
                BorderSizePixel = 0, ClipsDescendants = true,
                ZIndex = 30, Visible = false,
            }, contentArea)
            corner(list, T.R6)
            uistroke(list, T.Divider, 1)
            vlist(list)
            padding(list,3,3,0,0)

            local listH = math.min(#options,7)*28+6

            local function reposition()
                local ap = dbtn.AbsolutePosition
                local ca = contentArea.AbsolutePosition
                list.Position = UDim2.new(0, ap.X-ca.X, 0, ap.Y-ca.Y+dbtn.AbsoluteSize.Y+3)
            end

            local function closeList()
                isOpen = false
                tw(list, {Size=UDim2.new(0,155,0,0)}, .14)
                task.delay(.16, function() list.Visible = false end)
            end

            local function buildItems()
                for _,c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _,opt in ipairs(options) do
                    local it = new("TextButton",{
                        Size = UDim2.new(1,0,0,28),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = T.Accent,
                        Text = "  "..opt,
                        TextColor3 = opt==sel and T.Text or T.TextSub,
                        TextSize = 11, Font = T.Font,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
                    }, list)
                    it.MouseEnter:Connect(function()
                        tw(it,{BackgroundTransparency=0}); it.TextColor3=T.Text
                    end)
                    it.MouseLeave:Connect(function()
                        tw(it,{BackgroundTransparency=1})
                        if opt~=sel then it.TextColor3=T.TextSub end
                    end)
                    it.MouseButton1Click:Connect(function()
                        sel = opt; dbtn.Text = opt.."  ▾"; closeList()
                        if flag then Nova.Flags[flag].Value = opt end
                        pcall(cb, opt); Window:_saveAll()
                    end)
                end
            end
            buildItems()

            dbtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    reposition(); list.Visible = true
                    tw(list, {Size=UDim2.new(0,155,0,listH)}, .2, Enum.EasingStyle.Back)
                else
                    closeList()
                end
            end)

            local obj = {Value=sel, _save=save}
            function obj:Set(v)   sel=v; dbtn.Text=v.."  ▾"; self.Value=v end
            function obj:Refresh(tbl, clear)
                if clear then options={} end
                for _,v in ipairs(tbl) do table.insert(options,v) end
                listH = math.min(#options,7)*28+6
                buildItems()
            end
            if flag then Nova.Flags[flag] = obj end
            return obj
        end

        -- ── COLORPICKER ──────────────────────────────
        function Tab:AddColorpicker(opts)
            opts = opts or {}
            local name = opts.Name     or "Color"
            local col  = opts.Default  or Color3.fromRGB(255,80,80)
            local flag = opts.Flag     or nil
            local save = opts.Save     or false
            local cb   = opts.Callback or function() end
            local isOpen = false

            local f = elem(40)
            lblLeft(f, name, .65)

            local swatch = new("Frame",{
                Size = UDim2.new(0,26,0,26),
                Position = UDim2.new(1,-44,0.5,-13),
                BackgroundColor3 = col, BorderSizePixel = 0,
            }, f)
            corner(swatch, T.R5)
            uistroke(swatch, T.Divider, 1)

            local chevron = new("TextLabel",{
                Size = UDim2.new(0,14,1,0),
                Position = UDim2.new(1,-16,0,0),
                BackgroundTransparency = 1, Text = "▾",
                TextColor3 = T.TextMuted, TextSize = 10, Font = T.FontBold,
            }, f)

            -- expandable RGB panel (sits in same list below the element)
            local panel = new("Frame",{
                Size = UDim2.new(1,0,0,0),
                BackgroundColor3 = Color3.fromRGB(12,10,22),
                BorderSizePixel = 0, ClipsDescendants = true, Visible = false,
            }, target())
            corner(panel, T.R8)
            uistroke(panel, T.Divider, 1)
            padding(panel,8,8,10,10)
            vlist(panel, 6)

            local r = math.floor(col.R*255)
            local g = math.floor(col.G*255)
            local b = math.floor(col.B*255)

            local function push()
                col = Color3.fromRGB(r,g,b)
                swatch.BackgroundColor3 = col
                if flag then Nova.Flags[flag].Value = col end
                pcall(cb, col); Window:_saveAll()
            end

            local function mkChannel(lbl, init, setter)
                local row = new("Frame",{
                    Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1,
                }, panel)
                new("TextLabel",{
                    Size = UDim2.new(0,14,1,0), BackgroundTransparency = 1,
                    Text = lbl, TextColor3 = T.TextDim,
                    TextSize = 10, Font = T.FontBold,
                }, row)
                local trk = new("Frame",{
                    Size = UDim2.new(1,-46,0,3),
                    Position = UDim2.new(0,18,0.5,-1.5),
                    BackgroundColor3 = T.ToggleOff, BorderSizePixel = 0,
                }, row)
                corner(trk, T.RFull)
                local fl = new("Frame",{
                    Size = UDim2.new(init/255,0,1,0),
                    BackgroundColor3 = T.Accent, BorderSizePixel = 0,
                }, trk)
                corner(fl, T.RFull)
                local vl = new("TextLabel",{
                    Size = UDim2.new(0,26,1,0),
                    Position = UDim2.new(1,-28,0,0),
                    BackgroundTransparency = 1, Text = tostring(init),
                    TextColor3 = T.Accent, TextSize = 10, Font = T.FontBold,
                }, row)
                local d2 = false
                local function u(x)
                    local rel = math.clamp(
                        (x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X, 0,1)
                    local v2 = math.floor(rel*255)
                    fl.Size = UDim2.new(rel,0,1,0); vl.Text = tostring(v2)
                    setter(v2); push()
                end
                local hb = new("TextButton",{
                    Size = UDim2.new(1,0,0,20),
                    Position = UDim2.new(0,0,0.5,-10),
                    BackgroundTransparency = 1, Text = "", ZIndex = 2,
                }, trk)
                hb.MouseButton1Down:Connect(function() d2=true; u(Mouse.X) end)
                table.insert(Nova._conns, UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then d2=false end
                end))
                table.insert(Nova._conns, UserInputService.InputChanged:Connect(function(i)
                    if d2 and i.UserInputType==Enum.UserInputType.MouseMovement then
                        u(Mouse.X)
                    end
                end))
            end

            mkChannel("R", r, function(v) r=v end)
            mkChannel("G", g, function(v) g=v end)
            mkChannel("B", b, function(v) b=v end)

            -- hex input row
            local hexRow = new("Frame",{
                Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1,
            }, panel)
            new("TextLabel",{
                Size = UDim2.new(0,22,1,0), BackgroundTransparency = 1,
                Text = "#", TextColor3 = T.TextDim, TextSize = 10, Font = T.FontBold,
            }, hexRow)
            local hexBox = new("TextBox",{
                Size = UDim2.new(1,-26,0,22),
                Position = UDim2.new(0,24,0.5,-11),
                BackgroundColor3 = Color3.fromRGB(10,8,18),
                Text = string.format("%02X%02X%02X",r,g,b),
                PlaceholderText = "RRGGBB",
                PlaceholderColor3 = T.TextMuted,
                TextColor3 = T.TextSub, TextSize = 10, Font = T.Font,
                BorderSizePixel = 0, ClearTextOnFocus = false,
            }, hexRow)
            corner(hexBox, T.R5)
            uistroke(hexBox, T.Divider, 1)
            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#",""):upper()
                if #hex == 6 then
                    local ok,hr,hg,hb = pcall(function()
                        return tonumber(hex:sub(1,2),16),
                               tonumber(hex:sub(3,4),16),
                               tonumber(hex:sub(5,6),16)
                    end)
                    if ok and hr and hg and hb then
                        r,g,b = hr,hg,hb; push()
                    end
                end
                hexBox.Text = string.format("%02X%02X%02X",r,g,b)
            end)

            -- toggle open
            new("TextButton",{
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "",
            }, f).MouseButton1Click:Connect(function()
                isOpen = not isOpen
                chevron.Text = isOpen and "▴" or "▾"
                if isOpen then
                    panel.Visible = true
                    tw(panel, {Size=UDim2.new(1,0,0,130)}, .22, Enum.EasingStyle.Back)
                else
                    tw(panel, {Size=UDim2.new(1,0,0,0)}, .18)
                    task.delay(.2, function() panel.Visible=false end)
                end
            end)

            local obj = {Value=col, _save=save}
            function obj:Set(c)
                col=c; swatch.BackgroundColor3=c
                r=math.floor(c.R*255); g=math.floor(c.G*255); b=math.floor(c.B*255)
                hexBox.Text = string.format("%02X%02X%02X",r,g,b)
                self.Value=c
                if flag then Nova.Flags[flag].Value=c end
                pcall(cb,c)
            end
            if flag then Nova.Flags[flag] = obj end
            return obj
        end

        -- ── BIND (Keybind) ────────────────────────────
        function Tab:AddBind(opts)
            opts = opts or {}
            local name = opts.Name     or "Bind"
            local key  = opts.Default  or Enum.KeyCode.E
            local hold = opts.Hold     or false
            local flag = opts.Flag     or nil
            local save = opts.Save     or false
            local cb   = opts.Callback or function() end
            local listening = false
            local holding   = false

            local f = elem(40)
            lblLeft(f, name, .52)

            local kbtn = new("TextButton",{
                Size = UDim2.new(0,116,0,28),
                Position = UDim2.new(1,-126,0.5,-14),
                BackgroundColor3 = Color3.fromRGB(12,10,22),
                Text = "[ "..key.Name.." ]",
                TextColor3 = T.Accent, TextSize = 11, Font = T.FontBold,
                BorderSizePixel = 0,
            }, f)
            corner(kbtn, T.R5)
            uistroke(kbtn, T.Divider, 1)

            kbtn.MouseButton1Click:Connect(function()
                listening = true
                kbtn.Text = "[ ... ]"
                kbtn.TextColor3 = T.Warning
            end)

            table.insert(Nova._conns, UserInputService.InputBegan:Connect(function(i,gp)
                if gp then return end
                if listening then
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        key = i.KeyCode
                        kbtn.Text = "[ "..key.Name.." ]"
                        kbtn.TextColor3 = T.Accent
                        listening = false
                        if flag then Nova.Flags[flag].Value = key end
                        Window:_saveAll()
                    end
                    return
                end
                if i.KeyCode == key then
                    if hold then holding = true end
                    pcall(cb)
                end
            end))
            table.insert(Nova._conns, UserInputService.InputEnded:Connect(function(i)
                if hold and i.KeyCode == key then holding = false end
            end))

            local obj = {Value=key, _save=save}
            function obj:Set(k)
                key = k; kbtn.Text = "[ "..k.Name.." ]"; self.Value = k
                if flag then Nova.Flags[flag].Value = k end
            end
            function obj:IsHolding() return holding end
            if flag then Nova.Flags[flag] = obj end
            return obj
        end

        -- ── TEXTBOX ──────────────────────────────────
        function Tab:AddTextbox(opts)
            opts = opts or {}
            local name        = opts.Name          or "Input"
            local default     = opts.Default       or ""
            local placeholder = opts.Placeholder   or "Type here..."
            local vanish      = opts.TextDisappear or false
            local maxChars    = opts.MaxChars      or 200
            local numbersOnly = opts.NumbersOnly   or false
            local cb          = opts.Callback      or function() end

            local wrapper = new("Frame",{
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0,
            }, target())
            vlist(wrapper, 4)

            -- label + counter
            local labelRow = new("Frame",{
                Size = UDim2.new(1,0,0,15),
                BackgroundTransparency = 1,
            }, wrapper)
            new("TextLabel",{
                Size = UDim2.new(.7,0,1,0),
                BackgroundTransparency = 1, Text = name,
                TextColor3 = T.TextSub, TextSize = 11, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, labelRow)
            local counter = new("TextLabel",{
                Size = UDim2.new(.3,0,1,0),
                Position = UDim2.new(.7,0,0,0),
                BackgroundTransparency = 1,
                Text = "0 / "..maxChars,
                TextColor3 = T.TextMuted, TextSize = 9, Font = T.FontLight,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, labelRow)

            -- input row
            local inputFrame = new("Frame",{
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = Color3.fromRGB(10,8,20),
                BorderSizePixel = 0, ClipsDescendants = true,
            }, wrapper)
            corner(inputFrame, T.R8)
            local inputStroke = uistroke(inputFrame, Color3.fromRGB(28,22,52), 1.5)

            local acBar2 = new("Frame",{
                Size = UDim2.new(0,2,.55,0),
                Position = UDim2.new(0,0,.225,0),
                BackgroundColor3 = T.Accent, BorderSizePixel = 0,
                BackgroundTransparency = 1,
            }, inputFrame)
            corner(acBar2, T.RFull)

            new("TextLabel",{
                Size = UDim2.new(0,30,1,0),
                BackgroundTransparency = 1, Text = "✎",
                TextColor3 = Color3.fromRGB(55,44,90),
                TextSize = 14, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, inputFrame)

            local box = new("TextBox",{
                Size = UDim2.new(1,-64,1,0),
                Position = UDim2.new(0,32,0,0),
                BackgroundTransparency = 1, Text = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = T.TextMuted,
                TextColor3 = T.Text, TextSize = 12, Font = T.FontLight,
                BorderSizePixel = 0, ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, inputFrame)

            local clearBtn = new("TextButton",{
                Size = UDim2.new(0,26,0,26),
                Position = UDim2.new(1,-32,0.5,-13),
                BackgroundColor3 = Color3.fromRGB(28,22,48),
                Text = "✕", TextColor3 = T.TextMuted,
                TextSize = 10, Font = T.FontBold,
                BorderSizePixel = 0, BackgroundTransparency = 1,
            }, inputFrame)
            corner(clearBtn, T.RFull)

            clearBtn.MouseButton1Click:Connect(function()
                box.Text = ""; counter.Text = "0 / "..maxChars
                pcall(cb, "", false)
            end)

            box.Focused:Connect(function()
                tw(inputStroke,{Color=T.Accent})
                tw(inputFrame,{BackgroundColor3=Color3.fromRGB(14,11,28)})
                tw(acBar2,{BackgroundTransparency=0})
                tw(clearBtn,{BackgroundTransparency=0, TextColor3=T.TextSub})
            end)
            box.FocusLost:Connect(function(enter)
                tw(inputStroke,{Color=Color3.fromRGB(28,22,52)})
                tw(inputFrame,{BackgroundColor3=Color3.fromRGB(10,8,20)})
                tw(acBar2,{BackgroundTransparency=1})
                tw(clearBtn,{BackgroundTransparency=1, TextColor3=T.TextMuted})
                local txt = box.Text
                if numbersOnly and not tonumber(txt) then txt=""; box.Text="" end
                if #txt>maxChars then txt=txt:sub(1,maxChars); box.Text=txt end
                pcall(cb, txt, enter)
                if vanish then box.Text=""; counter.Text="0 / "..maxChars end
            end)

            box:GetPropertyChangedSignal("Text"):Connect(function()
                local txt = box.Text
                if numbersOnly then
                    local clean = txt:gsub("[^%d%.-]","")
                    if clean~=txt then box.Text=clean; return end
                end
                if #txt>maxChars then box.Text=txt:sub(1,maxChars); return end
                local len = #txt
                counter.Text = len.." / "..maxChars
                counter.TextColor3 = len>=maxChars and T.Danger
                    or (len>=math.floor(maxChars*.8) and T.Warning or T.TextMuted)
            end)
            counter.Text = #default.." / "..maxChars

            local obj = {}
            function obj:Set(v)
                box.Text = tostring(v)
                counter.Text = #tostring(v).." / "..maxChars
            end
            function obj:Get()   return box.Text end
            function obj:Clear() box.Text=""; counter.Text="0 / "..maxChars end
            return obj
        end

        -- ── KEY SYSTEM ────────────────────────────────
        function Tab:AddKeySystem(opts)
            opts = opts or {}
            local title       = opts.Title       or "Key System"
            local description = opts.Description or "Enter your key to access the script."
            local keys        = opts.Keys        or {}
            local placeholder = opts.Placeholder or "Enter key here..."
            local getKeyUrl   = opts.GetKeyUrl   or nil
            local onSuccess   = opts.onSuccess   or function() end
            local onFail      = opts.onFail      or function() end

            local card = new("Frame",{
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(12,10,22),
                BorderSizePixel = 0,
            }, target())
            corner(card, T.R10)
            uistroke(card, Color3.fromRGB(30,24,52), 1)
            padding(card,16,16,14,14)
            vlist(card, 10)

            -- title row
            local titleRow = new("Frame",{
                Size = UDim2.new(1,0,0,28), BackgroundTransparency=1,
            }, card)
            local iconCircle = new("Frame",{
                Size = UDim2.new(0,28,0,28),
                BackgroundColor3 = Color3.fromRGB(48,28,124),
                BorderSizePixel = 0,
            }, titleRow)
            corner(iconCircle, T.RFull)
            gradient(iconCircle, Color3.fromRGB(88,48,210), Color3.fromRGB(48,26,130), 135)
            new("TextLabel",{
                Size = UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text = "🔑", TextSize = 13, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, iconCircle)
            new("TextLabel",{
                Size = UDim2.new(1,-38,1,0), Position = UDim2.new(0,36,0,0),
                BackgroundTransparency = 1, Text = title,
                TextColor3 = T.Text, TextSize = 13, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, titleRow)

            -- description
            new("TextLabel",{
                Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, Text = description,
                TextColor3 = T.TextDim, TextSize = 11, Font = T.FontLight,
                TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            }, card)

            -- input
            local inputFrame = new("Frame",{
                Size = UDim2.new(1,0,0,42),
                BackgroundColor3 = Color3.fromRGB(8,7,16),
                BorderSizePixel = 0, ClipsDescendants = true,
            }, card)
            corner(inputFrame, T.R8)
            local inputStroke = uistroke(inputFrame, Color3.fromRGB(28,22,52), 1.5)
            new("TextLabel",{
                Size = UDim2.new(0,34,1,0), BackgroundTransparency=1,
                Text = "⌨", TextSize = 13, TextColor3 = T.TextMuted,
                Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Center,
            }, inputFrame)
            local keyInput = new("TextBox",{
                Size = UDim2.new(1,-38,1,0), Position = UDim2.new(0,34,0,0),
                BackgroundTransparency = 1, Text = "",
                PlaceholderText = placeholder,
                PlaceholderColor3 = T.TextMuted,
                TextColor3 = T.Text, TextSize = 12, Font = T.Font,
                BorderSizePixel = 0, ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, inputFrame)
            keyInput.Focused:Connect(function()
                tw(inputStroke,{Color=T.Accent})
                tw(inputFrame,{BackgroundColor3=Color3.fromRGB(12,10,24)})
            end)
            keyInput.FocusLost:Connect(function()
                tw(inputStroke,{Color=Color3.fromRGB(28,22,52)})
                tw(inputFrame,{BackgroundColor3=Color3.fromRGB(8,7,16)})
            end)

            -- status label
            local statusLbl = new("TextLabel",{
                Size = UDim2.new(1,0,0,14),
                BackgroundTransparency = 1, Text = "",
                TextSize = 10, Font = T.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left, Visible = false,
            }, card)

            -- verify button
            local verifyBtn = new("TextButton",{
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = Color3.fromRGB(52,28,138),
                Text = "", BorderSizePixel = 0,
            }, card)
            corner(verifyBtn, T.R8)
            gradient(verifyBtn, Color3.fromRGB(88,48,210), Color3.fromRGB(52,26,148), 90)
            local btnLbl = new("TextLabel",{
                Size = UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text = "Verify Key", TextColor3 = T.Text,
                TextSize = 13, Font = T.FontBold,
            }, verifyBtn)
            verifyBtn.MouseEnter:Connect(function()
                tw(verifyBtn,{BackgroundColor3=Color3.fromRGB(68,38,175)})
            end)
            verifyBtn.MouseLeave:Connect(function()
                tw(verifyBtn,{BackgroundColor3=Color3.fromRGB(52,28,138)})
            end)

            -- get key link
            if getKeyUrl then
                new("TextLabel",{
                    Size = UDim2.new(1,0,0,13),
                    BackgroundTransparency = 1,
                    Text = "🔗  Get a key:  "..getKeyUrl,
                    TextColor3 = T.TextMuted, TextSize = 10, Font = T.FontLight,
                    TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true,
                }, card)
            end

            -- verify logic
            local verified = false
            local attempts = 0
            local MAX     = 5

            local function doVerify()
                if verified then return end
                if attempts >= MAX then
                    statusLbl.Visible = true
                    statusLbl.Text = "✘  Too many attempts. Rejoin to try again."
                    statusLbl.TextColor3 = T.Danger
                    return
                end
                local entered = keyInput.Text:gsub("%s","")
                if entered == "" then
                    statusLbl.Visible = true
                    statusLbl.Text = "✘  Please enter a key."
                    statusLbl.TextColor3 = T.Danger
                    tw(inputStroke,{Color=T.Danger})
                    task.delay(.8,function() tw(inputStroke,{Color=Color3.fromRGB(28,22,52)}) end)
                    return
                end
                attempts = attempts + 1
                btnLbl.Text = "Verifying..."
                tw(verifyBtn,{BackgroundColor3=Color3.fromRGB(30,18,75)})

                task.delay(.55, function()
                    local valid = false
                    for _,k in ipairs(keys) do
                        if entered == tostring(k) then valid=true; break end
                    end
                    if valid then
                        verified = true
                        tw(verifyBtn,{BackgroundColor3=Color3.fromRGB(28,105,62)})
                        tw(inputStroke,{Color=T.Success})
                        btnLbl.Text = "✔  Access Granted"
                        statusLbl.Visible = true
                        statusLbl.Text = "✔  Key accepted! Welcome, "..LocalPlayer.Name.."."
                        statusLbl.TextColor3 = T.Success
                        verifyBtn.Active = false
                        keyInput.TextEditable = false
                        Nova:MakeNotification({
                            Name="Key System", Content="Key verified! Access granted.", Time=4
                        })
                        pcall(onSuccess, entered)
                    else
                        tw(verifyBtn,{BackgroundColor3=Color3.fromRGB(52,28,138)})
                        tw(inputStroke,{Color=T.Danger})
                        btnLbl.Text = "Verify Key"
                        statusLbl.Visible = true
                        statusLbl.Text = "✘  Invalid key. ("..attempts.."/"..MAX.." attempts)"
                        statusLbl.TextColor3 = T.Danger
                        task.delay(1,function()
                            tw(inputStroke,{Color=Color3.fromRGB(28,22,52)})
                        end)
                        -- shake
                        for i=1,4 do
                            task.wait(0.04)
                            inputFrame.Position = UDim2.new(0,(i%2==0 and 4 or -4),0,0)
                        end
                        inputFrame.Position = UDim2.new(0,0,0,0)
                        pcall(onFail, entered)
                    end
                end)
            end

            verifyBtn.MouseButton1Click:Connect(doVerify)
            keyInput.FocusLost:Connect(function(enter) if enter then doVerify() end end)

            local obj = {}
            function obj:IsVerified() return verified end
            function obj:SetKeys(t)  keys = t end
            return obj
        end

        return Tab
    end -- MakeTab

    Window._loadFn = function() Window:_loadAll() end
    return Window
end -- MakeWindow

-- ════════════════════════════════════════════════════════════
--  DESTROY
-- ════════════════════════════════════════════════════════════
function Nova:Destroy()
    for _,c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns = {}
    if self._gui then self._gui:Destroy(); self._gui = nil end
    self.Flags = {}
end

-- ════════════════════════════════════════════════════════════
--  INIT  (Orion compatibility stub)
-- ════════════════════════════════════════════════════════════
function Nova:Init() end

return Nova
