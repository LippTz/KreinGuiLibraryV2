-- KreinGuiV3 - Premium macOS-style GUI Library for Roblox
-- ════════════════════════════════════════════════════════════
--  CHANGELOG dari V2:
--
--  BUG FIXES:
--   [F1] registry sekarang self._registry (per-window, bukan global)
--   [F2] Live theme update mencakup MakePremiumButton (bgColor tracked)
--   [F3] Dropdown menutup otomatis saat tab diganti
--   [F4] Notifikasi di-stack (tidak overlap satu sama lain)
--   [F5] CreateSeparator: registry reference diperbaiki
--
--  FITUR BARU:
--   [N1] SaveConfig() / LoadConfig() — persistence via writefile/readfile
--   [N2] Search Bar di sidebar (filter tab by name)
--   [N3] ConfirmDialog() — modal popup dengan Confirm + Cancel
--   [N4] Ripple effect pada semua button
--   [N5] Progress Bar component (programmatic, tidak bisa di-drag)
--   [N6] Tab Badge/Counter (angka merah di pojok tab)
--   [N7] Tooltip — teks hover di atas elemen
--   [N8] Toggle Group / Radio Button
--   [N9] Custom Accent Color (via SetAccentColor())
--
--  PALETTE OVERHAUL:
--   [P1] Dark theme: lebih vibrant, kontras lebih baik, tidak flat
--   [P2] Light theme: total redesign — putih bersih dgn shadow halus,
--         bukan "dark transparan yg diputihkan"
-- ════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ══════════════════════════════════════════
--  UTILITIES
-- ══════════════════════════════════════════

local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function AddCorner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft   = UDim.new(0, left   or 0),
        PaddingRight  = UDim.new(0, right  or 0),
        Parent        = parent,
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color           = color or Color3.fromRGB(255,255,255),
        Thickness       = thickness or 1,
        Transparency    = transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent          = parent,
    })
end

local function AddShadow(parent, size, transparency)
    return Create("ImageLabel", {
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0.5, 4),
        Size                   = UDim2.new(1, size or 30, 1, size or 30),
        ZIndex                 = parent.ZIndex - 1,
        Image                  = "rbxassetid://6014261993",
        ImageColor3            = Color3.new(0,0,0),
        ImageTransparency      = transparency or 0.6,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49,49,450,450),
        Parent                 = parent,
    })
end

-- ══════════════════════════════════════════
--  SOUND SYSTEM
-- ══════════════════════════════════════════
local _sound = Instance.new("Sound")
_sound.SoundId      = "rbxassetid://3359534883"
_sound.Volume       = 0.35
_sound.RollOffMaxDistance = 0
_sound.Parent       = game:GetService("SoundService")

local function PlayClick()
    -- Clone & play agar bisa overlap (klik cepat tidak ke-cancel)
    local s = _sound:Clone()
    s.Parent = game:GetService("SoundService")
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- Hook otomatis ke semua TextButton yang dibuat lewat Create()
-- Wrapper tipis: intercept setelah Create jika class == TextButton
local _origCreate = Create
Create = function(cls, props)
    local obj = _origCreate(cls, props)
    if cls == "TextButton" and props.AutoButtonColor == false then
        -- Hanya hook click, bukan hover/other events
        obj.MouseButton1Click:Connect(PlayClick)
    end
    return obj
end
    table.insert(registry, { obj = obj, prop = prop, key = themeKey })
end

-- ══════════════════════════════════════════
--  RIPPLE EFFECT  [N4]
-- ══════════════════════════════════════════
local function AddRipple(btn, color)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x, y)
        local ripple = Create("Frame", {
            BackgroundColor3       = color or Color3.fromRGB(255,255,255),
            BackgroundTransparency = 0.65,
            BorderSizePixel        = 0,
            AnchorPoint            = Vector2.new(0.5, 0.5),
            Position               = UDim2.new(0, x - btn.AbsolutePosition.X, 0, y - btn.AbsolutePosition.Y),
            Size                   = UDim2.new(0, 0, 0, 0),
            ZIndex                 = btn.ZIndex + 10,
            Parent                 = btn,
        })
        AddCorner(ripple, 999)
        local maxD = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
        Tween(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quart), {
            Size                   = UDim2.new(0, maxD, 0, maxD),
            BackgroundTransparency = 1,
        })
        task.delay(0.5, function() ripple:Destroy() end)
    end)
end

-- ══════════════════════════════════════════
--  PREMIUM BUTTON FACTORY  (sekarang returning ref untuk theme update)
-- ══════════════════════════════════════════
local function MakePremiumButton(parent, text, bgColor, txtColor, zIndex, callback, style, registry)
    style = style or "primary"
    local isDark = (style == "secondary")

    local glowFrame = Create("Frame", {
        BackgroundColor3       = bgColor,
        BackgroundTransparency = 0.75,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0.96, 0, 0, 46),
        ZIndex                 = zIndex - 1,
        Parent                 = parent,
    })
    AddCorner(glowFrame, 12)

    local btnFrame = Create("Frame", {
        BackgroundColor3 = bgColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = zIndex,
        Parent           = glowFrame,
    })
    AddCorner(btnFrame, 11)

    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.45,Color3.fromRGB(200,200,200)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(130,130,130)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   isDark and 0.88 or 0.72),
            NumberSequenceKeypoint.new(0.5, 0.95),
            NumberSequenceKeypoint.new(1,   isDark and 0.92 or 0.78),
        }),
        Rotation = 90,
        Parent   = btnFrame,
    })

    local shineLabel = Create("Frame", {
        BackgroundColor3       = Color3.fromRGB(255,255,255),
        BackgroundTransparency = isDark and 0.92 or 0.82,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0.45, 0),
        ZIndex                 = zIndex + 1,
        Parent                 = btnFrame,
    })
    AddCorner(shineLabel, 10)
    Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, isDark and 0.7 or 0.55),
            NumberSequenceKeypoint.new(1, 1.0),
        }),
        Rotation = 90,
        Parent   = shineLabel,
    })

    local btn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = text,
        TextColor3             = txtColor,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 13,
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = zIndex + 2,
        AutoButtonColor        = false,
        Parent                 = btnFrame,
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = Color3.fromRGB(0,0,0),
        TextTransparency = 0.7,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        Size             = UDim2.new(1, 0, 1, 0),
        Position         = UDim2.new(0, 0, 0, 1),
        ZIndex           = zIndex + 1,
        Parent           = btnFrame,
    })

    local stroke = AddStroke(btnFrame, bgColor:Lerp(Color3.new(1,1,1), 0.45), 1.5, 0.3)

    -- [F2] FIX: Daftarkan warna button ke registry agar ikut live update tema
    if registry then
        local themeKey = style == "danger" and "BtnDanger"
                      or style == "secondary" and "BtnSecondary"
                      or "BtnPrimary"
        RegisterColor(registry, btnFrame,   "BackgroundColor3", themeKey)
        RegisterColor(registry, glowFrame,  "BackgroundColor3", themeKey)
    end

    local tiH = TweenInfo.new(0.18, Enum.EasingStyle.Quart)
    local tiP = TweenInfo.new(0.08, Enum.EasingStyle.Quart)
    local tiR = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        local cH = bgColor:Lerp(Color3.new(1,1,1), 0.14)
        Tween(btnFrame,   tiH, { BackgroundColor3 = cH })
        Tween(glowFrame,  tiH, { BackgroundTransparency = 0.6, BackgroundColor3 = cH })
        Tween(shineLabel, tiH, { BackgroundTransparency = isDark and 0.85 or 0.72 })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btnFrame,   tiR, { BackgroundColor3 = bgColor })
        Tween(glowFrame,  tiR, { BackgroundTransparency = 0.75, BackgroundColor3 = bgColor })
        Tween(shineLabel, tiR, { BackgroundTransparency = isDark and 0.92 or 0.82 })
    end)
    btn.MouseButton1Down:Connect(function()
        local cP = bgColor:Lerp(Color3.new(0,0,0), 0.10)
        Tween(btnFrame,  tiP, { BackgroundColor3 = cP })
        Tween(glowFrame, tiP, { BackgroundTransparency = 0.88, Size = UDim2.new(0.94, 0, 0, 44) })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btnFrame,  tiR, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiR, { BackgroundTransparency = 0.75, Size = UDim2.new(0.96, 0, 0, 46) })
    end)
    btn.MouseButton1Click:Connect(callback or function() end)

    -- [N4] Ripple
    AddRipple(btn, Color3.fromRGB(255,255,255))

    return glowFrame, btn
end

-- ══════════════════════════════════════════
--  THEMES  [P1] [P2] — PALETTE OVERHAUL
-- ══════════════════════════════════════════
--
--  Dark: lebih vibrant, accent lebih terang, sidebar lebih kontras,
--        section bg sedikit lebih terang dari window untuk depth.
--
--  Light: total baru — bukan "dark yang diputihkan".
--         Pakai sistem: background putih hangat, elemen mengambang
--         dengan shadow, teks gelap, accent biru indigo yang tegas.
-- ══════════════════════════════════════════

