-- ╔══════════════════════════════════════════════════════════════╗
-- ║          KreinGui V4  —  Premium macOS-Style GUI             ║
-- ║  Complete rewrite. All bugs fixed. Production-ready.        ║
-- ╚══════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ══════════════════════════════════════════════
--  PRIMITIVES
-- ══════════════════════════════════════════════

local function New(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end

local function Tw(obj, ti, props)
    TweenService:Create(obj, ti, props):Play()
end

local function Corner(r, p)
    return New("UICorner", {CornerRadius=UDim.new(0,r or 8), Parent=p})
end

local function Pad(p, t, b, l, r)
    return New("UIPadding", {
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
        Parent=p
    })
end

local function Stroke(p, col, thick, trans)
    return New("UIStroke", {
        Color=col or Color3.new(1,1,1), Thickness=thick or 1,
        Transparency=trans or 0.8,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=p
    })
end

local function Shadow(p, sz, tr)
    return New("ImageLabel", {
        AnchorPoint=Vector2.new(.5,.5), BackgroundTransparency=1,
        Position=UDim2.new(.5,0,.5,5),
        Size=UDim2.new(1,sz or 40,1,sz or 40),
        ZIndex=(p.ZIndex or 2)-1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=tr or 0.55,
        ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        Parent=p
    })
end

-- ══════════════════════════════════════════════
--  SOUND
-- ══════════════════════════════════════════════

local _svc  = game:GetService("SoundService")
local _snd  = New("Sound", {SoundId="rbxassetid://6026984224", Volume=0.45,
    RollOffMaxDistance=0, Parent=_svc})
local _sndOn = true

local function Click()
    if not _sndOn then return end
    local s = _snd:Clone()
    s.Parent = _svc
    s:Play()
    game:GetService("Debris"):AddItem(s, 1.5)
end

-- ══════════════════════════════════════════════
--  RIPPLE
-- ══════════════════════════════════════════════

local function Ripple(btn, col)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x, y)
        local r = New("Frame", {
            BackgroundColor3=col or Color3.new(1,1,1),
            BackgroundTransparency=0.72, BorderSizePixel=0,
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.new(0, x-btn.AbsolutePosition.X, 0, y-btn.AbsolutePosition.Y),
            Size=UDim2.new(0,0,0,0), ZIndex=btn.ZIndex+20, Parent=btn
        })
        Corner(999, r)
        local mx = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.6
        Tw(r, TweenInfo.new(.4, Enum.EasingStyle.Quart),
            {Size=UDim2.new(0,mx,0,mx), BackgroundTransparency=1})
        task.delay(.45, function() r:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════════════

local T = {}

T.Dark = {
    Win=Color3.fromRGB(16,16,20), TitleBar=Color3.fromRGB(22,22,28),
    TitleStroke=Color3.fromRGB(40,40,54),
    Sidebar=Color3.fromRGB(14,14,18), SbDiv=Color3.fromRGB(32,32,44),
    SbText=Color3.fromRGB(118,118,145), SbHover=Color3.fromRGB(28,28,38),
    SbActive=Color3.fromRGB(32,36,56), SbActiveTxt=Color3.fromRGB(240,240,255),
    Text=Color3.fromRGB(228,228,242), Sub=Color3.fromRGB(88,88,112),
    Label=Color3.fromRGB(148,148,172),
    Accent=Color3.fromRGB(118,135,255), AccentDark=Color3.fromRGB(88,105,225),
    Danger=Color3.fromRGB(255,72,72), Success=Color3.fromRGB(50,215,115),
    Warning=Color3.fromRGB(255,188,52),
    Card=Color3.fromRGB(22,22,30), CardStroke=Color3.fromRGB(34,34,48),
    BtnPrimary=Color3.fromRGB(108,122,255), BtnSecondary=Color3.fromRGB(36,36,50),
    BtnDanger=Color3.fromRGB(215,58,58),
    ToggleOff=Color3.fromRGB(42,42,58), ToggleOn=Color3.fromRGB(50,215,115),
    Track=Color3.fromRGB(32,32,48), Fill=Color3.fromRGB(108,122,255),
    InputBg=Color3.fromRGB(22,22,32),
    DdBg=Color3.fromRGB(20,20,30), DdItem=Color3.fromRGB(28,28,40),
    NotifBg=Color3.fromRGB(24,24,34), Stroke=Color3.fromRGB(38,38,54),
    ProfileBg=Color3.fromRGB(20,20,26), ProfileHov=Color3.fromRGB(28,28,38),
    PopupBg=Color3.fromRGB(20,20,30), PopupItem=Color3.fromRGB(28,28,42),
    SearchBg=Color3.fromRGB(22,22,32), ProgBg=Color3.fromRGB(28,28,44),
    TrRed=Color3.fromRGB(255,88,78), TrYellow=Color3.fromRGB(255,192,58),
    TrGreen=Color3.fromRGB(58,212,95),
    NeonA=Color3.fromRGB(140,80,255), NeonB=Color3.fromRGB(80,145,255),
}

-- Light: sidebar gelap abu-biru, content putih bersih
T.Light = {
    Win=Color3.fromRGB(244,244,250), TitleBar=Color3.fromRGB(255,255,255),
    TitleStroke=Color3.fromRGB(218,218,232),
    Sidebar=Color3.fromRGB(46,50,68), SbDiv=Color3.fromRGB(62,66,86),
    SbText=Color3.fromRGB(162,165,195), SbHover=Color3.fromRGB(58,62,82),
    SbActive=Color3.fromRGB(72,96,210), SbActiveTxt=Color3.fromRGB(255,255,255),
    Text=Color3.fromRGB(18,18,32), Sub=Color3.fromRGB(118,118,142),
    Label=Color3.fromRGB(62,62,88),
    Accent=Color3.fromRGB(72,96,225), AccentDark=Color3.fromRGB(52,76,200),
    Danger=Color3.fromRGB(200,42,42), Success=Color3.fromRGB(28,158,82),
    Warning=Color3.fromRGB(192,138,12),
    Card=Color3.fromRGB(255,255,255), CardStroke=Color3.fromRGB(220,220,236),
    BtnPrimary=Color3.fromRGB(72,96,225), BtnSecondary=Color3.fromRGB(232,232,248),
    BtnDanger=Color3.fromRGB(200,42,42),
    ToggleOff=Color3.fromRGB(195,195,218), ToggleOn=Color3.fromRGB(28,158,82),
    Track=Color3.fromRGB(212,212,232), Fill=Color3.fromRGB(72,96,225),
    InputBg=Color3.fromRGB(252,252,255),
    DdBg=Color3.fromRGB(255,255,255), DdItem=Color3.fromRGB(244,244,252),
    NotifBg=Color3.fromRGB(255,255,255), Stroke=Color3.fromRGB(215,215,232),
    ProfileBg=Color3.fromRGB(62,66,86), ProfileHov=Color3.fromRGB(74,78,100),
    PopupBg=Color3.fromRGB(255,255,255), PopupItem=Color3.fromRGB(244,244,252),
    SearchBg=Color3.fromRGB(60,64,84), ProgBg=Color3.fromRGB(215,215,232),
    TrRed=Color3.fromRGB(255,88,78), TrYellow=Color3.fromRGB(255,192,58),
    TrGreen=Color3.fromRGB(58,212,95),
    NeonA=Color3.fromRGB(100,60,220), NeonB=Color3.fromRGB(60,120,220),
}

T.Ocean = {
    Win=Color3.fromRGB(8,16,26), TitleBar=Color3.fromRGB(12,22,36),
    TitleStroke=Color3.fromRGB(22,48,68),
    Sidebar=Color3.fromRGB(8,18,30), SbDiv=Color3.fromRGB(18,44,62),
    SbText=Color3.fromRGB(88,138,168), SbHover=Color3.fromRGB(16,36,52),
    SbActive=Color3.fromRGB(18,46,70), SbActiveTxt=Color3.fromRGB(188,228,252),
    Text=Color3.fromRGB(198,225,245), Sub=Color3.fromRGB(68,112,142),
    Label=Color3.fromRGB(118,168,198),
    Accent=Color3.fromRGB(62,192,222), AccentDark=Color3.fromRGB(38,152,182),
    Danger=Color3.fromRGB(255,78,78), Success=Color3.fromRGB(52,212,128),
    Warning=Color3.fromRGB(255,182,52),
    Card=Color3.fromRGB(12,24,38), CardStroke=Color3.fromRGB(22,50,72),
    BtnPrimary=Color3.fromRGB(48,172,208), BtnSecondary=Color3.fromRGB(16,40,60),
    BtnDanger=Color3.fromRGB(212,62,62),
    ToggleOff=Color3.fromRGB(20,46,66), ToggleOn=Color3.fromRGB(52,212,128),
    Track=Color3.fromRGB(16,38,58), Fill=Color3.fromRGB(48,172,208),
    InputBg=Color3.fromRGB(12,26,40),
    DdBg=Color3.fromRGB(10,22,34), DdItem=Color3.fromRGB(16,36,54),
    NotifBg=Color3.fromRGB(12,26,42), Stroke=Color3.fromRGB(22,50,72),
    ProfileBg=Color3.fromRGB(10,20,32), ProfileHov=Color3.fromRGB(16,36,54),
    PopupBg=Color3.fromRGB(12,24,36), PopupItem=Color3.fromRGB(18,40,58),
    SearchBg=Color3.fromRGB(12,28,44), ProgBg=Color3.fromRGB(16,40,60),
    TrRed=Color3.fromRGB(255,88,78), TrYellow=Color3.fromRGB(255,192,58),
    TrGreen=Color3.fromRGB(58,212,95),
    NeonA=Color3.fromRGB(40,160,255), NeonB=Color3.fromRGB(40,225,195),
}

-- ══════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════

local function Draggable(handle, target)
    local drag, startI, startP
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; startI=i.Position; startP=target.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - startI
            target.Position = UDim2.new(startP.X.Scale, startP.X.Offset+d.X,
                startP.Y.Scale, startP.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════
--  COLOR PICKER MODAL
--  Selalu muncul di tengah layar. Satu instance per-window.
-- ══════════════════════════════════════════════

local function BuildColorModal(gui)
    local PANEL_W, PANEL_H = 300, 388
    local PAD = 14
    local SQ_W = PANEL_W - PAD*2  -- 272
    local SQ_H = 162

    -- Overlay gelap
    local overlay = New("Frame", {
        BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.5,
        BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=200, Visible=false, Parent=gui
    })

    local panel = New("Frame", {
        BackgroundColor3=Color3.fromRGB(22,22,30), BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.5,0),
        Size=UDim2.new(0,PANEL_W,0,PANEL_H),
        ZIndex=201, Parent=overlay
    })
    Corner(14, panel)
    Stroke(panel, Color3.fromRGB(50,50,70), 1.5, 0.3)
    Shadow(panel, 50, 0.42)

    -- Header
    local hdrLbl = New("TextLabel", {
        BackgroundTransparency=1, Text="Pilih Warna",
        TextColor3=Color3.fromRGB(228,228,242), Font=Enum.Font.GothamBold, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,-24,0,20), Position=UDim2.new(0,PAD,0,12), ZIndex=202, Parent=panel
    })

    -- ── SV SQUARE ──
    local SQ_Y = 38
    local svBase = New("Frame", {
        BackgroundColor3=Color3.fromRGB(255,0,0), BorderSizePixel=0,
        Position=UDim2.new(0,PAD,0,SQ_Y),
        Size=UDim2.new(0,SQ_W,0,SQ_H), ZIndex=202, Parent=panel
    })
    Corner(8, svBase)

    -- White saturation overlay (left=white→right=transparent)
    New("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }),
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation=0, Parent=svBase
    })

    -- Black value overlay (top=transparent→bottom=black)
    local svDark = New("Frame", {
        BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0,
        BorderSizePixel=0, Size=UDim2.new(1,0,1,0), ZIndex=203, Parent=svBase
    })
    Corner(8, svDark)
    New("UIGradient", {
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation=90, Parent=svDark
    })

    -- SV knob
    local svKnob = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0,20,0,20), ZIndex=205, Parent=svBase
    })
    Corner(10, svKnob)
    Stroke(svKnob, Color3.new(1,1,1), 2.5, 0)
    local svInner = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.5,0),
        Size=UDim2.new(0,10,0,10), ZIndex=206, Parent=svKnob
    })
    Corner(5, svInner)

    -- Invisible hitbox covering entire SV square (above knob)
    local svHit = New("TextButton", {
        BackgroundTransparency=1, BorderSizePixel=0, Text="",
        Size=UDim2.new(1,0,1,0), ZIndex=208, AutoButtonColor=false, Parent=svBase
    })

    -- ── HUE BAR ──
    local HUE_Y = SQ_Y + SQ_H + 12
    local hueBar = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        Position=UDim2.new(0,PAD,0,HUE_Y),
        Size=UDim2.new(0,SQ_W,0,14), ZIndex=202, Parent=panel
    })
    Corner(7, hueBar)
    New("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,0,0)),
        }),
        Rotation=0, Parent=hueBar
    })

    local hueKnob = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(0,0,.5,0),
        Size=UDim2.new(0,16,0,22), ZIndex=203, Parent=hueBar
    })
    Corner(4, hueKnob)
    Stroke(hueKnob, Color3.new(1,1,1), 2, 0)
    Shadow(hueKnob, 8, 0.65)

    local hueHit = New("TextButton", {
        BackgroundTransparency=1, BorderSizePixel=0, Text="",
        Size=UDim2.new(1,0,1,0), ZIndex=204, AutoButtonColor=false, Parent=hueBar
    })

    -- ── PREVIEW SWATCHES ──
    local PREV_Y = HUE_Y + 14 + 12
    local SW_W = (SQ_W - 8) / 2

    New("TextLabel", {
        BackgroundTransparency=1, Text="Sebelum",
        TextColor3=Color3.fromRGB(88,88,112), Font=Enum.Font.Gotham, TextSize=9,
        Size=UDim2.new(0,SW_W,0,13), Position=UDim2.new(0,PAD,0,PREV_Y),
        ZIndex=202, Parent=panel
    })
    New("TextLabel", {
        BackgroundTransparency=1, Text="Baru",
        TextColor3=Color3.fromRGB(88,88,112), Font=Enum.Font.Gotham, TextSize=9,
        Size=UDim2.new(0,SW_W,0,13), Position=UDim2.new(0,PAD+SW_W+8,0,PREV_Y),
        ZIndex=202, Parent=panel
    })
    local swOld = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        Position=UDim2.new(0,PAD,0,PREV_Y+14), Size=UDim2.new(0,SW_W,0,30),
        ZIndex=202, Parent=panel
    })
    Corner(7, swOld)
    Stroke(swOld, Color3.fromRGB(50,50,70), 1, 0.5)
    local swNew = New("Frame", {
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        Position=UDim2.new(0,PAD+SW_W+8,0,PREV_Y+14), Size=UDim2.new(0,SW_W,0,30),
        ZIndex=202, Parent=panel
    })
    Corner(7, swNew)
    Stroke(swNew, Color3.fromRGB(50,50,70), 1, 0.5)

    -- ── HEX DISPLAY ──
    local HEX_Y = PREV_Y + 14 + 30 + 10
    local hexBg = New("Frame", {
        BackgroundColor3=Color3.fromRGB(14,14,20), BorderSizePixel=0,
        Position=UDim2.new(0,PAD,0,HEX_Y), Size=UDim2.new(0,SQ_W,0,28),
        ZIndex=202, Parent=panel
    })
    Corner(7, hexBg)
    Stroke(hexBg, Color3.fromRGB(50,50,70), 1, 0.5)
    New("TextLabel", {
        BackgroundTransparency=1, Text="#",
        TextColor3=Color3.fromRGB(88,88,112), Font=Enum.Font.GothamBold, TextSize=11,
        Size=UDim2.new(0,20,1,0), Position=UDim2.new(0,8,0,0), ZIndex=203, Parent=hexBg
    })
    local hexLbl = New("TextLabel", {
        BackgroundTransparency=1, Text="FFFFFF",
        TextColor3=Color3.fromRGB(228,228,242), Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,24,0,0), ZIndex=203, Parent=panel
    })
    hexLbl.Parent = hexBg

    -- ── BUTTONS ──
    local BTN_Y = HEX_Y + 28 + 10
    local BW = (SQ_W - 8) / 2

    local batalBtn = New("TextButton", {
        BackgroundColor3=Color3.fromRGB(36,36,50), BorderSizePixel=0,
        Text="Batal", TextColor3=Color3.fromRGB(148,148,172),
        Font=Enum.Font.GothamBold, TextSize=12,
        Position=UDim2.new(0,PAD,0,BTN_Y), Size=UDim2.new(0,BW,0,36),
        AutoButtonColor=false, ZIndex=202, Parent=panel
    })
    Corner(9, batalBtn)
    Stroke(batalBtn, Color3.fromRGB(50,50,70), 1, 0.4)
    Ripple(batalBtn, Color3.new(.5,.5,.5))

    local ubahBtn = New("TextButton", {
        BackgroundColor3=Color3.fromRGB(108,122,255), BorderSizePixel=0,
        Text="Ubah", TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold, TextSize=12,
        Position=UDim2.new(0,PAD+BW+8,0,BTN_Y), Size=UDim2.new(0,BW,0,36),
        AutoButtonColor=false, ZIndex=202, Parent=panel
    })
    Corner(9, ubahBtn)
    Ripple(ubahBtn, Color3.new(1,1,1))

    batalBtn.MouseButton1Click:Connect(Click)
    ubahBtn.MouseButton1Click:Connect(Click)

    -- ── STATE & LOGIC ──
    local h, s, v     = 0, 1, 1
    local confirmed   = Color3.fromRGB(255,0,0)
    local onConfirm   = function() end
    local dragSV, dragHue = false, false

    local function toHex(c)
        return string.format("%02X%02X%02X",
            math.floor(c.R*255+.5), math.floor(c.G*255+.5), math.floor(c.B*255+.5))
    end

    local function refresh()
        local pending = Color3.fromHSV(h, s, v)
        svBase.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svKnob.Position = UDim2.new(s, 0, 1-v, 0)
        svInner.BackgroundColor3 = pending
        hueKnob.Position = UDim2.new(h, 0, .5, 0)
        swNew.BackgroundColor3 = pending
        hexLbl.Text = toHex(pending)
    end

    local function calcSV(mp)
        local abs = svBase.AbsolutePosition
        local sz  = svBase.AbsoluteSize
        if sz.X == 0 or sz.Y == 0 then return end
        s = math.clamp((mp.X - abs.X) / sz.X, 0, 1)
        v = math.clamp(1 - (mp.Y - abs.Y) / sz.Y, 0, 1)
        refresh()
    end

    local function calcHue(mp)
        local abs = hueBar.AbsolutePosition
        local sz  = hueBar.AbsoluteSize
        if sz.X == 0 then return end
        h = math.clamp((mp.X - abs.X) / sz.X, 0, 1)
        refresh()
    end

    svHit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragSV=true; calcSV(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    hueHit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragHue=true; calcHue(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragSV=false; dragHue=false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not overlay.Visible then return end
        if dragSV or dragHue then
            local mp = UserInputService:GetMouseLocation()
            if dragSV  then calcSV(mp)  end
            if dragHue then calcHue(mp) end
        end
    end)

    local function closeModal(cancel)
        _sndOn = false
        Tw(overlay, TweenInfo.new(.18, Enum.EasingStyle.Quart), {BackgroundTransparency=1})
        Tw(panel, TweenInfo.new(.18, Enum.EasingStyle.Quart),
            {BackgroundTransparency=1, Size=UDim2.new(0,PANEL_W,0,0)})
        task.delay(.2, function()
            overlay.Visible = false
            panel.BackgroundTransparency = 0
            panel.Size = UDim2.new(0,PANEL_W,0,PANEL_H)
            _sndOn = true
        end)
        if cancel then
            h,s,v = Color3.toHSV(confirmed); refresh()
        end
    end

    batalBtn.MouseButton1Click:Connect(function() closeModal(true) end)
    ubahBtn.MouseButton1Click:Connect(function()
        confirmed = Color3.fromHSV(h, s, v)
        swOld.BackgroundColor3 = confirmed
        onConfirm(confirmed)
        closeModal(false)
    end)

    local api = {}
    function api.Open(initColor, callback)
        confirmed = initColor or Color3.new(1,1,1)
        h, s, v = Color3.toHSV(confirmed)
        onConfirm = callback or function() end
        swOld.BackgroundColor3 = confirmed
        refresh()
        overlay.BackgroundTransparency = 1
        panel.Size = UDim2.new(0,PANEL_W,0,0)
        panel.BackgroundTransparency = 1
        overlay.Visible = true
        Tw(overlay, TweenInfo.new(.22, Enum.EasingStyle.Quart), {BackgroundTransparency=.5})
        Tw(panel, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {BackgroundTransparency=0, Size=UDim2.new(0,PANEL_W,0,PANEL_H)})
    end

    function api.UpdateTheme(C)
        panel.BackgroundColor3 = C.Card
        batalBtn.BackgroundColor3 = C.BtnSecondary
        batalBtn.TextColor3 = C.Label
        ubahBtn.BackgroundColor3 = C.BtnPrimary
        hexBg.BackgroundColor3 = C.InputBg
        hexLbl.TextColor3 = C.Text
        hdrLbl.TextColor3 = C.Text
    end

    return api
end

-- ══════════════════════════════════════════════
--  LIBRARY
-- ══════════════════════════════════════════════

local Library = {}
Library.Windows = {}

local Window = {}
Window.__index = Window

function Window.new(opts)
    local self          = setmetatable({}, Window)
    self.Title          = opts.Title    or "KreinUI"
    self.Subtitle       = opts.Subtitle or ""
    self.Icon           = opts.Icon     or "⬡"
    self.Theme          = opts.Theme    or "Dark"
    self.C              = T[self.Theme] or T.Dark
    self.Tabs           = {}
    self.ActiveTab      = nil
    self.Minimized      = false
    self.Maximized      = false
    self._reg           = {}
    self._cfg           = {}
    self._cfgCb         = {}
    self._cfgKey        = opts.ConfigKey or ("KreinCfg_"..(opts.Title or "x"))
    self._notifs        = {}
    self._searchIndex   = {}

    local pg = LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = New("ScreenGui", {
        Name="KreinV4_"..self.Title, Parent=pg,
        ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true
    })

    self._cp = BuildColorModal(self.Gui)

    local WIN_W, WIN_H = 780, 560

    -- Outer frame (holds neon border, not clipped)
    self.Win = New("Frame", {
        BackgroundColor3=self.C.Win, BorderSizePixel=0,
        Position=UDim2.new(.5,-WIN_W/2,.5,-WIN_H/2),
        Size=UDim2.new(0,WIN_W,0,WIN_H),
        ClipsDescendants=false, ZIndex=2, Parent=self.Gui
    })
    Corner(14, self.Win)
    local winStroke = Stroke(self.Win, self.C.Stroke, 1.5, .5)
    Shadow(self.Win, 70, .42)
    self:_r(self.Win, "BackgroundColor3", "Win")
    self:_r(winStroke, "Color", "Stroke")

    -- Inner clip frame
    self.WinInner = New("Frame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0), ClipsDescendants=true, ZIndex=2, Parent=self.Win
    })

    -- Neon border
    self:_buildNeon()

    -- Title Bar
    self.TitleBar = New("Frame", {
        BackgroundColor3=self.C.TitleBar, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,52), ZIndex=10, Parent=self.WinInner
    })
    Corner(14, self.TitleBar)
    self:_r(self.TitleBar, "BackgroundColor3", "TitleBar")

    local tbFill = New("Frame", {
        BackgroundColor3=self.C.TitleBar, BorderSizePixel=0,
        Position=UDim2.new(0,0,1,-14), Size=UDim2.new(1,0,0,14),
        ZIndex=10, Parent=self.TitleBar
    })
    self:_r(tbFill, "BackgroundColor3", "TitleBar")

    local tbDiv = New("Frame", {
        BackgroundColor3=self.C.TitleStroke, BorderSizePixel=0,
        Position=UDim2.new(0,0,1,-1), Size=UDim2.new(1,0,0,1),
        ZIndex=11, Parent=self.TitleBar
    })
    self:_r(tbDiv, "BackgroundColor3", "TitleStroke")

    -- Traffic lights (26px apart, centered hitboxes)
    local tlTi = TweenInfo.new(.14)
    local function TL(col, px, icon, fn)
        local dot = New("Frame", {
            BackgroundColor3=col, BorderSizePixel=0,
            Position=UDim2.new(0,px,.5,-7), Size=UDim2.new(0,14,0,14),
            ZIndex=12, Parent=self.TitleBar
        })
        Corner(100, dot)
        local ilbl = New("TextLabel", {
            BackgroundTransparency=1, Text="",
            TextColor3=Color3.fromRGB(80,30,20),
            Font=Enum.Font.GothamBold, TextSize=8,
            Size=UDim2.new(1,0,1,0), ZIndex=13, Parent=dot
        })
        local hb = New("TextButton", {
            BackgroundTransparency=1, BorderSizePixel=0, Text="",
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.new(0,px+7,.5,0),
            Size=UDim2.new(0,30,0,30),
            ZIndex=14, AutoButtonColor=false, Parent=self.TitleBar
        })
        hb.MouseEnter:Connect(function()
            ilbl.Text=icon
            Tw(dot, tlTi, {BackgroundColor3=col:Lerp(Color3.new(0,0,0),.18)})
        end)
        hb.MouseLeave:Connect(function()
            ilbl.Text=""
            Tw(dot, tlTi, {BackgroundColor3=col})
        end)
        hb.MouseButton1Click:Connect(function() Click(); fn() end)
    end
    TL(self.C.TrRed,   14, "✕", function() self:Destroy() end)
    TL(self.C.TrYellow,40, "–", function() self:ToggleMinimize() end)
    TL(self.C.TrGreen, 66, "+", function() self:ToggleMaximize() end)

    -- Title text
    local tIco = New("TextLabel", {
        BackgroundTransparency=1, Text=self.Icon,
        TextColor3=self.C.Accent, Font=Enum.Font.GothamBold, TextSize=20,
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,96,.5,-13),
        ZIndex=11, Parent=self.TitleBar
    })
    self:_r(tIco, "TextColor3", "Accent")
    local tTxt = New("TextLabel", {
        BackgroundTransparency=1, Text=self.Title,
        TextColor3=self.C.Text, Font=Enum.Font.GothamBold, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(0,240,0,18), Position=UDim2.new(0,128,.5,-14),
        ZIndex=11, Parent=self.TitleBar
    })
    self:_r(tTxt, "TextColor3", "Text")
    if self.Subtitle ~= "" then
        local sSub = New("TextLabel", {
            BackgroundTransparency=1, Text=self.Subtitle,
            TextColor3=self.C.Sub, Font=Enum.Font.Gotham, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(0,240,0,13), Position=UDim2.new(0,128,.5,4),
            ZIndex=11, Parent=self.TitleBar
        })
        self:_r(sSub, "TextColor3", "Sub")
    end
    Draggable(self.TitleBar, self.Win)

    -- Sidebar
    local SB_W = 200
    self.Sidebar = New("Frame", {
        BackgroundColor3=self.C.Sidebar, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,52), Size=UDim2.new(0,SB_W,1,-52),
        ZIndex=6, Parent=self.WinInner
    })
    self:_r(self.Sidebar, "BackgroundColor3", "Sidebar")
    local sbDiv = New("Frame", {
        BackgroundColor3=self.C.SbDiv, BorderSizePixel=0,
        Position=UDim2.new(1,-1,0,0), Size=UDim2.new(0,1,1,0),
        ZIndex=7, Parent=self.Sidebar
    })
    self:_r(sbDiv, "BackgroundColor3", "SbDiv")

    -- Global search bar
    local srchBg = New("Frame", {
        BackgroundColor3=self.C.SearchBg, BorderSizePixel=0,
        Position=UDim2.new(0,8,0,8), Size=UDim2.new(1,-16,0,30),
        ZIndex=8, Parent=self.Sidebar
    })
    Corner(8, srchBg)
    Stroke(srchBg, self.C.SbDiv, 1, .4)
    self:_r(srchBg, "BackgroundColor3", "SearchBg")
    New("TextLabel", {
        BackgroundTransparency=1, Text="🔍", TextSize=11,
        Size=UDim2.new(0,22,1,0), Position=UDim2.new(0,4,0,0),
        ZIndex=9, Parent=srchBg
    })
    self._srchBox = New("TextBox", {
        BackgroundTransparency=1,
        PlaceholderText="Search all...",
        PlaceholderColor3=self.C.SbText, Text="",
        TextColor3=self.C.SbActiveTxt,
        Font=Enum.Font.Gotham, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false,
        Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,24,0,0),
        ZIndex=9, Parent=srchBg
    })
    self:_r(self._srchBox, "TextColor3", "SbActiveTxt")
    self:_r(self._srchBox, "PlaceholderColor3", "SbText")

    -- Search results overlay
    self._srchOverlay = New("Frame", {
        BackgroundColor3=self.C.Sidebar, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,46), Size=UDim2.new(1,0,1,-86),
        ZIndex=15, Visible=false, Parent=self.Sidebar
    })
    self:_r(self._srchOverlay, "BackgroundColor3", "Sidebar")
    self._srchScroll = New("ScrollingFrame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=2, ScrollBarImageColor3=self.C.Accent,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ZIndex=15, Parent=self._srchOverlay
    })
    New("UIListLayout", {
        Padding=UDim.new(0,2),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=self._srchScroll
    })
    Pad(self._srchScroll, 4, 4, 4, 4)
    self._srchItems = {}

    self._srchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:_updateSearch(self._srchBox.Text)
    end)

    -- Tab list scroll
    self.SbScroll = New("ScrollingFrame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,46), Size=UDim2.new(1,0,1,-86),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=2, ScrollBarImageColor3=self.C.Accent,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ZIndex=7, Parent=self.Sidebar
    })
    New("UIListLayout", {
        Padding=UDim.new(0,4),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=self.SbScroll
    })
    Pad(self.SbScroll, 6, 6, 6, 6)

    self:_buildProfile()

    -- Content area
    self.Content = New("Frame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        ClipsDescendants=true,
        Position=UDim2.new(0,SB_W+1,0,52),
        Size=UDim2.new(1,-(SB_W+1),1,-52),
        ZIndex=3, Parent=self.WinInner
    })

    self:_buildResize()

    -- Open animation
    self.Win.Size = UDim2.new(0,WIN_W,0,0)
    self.Win.BackgroundTransparency = 1
    Tw(self.Win, TweenInfo.new(.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size=UDim2.new(0,WIN_W,0,WIN_H), BackgroundTransparency=0})

    table.insert(Library.Windows, self)
    return self
