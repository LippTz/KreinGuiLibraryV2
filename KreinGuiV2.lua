-- KreinGuiV2 - Premium macOS GUI Library for Roblox
-- Full Rewrite with Sidebar, Modern Components, Touch Support

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Utility
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

local function Stroke(obj, color, thickness)
    local s = Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    s.Parent = obj
    return s
end

-- Ikon
local Icons = {
    home = "🏠",
    gear = "⚙️",
    combat = "⚔️",
    palette = "🎨",
    notification = "🔔",
    close = "✕",
    minimize = "─",
    maximize = "➕",
}

-- Tema
local Themes = {
    Dark = {
        TitleBar = Color3.fromRGB(40,40,40),
        WindowBg = Color3.fromRGB(50,50,50),
        Sidebar = Color3.fromRGB(35,35,35),
        SidebarText = Color3.fromRGB(210,210,210),
        SidebarActive = Color3.fromRGB(55,55,55),
        Text = Color3.fromRGB(240,240,240),
        SubText = Color3.fromRGB(170,170,170),
        Accent = Color3.fromRGB(0,122,255),
        Danger = Color3.fromRGB(255,69,58),
        Success = Color3.fromRGB(48,209,88),
        Stroke = Color3.fromRGB(80,80,80),
        SectionBg = Color3.fromRGB(60,60,60),
        BtnPrimary = Color3.fromRGB(0,122,255),
        BtnSecondary = Color3.fromRGB(75,75,75),
        BtnDanger = Color3.fromRGB(255,69,58),
        ToggleOff = Color3.fromRGB(75,75,75),
        ToggleOn = Color3.fromRGB(48,209,88),
        SliderTrack = Color3.fromRGB(75,75,75),
        DropdownBg = Color3.fromRGB(60,60,60),
        NotifBg = Color3.fromRGB(55,55,55)
    },
    Light = {
        TitleBar = Color3.fromRGB(235,235,240),
        WindowBg = Color3.fromRGB(255,255,255),
        Sidebar = Color3.fromRGB(246,246,250),
        SidebarText = Color3.fromRGB(80,80,80),
        SidebarActive = Color3.fromRGB(230,230,235),
        Text = Color3.fromRGB(30,30,30),
        SubText = Color3.fromRGB(100,100,100),
        Accent = Color3.fromRGB(0,122,255),
        Danger = Color3.fromRGB(255,69,58),
        Success = Color3.fromRGB(48,209,88),
        Stroke = Color3.fromRGB(210,210,210),
        SectionBg = Color3.fromRGB(250,250,252),
        BtnPrimary = Color3.fromRGB(0,122,255),
        BtnSecondary = Color3.fromRGB(230,230,230),
        BtnDanger = Color3.fromRGB(255,69,58),
        ToggleOff = Color3.fromRGB(210,210,210),
        ToggleOn = Color3.fromRGB(48,209,88),
        SliderTrack = Color3.fromRGB(220,220,220),
        DropdownBg = Color3.fromRGB(250,250,252),
        NotifBg = Color3.fromRGB(255,255,255)
    }
}

-- Library
local Library = {}
Library.Windows = {}

-- Window
local Window = {}
Window.__index = Window

