--[[
╔══════════════════════════════════════════════════════════════╗
║                    NOVA UI LIBRARY  v6.0                     ║
║         Liquid Glass · Premium Borders · Orion API           ║
╠══════════════════════════════════════════════════════════════╣
║  Drop-in Orion replacement — same exact API                  ║
╠══════════════════════════════════════════════════════════════╣
║  MakeWindow · MakeTab · AddSection · AddButton               ║
║  AddToggle · AddSlider · AddDropdown · AddColorpicker        ║
║  AddBind · AddTextbox · AddLabel · AddParagraph              ║
║  AddKeySystem · MakeNotification · Flags · SaveConfig        ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local function safeWrite(p,d) pcall(writefile,p,d) end
local function safeRead(p)    local ok,d=pcall(readfile,p); return ok and d or nil end
local function safeMkdir(p)   pcall(makefolder,p) end

-- ════════════════════════════════════════════════════════════
--  LIQUID GLASS THEME
-- ════════════════════════════════════════════════════════════
local T = {
    Win         = Color3.fromRGB( 9,  8, 17),
    TopBar      = Color3.fromRGB(14, 12, 24),
    Sidebar     = Color3.fromRGB(12, 10, 21),
    Content     = Color3.fromRGB( 7,  6, 14),

    Glass       = Color3.fromRGB(18, 15, 32),
    GlassHov    = Color3.fromRGB(24, 20, 42),
    GlassDeep   = Color3.fromRGB(12, 10, 22),
    GlassCard   = Color3.fromRGB(15, 13, 27),

    BorderWin   = Color3.fromRGB( 55, 40, 105),
    BorderElem  = Color3.fromRGB( 38, 28,  72),
    BorderHov   = Color3.fromRGB( 85, 58, 165),
    BorderFocus = Color3.fromRGB(120, 80, 255),
    BorderBtn   = Color3.fromRGB( 65, 42, 140),
    BorderBtnHv = Color3.fromRGB(110, 72, 235),
    BorderSec   = Color3.fromRGB( 30, 22,  58),
    BorderCard  = Color3.fromRGB( 42, 30,  82),

    Accent      = Color3.fromRGB(115, 72, 250),
    AccentSoft  = Color3.fromRGB(145,105, 255),
    AccentDark  = Color3.fromRGB( 50, 28, 115),
    AccentGlow  = Color3.fromRGB( 78, 40, 185),
    AccentBtn0  = Color3.fromRGB( 62, 34, 145),
    AccentBtn1  = Color3.fromRGB( 30, 16,  78),

    TabAct0     = Color3.fromRGB( 82, 50, 210),
    TabAct1     = Color3.fromRGB( 38, 20, 115),

    Text        = Color3.fromRGB(228, 222, 252),
    TextSub     = Color3.fromRGB(165, 152, 208),
    TextDim     = Color3.fromRGB(105,  92, 148),
    TextMuted   = Color3.fromRGB( 58,  48,  92),

    Success     = Color3.fromRGB( 68, 215, 135),
    Danger      = Color3.fromRGB(228,  68,  68),
    Warning     = Color3.fromRGB(238, 188,  58),

    ToggleOff   = Color3.fromRGB( 24, 18,  44),

    PremBg      = Color3.fromRGB( 52, 28, 138),
    PremBorder  = Color3.fromRGB(148,100, 255),
    PremText    = Color3.fromRGB(218, 196, 255),
    FreeBg      = Color3.fromRGB( 20, 16,  38),
    FreeBorder  = Color3.fromRGB( 42, 32,  72),
    FreeText    = Color3.fromRGB( 95,  82, 138),

    Font        = Enum.Font.GothamSemibold,
    FontLight   = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,

    R10  = UDim.new(0,10),
    R9   = UDim.new(0, 9),
    R8   = UDim.new(0, 8),
    R6   = UDim.new(0, 6),
    R5   = UDim.new(0, 5),
    RFull= UDim.new(1, 0),
}

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function tw(o,p,t,es,ed)
    TweenService:Create(o,
        TweenInfo.new(t or .16, es or Enum.EasingStyle.Quad,
                      ed or Enum.EasingDirection.Out), p):Play()
end

local function corner(p,r)
    local c=Instance.new("UICorner",p); c.CornerRadius=r or T.R8; return c
end

local function glassBorder(p, col, thick)
    local s=Instance.new("UIStroke",p)
    s.Color=col or T.BorderElem
    s.Thickness=thick or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return s
end

local function pad(p,top,bot,left,right)
    local u=Instance.new("UIPadding",p)
    u.PaddingTop=UDim.new(0,top or 0); u.PaddingBottom=UDim.new(0,bot or 0)
    u.PaddingLeft=UDim.new(0,left or 0); u.PaddingRight=UDim.new(0,right or 0)
end

local function new(cls,props,parent)
    local o=Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end; return o
end

local function vlist(p,spacing)
    return new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,spacing or 0),SortOrder=Enum.SortOrder.LayoutOrder},p)
end

local function grad(p,c0,c1,rot)
    local g=Instance.new("UIGradient",p)
    g.Color=ColorSequence.new(c0,c1); g.Rotation=rot or 90; return g
end

local function shimmerLine(parent, alpha)
    local s=new("Frame",{
        Size=UDim2.new(0.55,0,0,1),
        Position=UDim2.new(0.225,0,0,1),
        BackgroundColor3=Color3.fromRGB(200,170,255),
        BackgroundTransparency=alpha or 0.55,
        BorderSizePixel=0, ZIndex=10,
    },parent)
    corner(s,T.RFull); return s
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
local _nh

local function ensureHolder(gui)
    if _nh and _nh.Parent then return end
    _nh=new("Frame",{Size=UDim2.new(0,252,1,-12),
        Position=UDim2.new(1,-262,0,6),
        BackgroundTransparency=1,ZIndex=100},gui)
    local ll=vlist(_nh,6)
    ll.VerticalAlignment=Enum.VerticalAlignment.Bottom
end

