-- KreinGuiV2 Ultimate - Full fix + Profile Sidebar + Live Theme
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

local function MakePremiumButton(parent, text, bgColor, txtColor, zIndex, callback, style)
    local glowFrame = Create("Frame", {
        BackgroundColor3 = bgColor,
        BackgroundTransparency = 0.75,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0.96, 0, 0, 46),
        ZIndex           = zIndex - 1,
        Parent           = parent
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
    -- Gradient gloss
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(200,200,200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(130,130,130))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.72),
            NumberSequenceKeypoint.new(0.5, 0.92),
            NumberSequenceKeypoint.new(1, 0.78)
        }),
        Rotation = 90,
        Parent = btnFrame
    })
    -- Shine
    local shine = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0.45,0),
        ZIndex = zIndex+1,
        Parent = btnFrame
    })
    AddCorner(shine, 10)
    Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(1, 1.0)
        }),
        Rotation = 90,
        Parent = shine
    })
    local btn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = txtColor,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.new(1,0,1,0),
        ZIndex = zIndex+2,
        AutoButtonColor = false,
        Parent = btnFrame
    })
    -- Text shadow
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(0,0,0),
        TextTransparency = 0.7,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,1),
        ZIndex = zIndex+1,
        Parent = btnFrame
    })
    AddStroke(btnFrame, bgColor:Lerp(Color3.new(1,1,1),0.45), 1.5, 0.3)

    local tiHover = TweenInfo.new(0.18, Enum.EasingStyle.Quart)
    local tiPress = TweenInfo.new(0.08, Enum.EasingStyle.Quart)
    local tiRelease = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local colorHover = bgColor:Lerp(Color3.new(1,1,1), 0.14)
    local colorPress = bgColor:Lerp(Color3.new(0,0,0), 0.1)

    btn.MouseEnter:Connect(function()
        Tween(btnFrame, tiHover, { BackgroundColor3 = colorHover })
        Tween(glowFrame, tiHover, { BackgroundTransparency = 0.6, BackgroundColor3 = colorHover })
        Tween(shine, tiHover, { BackgroundTransparency = 0.72 })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btnFrame, tiRelease, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiRelease, { BackgroundTransparency = 0.75, BackgroundColor3 = bgColor })
        Tween(shine, tiRelease, { BackgroundTransparency = 0.82 })
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btnFrame, tiPress, { BackgroundColor3 = colorPress })
        Tween(glowFrame, tiPress, {
            BackgroundTransparency = 0.88,
            Size = UDim2.new(0.94,0,0,44)
        })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btnFrame, tiRelease, { BackgroundColor3 = bgColor })
        Tween(glowFrame, tiRelease, {
            BackgroundTransparency = 0.75,
            Size = UDim2.new(0.96,0,0,46)
        })
    end)
    btn.MouseButton1Click:Connect(callback or function() end)
    return glowFrame, btnFrame
end

local Themes = {
    Dark = {
        WindowBg = Color3.fromRGB(22,22,26),
        TitleBar = Color3.fromRGB(28,28,34),
        Sidebar = Color3.fromRGB(18,18,22),
        SidebarDivider = Color3.fromRGB(40,40,50),
        SidebarText = Color3.fromRGB(145,145,165),
        SidebarHover = Color3.fromRGB(32,32,40),
        SidebarActive = Color3.fromRGB(38,38,52),
        SidebarActiveText = Color3.fromRGB(255,255,255),
        Text = Color3.fromRGB(235,235,245),
        SubText = Color3.fromRGB(110,110,130),
        Accent = Color3.fromRGB(110,130,255),
        Danger = Color3.fromRGB(255,75,75),
        Success = Color3.fromRGB(50,210,110),
        Warning = Color3.fromRGB(255,185,50),
        SectionBg = Color3.fromRGB(30,30,38),
        SectionStroke = Color3.fromRGB(45,45,58),
        BtnPrimary = Color3.fromRGB(100,120,255),
        BtnSecondary = Color3.fromRGB(55,55,72),
        BtnDanger = Color3.fromRGB(220,65,65),
        ToggleOff = Color3.fromRGB(50,50,65),
        ToggleOn = Color3.fromRGB(50,210,110),
        SliderTrack = Color3.fromRGB(40,40,55),
        SliderFill = Color3.fromRGB(100,120,255),
        InputBg = Color3.fromRGB(30,30,40),
        DropdownBg = Color3.fromRGB(28,28,38),
        NotifBg = Color3.fromRGB(32,32,42),
        Stroke = Color3.fromRGB(50,50,65),
        TrafficRed = Color3.fromRGB(255,90,80),
        TrafficYellow = Color3.fromRGB(255,195,60),
        TrafficGreen = Color3.fromRGB(60,210,90)
    },
    Light = {
        WindowBg = Color3.fromRGB(248,248,252),
        TitleBar = Color3.fromRGB(240,240,248),
        Sidebar = Color3.fromRGB(233,233,242),
        SidebarDivider = Color3.fromRGB(210,210,224),
        SidebarText = Color3.fromRGB(100,100,120),
        SidebarHover = Color3.fromRGB(222,222,235),
        SidebarActive = Color3.fromRGB(210,215,240),
        SidebarActiveText = Color3.fromRGB(20,20,40),
        Text = Color3.fromRGB(20,20,35),
        SubText = Color3.fromRGB(120,120,145),
        Accent = Color3.fromRGB(90,110,240),
        Danger = Color3.fromRGB(220,55,55),
        Success = Color3.fromRGB(40,185,95),
        Warning = Color3.fromRGB(220,160,30),
        SectionBg = Color3.fromRGB(255,255,255),
        SectionStroke = Color3.fromRGB(218,218,232),
        BtnPrimary = Color3.fromRGB(90,110,240),
        BtnSecondary = Color3.fromRGB(228,228,242),
        BtnDanger = Color3.fromRGB(220,55,55),
        ToggleOff = Color3.fromRGB(195,195,215),
        ToggleOn = Color3.fromRGB(40,185,95),
        SliderTrack = Color3.fromRGB(205,205,225),
        SliderFill = Color3.fromRGB(90,110,240),
        InputBg = Color3.fromRGB(250,250,255),
        DropdownBg = Color3.fromRGB(252,252,255),
        NotifBg = Color3.fromRGB(255,255,255),
        Stroke = Color3.fromRGB(210,210,228),
        TrafficRed = Color3.fromRGB(255,90,80),
        TrafficYellow = Color3.fromRGB(255,195,60),
        TrafficGreen = Color3.fromRGB(60,210,90)
    }
}

