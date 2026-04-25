-- KreinGuiV2 - Premium macOS-style GUI Library for Roblox
-- FIXES:
--   [1] Traffic lights hitbox diperbesar (invisible overlay button)
--   [2] SetTheme() sekarang live-update SEMUA elemen yang sudah dirender
--   [3] Dropdown ZIndex fix — tidak terpotong ScrollingFrame
--   [4] Hue bar pakai UIGradient lokal, tidak bergantung rbxasset
--   [5] Color picker container diperbesar + spacing lebih lapang
--   [6] Secondary button shine disesuaikan untuk warna gelap
-- NEW:
--   [7] Sidebar Profile Card (avatar, username, titik tiga popup menu)

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

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
        Parent        = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color           = color or Color3.fromRGB(255,255,255),
        Thickness       = thickness or 1,
        Transparency    = transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent          = parent
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
        ImageColor3            = Color3.new(0, 0, 0),
        ImageTransparency      = transparency or 0.6,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49, 49, 450, 450),
        Parent                 = parent
    })
end

-- ══════════════════════════════════════════
--  LIVE THEME REGISTRY
--  Setiap elemen yang perlu di-recolor saat SetTheme() dipanggil
--  didaftarkan di sini sebagai { object, propertyName, themeKey }
--  Contoh: { myFrame, "BackgroundColor3", "SectionBg" }
-- ══════════════════════════════════════════

-- Registry disimpan per-window di self._themeRegistry
local function RegisterColor(registry, obj, prop, themeKey)
    table.insert(registry, { obj = obj, prop = prop, key = themeKey })
end

-- ══════════════════════════════════════════
--  PREMIUM BUTTON FACTORY
-- ══════════════════════════════════════════

local function MakePremiumButton(parent, text, bgColor, txtColor, zIndex, callback, style)
    style = style or "primary"
    local isDark = (style == "secondary")  -- secondary = warna gelap

    local glowFrame = Create("Frame", {
        BackgroundColor3       = bgColor,
        BackgroundTransparency = 0.75,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0.96, 0, 0, 46),
        ZIndex                 = zIndex - 1,
        Parent                 = parent
    })
    AddCorner(glowFrame, 12)

    local btnFrame = Create("Frame", {
        BackgroundColor3 = bgColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = zIndex,
        Parent           = glowFrame
    })
    AddCorner(btnFrame, 11)

    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.45,Color3.fromRGB(200,200,200)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(130,130,130))
        }),
        Transparency = NumberSequence.new({
            -- Untuk secondary (gelap), shine lebih subtle
            NumberSequenceKeypoint.new(0,   isDark and 0.88 or 0.72),
            NumberSequenceKeypoint.new(0.5, 0.95),
            NumberSequenceKeypoint.new(1,   isDark and 0.92 or 0.78)
        }),
        Rotation = 90,
        Parent   = btnFrame
    })

    local shineLabel = Create("Frame", {
        BackgroundColor3       = Color3.fromRGB(255,255,255),
        BackgroundTransparency = isDark and 0.92 or 0.82,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0.45, 0),
        ZIndex                 = zIndex + 1,
        Parent                 = btnFrame
    })
    AddCorner(shineLabel, 10)
    Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, isDark and 0.7 or 0.55),
            NumberSequenceKeypoint.new(1, 1.0)
        }),
        Rotation = 90,
        Parent   = shineLabel
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
        Parent                 = btnFrame
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
        Parent           = btnFrame
    })
    AddStroke(btnFrame, bgColor:Lerp(Color3.new(1,1,1), 0.45), 1.5, 0.3)

    local tiH = TweenInfo.new(0.18, Enum.EasingStyle.Quart)
    local tiP = TweenInfo.new(0.08, Enum.EasingStyle.Quart)
    local tiR = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local cH  = bgColor:Lerp(Color3.new(1,1,1), 0.14)
    local cP  = bgColor:Lerp(Color3.new(0,0,0), 0.10)

    btn.MouseEnter:Connect(function()
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
        Tween(btnFrame,  tiP, { BackgroundColor3 = cP })
        Tween(glowFrame, tiP, { BackgroundTransparency = 0.88, Size = UDim2.new(0.94, 0, 0, 44) })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btnFrame,  tiR, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiR, { BackgroundTransparency = 0.75, Size = UDim2.new(0.96, 0, 0, 46) })
    end)
    btn.MouseButton1Click:Connect(callback or function() end)

    return glowFrame, btn
end

-- ══════════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════════