-- Universal drag
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
    self.Title = options.Title or "Window"
    self.Subtitle = options.Subtitle or ""
    self.Icon = options.Icon or Icons.home
    self.Theme = options.Theme or "Dark"
    self.Colors = Themes[self.Theme]
    self.Tabs = {}
    self.ActiveTab = nil

    -- Parent
    local parent = (syn and syn.protect_gui and CoreGui) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = Create("ScreenGui", {
        Name = "KreinGUI",
        Parent = parent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Main window
    self.Window = Create("Frame", {
        BackgroundColor3 = self.Colors.WindowBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -360, 0.5, -260),
        Size = UDim2.new(0, 720, 0, 520),
        ClipsDescendants = true,
        Parent = self.Gui
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Window })
    Stroke(self.Window, self.Colors.Stroke, 1)

    -- Title bar
    self.TitleBar = Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        Size = UDim2.new(1, 0, 0, 54),
        BorderSizePixel = 0,
        Parent = self.Window
    })
    Create("UICorner", { CornerRadius = UDim.new(10, 0), Parent = self.TitleBar })

    -- Traffic lights
    local function trafficBtn(color, x, icon, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, x, 0.5, -7),
            Text = "",
            BorderSizePixel = 0,
            Parent = self.TitleBar
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
        btn.MouseEnter:Connect(function() btn.Text = icon end)
        btn.MouseLeave:Connect(function() btn.Text = "" end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    trafficBtn(Color3.fromRGB(255,69,58), 12, Icons.close, function() self:Destroy() end)
    trafficBtn(Color3.fromRGB(255,189,46), 32, Icons.minimize, function() self:ToggleMinimize() end)
    trafficBtn(Color3.fromRGB(40,200,70), 52, Icons.maximize, function() self:ToggleMaximize() end)

    -- Title text
    local titleFrame = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        Parent = self.TitleBar
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Icon,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        Parent = titleFrame
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -28, 0, 22),
        Position = UDim2.new(0, 28, 0, 6),
        Parent = titleFrame
    })
    if self.Subtitle ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = self.Subtitle,
            TextColor3 = self.Colors.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -28, 0, 16),
            Position = UDim2.new(0, 28, 0, 30),
            Parent = titleFrame
        })
    end

    -- Sidebar
    self.Sidebar = Create("Frame", {
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        Parent = self.Window
    })
    Stroke(self.Sidebar, self.Colors.Stroke, 1)
    -- Garis pemisah kanan
    Create("Frame", {
        BackgroundColor3 = self.Colors.Stroke,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = self.Sidebar
    })

    -- Sidebar list
    self.SidebarList = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Sidebar
    })
    -- Top padding
    Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 10),
        Parent = self.Sidebar
    })

    -- Content area
    self.Content = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -184, 1, -62),
        Position = UDim2.new(0, 184, 0, 60),
        ClipsDescendants = true,
        Parent = self.Window
    })

    -- Drag
    MakeDraggable(self.TitleBar, self.Window)

    -- Animasi masuk
    self.Window.Size = UDim2.new(0, 720, 0, 0)
    Tween(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 720, 0, 520)
    })

    table.insert(Library.Windows, self)
    return self
end