local Library = {}
Library.Windows = {}
Library.Themes = Themes

local Window = {}
Window.__index = Window

local function MakeDraggable(handle, target)
    local dragging, startInput, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = target.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Title = options.Title or "KreinUI"
    self.Subtitle = options.Subtitle or ""
    self.Icon = options.Icon or "⬡"
    self.Theme = options.Theme or "Dark"
    self.Colors = Themes[self.Theme]
    self.Tabs = {}
    self.ActiveTab = nil
    self._updaters = {}  -- live theme updaters

    local parent = (syn and syn.protect_gui and CoreGui) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = Create("ScreenGui", {
        Name = "KreinGUI_" .. self.Title,
        Parent = parent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })

    self.Window = Create("Frame", {
        BackgroundColor3 = self.Colors.WindowBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -380, 0.5, -270),
        Size = UDim2.new(0, 760, 0, 540),
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 2
    })
    AddCorner(self.Window, 14)
    AddStroke(self.Window, self.Colors.Stroke, 1.5, 0.5)
    AddShadow(self.Window, 60, 0.45)

    self.TitleBar = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,52),
        ZIndex = 10,
        Parent = self.Window
    })
    Create("UICorner", { CornerRadius = UDim.new(0,14), Parent = self.TitleBar })
    Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-14),
        Size = UDim2.new(1,0,0,14),
        ZIndex = 10,
        Parent = self.TitleBar
    })
    local titleStroke = Create("Frame", {
        BackgroundColor3 = self.Colors.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-1),
        Size = UDim2.new(1,0,0,1),
        ZIndex = 11,
        Parent = self.TitleBar
    })

    -- Traffic lights dengan area klik lebih besar
    local function TrafficLight(color, posX, icon, callback)
        local btn = Create("TextButton", {
            Active = true,  -- biar klik lancar
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, posX, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18), -- perbesar
            Text = "",
            TextColor3 = Color3.fromRGB(80,30,20),
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            ZIndex = 12,
            AutoButtonColor = false,
            Parent = self.TitleBar
        })
        AddCorner(btn, 100)
        btn.MouseEnter:Connect(function()
            btn.Text = icon
            Tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = color:Lerp(Color3.new(0,0,0),0.15) })
        end)
        btn.MouseLeave:Connect(function()
            btn.Text = ""
            Tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = color })
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    TrafficLight(self.Colors.TrafficRed, 12, "✕", function() self:Destroy() end)
    TrafficLight(self.Colors.TrafficYellow, 34, "–", function() self:ToggleMinimize() end)
    TrafficLight(self.Colors.TrafficGreen, 56, "+", function() self:ToggleMaximize() end)

    -- Title text
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Icon,
        TextColor3 = self.Colors.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(0,90,0.5,-13),
        ZIndex = 11,
        Parent = self.TitleBar
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0,220,0,18),
        Position = UDim2.new(0,122,0.5,-14),
        ZIndex = 11,
        Parent = self.TitleBar
    })
    if self.Subtitle ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = self.Subtitle,
            TextColor3 = self.Colors.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0,220,0,13),
            Position = UDim2.new(0,122,0.5,3),
            ZIndex = 11,
            Parent = self.TitleBar
        })
    end

    MakeDraggable(self.TitleBar, self.Window)

    -- ── SIDEBAR ──
    self.Sidebar = Create("Frame", {
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,52),
        Size = UDim2.new(0,195,1,-52),
        ZIndex = 6,
        Parent = self.Window
    })
    Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarDivider,
        BorderSizePixel = 0,
        Position = UDim2.new(1,-1,0,0),
        Size = UDim2.new(0,1,1,0),
        ZIndex = 7,
        Parent = self.Sidebar
    })

    -- Sidebar scroll (tab hanya di atas, bawah untuk profil)
    self.SidebarScroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,8),
        Size = UDim2.new(1,0,1,-68), -- dikurangi 60 untuk profil
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Colors.Accent,
        ZIndex = 7,
        Parent = self.Sidebar
    })
    self.SidebarLayout = Create("UIListLayout", {
        Padding = UDim.new(0,4),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.SidebarScroll
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0,4),
        PaddingBottom = UDim.new(0,4),
        PaddingLeft = UDim.new(0,8),
        PaddingRight = UDim.new(0,8),
        Parent = self.SidebarScroll
    })

    -- Profil di bawah sidebar
    self.ProfileFrame = Create("Frame", {
        BackgroundColor3 = self.Colors.SidebarActive,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-60),
        Size = UDim2.new(1,-8,0,52),
        ZIndex = 7,
        Parent = self.Sidebar
    })
    AddCorner(self.ProfileFrame, 10)
    local userId = game.Players.LocalPlayer.UserId
    local username = game.Players.LocalPlayer.Name
    -- Avatar
    local avatar = Create("ImageLabel", {
        BackgroundColor3 = self.Colors.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0,8,0.5, -16),
        Size = UDim2.new(0,32,0,32),
        ZIndex = 8,
        Image = game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
        Parent = self.ProfileFrame
    })
    AddCorner(avatar, 16)
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = username,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -56, 0, 18),
        Position = UDim2.new(0, 48, 0.5, -14),
        ZIndex = 8,
        Parent = self.ProfileFrame
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Online",
        TextColor3 = self.Colors.Success,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -56, 0, 12),
        Position = UDim2.new(0, 48, 0.5, 6),
        ZIndex = 8,
        Parent = self.ProfileFrame
    })
    local menuBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "•••",
        TextColor3 = self.Colors.SidebarText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(0,28,0,28),
        Position = UDim2.new(1,-34,0.5,-14),
        ZIndex = 8,
        AutoButtonColor = false,
        Parent = self.ProfileFrame
    })
    -- Menu dropdown untuk profil
    local profileMenu = Create("Frame", {
        BackgroundColor3 = self.Colors.DropdownBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,0),
        Size = UDim2.new(0,140,0,0),
        Visible = false,
        ZIndex = 100,
        Parent = self.Gui  -- langsung ke ScreenGui agar tidak terpotong
    })
    AddCorner(profileMenu, 8)
    AddStroke(profileMenu, self.Colors.Stroke, 1, 0.4)
    local menuList = Create("UIListLayout", {
        Padding = UDim.new(0,2),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = profileMenu
    })
    local function addMenuItem(text, callback)
        local btn = Create("TextButton", {
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            Size = UDim2.new(0.9,0,0,26),
            Parent = profileMenu,
            ZIndex = 101
        })
        btn.MouseButton1Click:Connect(function()
            profileMenu.Visible = false
            callback()
        end)
        return btn
    end
    addMenuItem("Change Theme", function()
        local newTheme = self.Theme == "Dark" and "Light" or "Dark"
        self:SetTheme(newTheme)
    end)
    addMenuItem("Set Keybind", function()
        -- contoh: keybind untuk toggle UI bisa diset manual
        self:Notification({ Title = "Keybind", Description = "Click the keybind in Settings tab to set." })
    end)
    addMenuItem("Destroy GUI", function() self:Destroy() end)
    menuBtn.MouseButton1Click:Connect(function()
        profileMenu.Visible = not profileMenu.Visible
        if profileMenu.Visible then
            local absPos = menuBtn.AbsolutePosition
            profileMenu.Position = UDim2.new(0, absPos.X - 120, 0, absPos.Y - 10)
            profileMenu.Size = UDim2.new(0, 140, 0, 3*28 + 8)
        end
    end)

    -- Content area
    self.ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0,196,0,52),
        Size = UDim2.new(1,-196,1,-52),
        ZIndex = 3,
        Parent = self.Window
    })

    -- Animasi buka
    self.Window.Size = UDim2.new(0,760,0,0)
    self.Window.BackgroundTransparency = 1
    Tween(self.Window, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0,760,0,540),
        BackgroundTransparency = 0
    })

    table.insert(Library.Windows, self)
    return self