local Themes = {
    Dark = {
        WindowBg          = Color3.fromRGB(22, 22, 26),
        TitleBar          = Color3.fromRGB(28, 28, 34),
        TitleStroke       = Color3.fromRGB(55, 55, 65),
        Sidebar           = Color3.fromRGB(18, 18, 22),
        SidebarDivider    = Color3.fromRGB(40, 40, 50),
        SidebarText       = Color3.fromRGB(145, 145, 165),
        SidebarHover      = Color3.fromRGB(32, 32, 40),
        SidebarActive     = Color3.fromRGB(38, 38, 52),
        SidebarActiveText = Color3.fromRGB(255, 255, 255),
        Text              = Color3.fromRGB(235, 235, 245),
        SubText           = Color3.fromRGB(110, 110, 130),
        Label             = Color3.fromRGB(170, 170, 190),
        Accent            = Color3.fromRGB(110, 130, 255),
        AccentDark        = Color3.fromRGB(75, 95, 210),
        Danger            = Color3.fromRGB(255, 75, 75),
        Success           = Color3.fromRGB(50, 210, 110),
        Warning           = Color3.fromRGB(255, 185, 50),
        SectionBg         = Color3.fromRGB(30, 30, 38),
        SectionStroke     = Color3.fromRGB(45, 45, 58),
        BtnPrimary        = Color3.fromRGB(100, 120, 255),
        BtnSecondary      = Color3.fromRGB(42, 42, 55),
        BtnDanger         = Color3.fromRGB(220, 65, 65),
        ToggleOff         = Color3.fromRGB(50, 50, 65),
        ToggleOn          = Color3.fromRGB(50, 210, 110),
        SliderTrack       = Color3.fromRGB(40, 40, 55),
        SliderFill        = Color3.fromRGB(100, 120, 255),
        InputBg           = Color3.fromRGB(30, 30, 40),
        DropdownBg        = Color3.fromRGB(28, 28, 38),
        DropdownItem      = Color3.fromRGB(35, 35, 48),
        NotifBg           = Color3.fromRGB(32, 32, 42),
        Stroke            = Color3.fromRGB(50, 50, 65),
        ProfileBg         = Color3.fromRGB(25, 25, 30),
        ProfileHover      = Color3.fromRGB(35, 35, 45),
        PopupBg           = Color3.fromRGB(28, 28, 36),
        PopupItem         = Color3.fromRGB(35, 35, 48),
        TrafficRed        = Color3.fromRGB(255, 90, 80),
        TrafficYellow     = Color3.fromRGB(255, 195, 60),
        TrafficGreen      = Color3.fromRGB(60, 210, 90),
    },
    Light = {
        WindowBg          = Color3.fromRGB(248, 248, 252),
        TitleBar          = Color3.fromRGB(240, 240, 248),
        TitleStroke       = Color3.fromRGB(210, 210, 225),
        Sidebar           = Color3.fromRGB(233, 233, 242),
        SidebarDivider    = Color3.fromRGB(210, 210, 224),
        SidebarText       = Color3.fromRGB(100, 100, 120),
        SidebarHover      = Color3.fromRGB(222, 222, 235),
        SidebarActive     = Color3.fromRGB(210, 215, 240),
        SidebarActiveText = Color3.fromRGB(20, 20, 40),
        Text              = Color3.fromRGB(20, 20, 35),
        SubText           = Color3.fromRGB(120, 120, 145),
        Label             = Color3.fromRGB(70, 70, 90),
        Accent            = Color3.fromRGB(90, 110, 240),
        AccentDark        = Color3.fromRGB(65, 85, 210),
        Danger            = Color3.fromRGB(220, 55, 55),
        Success           = Color3.fromRGB(40, 185, 95),
        Warning           = Color3.fromRGB(220, 160, 30),
        SectionBg         = Color3.fromRGB(255, 255, 255),
        SectionStroke     = Color3.fromRGB(218, 218, 232),
        BtnPrimary        = Color3.fromRGB(90, 110, 240),
        BtnSecondary      = Color3.fromRGB(228, 228, 242),
        BtnDanger         = Color3.fromRGB(220, 55, 55),
        ToggleOff         = Color3.fromRGB(195, 195, 215),
        ToggleOn          = Color3.fromRGB(40, 185, 95),
        SliderTrack       = Color3.fromRGB(205, 205, 225),
        SliderFill        = Color3.fromRGB(90, 110, 240),
        InputBg           = Color3.fromRGB(250, 250, 255),
        DropdownBg        = Color3.fromRGB(252, 252, 255),
        DropdownItem      = Color3.fromRGB(245, 245, 252),
        NotifBg           = Color3.fromRGB(255, 255, 255),
        Stroke            = Color3.fromRGB(210, 210, 228),
        ProfileBg         = Color3.fromRGB(228, 228, 240),
        ProfileHover      = Color3.fromRGB(215, 215, 232),
        PopupBg           = Color3.fromRGB(250, 250, 255),
        PopupItem         = Color3.fromRGB(240, 240, 252),
        TrafficRed        = Color3.fromRGB(255, 90, 80),
        TrafficYellow     = Color3.fromRGB(255, 195, 60),
        TrafficGreen      = Color3.fromRGB(60, 210, 90),
    }
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
    local self          = setmetatable({}, Window)
    self.Title          = options.Title    or "KreinUI"
    self.Subtitle       = options.Subtitle or ""
    self.Icon           = options.Icon     or "⬡"
    self.Theme          = options.Theme    or "Dark"
    self.Colors         = Themes[self.Theme] or Themes.Dark
    self.Tabs           = {}
    self.ActiveTab      = nil
    self.Minimized      = false
    self.Maximized      = false
    -- Live-theme registry: daftar semua elemen yang perlu diupdate saat SetTheme()
    self._themeRegistry = {}

    local parent = (game:GetService("RunService"):IsStudio()
        and LocalPlayer:WaitForChild("PlayerGui"))
        or LocalPlayer:WaitForChild("PlayerGui")

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
    RegisterColor(self._themeRegistry, self.Window, "BackgroundColor3", "WindowBg")
    RegisterColor(self._themeRegistry, winStroke,   "Color",            "Stroke")

    -- ── TITLE BAR ──
    self.TitleBar = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 52),
        ZIndex           = 10,
        Parent           = self.Window,
    })
    AddCorner(self.TitleBar, 14)
    RegisterColor(self._themeRegistry, self.TitleBar, "BackgroundColor3", "TitleBar")

    -- Filler bawah untuk nutupin radius bawah titlebar
    local tbFiller = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -14),
        Size             = UDim2.new(1, 0, 0, 14),
        ZIndex           = 10,
        Parent           = self.TitleBar,
    })
    RegisterColor(self._themeRegistry, tbFiller, "BackgroundColor3", "TitleBar")

    local tbDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleStroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 11,
        Parent           = self.TitleBar,
    })
    RegisterColor(self._themeRegistry, tbDivider, "BackgroundColor3", "TitleStroke")

    -- ── TRAFFIC LIGHTS (FIX: hitbox transparan lebih besar) ──
    -- Trik: kita buat visual circle kecil (14x14) PLUS TextButton transparan
    -- yang lebih besar (28x28) di atas sebagai hitbox yang mudah dipencet.
    -- Di mobile touch target minimal harus ~44px, tapi 28px sudah jauh lebih baik.
    local tlTween = TweenInfo.new(0.15)

    local function TrafficLight(color, posX, hoverIcon, onClick)
        -- Visual dot (hanya tampilan)
        local dot = Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, posX, 0.5, -7),
            Size             = UDim2.new(0, 14, 0, 14),
            ZIndex           = 12,
            Parent           = self.TitleBar,
        })
        AddCorner(dot, 100)

        -- Icon label di atas dot
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

        -- HITBOX: transparan, lebih besar, di atas segalanya
        -- Posisi di-offset supaya tetap ter-center di atas dot
        local hitbox = Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "",
            -- Center hitbox 28x28 di atas dot 14x14
            -- dot center X = posX + 7, center Y = 0.5*52 = 26
            -- hitbox harus mulai dari (posX+7-14) sampai (posX+7+14)
            Position               = UDim2.new(0, posX - 7, 0.5, -14),
            Size                   = UDim2.new(0, 28, 0, 28),
            ZIndex                 = 14,  -- paling atas
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

    TrafficLight(self.Colors.TrafficRed,    14, "✕", function() self:Destroy() end)
    TrafficLight(self.Colors.TrafficYellow, 34, "–", function() self:ToggleMinimize() end)
    TrafficLight(self.Colors.TrafficGreen,  54, "+", function() self:ToggleMaximize() end)

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
    RegisterColor(self._themeRegistry, titleIcon, "TextColor3", "Accent")

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
    RegisterColor(self._themeRegistry, titleLabel, "TextColor3", "Text")

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
        RegisterColor(self._themeRegistry, subLbl, "TextColor3", "SubText")
    end

    MakeDraggable(self.TitleBar, self.Window)

    -- ── SIDEBAR ──
    -- Sidebar sekarang punya dua area:
    --   - SidebarScroll: untuk tab buttons (flex area)
    --   - ProfileCard: fixed di bagian bawah (62px dari bawah)
    self.Sidebar = Create("Frame", {
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 52),
        Size             = UDim2.new(0, 195, 1, -52),
        ZIndex           = 6,
        Parent           = self.Window,
    })
    RegisterColor(self._themeRegistry, self.Sidebar, "BackgroundColor3", "Sidebar")

    local sbDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        ZIndex           = 7,
        Parent           = self.Sidebar,
    })
    RegisterColor(self._themeRegistry, sbDivider, "BackgroundColor3", "SidebarDivider")

    -- Header kecil di atas tab list
    local sbHeader = Create("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 16),
        ZIndex                 = 7,
        Parent                 = self.Sidebar,
    })
    local sbHdrLine = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 16, 1, -1),
        Size             = UDim2.new(1, -32, 0, 1),
        ZIndex           = 8,
        Parent           = sbHeader,
    })
    RegisterColor(self._themeRegistry, sbHdrLine, "BackgroundColor3", "SidebarDivider")

    -- Tab list scroll area — tingginya dikurangi 78px untuk profile card
    self.SidebarScroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 0, 16),
        Size                   = UDim2.new(1, 0, 1, -94),  -- sisakan ruang untuk profile card
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

    -- ── PROFILE CARD (kiri bawah sidebar) ──
    -- Divider di atas profile card
    local profDivider = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -78),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 7,
        Parent           = self.Sidebar,
    })
    RegisterColor(self._themeRegistry, profDivider, "BackgroundColor3", "SidebarDivider")

    -- Container profile card
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
    RegisterColor(self._themeRegistry, profileCard, "BackgroundColor3", "ProfileBg")

    -- Avatar thumbnail
    -- Menggunakan Players:GetUserThumbnailAsync() di pcall karena bisa error
    local avatarFrame = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarActive,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 8, 0.5, -17),
        Size             = UDim2.new(0, 34, 0, 34),
        ZIndex           = 9,
        Parent           = profileCard,
    })
    AddCorner(avatarFrame, 100)  -- bulat penuh
    AddStroke(avatarFrame, self.Colors.Accent, 1.5, 0.5)

    local avatarImg = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image                  = "",
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 10,
        Parent                 = avatarFrame,
    })
    AddCorner(avatarImg, 100)

    -- Load avatar async (tidak block thread utama)
    task.spawn(function()
        local ok, thumbUrl = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size48x48
            )
        end)
        if ok then
            avatarImg.Image = thumbUrl
        end
    end)

    -- Username
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
    RegisterColor(self._themeRegistry, usernameLabel, "TextColor3", "Text")

    -- @username (nama asli lebih kecil di bawah)
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
    RegisterColor(self._themeRegistry, atLabel, "TextColor3", "SubText")

    -- Tombol titik tiga (⋯) di kanan
    local dotBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = "···",
        TextColor3             = self.Colors.SubText,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 14,
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -8, 0.5, 0),
        Size                   = UDim2.new(0, 28, 0, 28),  -- touch target cukup besar
        AutoButtonColor        = false,
        ZIndex                 = 10,
        Parent                 = profileCard,
    })
    RegisterColor(self._themeRegistry, dotBtn, "TextColor3", "SubText")

    -- Hover effect pada profile card
    local cardTi = TweenInfo.new(0.18)
    profileCard.MouseEnter:Connect(function()
        Tween(profileCard, cardTi, {
            BackgroundColor3       = self.Colors.ProfileHover,
            BackgroundTransparency = 0.1,
        })
    end)
    profileCard.MouseLeave:Connect(function()
        Tween(profileCard, cardTi, {
            BackgroundColor3       = self.Colors.ProfileBg,
            BackgroundTransparency = 0.3,
        })
    end)

    -- ── POPUP MENU (muncul di atas profile card saat titik tiga diklik) ──
    -- Popup di-parent ke self.Sidebar (bukan self.Window) supaya tidak terpotong
    -- tapi ZIndex-nya tinggi agar muncul di atas semua elemen sidebar
    local popupOpen = false
    local popup = Create("Frame", {
        BackgroundColor3 = self.Colors.PopupBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 8, 1, -80),  -- tepat di atas profile card
        Size             = UDim2.new(1, -16, 0, 0),   -- tinggi dimulai dari 0 (animasi)
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 20,
        Parent           = self.Sidebar,
    })
    AddCorner(popup, 10)
    AddStroke(popup, self.Colors.SidebarDivider, 1, 0.3)
    RegisterColor(self._themeRegistry, popup, "BackgroundColor3", "PopupBg")

    local popupLayout = Create("UIListLayout", {
        Padding             = UDim.new(0, 2),
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = popup,
    })
    AddPadding(popup, 4, 4, 4, 4)

    -- Helper untuk bikin item di popup
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
            -- Tutup popup dulu
            popupOpen = false
            Tween(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), { Size = UDim2.new(1, -16, 0, 0) })
            task.delay(0.2, function() popup.Visible = false end)
            -- Jalankan action
            action()
        end)
    end

    -- Item popup: Theme Dark
    PopupItem("🌙", "Dark Theme", self.Colors.Text, function()
        self:SetTheme("Dark")
        self:Notification({ Title="Theme", Description="Dark theme applied.", Type="info", Duration=2 })
    end)

    -- Item popup: Theme Light
    PopupItem("☀", "Light Theme", self.Colors.Text, function()
        self:SetTheme("Light")
        self:Notification({ Title="Theme", Description="Light theme applied.", Type="info", Duration=2 })
    end)

    -- Divider visual di dalam popup
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -16, 0, 1),
        ZIndex           = 21,
        Parent           = popup,
    })

    -- Item popup: Minimize
    PopupItem("–", "Minimize", self.Colors.Text, function()
        self:ToggleMinimize()
    end)

    -- Item popup: Destroy / Close GUI
    PopupItem("✕", "Close GUI", self.Colors.Danger, function()
        self:Notification({ Title="Closing...", Description="GUI destroyed.", Type="danger", Duration=1 })
        task.delay(1.2, function() self:Destroy() end)
    end)

    -- Hitung tinggi popup berdasarkan konten
    local popupTargetH = popupLayout.AbsoluteContentSize.Y + 12
    -- Kalau belum dirender, estimasi manual: 4 item x 34px + 1 divider + 8 padding
    popupTargetH = (4 * 34) + 6 + 12  -- = 154px

    -- Animasi buka/tutup popup saat titik tiga diklik
    dotBtn.MouseButton1Click:Connect(function()
        popupOpen = not popupOpen
        if popupOpen then
            popup.Visible = true
            -- Animasi muncul dari bawah ke atas: posisi digeser naik sesuai tinggi popup
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

    -- Tutup popup kalau klik di luar area sidebar
    UserInputService.InputBegan:Connect(function(input)
        if popupOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local sAbs = self.Sidebar.AbsolutePosition
            local sSize = self.Sidebar.AbsoluteSize
            -- Kalau klik di luar sidebar, tutup popup
            if pos.X < sAbs.X or pos.X > sAbs.X + sSize.X
            or pos.Y < sAbs.Y or pos.Y > sAbs.Y + sSize.Y then
                popupOpen = false
                Tween(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                    Size = UDim2.new(1, -16, 0, 0)
                })
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

    -- ── OPEN ANIMATION ──
    self.Window.Size = UDim2.new(0, 760, 0, 0)
    self.Window.BackgroundTransparency = 1
    Tween(self.Window, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size                   = UDim2.new(0, 760, 0, 540),
        BackgroundTransparency = 0,
    })

    table.insert(Library.Windows, self)
    return self
