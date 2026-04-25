-- KreinGuiV2 - Premium macOS-style GUI Library for Roblox
-- FIXED: Removed invalid LetterSpacing property
-- UPGRADED: Premium button visuals with gradient, shine, glow effects
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ══════════════════════════════════════════
--  UTILITIES
-- ══════════════════════════════════════════

local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        obj[k] = v
    end
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
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color       = color or Color3.fromRGB(255,255,255),
        Thickness   = thickness or 1,
        Transparency = transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddShadow(parent, size, transparency)
    local shadow = Create("ImageLabel", {
        AnchorPoint         = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position            = UDim2.new(0.5, 0, 0.5, 4),
        Size                = UDim2.new(1, size or 30, 1, size or 30),
        ZIndex              = parent.ZIndex - 1,
        Image               = "rbxassetid://6014261993",
        ImageColor3         = Color3.new(0, 0, 0),
        ImageTransparency   = transparency or 0.6,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49, 49, 450, 450),
        Parent              = parent
    })
    return shadow
end

-- ══════════════════════════════════════════
--  PREMIUM BUTTON FACTORY
--  Creates a macOS-style button with:
--    • UIGradient for depth/gloss
--    • Shine overlay layer
--    • Glow ImageLabel beneath
--    • Smooth multi-stage tween on hover/press
-- ══════════════════════════════════════════

local function MakePremiumButton(parent, text, bgColor, txtColor, zIndex, callback, style)
    style = style or "primary"

    -- Outer glow frame (sits behind the button)
    local glowFrame = Create("Frame", {
        BackgroundColor3     = bgColor,
        BackgroundTransparency = 0.75,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(0.96, 0, 0, 46),  -- slightly larger than button
        ZIndex               = zIndex - 1,
        Parent               = parent
    })
    AddCorner(glowFrame, 12)

    -- Main button frame (we use a Frame + TextButton layered for gradient control)
    local btnFrame = Create("Frame", {
        BackgroundColor3 = bgColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = zIndex,
        Parent           = glowFrame
    })
    AddCorner(btnFrame, 11)

    -- UIGradient: top is slightly lighter (gloss), bottom darker (depth)
    -- This simulates the "pill of light" you see on macOS buttons
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),  -- highlight
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(200, 200, 200)), -- mid
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(130, 130, 130))   -- shadow
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.72),  -- subtle top highlight
            NumberSequenceKeypoint.new(0.5, 0.92),  -- fade to near invisible
            NumberSequenceKeypoint.new(1,   0.78)   -- subtle bottom shadow
        }),
        Rotation = 90,  -- vertical gradient = top-to-bottom gloss
        Parent   = btnFrame
    })

    -- Shine streak: diagonal highlight strip across top-left area
    local shineLabel = Create("Frame", {
        BackgroundColor3     = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.82,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0, 0, 0, 0),
        Size                 = UDim2.new(1, 0, 0.45, 0),  -- covers top 45% of button
        ZIndex               = zIndex + 1,
        ClipsDescendants     = false,
        Parent               = btnFrame
    })
    AddCorner(shineLabel, 10)

    -- Shine's own gradient fades it out toward the bottom
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.55),  -- visible at top
            NumberSequenceKeypoint.new(1,   1.0)    -- fully invisible at bottom
        }),
        Rotation = 90,
        Parent   = shineLabel
    })

    -- The actual clickable TextButton (transparent bg, sits on top)
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

    -- Add a subtle text shadow by duplicating label slightly offset
    local textShadow = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = Color3.fromRGB(0, 0, 0),
        TextTransparency       = 0.7,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 13,
        Size                   = UDim2.new(1, 0, 1, 0),
        Position               = UDim2.new(0, 0, 0, 1),  -- 1px down = shadow
        ZIndex                 = zIndex + 1,
        Parent                 = btnFrame
    })

    -- Stroke border: color matches button with slight transparency for "inset" look
    local stroke = AddStroke(btnFrame, bgColor:Lerp(Color3.new(1,1,1), 0.45), 1.5, 0.3)

    -- ── Tween constants ──
    local tiHover = TweenInfo.new(0.18, Enum.EasingStyle.Quart)
    local tiPress = TweenInfo.new(0.08, Enum.EasingStyle.Quart)
    local tiRelease = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local colorHover = bgColor:Lerp(Color3.new(1,1,1), 0.14)
    local colorPress = bgColor:Lerp(Color3.new(0,0,0), 0.1)

    -- Hover: lighten + expand glow
    btn.MouseEnter:Connect(function()
        Tween(btnFrame, tiHover, { BackgroundColor3 = colorHover })
        Tween(glowFrame, tiHover, { BackgroundTransparency = 0.6, BackgroundColor3 = colorHover })
        Tween(shineLabel, tiHover, { BackgroundTransparency = 0.72 }) -- shine brightens slightly
    end)
    btn.MouseLeave:Connect(function()
        Tween(btnFrame, tiRelease, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiRelease, { BackgroundTransparency = 0.75, BackgroundColor3 = bgColor })
        Tween(shineLabel, tiRelease, { BackgroundTransparency = 0.82 })
    end)

    -- Press: darken + compress glow (tactile feel)
    btn.MouseButton1Down:Connect(function()
        Tween(btnFrame, tiPress, { BackgroundColor3 = colorPress })
        Tween(glowFrame, tiPress, {
            BackgroundTransparency = 0.88,
            Size = UDim2.new(0.94, 0, 0, 44) -- slightly smaller = "pressed in"
        })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btnFrame, tiRelease, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiRelease, {
            BackgroundTransparency = 0.75,
            Size = UDim2.new(0.96, 0, 0, 46)
        })
    end)
    btn.MouseButton1Click:Connect(callback or function() end)

    -- Return the outer frame so layout system can size it
    return glowFrame, btn