end

-- ── Theme updater system ──
function Window:RegisterUpdater(func)
    table.insert(self._updaters, func)
end

function Window:SetTheme(themeName)
    if not Themes[themeName] then return end
    local oldColors = self.Colors
    self.Colors = Themes[themeName]
    self.Theme = themeName
    -- Jalankan semua updater yang terdaftar
    for _, func in ipairs(self._updaters) do
        func(self.Colors)
    end
    -- Perbarui warna statis window & profile langsung
    self.Window.BackgroundColor3 = self.Colors.WindowBg
    self.ProfileFrame.BackgroundColor3 = self.Colors.SidebarActive
    self.ProfileFrame.TextLabel.TextColor3 = self.Colors.Text  -- kurang spesifik, perlu referensi
    -- Notification contoh
    self:Notification({ Title = "Theme Updated", Description = "Tema menjadi " .. themeName, Duration = 2 })
end

-- ── CreateTab ──
function Window:CreateTab(options)
    local C = self.Colors
    local tab = { Title = options.Title, Icon = options.Icon or "○", Window = self, Components = {} }

    tab.Frame = Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        Visible = false,
        ZIndex = 3,
        Parent = self.ContentArea
    })
    tab.Scroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,-6,1,0),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Accent,
        ZIndex = 3,
        Parent = tab.Frame
    })
    Create("UIListLayout", {
        Padding = UDim.new(0,10),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Scroll
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0,14),
        PaddingBottom = UDim.new(0,14),
        PaddingLeft = UDim.new(0,2),
        PaddingRight = UDim.new(0,2),
        Parent = tab.Scroll
    })

    local tabIndex = #self.Tabs + 1
    tab.SideBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,-8,0,42),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 8,
        LayoutOrder = tabIndex,
        Parent = self.SidebarScroll
    })
    AddCorner(tab.SideBtn, 9)

    tab.Indicator = Create("Frame", {
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0.5,-12),
        Size = UDim2.new(0,3,0,24),
        ZIndex = 9,
        Visible = false,
        Parent = tab.SideBtn
    })
    AddCorner(tab.Indicator, 3)

    tab.IconLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Icon,
        TextColor3 = C.SidebarText,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0,26,1,0),
        Position = UDim2.new(0,14,0,0),
        ZIndex = 9,
        Parent = tab.SideBtn
    })
    tab.TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = C.SidebarText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-48,1,0),
        Position = UDim2.new(0,40,0,0),
        ZIndex = 9,
        Parent = tab.SideBtn
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
    tab.SideBtn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    -- Updater tema untuk tab
    self:RegisterUpdater(function(newColors)
        tab.SideBtn.Indicator.BackgroundColor3 = newColors.Accent
        tab.IconLabel.TextColor3 = newColors.SidebarText
        tab.TitleLabel.TextColor3 = newColors.SidebarText
        if self.ActiveTab == tab then
            tab.SideBtn.BackgroundColor3 = newColors.SidebarActive
            tab.TitleLabel.TextColor3 = newColors.SidebarActiveText
        else
            tab.SideBtn.BackgroundTransparency = 1
        end
        tab.Scroll.ScrollBarImageColor3 = newColors.Accent
    end)

    -- helper baris
    local function MakeRow(title, height)
        local row = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0, height or 46),
            ZIndex = 4,
            Parent = tab.Scroll
        })
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = C.Label,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5,0,1,0),
            Position = UDim2.new(0,10,0,0),
            ZIndex = 4,
            Parent = row
        })
        local right = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0.5,-10,1,0),
            Position = UDim2.new(0.5,0,0,0),
            ZIndex = 4,
            Parent = row
        })
        return row, right, lbl
    end

    -- ── SECTION ──
    function tab:CreateSection(title)
        local section = {}
        section.Frame = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 4,
            Parent = tab.Scroll
        })
        AddCorner(section.Frame, 10)
        local stroke = AddStroke(section.Frame, C.SectionStroke, 1, 0.4)

        local header = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,30),
            ZIndex = 5,
            Parent = section.Frame
        })
        local secTitle = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = title:upper(),
            TextColor3 = C.SubText,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-20,1,0),
            Position = UDim2.new(0,12,0,0),
            ZIndex = 5,
            Parent = header
        })
        Create("Frame", {
            BackgroundColor3 = C.SectionStroke,
            BorderSizePixel = 0,
            Position = UDim2.new(0,12,1,-1),
            Size = UDim2.new(1,-24,0,1),
            ZIndex = 5,
            Parent = header
        })

        section.List = Create("UIListLayout", {
            Padding = UDim.new(0,2),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.Frame
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0,30),
            PaddingBottom = UDim.new(0,8),
            PaddingLeft = UDim.new(0,8),
            PaddingRight = UDim.new(0,8),
            Parent = section.Frame
        })
        section.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Frame.Size = UDim2.new(0.96,0,0,section.List.AbsoluteContentSize.Y + 46)
        end)

        table.insert(tab.Components, function(newColors)
            section.Frame.BackgroundColor3 = newColors.SectionBg
            stroke.Color = newColors.SectionStroke
            secTitle.TextColor3 = newColors.SubText
            header[2].BackgroundColor3 = newColors.SectionStroke
        end)

        function section:AddRow(title2, height2)
            local row2 = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0, height2 or 44),
                ZIndex = 5,
                Parent = section.Frame
            })
            local lbl = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text = title2,
                TextColor3 = C.Label,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0.5,0,1,0),
                Position = UDim2.new(0,4,0,0),
                ZIndex = 5,
                Parent = row2
            })
            local right2 = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.5,-4,1,0),
                Position = UDim2.new(0.5,0,0,0),
                ZIndex = 5,
                Parent = row2
            })
            table.insert(tab.Components, function(newColors)
                lbl.TextColor3 = newColors.Label
            end)
            return row2, right2
        end
        return section
    end

    -- ── BUTTON (PREMIUM) ──
    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local bgColor = style == "danger" and C.BtnDanger or style == "secondary" and C.BtnSecondary or C.BtnPrimary
        local txtColor = (style == "secondary") and C.Text or Color3.fromRGB(255,255,255)
        local glow, btnFrame = MakePremiumButton(tab.Scroll, text, bgColor, txtColor, 4, callback, style)
        -- register untuk tema
        local updater = function(newColors)
            local newBg = style == "danger" and newColors.BtnDanger or style == "secondary" and newColors.BtnSecondary or newColors.BtnPrimary
            glow.BackgroundColor3 = newBg
            btnFrame.BackgroundColor3 = newBg
            -- update stroke & gradient? Skip detail
        end
        table.insert(tab.Components, updater)
        return btnFrame
    end

    -- ── TOGGLE ──
    function tab:CreateToggle(options)
        local enabled = options.Default or false
        local callback = options.Callback or function() end
        local row, right, lbl = MakeRow(options.Title or "Toggle")
        local track = Create("Frame", {
            BackgroundColor3 = enabled and C.ToggleOn or C.ToggleOff,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1,-8,0.5,0),
            Size = UDim2.new(0,46,0,24),
            ZIndex = 5,
            Parent = right
        })
        AddCorner(track, 12)
        local knob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0,0.5),
            Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0),
            Size = UDim2.new(0,20,0,20),
            ZIndex = 6,
            Parent = track
        })
        AddCorner(knob, 10)
        AddShadow(knob, 8, 0.6)

        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quart)
        local function refresh()
            Tween(track, ti, { BackgroundColor3 = enabled and C.ToggleOn or C.ToggleOff })
            Tween(knob, ti, { Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0) })
            callback(enabled)
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled; refresh()
            end
        end)

        table.insert(tab.Components, function(newColors)
            track.BackgroundColor3 = enabled and newColors.ToggleOn or newColors.ToggleOff
        end)
        return { Set = function(v) enabled = v; refresh() end, Get = function() return enabled end }
    end

    -- ── SLIDER ──
    function tab:CreateSlider(options)
        local minV, maxV, val = options.Min or 0, options.Max or 100, options.Default or 0
        local callback = options.Callback or function() end
        local suffix = options.Suffix or ""
        local container = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,56),
            ZIndex = 4,
            Parent = tab.Scroll
        })
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Slider",
            TextColor3 = C.Label,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7,0,0,20),
            Position = UDim2.new(0,10,0,6),
            ZIndex = 4,
            Parent = container
        })
        local valLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = tostring(val) .. suffix,
            TextColor3 = C.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size = UDim2.new(0.3,-10,0,20),
            Position = UDim2.new(0.7,0,0,6),
            ZIndex = 4,
            Parent = container
        })
        local trackBg = Create("Frame", {
            BackgroundColor3 = C.SliderTrack,
            BorderSizePixel = 0,
            Position = UDim2.new(0,10,0,34),
            Size = UDim2.new(1,-20,0,5),
            ZIndex = 4,
            Parent = container
        })
        AddCorner(trackBg, 3)
        local pct = (val - minV) / (maxV - minV)
        local fill = Create("Frame", {
            BackgroundColor3 = C.SliderFill,
            BorderSizePixel = 0,
            Size = UDim2.new(pct,0,1,0),
            ZIndex = 5,
            Parent = trackBg
        })
        AddCorner(fill, 3)
        local thumb = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(pct,0,0.5,0),
            Size = UDim2.new(0,14,0,14),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 6,
            Parent = trackBg
        })
        AddCorner(thumb, 7)
        AddShadow(thumb, 10, 0.55)

        local function setVal(p)
            p = math.clamp(p,0,1)
            val = math.floor(minV + (maxV - minV)*p + 0.5)
            valLabel.Text = tostring(val)..suffix
            fill.Size = UDim2.new(p,0,1,0)
            thumb.Position = UDim2.new(p,0,0.5,0)
            callback(val)
        end
        local dragging = false
        local function onMove(input)
            local abs = trackBg.AbsolutePosition.X
            local sz = trackBg.AbsoluteSize.X
            setVal((input.Position.X - abs)/sz)
        end
        trackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; onMove(input)
            end
        end)
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                onMove(input)
            end
        end)

        table.insert(tab.Components, function(newColors)
            lbl.TextColor3 = newColors.Label
            valLabel.TextColor3 = newColors.Accent
            trackBg.BackgroundColor3 = newColors.SliderTrack
            fill.BackgroundColor3 = newColors.SliderFill
        end)
        return { Set = function(v) setVal(math.clamp((v-minV)/(maxV-minV),0,1)) end, Get = function() return val end }
    end

    -- ── DROPDOWN (POSISI ABSOLUT) ──
    function tab:CreateDropdown(options)
        local items = options.Items or {}
        local selected = options.Default or items[1] or "Select..."
        local callback = options.Callback or function() end
        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,46),
            ZIndex = 4,
            Parent = tab.Scroll
        })
        AddCorner(container, 9)
        local stroke = AddStroke(container, C.SectionStroke, 1, 0.4)

        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Dropdown",
            TextColor3 = C.Label,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5,0,1,0),
            Position = UDim2.new(0,12,0,0),
            ZIndex = 4,
            Parent = container
        })
        local selLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = selected,
            TextColor3 = C.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size = UDim2.new(0.45,-28,1,0),
            Position = UDim2.new(0.5,0,0,0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 4,
            Parent = container
        })
        local arrowBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = C.SubText,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            Size = UDim2.new(0,22,1,0),
            Position = UDim2.new(1,-26,0,0),
            ZIndex = 4,
            Parent = container
        })

        -- List box dibuat di ScreenGui langsung
        local listFrame = Create("Frame", {
            BackgroundColor3 = C.DropdownBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0,0,0,0),
            Visible = false,
            ZIndex = 100,
            Parent = self.Gui
        })
        AddCorner(listFrame, 9)
        AddStroke(listFrame, C.SectionStroke, 1, 0.4)
        Create("UIListLayout", {
            Padding = UDim.new(0,2),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = listFrame
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0,4),
            PaddingBottom = UDim.new(0,4),
            PaddingLeft = UDim.new(0,4),
            PaddingRight = UDim.new(0,4),
            Parent = listFrame
        })

        local function buildList()
            for _, ch in pairs(listFrame:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            for _, item in ipairs(items) do
                local b = Create("TextButton", {
                    BackgroundTransparency = 0.5,
                    BackgroundColor3 = C.DropdownBg,
                    BorderSizePixel = 0,
                    Text = item,
                    TextColor3 = C.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    Size = UDim2.new(1,0,0,28),
                    ZIndex = 101,
                    Parent = listFrame
                })
                AddCorner(b, 6)
                b.MouseButton1Click:Connect(function()
                    selected = item
                    selLabel.Text = item
                    listFrame.Visible = false
                    callback(item)
                end)
            end
            listFrame.Size = UDim2.new(0, container.AbsoluteSize.X, 0, math.min(#items*30+8, 180))
        end
        buildList()

        local open = false
        arrowBtn.MouseButton1Click:Connect(function()
            open = not open
            listFrame.Visible = open
            if open then
                local absPos = container.AbsolutePosition
                local absSize = container.AbsoluteSize
                listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                listFrame.Size = UDim2.new(0, absSize.X, 0, math.min(#items*30+8, 180))
            end
        end)

        table.insert(tab.Components, function(newColors)
            container.BackgroundColor3 = newColors.SectionBg
            stroke.Color = newColors.SectionStroke
            lbl.TextColor3 = newColors.Label
            selLabel.TextColor3 = newColors.Text
            arrowBtn.TextColor3 = newColors.SubText
            listFrame.BackgroundColor3 = newColors.DropdownBg
        end)
        return { SetItems = function(newItems) items = newItems; buildList() end, GetValue = function() return selected end }
    end

    -- ── INPUT ──
    function tab:CreateInput(options)
        local callback = options.Callback or function() end
        local placeholder = options.Placeholder or "Type here..."
        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,46),
            ZIndex = 4,
            Parent = tab.Scroll
        })
        AddCorner(container, 9)
        local stroke = AddStroke(container, C.SectionStroke, 1, 0.4)
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Input",
            TextColor3 = C.Label,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.4,0,1,0),
            Position = UDim2.new(0,12,0,0),
            ZIndex = 4,
            Parent = container
        })
        local inputBox = Create("TextBox", {
            BackgroundColor3 = C.InputBg,
            BorderSizePixel = 0,
            PlaceholderText = placeholder,
            PlaceholderColor3 = C.SubText,
            Text = options.Default or "",
            TextColor3 = C.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.55,-12,0,26),
            Position = UDim2.new(0.42,0,0.5,-13),
            ZIndex = 5,
            Parent = container
        })
        AddCorner(inputBox, 6)
        AddStroke(inputBox, C.Stroke, 1, 0.5)
        inputBox.FocusLost:Connect(function(enter) if enter then callback(inputBox.Text) end end)

        table.insert(tab.Components, function(newColors)
            container.BackgroundColor3 = newColors.SectionBg
            stroke.Color = newColors.SectionStroke
            inputBox.BackgroundColor3 = newColors.InputBg
            inputBox.PlaceholderColor3 = newColors.SubText
            inputBox.TextColor3 = newColors.Text
        end)
        return { Get = function() return inputBox.Text end, Set = function(v) inputBox.Text = v end }
    end

    -- ── KEYBIND ──
    function tab:CreateKeybind(options)
        local key = options.Default
        local callback = options.Callback or function() end
        local row, right, lbl = MakeRow(options.Title or "Keybind")
        local btn = Create("TextButton", {
            BackgroundColor3 = C.BtnSecondary,
            BorderSizePixel = 0,
            Text = key and key.Name or "None",
            TextColor3 = C.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1,-8,0.5,0),
            Size = UDim2.new(0,76,0,24),
            AutoButtonColor = false,
            ZIndex = 5,
            Parent = right
        })
        AddCorner(btn, 6)
        AddStroke(btn, C.Stroke, 1, 0.5)
        local listening = false
        btn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            btn.Text = "..."
            btn.TextColor3 = C.Warning
            local conn = UserInputService.InputBegan:Connect(function(input)
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
                    conn:Disconnect()
                end
            end)
        end)
        table.insert(tab.Components, function(newColors)
            btn.BackgroundColor3 = newColors.BtnSecondary
            btn.TextColor3 = listening and newColors.Warning or newColors.Accent
        end)
        return { GetKey = function() return key end, SetKey = function(k) key = k; btn.Text = k.Name end }
    end

    -- ── COLOR PICKER (FIX) ──
    function tab:CreateColorPicker(options)
        local color = options.Default or Color3.fromRGB(100,120,255)
        local callback = options.Callback or function() end
        local container = Create("Frame", {
            BackgroundColor3 = C.SectionBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,145), -- diperbesar
            ZIndex = 4,
            Parent = tab.Scroll
        })
        AddCorner(container, 10)
        local stroke = AddStroke(container, C.SectionStroke, 1, 0.4)
        local titleLbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Color",
            TextColor3 = C.Label,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.6,0,0,20),
            Position = UDim2.new(0,12,0,4),
            ZIndex = 5,
            Parent = container
        })
        local preview = Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(1,-48,0,8),
            Size = UDim2.new(0,32,0,32),
            ZIndex = 5,
            Parent = container
        })
        AddCorner(preview, 7)
        AddStroke(preview, C.Stroke, 1, 0.4)

        local h, s, v = Color3.toHSV(color)
        -- Hue track with gradient
        local hueTrackBg = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0,
            Position = UDim2.new(0,12,0,58),
            Size = UDim2.new(1,-64,0,12),
            ZIndex = 5,
            Parent = container
        })
        AddCorner(hueTrackBg, 6)
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
            }),
            Rotation = 0,
            Parent = hueTrackBg
        })
        local hueKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(h,0,0.5,0),
            Size = UDim2.new(0,14,0,14),
            ZIndex = 6,
            Parent = hueTrackBg
        })
        AddCorner(hueKnob, 7)
        AddStroke(hueKnob, C.Stroke, 2, 0.2)

        local function refresh()
            color = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = color
            callback(color)
        end

        local function makeMini(yOff, val0, label)
            local labelLbl = Create("TextLabel", {
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = C.SubText,
                Font = Enum.Font.Gotham,
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(0,20,0,12),
                Position = UDim2.new(0,12,0,yOff),
                ZIndex = 5,
                Parent = container
            })
            local tr = Create("Frame", {
                BackgroundColor3 = C.SliderTrack,
                BorderSizePixel = 0,
                Position = UDim2.new(0,32,0,yOff+1),
                Size = UDim2.new(1,-96,0,10),
                ZIndex = 5,
                Parent = container
            })
            AddCorner(tr, 5)
            local fl = Create("Frame", {
                BackgroundColor3 = C.SliderFill,
                BorderSizePixel = 0,
                Size = UDim2.new(val0,0,1,0),
                ZIndex = 6,
                Parent = tr
            })
            AddCorner(fl, 5)
            local kn = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(val0,0,0.5,0),
                Size = UDim2.new(0,14,0,14),
                ZIndex = 7,
                Parent = tr
            })
            AddCorner(kn, 7)
            return tr, fl, kn, labelLbl
        end
        local satTrack, satFill, satKnob, satLbl = makeMini(80, s, "S")
        local valTrack, valFill, valKnob, valLbl = makeMini(100, v, "V")

        local draggingHue, draggingSat, draggingVal = false, false, false
        hueTrackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                h = math.clamp((input.Position.X - hueTrackBg.AbsolutePosition.X)/hueTrackBg.AbsoluteSize.X,0,1)
                hueKnob.Position = UDim2.new(h,0,0.5,0)
                refresh()
            end
        end)
        satTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSat = true
                s = math.clamp((input.Position.X - satTrack.AbsolutePosition.X)/satTrack.AbsoluteSize.X,0,1)
                satFill.Size = UDim2.new(s,0,1,0)
                satKnob.Position = UDim2.new(s,0,0.5,0)
                refresh()
            end
        end)
        valTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingVal = true
                v = math.clamp((input.Position.X - valTrack.AbsolutePosition.X)/valTrack.AbsoluteSize.X,0,1)
                valFill.Size = UDim2.new(v,0,1,0)
                valKnob.Position = UDim2.new(v,0,0.5,0)
                refresh()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue, draggingSat, draggingVal = false, false, false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if draggingHue then
                    h = math.clamp((input.Position.X - hueTrackBg.AbsolutePosition.X)/hueTrackBg.AbsoluteSize.X,0,1)
                    hueKnob.Position = UDim2.new(h,0,0.5,0)
                    refresh()
                elseif draggingSat then
                    s = math.clamp((input.Position.X - satTrack.AbsolutePosition.X)/satTrack.AbsoluteSize.X,0,1)
                    satFill.Size = UDim2.new(s,0,1,0)
                    satKnob.Position = UDim2.new(s,0,0.5,0)
                    refresh()
                elseif draggingVal then
                    v = math.clamp((input.Position.X - valTrack.AbsolutePosition.X)/valTrack.AbsoluteSize.X,0,1)
                    valFill.Size = UDim2.new(v,0,1,0)
                    valKnob.Position = UDim2.new(v,0,0.5,0)
                    refresh()
                end
            end
        end)

        table.insert(tab.Components, function(newColors)
            container.BackgroundColor3 = newColors.SectionBg
            stroke.Color = newColors.SectionStroke
            titleLbl.TextColor3 = newColors.Label
            satTrack.BackgroundColor3 = newColors.SliderTrack
            satFill.BackgroundColor3 = newColors.SliderFill
            valTrack.BackgroundColor3 = newColors.SliderTrack
            valFill.BackgroundColor3 = newColors.SliderFill
        end)
        return { GetColor = function() return color end, SetColor = function(c) color = c; h,s,v = Color3.toHSV(c); refresh() end }
    end

    -- ── LABEL ──
    function tab:CreateLabel(text, color2)
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = color2 or C.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.96,0,0,24),
            ZIndex = 4,
            Parent = tab.Scroll
        })
        table.insert(tab.Components, function(newColors)
            if not color2 then lbl.TextColor3 = newColors.SubText end
        end)
        return { Set = function(v) lbl.Text = v end, SetColor = function(col) lbl.TextColor3 = col end }
    end

    -- ── SEPARATOR (padding atas) ──
    function tab:CreateSeparator(label)
        local sep = Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0.96,0,0,24), -- tambah tinggi
            ZIndex = 4,
            Parent = tab.Scroll
        })
        if label and label ~= "" then
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = C.SubText,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.new(0.3,0,1,0),
                Position = UDim2.new(0.35,0,0,0),
                ZIndex = 4,
                Parent = sep
            })
        end
        Create("Frame", {
            BackgroundColor3 = C.Stroke,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(0,0,0.5,0),
            Size = label and UDim2.new(0.33,-4,0,1) or UDim2.new(1,0,0,1),
            ZIndex = 4,
            Parent = sep
        })
        if label and label ~= "" then
            Create("Frame", {
                BackgroundColor3 = C.Stroke,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0,0.5),
                Position = UDim2.new(0.67,4,0.5,0),
                Size = UDim2.new(0.33,-4,0,1),
                ZIndex = 4,
                Parent = sep
            })
        end
    end

    self.Tabs[#self.Tabs + 1] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

-- ── SelectTab ──
function Window:SelectTab(tab)
    local prevTween = TweenInfo.new(0.18)
    local C = self.Colors
    if self.ActiveTab and self.ActiveTab ~= tab then
        local prev = self.ActiveTab
        prev.Frame.Visible = false
        prev.Indicator.Visible = false
        Tween(prev.SideBtn, prevTween, { BackgroundTransparency = 1 })
        Tween(prev.TitleLabel, prevTween, { TextColor3 = C.SidebarText })
        Tween(prev.IconLabel, prevTween, { TextColor3 = C.SidebarText })
    end
    tab.Frame.Visible = true
    tab.Indicator.Visible = true
    Tween(tab.SideBtn, prevTween, { BackgroundTransparency = 0, BackgroundColor3 = C.SidebarActive })
    Tween(tab.TitleLabel, prevTween, { TextColor3 = C.SidebarActiveText })
    Tween(tab.IconLabel, prevTween, { TextColor3 = C.Accent })
    self.ActiveTab = tab
end

-- ── Notification ──
function Window:Notification(options)
    local C = self.Colors
    local title = options.Title or "Notification"
    local desc = options.Description or ""
    local dur = options.Duration or 3.5
    local ntype = options.Type or "info"
    local accentColor = ntype == "success" and C.Success or ntype == "danger" and C.Danger or ntype == "warning" and C.Warning or C.Accent
    local notif = Create("Frame", {
        BackgroundColor3 = C.NotifBg,
        BorderSizePixel = 0,
        Position = UDim2.new(1,20,1,-88),
        Size = UDim2.new(0,260,0,72),
        ZIndex = 100,
        Parent = self.Gui
    })
    AddCorner(notif, 10)
    AddStroke(notif, accentColor, 1, 0.5)
    Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0,3,1,0),
        ZIndex = 101,
        Parent = notif
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-22,0,20),
        Position = UDim2.new(0,14,0,10),
        ZIndex = 101,
        Parent = notif
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = C.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1,-22,0,30),
        Position = UDim2.new(0,14,0,34),
        ZIndex = 101,
        Parent = notif
    })
    local progressBg = Create("Frame", {
        BackgroundColor3 = C.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0,14,1,-6),
        Size = UDim2.new(1,-28,0,2),
        ZIndex = 101,
        Parent = notif
    })
    AddCorner(progressBg, 1)
    local progressFill = Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        ZIndex = 102,
        Parent = progressBg
    })
    AddCorner(progressFill, 1)
    Tween(progressFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,1,0) })
    Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(1,-276,1,-88) })
    task.delay(dur, function()
        Tween(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Position = UDim2.new(1,20,1,-88) })
        task.delay(0.4, function() notif:Destroy() end)
    end)
end

function Window:ToggleMinimize()
    local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quint)
    self.Minimized = not self.Minimized
    if self.Minimized then
        self._origSize = self.Window.Size
        self._origPos = self.Window.Position
        Tween(self.Window, ti, { Size = UDim2.new(0,220,0,52), Position = UDim2.new(0,14,1,-70) })
    else
        Tween(self.Window, ti, { Size = self._origSize, Position = self._origPos })
    end
end

function Window:ToggleMaximize()
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quint)
    self.Maximized = not self.Maximized
    if self.Maximized then
        self._prevSize = self.Window.Size
        self._prevPos = self.Window.Position
        local vp = self.Gui.AbsoluteSize
        Tween(self.Window, ti, { Size = UDim2.new(0,vp.X,0,vp.Y), Position = UDim2.new(0,0,0,0) })
    else
        Tween(self.Window, ti, { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:Destroy()
    Tween(self.Window, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Size = UDim2.new(0,760,0,0), BackgroundTransparency = 1 })
    task.delay(0.4, function() self.Gui:Destroy() end)
    for i,w in ipairs(Library.Windows) do if w == self then table.remove(Library.Windows, i) break end end
end

function Library.CreateWindow(options)
    return Window.new(options)
end

return Library