end

-- ─────────────────────────────────────────
--  CreateTab
-- ─────────────────────────────────────────
function Window:CreateTab(options)
    local C = self.Colors
    local tab = { Title = options.Title or "Tab", Icon = options.Icon or "○", Window = self }

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
    RegisterColor(self._themeRegistry, tab.SideBtn, "BackgroundColor3", "SidebarActive")

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
    RegisterColor(self._themeRegistry, tab.Indicator, "BackgroundColor3", "Accent")

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
    RegisterColor(self._themeRegistry, tab.IconLabel, "TextColor3", "SidebarText")

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
    RegisterColor(self._themeRegistry, tab.TitleLabel, "TextColor3", "SidebarText")

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

    -- ── COMPONENT HELPERS ──

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
            TextColor3     = self.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 10, 0, 0),
            ZIndex         = 4,
            Parent         = row,
        })
        RegisterColor(self._themeRegistry, lbl, "TextColor3", "Label")
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

    -- ── SECTION ──
    function tab:CreateSection(title)
        local section = {}
        section.Frame = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(section.Frame, 10)
        local secStroke = AddStroke(section.Frame, self.Colors.SectionStroke, 1, 0.4)
        RegisterColor(self._themeRegistry, section.Frame, "BackgroundColor3", "SectionBg")
        RegisterColor(self._themeRegistry, secStroke,     "Color",            "SectionStroke")

        local header = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 30),
            ZIndex                 = 5,
            Parent                 = section.Frame,
        })
        -- FIXED: LetterSpacing dihapus
        local secTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = title:upper(),
            TextColor3     = self.Colors.SubText,
            Font           = Enum.Font.GothamBold,
            TextSize       = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -20, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 5,
            Parent         = header,
        })
        RegisterColor(self._themeRegistry, secTitle, "TextColor3", "SubText")

        local secDiv = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionStroke,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 12, 1, -1),
            Size             = UDim2.new(1, -24, 0, 1),
            ZIndex           = 5,
            Parent           = header,
        })
        RegisterColor(self._themeRegistry, secDiv, "BackgroundColor3", "SectionStroke")

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
                TextColor3     = self.Colors.Label,
                Font           = Enum.Font.Gotham,
                TextSize       = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(0.5, 0, 1, 0),
                Position       = UDim2.new(0, 4, 0, 0),
                ZIndex         = 5,
                Parent         = row2,
            })
            RegisterColor(self._themeRegistry, lbl2, "TextColor3", "Label")
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
    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local bgColor  = style == "danger"    and self.Colors.BtnDanger
                      or style == "secondary" and self.Colors.BtnSecondary
                      or self.Colors.BtnPrimary
        local txtColor = (style == "secondary") and self.Colors.Text or Color3.fromRGB(255,255,255)
        local gf, btn  = MakePremiumButton(tab.Scroll, text, bgColor, txtColor, 4, callback, style)
        return btn
    end

    -- ── TOGGLE ──
    function tab:CreateToggle(options)
        local enabled  = options.Default  or false
        local callback = options.Callback or function() end
        local row, right = MakeRow(options.Title or "Toggle")

        local track = Create("Frame", {
            BackgroundColor3 = enabled and self.Colors.ToggleOn or self.Colors.ToggleOff,
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
            Tween(track, ti, { BackgroundColor3 = enabled and self.Colors.ToggleOn or self.Colors.ToggleOff })
            Tween(knob,  ti, { Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0) })
            callback(enabled)
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled; refresh()
            end
        end)
        return { Set = function(v) enabled = v; refresh() end, Get = function() return enabled end }
    end

    -- ── SLIDER ──
    function tab:CreateSlider(options)
        local minV = options.Min     or 0
        local maxV = options.Max     or 100
        local val  = math.clamp(options.Default or minV, minV, maxV)
        local cb   = options.Callback or function() end
        local sfx  = options.Suffix   or ""

        local container = Create("Frame", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(0.96, 0, 0, 56),
            ZIndex                 = 4,
            Parent                 = tab.Scroll,
        })
        local slTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Slider",
            TextColor3     = self.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.7, 0, 0, 20),
            Position       = UDim2.new(0, 10, 0, 6),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, slTitle, "TextColor3", "Label")

        local valLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = tostring(val) .. sfx,
            TextColor3     = self.Colors.Accent,
            Font           = Enum.Font.GothamBold,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.3, -10, 0, 20),
            Position       = UDim2.new(0.7, 0, 0, 6),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, valLabel, "TextColor3", "Accent")

        local trackBg = Create("Frame", {
            BackgroundColor3 = self.Colors.SliderTrack,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 10, 0, 34),
            Size             = UDim2.new(1, -20, 0, 5),
            ZIndex           = 4,
            Parent           = container,
        })
        AddCorner(trackBg, 3)
        RegisterColor(self._themeRegistry, trackBg, "BackgroundColor3", "SliderTrack")

        local pct = (val - minV) / (maxV - minV)
        local fill = Create("Frame", {
            BackgroundColor3 = self.Colors.SliderFill,
            BorderSizePixel  = 0,
            Size             = UDim2.new(pct, 0, 1, 0),
            ZIndex           = 5,
            Parent           = trackBg,
        })
        AddCorner(fill, 3)
        RegisterColor(self._themeRegistry, fill, "BackgroundColor3", "SliderFill")

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
        return {
            Set = function(v) setVal(math.clamp((v-minV)/(maxV-minV),0,1)) end,
            Get = function()  return val end,
        }
    end

    -- ── DROPDOWN ──
    -- FIX: Dropdown sekarang di-parent ke self.Gui (bukan ke tab.Scroll)
    -- sehingga list-nya tidak terpotong oleh ScrollingFrame ClipsDescendants.
    -- Posisi list dihitung secara dinamis dari AbsolutePosition container.
    function tab:CreateDropdown(options)
        local items    = options.Items    or {}
        local selected = options.Default  or (items[1] or "Select...")
        local cb       = options.Callback or function() end

        local container = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ClipsDescendants = false,
            ZIndex           = 8,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 9)
        local contStroke = AddStroke(container, self.Colors.SectionStroke, 1, 0.4)
        RegisterColor(self._themeRegistry, container,   "BackgroundColor3", "SectionBg")
        RegisterColor(self._themeRegistry, contStroke,  "Color",            "SectionStroke")

        local ddTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Dropdown",
            TextColor3     = self.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 8,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, ddTitle, "TextColor3", "Label")

        local selLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = selected,
            TextColor3     = self.Colors.Text,
            Font           = Enum.Font.GothamBold,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.45, -28, 1, 0),
            Position       = UDim2.new(0.5, 0, 0, 0),
            TextTruncate   = Enum.TextTruncate.AtEnd,
            ZIndex         = 8,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, selLabel, "TextColor3", "Text")

        local arrowBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Text       = "▾",
            TextColor3 = self.Colors.SubText,
            Font       = Enum.Font.GothamBold,
            TextSize   = 11,
            Size       = UDim2.new(0, 22, 1, 0),
            Position   = UDim2.new(1, -26, 0, 0),
            ZIndex     = 8,
            Parent     = container,
        })

        -- LIST FRAME di-parent ke self.Gui supaya tidak di-clip
        -- Posisi dan ukuran di-set ulang setiap kali dibuka
        local listFrame = Create("Frame", {
            BackgroundColor3 = self.Colors.DropdownBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 0, 0, 0),
            Visible          = false,
            ZIndex           = 50,
            Parent           = self.Gui,  -- parent ke ScreenGui!
        })
        AddCorner(listFrame, 9)
        local listStroke = AddStroke(listFrame, self.Colors.SectionStroke, 1, 0.4)
        RegisterColor(self._themeRegistry, listFrame, "BackgroundColor3", "DropdownBg")
        RegisterColor(self._themeRegistry, listStroke, "Color",           "SectionStroke")

        Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = listFrame,
        })
        AddPadding(listFrame, 4, 4, 4, 4)

        local function buildList()
            for _, ch in pairs(listFrame:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemBtn = Create("TextButton", {
                    BackgroundColor3       = self.Colors.DropdownItem,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel        = 0,
                    Text                   = item,
                    TextColor3             = self.Colors.Text,
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
                    listFrame.Visible = false
                    cb(item)
                end)
            end
        end
        buildList()

        local ddOpen = false
        arrowBtn.MouseButton1Click:Connect(function()
            ddOpen = not ddOpen
            if ddOpen then
                -- Hitung posisi absolut container di layar
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

        -- Tutup dropdown kalau klik di luar
        UserInputService.InputBegan:Connect(function(input)
            if ddOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos    = input.Position
                local lAbs   = listFrame.AbsolutePosition
                local lSize  = listFrame.AbsoluteSize
                local cAbs   = container.AbsolutePosition
                local cSize  = container.AbsoluteSize
                local inList = pos.X >= lAbs.X and pos.X <= lAbs.X + lSize.X
                           and pos.Y >= lAbs.Y and pos.Y <= lAbs.Y + lSize.Y
                local inCont = pos.X >= cAbs.X and pos.X <= cAbs.X + cSize.X
                           and pos.Y >= cAbs.Y and pos.Y <= cAbs.Y + cSize.Y
                if not inList and not inCont then
                    ddOpen = false
                    listFrame.Visible = false
                end
            end
        end)

        return {
            SetItems = function(newItems) items = newItems; buildList() end,
            GetValue = function() return selected end,
            Set      = function(v) selected = v; selLabel.Text = v end,
        }
    end

    -- ── INPUT ──
    function tab:CreateInput(options)
        local cb      = options.Callback  or function() end
        local onCh    = options.OnChanged or function() end
        local ph      = options.Placeholder or "Type here..."

        local container = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 9)
        local inStroke = AddStroke(container, self.Colors.SectionStroke, 1, 0.4)
        RegisterColor(self._themeRegistry, container, "BackgroundColor3", "SectionBg")
        RegisterColor(self._themeRegistry, inStroke,  "Color",            "SectionStroke")

        local inTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Input",
            TextColor3     = self.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.4, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 4,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, inTitle, "TextColor3", "Label")

        local inputBox = Create("TextBox", {
            BackgroundColor3  = self.Colors.InputBg,
            BorderSizePixel   = 0,
            PlaceholderText   = ph,
            PlaceholderColor3 = self.Colors.SubText,
            Text              = options.Default or "",
            TextColor3        = self.Colors.Text,
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
        local ibStroke = AddStroke(inputBox, self.Colors.Stroke, 1, 0.5)
        RegisterColor(self._themeRegistry, inputBox, "BackgroundColor3",  "InputBg")
        RegisterColor(self._themeRegistry, inputBox, "TextColor3",        "Text")
        RegisterColor(self._themeRegistry, inputBox, "PlaceholderColor3", "SubText")
        RegisterColor(self._themeRegistry, ibStroke, "Color",             "Stroke")

        inputBox.FocusLost:Connect(function(enter) if enter then cb(inputBox.Text) end end)
        inputBox:GetPropertyChangedSignal("Text"):Connect(function() onCh(inputBox.Text) end)
        return { Get = function() return inputBox.Text end, Set = function(v) inputBox.Text = v end }
    end

    -- ── LABEL ──
    function tab:CreateLabel(text, color)
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = text,
            TextColor3     = color or self.Colors.SubText,
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

-- ── SEPARATOR ──
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
                TextColor3     = C.SubText,
                Font           = Enum.Font.GothamBold,
                TextSize       = 9,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size           = UDim2.new(0.3, 0, 1, 0),
                Position       = UDim2.new(0.35, 0, 0, 0),
                ZIndex         = 4,
                Parent         = sep,
            })
            -- FIXED: self._themeRegistry → self.Window._themeRegistry
            RegisterColor(self.Window._themeRegistry, sepTxt, "TextColor3", "SubText")
        end
        local sepLine1 = Create("Frame", {
            BackgroundColor3 = C.Stroke,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = hasLabel and UDim2.new(0.33, -4, 0, 1) or UDim2.new(1, 0, 0, 1),
            ZIndex           = 4,
            Parent           = sep,
        })
        -- FIXED: self._themeRegistry → self.Window._themeRegistry
        RegisterColor(self.Window._themeRegistry, sepLine1, "BackgroundColor3", "Stroke")
        if hasLabel then
            local sepLine2 = Create("Frame", {
                BackgroundColor3 = C.Stroke,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0.67, 4, 0.5, 0),
                Size             = UDim2.new(0.33, -4, 0, 1),
                ZIndex           = 4,
                Parent           = sep,
            })
            -- FIXED: self._themeRegistry → self.Window._themeRegistry
            RegisterColor(self.Window._themeRegistry, sepLine2, "BackgroundColor3", "Stroke")
        end
    end

    -- ── KEYBIND ──
    function tab:CreateKeybind(options)
        local key      = options.Default
        local cb       = options.Callback or function() end
        local row, right = MakeRow(options.Title or "Keybind")

        local kbBtn = Create("TextButton", {
            BackgroundColor3 = self.Colors.BtnSecondary,
            BorderSizePixel  = 0,
            Text             = key and key.Name or "None",
            TextColor3       = self.Colors.Accent,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -8, 0.5, 0),
            Size             = UDim2.new(0, 76, 0, 28),  -- sedikit lebih tinggi untuk touch
            AutoButtonColor  = false,
            ZIndex           = 5,
            Parent           = right,
        })
        AddCorner(kbBtn, 6)
        AddStroke(kbBtn, self.Colors.Stroke, 1, 0.5)
        RegisterColor(self._themeRegistry, kbBtn, "BackgroundColor3", "BtnSecondary")
        RegisterColor(self._themeRegistry, kbBtn, "TextColor3",       "Accent")

        local listening = false
        kbBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kbBtn.Text      = "..."
            kbBtn.TextColor3 = self.Colors.Warning
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    kbBtn.Text       = key.Name
                    kbBtn.TextColor3 = self.Colors.Accent
                    listening        = false
                    conn:Disconnect()
                    cb(key)
                end
            end)
            task.delay(5, function()
                if listening then
                    listening        = false
                    kbBtn.Text       = key and key.Name or "None"
                    kbBtn.TextColor3 = self.Colors.Accent
                    if conn then conn:Disconnect() end
                end
            end)
        end)
        return {
            GetKey = function()  return key end,
            SetKey = function(k) key = k; kbBtn.Text = k.Name end,
        }
    end

    -- ── COLOR PICKER (FIXED) ──
    -- FIX 1: Hue bar sekarang menggunakan UIGradient lokal (tidak perlu rbxasset)
    -- FIX 2: Container diperbesar ke 148px untuk spacing lebih lapang
    -- FIX 3: Spacing antar elemen ditambah
    function tab:CreateColorPicker(options)
        local color = options.Default  or Color3.fromRGB(100, 120, 255)
        local cb    = options.Callback or function() end

        -- Container lebih tinggi: 148px (sebelumnya 120px)
        local container = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 148),
            ZIndex           = 4,
            Parent           = tab.Scroll,
        })
        AddCorner(container, 10)
        local cpStroke = AddStroke(container, self.Colors.SectionStroke, 1, 0.4)
        RegisterColor(self._themeRegistry, container, "BackgroundColor3", "SectionBg")
        RegisterColor(self._themeRegistry, cpStroke,  "Color",            "SectionStroke")

        local cpTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Color",
            TextColor3     = self.Colors.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.6, 0, 0, 20),
            Position       = UDim2.new(0, 12, 0, 6),
            ZIndex         = 5,
            Parent         = container,
        })
        RegisterColor(self._themeRegistry, cpTitle, "TextColor3", "Label")

        local preview = Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Position         = UDim2.new(1, -52, 0, 8),
            Size             = UDim2.new(0, 36, 0, 36),
            ZIndex           = 5,
            Parent           = container,
        })
        AddCorner(preview, 7)
        AddStroke(preview, self.Colors.Stroke, 1, 0.4)

        local h, s, v = Color3.toHSV(color)
        local function refresh()
            color = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = color
            cb(color)
        end

        -- HUE BAR: menggunakan UIGradient (rainbow dari lokal, tidak perlu asset ID)
        -- Ini lebih reliable karena tidak bergantung network/asset loading
        local hueTrack = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 12, 0, 56),  -- lebih turun dari sebelumnya
            Size             = UDim2.new(1, -64, 0, 12),  -- sedikit lebih tinggi untuk mudah di-drag
            ZIndex           = 5,
            Parent           = container,
        })
        AddCorner(hueTrack, 6)

        -- Rainbow gradient untuk hue bar
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,   0,   0)),  -- Red
                ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255,   0)),  -- Yellow
                ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0, 255,   0)),  -- Green
                ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0, 255, 255)),  -- Cyan
                ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,   0, 255)),  -- Blue
                ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,   0, 255)),  -- Magenta
                ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,   0,   0)),  -- Red lagi (loop)
            }),
            Rotation = 0,  -- horizontal, kiri ke kanan
            Parent   = hueTrack,
        })

        local hueKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(h, 0, 0.5, 0),
            Size             = UDim2.new(0, 14, 0, 14),
            ZIndex           = 6,
            Parent           = hueTrack,
        })
        AddCorner(hueKnob, 7)
        AddStroke(hueKnob, Color3.fromRGB(255,255,255), 2, 0.1)

        -- Helper untuk mini slider (S dan V)
        local function makeMini(yOff, val0, lbl)
            local lblEl = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = lbl,
                TextColor3     = self.Colors.SubText,
                Font           = Enum.Font.GothamBold,
                TextSize       = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(0, 16, 0, 12),
                Position       = UDim2.new(0, 12, 0, yOff),
                ZIndex         = 5,
                Parent         = container,
            })
            RegisterColor(self._themeRegistry, lblEl, "TextColor3", "SubText")

            local tr = Create("Frame", {
                BackgroundColor3 = self.Colors.SliderTrack,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 30, 0, yOff + 2),
                Size             = UDim2.new(1, -90, 0, 8),
                ZIndex           = 5,
                Parent           = container,
            })
            AddCorner(tr, 4)
            RegisterColor(self._themeRegistry, tr, "BackgroundColor3", "SliderTrack")

            local fl = Create("Frame", {
                BackgroundColor3 = self.Colors.SliderFill,
                BorderSizePixel  = 0,
                Size             = UDim2.new(val0, 0, 1, 0),
                ZIndex           = 6,
                Parent           = tr,
            })
            AddCorner(fl, 4)
            RegisterColor(self._themeRegistry, fl, "BackgroundColor3", "SliderFill")

            local kn = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(val0, 0, 0.5, 0),
                Size             = UDim2.new(0, 12, 0, 12),
                ZIndex           = 7,
                Parent           = tr,
            })
            AddCorner(kn, 6)
            return tr, fl, kn
        end

        -- S dan V slider dengan spacing lebih lapang (yOff lebih besar)
        local satTr, satFl, satKn = makeMini(82, s, "S")
        local valTr, valFl, valKn = makeMini(102, v, "V")

        -- Drag logic
        local dH, dS, dV = false, false, false
        local function clampDrag(input, track)
            return math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        end

        hueTrack.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dH = true; h = clampDrag(i, hueTrack)
                hueKnob.Position = UDim2.new(h,0,0.5,0); refresh()
            end
        end)
        satTr.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dS = true; s = clampDrag(i, satTr)
                satKn.Position = UDim2.new(s,0,0.5,0); satFl.Size = UDim2.new(s,0,1,0); refresh()
            end
        end)
        valTr.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dV = true; v = clampDrag(i, valTr)
                valKn.Position = UDim2.new(v,0,0.5,0); valFl.Size = UDim2.new(v,0,1,0); refresh()
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dH = false; dS = false; dV = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
                if dH then h = clampDrag(i, hueTrack); hueKnob.Position = UDim2.new(h,0,0.5,0); refresh()
                elseif dS then s = clampDrag(i, satTr); satKn.Position = UDim2.new(s,0,0.5,0); satFl.Size = UDim2.new(s,0,1,0); refresh()
                elseif dV then v = clampDrag(i, valTr); valKn.Position = UDim2.new(v,0,0.5,0); valFl.Size = UDim2.new(v,0,1,0); refresh()
                end
            end
        end)

        return {
            GetColor = function() return color end,
            SetColor = function(c)
                color = c; h, s, v = Color3.toHSV(c)
                hueKnob.Position = UDim2.new(h,0,0.5,0)
                satKn.Position = UDim2.new(s,0,0.5,0); satFl.Size = UDim2.new(s,0,1,0)
                valKn.Position = UDim2.new(v,0,0.5,0); valFl.Size = UDim2.new(v,0,1,0)
                preview.BackgroundColor3 = c
            end,
        }
    end

    -- Register dan return tab
    self.Tabs[#self.Tabs + 1] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

-- ─────────────────────────────────────────
--  SelectTab
-- ─────────────────────────────────────────
function Window:SelectTab(tab)
    local ti = TweenInfo.new(0.18)
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
--  SetTheme — LIVE UPDATE semua elemen terdaftar
-- ─────────────────────────────────────────
function Window:SetTheme(themeName)
    if not Themes[themeName] then return end
    self.Theme  = themeName
    self.Colors = Themes[themeName]
    local C     = self.Colors
    local ti    = TweenInfo.new(0.3, Enum.EasingStyle.Quart)

    -- Update semua elemen yang terdaftar di registry
    for _, entry in ipairs(self._themeRegistry) do
        local newColor = C[entry.key]
        if newColor and entry.obj and entry.obj.Parent then
            -- Cek apakah properti bisa di-tween
            local ok = pcall(function()
                Tween(entry.obj, ti, { [entry.prop] = newColor })
            end)
            if not ok then
                -- Kalau tidak bisa tween, set langsung
                pcall(function() entry.obj[entry.prop] = newColor end)
            end
        end
    end

    -- Update sidebar scroll bar color
    self.SidebarScroll.ScrollBarImageColor3 = C.Accent

    -- Update active tab indicator dan styling
    if self.ActiveTab then
        self.ActiveTab.SideBtn.BackgroundColor3 = C.SidebarActive
        self.ActiveTab.TitleLabel.TextColor3     = C.SidebarActiveText
        self.ActiveTab.IconLabel.TextColor3      = C.Accent
        self.ActiveTab.Indicator.BackgroundColor3 = C.Accent
    end
end

-- ─────────────────────────────────────────
--  Notification
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

    local notif = Create("Frame", {
        BackgroundColor3 = C.NotifBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, 20, 1, -88),
        Size             = UDim2.new(0, 260, 0, 72),
        ZIndex           = 100,
        Parent           = self.Gui,
    })
    AddCorner(notif, 10)
    AddStroke(notif, accent, 1, 0.5)
    AddShadow(notif, 30, 0.5)

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
    Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -276, 1, -88)
    })
    task.delay(dur, function()
        Tween(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Position = UDim2.new(1, 20, 1, -88) })
        task.delay(0.4, function() notif:Destroy() end)
    end)
    return notif
end

-- ─────────────────────────────────────────
--  Window Controls
-- ─────────────────────────────────────────
function Window:ToggleMinimize()
    local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quint)
    self.Minimized = not self.Minimized
    if self.Minimized then
        self._origSize = self.Window.Size
        self._origPos  = self.Window.Position
        Tween(self.Window, ti, { Size = UDim2.new(0, 220, 0, 52), Position = UDim2.new(0, 14, 1, -70) })
    else
        Tween(self.Window, ti, { Size = self._origSize, Position = self._origPos })
    end
end

function Window:ToggleMaximize()
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quint)
    self.Maximized = not self.Maximized
    if self.Maximized then
        self._prevSize = self.Window.Size
        self._prevPos  = self.Window.Position
        local vp = self.Gui.AbsoluteSize
        Tween(self.Window, ti, { Size = UDim2.new(0, vp.X, 0, vp.Y), Position = UDim2.new(0, 0, 0, 0) })
    else
        Tween(self.Window, ti, { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:Destroy()
    Tween(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 760, 0, 0), BackgroundTransparency = 1
    })
    task.delay(0.4, function() self.Gui:Destroy() end)
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