local Themes = {
    Dark = {
        -- Struktur window
        WindowBg          = Color3.fromRGB(14, 14, 18),    -- lebih gelap, lebih dalam
        TitleBar          = Color3.fromRGB(20, 20, 26),
        TitleStroke       = Color3.fromRGB(38, 38, 52),
        -- Sidebar
        Sidebar           = Color3.fromRGB(17, 17, 23),
        SidebarDivider    = Color3.fromRGB(32, 32, 44),
        SidebarText       = Color3.fromRGB(120, 120, 148),
        SidebarHover      = Color3.fromRGB(28, 28, 38),
        SidebarActive     = Color3.fromRGB(32, 34, 52),
        SidebarActiveText = Color3.fromRGB(235, 235, 255),
        -- Teks
        Text              = Color3.fromRGB(230, 230, 245),
        SubText           = Color3.fromRGB(95, 95, 120),
        Label             = Color3.fromRGB(155, 155, 180),
        -- Accent & status
        Accent            = Color3.fromRGB(125, 145, 255),  -- lebih terang, lebih vibrant
        AccentDark        = Color3.fromRGB(85, 105, 225),
        Danger            = Color3.fromRGB(255, 72, 72),
        Success           = Color3.fromRGB(52, 220, 120),
        Warning           = Color3.fromRGB(255, 190, 55),
        -- Section & cards
        SectionBg         = Color3.fromRGB(22, 22, 30),
        SectionStroke     = Color3.fromRGB(36, 36, 52),
        -- Buttons
        BtnPrimary        = Color3.fromRGB(110, 125, 255),
        BtnSecondary      = Color3.fromRGB(35, 35, 50),
        BtnDanger         = Color3.fromRGB(215, 60, 60),
        -- Controls
        ToggleOff         = Color3.fromRGB(40, 40, 58),
        ToggleOn          = Color3.fromRGB(52, 220, 120),
        SliderTrack       = Color3.fromRGB(32, 32, 48),
        SliderFill        = Color3.fromRGB(110, 125, 255),
        InputBg           = Color3.fromRGB(22, 22, 32),
        -- Dropdown
        DropdownBg        = Color3.fromRGB(20, 20, 30),
        DropdownItem      = Color3.fromRGB(28, 28, 42),
        -- Notification
        NotifBg           = Color3.fromRGB(24, 24, 34),
        -- Misc
        Stroke            = Color3.fromRGB(40, 40, 58),
        -- Profile card
        ProfileBg         = Color3.fromRGB(20, 20, 28),
        ProfileHover      = Color3.fromRGB(28, 28, 40),
        -- Popup
        PopupBg           = Color3.fromRGB(22, 22, 32),
        PopupItem         = Color3.fromRGB(30, 30, 44),
        -- Traffic lights
        TrafficRed        = Color3.fromRGB(255, 88, 78),
        TrafficYellow     = Color3.fromRGB(255, 192, 58),
        TrafficGreen      = Color3.fromRGB(58, 212, 95),
        -- Progress
        ProgressBg        = Color3.fromRGB(30, 30, 44),
        ProgressFill      = Color3.fromRGB(110, 125, 255),
        -- Search
        SearchBg          = Color3.fromRGB(22, 22, 32),
    },

    Light = {
        -- Light theme v2: sidebar GELAP abu-biru (kontras dgn content putih)
        -- Window: putih bersih sebagai canvas utama
        WindowBg          = Color3.fromRGB(245, 245, 250),
        TitleBar          = Color3.fromRGB(255, 255, 255),
        TitleStroke       = Color3.fromRGB(215, 215, 228),
        -- Sidebar: abu GELAP — ini yg bikin kontras jelas di screenshot
        -- Pakai abu kebiruan gelap seperti macOS sidebar di Light mode
        Sidebar           = Color3.fromRGB(52, 55, 72),      -- gelap! bukan abu muda
        SidebarDivider    = Color3.fromRGB(68, 72, 92),
        SidebarText       = Color3.fromRGB(165, 168, 195),
        SidebarHover      = Color3.fromRGB(65, 68, 88),
        SidebarActive     = Color3.fromRGB(75, 95, 200),     -- biru accent solid
        SidebarActiveText = Color3.fromRGB(255, 255, 255),   -- teks putih di atas biru
        -- Teks di content area: hitam pekat utk kontras maksimal
        Text              = Color3.fromRGB(18, 18, 32),
        SubText           = Color3.fromRGB(115, 115, 140),
        Label             = Color3.fromRGB(65, 65, 88),
        -- Accent: biru tegas
        Accent            = Color3.fromRGB(75, 95, 220),
        AccentDark        = Color3.fromRGB(55, 75, 195),
        Danger            = Color3.fromRGB(205, 45, 45),
        Success           = Color3.fromRGB(30, 160, 82),
        Warning           = Color3.fromRGB(195, 138, 15),
        -- Content/section: putih murni agar terang & kontras dgn sidebar gelap
        SectionBg         = Color3.fromRGB(255, 255, 255),
        SectionStroke     = Color3.fromRGB(218, 218, 232),
        -- Buttons
        BtnPrimary        = Color3.fromRGB(75, 95, 220),
        BtnSecondary      = Color3.fromRGB(235, 235, 248),
        BtnDanger         = Color3.fromRGB(205, 45, 45),
        -- Controls
        ToggleOff         = Color3.fromRGB(195, 195, 215),
        ToggleOn          = Color3.fromRGB(30, 160, 82),
        SliderTrack       = Color3.fromRGB(210, 210, 230),
        SliderFill        = Color3.fromRGB(75, 95, 220),
        InputBg           = Color3.fromRGB(252, 252, 255),
        -- Dropdown
        DropdownBg        = Color3.fromRGB(255, 255, 255),
        DropdownItem      = Color3.fromRGB(244, 244, 252),
        -- Notification
        NotifBg           = Color3.fromRGB(255, 255, 255),
        -- Misc
        Stroke            = Color3.fromRGB(210, 210, 230),
        -- Profile card: di sidebar gelap, card sedikit lebih terang dari sidebar
        ProfileBg         = Color3.fromRGB(65, 68, 88),
        ProfileHover      = Color3.fromRGB(78, 82, 105),
        -- Popup
        PopupBg           = Color3.fromRGB(255, 255, 255),
        PopupItem         = Color3.fromRGB(244, 244, 252),
        -- Traffic lights
        TrafficRed        = Color3.fromRGB(255, 88, 78),
        TrafficYellow     = Color3.fromRGB(255, 192, 58),
        TrafficGreen      = Color3.fromRGB(58, 212, 95),
        -- Progress
        ProgressBg        = Color3.fromRGB(215, 215, 232),
        ProgressFill      = Color3.fromRGB(75, 95, 220),
        -- Search
        SearchBg          = Color3.fromRGB(68, 72, 92),      -- search bg ikut sidebar gelap
    },

    -- Bonus: Ocean tema (dark teal vibes)
    Ocean = {
        WindowBg          = Color3.fromRGB(10, 18, 28),
        TitleBar          = Color3.fromRGB(14, 24, 36),
        TitleStroke       = Color3.fromRGB(25, 50, 70),
        Sidebar           = Color3.fromRGB(10, 20, 32),
        SidebarDivider    = Color3.fromRGB(20, 45, 65),
        SidebarText       = Color3.fromRGB(90, 140, 170),
        SidebarHover      = Color3.fromRGB(18, 38, 55),
        SidebarActive     = Color3.fromRGB(20, 48, 72),
        SidebarActiveText = Color3.fromRGB(190, 230, 255),
        Text              = Color3.fromRGB(200, 228, 248),
        SubText           = Color3.fromRGB(72, 115, 145),
        Label             = Color3.fromRGB(120, 170, 200),
        Accent            = Color3.fromRGB(65, 195, 225),
        AccentDark        = Color3.fromRGB(40, 155, 185),
        Danger            = Color3.fromRGB(255, 80, 80),
        Success           = Color3.fromRGB(55, 215, 130),
        Warning           = Color3.fromRGB(255, 185, 55),
        SectionBg         = Color3.fromRGB(14, 26, 40),
        SectionStroke     = Color3.fromRGB(24, 52, 74),
        BtnPrimary        = Color3.fromRGB(50, 175, 210),
        BtnSecondary      = Color3.fromRGB(18, 42, 62),
        BtnDanger         = Color3.fromRGB(215, 65, 65),
        ToggleOff         = Color3.fromRGB(22, 48, 68),
        ToggleOn          = Color3.fromRGB(55, 215, 130),
        SliderTrack       = Color3.fromRGB(18, 40, 60),
        SliderFill        = Color3.fromRGB(50, 175, 210),
        InputBg           = Color3.fromRGB(14, 28, 42),
        DropdownBg        = Color3.fromRGB(12, 24, 36),
        DropdownItem      = Color3.fromRGB(18, 38, 56),
        NotifBg           = Color3.fromRGB(14, 28, 44),
        Stroke            = Color3.fromRGB(24, 52, 74),
        ProfileBg         = Color3.fromRGB(12, 22, 35),
        ProfileHover      = Color3.fromRGB(18, 38, 56),
        PopupBg           = Color3.fromRGB(14, 26, 40),
        PopupItem         = Color3.fromRGB(20, 44, 64),
        TrafficRed        = Color3.fromRGB(255, 88, 78),
        TrafficYellow     = Color3.fromRGB(255, 192, 58),
        TrafficGreen      = Color3.fromRGB(58, 212, 95),
        ProgressBg        = Color3.fromRGB(18, 42, 62),
        ProgressFill      = Color3.fromRGB(50, 175, 210),
        SearchBg          = Color3.fromRGB(14, 28, 44),
    },
}

-- ══════════════════════════════════════════
--  DRAG SYSTEM
-- ══════════════════════════════════════════

local function MakeDraggable(handle, target)
    local dragging, startInput, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startInput = input.Position
            startPos   = target.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - startInput
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════════════
--  LIBRARY
-- ══════════════════════════════════════════

local Library = {}
Library.Windows = {}

local Window = {}
Window.__index = Window