function Nova:MakeNotification(opts)
    opts=opts or {}
    local title=opts.Name or "Notification"
    local body=opts.Content or ""
    local img=opts.Image or ""
    local t=opts.Time or 4
    ensureHolder(self._gui or LocalPlayer.PlayerGui)

    local card=new("Frame",{
        Size=UDim2.new(1,0,0,62),
        BackgroundColor3=Color3.fromRGB(13,11,26),
        BorderSizePixel=0,ZIndex=101},_nh)
    corner(card,T.R8)
    local cardStroke=Instance.new("UIStroke",card)
    cardStroke.Color=T.BorderCard
    cardStroke.Thickness=1.2
    cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local xOff=img~="" and 50 or 12
    if img~="" then
        local ic=new("Frame",{Size=UDim2.new(0,30,0,30),
            Position=UDim2.new(0,10,0.5,-15),
            BackgroundColor3=T.AccentDark,BorderSizePixel=0,
            ZIndex=102,ClipsDescendants=true},card)
        corner(ic,T.RFull)
        local icS=Instance.new("UIStroke",ic)
        icS.Color=T.BorderBtn; icS.Thickness=1
        icS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        new("ImageLabel",{Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,Image=img,ZIndex=103},ic)
    end
    new("TextLabel",{Size=UDim2.new(1,-(xOff+8),0,18),
        Position=UDim2.new(0,xOff,0,8),BackgroundTransparency=1,
        Text=title,TextColor3=T.Text,TextSize=12,Font=T.FontBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},card)
    new("TextLabel",{Size=UDim2.new(1,-(xOff+8),0,26),
        Position=UDim2.new(0,xOff,0,27),BackgroundTransparency=1,
        Text=body,TextColor3=T.TextSub,TextSize=10,Font=T.FontLight,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=102},card)
    local progBg=new("Frame",{Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=Color3.fromRGB(28,22,52),BorderSizePixel=0,ZIndex=102},card)
    local prog=new("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=103},progBg)
    card.Position=UDim2.new(1,12,0,0)
    tw(card,{Position=UDim2.new(0,0,0,0)},.3,Enum.EasingStyle.Back)
    tw(prog,{Size=UDim2.new(0,0,1,0)},t,Enum.EasingStyle.Linear)
    task.delay(t,function()
        tw(card,{Position=UDim2.new(1,12,0,0)},.22)
        task.wait(.28); card:Destroy()
    end)
end

-- ════════════════════════════════════════════════════════════
--  MAKE WINDOW
-- ════════════════════════════════════════════════════════════
function Nova:MakeWindow(opts)
    opts=opts or {}
    local title       = opts.Name          or "Nova"
    local hidePremium = opts.HidePremium
    local saveConfig  = opts.SaveConfig    or false
    local cfgFolder   = opts.ConfigFolder  or "NovaConfig"
    local winIcon     = opts.Icon          or ""
    local closeCb     = opts.CloseCallback or nil
    local toggleKey   = opts.Key           or Enum.KeyCode.RightShift
    local TOP_H       = 52
    local TAB_W       = 154
    local CARD_H      = 85

    if saveConfig then safeMkdir(cfgFolder) end

    local gui=new("ScreenGui",{Name="NovaUI",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling},LocalPlayer.PlayerGui)
    self._gui=gui
    ensureHolder(gui)

    -- ── SHADOW: disabled — rendered outside window border ──
    local shadow = new("Frame",{
        Size=UDim2.new(0,0,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Visible=false},gui)  -- invisible placeholder so shadow references still work

    local win=new("Frame",{
        Size=UDim2.new(0.82,0,0.80,0),
        Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=T.Win,BorderSizePixel=0,
        ClipsDescendants=true},gui)
    corner(win,T.R10)
    -- no outer border stroke

    -- ── TOP BAR ──────────────────────────────────
    local topbar=new("Frame",{Size=UDim2.new(1,0,0,TOP_H),
        BackgroundColor3=T.TopBar,BorderSizePixel=0,ZIndex=2},win)
    corner(topbar,T.R10)
    shimmerLine(topbar,0.68)

    local acLine=new("Frame",{Size=UDim2.new(0,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=3},topbar)
    tw(acLine,{Size=UDim2.new(1,0,0,1)},.75,Enum.EasingStyle.Quad)

    if winIcon~="" then
        new("ImageLabel",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,12,0.5,-13),
            BackgroundTransparency=1,Image=winIcon,ZIndex=3},topbar)
    else
        local dot=new("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,14,0.5,-4),
            BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=4},topbar)
        corner(dot,T.RFull)
        glassBorder(dot,T.AccentSoft,1)
        local ring=new("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,-8),
            BackgroundColor3=T.AccentGlow,BackgroundTransparency=.7,
            BorderSizePixel=0,ZIndex=3},topbar)
        corner(ring,T.RFull)
    end

    -- Title left-aligned
    new("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,30,0,0),
        BackgroundTransparency=1,Text=title,
        TextColor3=T.Text,TextSize=14,Font=T.FontBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},topbar)

    -- NovaLibV2 perfectly centered in topbar
    new("TextLabel",{
        Size=UDim2.new(0,120,0,20),
        Position=UDim2.new(0.5,-60,0.5,-10),
        BackgroundTransparency=1,
        Text="NovaLibV2",
        TextColor3=Color3.fromRGB(120,100,180),
        TextSize=10,Font=T.FontBold,
        TextXAlignment=Enum.TextXAlignment.Center,
        ZIndex=4},topbar)
    -- ── TOPBAR CONTROL BUTTONS ────────────────────
    local function ctrlBtn(text,xOff,yOff,hCol,cb)
        local b=new("TextButton",{
            Size=UDim2.new(0,28,0,28),
            Position=UDim2.new(1,xOff,0.5,yOff or -14),
            BackgroundColor3=T.Glass,Text=text,
            TextColor3=T.TextDim,TextSize=10,Font=T.FontBold,
            BorderSizePixel=0,ZIndex=4},topbar)
        corner(b,T.R6)
        local bs=glassBorder(b,T.BorderElem,1)
        shimmerLine(b,0.72)
        b.MouseEnter:Connect(function()
            tw(b,{BackgroundColor3=hCol or T.GlassHov})
            tw(bs,{Color=T.BorderHov})
        end)
        b.MouseLeave:Connect(function()
            tw(b,{BackgroundColor3=T.Glass})
            tw(bs,{Color=T.BorderElem})
        end)
        b.MouseButton1Click:Connect(cb)
        return b,bs
    end

    local minimized=false
    local fullSz=UDim2.new(0.82,0,0.80,0)

    -- ── FLOATING RESTORE BUBBLE ──────────────────
    local bubble=new("Frame",{Size=UDim2.new(0,42,0,42),
        Position=UDim2.new(1,-52,0,8),
        BackgroundColor3=Color3.fromRGB(16,12,34),
        BorderSizePixel=0,ZIndex=200,Visible=false,
        ClipsDescendants=true},gui)
    corner(bubble,UDim.new(0,12))
    grad(bubble,Color3.fromRGB(68,40,182),Color3.fromRGB(16,10,38),135)
    local bubStroke=glassBorder(bubble,T.Accent,1.4)
    shimmerLine(bubble,0.55)

    for _,yOff in ipairs({-6,0,6}) do
        local bar=new("Frame",{Size=UDim2.new(0,16,0,2),
            Position=UDim2.new(0.5,-8,0.5,yOff),
            BackgroundColor3=Color3.new(1,1,1),
            BorderSizePixel=0,ZIndex=202},bubble)
        corner(bar,T.RFull)
    end

    local bubBtn=new("TextButton",{Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,Text="",ZIndex=203},bubble)
    bubBtn.MouseEnter:Connect(function()
        tw(bubble,{BackgroundColor3=Color3.fromRGB(26,18,56)})
        tw(bubStroke,{Color=T.AccentSoft,Thickness=2})
    end)
    bubBtn.MouseLeave:Connect(function()
        tw(bubble,{BackgroundColor3=Color3.fromRGB(16,12,34)})
        tw(bubStroke,{Color=T.Accent,Thickness=1.4})
    end)
    bubBtn.MouseButton1Click:Connect(function()
        minimized=false; bubble.Visible=false
        win.Visible=true; shadow.Visible=true
        tw(win,{Size=fullSz},.3,Enum.EasingStyle.Back)
        tw(shadow,{Size=UDim2.new(fullSz.X.Scale,fullSz.X.Offset+80,
                                  fullSz.Y.Scale,fullSz.Y.Offset+80)},.3,Enum.EasingStyle.Back)
    end)

    local function pulseBubble()
        if not bubble.Visible then return end
        tw(bubStroke,{Color=T.AccentSoft,Thickness=2},.9)
        task.delay(.95,function()
            if not bubble.Visible then return end
            tw(bubStroke,{Color=T.AccentGlow,Thickness=1.2},.9)
            task.delay(.95,pulseBubble)
        end)
    end

    local minBtn,minBs=ctrlBtn("─",-52,-8,T.GlassHov,function()
        minimized=true; fullSz=win.Size
        tw(win,{Size=UDim2.new(0.82,0,0,0)},.2,Enum.EasingStyle.Quad)
        tw(shadow,{Size=UDim2.new(0.82,80,0,80)},.2,Enum.EasingStyle.Quad)
        task.delay(.25,function()
            win.Visible=false; shadow.Visible=false; bubble.Visible=true
            bubble.Size=UDim2.new(0,0,0,0)
            bubble.Position=UDim2.new(1,-32,0,30)
            tw(bubble,{Size=UDim2.new(0,42,0,42),Position=UDim2.new(1,-52,0,8)},
                .34,Enum.EasingStyle.Back)
            pulseBubble()
        end)
    end)
    minBs.Color=T.AccentSoft; minBs.Thickness=1.8
    minBtn.MouseEnter:Connect(function()
        tw(minBs,{Color=T.BorderFocus,Thickness=2.2})
    end)
    minBtn.MouseLeave:Connect(function()
        tw(minBs,{Color=T.AccentSoft,Thickness=1.8})
    end)

    -- Drag
    local _dg,_ds,_ws=false,nil,nil
    topbar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            _dg=true;_ds=i.Position;_ws=win.Position end
    end)
    topbar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then _dg=false end
    end)
    table.insert(self._conns,UserInputService.InputChanged:Connect(function(i)
        if _dg and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-_ds
            local np=UDim2.new(_ws.X.Scale,_ws.X.Offset+d.X,_ws.Y.Scale,_ws.Y.Offset+d.Y)
            win.Position=np
            -- shadow keeps its +8px Y depth offset relative to win
            shadow.Position=UDim2.new(np.X.Scale,np.X.Offset,np.Y.Scale,np.Y.Offset+8)
        end
    end))
    table.insert(self._conns,UserInputService.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==toggleKey then
            local v=not win.Visible
            win.Visible=v; shadow.Visible=v
        end
    end))

    -- ── PREMIUM CHECK ────────────────────────────
    -- isPremium = true if the player's UserId is in PremiumIds table,
    -- OR if opts.ForcePremium = true (for testing / all-premium scripts).
    -- To make a specific player premium, add their UserId to PremiumIds:
    --   Nova:MakeWindow({ PremiumIds = { 123456789 } })
    local PREMIUM_IDS = opts.PremiumIds or {}
    local isPremium   = opts.ForcePremium == true
    if not isPremium then
        for _,id in ipairs(PREMIUM_IDS) do
            if LocalPlayer.UserId == id then isPremium=true; break end
        end
    end

    -- ── SIDEBAR ──────────────────────────────────
    local tabBar=new("ScrollingFrame",{
        Size=UDim2.new(0,TAB_W,1,-(TOP_H+CARD_H)),
        Position=UDim2.new(0,0,0,TOP_H),
        BackgroundColor3=T.Sidebar,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ElasticBehavior=Enum.ElasticBehavior.Never},win)
    vlist(tabBar,2)
    pad(tabBar,10,4,8,8)

    -- ── FIX: divider shortened by 10px so it doesn't overwrite the bottom-left corner ──
    local sdiv=new("Frame",{
        Size=UDim2.new(0,1,1,-(TOP_H+10)),
        Position=UDim2.new(0,TAB_W,0,TOP_H),
        BackgroundColor3=Color3.fromRGB(40,30,76),BorderSizePixel=0},win)
    grad(sdiv,Color3.fromRGB(60,42,110),Color3.fromRGB(28,20,55),90)

    local contentArea=new("Frame",{
        Size=UDim2.new(1,-(TAB_W+1),1,-(TOP_H+10)),
        Position=UDim2.new(0,TAB_W+1,0,TOP_H),
        BackgroundColor3=T.Content,
        ClipsDescendants=true},win)
    corner(contentArea,T.R10)

    -- ── PLAYER CARD ──────────────────────────────
    new("Frame",{Size=UDim2.new(0,TAB_W,0,1),Position=UDim2.new(0,0,1,-CARD_H),
        BackgroundColor3=Color3.fromRGB(40,30,76),BorderSizePixel=0},win)

    local pcCard=new("Frame",{
        Size=UDim2.new(0,TAB_W,0,CARD_H-1),
        Position=UDim2.new(0,0,1,-(CARD_H-1)),
        BackgroundColor3=T.Sidebar,BorderSizePixel=0,
        ClipsDescendants=true},win)
    -- round bottom-left corner of player card
    corner(pcCard,T.R10)
    pad(pcCard,9,9,10,8)
    vlist(pcCard,6)

    local pcRow=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1},pcCard)

    -- ── Avatar — definitive circle crop ─────────────────────────────────────
    -- Strategy: one Frame with ClipsDescendants=true + UICorner(1,0) + opaque bg
    -- matching sidebar. ImageLabel inside also has the same opaque bg so there
    -- is zero white/square flash at any frame. The UIStroke ring is a ZIndex-6
    -- sibling on pcRow so it is never clipped by the parent frame.
    local AV = 38  -- diameter px

    -- BLACK MASK APPROACH:
    -- 1. avOuter: black circle frame, ClipsDescendants=true — hard clips image to circle
    -- 2. avImg: image inside avOuter fills it completely
    -- 3. avRing: separate sibling with UIStroke for the colored border ring
    -- The black background of avOuter = any square corner that leaks is black, matching
    -- the dark sidebar, so it's invisible. ClipsDescendants + UICorner does the circle crop.

    local avOuter = new("Frame",{
        Size             = UDim2.new(0,AV,0,AV),
        Position         = UDim2.new(0,4,0.5,-AV/2),
        BackgroundColor3 = Color3.fromRGB(0,0,0),   -- black fallback = invisible on dark bg
        BackgroundTransparency = 0,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 3,
    }, pcRow)
    local _avOC = Instance.new("UICorner", avOuter)
    _avOC.CornerRadius = UDim.new(1,0)

    local avImg = new("ImageLabel",{
        Size             = UDim2.new(1,0,1,0)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = avImg
,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0,
        Image            = "rbxthumb://type=AvatarHeadShot&id="
                           ..tostring(LocalPlayer.UserId).."&w=48&h=48",
        ScaleType        = Enum.ScaleType.Crop,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, avOuter)

    -- Colored ring border — sibling on pcRow so UIStroke is NEVER clipped
    local avRing = new("Frame",{
        Size             = UDim2.new(0,AV,0,AV),
        Position         = UDim2.new(0,4,0.5,-AV/2),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, pcRow)
    local _avRC = Instance.new("UICorner", avRing)
    _avRC.CornerRadius = UDim.new(1,0)
    local _avRS = Instance.new("UIStroke", avRing)
    _avRS.Color           = isPremium and T.PremBorder or T.AccentSoft
    _avRS.Thickness       = isPremium and 2.5 or 2
    _avRS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    if isPremium then
        new("TextLabel",{
            Size=UDim2.new(0,14,0,14),
            Position=UDim2.new(0,AV-8,0,-4),
            BackgroundTransparency=1,Text="👑",TextSize=10,
            Font=T.FontBold,ZIndex=7},pcRow)
    end

    -- Names shifted right of avatar with comfortable gap
    local pcNames=new("Frame",{
        Size     = UDim2.new(1,-(AV+16),1,0),
        Position = UDim2.new(0,AV+12,0,0),
        BackgroundTransparency=1},pcRow)
    vlist(pcNames,3)
    pad(pcNames,5,0,0,0)

    new("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
        Text=LocalPlayer.DisplayName,
        TextColor3=isPremium and T.PremText or T.Text,
        TextSize=13,Font=T.FontBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd},pcNames)
    new("TextLabel",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,
        Text="@"..LocalPlayer.Name,
        TextColor3=T.TextMuted,TextSize=10,Font=T.FontLight,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd},pcNames)

    if hidePremium ~= true then
        local badgeBg=new("Frame",{
            Size=UDim2.new(0,isPremium and 82 or 46,0,18),
            BackgroundColor3=isPremium and T.PremBg or T.FreeBg,
            BorderSizePixel=0},pcCard)
        corner(badgeBg,T.RFull)
        glassBorder(badgeBg,isPremium and T.PremBorder or T.FreeBorder,1)
        shimmerLine(badgeBg,isPremium and 0.5 or 0.8)

        if isPremium then
            grad(badgeBg,Color3.fromRGB(88,46,218),Color3.fromRGB(52,26,148),90)
        end

        new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=isPremium and "★  Premium" or "Free",
            TextColor3=isPremium and T.PremText or T.FreeText,
            TextSize=9,Font=T.FontBold,
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=2},badgeBg)
    end

    win.Size=UDim2.new(0.82,0,0,0)
    shadow.Size=UDim2.new(0.82,80,0,80)
    tw(win,{Size=UDim2.new(0.82,0,0.80,0)},.4,Enum.EasingStyle.Back)
    tw(shadow,{Size=UDim2.new(0.82,80,0.80,80)},.4,Enum.EasingStyle.Back)

    -- ════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════════════════
    local Window={_tabs={},_btns={},_active=nil,
                  _cfgFolder=cfgFolder,_saveConfig=saveConfig}

    function Window:_select(name)
        for n,f in pairs(self._tabs) do f.Visible=(n==name) end
        for n,b in pairs(self._btns) do
            local on=(n==name)
            local gf=b:FindFirstChild("_grad")
            local bar=b:FindFirstChild("_bar")
            local lbl=b:FindFirstChildOfClass("TextLabel")
            local bs=b:FindFirstChildOfClass("UIStroke")
            if on then
                tw(b,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(26,16,60)})
                if gf  then gf.Visible=true end
                if bar then tw(bar,{BackgroundTransparency=0}) end
                if lbl then lbl.TextColor3=T.Text end
                if bs  then tw(bs,{Color=T.BorderFocus}) end
            else
                tw(b,{BackgroundTransparency=1})
                if gf  then gf.Visible=false end
                if bar then tw(bar,{BackgroundTransparency=1}) end
                if lbl then lbl.TextColor3=T.TextDim end
                if bs  then tw(bs,{Color=T.BorderElem}) end
            end
        end
        self._active=name
    end

    function Window:_saveAll()
        if not self._saveConfig then return end
        local d={}
        for f,obj in pairs(Nova.Flags) do if obj._save then d[f]=obj.Value end end
        safeWrite(self._cfgFolder.."/config.json",HttpService:JSONEncode(d))
    end

    function Window:_loadAll()
        if not self._saveConfig then return end
        local raw=safeRead(self._cfgFolder.."/config.json")
        if not raw then return end
        local ok,d=pcall(HttpService.JSONDecode,HttpService,raw)
        if not ok or type(d)~="table" then return end
        for f,v in pairs(d) do
            if Nova.Flags[f] and Nova.Flags[f].Set then Nova.Flags[f]:Set(v) end
        end
    end

    -- ────────────────────────────────────────────
    --  MAKE TAB
    -- ────────────────────────────────────────────
    function Window:MakeTab(opts)
        opts=opts or {}
        local name=opts.Name or "Tab"
        local icon=opts.Icon or ""
        local premOnly=opts.PremiumOnly or false

        local btn=new("TextButton",{Size=UDim2.new(1,0,0,36),
            BackgroundTransparency=1,
            BackgroundColor3=Color3.fromRGB(26,16,56),
            Text="",BorderSizePixel=0},tabBar)
        corner(btn,T.R6)
        glassBorder(btn,T.BorderElem,1)
        shimmerLine(btn,0.78)

        local gf=new("Frame",{Name="_grad",Size=UDim2.new(1,0,1,0),
            BackgroundColor3=T.TabAct0,BorderSizePixel=0,Visible=false,ZIndex=0},btn)
        corner(gf,T.R6)
        grad(gf,T.TabAct0,T.TabAct1,90)
        shimmerLine(gf,0.55)

        local bar=new("Frame",{Name="_bar",Size=UDim2.new(0,3,0.55,0),
            Position=UDim2.new(0,-1,0.225,0),
            BackgroundColor3=T.AccentSoft,BorderSizePixel=0,
            BackgroundTransparency=1,ZIndex=3},btn)
        corner(bar,T.RFull)

        local hasImg=icon~="" and icon:find("rbxassetid")
        if hasImg then
            new("ImageLabel",{Size=UDim2.new(0,16,0,16),
                Position=UDim2.new(0,10,0.5,-8),
                BackgroundTransparency=1,Image=icon,ZIndex=2},btn)
        end
        local lbl=new("TextLabel",{
            Size=hasImg and UDim2.new(1,-34,1,0) or UDim2.new(1,-14,1,0),
            Position=hasImg and UDim2.new(0,32,0,0) or UDim2.new(0,12,0,0),
            BackgroundTransparency=1,
            Text=(not hasImg and icon~="" and icon.."  " or "")..name,
            TextColor3=T.TextDim,TextSize=13,Font=T.Font,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},btn)

        if premOnly and not isPremium then
            local lo=new("TextButton",{Size=UDim2.new(1,0,1,0),
                BackgroundColor3=T.Sidebar,BackgroundTransparency=.35,
                Text="🔒",TextColor3=T.TextMuted,TextSize=11,
                Font=T.FontBold,BorderSizePixel=0,ZIndex=5},btn)
            corner(lo,T.R6)
            lo.MouseButton1Click:Connect(function()
                Nova:MakeNotification({Name="Premium Required",
                    Content="This tab requires Premium access.",Time=3})
            end)
        end

        btn.MouseEnter:Connect(function()
            if self._active~=name then
                tw(btn,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(22,14,46)})
                local bs=btn:FindFirstChildOfClass("UIStroke")
                if bs then tw(bs,{Color=T.BorderHov}) end
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._active~=name then
                tw(btn,{BackgroundTransparency=1})
                local bs=btn:FindFirstChildOfClass("UIStroke")
                if bs then tw(bs,{Color=T.BorderElem}) end
            end
        end)

        local scroll=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ClipsDescendants=true,
            Visible=false},contentArea)
        vlist(scroll,5)
        pad(scroll,8,14,8,8)  -- extra bottom pad keeps content above rounded corner

        self._tabs[name]=scroll; self._btns[name]=btn
        btn.MouseButton1Click:Connect(function()
            if premOnly and not isPremium then return end
            self:_select(name)
        end)
        if not self._active then self:_select(name) end

        -- ════════════════════════════════════════
        --  TAB OBJECT
        -- ════════════════════════════════════════
        local Tab={_scroll=scroll,_override=nil}

        local function target() return Tab._override or scroll end

        local function glassElem(h,bg)
            local f=new("Frame",{Size=UDim2.new(1,0,0,h or 40),
                BackgroundColor3=bg or T.Glass,BorderSizePixel=0},target())
            corner(f,T.R8)
            glassBorder(f,T.BorderElem,1)
            shimmerLine(f,0.74)
            return f
        end

        local function lblLeft(parent,text,w)
            return new("TextLabel",{Size=UDim2.new(w or .56,0,1,0),
                Position=UDim2.new(0,11,0,0),BackgroundTransparency=1,
                Text=text,TextColor3=T.Text,TextSize=12,Font=T.Font,
                TextXAlignment=Enum.TextXAlignment.Left},parent)
        end

        -- ── SECTION ──────────────────────────────
        function Tab:AddSection(opts)
            local name=type(opts)=="string" and opts or (opts and opts.Name or "Section")

            local hdr=new("Frame",{Size=UDim2.new(1,0,0,24),
                BackgroundTransparency=1,BorderSizePixel=0},target())

            local tick=new("Frame",{Size=UDim2.new(0,2,0.6,0),
                Position=UDim2.new(0,0,0.2,0),
                BackgroundColor3=T.AccentGlow,BorderSizePixel=0},hdr)
            corner(tick,T.RFull)
            grad(tick,T.AccentSoft,T.AccentGlow,90)

            new("TextLabel",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1,Text=name:upper(),
                TextColor3=Color3.fromRGB(92,78,140),
                TextSize=9,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Left},hdr)

            local container=new("Frame",{Size=UDim2.new(1,0,0,0),
                BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},target())
            vlist(container,4)

            local Section={}
            setmetatable(Section,{__index=function(_,k)
                return function(s2,...)
                    if Tab[k] then
                        Tab._override=container
                        local r=Tab[k](Tab,...); Tab._override=nil; return r
                    end
                end
            end})
            return Section
        end

        -- ── LABEL ────────────────────────────────
        function Tab:AddLabel(text)
            local f=new("Frame",{Size=UDim2.new(1,0,0,30),
                BackgroundColor3=T.Glass,BorderSizePixel=0},target())
            corner(f,T.R8)
            glassBorder(f,T.BorderSec,1)
            shimmerLine(f,0.78)
            local lbl=new("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,11,0,0),
                BackgroundTransparency=1,Text=text,TextColor3=T.TextSub,
                TextSize=11,Font=T.FontLight,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},f)
            local obj={}; function obj:Set(t) lbl.Text=t end; return obj
        end

        -- ── PARAGRAPH ────────────────────────────
        function Tab:AddParagraph(title,body)
            local t,b
            if type(title)=="table" then t=title.Name or ""; b=title.Content or ""
            else t=title or ""; b=body or "" end

            local f=new("Frame",{Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=T.Glass,BorderSizePixel=0},target())
            corner(f,T.R8)
            glassBorder(f,T.BorderSec,1)
            shimmerLine(f,0.75)
            pad(f,9,9,12,12)
            vlist(f,4)

            local tl=new("TextLabel",{Size=UDim2.new(1,0,0,16),
                BackgroundTransparency=1,Text=t,TextColor3=T.Text,
                TextSize=12,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left},f)
            local bl=new("TextLabel",{Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,
                Text=b,TextColor3=T.TextSub,TextSize=11,Font=T.FontLight,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},f)

            local obj={}
            function obj:Set(nt,nb) if nt then tl.Text=nt end; if nb then bl.Text=nb end end
            return obj
        end

        -- ── BUTTON ───────────────────────────────
        function Tab:AddButton(opts)
            local name=type(opts)=="string" and opts or (opts and opts.Name or "Button")
            local cb=(type(opts)=="table" and opts.Callback) or function()end

            local f=new("Frame",{Size=UDim2.new(1,0,0,40),
                BackgroundColor3=T.AccentBtn0,BorderSizePixel=0},target())
            corner(f,T.R8)
            grad(f,T.AccentBtn0,T.AccentBtn1,90)

            local bs=glassBorder(f,T.BorderBtn,1.2)
            local sh=shimmerLine(f,0.48)

            local b=new("TextButton",{Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,Text=name,
                TextColor3=Color3.fromRGB(218,204,255),
                TextSize=12,Font=T.Font,ZIndex=3},f)

            b.MouseEnter:Connect(function()
                tw(f,{BackgroundColor3=Color3.fromRGB(72,42,168)})
                tw(bs,{Color=T.BorderBtnHv,Thickness=1.4})
                tw(sh,{BackgroundTransparency=0.3})
            end)
            b.MouseLeave:Connect(function()
                tw(f,{BackgroundColor3=T.AccentBtn0})
                tw(bs,{Color=T.BorderBtn,Thickness=1.2})
                tw(sh,{BackgroundTransparency=0.48})
            end)
            b.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=T.Accent},.06)
                tw(bs,{Color=T.AccentSoft},.06)
                tw(sh,{BackgroundTransparency=0.2},.06)
                task.wait(.14)
                tw(f,{BackgroundColor3=T.AccentBtn0})
                tw(bs,{Color=T.BorderBtn})
                tw(sh,{BackgroundTransparency=0.48})
                pcall(cb)
            end)
        end

        -- ── TOGGLE ───────────────────────────────
        function Tab:AddToggle(opts)
            opts=opts or {}
            local name=opts.Name or "Toggle"
            local val=opts.Default or false
            local flag=opts.Flag or nil
            local save=opts.Save or false
            local cb=opts.Callback or function()end

            local f=glassElem(40)
            local fbs=f:FindFirstChildOfClass("UIStroke")
            lblLeft(f,name)

            local track=new("Frame",{Size=UDim2.new(0,44,0,24),
                Position=UDim2.new(1,-54,0.5,-12),
                BackgroundColor3=val and T.Accent or T.ToggleOff,
                BorderSizePixel=0,
                ClipsDescendants=true},f)
            corner(track,T.RFull)
            local tbs=glassBorder(track,val and T.BorderFocus or T.BorderElem,1.2)
            shimmerLine(track,val and 0.45 or 0.8)

            local knob=new("Frame",{Size=UDim2.new(0,18,0,18),
                Position=val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track)
            corner(knob,T.RFull)
            glassBorder(knob,Color3.fromRGB(200,180,255),1)

            new("TextButton",{Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,Text=""},f
            ).MouseButton1Click:Connect(function()
                val=not val
                tw(track,{BackgroundColor3=val and T.Accent or T.ToggleOff})
                tw(tbs,{Color=val and T.BorderFocus or T.BorderElem})
                tw(knob,{Position=val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)})
                if fbs then tw(fbs,{Color=val and T.BorderHov or T.BorderElem}) end
                if flag then Nova.Flags[flag].Value=val end
                pcall(cb,val); Window:_saveAll()
            end)

            local obj={Value=val,_save=save}
            function obj:Set(v)
                val=v
                tw(track,{BackgroundColor3=v and T.Accent or T.ToggleOff})
                tw(tbs,{Color=v and T.BorderFocus or T.BorderElem})
                tw(knob,{Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)})
                if fbs then tw(fbs,{Color=v and T.BorderHov or T.BorderElem}) end
                self.Value=v
                if flag then Nova.Flags[flag].Value=v end
                pcall(cb,v)
            end
            if flag then Nova.Flags[flag]=obj end
            return obj
        end

        -- ── SLIDER ───────────────────────────────
        function Tab:AddSlider(opts)
            opts=opts or {}
            local name=opts.Name or "Slider"
            local min=opts.Min or 0; local max=opts.Max or 100
            local inc=opts.Increment or 1
            local val=math.clamp(opts.Default or min,min,max)
            local vname=opts.ValueName or ""
            local flag=opts.Flag or nil; local save=opts.Save or false
            local col=opts.Color or T.Accent
            local cb=opts.Callback or function()end

            local f=glassElem(54)
            lblLeft(f,name,.58)

            local vlbl=new("TextLabel",{Size=UDim2.new(0,72,0,22),
                Position=UDim2.new(1,-82,0,4),BackgroundTransparency=1,
                Text=tostring(val)..(vname~="" and " "..vname or ""),
                TextColor3=col,TextSize=11,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Right},f)

            local track=new("Frame",{Size=UDim2.new(1,-22,0,5),
                Position=UDim2.new(0,11,0,38),
                BackgroundColor3=T.ToggleOff,BorderSizePixel=0,
                ClipsDescendants=true},f)
            corner(track,T.RFull)
            glassBorder(track,T.BorderElem,1)

            local fill=new("Frame",{Size=UDim2.new((val-min)/(max-min),0,1,0),
                BackgroundColor3=col,BorderSizePixel=0},track)
            corner(fill,T.RFull)
            shimmerLine(fill,0.5)

            local handle=new("Frame",{Size=UDim2.new(0,14,0,14),
                Position=UDim2.new((val-min)/(max-min),-7,0.5,-7),
                BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track)
            corner(handle,T.RFull)
            glassBorder(handle,Color3.fromRGB(185,155,255),1.2)

            local dragging=false
            local function upd(x)
                local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                val=min+math.floor(rel*(max-min)/inc+.5)*inc
                val=math.clamp(val,min,max); rel=(val-min)/(max-min)
                vlbl.Text=tostring(val)..(vname~="" and " "..vname or "")
                tw(fill,{Size=UDim2.new(rel,0,1,0)},.05)
                tw(handle,{Position=UDim2.new(rel,-7,0.5,-7)},.05)
                if flag then Nova.Flags[flag].Value=val end
                pcall(cb,val); Window:_saveAll()
            end

            local hb=new("TextButton",{Size=UDim2.new(1,0,0,26),
                Position=UDim2.new(0,0,0.5,-13),BackgroundTransparency=1,Text="",ZIndex=2},track)
            hb.MouseButton1Down:Connect(function() dragging=true; upd(Mouse.X) end)
            table.insert(Nova._conns,UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end))
            table.insert(Nova._conns,UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                    upd(Mouse.X) end
            end))

            local obj={Value=val,_save=save}
            function obj:Set(v)
                val=math.clamp(v,min,max); local rel=(val-min)/(max-min)
                vlbl.Text=tostring(val)..(vname~="" and " "..vname or "")
                tw(fill,{Size=UDim2.new(rel,0,1,0)})
                tw(handle,{Position=UDim2.new(rel,-7,0.5,-7)})
                self.Value=val
                if flag then Nova.Flags[flag].Value=val end
                pcall(cb,val)
            end
            if flag then Nova.Flags[flag]=obj end
            return obj
        end

        -- ── DROPDOWN ─────────────────────────────
        function Tab:AddDropdown(opts)
            opts=opts or {}
            local name=opts.Name or "Dropdown"
            local options=opts.Options or {}
            local sel=opts.Default or (options[1] or "")
            local flag=opts.Flag or nil; local save=opts.Save or false
            local cb=opts.Callback or function()end
            local isOpen=false

            local f=glassElem(40)
            f.ClipsDescendants=false; f.ZIndex=2
            lblLeft(f,name,.40)

            local dbtn=new("TextButton",{Size=UDim2.new(0,158,0,28),
                Position=UDim2.new(1,-168,0.5,-14),
                BackgroundColor3=T.GlassDeep,
                Text=sel.."  ▾",TextColor3=T.TextSub,
                TextSize=11,Font=T.Font,BorderSizePixel=0,ZIndex=3},f)
            corner(dbtn,T.R6)
            local dbs=glassBorder(dbtn,T.BorderElem,1)
            shimmerLine(dbtn,0.78)

            dbtn.MouseEnter:Connect(function()
                tw(dbs,{Color=T.BorderHov})
                tw(dbtn,{BackgroundColor3=T.Glass})
            end)
            dbtn.MouseLeave:Connect(function()
                if not isOpen then
                    tw(dbs,{Color=T.BorderElem})
                    tw(dbtn,{BackgroundColor3=T.GlassDeep})
                end
            end)

            local list=new("Frame",{Size=UDim2.new(0,158,0,0),
                BackgroundColor3=Color3.fromRGB(14,11,26),
                BorderSizePixel=0,ClipsDescendants=true,
                ZIndex=30,Visible=false},contentArea)
            corner(list,T.R8)
            glassBorder(list,T.BorderHov,1.2)
            shimmerLine(list,0.7)
            vlist(list)
            pad(list,3,3,0,0)

            local listH=math.min(#options,7)*28+6

            local function repos()
                local ap=dbtn.AbsolutePosition; local ca=contentArea.AbsolutePosition
                list.Position=UDim2.new(0,ap.X-ca.X,0,ap.Y-ca.Y+dbtn.AbsoluteSize.Y+4)
            end

            local function closeList()
                isOpen=false
                tw(list,{Size=UDim2.new(0,158,0,0)},.14)
                task.delay(.16,function() list.Visible=false end)
                tw(dbs,{Color=T.BorderElem})
                tw(dbtn,{BackgroundColor3=T.GlassDeep})
            end

            local function buildItems()
                for _,c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _,opt in ipairs(options) do
                    local it=new("TextButton",{Size=UDim2.new(1,0,0,28),
                        BackgroundTransparency=1,BackgroundColor3=T.Accent,
                        Text="  "..opt,
                        TextColor3=opt==sel and T.Text or T.TextSub,
                        TextSize=11,Font=T.Font,
                        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31},list)
                    it.MouseEnter:Connect(function()
                        tw(it,{BackgroundTransparency=0}); it.TextColor3=T.Text
                    end)
                    it.MouseLeave:Connect(function()
                        tw(it,{BackgroundTransparency=1})
                        if opt~=sel then it.TextColor3=T.TextSub end
                    end)
                    it.MouseButton1Click:Connect(function()
                        sel=opt; dbtn.Text=opt.."  ▾"; closeList()
                        if flag then Nova.Flags[flag].Value=opt end
                        pcall(cb,opt); Window:_saveAll()
                    end)
                end
            end
            buildItems()

            dbtn.MouseButton1Click:Connect(function()
                isOpen=not isOpen
                if isOpen then
                    repos(); list.Visible=true
                    tw(list,{Size=UDim2.new(0,158,0,listH)},.2,Enum.EasingStyle.Back)
                    tw(dbs,{Color=T.BorderFocus})
                    tw(dbtn,{BackgroundColor3=T.Glass})
                else closeList() end
            end)

            local obj={Value=sel,_save=save}
            function obj:Set(v) sel=v; dbtn.Text=v.."  ▾"; self.Value=v end
            function obj:Refresh(tbl,clear)
                if clear then options={} end
                for _,v in ipairs(tbl) do table.insert(options,v) end
                listH=math.min(#options,7)*28+6; buildItems()
            end
            if flag then Nova.Flags[flag]=obj end
            return obj
        end

        -- ── COLORPICKER ──────────────────────────
        function Tab:AddColorpicker(opts)
            opts=opts or {}
            local name=opts.Name or "Color"
            local col=opts.Default or Color3.fromRGB(255,80,80)
            local flag=opts.Flag or nil; local save=opts.Save or false
            local cb=opts.Callback or function()end
            local isOpen=false

            local f=glassElem(40)
            lblLeft(f,name,.65)

            local swatch=new("Frame",{Size=UDim2.new(0,28,0,28),
                Position=UDim2.new(1,-46,0.5,-14),
                BackgroundColor3=col,BorderSizePixel=0},f)
            corner(swatch,T.R5)
            glassBorder(swatch,T.BorderBtn,1.4)
            shimmerLine(swatch,0.55)

            local chev=new("TextLabel",{Size=UDim2.new(0,14,1,0),
                Position=UDim2.new(1,-16,0,0),BackgroundTransparency=1,
                Text="▾",TextColor3=T.TextMuted,TextSize=10,Font=T.FontBold},f)

            local panel=new("Frame",{Size=UDim2.new(1,0,0,0),
                BackgroundColor3=T.GlassCard,BorderSizePixel=0,
                ClipsDescendants=true,Visible=false},target())
            corner(panel,T.R8)
            glassBorder(panel,T.BorderHov,1.2)
            shimmerLine(panel,0.7)
            pad(panel,8,8,10,10)
            vlist(panel,6)

            local r=math.floor(col.R*255)
            local g=math.floor(col.G*255)
            local b=math.floor(col.B*255)

            local function push()
                col=Color3.fromRGB(r,g,b)
                swatch.BackgroundColor3=col
                if flag then Nova.Flags[flag].Value=col end
                pcall(cb,col); Window:_saveAll()
            end

            local function mkCh(lbl,init,setter)
                local row=new("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},panel)
                new("TextLabel",{Size=UDim2.new(0,14,1,0),BackgroundTransparency=1,
                    Text=lbl,TextColor3=T.TextDim,TextSize=10,Font=T.FontBold},row)
                local trk=new("Frame",{Size=UDim2.new(1,-46,0,4),
                    Position=UDim2.new(0,18,0.5,-2),
                    BackgroundColor3=T.ToggleOff,BorderSizePixel=0,
                    ClipsDescendants=true},row)
                corner(trk,T.RFull)
                glassBorder(trk,T.BorderElem,1)
                local fl=new("Frame",{Size=UDim2.new(init/255,0,1,0),
                    BackgroundColor3=T.Accent,BorderSizePixel=0},trk)
                corner(fl,T.RFull)
                shimmerLine(fl,0.5)
                local vl=new("TextLabel",{Size=UDim2.new(0,28,1,0),
                    Position=UDim2.new(1,-30,0,0),BackgroundTransparency=1,
                    Text=tostring(init),TextColor3=T.Accent,TextSize=10,Font=T.FontBold},row)
                local d2=false
                local function u(x)
                    local rel=math.clamp((x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
                    local v2=math.floor(rel*255)
                    fl.Size=UDim2.new(rel,0,1,0); vl.Text=tostring(v2)
                    setter(v2); push()
                end
                local hb=new("TextButton",{Size=UDim2.new(1,0,0,20),
                    Position=UDim2.new(0,0,0.5,-10),BackgroundTransparency=1,Text="",ZIndex=2},trk)
                hb.MouseButton1Down:Connect(function() d2=true; u(Mouse.X) end)
                table.insert(Nova._conns,UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then d2=false end
                end))
                table.insert(Nova._conns,UserInputService.InputChanged:Connect(function(i)
                    if d2 and i.UserInputType==Enum.UserInputType.MouseMovement then u(Mouse.X) end
                end))
            end
            mkCh("R",r,function(v) r=v end)
            mkCh("G",g,function(v) g=v end)
            mkCh("B",b,function(v) b=v end)

            local hexRow=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},panel)
            new("TextLabel",{Size=UDim2.new(0,22,1,0),BackgroundTransparency=1,
                Text="#",TextColor3=T.TextDim,TextSize=10,Font=T.FontBold},hexRow)
            local hexBox=new("TextBox",{Size=UDim2.new(1,-26,0,24),
                Position=UDim2.new(0,24,0.5,-12),
                BackgroundColor3=T.GlassDeep,
                Text=string.format("%02X%02X%02X",r,g,b),
                PlaceholderText="RRGGBB",PlaceholderColor3=T.TextMuted,
                TextColor3=T.TextSub,TextSize=10,Font=T.Font,
                BorderSizePixel=0,ClearTextOnFocus=false},hexRow)
            corner(hexBox,T.R5)
            glassBorder(hexBox,T.BorderElem,1)
            hexBox.Focused:Connect(function()
                local s=hexBox:FindFirstChildOfClass("UIStroke")
                if s then tw(s,{Color=T.BorderFocus}) end
            end)
            hexBox.FocusLost:Connect(function()
                local s=hexBox:FindFirstChildOfClass("UIStroke")
                if s then tw(s,{Color=T.BorderElem}) end
                local hex=hexBox.Text:gsub("#",""):upper()
                if #hex==6 then
                    local ok,hr,hg,hb=pcall(function()
                        return tonumber(hex:sub(1,2),16),
                               tonumber(hex:sub(3,4),16),
                               tonumber(hex:sub(5,6),16)
                    end)
                    if ok and hr and hg and hb then r,g,b=hr,hg,hb; push() end
                end
                hexBox.Text=string.format("%02X%02X%02X",r,g,b)
            end)

            new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},f
            ).MouseButton1Click:Connect(function()
                isOpen=not isOpen; chev.Text=isOpen and "▴" or "▾"
                if isOpen then
                    panel.Visible=true
                    tw(panel,{Size=UDim2.new(1,0,0,140)},.22,Enum.EasingStyle.Back)
                else
                    tw(panel,{Size=UDim2.new(1,0,0,0)},.18)
                    task.delay(.2,function() panel.Visible=false end)
                end
            end)

            local obj={Value=col,_save=save}
            function obj:Set(c)
                col=c; swatch.BackgroundColor3=c
                r=math.floor(c.R*255); g=math.floor(c.G*255); b=math.floor(c.B*255)
                hexBox.Text=string.format("%02X%02X%02X",r,g,b)
                self.Value=c
                if flag then Nova.Flags[flag].Value=c end
                pcall(cb,c)
            end
            if flag then Nova.Flags[flag]=obj end
            return obj
        end

        -- ── BIND ─────────────────────────────────
        function Tab:AddBind(opts)
            opts=opts or {}
            local name=opts.Name or "Bind"
            local key=opts.Default or Enum.KeyCode.E
            local hold=opts.Hold or false
            local flag=opts.Flag or nil; local save=opts.Save or false
            local cb=opts.Callback or function()end
            local listening=false; local holding=false

            local f=glassElem(40)
            lblLeft(f,name,.52)

            local kbtn=new("TextButton",{Size=UDim2.new(0,118,0,28),
                Position=UDim2.new(1,-128,0.5,-14),
                BackgroundColor3=T.GlassDeep,
                Text="[ "..key.Name.." ]",
                TextColor3=T.Accent,TextSize=11,Font=T.FontBold,
                BorderSizePixel=0},f)
            corner(kbtn,T.R6)
            local kbs=glassBorder(kbtn,T.BorderBtn,1.2)
            shimmerLine(kbtn,0.7)

            kbtn.MouseEnter:Connect(function()
                if not listening then
                    tw(kbs,{Color=T.BorderBtnHv})
                    tw(kbtn,{BackgroundColor3=T.Glass})
                end
            end)
            kbtn.MouseLeave:Connect(function()
                if not listening then
                    tw(kbs,{Color=T.BorderBtn})
                    tw(kbtn,{BackgroundColor3=T.GlassDeep})
                end
            end)

            kbtn.MouseButton1Click:Connect(function()
                listening=true
                kbtn.Text="[ ... ]"
                kbtn.TextColor3=T.Warning
                tw(kbs,{Color=T.Warning})
                tw(kbtn,{BackgroundColor3=Color3.fromRGB(38,28,10)})
            end)

            table.insert(Nova._conns,UserInputService.InputBegan:Connect(function(i,gp)
                if gp then return end
                if listening then
                    if i.UserInputType==Enum.UserInputType.Keyboard then
                        key=i.KeyCode
                        kbtn.Text="[ "..key.Name.." ]"
                        kbtn.TextColor3=T.Accent
                        tw(kbs,{Color=T.BorderFocus})
                        tw(kbtn,{BackgroundColor3=T.GlassDeep})
                        listening=false
                        if flag then Nova.Flags[flag].Value=key end
                        Window:_saveAll()
                    end
                    return
                end
                if i.KeyCode==key then
                    if hold then holding=true end
                    pcall(cb)
                end
            end))
            table.insert(Nova._conns,UserInputService.InputEnded:Connect(function(i)
                if hold and i.KeyCode==key then holding=false end
            end))

            local obj={Value=key,_save=save}
            function obj:Set(k)
                key=k; kbtn.Text="[ "..k.Name.." ]"; self.Value=k
                if flag then Nova.Flags[flag].Value=k end
            end
            function obj:IsHolding() return holding end
            if flag then Nova.Flags[flag]=obj end
            return obj
        end

        -- ── TEXTBOX ──────────────────────────────
        function Tab:AddTextbox(opts)
            opts=opts or {}
            local name=opts.Name or "Input"
            local default=opts.Default or ""
            local placeholder=opts.Placeholder or "Type here..."
            local vanish=opts.TextDisappear or false
            local maxChars=opts.MaxChars or 200
            local numbersOnly=opts.NumbersOnly or false
            local cb=opts.Callback or function()end

            local wrapper=new("Frame",{Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,BorderSizePixel=0},target())
            vlist(wrapper,4)

            local labelRow=new("Frame",{Size=UDim2.new(1,0,0,15),
                BackgroundTransparency=1},wrapper)
            new("TextLabel",{Size=UDim2.new(.7,0,1,0),BackgroundTransparency=1,
                Text=name,TextColor3=T.TextSub,TextSize=11,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Left},labelRow)
            local counter=new("TextLabel",{Size=UDim2.new(.3,0,1,0),
                Position=UDim2.new(.7,0,0,0),BackgroundTransparency=1,
                Text="0 / "..maxChars,TextColor3=T.TextMuted,
                TextSize=9,Font=T.FontLight,
                TextXAlignment=Enum.TextXAlignment.Right},labelRow)

            local iFrame=new("Frame",{Size=UDim2.new(1,0,0,40),
                BackgroundColor3=T.GlassDeep,BorderSizePixel=0,ClipsDescendants=true},wrapper)
            corner(iFrame,T.R8)
            local ibs=glassBorder(iFrame,T.BorderElem,1.5)
            shimmerLine(iFrame,0.74)

            local acBar=new("Frame",{Size=UDim2.new(0,2,.55,0),
                Position=UDim2.new(0,0,.225,0),
                BackgroundColor3=T.Accent,BorderSizePixel=0,
                BackgroundTransparency=1},iFrame)
            corner(acBar,T.RFull)

            new("TextLabel",{Size=UDim2.new(0,30,1,0),BackgroundTransparency=1,
                Text="✎",TextColor3=T.TextMuted,TextSize=14,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Center},iFrame)

            local box=new("TextBox",{Size=UDim2.new(1,-62,1,0),
                Position=UDim2.new(0,30,0,0),BackgroundTransparency=1,
                Text=default,PlaceholderText=placeholder,
                PlaceholderColor3=T.TextMuted,TextColor3=T.Text,
                TextSize=12,Font=T.FontLight,BorderSizePixel=0,
                ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd},iFrame)

            local clearBtn=new("TextButton",{Size=UDim2.new(0,26,0,26),
                Position=UDim2.new(1,-32,0.5,-13),
                BackgroundColor3=T.Glass,Text="✕",
                TextColor3=T.TextMuted,TextSize=10,Font=T.FontBold,
                BorderSizePixel=0,BackgroundTransparency=1},iFrame)
            corner(clearBtn,T.RFull)
            glassBorder(clearBtn,T.BorderElem,1)

            clearBtn.MouseButton1Click:Connect(function()
                box.Text=""; counter.Text="0 / "..maxChars; pcall(cb,"",false)
            end)
            box.Focused:Connect(function()
                tw(ibs,{Color=T.BorderFocus,Thickness=1.8})
                tw(iFrame,{BackgroundColor3=Color3.fromRGB(13,10,26)})
                tw(acBar,{BackgroundTransparency=0})
                tw(clearBtn,{BackgroundTransparency=0,TextColor3=T.TextSub})
            end)
            box.FocusLost:Connect(function(enter)
                tw(ibs,{Color=T.BorderElem,Thickness=1.5})
                tw(iFrame,{BackgroundColor3=T.GlassDeep})
                tw(acBar,{BackgroundTransparency=1})
                tw(clearBtn,{BackgroundTransparency=1,TextColor3=T.TextMuted})
                local txt=box.Text
                if numbersOnly and not tonumber(txt) then txt=""; box.Text="" end
                if #txt>maxChars then txt=txt:sub(1,maxChars); box.Text=txt end
                pcall(cb,txt,enter)
                if vanish then box.Text=""; counter.Text="0 / "..maxChars end
            end)
            box:GetPropertyChangedSignal("Text"):Connect(function()
                local txt=box.Text
                if numbersOnly then
                    local c=txt:gsub("[^%d%.-]","")
                    if c~=txt then box.Text=c; return end
                end
                if #txt>maxChars then box.Text=txt:sub(1,maxChars); return end
                local len=#txt; counter.Text=len.." / "..maxChars
                counter.TextColor3=len>=maxChars and T.Danger
                    or (len>=math.floor(maxChars*.8) and T.Warning or T.TextMuted)
            end)
            counter.Text=#default.." / "..maxChars

            local obj={}
            function obj:Set(v) box.Text=tostring(v); counter.Text=#tostring(v).." / "..maxChars end
            function obj:Get() return box.Text end
            function obj:Clear() box.Text=""; counter.Text="0 / "..maxChars end
            return obj
        end

        -- ── KEY SYSTEM ────────────────────────────
        function Tab:AddKeySystem(opts)
            opts=opts or {}
            local title=opts.Title or "Key System"
            local description=opts.Description or "Enter your key to access the script."
            local keys=opts.Keys or {}
            local placeholder=opts.Placeholder or "Enter key here..."
            local getKeyUrl=opts.GetKeyUrl or nil
            local onSuccess=opts.onSuccess or function()end
            local onFail=opts.onFail or function()end

            local card=new("Frame",{Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=T.GlassCard,BorderSizePixel=0},target())
            corner(card,T.R10)
            glassBorder(card,T.BorderCard,1.2)
            shimmerLine(card,0.65)
            pad(card,16,16,14,14)
            vlist(card,10)

            local titleRow=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},card)
            local ic=new("Frame",{Size=UDim2.new(0,28,0,28),
                BackgroundColor3=T.AccentDark,BorderSizePixel=0,
                ClipsDescendants=true},titleRow)
            corner(ic,T.RFull)
            grad(ic,Color3.fromRGB(90,48,215),Color3.fromRGB(48,26,130),135)
            glassBorder(ic,T.BorderBtn,1)
            new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="🔑",TextSize=13,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Center},ic)
            new("TextLabel",{Size=UDim2.new(1,-38,1,0),Position=UDim2.new(0,36,0,0),
                BackgroundTransparency=1,Text=title,TextColor3=T.Text,
                TextSize=13,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left},titleRow)

            new("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,Text=description,TextColor3=T.TextDim,
                TextSize=11,Font=T.FontLight,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true},card)

            local iFrame=new("Frame",{Size=UDim2.new(1,0,0,42),
                BackgroundColor3=T.GlassDeep,BorderSizePixel=0,ClipsDescendants=true},card)
            corner(iFrame,T.R8)
            local ibs=glassBorder(iFrame,T.BorderElem,1.5)
            shimmerLine(iFrame,0.72)
            new("TextLabel",{Size=UDim2.new(0,34,1,0),BackgroundTransparency=1,
                Text="⌨",TextSize=13,TextColor3=T.TextMuted,
                Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Center},iFrame)
            local keyInput=new("TextBox",{Size=UDim2.new(1,-38,1,0),
                Position=UDim2.new(0,34,0,0),BackgroundTransparency=1,
                Text="",PlaceholderText=placeholder,PlaceholderColor3=T.TextMuted,
                TextColor3=T.Text,TextSize=12,Font=T.Font,
                BorderSizePixel=0,ClearTextOnFocus=false,
                TextXAlignment=Enum.TextXAlignment.Left},iFrame)

            keyInput.Focused:Connect(function()
                tw(ibs,{Color=T.BorderFocus,Thickness=1.8})
                tw(iFrame,{BackgroundColor3=Color3.fromRGB(12,9,24)})
            end)
            keyInput.FocusLost:Connect(function()
                tw(ibs,{Color=T.BorderElem,Thickness=1.5})
                tw(iFrame,{BackgroundColor3=T.GlassDeep})
            end)

            local statusLbl=new("TextLabel",{Size=UDim2.new(1,0,0,14),
                BackgroundTransparency=1,Text="",TextSize=10,Font=T.FontBold,
                TextXAlignment=Enum.TextXAlignment.Left,Visible=false},card)

            local vBtn=new("TextButton",{Size=UDim2.new(1,0,0,40),
                BackgroundColor3=T.AccentBtn0,Text="",BorderSizePixel=0},card)
            corner(vBtn,T.R8)
            grad(vBtn,T.AccentBtn0,T.AccentBtn1,90)
            local vbs=glassBorder(vBtn,T.BorderBtn,1.2)
            shimmerLine(vBtn,0.5)
            local vLbl=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="Verify Key",TextColor3=T.Text,TextSize=13,Font=T.FontBold},vBtn)
            vBtn.MouseEnter:Connect(function()
                tw(vBtn,{BackgroundColor3=Color3.fromRGB(70,40,172)})
                tw(vbs,{Color=T.BorderBtnHv})
            end)
            vBtn.MouseLeave:Connect(function()
                tw(vBtn,{BackgroundColor3=T.AccentBtn0})
                tw(vbs,{Color=T.BorderBtn})
            end)

            if getKeyUrl then
                new("TextLabel",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,
                    Text="🔗  Get a key:  "..getKeyUrl,TextColor3=T.TextMuted,
                    TextSize=10,Font=T.FontLight,TextXAlignment=Enum.TextXAlignment.Center,
                    TextWrapped=true},card)
            end

            local verified=false; local attempts=0; local MAX=5

            local function doVerify()
                if verified then return end
                if attempts>=MAX then
                    statusLbl.Visible=true
                    statusLbl.Text="✘  Too many attempts."; statusLbl.TextColor3=T.Danger; return
                end
                local entered=keyInput.Text:gsub("%s","")
                if entered=="" then
                    statusLbl.Visible=true
                    statusLbl.Text="✘  Please enter a key."; statusLbl.TextColor3=T.Danger
                    tw(ibs,{Color=T.Danger}); task.delay(.9,function() tw(ibs,{Color=T.BorderElem}) end)
                    return
                end
                attempts=attempts+1
                vLbl.Text="Verifying..."
                tw(vBtn,{BackgroundColor3=Color3.fromRGB(28,16,72)})
                tw(vbs,{Color=T.BorderElem})
                task.delay(.55,function()
                    local valid=false
                    for _,k in ipairs(keys) do if entered==tostring(k) then valid=true; break end end
                    if valid then
                        verified=true
                        tw(vBtn,{BackgroundColor3=Color3.fromRGB(26,100,58)})
                        tw(vbs,{Color=T.Success})
                        tw(ibs,{Color=T.Success})
                        vLbl.Text="✔  Access Granted"
                        statusLbl.Visible=true
                        statusLbl.Text="✔  Welcome, "..LocalPlayer.Name.."!"
                        statusLbl.TextColor3=T.Success
                        vBtn.Active=false; keyInput.TextEditable=false
                        Nova:MakeNotification({Name="Key System",
                            Content="Access granted! Welcome.",Time=4})
                        pcall(onSuccess,entered)
                    else
                        tw(vBtn,{BackgroundColor3=T.AccentBtn0})
                        tw(vbs,{Color=T.BorderBtn})
                        tw(ibs,{Color=T.Danger})
                        vLbl.Text="Verify Key"
                        statusLbl.Visible=true
                        statusLbl.Text="✘  Invalid key. ("..attempts.."/"..MAX.." attempts)"
                        statusLbl.TextColor3=T.Danger
                        task.delay(1,function() tw(ibs,{Color=T.BorderElem}) end)
                        for i=1,4 do
                            task.wait(0.04)
                            iFrame.Position=UDim2.new(0,i%2==0 and 5 or -5,0,0)
                        end
                        iFrame.Position=UDim2.new(0,0,0,0)
                        pcall(onFail,entered)
                    end
                end)
            end

            vBtn.MouseButton1Click:Connect(doVerify)
            keyInput.FocusLost:Connect(function(enter) if enter then doVerify() end end)

            local obj={}
            function obj:IsVerified() return verified end
            function obj:SetKeys(t) keys=t end
            return obj
        end

        return Tab
    end -- MakeTab

    Window._loadFn=function() Window:_loadAll() end
    return Window
end -- MakeWindow

-- ════════════════════════════════════════════════════════════
--  DESTROY / INIT
-- ════════════════════════════════════════════════════════════
function Nova:Destroy()
    for _,c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns={}
    if self._gui then self._gui:Destroy(); self._gui=nil end
    self.Flags={}
end

function Nova:Init() end

return Nova