end

-- ══════════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════════

local Themes = {
    Dark = {
        -- Window
        WindowBg        = Color3.fromRGB(22, 22, 26),
        TitleBar        = Color3.fromRGB(28, 28, 34),
        TitleStroke     = Color3.fromRGB(55, 55, 65),
        -- Sidebar
        Sidebar         = Color3.fromRGB(18, 18, 22),
        SidebarDivider  = Color3.fromRGB(40, 40, 50),
        SidebarText     = Color3.fromRGB(145, 145, 165),
        SidebarHover    = Color3.fromRGB(32, 32, 40),
        SidebarActive   = Color3.fromRGB(38, 38, 52),
        SidebarActiveText = Color3.fromRGB(255, 255, 255),
        -- Text
        Text            = Color3.fromRGB(235, 235, 245),
        SubText         = Color3.fromRGB(110, 110, 130),
        Label           = Color3.fromRGB(170, 170, 190),
        -- Accent
        Accent          = Color3.fromRGB(110, 130, 255),
        AccentDark      = Color3.fromRGB(75, 95, 210),
        AccentGlow      = Color3.fromRGB(110, 130, 255),
        -- Status
        Danger          = Color3.fromRGB(255, 75, 75),
        Success         = Color3.fromRGB(50, 210, 110),
        Warning         = Color3.fromRGB(255, 185, 50),
        -- Components
        SectionBg       = Color3.fromRGB(30, 30, 38),
        SectionStroke   = Color3.fromRGB(45, 45, 58),
        BtnPrimary      = Color3.fromRGB(100, 120, 255),
        BtnSecondary    = Color3.fromRGB(42, 42, 55),
        BtnDanger       = Color3.fromRGB(220, 65, 65),
        ToggleOff       = Color3.fromRGB(50, 50, 65),
        ToggleOn        = Color3.fromRGB(50, 210, 110),
        SliderTrack     = Color3.fromRGB(40, 40, 55),
        SliderFill      = Color3.fromRGB(100, 120, 255),
        InputBg         = Color3.fromRGB(30, 30, 40),
        DropdownBg      = Color3.fromRGB(28, 28, 38),
        DropdownItem    = Color3.fromRGB(35, 35, 48),
        NotifBg         = Color3.fromRGB(32, 32, 42),
        Stroke          = Color3.fromRGB(50, 50, 65),
        -- Traffic lights
        TrafficRed      = Color3.fromRGB(255, 90, 80),
        TrafficYellow   = Color3.fromRGB(255, 195, 60),
        TrafficGreen    = Color3.fromRGB(60, 210, 90),
    },
    Light = {
        WindowBg        = Color3.fromRGB(248, 248, 252),
        TitleBar        = Color3.fromRGB(240, 240, 248),
        TitleStroke     = Color3.fromRGB(210, 210, 225),
        Sidebar         = Color3.fromRGB(233, 233, 242),
        SidebarDivider  = Color3.fromRGB(210, 210, 224),
        SidebarText     = Color3.fromRGB(100, 100, 120),
        SidebarHover    = Color3.fromRGB(222, 222, 235),
        SidebarActive   = Color3.fromRGB(210, 215, 240),
        SidebarActiveText = Color3.fromRGB(20, 20, 40),
        Text            = Color3.fromRGB(20, 20, 35),
        SubText         = Color3.fromRGB(120, 120, 145),
        Label           = Color3.fromRGB(70, 70, 90),
        Accent          = Color3.fromRGB(90, 110, 240),
        AccentDark      = Color3.fromRGB(65, 85, 210),
        AccentGlow      = Color3.fromRGB(90, 110, 240),
        Danger          = Color3.fromRGB(220, 55, 55),
        Success         = Color3.fromRGB(40, 185, 95),
        Warning         = Color3.fromRGB(220, 160, 30),
        SectionBg       = Color3.fromRGB(255, 255, 255),
        SectionStroke   = Color3.fromRGB(218, 218, 232),
        BtnPrimary      = Color3.fromRGB(90, 110, 240),
        BtnSecondary    = Color3.fromRGB(228, 228, 242),
        BtnDanger       = Color3.fromRGB(220, 55, 55),
        ToggleOff       = Color3.fromRGB(195, 195, 215),
        ToggleOn        = Color3.fromRGB(40, 185, 95),
        SliderTrack     = Color3.fromRGB(205, 205, 225),
        SliderFill      = Color3.fromRGB(90, 110, 240),
        InputBg         = Color3.fromRGB(250, 250, 255),
        DropdownBg      = Color3.fromRGB(252, 252, 255),
        DropdownItem    = Color3.fromRGB(245, 245, 252),
        NotifBg         = Color3.fromRGB(255, 255, 255),
        Stroke          = Color3.fromRGB(210, 210, 228),
        TrafficRed      = Color3.fromRGB(255, 90, 80),
        TrafficYellow   = Color3.fromRGB(255, 195, 60),
        TrafficGreen    = Color3.fromRGB(60, 210, 90),
    }
}