end

-- Registry helper
function Window:_r(obj, prop, key)
    table.insert(self._reg, {obj=obj, prop=prop, key=key})
end

-- ─────────────────────────────────────────
--  NEON BORDER (динамически follows window size)
-- ─────────────────────────────────────────
function Window:_buildNeon()
    local THICK = 2.5

    local function makeSide(horiz)
        local f = New("Frame", {
            BackgroundColor3=Color3.new(0,0,0), BorderSizePixel=0,
            ZIndex=1, Parent=self.Win
        })
        if horiz then
            f.Size=UDim2.new(1,0,0,THICK)
        else
            f.Size=UDim2.new(0,THICK,1,0)
        end
        local g = New("UIGradient", {Rotation=0, Parent=f})
        return f, g
    end

    local topF,topG     = makeSide(true)
    local botF,botG     = makeSide(true)
    local leftF,leftG   = makeSide(false)
    local rightF,rightG = makeSide(false)

    topF.Position  = UDim2.new(0,0,0,0)
    Corner(14, topF)
    botF.AnchorPoint=Vector2.new(0,1)
    botF.Position  = UDim2.new(0,0,1,0)
    Corner(14, botF)
    leftF.Position  = UDim2.new(0,0,0,0)
    rightF.AnchorPoint=Vector2.new(1,0)
    rightF.Position = UDim2.new(1,0,0,0)

    local angle = 0
    local cols = {
        Color3.fromRGB(155,80,255),
        Color3.fromRGB(80,145,255),
        Color3.fromRGB(40,210,255),
        Color3.fromRGB(155,80,255),
    }

    self._neonConn = RunService.RenderStepped:Connect(function(dt)
        if not self.Win.Parent or self.Minimized then return end
        angle = (angle + dt*52) % 360

        local t = (angle/360)*3
        local ci = math.floor(t) % 3 + 1
        local cf = t % 1
        local cA = cols[ci]:Lerp(cols[ci+1], cf)
        local cB = cols[(ci%3)+1]:Lerp(cols[math.min(ci+2,4)], cf)

        local function seq(baseAngle)
            local off = (baseAngle % 360) / 360
            -- Two bright spots travelling around
            local p1 = off % 1
            local p2 = (off + .5) % 1
            -- Sort so keypoints are ascending
            local pts = {
                {0, Color3.new(0,0,0)},
            }
            local function addSpot(p, c)
                local a = math.max(p-.1, 0)
                local b = math.min(p+.1, 1)
                if a > 0 then pts[#pts+1]={a, Color3.new(0,0,0)} end
                pts[#pts+1]={p, c}
                if b < 1 then pts[#pts+1]={b, Color3.new(0,0,0)} end
            end
            if p1 < p2 then
                addSpot(p1, cA); addSpot(p2, cB)
            else
                addSpot(p2, cB); addSpot(p1, cA)
            end
            pts[#pts+1]={1, Color3.new(0,0,0)}
            -- Remove duplicate t values
            table.sort(pts, function(a,b) return a[1]<b[1] end)
            local kps = {}
            local prev = -1
            for _,pt in ipairs(pts) do
                if pt[1] > prev then
                    kps[#kps+1] = ColorSequenceKeypoint.new(pt[1], pt[2])
                    prev = pt[1]
                end
            end
            if kps[1].Time > 0 then
                table.insert(kps,1, ColorSequenceKeypoint.new(0, Color3.new(0,0,0)))
            end
            if kps[#kps].Time < 1 then
                kps[#kps+1] = ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
            end
            return ColorSequence.new(kps)
        end

        topG.Color   = seq(angle)
        botG.Color   = seq(angle+180)
        leftG.Color  = seq(angle+270)
        rightG.Color = seq(angle+90)
        leftG.Rotation  = 90
        rightG.Rotation = 90
    end)
end

-- ─────────────────────────────────────────
--  PROFILE CARD + POPUP
-- ─────────────────────────────────────────
function Window:_buildProfile()
    local C = self.C
    local div = New("Frame", {
        BackgroundColor3=C.SbDiv, BorderSizePixel=0,
        Position=UDim2.new(0,0,1,-80), Size=UDim2.new(1,0,0,1),
        ZIndex=7, Parent=self.Sidebar
    })
    self:_r(div, "BackgroundColor3", "SbDiv")

    local card = New("Frame", {
        BackgroundColor3=C.ProfileBg, BackgroundTransparency=.25, BorderSizePixel=0,
        Position=UDim2.new(0,8,1,-72), Size=UDim2.new(1,-16,0,56),
        ZIndex=8, Parent=self.Sidebar
    })
    Corner(10, card)
    self:_r(card, "BackgroundColor3", "ProfileBg")

    local avF = New("Frame", {
        BackgroundColor3=C.SbActive, BorderSizePixel=0,
        Position=UDim2.new(0,8,.5,-18), Size=UDim2.new(0,36,0,36),
        ZIndex=9, Parent=card
    })
    Corner(100, avF)
    Stroke(avF, C.Accent, 1.5, .45)
    local avImg = New("ImageLabel", {
        BackgroundTransparency=1, Image="",
        Size=UDim2.new(1,0,1,0), ZIndex=10, Parent=avF
    })
    Corner(100, avImg)
    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok then avImg.Image = url end
    end)

    local dnL = New("TextLabel", {
        BackgroundTransparency=1, Text=LocalPlayer.DisplayName,
        TextColor3=C.Text, Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Size=UDim2.new(1,-72,0,14), Position=UDim2.new(0,52,0,10),
        ZIndex=9, Parent=card
    })
    self:_r(dnL, "TextColor3", "Text")
    local unL = New("TextLabel", {
        BackgroundTransparency=1, Text="@"..LocalPlayer.Name,
        TextColor3=C.Sub, Font=Enum.Font.Gotham, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Size=UDim2.new(1,-72,0,12), Position=UDim2.new(0,52,0,27),
        ZIndex=9, Parent=card
    })
    self:_r(unL, "TextColor3", "Sub")

    local dotBtn = New("TextButton", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Text="···", TextColor3=C.SbText,
        Font=Enum.Font.GothamBold, TextSize=14,
        AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-8,.5,0),
        Size=UDim2.new(0,28,0,28),
        AutoButtonColor=false, ZIndex=10, Parent=card
    })
    self:_r(dotBtn, "TextColor3", "SbText")

    local cTi = TweenInfo.new(.18)
    card.MouseEnter:Connect(function()
        Tw(card, cTi, {BackgroundColor3=C.ProfileHov, BackgroundTransparency=.1})
    end)
    card.MouseLeave:Connect(function()
        Tw(card, cTi, {BackgroundColor3=C.ProfileBg, BackgroundTransparency=.25})
    end)

    -- Popup
    local popOpen = false
    local popup = New("Frame", {
        BackgroundColor3=C.PopupBg, BorderSizePixel=0,
        Position=UDim2.new(0,8,1,-82), Size=UDim2.new(1,-16,0,0),
        ClipsDescendants=true, Visible=false, ZIndex=22, Parent=self.Sidebar
    })
    Corner(10, popup)
    Stroke(popup, C.SbDiv, 1, .3)
    self:_r(popup, "BackgroundColor3", "PopupBg")
    New("UIListLayout", {
        Padding=UDim.new(0,2),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=popup
    })
    Pad(popup, 4, 4, 4, 4)

    local function PopItem(ic, lbl, col, fn)
        local item = New("TextButton", {
            BackgroundColor3=C.PopupItem, BackgroundTransparency=.6,
            BorderSizePixel=0, Text="",
            Size=UDim2.new(1,0,0,32), AutoButtonColor=false,
            ZIndex=23, Parent=popup
        })
        Corner(7, item)
        New("TextLabel", {
            BackgroundTransparency=1, Text=ic, TextColor3=col or C.Text,
            Font=Enum.Font.Gotham, TextSize=13,
            Size=UDim2.new(0,24,1,0), Position=UDim2.new(0,8,0,0),
            ZIndex=24, Parent=item
        })
        New("TextLabel", {
            BackgroundTransparency=1, Text=lbl, TextColor3=col or C.Text,
            Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,34,0,0),
            ZIndex=24, Parent=item
        })
        local ti = TweenInfo.new(.12)
        item.MouseEnter:Connect(function() Tw(item,ti,{BackgroundTransparency=0}) end)
        item.MouseLeave:Connect(function() Tw(item,ti,{BackgroundTransparency=.6}) end)
        item.MouseButton1Click:Connect(function()
            popOpen=false
            Tw(popup, TweenInfo.new(.16,Enum.EasingStyle.Quart),
                {Size=UDim2.new(1,-16,0,0)})
            task.delay(.18, function() popup.Visible=false end)
            Click(); fn()
        end)
    end

    local tNames = {"Dark","Light","Ocean"}
    local tIcons = {"🌙","☀","🌊"}
    for i,name in ipairs(tNames) do
        PopItem(tIcons[i], name.." Theme", nil, function()
            self:SetTheme(name)
            self:Notify({Title="Theme",Desc=name.." applied.",Type="info",Dur=2})
        end)
    end
    New("Frame",{BackgroundColor3=C.SbDiv,BorderSizePixel=0,
        Size=UDim2.new(1,-16,0,1),ZIndex=23,Parent=popup})
    PopItem("💾","Save Config",nil,function()
        self:SaveConfig()
        self:Notify({Title="Saved",Desc="Config tersimpan.",Type="success",Dur=2})
    end)
    PopItem("📂","Load Config",nil,function()
        self:LoadConfig()
        self:Notify({Title="Loaded",Desc="Config diload.",Type="success",Dur=2})
    end)
    New("Frame",{BackgroundColor3=C.SbDiv,BorderSizePixel=0,
        Size=UDim2.new(1,-16,0,1),ZIndex=23,Parent=popup})
    PopItem("–","Minimize",nil,function() self:ToggleMinimize() end)
    PopItem("✕","Close GUI",C.Danger,function()
        self:Notify({Title="Closing",Desc="GUI destroyed.",Type="danger",Dur=1})
        task.delay(1.2, function() self:Destroy() end)
    end)

    local popH = 8*34 + 2*5 + 12

    local function closePopup()
        popOpen=false
        Tw(popup, TweenInfo.new(.16,Enum.EasingStyle.Quart),
            {Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,1,-82)})
        task.delay(.18, function() popup.Visible=false end)
    end

    dotBtn.MouseButton1Click:Connect(function()
        Click()
        popOpen = not popOpen
        if popOpen then
            popup.Visible=true
            popup.Position=UDim2.new(0,8,1,-82)
            popup.Size=UDim2.new(1,-16,0,0)
            Tw(popup, TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
                Size=UDim2.new(1,-16,0,popH),
                Position=UDim2.new(0,8,1,-82-popH-4)
            })
        else closePopup() end
    end)
    UserInputService.InputBegan:Connect(function(i)
        if popOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then
            local p=i.Position
            local sA=self.Sidebar.AbsolutePosition
            local sS=self.Sidebar.AbsoluteSize
            if p.X<sA.X or p.X>sA.X+sS.X or p.Y<sA.Y or p.Y>sA.Y+sS.Y then
                closePopup()
            end
        end
    end)
end

-- ─────────────────────────────────────────
--  RESIZE HANDLE
-- ─────────────────────────────────────────
function Window:_buildResize()
    local rh = New("Frame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,0,1,0),
        Size=UDim2.new(0,32,0,32), ZIndex=18, Parent=self.Win
    })
    for i=1,3 do
        New("Frame", {
            BackgroundColor3=self.C.Sub, BackgroundTransparency=.45,
            BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-4,1,-4),
            Size=UDim2.new(0,i*7,0,1.5), Rotation=-45,
            ZIndex=19, Parent=rh
        })
    end
    local dot = New("Frame", {
        BackgroundColor3=self.C.Accent, BackgroundTransparency=.4,
        BorderSizePixel=0, AnchorPoint=Vector2.new(1,1),
        Position=UDim2.new(1,-5,1,-5), Size=UDim2.new(0,5,0,5),
        ZIndex=19, Parent=rh
    })
    Corner(3, dot)
    self:_r(dot, "BackgroundColor3", "Accent")

    local rhBtn = New("TextButton", {
        BackgroundTransparency=1, BorderSizePixel=0, Text="",
        Size=UDim2.new(1,0,1,0), ZIndex=20, AutoButtonColor=false, Parent=rh
    })
    local ti = TweenInfo.new(.15)
    rhBtn.MouseEnter:Connect(function()
        Tw(dot,ti,{BackgroundTransparency=0,Size=UDim2.new(0,7,0,7)})
    end)
    rhBtn.MouseLeave:Connect(function()
        Tw(dot,ti,{BackgroundTransparency=.4,Size=UDim2.new(0,5,0,5)})
    end)

    local resizing,rStart,rW,rH = false,Vector2.new(),0,0
    rhBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            resizing=true
            rStart=Vector2.new(i.Position.X,i.Position.Y)
            rW=self.Win.AbsoluteSize.X; rH=self.Win.AbsoluteSize.Y
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if resizing and not self.Minimized and not self.Maximized and
        (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local d=Vector2.new(i.Position.X,i.Position.Y)-rStart
            self.Win.Size=UDim2.new(0,math.clamp(rW+d.X,520,1200),
                0,math.clamp(rH+d.Y,380,860))
        end
    end)