-- ─────────────────────────────────────────
--  Window Constructor
-- ─────────────────────────────────────────
function Window.new(options)
    local self            = setmetatable({}, Window)
    self.Title            = options.Title    or "KreinUI"
    self.Subtitle         = options.Subtitle or ""
    self.Icon             = options.Icon     or "⬡"
    self.Theme            = options.Theme    or "Dark"
    self.Colors           = Themes[self.Theme] or Themes.Dark
    self.Tabs             = {}
    self.ActiveTab        = nil
    self.Minimized        = false
    self.Maximized        = false
    self._configKey       = options.ConfigKey or ("KreinConfig_" .. (options.Title or "default"))
    self._configData      = {}        -- nilai komponen yang disave
    self._configCallbacks = {}        -- { key -> callback untuk set nilai }

    -- [F1] FIX: registry per-window, bukan global!
    self._registry = {}

    -- Shortcut lokal agar tidak perlu ketik self._registry terus
    local registry = self._registry

    local parent = LocalPlayer:WaitForChild("PlayerGui")

    self.Gui = Create("ScreenGui", {
        Name           = "KreinGUI_" .. self.Title,
        Parent         = parent,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    -- ── MAIN WINDOW ──
    self.Window = Create("Frame", {
        BackgroundColor3 = self.Colors.WindowBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5, -380, 0.5, -270),
        Size             = UDim2.new(0, 760, 0, 540),
        ClipsDescendants = true,
        Parent           = self.Gui,
        ZIndex           = 2,
    })
    AddCorner(self.Window, 14)
    local winStroke = AddStroke(self.Window, self.Colors.Stroke, 1.5, 0.5)
    AddShadow(self.Window, 60, 0.45)
    RegisterColor(registry, self.Window, "BackgroundColor3", "WindowBg")
    RegisterColor(registry, winStroke,   "Color",            "Stroke")

    -- ── TITLE BAR ──
    self.TitleBar = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 52),
        ZIndex           = 10,
        Parent           = self.Window,
    })
    AddCorner(self.TitleBar, 14)
    RegisterColor(registry, self.TitleBar, "BackgroundColor3", "TitleBar")

    local tbFiller = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -14),
        Size             = UDim2.new(1, 0, 0, 14),
        ZIndex           = 10,
        Parent           = self.TitleBar,
    })
    RegisterColor(registry, tbFiller, "BackgroundColor3", "TitleBar")

    local tbDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleStroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 11,
        Parent           = self.TitleBar,
    })
    RegisterColor(registry, tbDivider, "BackgroundColor3", "TitleStroke")

    -- ── TRAFFIC LIGHTS ──
    -- Jarak antar dot: 26px (cukup renggang agar hitbox tidak overlap)
    -- Dot: 14x14, Hitbox: 30x30, centered di dot masing-masing
    local tlTween = TweenInfo.new(0.15)
    local function TrafficLight(color, posX, hoverIcon, onClick)
        local dot = Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, posX, 0.5, -7),
            Size             = UDim2.new(0, 14, 0, 14),
            ZIndex           = 12,
            Parent           = self.TitleBar,
        })
        AddCorner(dot, 100)
        local iconLbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text       = "",
            TextColor3 = Color3.fromRGB(80, 30, 20),
            Font       = Enum.Font.GothamBold,
            TextSize   = 8,
            Size       = UDim2.new(1, 0, 1, 0),
            ZIndex     = 13,
            Parent     = dot,
        })
        -- Hitbox 30x30, tepat centered di dot, tidak overlap tetangga
        local hitbox = Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "",
            AnchorPoint            = Vector2.new(0.5, 0.5),
            Position               = UDim2.new(0, posX + 7, 0.5, 0),
            Size                   = UDim2.new(0, 30, 0, 30),
            ZIndex                 = 14,
            AutoButtonColor        = false,
            Parent                 = self.TitleBar,
        })
        hitbox.MouseEnter:Connect(function()
            iconLbl.Text = hoverIcon
            Tween(dot, tlTween, { BackgroundColor3 = color:Lerp(Color3.new(0,0,0), 0.15) })
        end)
        hitbox.MouseLeave:Connect(function()
            iconLbl.Text = ""
            Tween(dot, tlTween, { BackgroundColor3 = color })
        end)
        hitbox.MouseButton1Click:Connect(onClick)
        return dot
    end
    -- Posisi: 14, 40, 66 (jarak 26px antar center = tidak overlap hitbox 30px)
    TrafficLight(self.Colors.TrafficRed,    14, "✕", function() self:Destroy() end)
    TrafficLight(self.Colors.TrafficYellow, 40, "–", function() self:ToggleMinimize() end)
    TrafficLight(self.Colors.TrafficGreen,  66, "+", function() self:ToggleMaximize() end)

    -- Icon + Title
    local titleIcon = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = self.Icon,
        TextColor3 = self.Colors.Accent,
        Font       = Enum.Font.GothamBold,
        TextSize   = 20,
        Size       = UDim2.new(0, 26, 0, 26),
        Position   = UDim2.new(0, 80, 0.5, -13),
        ZIndex     = 11,
        Parent     = self.TitleBar,
    })
    RegisterColor(registry, titleIcon, "TextColor3", "Accent")

    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = self.Title,
        TextColor3     = self.Colors.Text,
        Font           = Enum.Font.GothamBold,
        TextSize       = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size           = UDim2.new(0, 220, 0, 18),
        Position       = UDim2.new(0, 112, 0.5, -14),
        ZIndex         = 11,
        Parent         = self.TitleBar,
    })
    RegisterColor(registry, titleLabel, "TextColor3", "Text")

    if self.Subtitle ~= "" then
        local subLbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = self.Subtitle,
            TextColor3     = self.Colors.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0, 220, 0, 13),
            Position       = UDim2.new(0, 112, 0.5, 3),
            ZIndex         = 11,
            Parent         = self.TitleBar,
        })
        RegisterColor(registry, subLbl, "TextColor3", "SubText")
    end

    MakeDraggable(self.TitleBar, self.Window)

    -- ── SIDEBAR ──
    self.Sidebar = Create("Frame", {
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 52),
        Size             = UDim2.new(0, 195, 1, -52),
        ZIndex           = 6,
        Parent           = self.Window,
    })
    RegisterColor(registry, self.Sidebar, "BackgroundColor3", "Sidebar")

    local sbDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        ZIndex           = 7,
        Parent           = self.Sidebar,
    })
    RegisterColor(registry, sbDivider, "BackgroundColor3", "SidebarDivider")

    -- [N2] SEARCH BAR di atas tab list
    local searchContainer = Create("Frame", {
        BackgroundColor3 = self.Colors.SearchBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 8, 0, 8),
        Size             = UDim2.new(1, -16, 0, 30),
        ZIndex           = 8,
        Parent           = self.Sidebar,
    })
    AddCorner(searchContainer, 8)
    AddStroke(searchContainer, self.Colors.SidebarDivider, 1, 0.4)
    RegisterColor(registry, searchContainer, "BackgroundColor3", "SearchBg")

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = "🔍",
        TextSize   = 11,
        Size       = UDim2.new(0, 24, 1, 0),
        Position   = UDim2.new(0, 4, 0, 0),
        ZIndex     = 9,
        Parent     = searchContainer,
    })

    local searchBox = Create("TextBox", {
        BackgroundTransparency = 1,
        PlaceholderText        = "Search tabs...",
        PlaceholderColor3      = self.Colors.SubText,
        Text                   = "",
        TextColor3             = self.Colors.Text,
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ClearTextOnFocus       = false,
        Size                   = UDim2.new(1, -28, 1, 0),
        Position               = UDim2.new(0, 26, 0, 0),
        ZIndex                 = 9,
        Parent                 = searchContainer,
    })
    RegisterColor(registry, searchBox, "TextColor3",        "Text")
    RegisterColor(registry, searchBox, "PlaceholderColor3", "SubText")
    self._searchBox = searchBox

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, tab in ipairs(self.Tabs) do
            if query == "" then
                tab.SideBtn.Visible = true
            else
                tab.SideBtn.Visible = tab.Title:lower():find(query, 1, true) ~= nil
            end
        end
    end)

    -- Tab list scroll area
    self.SidebarScroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 0, 46),
        Size                   = UDim2.new(1, 0, 1, -124),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = self.Colors.Accent,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        ZIndex                 = 7,
        Parent                 = self.Sidebar,
    })
    self.SidebarLayout = Create("UIListLayout", {
        Padding             = UDim.new(0, 4),
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = self.SidebarScroll,
    })
    AddPadding(self.SidebarScroll, 8, 8, 8, 8)

    -- ── PROFILE CARD ──
    local profDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -78),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 7,
        Parent           = self.Sidebar,
    })
    RegisterColor(registry, profDivider, "BackgroundColor3", "SidebarDivider")

    local profileCard = Create("Frame", {
        BackgroundColor3       = self.Colors.ProfileBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 8, 1, -70),
        Size                   = UDim2.new(1, -16, 0, 54),
        ZIndex                 = 8,
        Parent                 = self.Sidebar,
    })
    AddCorner(profileCard, 10)
    RegisterColor(registry, profileCard, "BackgroundColor3", "ProfileBg")

    local avatarFrame = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarActive,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 8, 0.5, -17),
        Size             = UDim2.new(0, 34, 0, 34),
        ZIndex           = 9,
        Parent           = profileCard,
    })
    AddCorner(avatarFrame, 100)
    AddStroke(avatarFrame, self.Colors.Accent, 1.5, 0.5)

    local avatarImg = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image                  = "",
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 10,
        Parent                 = avatarFrame,
    })
    AddCorner(avatarImg, 100)
    task.spawn(function()
        local ok, thumbUrl = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48
            )
        end)
        if ok then avatarImg.Image = thumbUrl end
    end)

    local usernameLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = LocalPlayer.DisplayName,
        TextColor3     = self.Colors.Text,
        Font           = Enum.Font.GothamBold,
        TextSize       = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate   = Enum.TextTruncate.AtEnd,
        Size           = UDim2.new(1, -72, 0, 14),
        Position       = UDim2.new(0, 50, 0, 10),
        ZIndex         = 9,
        Parent         = profileCard,
    })
    RegisterColor(registry, usernameLabel, "TextColor3", "Text")

    local atLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = "@" .. LocalPlayer.Name,
        TextColor3     = self.Colors.SubText,
        Font           = Enum.Font.Gotham,
        TextSize       = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate   = Enum.TextTruncate.AtEnd,
        Size           = UDim2.new(1, -72, 0, 12),
        Position       = UDim2.new(0, 50, 0, 26),
        ZIndex         = 9,
        Parent         = profileCard,
    })
    RegisterColor(registry, atLabel, "TextColor3", "SubText")

    local dotBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = "···",
        TextColor3             = self.Colors.SubText,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 14,
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -8, 0.5, 0),
        Size                   = UDim2.new(0, 28, 0, 28),
        AutoButtonColor        = false,
        ZIndex                 = 10,
        Parent                 = profileCard,
    })
    RegisterColor(registry, dotBtn, "TextColor3", "SubText")

    local cardTi = TweenInfo.new(0.18)
    profileCard.MouseEnter:Connect(function()
        Tween(profileCard, cardTi, { BackgroundColor3 = self.Colors.ProfileHover, BackgroundTransparency = 0.1 })
    end)
    profileCard.MouseLeave:Connect(function()
        Tween(profileCard, cardTi, { BackgroundColor3 = self.Colors.ProfileBg, BackgroundTransparency = 0.3 })
    end)

    -- ── POPUP MENU ──
    local popupOpen = false
    local popup = Create("Frame", {
        BackgroundColor3 = self.Colors.PopupBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 8, 1, -80),
        Size             = UDim2.new(1, -16, 0, 0),
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 20,
        Parent           = self.Sidebar,
    })
    AddCorner(popup, 10)
    AddStroke(popup, self.Colors.SidebarDivider, 1, 0.3)
    RegisterColor(registry, popup, "BackgroundColor3", "PopupBg")

    Create("UIListLayout", {
        Padding             = UDim.new(0, 2),
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = popup,
    })
    AddPadding(popup, 4, 4, 4, 4)

    local function PopupItem(icon, label, color, action)
        local item = Create("TextButton", {
            BackgroundColor3       = self.Colors.PopupItem,
            BackgroundTransparency = 0.6,
            BorderSizePixel        = 0,
            Text                   = "",
            Size                   = UDim2.new(1, 0, 0, 32),
            AutoButtonColor        = false,
            ZIndex                 = 21,
            Parent                 = popup,
        })
        AddCorner(item, 7)
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text       = icon,
            TextColor3 = color or self.Colors.Text,
            Font       = Enum.Font.Gotham,
            TextSize   = 13,
            Size       = UDim2.new(0, 24, 1, 0),
            Position   = UDim2.new(0, 8, 0, 0),
            ZIndex     = 22,
            Parent     = item,
        })
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = label,
            TextColor3     = color or self.Colors.Text,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -38, 1, 0),
            Position       = UDim2.new(0, 34, 0, 0),
            ZIndex         = 22,
            Parent         = item,
        })
        local itemTi = TweenInfo.new(0.12)
        item.MouseEnter:Connect(function()
            Tween(item, itemTi, { BackgroundTransparency = 0 })
        end)
        item.MouseLeave:Connect(function()
            Tween(item, itemTi, { BackgroundTransparency = 0.6 })
        end)
        item.MouseButton1Click:Connect(function()
            popupOpen = false
            Tween(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { Size = UDim2.new(1,-16,0,0) })
            task.delay(0.2, function() popup.Visible = false end)
            action()
        end)
    end

    PopupItem("🌙", "Dark Theme", self.Colors.Text, function()
        self:SetTheme("Dark")
        self:Notification({ Title="Theme", Description="Dark theme applied.", Type="info", Duration=2 })
    end)
    PopupItem("☀", "Light Theme", self.Colors.Text, function()
        self:SetTheme("Light")
        self:Notification({ Title="Theme", Description="Light theme applied.", Type="info", Duration=2 })
    end)
    PopupItem("🌊", "Ocean Theme", self.Colors.Text, function()
        self:SetTheme("Ocean")
        self:Notification({ Title="Theme", Description="Ocean theme applied.", Type="info", Duration=2 })
    end)
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -16, 0, 1),
        ZIndex           = 21,
        Parent           = popup,
    })
    PopupItem("💾", "Save Config", self.Colors.Text, function()
        self:SaveConfig()
        self:Notification({ Title="Config", Description="Saved successfully.", Type="success", Duration=2 })
    end)
    PopupItem("📂", "Load Config", self.Colors.Text, function()
        self:LoadConfig()
        self:Notification({ Title="Config", Description="Config loaded.", Type="success", Duration=2 })
    end)
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -16, 0, 1),
        ZIndex           = 21,
        Parent           = popup,
    })
    PopupItem("–", "Minimize", self.Colors.Text, function()
        self:ToggleMinimize()
    end)
    PopupItem("✕", "Close GUI", self.Colors.Danger, function()
        self:Notification({ Title="Closing...", Description="GUI destroyed.", Type="danger", Duration=1 })
        task.delay(1.2, function() self:Destroy() end)
    end)

    -- 7 items (3+2+2) × 34 + 2 dividers × 5 + padding 8
    local popupTargetH = 7 * 34 + 2 * 5 + 12  -- = 260px

    dotBtn.MouseButton1Click:Connect(function()
        popupOpen = not popupOpen
        if popupOpen then
            popup.Visible  = true
            popup.Position = UDim2.new(0, 8, 1, -80)
            popup.Size     = UDim2.new(1, -16, 0, 0)
            Tween(popup, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size     = UDim2.new(1, -16, 0, popupTargetH),
                Position = UDim2.new(0, 8, 1, -80 - popupTargetH - 4),
            })
        else
            Tween(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Size     = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 1, -80),
            })
            task.delay(0.2, function() popup.Visible = false end)
        end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if popupOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos   = input.Position
            local sAbs  = self.Sidebar.AbsolutePosition
            local sSize = self.Sidebar.AbsoluteSize
            if pos.X < sAbs.X or pos.X > sAbs.X + sSize.X
            or pos.Y < sAbs.Y or pos.Y > sAbs.Y + sSize.Y then
                popupOpen = false
                Tween(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { Size = UDim2.new(1,-16,0,0) })
                task.delay(0.2, function() popup.Visible = false end)
            end
        end
    end)

    -- ── CONTENT AREA ──
    self.ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        Position               = UDim2.new(0, 196, 0, 52),
        Size                   = UDim2.new(1, -196, 1, -52),
        ZIndex                 = 3,
        Parent                 = self.Window,
    })

    -- ── RESIZE HANDLE (pojok kanan bawah) ──
    -- Ukuran minimum dan maksimum window
    local MIN_W, MIN_H = 500, 360
    local MAX_W, MAX_H = 1100, 800

    -- Container handle: area 32x32 di pojok kanan bawah
    local resizeHandle = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        AnchorPoint            = Vector2.new(1, 1),
        Position               = UDim2.new(1, 0, 1, 0),
        Size                   = UDim2.new(0, 32, 0, 32),
        ZIndex                 = 15,
        Parent                 = self.Window,
    })

    -- Ikon resize: tiga garis diagonal bertingkat (macOS style)
    for i = 1, 3 do
        local offset = i * 7
        Create("Frame", {
            BackgroundColor3 = self.Colors.SubText,
            BackgroundTransparency = 0.4,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(1, 1),
            -- Diagonal dari kanan bawah ke kiri atas
            Position         = UDim2.new(1, -4, 1, -4),
            Size             = UDim2.new(0, offset, 0, 1.5),
            Rotation         = -45,
            ZIndex           = 16,
            Parent           = resizeHandle,
        })
    end

    -- Glow dot di sudut
    local resizeDot = Create("Frame", {
        BackgroundColor3       = self.Colors.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel        = 0,
        AnchorPoint            = Vector2.new(1, 1),
        Position               = UDim2.new(1, -5, 1, -5),
        Size                   = UDim2.new(0, 5, 0, 5),
        ZIndex                 = 16,
        Parent                 = resizeHandle,
    })
    AddCorner(resizeDot, 3)
    RegisterColor(registry, resizeDot, "BackgroundColor3", "Accent")

    -- Tombol invisible di atas semua untuk input
    local resizeBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = "",
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 17,
        AutoButtonColor        = false,
        Parent                 = resizeHandle,
    })

    -- Hover: tampilkan glow
    local rHoverTi = TweenInfo.new(0.15)
    resizeBtn.MouseEnter:Connect(function()
        Tween(resizeDot, rHoverTi, { BackgroundTransparency = 0, Size = UDim2.new(0, 7, 0, 7) })
    end)
    resizeBtn.MouseLeave:Connect(function()
        Tween(resizeDot, rHoverTi, { BackgroundTransparency = 0.5, Size = UDim2.new(0, 5, 0, 5) })
    end)

    -- Drag resize logic
    local resizing     = false
    local resizeStart  = Vector2.new(0, 0)
    local resizeInitW  = 0
    local resizeInitH  = 0

    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing    = true
            resizeStart = Vector2.new(input.Position.X, input.Position.Y)
            resizeInitW = self.Window.AbsoluteSize.X
            resizeInitH = self.Window.AbsoluteSize.Y
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and not self.Minimized and not self.Maximized and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStart
            local newW  = math.clamp(resizeInitW + delta.X, MIN_W, MAX_W)
            local newH  = math.clamp(resizeInitH + delta.Y, MIN_H, MAX_H)
            self.Window.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    -- ── OPEN ANIMATION — spring bounce ──
    self.Window.Size                   = UDim2.new(0, 760, 0, 0)
    self.Window.BackgroundTransparency = 1
    Tween(self.Window, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size                   = UDim2.new(0, 760, 0, 540),
        BackgroundTransparency = 0,
    })

    -- [N5] Notifikasi stack tracker
    self._notifStack = {}

    table.insert(Library.Windows, self)
    return self