-- Fungsi CreateTab
function Window:CreateTab(options)
    local tab = {}
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or Icons.home
    tab.Window = self

    -- Konten
    tab.Content = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.Content
    })
    tab.Scroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Colors.Accent,
        Parent = tab.Content
    })
    local scrollList = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Scroll
    })
    -- Padding atas konten
    Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 8),
        Parent = tab.Scroll
    })

    -- Tombol di sidebar
    tab.Btn = Create("TextButton", {
        BackgroundTransparency = 1,
        BackgroundColor3 = self.Colors.SidebarActive,
        Text = "",
        Size = UDim2.new(1, -16, 0, 42),
        Parent = self.Sidebar
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tab.Btn })
    local btnLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Btn
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Icon,
        TextColor3 = self.Colors.SidebarText,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0, 22, 0, 22),
        Parent = tab.Btn
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = self.Colors.SidebarText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Size = UDim2.new(1, -32, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tab.Btn
    })
    -- Indikator
    tab.Indicator = Create("Frame", {
        BackgroundColor3 = self.Colors.Accent,
        Size = UDim2.new(0, 3, 0, 28),
        Position = UDim2.new(0, 5, 0.5, -14),
        BorderSizePixel = 0,
        Visible = false,
        Parent = tab.Btn
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = tab.Indicator })

    tab.Btn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    -- Helper komponen
    function tab:CreateSection(title)
        local section = {}
        section.Bg = Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBg,
            BorderSizePixel = 0,
            Size = UDim2.new(0.95, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab.Scroll
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = section.Bg })
        Stroke(section.Bg, self.Colors.Stroke, 1)
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = title:upper(),
            TextColor3 = self.Colors.SubText,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.new(0, 10, 0, 4),
            Parent = section.Bg
        })
        section.List = Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.Bg
        })
        section.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Bg.Size = UDim2.new(0.95, 0, 0, section.List.AbsoluteContentSize.Y + 12)
        end)
        return section
    end

    local function makeRow(title)
        local row = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0, 44),
            Parent = tab.Scroll
        })
        local lbl = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5, 0, 1, 0),
            Parent = row
        })
        local right = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            Parent = row
        })
        return row, lbl, right
    end

    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local bgColor = style == "primary" and self.Colors.BtnPrimary or style == "danger" and self.Colors.BtnDanger or self.Colors.BtnSecondary
        local txtColor = (style == "secondary") and self.Colors.Text or Color3.fromRGB(255,255,255)
        local btn = Create("TextButton", {
            BackgroundColor3 = bgColor,
            Text = text,
            TextColor3 = txtColor,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            BorderSizePixel = 0,
            Size = UDim2.new(0.92, 0, 0, 38),
            Parent = tab.Scroll
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
        Stroke(btn, self.Colors.Stroke, 1)
        -- Hover effect
        btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = bgColor:Lerp(Color3.new(1,1,1), 0.1) })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = bgColor })
        end)
        btn.MouseButton1Click:Connect(callback or function() end)
        return btn
    end

    function tab:CreateToggle(options)
        local enabled = options.Default or false
        local callback = options.Callback or function() end
        local row, lbl, right = makeRow(options.Title or "Toggle")
        local switch = Create("Frame", {
            BackgroundColor3 = enabled and self.Colors.ToggleOn or self.Colors.ToggleOff,
            Size = UDim2.new(0, 46, 0, 24),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -2, 0.5, 0),
            BorderSizePixel = 0,
            Parent = right
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
        local knob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = enabled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BorderSizePixel = 0,
            Parent = switch
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
        local function update()
            Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = enabled and self.Colors.ToggleOn or self.Colors.ToggleOff })
            Tween(knob, TweenInfo.new(0.2), { Position = enabled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
            callback(enabled)
        end
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                update()
            end
        end)
        return { Set = function(v) enabled = v; update() end, Get = function() return enabled end }
    end

    function tab:CreateSlider(options)
        local min, max, val = options.Min or 0, options.Max or 100, options.Default or 0
        local callback = options.Callback or function() end
        local row, lbl, right = makeRow(options.Title or "Slider")
        local valLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = tostring(val),
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = right
        })
        local track = Create("Frame", {
            BackgroundColor3 = self.Colors.SliderTrack,
            Size = UDim2.new(1, -48, 0, 4),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 4, 0.5, 0),
            BorderSizePixel = 0,
            Parent = right
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
        local fill = Create("Frame", {
            BackgroundColor3 = self.Colors.Accent,
            Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
            BorderSizePixel = 0,
            Parent = track
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
        local thumb = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0),
            Text = "",
            BorderSizePixel = 0,
            Parent = track
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
        local function setPercent(p)
            val = math.floor(min + (max - min) * p)
            valLabel.Text = tostring(val)
            fill.Size = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            callback(val)
        end
        local dragging = false
        local function move(input)
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setPercent(relX)
        end
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                move(input)
            end
        end)
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                move(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                move(input)
            end
        end)
        return { Set = function(v) setPercent(math.clamp((v - min) / (max - min), 0, 1)) end }
    end

    function tab:CreateDropdown(options)
        local items = options.Items or {}
        local default = options.Default or items[1] or ""
        local callback = options.Callback or function() end
        local row, lbl, right = makeRow(options.Title or "Dropdown")
        local selectedText = Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = default,
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Size = UDim2.new(1, -24, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = right
        })
        local arrow = Create("TextButton", {
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            Size = UDim2.new(0, 18, 1, 0),
            Position = UDim2.new(1, -18, 0, 0),
            Parent = right
        })
        local listFrame = Create("Frame", {
            BackgroundColor3 = self.Colors.DropdownBg,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 10,
            Parent = row
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = listFrame })
        Stroke(listFrame, self.Colors.Stroke, 1)
        local function populate()
            -- clear old
            for _, v in pairs(listFrame:GetChildren()) do
                if v:IsA("TextButton") then v:Destroy() end
            end
            for i, item in ipairs(items) do
                local btn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Text = item,
                    TextColor3 = self.Colors.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(0.95, 0, 0, 26),
                    ZIndex = 11,
                    Parent = listFrame
                })
                btn.MouseButton1Click:Connect(function()
                    selectedText.Text = item
                    listFrame.Visible = false
                    callback(item)
                end)
            end
            listFrame.Size = UDim2.new(1, 0, 0, #items * 26 + 8)
        end
        populate()
        local open = false
        arrow.MouseButton1Click:Connect(function()
            open = not open
            listFrame.Visible = open
        end)
        return { SetItems = function(new) items = new; populate() end, GetValue = function() return selectedText.Text end }
    end

    function tab:CreateKeybind(options)
        local key = options.Default
        local callback = options.Callback or function() end
        local row, lbl, right = makeRow(options.Title or "Keybind")
        local btn = Create("TextButton", {
            BackgroundColor3 = self.Colors.BtnSecondary,
            Text = key and key.Name or "None",
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 70, 0, 22),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -2, 0.5, 0),
            Parent = right
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
        local listening = false
        btn.MouseButton1Click:Connect(function()
            listening = true
            btn.Text = "..."
            local conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    btn.Text = key.Name
                    listening = false
                    conn:Disconnect()
                    callback(key)
                end
            end)
            delay(5, function()
                if listening then
                    listening = false
                    btn.Text = key and key.Name or "None"
                    conn:Disconnect()
                end
            end)
        end)
        return { GetKey = function() return key end, SetKey = function(k) key = k; btn.Text = k.Name end }
    end

    function tab:CreateColorPicker(options)
        local color = options.Default or Color3.fromRGB(255, 255, 255)
        local callback = options.Callback or function() end
        local container = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.92, 0, 0, 110),
            Parent = tab.Scroll
        })
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Color",
            TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            Size = UDim2.new(1, 0, 0, 18),
            Parent = container
        })
        local preview = Create("Frame", {
            BackgroundColor3 = color,
            Size = UDim2.new(0.85, 0, 0, 28),
            Position = UDim2.new(0.075, 0, 0, 22),
            BorderSizePixel = 0,
            Parent = container
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
        Stroke(preview, self.Colors.Stroke, 1)

        local h, s, v = Color3.toHSV(color)
        local function update()
            color = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = color
            callback(color)
        end

        -- Hue bar
        local hueBar = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.85, 0, 0, 12),
            Position = UDim2.new(0.075, 0, 0, 54),
            Parent = container
        })
        local hueImg = Create("ImageLabel", {
            Image = "rbxassetid://9607867758",
            Size = UDim2.new(1, 0, 1, 0),
            Parent = hueBar
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueImg })
        local hueKnob = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(h, 0, 0.5, 0),
            BorderSizePixel = 0,
            Parent = hueImg
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueKnob })
        local draggingHue = false
        hueImg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                local relX = math.clamp((input.Position.X - hueImg.AbsolutePosition.X) / hueImg.AbsoluteSize.X, 0, 1)
                h = relX; hueKnob.Position = UDim2.new(h, 0, 0.5, 0); update()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp((input.Position.X - hueImg.AbsolutePosition.X) / hueImg.AbsoluteSize.X, 0, 1)
                h = relX; hueKnob.Position = UDim2.new(h, 0, 0.5, 0); update()
            end
        end)

        -- Sat/Val sliders
        local svFrame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.85, 0, 0, 30),
            Position = UDim2.new(0.075, 0, 0, 70),
            Parent = container
        })
        local function makeSV(yPos, valProp)
            local slider = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(200,200,200),
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, yPos),
                BorderSizePixel = 0,
                Parent = svFrame
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider })
            local fill2 = Create("Frame", {
                BackgroundColor3 = self.Colors.Accent,
                Size = UDim2.new(valProp, 0, 1, 0),
                Parent = slider
            })
            local thumb2 = Create("TextButton", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Size = UDim2.new(0, 10, 0, 10),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(valProp, 0, 0.5, 0),
                Text = "",
                BorderSizePixel = 0,
                Parent = slider
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb2 })
            return fill2, thumb2, slider
        end
        local satFill, satThumb, satSlide = makeSV(0, s)
        local valFill, valThumb, valSlide = makeSV(14, v)
        local satDrag, valDrag = false, false
        local function updateSat(input)
            local relX = math.clamp((input.Position.X - satSlide.AbsolutePosition.X) / satSlide.AbsoluteSize.X, 0, 1)
            s = relX; satFill.Size = UDim2.new(relX, 0, 1, 0); satThumb.Position = UDim2.new(relX, 0, 0.5, 0); update()
        end
        local function updateVal(input)
            local relX = math.clamp((input.Position.X - valSlide.AbsolutePosition.X) / valSlide.AbsoluteSize.X, 0, 1)
            v = relX; valFill.Size = UDim2.new(relX, 0, 1, 0); valThumb.Position = UDim2.new(relX, 0, 0.5, 0); update()
        end
        satSlide.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then satDrag = true; updateSat(input) end
        end)
        valSlide.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then valDrag = true; updateVal(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then satDrag = false; valDrag = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if satDrag then updateSat(input) elseif valDrag then updateVal(input) end
            end
        end)
        return { GetColor = function() return color end, SetColor = function(c) color = c; h,s,v = Color3.toHSV(c); update() end }
    end

    self.Tabs[#self.Tabs + 1] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Indicator.Visible = false
    end
    tab.Content.Visible = true
    tab.Indicator.Visible = true
    self.ActiveTab = tab
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        self._origSize = self.Window.Size
        self._origPos = self.Window.Position
        Tween(self.Window, TweenInfo.new(0.3), { Size = UDim2.new(0, 200, 0, 54), Position = UDim2.new(0, 10, 1, -70) })
    else
        Tween(self.Window, TweenInfo.new(0.3), { Size = self._origSize, Position = self._origPos })
    end
end

function Window:ToggleMaximize()
    self.Maximized = not self.Maximized
    if self.Maximized then
        self._prevSize = self.Window.Size
        self._prevPos = self.Window.Position
        local s = self.Gui.AbsoluteSize
        Tween(self.Window, TweenInfo.new(0.3), { Size = UDim2.new(0, s.X, 0, s.Y - 54), Position = UDim2.new(0, 0, 0, 0) })
    else
        Tween(self.Window, TweenInfo.new(0.3), { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:Notification(options)
    local title = options.Title or ""
    local desc = options.Description or ""
    local dur = options.Duration or 3
    local notif = Create("Frame", {
        BackgroundColor3 = self.Colors.NotifBg,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 1, -80),
        Size = UDim2.new(0, 240, 0, 60),
        Parent = self.Gui,
        ZIndex = 5
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
    Stroke(notif, self.Colors.Stroke, 1)
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 8),
        Parent = notif
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = self.Colors.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 30),
        Parent = notif
    })
    Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -260, 1, -80) })
    delay(dur, function()
        Tween(notif, TweenInfo.new(0.3), { Position = UDim2.new(1, 20, 1, -80) })
        delay(0.3, function() notif:Destroy() end)
    end)
end

function Window:Destroy()
    Tween(self.Window, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 0) })
    delay(0.3, function() self.Gui:Destroy() end)
    for i, w in ipairs(Library.Windows) do
        if w == self then table.remove(Library.Windows, i); break end
    end
end

-- CreateWindow
function Library.CreateWindow(options)
    return Window.new(options)
end

return Library