end

-- ─────────────────────────────────────────
--  SEARCH (global cross-tab)
-- ─────────────────────────────────────────
function Window:_regSearch(label, tab, target)
    table.insert(self._searchIndex, {
        label=label:lower(), display=label, tab=tab, target=target
    })
end

function Window:_updateSearch(query)
    query = query:lower():match("^%s*(.-)%s*$") or ""
    for _,f in ipairs(self._srchItems) do f:Destroy() end
    self._srchItems = {}

    if query == "" then
        self._srchOverlay.Visible = false
        self.SbScroll.Visible = true
        return
    end

    self._srchOverlay.Visible = true
    self.SbScroll.Visible = false

    local results = {}
    for _,e in ipairs(self._searchIndex) do
        if e.label:find(query, 1, true) then results[#results+1]=e end
    end

    if #results == 0 then
        local emp = New("TextLabel", {
            BackgroundTransparency=1, Text="No results",
            TextColor3=self.C.Sub, Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Center,
            Size=UDim2.new(1,0,0,36), ZIndex=16, Parent=self._srchScroll
        })
        self._srchItems={emp}; return
    end

    for _,entry in ipairs(results) do
        local row = New("TextButton", {
            BackgroundColor3=self.C.SbHover, BackgroundTransparency=.6,
            BorderSizePixel=0, Text="",
            Size=UDim2.new(1,0,0,42), AutoButtonColor=false,
            ZIndex=16, Parent=self._srchScroll
        })
        Corner(8, row)
        New("TextLabel", {
            BackgroundTransparency=1, Text=entry.tab.Title,
            TextColor3=self.C.Accent, Font=Enum.Font.GothamBold, TextSize=8,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-8,0,13), Position=UDim2.new(0,8,0,4),
            ZIndex=17, Parent=row
        })
        New("TextLabel", {
            BackgroundTransparency=1, Text=entry.display,
            TextColor3=self.C.Text, Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-8,0,17), Position=UDim2.new(0,8,0,20),
            ZIndex=17, Parent=row
        })
        local ti = TweenInfo.new(.12)
        row.MouseEnter:Connect(function() Tw(row,ti,{BackgroundTransparency=.2}) end)
        row.MouseLeave:Connect(function() Tw(row,ti,{BackgroundTransparency=.6}) end)
        row.MouseButton1Click:Connect(function()
            Click()
            self._srchBox.Text=""
            self:SelectTab(entry.tab)
            if entry.target and entry.target.Parent then
                task.defer(function()
                    local scr = entry.tab.Scroll
                    local relY = entry.target.AbsolutePosition.Y
                        - scr.AbsolutePosition.Y
                        + scr.CanvasPosition.Y
                    Tw(scr, TweenInfo.new(.3,Enum.EasingStyle.Quart),
                        {CanvasPosition=Vector2.new(0, math.max(0,relY-20))})
                end)
            end
        end)
        self._srchItems[#self._srchItems+1] = row
    end
end

-- ─────────────────────────────────────────
--  CREATE TAB
-- ─────────────────────────────────────────
function Window:CreateTab(opts)
    local C   = self.C
    local win = self
    local tab = {Title=opts.Title or "Tab", Icon=opts.Icon or "○", _dropdowns={}}

    tab.Frame = New("Frame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0), Visible=false, ZIndex=3, Parent=self.Content
    })
    tab.Scroll = New("ScrollingFrame", {
        BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,-6,1,0), CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=C.Accent,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ZIndex=3, Parent=tab.Frame
    })
    New("UIListLayout", {
        Padding=UDim.new(0,8),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=tab.Scroll
    })
    Pad(tab.Scroll, 14, 14, 2, 2)

    local idx = #self.Tabs+1
    tab.SideBtn = New("TextButton", {
        BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=1,
        BorderSizePixel=0, Size=UDim2.new(1,0,0,42),
        Text="", AutoButtonColor=false,
        ZIndex=8, LayoutOrder=idx, Parent=self.SbScroll
    })
    Corner(9, tab.SideBtn)
    self:_r(tab.SideBtn, "BackgroundColor3", "SbActive")

    tab.Indicator = New("Frame", {
        BackgroundColor3=C.Accent, BorderSizePixel=0,
        Position=UDim2.new(0,0,.5,-12), Size=UDim2.new(0,3,0,24),
        ZIndex=9, Visible=false, Parent=tab.SideBtn
    })
    Corner(3, tab.Indicator)
    self:_r(tab.Indicator, "BackgroundColor3", "Accent")

    tab.IcoLbl = New("TextLabel", {
        BackgroundTransparency=1, Text=tab.Icon,
        TextColor3=C.SbText, Font=Enum.Font.Gotham, TextSize=16,
        Size=UDim2.new(0,26,1,0), Position=UDim2.new(0,14,0,0),
        ZIndex=9, Parent=tab.SideBtn
    })
    self:_r(tab.IcoLbl, "TextColor3", "SbText")

    tab.TxtLbl = New("TextLabel", {
        BackgroundTransparency=1, Text=tab.Title,
        TextColor3=C.SbText, Font=Enum.Font.Gotham, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,40,0,0),
        ZIndex=9, Parent=tab.SideBtn
    })
    self:_r(tab.TxtLbl, "TextColor3", "SbText")

    tab._badge = New("Frame", {
        BackgroundColor3=C.Danger, BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-10,.5,0),
        Size=UDim2.new(0,18,0,18), ZIndex=10, Visible=false, Parent=tab.SideBtn
    })
    Corner(9, tab._badge)
    tab._badgeLbl = New("TextLabel", {
        BackgroundTransparency=1, Text="0", TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold, TextSize=9,
        Size=UDim2.new(1,0,1,0), ZIndex=11, Parent=tab._badge
    })

    local hTi = TweenInfo.new(.18)
    tab.SideBtn.MouseEnter:Connect(function()
        if win.ActiveTab~=tab then
            Tw(tab.SideBtn,hTi,{BackgroundTransparency=0,BackgroundColor3=win.C.SbHover})
        end
    end)
    tab.SideBtn.MouseLeave:Connect(function()
        if win.ActiveTab~=tab then Tw(tab.SideBtn,hTi,{BackgroundTransparency=1}) end
    end)
    tab.SideBtn.MouseButton1Click:Connect(function() Click(); win:SelectTab(tab) end)

    -- ── HELPERS ──

    -- Card: visual container (nama kiri, kontrol kanan)
    local function Row(lbl, h, parent)
        local f = New("Frame", {
            BackgroundColor3=win.C.Card, BorderSizePixel=0,
            Size=UDim2.new(.97,0,0,h or 44), ZIndex=4,
            Parent=parent or tab.Scroll
        })
        Corner(10, f)
        local fs = Stroke(f, win.C.CardStroke, 1, .45)
        win:_r(f, "BackgroundColor3", "Card")
        win:_r(fs, "Color", "CardStroke")
        local label = New("TextLabel", {
            BackgroundTransparency=1, Text=lbl,
            TextColor3=win.C.Label, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(.48,0,1,0), Position=UDim2.new(0,12,0,0),
            ZIndex=5, Parent=f
        })
        win:_r(label, "TextColor3", "Label")
        local right = New("Frame", {
            BackgroundTransparency=1, BorderSizePixel=0,
            Size=UDim2.new(.52,-8,1,0), Position=UDim2.new(.48,0,0,0),
            ZIndex=5, Parent=f
        })
        return f, right
    end

    -- ── SECTION ──
    function tab:CreateSection(title)
        local sec = {}
        sec.Frame = New("Frame", {
            BackgroundColor3=win.C.Card, BorderSizePixel=0,
            Size=UDim2.new(.97,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            ZIndex=4, Parent=tab.Scroll
        })
        Corner(10, sec.Frame)
        local ss = Stroke(sec.Frame, win.C.CardStroke, 1, .4)
        win:_r(sec.Frame, "BackgroundColor3", "Card")
        win:_r(ss, "Color", "CardStroke")
        local hdr = New("Frame", {
            BackgroundTransparency=1, Size=UDim2.new(1,0,0,28), ZIndex=5, Parent=sec.Frame
        })
        local ht = New("TextLabel", {
            BackgroundTransparency=1, Text=title:upper(),
            TextColor3=win.C.Sub, Font=Enum.Font.GothamBold, TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,12,0,0),
            ZIndex=5, Parent=hdr
        })
        win:_r(ht, "TextColor3", "Sub")
        local hd = New("Frame", {
            BackgroundColor3=win.C.CardStroke, BorderSizePixel=0,
            Position=UDim2.new(0,12,1,-1), Size=UDim2.new(1,-24,0,1),
            ZIndex=5, Parent=hdr
        })
        win:_r(hd, "BackgroundColor3", "CardStroke")
        sec.List = New("UIListLayout", {
            Padding=UDim.new(0,0),
            FillDirection=Enum.FillDirection.Vertical,
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder, Parent=sec.Frame
        })
        Pad(sec.Frame, 28, 6, 8, 8)
        sec.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sec.Frame.Size=UDim2.new(.97,0,0,sec.List.AbsoluteContentSize.Y+38)
        end)
        return sec
    end

    -- ── BUTTON — nama kiri, tombol kecil kanan ──
    function tab:CreateButton(label, callback, style, tooltip)
        style = style or "primary"
        local bgCol = style=="danger"    and win.C.BtnDanger
                   or style=="secondary" and win.C.BtnSecondary
                   or win.C.BtnPrimary
        local txCol = style=="secondary" and win.C.Text or Color3.new(1,1,1)

        local f, right = Row(label, 44)

        local btn = New("TextButton", {
            BackgroundColor3=bgCol, BorderSizePixel=0,
            Text=label, TextColor3=txCol,
            Font=Enum.Font.GothamBold, TextSize=11,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0),
            Size=UDim2.new(.88,0,0,30),
            AutoButtonColor=false, ZIndex=5, Parent=right
        })
        Corner(8, btn)
        if style=="secondary" then Stroke(btn, win.C.CardStroke, 1, .4) end
        Ripple(btn, style=="secondary" and win.C.Label or Color3.new(1,1,1))

        local ti = TweenInfo.new(.15)
        btn.MouseEnter:Connect(function()
            Tw(btn, ti, {BackgroundColor3=bgCol:Lerp(Color3.new(1,1,1),.12)})
        end)
        btn.MouseLeave:Connect(function() Tw(btn, ti, {BackgroundColor3=bgCol}) end)
        btn.MouseButton1Click:Connect(function()
            Click(); if callback then callback() end
        end)

        win:_r(btn, "BackgroundColor3",
            style=="danger" and "BtnDanger" or style=="secondary" and "BtnSecondary" or "BtnPrimary")
        if style=="secondary" then win:_r(btn, "TextColor3", "Text") end
        win:_regSearch(label, tab, f)
        return btn
    end

    -- ── TOGGLE ──
    function tab:CreateToggle(o)
        local en   = o.Default  or false
        local cb   = o.Callback or function() end
        local cKey = o.ConfigKey
        local f, right = Row(o.Title or "Toggle")

        local track = New("Frame", {
            BackgroundColor3=en and win.C.ToggleOn or win.C.ToggleOff,
            BorderSizePixel=0, AnchorPoint=Vector2.new(1,.5),
            Position=UDim2.new(1,-6,.5,0), Size=UDim2.new(0,46,0,24),
            ZIndex=5, Parent=right
        })
        Corner(12, track)
        local knob = New("Frame", {
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,.5),
            Position=en and UDim2.new(1,-22,.5,0) or UDim2.new(0,2,.5,0),
            Size=UDim2.new(0,20,0,20), ZIndex=6, Parent=track
        })
        Corner(10, knob)
        Shadow(knob, 8, .65)

        local ti = TweenInfo.new(.22, Enum.EasingStyle.Quart)
        local function ref()
            Tw(track, ti, {BackgroundColor3=en and win.C.ToggleOn or win.C.ToggleOff})
            Tw(knob,  ti, {Position=en and UDim2.new(1,-22,.5,0) or UDim2.new(0,2,.5,0)})
            cb(en)
            if cKey then win._cfg[cKey]=en end
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                Click(); en=not en; ref()
            end
        end)
        local api = {Set=function(v) en=v; ref() end, Get=function() return en end}
        if cKey then win._cfgCb[cKey]=function(v) api.Set(v) end end
        win:_regSearch(o.Title or "Toggle", tab, f)
        return api
    end

    -- ── SLIDER ──
    function tab:CreateSlider(o)
        local mn = o.Min or 0; local mx = o.Max or 100
        local val= math.clamp(o.Default or mn, mn, mx)
        local cb = o.Callback or function() end
        local sfx= o.Suffix or ""; local cKey=o.ConfigKey

        local crd = New("Frame", {
            BackgroundColor3=win.C.Card, BorderSizePixel=0,
            Size=UDim2.new(.97,0,0,54), ZIndex=4, Parent=tab.Scroll
        })
        Corner(10, crd)
        local cs = Stroke(crd, win.C.CardStroke, 1, .45)
        win:_r(crd,"BackgroundColor3","Card"); win:_r(cs,"Color","CardStroke")

        local tl = New("TextLabel", {
            BackgroundTransparency=1, Text=o.Title or "Slider",
            TextColor3=win.C.Label, Font=Enum.Font.Gotham, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(.7,0,0,20), Position=UDim2.new(0,12,0,5), ZIndex=5, Parent=crd
        })
        win:_r(tl,"TextColor3","Label")
        local vl = New("TextLabel", {
            BackgroundTransparency=1, Text=tostring(val)..sfx,
            TextColor3=win.C.Accent, Font=Enum.Font.GothamBold, TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Right,
            Size=UDim2.new(.3,-10,0,20), Position=UDim2.new(.7,0,0,5), ZIndex=5, Parent=crd
        })
        win:_r(vl,"TextColor3","Accent")
        local trk = New("Frame", {
            BackgroundColor3=win.C.Track, BorderSizePixel=0,
            Position=UDim2.new(0,12,0,33), Size=UDim2.new(1,-24,0,5),
            ZIndex=5, Parent=crd
        })
        Corner(3, trk); win:_r(trk,"BackgroundColor3","Track")
        local pct = (val-mn)/(mx-mn)
        local fill = New("Frame", {
            BackgroundColor3=win.C.Fill, BorderSizePixel=0,
            Size=UDim2.new(pct,0,1,0), ZIndex=6, Parent=trk
        })
        Corner(3, fill); win:_r(fill,"BackgroundColor3","Fill")
        local thumb = New("TextButton", {
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
            AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(pct,0,.5,0),
            Size=UDim2.new(0,14,0,14), Text="", AutoButtonColor=false,
            ZIndex=7, Parent=trk
        })
        Corner(7, thumb); Shadow(thumb,10,.6)

        local function setV(p)
            p=math.clamp(p,0,1)
            val=math.floor(mn+(mx-mn)*p+.5)
            vl.Text=tostring(val)..sfx
            fill.Size=UDim2.new(p,0,1,0)
            thumb.Position=UDim2.new(p,0,.5,0)
            cb(val)
            if cKey then win._cfg[cKey]=val end
        end
        local dragging=false
        local function mv(i) setV((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X) end
        trk.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=true; mv(i) end
        end)
        thumb.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then mv(i) end
        end)
        local api={Set=function(v) setV(math.clamp((v-mn)/(mx-mn),0,1)) end,Get=function() return val end}
        if cKey then win._cfgCb[cKey]=function(v) api.Set(v) end end
        win:_regSearch(o.Title or "Slider", tab, crd)
        return api
    end

    -- ── DROPDOWN — fixed size, scrollable ──
    function tab:CreateDropdown(o)
        local items = o.Items or {}
        local sel   = o.Default or (items[1] or "Select...")
        local cb    = o.Callback or function() end
        local cKey  = o.ConfigKey
        local ITEM_H= 32
        local MAX_H = 200
        local listH = math.min(#items*ITEM_H+8, MAX_H)

        local f, right = Row(o.Title or "Dropdown")

        local selBg = New("Frame", {
            BackgroundColor3=win.C.InputBg, BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-4,.5,0),
            Size=UDim2.new(.88,0,0,30), ZIndex=5, Parent=right
        })
        Corner(7, selBg)
        Stroke(selBg, win.C.CardStroke, 1, .4)
        win:_r(selBg,"BackgroundColor3","InputBg")

        local selLbl = New("TextLabel", {
            BackgroundTransparency=1, Text=sel,
            TextColor3=win.C.Text, Font=Enum.Font.GothamBold, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,
            Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,8,0,0),
            ZIndex=6, Parent=selBg
        })
        win:_r(selLbl,"TextColor3","Text")

        local arw = New("TextLabel", {
            BackgroundTransparency=1, Text="▾",
            TextColor3=win.C.Sub, Font=Enum.Font.GothamBold, TextSize=11,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-6,.5,0),
            Size=UDim2.new(0,14,1,0), ZIndex=6, Parent=selBg
        })
        win:_r(arw,"TextColor3","Sub")

        local hitBtn = New("TextButton", {
            BackgroundTransparency=1, BorderSizePixel=0, Text="",
            Size=UDim2.new(1,0,1,0), ZIndex=7, AutoButtonColor=false, Parent=selBg
        })

        -- List frame parented to Gui (not scroll) — never clipped
        local list = New("Frame", {
            BackgroundColor3=win.C.DdBg, BorderSizePixel=0,
            Size=UDim2.new(0,0,0,listH), Visible=false, ZIndex=52, Parent=win.Gui
        })
        Corner(9, list)
        Stroke(list, win.C.CardStroke, 1, .3)
        Shadow(list, 20, .55)
        win:_r(list,"BackgroundColor3","DdBg")

        local listScroll = New("ScrollingFrame", {
            BackgroundTransparency=1, BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollBarThickness=#items*ITEM_H>MAX_H and 3 or 0,
            ScrollBarImageColor3=win.C.Accent,
            ScrollingDirection=Enum.ScrollingDirection.Y,
            ZIndex=53, Parent=list
        })
        New("UIListLayout", {
            Padding=UDim.new(0,2),
            FillDirection=Enum.FillDirection.Vertical,
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder,
            Parent=listScroll
        })
        Pad(listScroll, 4, 4, 4, 4)

        local ddOpen = false
        table.insert(tab._dropdowns, function()
            if ddOpen then
                ddOpen=false; list.Visible=false
                Tw(arw, TweenInfo.new(.14), {Rotation=0})
            end
        end)

        local function buildItems()
            for _,c in pairs(listScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _,item in ipairs(items) do
                local ib = New("TextButton", {
                    BackgroundColor3=win.C.DdItem, BackgroundTransparency=.5,
                    BorderSizePixel=0, Text=item,
                    TextColor3=win.C.Text, Font=Enum.Font.Gotham, TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Size=UDim2.new(1,0,0,ITEM_H), AutoButtonColor=false,
                    ZIndex=54, Parent=listScroll
                })
                Corner(6, ib)
                Pad(ib,0,0,8,8)
                win:_r(ib,"BackgroundColor3","DdItem"); win:_r(ib,"TextColor3","Text")
                local ti=TweenInfo.new(.12)
                ib.MouseEnter:Connect(function() Tw(ib,ti,{BackgroundTransparency=0}) end)
                ib.MouseLeave:Connect(function() Tw(ib,ti,{BackgroundTransparency=.5}) end)
                ib.MouseButton1Click:Connect(function()
                    Click()
                    sel=item; selLbl.Text=item
                    ddOpen=false
                    Tw(list,TweenInfo.new(.14,Enum.EasingStyle.Quart),
                        {Size=UDim2.new(0,list.AbsoluteSize.X,0,0)})
                    task.delay(.15,function() list.Visible=false end)
                    Tw(arw,TweenInfo.new(.14),{Rotation=0})
                    cb(item)
                    if cKey then win._cfg[cKey]=item end
                end)
            end
        end
        buildItems()

        local function openList()
            local abs=selBg.AbsolutePosition; local sz=selBg.AbsoluteSize
            local scrH=win.Gui.AbsoluteSize.Y; local scrW=win.Gui.AbsoluteSize.X
            local lW=math.max(sz.X,180)
            local posY
            if abs.Y+sz.Y+listH+6>scrH then posY=abs.Y-listH-4
            else posY=abs.Y+sz.Y+4 end
            local posX=math.min(abs.X, scrW-lW-4)
            list.Size=UDim2.new(0,lW,0,0)
            list.Position=UDim2.new(0,posX,0,posY)
            list.Visible=true
            Tw(list,TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
                {Size=UDim2.new(0,lW,0,listH)})
            Tw(arw,TweenInfo.new(.14),{Rotation=180})
        end

        local function closeList()
            Tw(list,TweenInfo.new(.14,Enum.EasingStyle.Quart),
                {Size=UDim2.new(0,list.AbsoluteSize.X,0,0)})
            task.delay(.15,function() list.Visible=false end)
            Tw(arw,TweenInfo.new(.14),{Rotation=0})
        end

        hitBtn.MouseButton1Click:Connect(function()
            Click(); ddOpen=not ddOpen
            if ddOpen then openList() else closeList() end
        end)
        UserInputService.InputBegan:Connect(function(i)
            if ddOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then
                local p=i.Position
                local lA=list.AbsolutePosition; local lS=list.AbsoluteSize
                local sA=selBg.AbsolutePosition; local sS=selBg.AbsoluteSize
                local inL=p.X>=lA.X and p.X<=lA.X+lS.X and p.Y>=lA.Y and p.Y<=lA.Y+lS.Y
                local inS=p.X>=sA.X and p.X<=sA.X+sS.X and p.Y>=sA.Y and p.Y<=sA.Y+sS.Y
                if not inL and not inS then ddOpen=false; closeList() end
            end
        end)

        local api={
            Set=function(v) sel=v; selLbl.Text=v end,
            Get=function() return sel end,
            SetItems=function(newItems)
                items=newItems
                listH=math.min(#items*ITEM_H+8,MAX_H)
                listScroll.ScrollBarThickness=#items*ITEM_H>MAX_H and 3 or 0
                buildItems()
            end,
        }
        if cKey then win._cfgCb[cKey]=function(v) api.Set(v) end end
        win:_regSearch(o.Title or "Dropdown", tab, f)
        return api
    end

    -- ── INPUT ──
    function tab:CreateInput(o)
        local cb=o.Callback or function() end
        local och=o.OnChanged or function() end
        local cKey=o.ConfigKey
        local f,right = Row(o.Title or "Input")
        local ib = New("TextBox", {
            BackgroundColor3=win.C.InputBg, BorderSizePixel=0,
            PlaceholderText=o.Placeholder or "Type here...",
            PlaceholderColor3=win.C.Sub, Text=o.Default or "",
            TextColor3=win.C.Text, Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,
            ClearTextOnFocus=o.ClearOnFocus or false,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-4,.5,0),
            Size=UDim2.new(.88,0,0,28), ZIndex=5, Parent=right
        })
        Corner(7, ib)
        Pad(ib,0,0,8,8)
        Stroke(ib, win.C.CardStroke, 1, .45)
        win:_r(ib,"BackgroundColor3","InputBg")
        win:_r(ib,"TextColor3","Text")
        win:_r(ib,"PlaceholderColor3","Sub")
        ib.FocusLost:Connect(function(enter)
            if enter then cb(ib.Text) end
            if cKey then win._cfg[cKey]=ib.Text end
        end)
        ib:GetPropertyChangedSignal("Text"):Connect(function() och(ib.Text) end)
        local api={Get=function() return ib.Text end,Set=function(v) ib.Text=v end}
        if cKey then win._cfgCb[cKey]=function(v) api.Set(v) end end
        win:_regSearch(o.Title or "Input", tab, f)
        return api
    end

    -- ── LABEL ──
    function tab:CreateLabel(text, col)
        local lbl = New("TextLabel", {
            BackgroundTransparency=1, Text=text,
            TextColor3=col or win.C.Sub, Font=Enum.Font.Gotham, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(.97,0,0,22), ZIndex=4, Parent=tab.Scroll
        })
        Pad(lbl,0,0,14,4)
        win:_regSearch(text, tab, lbl)
        return {Set=function(v) lbl.Text=v end,SetColor=function(c) lbl.TextColor3=c end}
    end

    -- ── SEPARATOR ──
    function tab:CreateSeparator(lbl)
        local sep = New("Frame", {
            BackgroundTransparency=1, Size=UDim2.new(.97,0,0,20),
            ZIndex=4, Parent=tab.Scroll
        })
        local hasL = lbl and lbl~=""
        if hasL then
            local lt = New("TextLabel", {
                BackgroundTransparency=1, Text=lbl,
                TextColor3=win.C.Sub, Font=Enum.Font.GothamBold, TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Center,
                Size=UDim2.new(.3,0,1,0), Position=UDim2.new(.35,0,0,0),
                ZIndex=4, Parent=sep
            })
            win:_r(lt,"TextColor3","Sub")
        end
        local function ln(px,pw)
            local l = New("Frame", {
                BackgroundColor3=win.C.Stroke, BorderSizePixel=0,
                AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(px,0,.5,0),
                Size=UDim2.new(pw,0,0,1), ZIndex=4, Parent=sep
            })
            win:_r(l,"BackgroundColor3","Stroke")
        end
        if hasL then ln(0,.33); ln(.67,.33) else ln(0,1) end
    end

    -- ── KEYBIND ──
    function tab:CreateKeybind(o)
        local key=o.Default; local cb=o.Callback or function() end
        local f,right = Row(o.Title or "Keybind")
        local kbBtn = New("TextButton", {
            BackgroundColor3=win.C.BtnSecondary, BorderSizePixel=0,
            Text=key and key.Name or "None",
            TextColor3=win.C.Accent, Font=Enum.Font.GothamBold, TextSize=11,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-4,.5,0),
            Size=UDim2.new(0,90,0,28), AutoButtonColor=false, ZIndex=5, Parent=right
        })
        Corner(7, kbBtn)
        Stroke(kbBtn, win.C.CardStroke, 1, .4)
        win:_r(kbBtn,"BackgroundColor3","BtnSecondary")
        win:_r(kbBtn,"TextColor3","Accent")

        local listening=false
        kbBtn.MouseButton1Click:Connect(function()
            if listening then return end
            Click(); listening=true
            kbBtn.Text="..."; kbBtn.TextColor3=win.C.Warning
            local conn
            conn=UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; kbBtn.Text=key.Name; kbBtn.TextColor3=win.C.Accent
                    listening=false; conn:Disconnect(); cb(key)
                end
            end)
            task.delay(5,function()
                if listening then
                    listening=false; kbBtn.Text=key and key.Name or "None"
                    kbBtn.TextColor3=win.C.Accent
                    if conn then conn:Disconnect() end
                end
            end)
        end)
        win:_regSearch(o.Title or "Keybind", tab, f)
        return {GetKey=function() return key end,SetKey=function(k) key=k; kbBtn.Text=k.Name end}
    end

    -- ── COLOR PICKER ──
    function tab:CreateColorPicker(o)
        local initColor=o.Default or Color3.fromRGB(108,122,255)
        local cb=o.Callback or function() end
        local current=initColor
        local f,right = Row(o.Title or "Color")

        local swatch = New("Frame", {
            BackgroundColor3=current, BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-36,.5,0),
            Size=UDim2.new(0,26,0,26), ZIndex=5, Parent=right
        })
        Corner(7, swatch)
        Stroke(swatch, win.C.CardStroke, 1, .4)

        local openBtn = New("TextButton", {
            BackgroundColor3=win.C.BtnSecondary, BorderSizePixel=0,
            Text="▾", TextColor3=win.C.Sub,
            Font=Enum.Font.GothamBold, TextSize=11,
            AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-4,.5,0),
            Size=UDim2.new(0,26,0,26),
            AutoButtonColor=false, ZIndex=5, Parent=right
        })
        Corner(7, openBtn)
        Stroke(openBtn, win.C.CardStroke, 1, .4)
        win:_r(openBtn,"BackgroundColor3","BtnSecondary")

        openBtn.MouseButton1Click:Connect(function()
            Click()
            win._cp.UpdateTheme(win.C)
            win._cp.Open(current, function(c)
                current=c; swatch.BackgroundColor3=c; cb(c)
            end)
        end)
        win:_regSearch(o.Title or "Color", tab, f)
        return {
            GetColor=function() return current end,
            SetColor=function(c) current=c; swatch.BackgroundColor3=c end,
        }
    end

    -- ── PROGRESS BAR ──
    function tab:CreateProgressBar(o)
        local val=math.clamp(o.Default or 0,0,100)
        local sfx=o.Suffix or "%"
        local crd = New("Frame", {
            BackgroundColor3=win.C.Card, BorderSizePixel=0,
            Size=UDim2.new(.97,0,0,50), ZIndex=4, Parent=tab.Scroll
        })
        Corner(10, crd)
        local cs=Stroke(crd,win.C.CardStroke,1,.45)
        win:_r(crd,"BackgroundColor3","Card"); win:_r(cs,"Color","CardStroke")

        local tl=New("TextLabel",{BackgroundTransparency=1,Text=o.Title or "Progress",
            TextColor3=win.C.Label,Font=Enum.Font.Gotham,TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(.7,0,0,20),Position=UDim2.new(0,12,0,5),ZIndex=5,Parent=crd})
        win:_r(tl,"TextColor3","Label")
        local vl=New("TextLabel",{BackgroundTransparency=1,Text=tostring(val)..sfx,
            TextColor3=win.C.Accent,Font=Enum.Font.GothamBold,TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Right,
            Size=UDim2.new(.3,-10,0,20),Position=UDim2.new(.7,0,0,5),ZIndex=5,Parent=crd})
        win:_r(vl,"TextColor3","Accent")
        local trk=New("Frame",{BackgroundColor3=win.C.ProgBg,BorderSizePixel=0,
            Position=UDim2.new(0,12,0,32),Size=UDim2.new(1,-24,0,8),ZIndex=5,Parent=crd})
        Corner(4,trk); win:_r(trk,"BackgroundColor3","ProgBg")
        local fill=New("Frame",{BackgroundColor3=win.C.Fill,BorderSizePixel=0,
            Size=UDim2.new(val/100,0,1,0),ZIndex=6,Parent=trk})
        Corner(4,fill); win:_r(fill,"BackgroundColor3","Fill")

        local function setV(nv,anim)
            val=math.clamp(nv,0,100); vl.Text=tostring(val)..sfx
            if anim~=false then
                Tw(fill,TweenInfo.new(.35,Enum.EasingStyle.Quart),{Size=UDim2.new(val/100,0,1,0)})
            else fill.Size=UDim2.new(val/100,0,1,0) end
        end
        win:_regSearch(o.Title or "Progress", tab, crd)
        return {
            Set=setV, Get=function() return val end,
            Animate=function(fr,to,dur2)
                setV(fr,false)
                task.delay(.05,function()
                    Tw(fill,TweenInfo.new(dur2 or 1,Enum.EasingStyle.Quart),
                        {Size=UDim2.new(to/100,0,1,0)})
                    vl.Text=tostring(to)..sfx
                end)
            end,
        }
    end

    -- ── TOGGLE GROUP ──
    function tab:CreateToggleGroup(o)
        local items=o.Items or {}; local cur=o.Default or items[1]
        local cb=o.Callback or function() end; local cKey=o.ConfigKey

        local crd=New("Frame",{BackgroundColor3=win.C.Card,BorderSizePixel=0,
            Size=UDim2.new(.97,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            ZIndex=4,Parent=tab.Scroll})
        Corner(10,crd)
        local cs=Stroke(crd,win.C.CardStroke,1,.45)
        win:_r(crd,"BackgroundColor3","Card"); win:_r(cs,"Color","CardStroke")

        local ht=New("TextLabel",{BackgroundTransparency=1,Text=(o.Title or "Select"):upper(),
            TextColor3=win.C.Sub,Font=Enum.Font.GothamBold,TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,-20,0,26),Position=UDim2.new(0,12,0,0),ZIndex=5,Parent=crd})
        win:_r(ht,"TextColor3","Sub")
        local hd=New("Frame",{BackgroundColor3=win.C.CardStroke,BorderSizePixel=0,
            Position=UDim2.new(0,12,0,25),Size=UDim2.new(1,-24,0,1),ZIndex=5,Parent=crd})
        win:_r(hd,"BackgroundColor3","CardStroke")

        local layout=New("UIListLayout",{Padding=UDim.new(0,2),
            FillDirection=Enum.FillDirection.Vertical,
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder,Parent=crd})
        Pad(crd,28,6,8,8)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            crd.Size=UDim2.new(.97,0,0,layout.AbsoluteContentSize.Y+38)
        end)

        local btns={}
        local function refreshBtns()
            for _,e in ipairs(btns) do
                local active=e.val==cur
                Tw(e.f,TweenInfo.new(.18),{
                    BackgroundColor3=active and win.C.Accent or win.C.Card,
                    BackgroundTransparency=active and 0 or .6})
                e.lbl.TextColor3=active and Color3.new(1,1,1) or win.C.Text
                e.dot.BackgroundColor3=active and Color3.new(1,1,1) or win.C.Sub
            end
        end
        for _,item in ipairs(items) do
            local row=New("TextButton",{BackgroundColor3=win.C.Card,
                BackgroundTransparency=.6,BorderSizePixel=0,Text="",
                Size=UDim2.new(1,0,0,36),AutoButtonColor=false,ZIndex=5,Parent=crd})
            Corner(7,row)
            local dot=New("Frame",{BackgroundColor3=item==cur and Color3.new(1,1,1) or win.C.Sub,
                BorderSizePixel=0,AnchorPoint=Vector2.new(0,.5),
                Position=UDim2.new(0,10,.5,0),Size=UDim2.new(0,8,0,8),ZIndex=6,Parent=row})
            Corner(100,dot)
            local lbl=New("TextLabel",{BackgroundTransparency=1,Text=item,
                TextColor3=item==cur and Color3.new(1,1,1) or win.C.Text,
                Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
                Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,26,0,0),ZIndex=6,Parent=row})
            if item==cur then row.BackgroundTransparency=0; row.BackgroundColor3=win.C.Accent end
            table.insert(btns,{f=row,lbl=lbl,dot=dot,val=item})
            row.MouseButton1Click:Connect(function()
                Click(); cur=item; refreshBtns(); cb(item)
                if cKey then win._cfg[cKey]=item end
            end)
        end
        local api={Get=function() return cur end,Set=function(v) cur=v; refreshBtns() end}
        if cKey then win._cfgCb[cKey]=function(v) api.Set(v) end end
        win:_regSearch(o.Title or "Select", tab, crd)
        return api
    end

    -- ── ACCENT PICKER ──
    function tab:CreateAccentPicker(o)
        o = o or {}
        local cb=o.Callback or function() end
        local f,right = Row(o.Title or "Accent Color")
        local presets={
            Color3.fromRGB(108,122,255),Color3.fromRGB(62,192,222),
            Color3.fromRGB(255,100,120),Color3.fromRGB(50,215,115),
            Color3.fromRGB(255,165,50), Color3.fromRGB(185,75,255),
        }
        local SW=20; local GAP=5
        for i,col in ipairs(presets) do
            local sw=New("TextButton",{BackgroundColor3=col,BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,.5),
                Position=UDim2.new(1,-4-(#presets-i)*(SW+GAP),.5,0),
                Size=UDim2.new(0,SW,0,SW),Text="",AutoButtonColor=false,
                ZIndex=5,Parent=right})
            Corner(100,sw)
            Ripple(sw,Color3.new(1,1,1))
            sw.MouseButton1Click:Connect(function()
                Click(); win:SetAccentColor(col); cb(col)
            end)
        end
        win:_regSearch(o.Title or "Accent Color", tab, f)
    end

    self.Tabs[#self.Tabs+1] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

-- ─────────────────────────────────────────
--  SELECT TAB
-- ─────────────────────────────────────────
function Window:SelectTab(tab)
    local ti = TweenInfo.new(.18)
    if self.ActiveTab and self.ActiveTab._dropdowns then
        for _,fn in ipairs(self.ActiveTab._dropdowns) do pcall(fn) end
    end
    if self.ActiveTab and self.ActiveTab ~= tab then
        local p=self.ActiveTab
        p.Frame.Visible=false; p.Indicator.Visible=false
        Tw(p.SideBtn,ti,{BackgroundTransparency=1})
        Tw(p.TxtLbl,ti,{TextColor3=self.C.SbText})
        Tw(p.IcoLbl,ti,{TextColor3=self.C.SbText})
    end
    tab.Frame.Visible=true; tab.Indicator.Visible=true
    Tw(tab.SideBtn,ti,{BackgroundTransparency=0,BackgroundColor3=self.C.SbActive})
    Tw(tab.TxtLbl,ti,{TextColor3=self.C.SbActiveTxt})
    Tw(tab.IcoLbl,ti,{TextColor3=self.C.Accent})
    self.ActiveTab=tab
end

-- ─────────────────────────────────────────
--  SET THEME
-- ─────────────────────────────────────────
function Window:SetTheme(name)
    if not T[name] then return end
    self.Theme=name; self.C=T[name]
    local C=self.C
    local ti=TweenInfo.new(.3,Enum.EasingStyle.Quart)
    for _,e in ipairs(self._reg) do
        if e.key and C[e.key] and e.obj and e.obj.Parent then
            pcall(function() Tw(e.obj,ti,{[e.prop]=C[e.key]}) end)
        end
    end
    self.SbScroll.ScrollBarImageColor3=C.Accent
    if self.ActiveTab then
        self.ActiveTab.SideBtn.BackgroundColor3=C.SbActive
        self.ActiveTab.TxtLbl.TextColor3=C.SbActiveTxt
        self.ActiveTab.IcoLbl.TextColor3=C.Accent
        self.ActiveTab.Indicator.BackgroundColor3=C.Accent
    end
    self._cp.UpdateTheme(C)
end

-- ─────────────────────────────────────────
--  SET ACCENT COLOR
-- ─────────────────────────────────────────
function Window:SetAccentColor(col)
    local keys={"Accent","Fill","BtnPrimary"}
    local ti=TweenInfo.new(.3,Enum.EasingStyle.Quart)
    for _,k in ipairs(keys) do self.C[k]=col end
    for _,e in ipairs(self._reg) do
        for _,k in ipairs(keys) do
            if e.key==k and e.obj and e.obj.Parent then
                pcall(function() Tw(e.obj,ti,{[e.prop]=col}) end)
            end
        end
    end
    self.SbScroll.ScrollBarImageColor3=col
    if self.ActiveTab then
        self.ActiveTab.Indicator.BackgroundColor3=col
        self.ActiveTab.IcoLbl.TextColor3=col
    end
end

-- ─────────────────────────────────────────
--  BADGE
-- ─────────────────────────────────────────
function Window:SetTabBadge(tab, count)
    if count and count>0 then
        tab._badge.Visible=true
        tab._badgeLbl.Text=tostring(math.min(count,99))
        tab._badge.Size=count>9 and UDim2.new(0,24,0,18) or UDim2.new(0,18,0,18)
    else tab._badge.Visible=false end
end

-- ─────────────────────────────────────────
--  CONFIRM DIALOG
-- ─────────────────────────────────────────
function Window:ConfirmDialog(opts)
    local C=self.C
    local overlay=New("Frame",{BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=.55,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ZIndex=82,Parent=self.WinInner})
    local dlg=New("Frame",{BackgroundColor3=C.Card,BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,12),
        Size=UDim2.new(0,330,0,152),ZIndex=83,Parent=self.WinInner})
    Corner(14,dlg)
    Stroke(dlg,C.CardStroke,1,.3)
    Shadow(dlg,40,.42)
    New("TextLabel",{BackgroundTransparency=1,Text=opts.Title or "Confirm",
        TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,-24,0,22),Position=UDim2.new(0,16,0,16),ZIndex=84,Parent=dlg})
    New("TextLabel",{BackgroundTransparency=1,Text=opts.Message or "Are you sure?",
        TextColor3=C.Sub,Font=Enum.Font.Gotham,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
        Size=UDim2.new(1,-24,0,48),Position=UDim2.new(0,16,0,44),ZIndex=84,Parent=dlg})
    New("Frame",{BackgroundColor3=C.CardStroke,BorderSizePixel=0,
        Position=UDim2.new(0,0,0,104),Size=UDim2.new(1,0,0,1),ZIndex=84,Parent=dlg})
    New("Frame",{BackgroundColor3=C.CardStroke,BorderSizePixel=0,
        Position=UDim2.new(.5,-1,0,104),Size=UDim2.new(0,1,0,48),ZIndex=84,Parent=dlg})

    local function close()
        Tw(overlay,TweenInfo.new(.18,Enum.EasingStyle.Quart),{BackgroundTransparency=1})
        Tw(dlg,TweenInfo.new(.18,Enum.EasingStyle.Quart),
            {BackgroundTransparency=1,Position=UDim2.new(.5,0,.5,20)})
        task.delay(.2,function() overlay:Destroy(); dlg:Destroy() end)
    end

    local function mkBtn(txt,col,px,fn)
        local b=New("TextButton",{BackgroundTransparency=1,BorderSizePixel=0,
            Text=txt,TextColor3=col,Font=Enum.Font.GothamBold,TextSize=12,
            Size=UDim2.new(.5,-1,0,48),Position=UDim2.new(px,0,0,104),
            AutoButtonColor=false,ZIndex=84,Parent=dlg})
        Ripple(b,col)
        local ti=TweenInfo.new(.14)
        b.MouseEnter:Connect(function() Tw(b,ti,{TextColor3=col:Lerp(Color3.new(1,1,1),.25)}) end)
        b.MouseLeave:Connect(function() Tw(b,ti,{TextColor3=col}) end)
        b.MouseButton1Click:Connect(fn)
    end
    mkBtn("Batal",C.Sub,0,function() Click(); close(); if opts.OnCancel then opts.OnCancel() end end)
    mkBtn(opts.ConfirmText or "Konfirm",opts.Danger and C.Danger or C.Accent,.5,
        function() Click(); close(); if opts.OnConfirm then opts.OnConfirm() end end)

    Tw(dlg,TweenInfo.new(.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(.5,0,.5,0)})