end

-- ─────────────────────────────────────────
--  CreateTab
-- ─────────────────────────────────────────
function Window:CreateTab(options)
    local C        = self.Colors
    local registry = self._registry  -- [F1] gunakan per-window registry
    local tab      = { Title = options.Title or "Tab", Icon = options.Icon or "○", Window = self }

    tab.Frame = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Visible                = false,
        ZIndex                 = 3,
        Parent                 = self.ContentArea,
    })
    tab.Scroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -6, 1, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = C.Accent,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        ZIndex                 = 3,
        Parent                 = tab.Frame,
    })
    Create("UIListLayout", {
        Padding             = UDim.new(0, 10),
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = tab.Scroll,
    })
    AddPadding(tab.Scroll, 14, 14, 2, 2)

    -- Sidebar button
    local tabIndex = #self.Tabs + 1
    tab.SideBtn = Create("TextButton", {
        BackgroundColor3       = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 42),
        Text                   = "",
        AutoButtonColor        = false,
        ZIndex                 = 8,
        LayoutOrder            = tabIndex,
        Parent                 = self.SidebarScroll,
    })
    AddCorner(tab.SideBtn, 9)
    RegisterColor(registry, tab.SideBtn, "BackgroundColor3", "SidebarActive")

    tab.Indicator = Create("Frame", {
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0.5, -12),
        Size             = UDim2.new(0, 3, 0, 24),
        ZIndex           = 9,
        Visible          = false,
        Parent           = tab.SideBtn,
    })
    AddCorner(tab.Indicator, 3)
    RegisterColor(registry, tab.Indicator, "BackgroundColor3", "Accent")

    tab.IconLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = tab.Icon,
        TextColor3 = C.SidebarText,
        Font       = Enum.Font.Gotham,
        TextSize   = 16,
        Size       = UDim2.new(0, 26, 1, 0),
        Position   = UDim2.new(0, 14, 0, 0),
        ZIndex     = 9,
        Parent     = tab.SideBtn,
    })
    RegisterColor(registry, tab.IconLabel, "TextColor3", "SidebarText")

    tab.TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = tab.Title,
        TextColor3     = C.SidebarText,
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size           = UDim2.new(1, -48, 1, 0),
        Position       = UDim2.new(0, 40, 0, 0),
        ZIndex         = 9,
        Parent         = tab.SideBtn,
    })
    RegisterColor(registry, tab.TitleLabel, "TextColor3", "SidebarText")

    -- [N6] BADGE container (hidden by default)
    tab._badge = Create("Frame", {
        BackgroundColor3 = C.Danger,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -10, 0.5, 0),
        Size             = UDim2.new(0, 18, 0, 18),
        ZIndex           = 10,
        Visible          = false,
        Parent           = tab.SideBtn,
    })
    AddCorner(tab._badge, 9)
    tab._badgeLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = "0",
        TextColor3 = Color3.fromRGB(255,255,255),
        Font       = Enum.Font.GothamBold,
        TextSize   = 9,
        Size       = UDim2.new(1, 0, 1, 0),
        ZIndex     = 11,
        Parent     = tab._badge,
    })

    local hTween = TweenInfo.new(0.18)
    tab.SideBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.SideBtn, hTween, { BackgroundTransparency = 0, BackgroundColor3 = self.Colors.SidebarHover })
        end
    end)
    tab.SideBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.SideBtn, hTween, { BackgroundTransparency = 1 })
        end
    end)
    tab.SideBtn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    -- ── HELPERS ──
    local window = self

    local function MakeRow(title, height)
        local row = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, height or 46),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = title,
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 10, 0, 0),
            ZIndex         = 4,
            Parent         = row,
        })
        RegisterColor(registry, lbl, "TextColor3", "Label")
        local right = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.5, -10, 1, 0),
            Position               = UDim2.new(0.5, 0, 0, 0),
            ZIndex                 = 4,
            Parent                 = row,
        })
        return row, right
    end

    -- [N7] TOOLTIP helper
    local function MakeTooltip(parent, text)
        local tip = Create("Frame", {
            BackgroundColor3       = window.Colors.PopupBg,
            BackgroundTransparency = 0.1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 0, 0, 22),
            AnchorPoint            = Vector2.new(0, 1),
            Position               = UDim2.new(0, 0, 0, -4),
            Visible                = false,
            ZIndex                 = 60,
            Parent                 = parent,
        })
        AddCorner(tip, 5)
        AddStroke(tip, window.Colors.Stroke, 1, 0.5)
        local tipLbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = text,
            TextColor3     = window.Colors.Text,
            Font           = Enum.Font.Gotham,
            TextSize       = 10,
            AutomaticSize  = Enum.AutomaticSize.X,
            Size           = UDim2.new(0, 0, 1, 0),
            ZIndex         = 61,
            Parent         = tip,
        })
        AddPadding(tip, 0, 0, 6, 6)
        tip:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            tip.Size = UDim2.new(0, tipLbl.AbsoluteSize.X + 12, 0, 22)
        end)

        parent.MouseEnter:Connect(function()
            tip.Visible = true
        end)
        parent.MouseLeave:Connect(function()
            tip.Visible = false
        end)
        return tip
    end

    -- ── SECTION ──
    function tab:CreateSection(title)
        local section = {}
        section.Frame = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(section.Frame, 10)
        local secStroke = AddStroke(section.Frame, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, section.Frame, "BackgroundColor3", "SectionBg")
        RegisterColor(registry, secStroke,     "Color",            "SectionStroke")

        local header = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 30),
            ZIndex                 = 5,
            Parent                 = section.Frame,
        })
        local secTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = title:upper(),
            TextColor3     = window.Colors.SubText,
            Font           = Enum.Font.GothamBold,
            TextSize       = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -20, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 5,
            Parent         = header,
        })
        RegisterColor(registry, secTitle, "TextColor3", "SubText")

        local secDiv = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionStroke,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 12, 1, -1),
            Size             = UDim2.new(1, -24, 0, 1),
            ZIndex           = 5,
            Parent           = header,
        })
        RegisterColor(registry, secDiv, "BackgroundColor3", "SectionStroke")

        section.List = Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = section.Frame,
        })
        AddPadding(section.Frame, 30, 8, 8, 8)
        section.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Frame.Size = UDim2.new(0.96, 0, 0, section.List.AbsoluteContentSize.Y + 46)
        end)

        function section:AddRow(t2, h2)
            local row2 = Create("Frame", {
                BackgroundTransparency = 1,
                Size                   = UDim2.new(1, 0, 0, h2 or 44),
                ZIndex                 = 5,
                Parent                 = section.Frame,
            })
            local lbl2 = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = t2,
                TextColor3     = window.Colors.Label,
                Font           = Enum.Font.Gotham,
                TextSize       = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(0.5, 0, 1, 0),
                Position       = UDim2.new(0, 4, 0, 0),
                ZIndex         = 5,
                Parent         = row2,
            })
            RegisterColor(registry, lbl2, "TextColor3", "Label")
            local right2 = Create("Frame", {
                BackgroundTransparency = 1,
                Size                   = UDim2.new(0.5, -4, 1, 0),
                Position               = UDim2.new(0.5, 0, 0, 0),
                ZIndex                 = 5,
                Parent                 = row2,
            })
            return row2, right2
        end

        return section
    end

    -- ── BUTTON ──
    function tab:CreateButton(text, callback, style, tooltip)
        style = style or "primary"
        local bgColor  = style == "danger"    and window.Colors.BtnDanger
                      or style == "secondary" and window.Colors.BtnSecondary
                      or window.Colors.BtnPrimary
        local txtColor = (style == "secondary") and window.Colors.Text or Color3.fromRGB(255,255,255)
        local gf, btn  = MakePremiumButton(tab.Scroll, text, bgColor, txtColor, 4, callback, style, registry)
        if tooltip then MakeTooltip(btn, tooltip) end
        return btn
    end

    -- ── TOGGLE ──
    function tab:CreateToggle(options)
        local enabled  = options.Default  or false
        local callback = options.Callback or function() end
        local cfgKey   = options.ConfigKey
        local row, right = MakeRow(options.Title or "Toggle")

        local track = Create("Frame", {
            BackgroundColor3 = enabled and window.Colors.ToggleOn or window.Colors.ToggleOff,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -8, 0.5, 0),
            Size             = UDim2.new(0, 46, 0, 24),
            ZIndex           = 5,
            Parent           = right,
        })
        AddCorner(track, 12)

        local knob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0),
            Size             = UDim2.new(0, 20, 0, 20),
            ZIndex           = 6,
            Parent           = track,
        })
        AddCorner(knob, 10)
        AddShadow(knob, 8, 0.6)

        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quart)
        local function refresh()
            Tween(track, ti, { BackgroundColor3 = enabled and window.Colors.ToggleOn or window.Colors.ToggleOff })
            Tween(knob,  ti, { Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0) })
            callback(enabled)
            if cfgKey then window._configData[cfgKey] = enabled end
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled; refresh()
            end
        end)

        local api = {
            Set = function(v) enabled = v; refresh() end,
            Get = function()  return enabled end,
        }
        if cfgKey then
            window._configCallbacks[cfgKey] = function(v) api.Set(v) end
        end
        if options.Tooltip then MakeTooltip(track, options.Tooltip) end
        return api
    end

    -- ── SLIDER ──
    function tab:CreateSlider(options)
        local minV  = options.Min     or 0
        local maxV  = options.Max     or 100
        local val   = math.clamp(options.Default or minV, minV, maxV)
        local cb    = options.Callback or function() end
        local sfx   = options.Suffix   or ""
        local cfgKey = options.ConfigKey

        local container = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.96, 0, 0, 56),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        local slTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Slider",
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.7, 0, 0, 20),
            Position       = UDim2.new(0, 10, 0, 6),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, slTitle, "TextColor3", "Label")

        local valLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = tostring(val) .. sfx,
            TextColor3     = window.Colors.Accent,
            Font           = Enum.Font.GothamBold,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.3, -10, 0, 20),
            Position       = UDim2.new(0.7, 0, 0, 6),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, valLabel, "TextColor3", "Accent")

        local trackBg = Create("Frame", {
            BackgroundColor3 = window.Colors.SliderTrack,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 10, 0, 34),
            Size             = UDim2.new(1, -20, 0, 5),
            ZIndex           = 4,
            Parent           = container,
        })
        AddCorner(trackBg, 3)
        RegisterColor(registry, trackBg, "BackgroundColor3", "SliderTrack")

        local pct  = (val - minV) / (maxV - minV)
        local fill = Create("Frame", {
            BackgroundColor3 = window.Colors.SliderFill,
            BorderSizePixel  = 0,
            Size             = UDim2.new(pct, 0, 1, 0),
            ZIndex           = 5,
            Parent           = trackBg,
        })
        AddCorner(fill, 3)
        RegisterColor(registry, fill, "BackgroundColor3", "SliderFill")

        local thumb = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(pct, 0, 0.5, 0),
            Size             = UDim2.new(0, 14, 0, 14),
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = trackBg,
        })
        AddCorner(thumb, 7)
        AddShadow(thumb, 10, 0.55)

        local function setVal(p)
            p   = math.clamp(p, 0, 1)
            val = math.floor(minV + (maxV - minV) * p + 0.5)
            valLabel.Text  = tostring(val) .. sfx
            fill.Size      = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            cb(val)
            if cfgKey then window._configData[cfgKey] = val end
        end

        local dragging = false
        local function onMove(input)
            setVal((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X)
        end
        trackBg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; onMove(i)
            end
        end)
        thumb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                onMove(i)
            end
        end)

        local api = {
            Set = function(v) setVal(math.clamp((v-minV)/(maxV-minV),0,1)) end,
            Get = function()  return val end,
        }
        if cfgKey then
            window._configCallbacks[cfgKey] = function(v) api.Set(v) end
        end
        return api
    end

    -- ── DROPDOWN ──  [F3] Menutup saat tab diganti (via tab:_closeDropdowns())
    function tab:CreateDropdown(options)
        local items    = options.Items    or {}
        local selected = options.Default  or (items[1] or "Select...")
        local cb       = options.Callback or function() end
        local cfgKey   = options.ConfigKey

        tab._openDropdowns = tab._openDropdowns or {}

        local container = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ClipsDescendants = false,
            ZIndex           = 8,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 9)
        local contStroke = AddStroke(container, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, container,  "BackgroundColor3", "SectionBg")
        RegisterColor(registry, contStroke, "Color",            "SectionStroke")

        local ddTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Dropdown",
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 8,
            Parent         = container,
        })
        RegisterColor(registry, ddTitle, "TextColor3", "Label")

        local selLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = selected,
            TextColor3     = window.Colors.Text,
            Font           = Enum.Font.GothamBold,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.45, -28, 1, 0),
            Position       = UDim2.new(0.5, 0, 0, 0),
            TextTruncate   = Enum.TextTruncate.AtEnd,
            ZIndex         = 8,
            Parent         = container,
        })
        RegisterColor(registry, selLabel, "TextColor3", "Text")

        local arrowBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Text       = "▾",
            TextColor3 = window.Colors.SubText,
            Font       = Enum.Font.GothamBold,
            TextSize   = 11,
            Size       = UDim2.new(0, 22, 1, 0),
            Position   = UDim2.new(1, -26, 0, 0),
            ZIndex     = 8,
            Parent     = container,
        })

        local listFrame = Create("Frame", {
            BackgroundColor3 = window.Colors.DropdownBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 0, 0, 0),
            Visible          = false,
            ZIndex           = 50,
            Parent           = window.Gui,
        })
        AddCorner(listFrame, 9)
        local listStroke = AddStroke(listFrame, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, listFrame,  "BackgroundColor3", "DropdownBg")
        RegisterColor(registry, listStroke, "Color",            "SectionStroke")
        Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = listFrame,
        })
        AddPadding(listFrame, 4, 4, 4, 4)

        local ddOpen = false
        -- Register ke list dropdown tab supaya bisa ditutup saat tab ganti
        table.insert(tab._openDropdowns, function()
            if ddOpen then
                ddOpen = false
                listFrame.Visible = false
            end
        end)

        local function buildList()
            for _, ch in pairs(listFrame:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemBtn = Create("TextButton", {
                    BackgroundColor3       = window.Colors.DropdownItem,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel        = 0,
                    Text                   = item,
                    TextColor3             = window.Colors.Text,
                    Font                   = Enum.Font.Gotham,
                    TextSize               = 11,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Size                   = UDim2.new(1, 0, 0, 28),
                    AutoButtonColor        = false,
                    ZIndex                 = 51,
                    Parent                 = listFrame,
                })
                AddCorner(itemBtn, 6)
                AddPadding(itemBtn, 0, 0, 8, 8)
                itemBtn.MouseEnter:Connect(function()
                    Tween(itemBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
                end)
                itemBtn.MouseLeave:Connect(function()
                    Tween(itemBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.5 })
                end)
                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    selLabel.Text = item
                    ddOpen = false
                    listFrame.Visible = false
                    cb(item)
                    if cfgKey then window._configData[cfgKey] = item end
                end)
            end
        end
        buildList()

        arrowBtn.MouseButton1Click:Connect(function()
            ddOpen = not ddOpen
            if ddOpen then
                local absPos  = container.AbsolutePosition
                local absSize = container.AbsoluteSize
                local listH   = math.min(#items * 30 + 8, 180)
                listFrame.Size     = UDim2.new(0, absSize.X, 0, listH)
                listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                listFrame.Visible  = true
            else
                listFrame.Visible = false
            end
        end)

        UserInputService.InputBegan:Connect(function(input)
            if ddOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos   = input.Position
                local lAbs  = listFrame.AbsolutePosition
                local lSize = listFrame.AbsoluteSize
                local cAbs  = container.AbsolutePosition
                local cSize = container.AbsoluteSize
                local inL   = pos.X >= lAbs.X and pos.X <= lAbs.X + lSize.X
                           and pos.Y >= lAbs.Y and pos.Y <= lAbs.Y + lSize.Y
                local inC   = pos.X >= cAbs.X and pos.X <= cAbs.X + cSize.X
                           and pos.Y >= cAbs.Y and pos.Y <= cAbs.Y + cSize.Y
                if not inL and not inC then
                    ddOpen = false
                    listFrame.Visible = false
                end
            end
        end)

        local api = {
            SetItems = function(newItems) items = newItems; buildList() end,
            GetValue = function() return selected end,
            Set      = function(v) selected = v; selLabel.Text = v end,
        }
        if cfgKey then
            window._configCallbacks[cfgKey] = function(v) api.Set(v) end
        end
        return api
    end

    -- ── INPUT ──
    function tab:CreateInput(options)
        local cb     = options.Callback  or function() end
        local onCh   = options.OnChanged or function() end
        local ph     = options.Placeholder or "Type here..."
        local cfgKey = options.ConfigKey

        local container = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 9)
        local inStroke = AddStroke(container, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, container, "BackgroundColor3", "SectionBg")
        RegisterColor(registry, inStroke,  "Color",            "SectionStroke")

        local inTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Input",
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.4, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, inTitle, "TextColor3", "Label")

        local inputBox = Create("TextBox", {
            BackgroundColor3  = window.Colors.InputBg,
            BorderSizePixel   = 0,
            PlaceholderText   = ph,
            PlaceholderColor3 = window.Colors.SubText,
            Text              = options.Default or "",
            TextColor3        = window.Colors.Text,
            Font              = Enum.Font.Gotham,
            TextSize          = 11,
            TextXAlignment    = Enum.TextXAlignment.Left,
            ClearTextOnFocus  = options.ClearOnFocus or false,
            Size              = UDim2.new(0.55, -12, 0, 26),
            Position          = UDim2.new(0.42, 0, 0.5, -13),
            ZIndex            = 5,
            Parent            = container,
        })
        AddCorner(inputBox, 6)
        AddPadding(inputBox, 0, 0, 8, 8)
        local ibStroke = AddStroke(inputBox, window.Colors.Stroke, 1, 0.5)
        RegisterColor(registry, inputBox, "BackgroundColor3",  "InputBg")
        RegisterColor(registry, inputBox, "TextColor3",        "Text")
        RegisterColor(registry, inputBox, "PlaceholderColor3", "SubText")
        RegisterColor(registry, ibStroke, "Color",             "Stroke")

        inputBox.FocusLost:Connect(function(enter)
            if enter then
                cb(inputBox.Text)
                if cfgKey then window._configData[cfgKey] = inputBox.Text end
            end
        end)
        inputBox:GetPropertyChangedSignal("Text"):Connect(function() onCh(inputBox.Text) end)

        local api = {
            Get = function()  return inputBox.Text end,
            Set = function(v) inputBox.Text = v end,
        }
        if cfgKey then
            window._configCallbacks[cfgKey] = function(v) api.Set(v) end
        end
        return api
    end

    -- ── LABEL ──
    function tab:CreateLabel(text, color)
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = text,
            TextColor3     = color or window.Colors.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.96, 0, 0, 24),
            ZIndex         = 4,
            Parent         = tab.Scroll,
        })
        AddPadding(lbl, 0, 0, 12, 4)
        return {
            Set      = function(v)   lbl.Text       = v   end,
            SetColor = function(col) lbl.TextColor3 = col end,
        }
    end

    -- ── SEPARATOR ──  [F5] registry reference diperbaiki
    function tab:CreateSeparator(label)
        local sep = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.96, 0, 0, 22),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        local hasLabel = label and label ~= ""
        if hasLabel then
            local sepTxt = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = label,
                TextColor3     = window.Colors.SubText,
                Font           = Enum.Font.GothamBold,
                TextSize       = 9,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size           = UDim2.new(0.3, 0, 1, 0),
                Position       = UDim2.new(0.35, 0, 0, 0),
                ZIndex         = 4,
                Parent         = sep,
            })
            RegisterColor(registry, sepTxt, "TextColor3", "SubText")  -- [F5] FIX
        end
        local sepLine1 = Create("Frame", {
            BackgroundColor3 = window.Colors.Stroke,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = hasLabel and UDim2.new(0.33, -4, 0, 1) or UDim2.new(1, 0, 0, 1),
            ZIndex           = 4,
            Parent           = sep,
        })
        RegisterColor(registry, sepLine1, "BackgroundColor3", "Stroke")  -- [F5] FIX
        if hasLabel then
            local sepLine2 = Create("Frame", {
                BackgroundColor3 = window.Colors.Stroke,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0.67, 4, 0.5, 0),
                Size             = UDim2.new(0.33, -4, 0, 1),
                ZIndex           = 4,
                Parent           = sep,
            })
            RegisterColor(registry, sepLine2, "BackgroundColor3", "Stroke")  -- [F5] FIX
        end
    end

    -- ── KEYBIND ──
    function tab:CreateKeybind(options)
        local key      = options.Default
        local cb       = options.Callback or function() end
        local row, right = MakeRow(options.Title or "Keybind")

        local kbBtn = Create("TextButton", {
            BackgroundColor3 = window.Colors.BtnSecondary,
            BorderSizePixel  = 0,
            Text             = key and key.Name or "None",
            TextColor3       = window.Colors.Accent,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -8, 0.5, 0),
            Size             = UDim2.new(0, 76, 0, 28),
            AutoButtonColor  = false,
            ZIndex           = 5,
            Parent           = right,
        })
        AddCorner(kbBtn, 6)
        AddStroke(kbBtn, window.Colors.Stroke, 1, 0.5)
        RegisterColor(registry, kbBtn, "BackgroundColor3", "BtnSecondary")
        RegisterColor(registry, kbBtn, "TextColor3",       "Accent")

        local listening = false
        kbBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kbBtn.Text       = "..."
            kbBtn.TextColor3 = window.Colors.Warning
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    key              = input.KeyCode
                    kbBtn.Text       = key.Name
                    kbBtn.TextColor3 = window.Colors.Accent
                    listening        = false
                    conn:Disconnect()
                    cb(key)
                end
            end)
            task.delay(5, function()
                if listening then
                    listening        = false
                    kbBtn.Text       = key and key.Name or "None"
                    kbBtn.TextColor3 = window.Colors.Accent
                    if conn then conn:Disconnect() end
                end
            end)
        end)
        return {
            GetKey = function()  return key end,
            SetKey = function(k) key = k; kbBtn.Text = k.Name end,
        }
    end

    -- ── COLOR PICKER (2D SV Square + Hue Bar + Batal/Ubah) ──
    -- Seperti gambar referensi: kotak SV 2D di atas, hue bar horizontal di bawah,
    -- preview warna lama vs baru, tombol Batal & Ubah
    function tab:CreateColorPicker(options)
        local initColor = options.Default  or Color3.fromRGB(100, 120, 255)
        local cb        = options.Callback or function() end

        -- State
        local h, s, v    = Color3.toHSV(initColor)
        local pendingColor = initColor   -- warna yg sedang di-preview (belum dikonfirm)
        local confirmedColor = initColor -- warna yg sudah dikonfirm

        -- Row tombol expand di scroll
        local rowBtn = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(rowBtn, 10)
        local rbStroke = AddStroke(rowBtn, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, rowBtn,   "BackgroundColor3", "SectionBg")
        RegisterColor(registry, rbStroke, "Color",            "SectionStroke")

        local cpTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Color",
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.6, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 5,
            Parent         = rowBtn,
        })
        RegisterColor(registry, cpTitle, "TextColor3", "Label")

        -- Swatch kecil yang menunjukkan warna terkonfirmasi
        local swatchSmall = Create("Frame", {
            BackgroundColor3 = confirmedColor,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -44, 0.5, 0),
            Size             = UDim2.new(0, 24, 0, 24),
            ZIndex           = 5,
            Parent           = rowBtn,
        })
        AddCorner(swatchSmall, 6)
        AddStroke(swatchSmall, window.Colors.Stroke, 1, 0.4)

        -- Tombol expand/collapse
        local expandBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "▾",
            TextColor3             = window.Colors.SubText,
            Font                   = Enum.Font.GothamBold,
            TextSize               = 12,
            AnchorPoint            = Vector2.new(1, 0.5),
            Position               = UDim2.new(1, -14, 0.5, 0),
            Size                   = UDim2.new(0, 20, 1, 0),
            AutoButtonColor        = false,
            ZIndex                 = 5,
            Parent                 = rowBtn,
        })

        -- Panel picker (di-parent ke Gui supaya tidak di-clip scroll)
        local panelW = 280
        -- panelH dihitung manual:
        -- SQ_PAD(12) + 8 + SQ_H(170) + 12(gap) + hueBar(14) + 12(gap)
        -- + label(12) + 14(gap) + swatch(28) + 10(gap) + hex(26) + 10(gap) + btn(34) + PAD(12)
        local panelH = 12 + 8 + 170 + 12 + 14 + 12 + 12 + 14 + 28 + 10 + 26 + 10 + 34 + 12  -- = 374
        local panel = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, panelW, 0, panelH),
            Visible          = false,
            ZIndex           = 55,
            Parent           = window.Gui,
        })
        AddCorner(panel, 12)
        AddStroke(panel, window.Colors.SectionStroke, 1.5, 0.3)
        AddShadow(panel, 40, 0.45)
        RegisterColor(registry, panel, "BackgroundColor3", "SectionBg")

        local isOpen   = false
        local SQ_PAD   = 12
        local SQ_W     = panelW - SQ_PAD * 2   -- 256
        local SQ_H     = 170

        -- ── SV SQUARE ──
        -- Layer 1: warna hue murni (diupdate saat hue berubah)
        local svBase = Create("Frame", {
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, SQ_PAD, 0, SQ_PAD + 8),
            Size             = UDim2.new(0, SQ_W, 0, SQ_H),
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(svBase, 6)

        -- Layer 2: gradien putih (saturation) dari kiri ke kanan
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),    -- putih opak di kiri
                NumberSequenceKeypoint.new(1, 1),    -- transparan di kanan
            }),
            Rotation = 0,
            Parent   = svBase,
        })

        -- Layer 3: gradien hitam (value) dari bawah ke atas
        local svDarkOverlay = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 0,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, 0, 1, 0),
            ZIndex           = 57,
            Parent           = svBase,
        })
        AddCorner(svDarkOverlay, 6)
        Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),    -- transparan di atas
                NumberSequenceKeypoint.new(1, 0),    -- hitam opak di bawah
            }),
            Rotation = 90,
            Parent   = svDarkOverlay,
        })

        -- Knob SV (lingkaran putih berisi warna selected)
        local svKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(s, 0, 1 - v, 0),
            Size             = UDim2.new(0, 18, 0, 18),
            ZIndex           = 59,
            Parent           = svBase,
        })
        AddCorner(svKnob, 9)
        AddStroke(svKnob, Color3.fromRGB(255,255,255), 2.5, 0)

        local svKnobInner = Create("Frame", {
            BackgroundColor3 = Color3.fromHSV(h, s, v),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0.5, 0, 0.5, 0),
            Size             = UDim2.new(0, 10, 0, 10),
            ZIndex           = 60,
            Parent           = svKnob,
        })
        AddCorner(svKnobInner, 5)

        -- Hitbox di atas semua layer SV (ZIndex > knob 60)
        local svHitbox = Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "",
            Size                   = UDim2.new(1, 0, 1, 0),
            ZIndex                 = 62,
            AutoButtonColor        = false,
            Parent                 = svBase,
        })

        -- ── HUE BAR ──
        local hueY = SQ_PAD + 8 + SQ_H + 12
        local hueBar = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, SQ_PAD, 0, hueY),
            Size             = UDim2.new(0, SQ_W, 0, 14),
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(hueBar, 7)
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,   0,   0)),
                ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255,   0)),
                ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0, 255,   0)),
                ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0, 255, 255)),
                ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,   0, 255)),
                ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,   0, 255)),
                ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,   0,   0)),
            }),
            Rotation = 0,
            Parent   = hueBar,
        })

        local hueKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(h, 0, 0.5, 0),
            Size             = UDim2.new(0, 16, 0, 22),
            ZIndex           = 57,
            Parent           = hueBar,
        })
        AddCorner(hueKnob, 4)
        AddStroke(hueKnob, Color3.fromRGB(255,255,255), 2, 0.1)
        AddShadow(hueKnob, 6, 0.65)

        local hueHitbox = Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "",
            Size                   = UDim2.new(1, 0, 1, 0),
            ZIndex                 = 58,
            AutoButtonColor        = false,
            Parent                 = hueBar,
        })

        -- ── PREVIEW SWATCH (lama vs baru) ──
        local previewY = hueY + 14 + 12
        local swatchW  = (SQ_W - 8) / 2

        -- Label "Sebelum"
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = "Sebelum",
            TextColor3     = window.Colors.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 9,
            Size           = UDim2.new(0, swatchW, 0, 12),
            Position       = UDim2.new(0, SQ_PAD, 0, previewY),
            ZIndex         = 56,
            Parent         = panel,
        })
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = "Baru",
            TextColor3     = window.Colors.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 9,
            Size           = UDim2.new(0, swatchW, 0, 12),
            Position       = UDim2.new(0, SQ_PAD + swatchW + 8, 0, previewY),
            ZIndex         = 56,
            Parent         = panel,
        })

        -- Swatch lama (warna terkonfirmasi)
        local swOld = Create("Frame", {
            BackgroundColor3 = confirmedColor,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, SQ_PAD, 0, previewY + 14),
            Size             = UDim2.new(0, swatchW, 0, 28),
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(swOld, 6)
        AddStroke(swOld, window.Colors.Stroke, 1, 0.4)

        -- Swatch baru (warna pending)
        local swNew = Create("Frame", {
            BackgroundColor3 = pendingColor,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, SQ_PAD + swatchW + 8, 0, previewY + 14),
            Size             = UDim2.new(0, swatchW, 0, 28),
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(swNew, 6)
        AddStroke(swNew, window.Colors.Stroke, 1, 0.4)

        -- ── HEX DISPLAY ──
        local hexY = previewY + 14 + 28 + 10
        local hexBg = Create("Frame", {
            BackgroundColor3 = window.Colors.InputBg,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, SQ_PAD, 0, hexY),
            Size             = UDim2.new(0, SQ_W, 0, 26),
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(hexBg, 6)
        AddStroke(hexBg, window.Colors.Stroke, 1, 0.4)
        RegisterColor(registry, hexBg, "BackgroundColor3", "InputBg")

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text       = "#",
            TextColor3 = window.Colors.SubText,
            Font       = Enum.Font.GothamBold,
            TextSize   = 11,
            Size       = UDim2.new(0, 18, 1, 0),
            Position   = UDim2.new(0, 8, 0, 0),
            ZIndex     = 57,
            Parent     = hexBg,
        })

        local hexLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = "",
            TextColor3     = window.Colors.Text,
            Font           = Enum.Font.GothamBold,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -28, 1, 0),
            Position       = UDim2.new(0, 24, 0, 0),
            ZIndex         = 57,
            Parent         = hexBg,
        })
        RegisterColor(registry, hexLabel, "TextColor3", "Text")

        local function toHex(c)
            return string.format("%02X%02X%02X",
                math.floor(c.R * 255 + 0.5),
                math.floor(c.G * 255 + 0.5),
                math.floor(c.B * 255 + 0.5)
            )
        end

        -- ── TOMBOL BATAL & UBAH ──
        local btnY   = hexY + 26 + 10
        local btnW   = (SQ_W - 8) / 2

        -- Tombol Batal
        local batalBtn = Create("TextButton", {
            BackgroundColor3 = window.Colors.BtnSecondary,
            BorderSizePixel  = 0,
            Text             = "Batal",
            TextColor3       = window.Colors.SubText,
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            Position         = UDim2.new(0, SQ_PAD, 0, btnY),
            Size             = UDim2.new(0, btnW, 0, 34),
            AutoButtonColor  = false,
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(batalBtn, 8)
        AddStroke(batalBtn, window.Colors.Stroke, 1, 0.4)
        RegisterColor(registry, batalBtn, "BackgroundColor3", "BtnSecondary")
        RegisterColor(registry, batalBtn, "TextColor3",       "SubText")
        AddRipple(batalBtn, window.Colors.SubText)

        -- Tombol Ubah
        local ubahBtn = Create("TextButton", {
            BackgroundColor3 = window.Colors.BtnPrimary,
            BorderSizePixel  = 0,
            Text             = "Ubah",
            TextColor3       = Color3.fromRGB(255,255,255),
            Font             = Enum.Font.GothamBold,
            TextSize         = 12,
            Position         = UDim2.new(0, SQ_PAD + btnW + 8, 0, btnY),
            Size             = UDim2.new(0, btnW, 0, 34),
            AutoButtonColor  = false,
            ZIndex           = 56,
            Parent           = panel,
        })
        AddCorner(ubahBtn, 8)
        RegisterColor(registry, ubahBtn, "BackgroundColor3", "BtnPrimary")
        AddRipple(ubahBtn, Color3.fromRGB(255,255,255))

        -- ── REFRESH LOGIC ──
        local function updateSvKnob()
            svKnob.Position              = UDim2.new(s, 0, 1 - v, 0)
            svKnobInner.BackgroundColor3 = Color3.fromHSV(h, s, v)
            pendingColor                 = Color3.fromHSV(h, s, v)
            swNew.BackgroundColor3       = pendingColor
            hexLabel.Text                = toHex(pendingColor)
            svBase.BackgroundColor3      = Color3.fromHSV(h, 1, 1)
        end
        -- Init hex label & swatch sekarang (tanpa tunggu AbsolutePosition)
        hexLabel.Text              = toHex(pendingColor)
        swNew.BackgroundColor3     = pendingColor
        svBase.BackgroundColor3    = Color3.fromHSV(h, 1, 1)
        svKnob.Position            = UDim2.new(s, 0, 1 - v, 0)
        svKnobInner.BackgroundColor3 = pendingColor

        -- ── DRAG SV ──
        local draggingSV = false
        local function onSvInput(pos)
            local rel = pos - svBase.AbsolutePosition
            s = math.clamp(rel.X / svBase.AbsoluteSize.X, 0, 1)
            v = math.clamp(1 - rel.Y / svBase.AbsoluteSize.Y, 0, 1)
            updateSvKnob()
        end
        svHitbox.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
                onSvInput(Vector2.new(i.Position.X, i.Position.Y))
            end
        end)

        -- ── DRAG HUE ──
        local draggingHue = false
        local function onHueInput(pos)
            local rel = pos.X - hueBar.AbsolutePosition.X
            h = math.clamp(rel / hueBar.AbsoluteSize.X, 0, 1)
            hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
            updateSvKnob()
        end
        hueHitbox.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                onHueInput(Vector2.new(i.Position.X, i.Position.Y))
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                draggingSV  = false
                draggingHue = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
                if draggingSV  then onSvInput(Vector2.new(i.Position.X, i.Position.Y))  end
                if draggingHue then onHueInput(Vector2.new(i.Position.X, i.Position.Y)) end
            end
        end)

        -- ── TOMBOL LOGIC ──
        batalBtn.MouseButton1Click:Connect(function()
            -- Reset ke warna terkonfirmasi, tutup panel
            h, s, v = Color3.toHSV(confirmedColor)
            pendingColor = confirmedColor
            updateSvKnob()
            isOpen = false
            Tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, panelW, 0, 0),
                BackgroundTransparency = 1,
            })
            task.delay(0.22, function() panel.Visible = false end)
            Tween(expandBtn, TweenInfo.new(0.2), { Rotation = 0 })
        end)

        ubahBtn.MouseButton1Click:Connect(function()
            -- Konfirmasi warna baru, fire callback, tutup panel
            confirmedColor = pendingColor
            swOld.BackgroundColor3   = confirmedColor
            swatchSmall.BackgroundColor3 = confirmedColor
            cb(confirmedColor)
            isOpen = false
            Tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, panelW, 0, 0),
                BackgroundTransparency = 1,
            })
            task.delay(0.22, function() panel.Visible = false end)
            Tween(expandBtn, TweenInfo.new(0.2), { Rotation = 0 })
        end)

        -- ── EXPAND/COLLAPSE ──
        local function openPanel()
            local absPos  = rowBtn.AbsolutePosition
            local absSize = rowBtn.AbsoluteSize
            -- Posisi panel: tepat di bawah row, rata kiri, atau flip ke atas jika terlalu bawah
            local screenH  = window.Gui.AbsoluteSize.Y
            local spaceBelow = screenH - (absPos.Y + absSize.Y)
            local posY
            if spaceBelow >= panelH + 8 then
                posY = absPos.Y + absSize.Y + 6
            else
                posY = absPos.Y - panelH - 6
            end
            panel.Position               = UDim2.new(0, absPos.X, 0, posY + 20)
            panel.Size                   = UDim2.new(0, panelW, 0, 0)
            panel.BackgroundTransparency = 1
            panel.Visible                = true
            Tween(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size                   = UDim2.new(0, panelW, 0, panelH),
                Position               = UDim2.new(0, absPos.X, 0, posY),
                BackgroundTransparency = 0,
            })
            Tween(expandBtn, TweenInfo.new(0.2), { Rotation = 180 })
        end

        local function closePanel()
            Tween(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, panelW, 0, 0),
                BackgroundTransparency = 1,
            })
            task.delay(0.2, function() panel.Visible = false end)
            Tween(expandBtn, TweenInfo.new(0.2), { Rotation = 0 })
        end

        expandBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then openPanel() else closePanel() end
        end)

        -- Tutup saat klik di luar panel
        UserInputService.InputBegan:Connect(function(input)
            if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos   = input.Position
                local pAbs  = panel.AbsolutePosition
                local pSize = panel.AbsoluteSize
                local rAbs  = rowBtn.AbsolutePosition
                local rSize = rowBtn.AbsoluteSize
                local inP = pos.X >= pAbs.X and pos.X <= pAbs.X + pSize.X
                         and pos.Y >= pAbs.Y and pos.Y <= pAbs.Y + pSize.Y
                local inR = pos.X >= rAbs.X and pos.X <= rAbs.X + rSize.X
                         and pos.Y >= rAbs.Y and pos.Y <= rAbs.Y + rSize.Y
                if not inP and not inR then
                    isOpen = false; closePanel()
                end
            end
        end)

        return {
            GetColor = function() return confirmedColor end,
            SetColor = function(c)
                confirmedColor = c; pendingColor = c
                h, s, v = Color3.toHSV(c)
                updateSvKnob()
                swOld.BackgroundColor3       = c
                swNew.BackgroundColor3       = c
                swatchSmall.BackgroundColor3 = c
            end,
        }
    end

    -- ── PROGRESS BAR  [N5] ──
    -- Tidak bisa di-drag user. Diupdate programmatically.
    function tab:CreateProgressBar(options)
        local val   = math.clamp(options.Default or 0, 0, 100)
        local sfx   = options.Suffix or "%"
        local label = options.Title  or "Progress"

        local container = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.96, 0, 0, 50),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        local pbTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = label,
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.7, 0, 0, 20),
            Position       = UDim2.new(0, 10, 0, 4),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, pbTitle, "TextColor3", "Label")

        local valLbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = tostring(val) .. sfx,
            TextColor3     = window.Colors.Accent,
            Font           = Enum.Font.GothamBold,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.3, -10, 0, 20),
            Position       = UDim2.new(0.7, 0, 0, 4),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, valLbl, "TextColor3", "Accent")

        local trackBg = Create("Frame", {
            BackgroundColor3 = window.Colors.ProgressBg,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 10, 0, 32),
            Size             = UDim2.new(1, -20, 0, 8),
            ZIndex           = 4,
            Parent           = container,
        })
        AddCorner(trackBg, 4)
        RegisterColor(registry, trackBg, "BackgroundColor3", "ProgressBg")

        local fill = Create("Frame", {
            BackgroundColor3 = window.Colors.ProgressFill,
            BorderSizePixel  = 0,
            Size             = UDim2.new(val / 100, 0, 1, 0),
            ZIndex           = 5,
            Parent           = trackBg,
        })
        AddCorner(fill, 4)
        RegisterColor(registry, fill, "BackgroundColor3", "ProgressFill")

        local function setVal(newVal, animate)
            val = math.clamp(newVal, 0, 100)
            valLbl.Text = tostring(val) .. sfx
            local pct = val / 100
            if animate ~= false then
                Tween(fill, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { Size = UDim2.new(pct, 0, 1, 0) })
            else
                fill.Size = UDim2.new(pct, 0, 1, 0)
            end
        end

        return {
            Set     = setVal,
            Get     = function() return val end,
            Animate = function(from, to, duration)
                setVal(from, false)
                task.delay(0.05, function()
                    Tween(fill, TweenInfo.new(duration or 1, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(to / 100, 0, 1, 0)
                    })
                    valLbl.Text = tostring(to) .. sfx
                end)
            end,
        }
    end

    -- ── TOGGLE GROUP / RADIO  [N8] ──
    -- Hanya satu yang boleh aktif di satu waktu.
    function tab:CreateToggleGroup(options)
        local items    = options.Items    or {}
        local default  = options.Default  or items[1]
        local cb       = options.Callback or function() end
        local cfgKey   = options.ConfigKey
        local current  = default

        local container = Create("Frame", {
            BackgroundColor3 = window.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 10)
        local grpStroke = AddStroke(container, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, container, "BackgroundColor3", "SectionBg")
        RegisterColor(registry, grpStroke, "Color",            "SectionStroke")

        local grpTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = (options.Title or "Select"):upper(),
            TextColor3     = window.Colors.SubText,
            Font           = Enum.Font.GothamBold,
            TextSize       = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -20, 0, 28),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 5,
            Parent         = container,
        })
        RegisterColor(registry, grpTitle, "TextColor3", "SubText")

        local layout = Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = container,
        })
        AddPadding(container, 30, 8, 8, 8)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(0.96, 0, 0, layout.AbsoluteContentSize.Y + 42)
        end)

        local btns = {}
        local function refreshBtns()
            for _, entry in ipairs(btns) do
                local isActive = entry.value == current
                Tween(entry.frame, TweenInfo.new(0.18), {
                    BackgroundColor3       = isActive and window.Colors.Accent or window.Colors.SectionBg,
                    BackgroundTransparency = isActive and 0 or 0.6,
                })
                entry.label.TextColor3 = isActive and Color3.fromRGB(255,255,255) or window.Colors.Text
                entry.dot.BackgroundColor3 = isActive and Color3.fromRGB(255,255,255) or window.Colors.SubText
            end
        end

        for _, item in ipairs(items) do
            local row = Create("TextButton", {
                BackgroundColor3       = window.Colors.SectionBg,
                BackgroundTransparency = 0.6,
                BorderSizePixel        = 0,
                Text                   = "",
                Size                   = UDim2.new(1, 0, 0, 36),
                AutoButtonColor        = false,
                ZIndex                 = 5,
                Parent                 = container,
            })
            AddCorner(row, 7)

            local dot = Create("Frame", {
                BackgroundColor3 = item == default and Color3.fromRGB(255,255,255) or window.Colors.SubText,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0, 12, 0.5, 0),
                Size             = UDim2.new(0, 8, 0, 8),
                ZIndex           = 6,
                Parent           = row,
            })
            AddCorner(dot, 100)

            local lbl = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = item,
                TextColor3     = item == default and Color3.fromRGB(255,255,255) or window.Colors.Text,
                Font           = Enum.Font.Gotham,
                TextSize       = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(1, -32, 1, 0),
                Position       = UDim2.new(0, 28, 0, 0),
                ZIndex         = 6,
                Parent         = row,
            })

            table.insert(btns, { frame = row, label = lbl, dot = dot, value = item })

            row.MouseButton1Click:Connect(function()
                current = item
                refreshBtns()
                cb(item)
                if cfgKey then window._configData[cfgKey] = item end
            end)

            -- Langsung set warna awal untuk default
            if item == default then
                row.BackgroundTransparency = 0
                row.BackgroundColor3       = window.Colors.Accent
            end
        end

        local api = {
            Get = function()  return current end,
            Set = function(v) current = v; refreshBtns() end,
        }
        if cfgKey then
            window._configCallbacks[cfgKey] = function(v) api.Set(v) end
        end
        return api
    end

    -- ── CUSTOM ACCENT COLOR  [N9] ──
    -- Memanggil SetTheme ulang dengan modifikasi warna accent
    function tab:CreateAccentPicker(options)
        options = options or {}
        local cb = options.Callback or function() end

        local container = Create("Frame", {
            BackgroundColor3       = window.Colors.SectionBg,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.96, 0, 0, 46),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        AddCorner(container, 9)
        local acStroke = AddStroke(container, window.Colors.SectionStroke, 1, 0.4)
        RegisterColor(registry, container, "BackgroundColor3", "SectionBg")
        RegisterColor(registry, acStroke,  "Color",            "SectionStroke")

        local acTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Accent Color",
            TextColor3     = window.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(registry, acTitle, "TextColor3", "Label")

        -- Preset warna accent yang bagus
        local presets = {
            Color3.fromRGB(110, 125, 255),  -- Default indigo
            Color3.fromRGB(65,  195, 225),  -- Teal/cyan
            Color3.fromRGB(255, 100, 120),  -- Pink
            Color3.fromRGB(52,  210, 120),  -- Green
            Color3.fromRGB(255, 165,  50),  -- Orange
            Color3.fromRGB(190,  80, 255),  -- Purple
        }

        local swatchSize = 20
        local swatchGap  = 6
        local totalW     = (#presets * (swatchSize + swatchGap)) - swatchGap

        for i, col in ipairs(presets) do
            local sw = Create("TextButton", {
                BackgroundColor3 = col,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10 - (#presets - i) * (swatchSize + swatchGap), 0.5, 0),
                Size             = UDim2.new(0, swatchSize, 0, swatchSize),
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 5,
                Parent           = container,
            })
            AddCorner(sw, 100)
            AddRipple(sw, Color3.fromRGB(255,255,255))

            sw.MouseButton1Click:Connect(function()
                window:SetAccentColor(col)
                cb(col)
                window:Notification({ Title="Accent", Description="Accent color updated!", Type="info", Duration=2 })
            end)
        end
    end

    -- Register tab dan return
    self.Tabs[#self.Tabs + 1] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

-- ─────────────────────────────────────────
--  SelectTab  [F3] Tutup semua dropdown saat tab diganti
-- ─────────────────────────────────────────
function Window:SelectTab(tab)
    local ti = TweenInfo.new(0.18)

    -- [F3] FIX: tutup semua dropdown dari tab sebelumnya
    if self.ActiveTab and self.ActiveTab._openDropdowns then
        for _, closeFn in ipairs(self.ActiveTab._openDropdowns) do
            pcall(closeFn)
        end
    end

    if self.ActiveTab and self.ActiveTab ~= tab then
        local prev = self.ActiveTab
        prev.Frame.Visible     = false
        prev.Indicator.Visible = false
        Tween(prev.SideBtn,    ti, { BackgroundTransparency = 1 })
        Tween(prev.TitleLabel, ti, { TextColor3 = self.Colors.SidebarText })
        Tween(prev.IconLabel,  ti, { TextColor3 = self.Colors.SidebarText })
    end
    tab.Frame.Visible     = true
    tab.Indicator.Visible = true
    Tween(tab.SideBtn,    ti, { BackgroundTransparency = 0, BackgroundColor3 = self.Colors.SidebarActive })
    Tween(tab.TitleLabel, ti, { TextColor3 = self.Colors.SidebarActiveText })
    Tween(tab.IconLabel,  ti, { TextColor3 = self.Colors.Accent })
    self.ActiveTab = tab
end

-- ─────────────────────────────────────────
--  SetTheme — LIVE UPDATE [F1][F2]
-- ─────────────────────────────────────────
function Window:SetTheme(themeName)
    if not Themes[themeName] then return end
    self.Theme  = themeName
    self.Colors = Themes[themeName]
    local C     = self.Colors
    local ti    = TweenInfo.new(0.3, Enum.EasingStyle.Quart)

    for _, entry in ipairs(self._registry) do  -- [F1] gunakan self._registry
        local newColor = C[entry.key]
        if newColor and entry.obj and entry.obj.Parent then
            local ok = pcall(function()
                Tween(entry.obj, ti, { [entry.prop] = newColor })
            end)
            if not ok then
                pcall(function() entry.obj[entry.prop] = newColor end)
            end
        end
    end

    self.SidebarScroll.ScrollBarImageColor3 = C.Accent

    if self.ActiveTab then
        self.ActiveTab.SideBtn.BackgroundColor3   = C.SidebarActive
        self.ActiveTab.TitleLabel.TextColor3       = C.SidebarActiveText
        self.ActiveTab.IconLabel.TextColor3        = C.Accent
        self.ActiveTab.Indicator.BackgroundColor3  = C.Accent
    end
end

-- ─────────────────────────────────────────
--  SetAccentColor  [N9]
-- ─────────────────────────────────────────
function Window:SetAccentColor(color)
    -- Override semua key yang berhubungan dengan accent di Colors saat ini
    local accentKeys = {
        "Accent", "SliderFill", "BtnPrimary", "ProgressFill"
    }
    local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
    for _, key in ipairs(accentKeys) do
        self.Colors[key] = color
    end
    -- Live update semua elemen terdaftar yang pakai key accent
    for _, entry in ipairs(self._registry) do
        for _, key in ipairs(accentKeys) do
            if entry.key == key and entry.obj and entry.obj.Parent then
                pcall(function()
                    Tween(entry.obj, ti, { [entry.prop] = color })
                end)
            end
        end
    end
    self.SidebarScroll.ScrollBarImageColor3 = color
    if self.ActiveTab then
        self.ActiveTab.Indicator.BackgroundColor3 = color
        self.ActiveTab.IconLabel.TextColor3       = color
    end
end

-- ─────────────────────────────────────────
--  Tab Badge API  [N6]
-- ─────────────────────────────────────────
function Window:SetTabBadge(tab, count)
    if count and count > 0 then
        tab._badge.Visible      = true
        tab._badgeLabel.Text    = tostring(math.min(count, 99))
        if count > 9 then
            tab._badge.Size = UDim2.new(0, 24, 0, 18)
        else
            tab._badge.Size = UDim2.new(0, 18, 0, 18)
        end
    else
        tab._badge.Visible = false
    end
end

-- ─────────────────────────────────────────
--  ConfirmDialog  [N3]
-- ─────────────────────────────────────────
function Window:ConfirmDialog(options)
    local title   = options.Title   or "Confirm"
    local message = options.Message or "Are you sure?"
    local onYes   = options.OnConfirm or function() end
    local onNo    = options.OnCancel  or function() end
    local C       = self.Colors

    -- Overlay gelap
    local overlay = Create("Frame", {
        BackgroundColor3       = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 80,
        Parent                 = self.Window,
    })

    -- Dialog box
    local dialog = Create("Frame", {
        BackgroundColor3 = C.SectionBg,
        BorderSizePixel  = 0,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 10),  -- sedikit di bawah untuk animasi
        Size             = UDim2.new(0, 320, 0, 148),
        ZIndex           = 81,
        Parent           = self.Window,
    })
    AddCorner(dialog, 14)
    AddStroke(dialog, C.SectionStroke, 1, 0.3)
    AddShadow(dialog, 40, 0.4)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = title,
        TextColor3     = C.Text,
        Font           = Enum.Font.GothamBold,
        TextSize       = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size           = UDim2.new(1, -24, 0, 22),
        Position       = UDim2.new(0, 16, 0, 16),
        ZIndex         = 82,
        Parent         = dialog,
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = message,
        TextColor3     = C.SubText,
        Font           = Enum.Font.Gotham,
        TextSize       = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        Size           = UDim2.new(1, -24, 0, 50),
        Position       = UDim2.new(0, 16, 0, 44),
        ZIndex         = 82,
        Parent         = dialog,
    })

    local divider = Create("Frame", {
        BackgroundColor3 = C.SectionStroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 104),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 82,
        Parent           = dialog,
    })

    local function close()
        Tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
        Tween(dialog,  TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0.5, 0, 0.5, 20),
        })
        task.delay(0.22, function()
            overlay:Destroy()
            dialog:Destroy()
        end)
    end

    -- Tombol Cancel (kiri)
    local cancelBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = "Cancel",
        TextColor3             = C.SubText,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        Size                   = UDim2.new(0.5, -1, 0, 43),
        Position               = UDim2.new(0, 0, 0, 105),
        AutoButtonColor        = false,
        ZIndex                 = 82,
        Parent                 = dialog,
    })
    AddRipple(cancelBtn, C.SubText)
    cancelBtn.MouseEnter:Connect(function()
        Tween(cancelBtn, TweenInfo.new(0.15), { TextColor3 = C.Text })
    end)
    cancelBtn.MouseLeave:Connect(function()
        Tween(cancelBtn, TweenInfo.new(0.15), { TextColor3 = C.SubText })
    end)
    cancelBtn.MouseButton1Click:Connect(function()
        close(); onNo()
    end)

    -- Divider vertikal antara dua tombol
    Create("Frame", {
        BackgroundColor3 = C.SectionStroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5, -1, 0, 105),
        Size             = UDim2.new(0, 1, 0, 43),
        ZIndex           = 82,
        Parent           = dialog,
    })

    -- Tombol Confirm (kanan)
    local confirmBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = options.ConfirmText or "Confirm",
        TextColor3             = options.Danger and C.Danger or C.Accent,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 12,
        Size                   = UDim2.new(0.5, -1, 0, 43),
        Position               = UDim2.new(0.5, 1, 0, 105),
        AutoButtonColor        = false,
        ZIndex                 = 82,
        Parent                 = dialog,
    })
    local confirmColor = options.Danger and C.Danger or C.Accent
    AddRipple(confirmBtn, confirmColor)
    confirmBtn.MouseEnter:Connect(function()
        Tween(confirmBtn, TweenInfo.new(0.15), {
            TextColor3 = confirmColor:Lerp(Color3.new(1,1,1), 0.25)
        })
    end)
    confirmBtn.MouseLeave:Connect(function()
        Tween(confirmBtn, TweenInfo.new(0.15), { TextColor3 = confirmColor })
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        close(); onYes()
    end)

    -- Animasi masuk
    Tween(dialog, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
end

-- ─────────────────────────────────────────
--  Notification  [F4] Stack system
-- ─────────────────────────────────────────
function Window:Notification(options)
    local C     = self.Colors
    local title = options.Title       or "Notification"
    local desc  = options.Description or ""
    local dur   = options.Duration    or 3.5
    local ntype = options.Type        or "info"

    local accent = ntype == "success" and C.Success
                or ntype == "danger"  and C.Danger
                or ntype == "warning" and C.Warning
                or C.Accent

    -- [F4] Hitung posisi Y berdasarkan berapa notif yang sedang tampil
    local NOTIF_H   = 72
    local NOTIF_GAP = 8
    local stackIdx  = #self._notifStack + 1
    local yOffset   = -88 - (stackIdx - 1) * (NOTIF_H + NOTIF_GAP)

    local notif = Create("Frame", {
        BackgroundColor3 = C.NotifBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, 20, 1, yOffset),
        Size             = UDim2.new(0, 260, 0, NOTIF_H),
        ZIndex           = 100,
        Parent           = self.Gui,
    })
    AddCorner(notif, 10)
    AddStroke(notif, accent, 1, 0.5)
    AddShadow(notif, 30, 0.5)

    table.insert(self._notifStack, notif)
    local myIdx = stackIdx

    Create("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 3, 1, 0),
        ZIndex           = 101,
        Parent           = notif,
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = title,
        TextColor3     = C.Text,
        Font           = Enum.Font.GothamBold,
        TextSize       = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size           = UDim2.new(1, -22, 0, 20),
        Position       = UDim2.new(0, 14, 0, 10),
        ZIndex         = 101,
        Parent         = notif,
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text           = desc,
        TextColor3     = C.SubText,
        Font           = Enum.Font.Gotham,
        TextSize       = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        Size           = UDim2.new(1, -22, 0, 30),
        Position       = UDim2.new(0, 14, 0, 34),
        ZIndex         = 101,
        Parent         = notif,
    })

    local pgBg = Create("Frame", {
        BackgroundColor3 = C.Stroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 14, 1, -6),
        Size             = UDim2.new(1, -28, 0, 2),
        ZIndex           = 101,
        Parent           = notif,
    })
    AddCorner(pgBg, 1)
    local pgFill = Create("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 102,
        Parent           = pgBg,
    })
    AddCorner(pgFill, 1)
    Tween(pgFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    -- Slide in
    Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -276, 1, yOffset)
    })

    task.delay(dur, function()
        -- Slide out
        Tween(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 20, 1, yOffset)
        })
        task.delay(0.4, function()
            -- Hapus dari stack dan shift sisa notif ke bawah
            for i, n in ipairs(self._notifStack) do
                if n == notif then
                    table.remove(self._notifStack, i)
                    break
                end
            end
            -- Geser semua notif yang masih ada
            for i, n in ipairs(self._notifStack) do
                local newY = -88 - (i - 1) * (NOTIF_H + NOTIF_GAP)
                Tween(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                    Position = UDim2.new(1, -276, 1, newY)
                })
            end
            notif:Destroy()
        end)
    end)
    return notif