-- ══════════════════════════════════════════
--  DRAG SYSTEM
-- ══════════════════════════════════════════

local function MakeDraggable(handle, target)
    local dragging, startInput, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startInput = input.Position
            startPos   = target.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
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

-- ────────────────────────────────────────
-- Window Constructor
-- ────────────────────────────────────────
function Window.new(options)
    local self     = setmetatable({}, Window)
    self.Title     = options.Title    or "KreinUI"
    self.Subtitle  = options.Subtitle or ""
    self.Icon      = options.Icon     or "⬡"
    self.Theme     = options.Theme    or "Dark"
    self.Colors    = Themes[self.Theme] or Themes.Dark
    self.Tabs      = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Maximized = false

    local parent = pcall(function() return syn.protect_gui end) and CoreGui
        or (game:GetService("RunService"):IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
        or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    self.Gui = Create("ScreenGui", {
        Name             = "KreinGUI_" .. self.Title,
        Parent           = parent,
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true
    })

    -- ── MAIN WINDOW FRAME ──
    self.Window = Create("Frame", {
        BackgroundColor3  = self.Colors.WindowBg,
        BorderSizePixel   = 0,
        Position          = UDim2.new(0.5, -380, 0.5, -270),
        Size              = UDim2.new(0, 760, 0, 540),
        ClipsDescendants  = true,
        Parent            = self.Gui,
        ZIndex            = 2
    })
    AddCorner(self.Window, 14)
    AddStroke(self.Window, self.Colors.Stroke, 1.5, 0.5)
    AddShadow(self.Window, 60, 0.45)

    -- ── TITLE BAR ──
    self.TitleBar = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 52),
        ZIndex           = 10,
        Parent           = self.Window
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = self.TitleBar })
    Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -14),
        Size             = UDim2.new(1, 0, 0, 14),
        ZIndex           = 10,
        Parent           = self.TitleBar
    })
    Create("Frame", {
        BackgroundColor3 = self.Colors.TitleStroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 11,
        Parent           = self.TitleBar
    })

    -- Traffic Lights
    local tlInfo = TweenInfo.new(0.15)
    local function TrafficLight(color, posX, hoverIcon, onClick)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, posX, 0.5, -7),
            Size             = UDim2.new(0, 14, 0, 14),
            Text             = "",
            TextColor3       = Color3.fromRGB(80, 30, 20),
            Font             = Enum.Font.GothamBold,
            TextSize         = 8,
            ZIndex           = 12,
            Parent           = self.TitleBar
        })
        AddCorner(btn, 100)
        btn.MouseEnter:Connect(function()
            btn.Text = hoverIcon
            Tween(btn, tlInfo, { BackgroundColor3 = color:Lerp(Color3.new(0,0,0), 0.15) })
        end)
        btn.MouseLeave:Connect(function()
            btn.Text = ""
            Tween(btn, tlInfo, { BackgroundColor3 = color })
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    TrafficLight(self.Colors.TrafficRed,    14, "✕", function() self:Destroy() end)
    TrafficLight(self.Colors.TrafficYellow, 34, "–", function() self:ToggleMinimize() end)
    TrafficLight(self.Colors.TrafficGreen,  54, "+", function() self:ToggleMaximize() end)

    -- Icon + Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = self.Icon,
        TextColor3 = self.Colors.Accent,
        Font       = Enum.Font.GothamBold,
        TextSize   = 20,
        Size       = UDim2.new(0, 26, 0, 26),
        Position   = UDim2.new(0, 80, 0.5, -13),
        ZIndex     = 11,
        Parent     = self.TitleBar
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text              = self.Title,
        TextColor3        = self.Colors.Text,
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Size              = UDim2.new(0, 220, 0, 18),
        Position          = UDim2.new(0, 112, 0.5, -14),
        ZIndex            = 11,
        Parent            = self.TitleBar
    })
    if self.Subtitle ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = self.Subtitle,
            TextColor3     = self.Colors.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0, 220, 0, 13),
            Position       = UDim2.new(0, 112, 0.5, 3),
            ZIndex         = 11,
            Parent         = self.TitleBar
        })
    end

    MakeDraggable(self.TitleBar, self.Window)

    -- ── SIDEBAR ──
    self.Sidebar = Create("Frame", {
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 52),
        Size             = UDim2.new(0, 195, 1, -52),
        ZIndex           = 6,
        Parent           = self.Window
    })
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        ZIndex           = 7,
        Parent           = self.Sidebar
    })

    local sidebarHeader = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 0, 0),
        Size                   = UDim2.new(1, 0, 0, 16),
        ZIndex                 = 7,
        Parent                 = self.Sidebar
    })
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 16, 1, -1),
        Size             = UDim2.new(1, -32, 0, 1),
        ZIndex           = 8,
        Parent           = sidebarHeader
    })

    self.SidebarScroll = Create("ScrollingFrame", {
        BackgroundTransparency  = 1,
        BorderSizePixel         = 0,
        Position                = UDim2.new(0, 0, 0, 16),
        Size                    = UDim2.new(1, 0, 1, -32),
        CanvasSize              = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        ScrollBarThickness      = 2,
        ScrollBarImageColor3    = self.Colors.Accent,
        ScrollingDirection      = Enum.ScrollingDirection.Y,
        ZIndex                  = 7,
        Parent                  = self.Sidebar
    })

    self.SidebarLayout = Create("UIListLayout", {
        Padding               = UDim.new(0, 4),
        FillDirection         = Enum.FillDirection.Vertical,
        HorizontalAlignment   = Enum.HorizontalAlignment.Center,
        VerticalAlignment     = Enum.VerticalAlignment.Top,
        SortOrder             = Enum.SortOrder.LayoutOrder,
        Parent                = self.SidebarScroll
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
        Parent        = self.SidebarScroll
    })

    -- ── CONTENT AREA ──
    self.ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        Position               = UDim2.new(0, 196, 0, 52),
        Size                   = UDim2.new(1, -196, 1, -52),
        ZIndex                 = 3,
        Parent                 = self.Window
    })

    -- ── OPEN ANIMATION ──
    self.Window.Size = UDim2.new(0, 760, 0, 0)
    self.Window.BackgroundTransparency = 1
    Tween(self.Window, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size                 = UDim2.new(0, 760, 0, 540),
        BackgroundTransparency = 0
    })

    table.insert(Library.Windows, self)
    return self