end

-- ─────────────────────────────────────────
--  NOTIFY (stacked)
-- ─────────────────────────────────────────
function Window:Notify(opts)
    local C=self.C
    local accent=opts.Type=="success" and C.Success
               or opts.Type=="danger"  and C.Danger
               or opts.Type=="warning" and C.Warning
               or C.Accent
    local NH,NG=74,8
    local idx=#self._notifs+1
    local yOff=-96-(idx-1)*(NH+NG)

    local notif=New("Frame",{BackgroundColor3=C.NotifBg,BorderSizePixel=0,
        Position=UDim2.new(1,20,1,yOff),Size=UDim2.new(0,270,0,NH),
        ZIndex=102,Parent=self.Gui})
    Corner(12,notif)
    Stroke(notif,accent,1,.45)
    Shadow(notif,28,.52)
    table.insert(self._notifs,notif)

    New("Frame",{BackgroundColor3=accent,BorderSizePixel=0,
        Size=UDim2.new(0,3,1,0),ZIndex=103,Parent=notif})
    New("TextLabel",{BackgroundTransparency=1,Text=opts.Title or "Notification",
        TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,-22,0,20),Position=UDim2.new(0,14,0,10),ZIndex=103,Parent=notif})
    New("TextLabel",{BackgroundTransparency=1,Text=opts.Desc or opts.Description or "",
        TextColor3=C.Sub,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
        Size=UDim2.new(1,-22,0,28),Position=UDim2.new(0,14,0,34),ZIndex=103,Parent=notif})

    local pgBg=New("Frame",{BackgroundColor3=C.Stroke,BorderSizePixel=0,
        Position=UDim2.new(0,14,1,-6),Size=UDim2.new(1,-28,0,2),ZIndex=103,Parent=notif})
    Corner(1,pgBg)
    local pgF=New("Frame",{BackgroundColor3=accent,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ZIndex=104,Parent=pgBg})
    Corner(1,pgF)
    local dur=opts.Dur or opts.Duration or 3.5
    Tw(pgF,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)})
    Tw(notif,TweenInfo.new(.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
        {Position=UDim2.new(1,-286,1,yOff)})

    task.delay(dur,function()
        Tw(notif,TweenInfo.new(.32,Enum.EasingStyle.Quint),
            {Position=UDim2.new(1,20,1,yOff)})
        task.delay(.35,function()
            for i,n in ipairs(self._notifs) do
                if n==notif then table.remove(self._notifs,i); break end
            end
            for i,n in ipairs(self._notifs) do
                local ny=-96-(i-1)*(NH+NG)
                Tw(n,TweenInfo.new(.25,Enum.EasingStyle.Quart),
                    {Position=UDim2.new(1,-286,1,ny)})
            end
            _sndOn=false
            notif:Destroy()
            task.delay(.05,function() _sndOn=true end)
        end)
    end)
end

-- Backward compat
function Window:Notification(opts)
    return self:Notify({Title=opts.Title,Desc=opts.Description,Dur=opts.Duration,Type=opts.Type})
end

-- ─────────────────────────────────────────
--  CONFIG
-- ─────────────────────────────────────────
function Window:SaveConfig()
    local ok=pcall(function()
        writefile(self._cfgKey..".json",
            game:GetService("HttpService"):JSONEncode(self._cfg))
    end)
    return ok
end
function Window:LoadConfig()
    local ok=pcall(function()
        if not isfile(self._cfgKey..".json") then return end
        local data=game:GetService("HttpService"):JSONDecode(
            readfile(self._cfgKey..".json"))
        for k,v in pairs(data) do
            self._cfg[k]=v
            if self._cfgCb[k] then pcall(self._cfgCb[k],v) end
        end
    end)
    return ok
end

-- ─────────────────────────────────────────
--  WINDOW CONTROLS
-- ─────────────────────────────────────────
function Window:ToggleMinimize()
    if self.Maximized then self:ToggleMaximize(); return end
    self.Minimized=not self.Minimized
    if self.Minimized then
        self._origSz=self.Win.Size; self._origPos=self.Win.Position
        self.Content.Visible=false; self.Sidebar.Visible=false
        Tw(self.Win,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
            {Size=UDim2.new(0,270,0,52),Position=UDim2.new(0,14,1,-70)})
    else
        Tw(self.Win,TweenInfo.new(.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=self._origSz,Position=self._origPos})
        task.delay(.28,function()
            if not self.Minimized then
                self.Content.Visible=true; self.Sidebar.Visible=true end
        end)
    end
end

function Window:ToggleMaximize()
    if self.Minimized then return end
    self.Maximized=not self.Maximized
    if self.Maximized then
        self._prevSz=self.Win.Size; self._prevPos=self.Win.Position
        local vp=self.Gui.AbsoluteSize
        Tw(self.Win,TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,vp.X,0,vp.Y),Position=UDim2.new(0,0,0,0)})
    else
        Tw(self.Win,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
            {Size=self._prevSz,Position=self._prevPos})
    end
end

function Window:Destroy()
    if self._neonConn then self._neonConn:Disconnect() end
    local sz=self.Win.AbsoluteSize
    Tw(self.Win,TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
        {Size=UDim2.new(0,sz.X,0,0),BackgroundTransparency=1})
    task.delay(.3,function() self.Gui:Destroy() end)
    for i,w in ipairs(Library.Windows) do
        if w==self then table.remove(Library.Windows,i); break end
    end
end

-- ══════════════════════════════════════════════
--  PUBLIC API
-- ══════════════════════════════════════════════

function Library.CreateWindow(opts)
    return Window.new(opts)
end
Library.Themes = T

return Library