end

-- ─────────────────────────────────────────
--  SaveConfig / LoadConfig  [N1]
-- ─────────────────────────────────────────
function Window:SaveConfig()
    local ok, err = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(self._configData)
        writefile(self._configKey .. ".json", json)
    end)
    return ok, err
end

function Window:LoadConfig()
    local ok, result = pcall(function()
        if not isfile(self._configKey .. ".json") then return end
        local json = readfile(self._configKey .. ".json")
        local data = game:GetService("HttpService"):JSONDecode(json)
        for key, val in pairs(data) do
            self._configData[key] = val
            if self._configCallbacks[key] then
                pcall(self._configCallbacks[key], val)
            end
        end
    end)
    return ok, result
end

-- ─────────────────────────────────────────
--  Window Controls
-- ─────────────────────────────────────────
function Window:ToggleMinimize()
    -- Jangan minimize kalau lagi maximized — restore dulu
    if self.Maximized then self:ToggleMaximize() return end

    local tiOut = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local tiIn  = TweenInfo.new(0.42, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
    self.Minimized = not self.Minimized

    if self.Minimized then
        self._origSize = self.Window.Size
        self._origPos  = self.Window.Position
        -- Sembunyikan konten & sidebar agar animasi collapse terlihat bersih
        self.ContentArea.Visible = false
        self.Sidebar.Visible     = false
        -- Minimize ke title bar saja, pojok kiri bawah layar
        Tween(self.Window, tiOut, {
            Size     = UDim2.new(0, 260, 0, 52),
            Position = UDim2.new(0, 14, 1, -70),
        })
    else
        -- Restore
        Tween(self.Window, tiIn, {
            Size     = self._origSize,
            Position = self._origPos,
        })
        task.delay(0.25, function()
            if not self.Minimized then
                self.ContentArea.Visible = true
                self.Sidebar.Visible     = true
            end
        end)
    end
end

function Window:ToggleMaximize()
    -- Jangan maximize kalau lagi minimized
    if self.Minimized then return end

    local tiOut = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tiIn  = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    self.Maximized = not self.Maximized

    if self.Maximized then
        self._prevSize = self.Window.Size
        self._prevPos  = self.Window.Position
        local vp = self.Gui.AbsoluteSize
        -- Scale-up dari posisi saat ini ke fullscreen
        Tween(self.Window, tiOut, {
            Size     = UDim2.new(0, vp.X, 0, vp.Y),
            Position = UDim2.new(0, 0, 0, 0),
        })
    else
        Tween(self.Window, tiIn, {
            Size     = self._prevSize,
            Position = self._prevPos,
        })
    end
end

function Window:Destroy()
    local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    Tween(self.Window, ti, {
        Size                   = UDim2.new(0, self.Window.AbsoluteSize.X, 0, 0),
        BackgroundTransparency = 1,
    })
    task.delay(0.32, function() self.Gui:Destroy() end)
    for i, w in ipairs(Library.Windows) do
        if w == self then table.remove(Library.Windows, i); break end
    end
end

-- ══════════════════════════════════════════
--  PUBLIC API
-- ══════════════════════════════════════════
function Library.CreateWindow(options)
    return Window.new(options)
end
Library.Themes = Themes

return Library

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  USAGE EXAMPLE — KreinGuiV3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local GUI = loadstring(...)()   -- atau require(MODULE_ID)

local win = GUI.CreateWindow({
    Title     = "MyApp",
    Subtitle  = "v3.0",
    Icon      = "⚡",
    Theme     = "Dark",          -- "Dark" | "Light" | "Ocean"
    ConfigKey = "MyApp_Config",  -- key untuk SaveConfig/LoadConfig
})

local tab1 = win:CreateTab({ Title = "Home",     Icon = "🏠" })
local tab2 = win:CreateTab({ Title = "Settings", Icon = "⚙" })
local tab3 = win:CreateTab({ Title = "About",    Icon = "ℹ" })

-- Badge
win:SetTabBadge(tab1, 5)  -- tampilkan "5" di pojok tab Home

-- Section
local sec = tab1:CreateSection("Player Settings")

-- Toggle
local myToggle = tab1:CreateToggle({
    Title     = "God Mode",
    Default   = false,
    ConfigKey = "godmode",          -- disimpan ke config
    Tooltip   = "Toggle invincibility",
    Callback  = function(v)
        print("GodMode:", v)
    end,
})

-- Slider
local mySlider = tab1:CreateSlider({
    Title     = "Speed",
    Min       = 1, Max = 100,
    Default   = 16,
    Suffix    = " stud/s",
    ConfigKey = "speed",
    Callback  = function(v)
        print("Speed:", v)
    end,
})

-- Dropdown
local myDD = tab1:CreateDropdown({
    Title    = "Team",
    Items    = { "Red", "Blue", "Green" },
    Default  = "Red",
    ConfigKey = "team",
    Callback = function(v) print("Team:", v) end,
})

-- Progress bar
local progress = tab2:CreateProgressBar({
    Title   = "Loading Assets",
    Default = 0,
    Suffix  = "%",
})
-- Animasi dari 0 ke 80 dalam 2 detik:
progress:Animate(0, 80, 2)

-- Toggle Group
local mode = tab2:CreateToggleGroup({
    Title    = "Game Mode",
    Items    = { "Normal", "Hard", "Insane" },
    Default  = "Normal",
    ConfigKey = "gamemode",
    Callback = function(v) print("Mode:", v) end,
})

-- Accent color picker
tab2:CreateAccentPicker({
    Title    = "Accent Color",
    Callback = function(c) print("New accent:", c) end,
})

-- Confirm dialog
tab3:CreateButton("Reset Config", function()
    win:ConfirmDialog({
        Title      = "Reset Config",
        Message    = "This will delete all saved settings. Continue?",
        ConfirmText = "Reset",
        Danger     = true,
        OnConfirm  = function()
            win:Notification({ Title="Reset", Description="Config cleared.", Type="danger", Duration=3 })
        end,
        OnCancel   = function()
            win:Notification({ Title="Cancelled", Description="Nothing changed.", Type="info", Duration=2 })
        end,
    })
end, "danger")

-- Save/Load config
tab3:CreateButton("Save Config", function()
    win:SaveConfig()
    win:Notification({ Title="Saved!", Description="Config saved to disk.", Type="success" })
end)
tab3:CreateButton("Load Config", function()
    win:LoadConfig()
    win:Notification({ Title="Loaded!", Description="Config applied.", Type="success" })
end)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--]]