end

-- ────────────────────────────────────────
-- Create Tab
-- ────────────────────────────────────────
function Window:CreateTab(options)
    local C = self.Colors
    local tab = {
        Title  = options.Title or "Tab",
        Icon   = options.Icon  or "○",
        Window = self,
    }

    -- ── Tab content frame ──
    tab.Frame = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Visible                = false,
        ZIndex                 = 3,
        Parent                 = self.ContentArea
    })

    tab.Scroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -6, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = C.Accent,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        ZIndex                 = 3,
        Parent                 = tab.Frame
    })

    Create("UIListLayout", {
        Padding             = UDim.new(0, 10),
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = tab.Scroll
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft   = UDim.new(0, 2),
        PaddingRight  = UDim.new(0, 2),
        Parent        = tab.Scroll
    })

    -- ── Sidebar Button ──
    local tabIndex = #self.Tabs + 1
    tab.SideBtn = Create("TextButton", {
        BackgroundColor3    = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Size                = UDim2.new(1, 0, 0, 42),
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 8,
        LayoutOrder         = tabIndex,
        Parent              = self.SidebarScroll
    })
    AddCorner(tab.SideBtn, 9)

    tab.Indicator = Create("Frame", {
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0.5, -12),
        Size             = UDim2.new(0, 3, 0, 24),
        ZIndex           = 9,
        Visible          = false,
        Parent           = tab.SideBtn
    })
    AddCorner(tab.Indicator, 3)

    tab.IconLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text       = tab.Icon,
        TextColor3 = C.SidebarText,
        Font       = Enum.Font.Gotham,
        TextSize   = 16,
        Size       = UDim2.new(0, 26, 1, 0),
        Position   = UDim2.new(0, 14, 0, 0),
        ZIndex     = 9,
        Parent     = tab.SideBtn
    })

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
        Parent         = tab.SideBtn
    })

    local hoverTween = TweenInfo.new(0.18)
    tab.SideBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.SideBtn, hoverTween, { BackgroundTransparency = 0, BackgroundColor3 = C.SidebarHover })
        end
    end)
    tab.SideBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.SideBtn, hoverTween, { BackgroundTransparency = 1 })
        end
    end)
    tab.SideBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    -- ════════════════════════════════
    --  COMPONENT HELPERS
    -- ════════════════════════════════

    local function MakeRow(title, height)
        local row = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, height or 46),
            ZIndex                 = 4,
            Parent                 = tab.Scroll
        })
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = title,
            TextColor3     = C.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 10, 0, 0),
            ZIndex         = 4,
            Parent         = row
        })
        local right = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.5, -10, 1, 0),
            Position               = UDim2.new(0.5, 0, 0, 0),
            ZIndex                 = 4,
            Parent                 = row
        })
        return row, right
    end

    -- ── CREATE SECTION ──
    function tab:CreateSection(title)
        local section = {}

        section.Frame = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            ZIndex           = 4,
            Parent           = tab.Scroll
        })
        AddCorner(section.Frame, 10)
        AddStroke(section.Frame, C.SectionStroke, 1, 0.4)

        local header = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 0, 30),
            ZIndex                 = 5,
            Parent                 = section.Frame
        })

        -- FIXED: Removed LetterSpacing (not valid in Roblox TextLabel)
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = title:upper(),
            TextColor3     = C.SubText,
            Font           = Enum.Font.GothamBold,
            TextSize       = 9,
            -- LetterSpacing removed: this property does not exist in Roblox
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(1, -20, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 5,
            Parent         = header
        })
        Create("Frame", {
            BackgroundColor3 = C.SectionStroke,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 12, 1, -1),
            Size             = UDim2.new(1, -24, 0, 1),
            ZIndex           = 5,
            Parent           = header
        })

        section.List = Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = section.Frame
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 30),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            Parent        = section.Frame
        })

        section.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Frame.Size = UDim2.new(0.96, 0, 0, section.List.AbsoluteContentSize.Y + 46)
        end)

        function section:AddRow(title2, height2)
            local row2 = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, height2 or 44),
                ZIndex                 = 5,
                Parent                 = section.Frame
            })
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = title2,
                TextColor3     = C.Label,
                Font           = Enum.Font.Gotham,
                TextSize       = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(0.5, 0, 1, 0),
                Position       = UDim2.new(0, 4, 0, 0),
                ZIndex         = 5,
                Parent         = row2
            })
            local right2 = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(0.5, -4, 1, 0),
                Position               = UDim2.new(0.5, 0, 0, 0),
                ZIndex                 = 5,
                Parent                 = row2
            })
            return row2, right2
        end

        return section
    end

    -- ── CREATE BUTTON (PREMIUM VERSION) ──
    --
    -- Instead of a plain TextButton, we use MakePremiumButton which adds:
    --   1. UIGradient gloss layer on the button face
    --   2. Shine strip (semi-transparent white Frame) over the top half
    --   3. Outer glow frame that pulses on hover
    --   4. Text shadow for depth
    --   5. Multi-stage tweens: hover → lighten+glow, press → darken+shrink, release → restore
    --
    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local bgColor  = style == "danger"    and C.BtnDanger
                      or style == "secondary" and C.BtnSecondary
                      or C.BtnPrimary
        local txtColor = (style == "secondary") and C.Text or Color3.fromRGB(255, 255, 255)

        -- MakePremiumButton parents its outer glow frame to tab.Scroll
        -- and returns (glowFrame, clickableBtn)
        local glowFrame, btn = MakePremiumButton(
            tab.Scroll,    -- parent
            text,          -- button text
            bgColor,       -- base background color
            txtColor,      -- text color
            4,             -- base ZIndex
            callback,      -- click callback
            style          -- style hint (unused inside but passed for future use)
        )

        return btn  -- expose the TextButton for any further manipulation
    end

    -- ── CREATE TOGGLE ──
    function tab:CreateToggle(options)
        local enabled  = options.Default  or false
        local callback = options.Callback or function() end
        local row, right = MakeRow(options.Title or "Toggle")

        local trackOff = C.ToggleOff
        local trackOn  = C.ToggleOn
        local track = Create("Frame", {
            BackgroundColor3 = enabled and trackOn or trackOff,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -8, 0.5, 0),
            Size             = UDim2.new(0, 46, 0, 24),
            ZIndex           = 5,
            Parent           = right
        })
        AddCorner(track, 12)

        local knob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0),
            Size             = UDim2.new(0, 20, 0, 20),
            ZIndex           = 6,
            Parent           = track
        })
        AddCorner(knob, 10)
        AddShadow(knob, 8, 0.6)

        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quart)
        local function refresh()
            Tween(track, ti, { BackgroundColor3 = enabled and trackOn or trackOff })
            Tween(knob,  ti, { Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0) })
            callback(enabled)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                refresh()
            end
        end)

        return {
            Set = function(v) enabled = v; refresh() end,
            Get = function()  return enabled end
        }
    end

    -- ── CREATE SLIDER ──
    function tab:CreateSlider(options)
        local minV = options.Min     or 0
        local maxV = options.Max     or 100
        local val  = math.clamp(options.Default or minV, minV, maxV)
        local callback = options.Callback or function() end
        local suffix   = options.Suffix   or ""

        local container = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.96, 0, 0, 56),
            ZIndex                 = 4,
            Parent                 = tab.Scroll
        })

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Slider",
            TextColor3     = C.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.7, 0, 0, 20),
            Position       = UDim2.new(0, 10, 0, 6),
            ZIndex         = 4,
            Parent         = container
        })
        local valLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = tostring(val) .. suffix,
            TextColor3     = C.Accent,
            Font           = Enum.Font.GothamBold,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.3, -10, 0, 20),
            Position       = UDim2.new(0.7, 0, 0, 6),
            ZIndex         = 4,
            Parent         = container
        })

        local trackBg = Create("Frame", {
            BackgroundColor3 = C.SliderTrack,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 10, 0, 34),
            Size             = UDim2.new(1, -20, 0, 5),
            ZIndex           = 4,
            Parent           = container
        })
        AddCorner(trackBg, 3)

        local pct = (val - minV) / (maxV - minV)
        local fill = Create("Frame", {
            BackgroundColor3 = C.SliderFill,
            BorderSizePixel  = 0,
            Size             = UDim2.new(pct, 0, 1, 0),
            ZIndex           = 5,
            Parent           = trackBg
        })
        AddCorner(fill, 3)

        local thumb = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(pct, 0, 0.5, 0),
            Size             = UDim2.new(0, 14, 0, 14),
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = trackBg
        })
        AddCorner(thumb, 7)
        AddShadow(thumb, 10, 0.55)

        local function setVal(p)
            p   = math.clamp(p, 0, 1)
            val = math.floor(minV + (maxV - minV) * p + 0.5)
            valLabel.Text = tostring(val) .. suffix
            fill.Size  = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            callback(val)
        end

        local dragging = false
        local function onMove(input)
            local abs = trackBg.AbsolutePosition.X
            local sz  = trackBg.AbsoluteSize.X
            setVal((input.Position.X - abs) / sz)
        end

        trackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; onMove(input)
            end
        end)
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement or
                input.UserInputType == Enum.UserInputType.Touch
            ) then
                onMove(input)
            end
        end)

        return {
            Set = function(v) setVal(math.clamp((v-minV)/(maxV-minV),0,1)) end,
            Get = function()  return val end
        }
    end

    -- ── CREATE DROPDOWN ──
    function tab:CreateDropdown(options)
        local items    = options.Items    or {}
        local selected = options.Default  or (items[1] or "Select...")
        local callback = options.Callback or function() end

        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ClipsDescendants = false,
            ZIndex           = 8,
            Parent           = tab.Scroll
        })
        AddCorner(container, 9)
        AddStroke(container, C.SectionStroke, 1, 0.4)

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Dropdown",
            TextColor3     = C.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.5, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 8,
            Parent         = container
        })

        local selLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = selected,
            TextColor3     = C.Text,
            Font           = Enum.Font.GothamBold,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size           = UDim2.new(0.45, -28, 1, 0),
            Position       = UDim2.new(0.5, 0, 0, 0),
            TextTruncate   = Enum.TextTruncate.AtEnd,
            ZIndex         = 8,
            Parent         = container
        })

        local arrowBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Text       = "▾",
            TextColor3 = C.SubText,
            Font       = Enum.Font.GothamBold,
            TextSize   = 11,
            Size       = UDim2.new(0, 22, 1, 0),
            Position   = UDim2.new(1, -26, 0, 0),
            ZIndex     = 8,
            Parent     = container
        })

        local listFrame = Create("Frame", {
            BackgroundColor3 = C.DropdownBg,
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 0, 1, 4),
            Size             = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Visible          = false,
            ZIndex           = 20,
            Parent           = container
        })
        AddCorner(listFrame, 9)
        AddStroke(listFrame, C.SectionStroke, 1, 0.4)

        Create("UIListLayout", {
            Padding             = UDim.new(0, 2),
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            Parent              = listFrame
        })
        AddPadding(listFrame, 4, 4, 4, 4)

        local function buildList()
            for _, ch in pairs(listFrame:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemBtn = Create("TextButton", {
                    BackgroundColor3    = C.DropdownItem,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel     = 0,
                    Text                = item,
                    TextColor3          = C.Text,
                    Font                = Enum.Font.Gotham,
                    TextSize            = 11,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    Size                = UDim2.new(1, 0, 0, 28),
                    AutoButtonColor     = false,
                    ZIndex              = 21,
                    Parent              = listFrame
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
                    callback(item)
                end)
            end
            local listH = math.min(#items * 30 + 8, 180)
            listFrame.Size = UDim2.new(1, 0, 0, listH)
        end
        buildList()

        local open = false
        arrowBtn.MouseButton1Click:Connect(function()
            open = not open
            listFrame.Visible = open
        end)

        return {
            SetItems = function(newItems) items = newItems; buildList() end,
            GetValue = function() return selected end,
            Set      = function(v) selected = v; selLabel.Text = v end
        }
    end

    -- ── CREATE INPUT ──
    function tab:CreateInput(options)
        local callback    = options.Callback    or function() end
        local onChanged   = options.OnChanged   or function() end
        local placeholder = options.Placeholder or "Type here..."

        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 46),
            ZIndex           = 4,
            Parent           = tab.Scroll
        })
        AddCorner(container, 9)
        AddStroke(container, C.SectionStroke, 1, 0.4)

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Input",
            TextColor3     = C.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.4, 0, 1, 0),
            Position       = UDim2.new(0, 12, 0, 0),
            ZIndex         = 4,
            Parent         = container
        })

        local inputBox = Create("TextBox", {
            BackgroundColor3     = C.InputBg,
            BorderSizePixel      = 0,
            PlaceholderText      = placeholder,
            PlaceholderColor3    = C.SubText,
            Text                 = options.Default or "",
            TextColor3           = C.Text,
            Font                 = Enum.Font.Gotham,
            TextSize             = 11,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ClearTextOnFocus     = options.ClearOnFocus or false,
            Size                 = UDim2.new(0.55, -12, 0, 26),
            Position             = UDim2.new(0.42, 0, 0.5, -13),
            ZIndex               = 5,
            Parent               = container
        })
        AddCorner(inputBox, 6)
        AddPadding(inputBox, 0, 0, 8, 8)
        AddStroke(inputBox, C.Stroke, 1, 0.5)

        inputBox.FocusLost:Connect(function(enter)
            if enter then callback(inputBox.Text) end
        end)
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            onChanged(inputBox.Text)
        end)

        return {
            Get = function() return inputBox.Text end,
            Set = function(v) inputBox.Text = v end
        }
    end

    -- ── CREATE LABEL ──
    function tab:CreateLabel(text, color)
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = text,
            TextColor3     = color or C.SubText,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.96, 0, 0, 24),
            ZIndex         = 4,
            Parent         = tab.Scroll
        })
        AddPadding(lbl, 0, 0, 12, 4)
        return {
            Set = function(v) lbl.Text = v end,
            SetColor = function(col) lbl.TextColor3 = col end
        }
    end

    -- ── CREATE KEYBIND ──
    function tab:CreateKeybind(options)
        local key      = options.Default
        local callback = options.Callback or function() end
        local row, right = MakeRow(options.Title or "Keybind")

        local btn = Create("TextButton", {
            BackgroundColor3 = C.BtnSecondary,
            BorderSizePixel  = 0,
            Text             = key and key.Name or "None",
            TextColor3       = C.Accent,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, -8, 0.5, 0),
            Size             = UDim2.new(0, 76, 0, 24),
            AutoButtonColor  = false,
            ZIndex           = 5,
            Parent           = right
        })
        AddCorner(btn, 6)
        AddStroke(btn, C.Stroke, 1, 0.5)

        local listening = false
        btn.MouseButton1Click:Connect(function()
            if listening then return end
            listening     = true
            btn.Text      = "..."
            btn.TextColor3 = C.Warning
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    btn.Text = key.Name
                    btn.TextColor3 = C.Accent
                    listening = false
                    conn:Disconnect()
                    callback(key)
                end
            end)
            task.delay(5, function()
                if listening then
                    listening = false
                    btn.Text = key and key.Name or "None"
                    btn.TextColor3 = C.Accent
                    if conn then conn:Disconnect() end
                end
            end)
        end)

        return {
            GetKey = function() return key end,
            SetKey = function(k) key = k; btn.Text = k.Name end
        }
    end

    -- ── CREATE COLOR PICKER ──
    function tab:CreateColorPicker(options)
        local color    = options.Default  or Color3.fromRGB(100, 120, 255)
        local callback = options.Callback or function() end

        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0.96, 0, 0, 120),
            ZIndex           = 4,
            Parent           = tab.Scroll
        })
        AddCorner(container, 10)
        AddStroke(container, C.SectionStroke, 1, 0.4)

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text           = options.Title or "Color",
            TextColor3     = C.Label,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size           = UDim2.new(0.6, 0, 0, 20),
            Position       = UDim2.new(0, 12, 0, 4),
            ZIndex         = 5,
            Parent         = container
        })

        local preview = Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Position         = UDim2.new(1, -52, 0, 8),
            Size             = UDim2.new(0, 36, 0, 36),
            ZIndex           = 5,
            Parent           = container
        })
        AddCorner(preview, 7)
        AddStroke(preview, C.Stroke, 1, 0.4)

        local h, s, v = Color3.toHSV(color)

        local function refresh()
            color = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = color
            callback(color)
        end

        local hueTrack = Create("ImageLabel", {
            Image           = "rbxassetid://9607867758",
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            Position         = UDim2.new(0, 12, 0, 52),
            Size             = UDim2.new(1, -64, 0, 10),
            ZIndex           = 5,
            Parent           = container
        })
        AddCorner(hueTrack, 5)

        local hueKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(h, 0, 0.5, 0),
            Size             = UDim2.new(0, 12, 0, 12),
            ZIndex           = 6,
            Parent           = hueTrack
        })
        AddCorner(hueKnob, 6)
        AddStroke(hueKnob, Color3.fromRGB(255,255,255), 2, 0.2)

        local function makeMini(yOff, val0, label)
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = label,
                TextColor3     = C.SubText,
                Font           = Enum.Font.Gotham,
                TextSize       = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size           = UDim2.new(0, 20, 0, 12),
                Position       = UDim2.new(0, 12, 0, yOff),
                ZIndex         = 5,
                Parent         = container
            })
            local tr = Create("Frame", {
                BackgroundColor3 = C.SliderTrack,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0, 32, 0, yOff + 1),
                Size             = UDim2.new(1, -96, 0, 8),
                ZIndex           = 5,
                Parent           = container
            })
            AddCorner(tr, 4)
            local fl = Create("Frame", {
                BackgroundColor3 = C.SliderFill,
                BorderSizePixel  = 0,
                Size             = UDim2.new(val0, 0, 1, 0),
                ZIndex           = 6,
                Parent           = tr
            })
            AddCorner(fl, 4)
            local kn = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0.5,0.5),
                Position         = UDim2.new(val0,0,0.5,0),
                Size             = UDim2.new(0,12,0,12),
                ZIndex           = 7,
                Parent           = tr
            })
            AddCorner(kn, 6)
            return tr, fl, kn
        end

        local satTr, satFl, satKn = makeMini(70, s, "S")
        local valTr, valFl, valKn = makeMini(86, v, "V")

        local draggingHue, draggingSat, draggingVal = false,false,false

        hueTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                h = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X)/hueTrack.AbsoluteSize.X,0,1)
                hueKnob.Position = UDim2.new(h,0,0.5,0)
                refresh()
            end
        end)
        satTr.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                draggingSat = true
                s = math.clamp((input.Position.X - satTr.AbsolutePosition.X)/satTr.AbsoluteSize.X,0,1)
                satKn.Position = UDim2.new(s,0,0.5,0)
                satFl.Size = UDim2.new(s,0,1,0)
                refresh()
            end
        end)
        valTr.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                draggingVal = true
                v = math.clamp((input.Position.X - valTr.AbsolutePosition.X)/valTr.AbsoluteSize.X,0,1)
                valKn.Position = UDim2.new(v,0,0.5,0)
                valFl.Size = UDim2.new(v,0,1,0)
                refresh()
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = false; draggingSat = false; draggingVal = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                if draggingHue then
                    h = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X)/hueTrack.AbsoluteSize.X,0,1)
                    hueKnob.Position = UDim2.new(h,0,0.5,0)
                    refresh()
                elseif draggingSat then
                    s = math.clamp((input.Position.X - satTr.AbsolutePosition.X)/satTr.AbsoluteSize.X,0,1)
                    satKn.Position = UDim2.new(s,0,0.5,0)
                    satFl.Size = UDim2.new(s,0,1,0)
                    refresh()
                elseif draggingVal then
                    v = math.clamp((input.Position.X - valTr.AbsolutePosition.X)/valTr.AbsoluteSize.X,0,1)
                    valKn.Position = UDim2.new(v,0,0.5,0)
                    valFl.Size = UDim2.new(v,0,1,0)
                    refresh()
                end
            end
        end)

        return {
            GetColor = function() return color end,
            SetColor = function(c)
                color = c
                h, s, v = Color3.toHSV(c)
                hueKnob.Position = UDim2.new(h,0,0.5,0)
                satKn.Position = UDim2.new(s,0,0.5,0)
                satFl.Size = UDim2.new(s,0,1,0)
                valKn.Position = UDim2.new(v,0,0.5,0)
                valFl.Size = UDim2.new(v,0,1,0)
                preview.BackgroundColor3 = c
            end
        }
    end

    -- ── CREATE SEPARATOR ──
    function tab:CreateSeparator(label)
        local sep = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.96, 0, 0, 18),
            ZIndex                 = 4,
            Parent                 = tab.Scroll
        })
        if label and label ~= "" then
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Text           = label,
                TextColor3     = C.SubText,
                Font           = Enum.Font.GothamBold,
                TextSize       = 9,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size           = UDim2.new(0.3, 0, 1, 0),
                Position       = UDim2.new(0.35, 0, 0, 0),
                ZIndex         = 4,
                Parent         = sep
            })
        end
        Create("Frame", {
            BackgroundColor3 = C.Stroke,
            BorderSizePixel  = 0,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = label and UDim2.new(0.33, -4, 0, 1) or UDim2.new(1, 0, 0, 1),
            ZIndex           = 4,
            Parent           = sep
        })
        if label and label ~= "" then
            Create("Frame", {
                BackgroundColor3 = C.Stroke,
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0.67, 4, 0.5, 0),
                Size             = UDim2.new(0.33, -4, 0, 1),
                ZIndex           = 4,
                Parent           = sep
            })
        end
    end

    self.Tabs[#self.Tabs + 1] = tab
    if not self.ActiveTab then
        self:SelectTab(tab)
    end

    return tab
end

-- ────────────────────────────────────────
-- Select Tab
-- ────────────────────────────────────────
function Window:SelectTab(tab)
    local prevTween = TweenInfo.new(0.18)
    local C = self.Colors

    if self.ActiveTab and self.ActiveTab ~= tab then
        local prev = self.ActiveTab
        prev.Frame.Visible       = false
        prev.Indicator.Visible   = false
        Tween(prev.SideBtn, prevTween, { BackgroundTransparency = 1 })
        Tween(prev.TitleLabel, prevTween, { TextColor3 = C.SidebarText })
        Tween(prev.IconLabel,  prevTween, { TextColor3 = C.SidebarText })
    end

    tab.Frame.Visible     = true
    tab.Indicator.Visible = true
    Tween(tab.SideBtn,    prevTween, { BackgroundTransparency = 0, BackgroundColor3 = C.SidebarActive })
    Tween(tab.TitleLabel, prevTween, { TextColor3 = C.SidebarActiveText })
    Tween(tab.IconLabel,  prevTween, { TextColor3 = C.Accent })

    self.ActiveTab = tab
end

-- ────────────────────────────────────────
-- Notification
-- ────────────────────────────────────────
function Window:Notification(options)
    local C     = self.Colors
    local title = options.Title       or "Notification"
    local desc  = options.Description or ""
    local dur   = options.Duration    or 3.5
    local ntype = options.Type        or "info"

    local accentColor = ntype == "success" and C.Success
                     or ntype == "danger"  and C.Danger
                     or ntype == "warning" and C.Warning
                     or C.Accent

    local notif = Create("Frame", {
        BackgroundColor3 = C.NotifBg,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1, 20, 1, -88),
        Size             = UDim2.new(0, 260, 0, 72),
        ZIndex           = 100,
        Parent           = self.Gui
    })
    AddCorner(notif, 10)
    AddStroke(notif, accentColor, 1, 0.5)
    AddShadow(notif, 30, 0.5)

    Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 0, 0, 0),
        Size             = UDim2.new(0, 3, 1, 0),
        ZIndex           = 101,
        Parent           = notif
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
        Parent         = notif
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
        Parent         = notif
    })

    local progressBg = Create("Frame", {
        BackgroundColor3 = C.Stroke,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, 14, 1, -6),
        Size             = UDim2.new(1, -28, 0, 2),
        ZIndex           = 101,
        Parent           = notif
    })
    AddCorner(progressBg, 1)
    local progressFill = Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 102,
        Parent           = progressBg
    })
    AddCorner(progressFill, 1)
    Tween(progressFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -276, 1, -88)
    })

    task.delay(dur, function()
        Tween(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 20, 1, -88)
        })
        task.delay(0.4, function() notif:Destroy() end)
    end)

    return notif
end

-- ────────────────────────────────────────
-- Window Controls
-- ────────────────────────────────────────
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
        Tween(self.Window, ti, {
            Size     = UDim2.new(0, vp.X, 0, vp.Y),
            Position = UDim2.new(0, 0, 0, 0)
        })
    else
        Tween(self.Window, ti, { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:SetTheme(themeName)
    if Themes[themeName] then
        self.Theme  = themeName
        self.Colors = Themes[themeName]
    end
end

function Window:Destroy()
    Tween(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 760, 0, 0),
        BackgroundTransparency = 1
    })
    task.delay(0.4, function()
        self.Gui:Destroy()
    end)
    for i, w in ipairs(Library.Windows) do
        if w == self then table.remove(Library.Windows, i); break end
    end
end

-- ════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════

function Library.CreateWindow(options)
    return Window.new(options)
end

Library.Themes = Themes

return Library
