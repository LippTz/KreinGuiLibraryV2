--[[
    macOS GUI Library for Roblox
    Version: 1.0.0
    Author: KreinUX Team
    Description: A modern, elegant, and highly optimized Roblox GUI Library
                 that mimics the visual style of macOS (Big Sur / Monterey / Ventura).
    License: MIT
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") -- using CoreGui for syn executors; fallback to PlayerGui

-- Utility functions
local Utility = {}

function Utility.Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Utility.Tween(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.ApplyStroke(frame, color, thickness)
    local stroke = Utility.Create("UIStroke", {
        Color = color,
        Thickness = thickness,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    stroke.Parent = frame
    return stroke
end

function Utility.AddBlurEffect(parent, size)
    local blur = Utility.Create("BlurEffect", {
        Size = size or 10
    })
    blur.Parent = parent
    return blur
end

-- Icons (using Unicode symbols that resemble SF Symbols)
local Icons = {
    gear = "⚙️",
    house = "🏠",
    person = "👤",
    sparkles = "✨",
    paintbrush = "🖌️",
    keyboard = "⌨️",
    colorwheel = "🎨",
    slider = "🎚️",
    toggle = "🔘",
    dropdown = "📋",
    notification = "🔔",
    close = "✕",
    minimize = "─",
    maximize = "➕",
    search = "🔍",
    checkmark = "✓",
    plus = "＋",
}

-- Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        WindowBackground = Color3.fromRGB(45, 45, 45),
        TitleBar = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(220, 220, 220),
        SecondaryText = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(0, 122, 255),
        Danger = Color3.fromRGB(255, 69, 58),
        Success = Color3.fromRGB(48, 209, 88),
        Stroke = Color3.fromRGB(80, 80, 80),
        SectionBackground = Color3.fromRGB(55, 55, 55),
        ButtonPrimary = Color3.fromRGB(0, 122, 255),
        ButtonSecondary = Color3.fromRGB(70, 70, 70),
        ToggleTrackOff = Color3.fromRGB(70, 70, 70),
        ToggleTrackOn = Color3.fromRGB(48, 209, 88),
        SliderTrack = Color3.fromRGB(70, 70, 70),
        DropdownList = Color3.fromRGB(55, 55, 55),
        Notification = Color3.fromRGB(45, 45, 45)
    },
    Light = {
        Background = Color3.fromRGB(242, 242, 247),
        WindowBackground = Color3.fromRGB(255, 255, 255),
        TitleBar = Color3.fromRGB(240, 240, 245),
        Text = Color3.fromRGB(30, 30, 30),
        SecondaryText = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 122, 255),
        Danger = Color3.fromRGB(255, 69, 58),
        Success = Color3.fromRGB(48, 209, 88),
        Stroke = Color3.fromRGB(200, 200, 200),
        SectionBackground = Color3.fromRGB(245, 245, 250),
        ButtonPrimary = Color3.fromRGB(0, 122, 255),
        ButtonSecondary = Color3.fromRGB(220, 220, 220),
        ToggleTrackOff = Color3.fromRGB(200, 200, 200),
        ToggleTrackOn = Color3.fromRGB(48, 209, 88),
        SliderTrack = Color3.fromRGB(220, 220, 220),
        DropdownList = Color3.fromRGB(245, 245, 250),
        Notification = Color3.fromRGB(255, 255, 255)
    }
}

-- Main Library
local Library = {}
Library.Windows = {}
Library.ActiveWindow = nil
Library.CurrentTheme = "Dark"

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Title = options.Title or "Window"
    self.Subtitle = options.Subtitle or ""
    self.Icon = options.Icon or Icons.house
    self.Theme = options.Theme or Library.CurrentTheme
    self.Colors = Themes[self.Theme]
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Maximized = false
    self.Draggable = true
    self.Resizable = true
    
    -- Main GUI container
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "macOS_GUI",
        Parent = (syn and syn.protect_gui and (function() return CoreGui end)() or game.Players.LocalPlayer:FindFirstChild("PlayerGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    })
    
    -- Blur background
    self.BlurFrame = Utility.Create("Frame", {
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size = UDim2.new(1,0,1,0),
        Parent = self.ScreenGui
    })
    Utility.AddBlurEffect(self.BlurFrame, 15)
    
    -- Main Window
    self.WindowFrame = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.WindowBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    -- Rounded corners
    Utility.Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = self.WindowFrame })
    Utility.ApplyStroke(self.WindowFrame, self.Colors.Stroke, 1)
    
    -- Title bar
    self.TitleBar = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar,
        Size = UDim2.new(1,0,0,40),
        BorderSizePixel = 0,
        Parent = self.WindowFrame
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(12,0), Parent = self.TitleBar })
    
    -- Traffic light buttons
    self.CloseBtn = Utility.Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(255,69,58),
        Size = UDim2.new(0,12,0,12),
        Position = UDim2.new(0,12,0.5,-6),
        Text = "",
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = self.CloseBtn })
    self.CloseBtn.MouseEnter:Connect(function() self.CloseBtn.Text = Icons.close end)
    self.CloseBtn.MouseLeave:Connect(function() self.CloseBtn.Text = "" end)
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.MinimizeBtn = Utility.Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(255,189,46),
        Size = UDim2.new(0,12,0,12),
        Position = UDim2.new(0,30,0.5,-6),
        Text = "",
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = self.MinimizeBtn })
    self.MinimizeBtn.MouseEnter:Connect(function() self.MinimizeBtn.Text = Icons.minimize end)
    self.MinimizeBtn.MouseLeave:Connect(function() self.MinimizeBtn.Text = "" end)
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.MaximizeBtn = Utility.Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(40,200,70),
        Size = UDim2.new(0,12,0,12),
        Position = UDim2.new(0,48,0.5,-6),
        Text = "",
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = self.MaximizeBtn })
    self.MaximizeBtn.MouseEnter:Connect(function() self.MaximizeBtn.Text = Icons.maximize end)
    self.MaximizeBtn.MouseLeave:Connect(function() self.MaximizeBtn.Text = "" end)
    self.MaximizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)
    
    -- Title and icon
    local titleContainer = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-120,1,0),
        Position = UDim2.new(0,70,0,0),
        Parent = self.TitleBar
    })
    
    self.IconLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Icon,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(0,5,0.5,-10),
        Parent = titleContainer
    })
    
    self.TitleLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-30,1,0),
        Position = UDim2.new(0,30,0,0),
        Parent = titleContainer
    })
    
    if self.Subtitle ~= "" then
        self.SubtitleLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = self.Subtitle,
            TextColor3 = self.Colors.SecondaryText,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-30,0,14),
            Position = UDim2.new(0,30,0,22),
            Parent = titleContainer
        })
    end
    
    -- Tab container
    self.TabContainer = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,0,32),
        Position = UDim2.new(0,10,0,46),
        Parent = self.WindowFrame
    })
    self.TabListLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
        Parent = self.TabContainer
    })
    
    -- Content area
    self.ContentFrame = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,-88),
        Position = UDim2.new(0,10,0,82),
        ClipsDescendants = true,
        Parent = self.WindowFrame
    })
    
    -- Resize handle
    if self.Resizable then
        self.ResizeHandle = Utility.Create("TextButton", {
            BackgroundTransparency = 0.8,
            BackgroundColor3 = self.Colors.Stroke,
            Size = UDim2.new(0,16,0,16),
            Position = UDim2.new(1,-18,1,-18),
            Text = "",
            BorderSizePixel = 0,
            Parent = self.WindowFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,4), Parent = self.ResizeHandle })
        self:_enableResize()
    end
    
    -- Draggability
    self:_enableDrag()
    
    -- Entrance animation
    self.WindowFrame.Size = UDim2.new(0,600,0,0)
    Utility.Tween(self.WindowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 400)
    })
    
    table.insert(Library.Windows, self)
    return self
end

function Window:_enableDrag()
    local dragging, dragInput, dragStart, startPos
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.WindowFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.WindowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Window:_enableResize()
    local resizing, resizeInput, startSize, startPos, startMousePos
    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = self.WindowFrame.Size
            startPos = self.WindowFrame.Position
            startMousePos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    self.ResizeHandle.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMousePos
            local newWidth = math.clamp(startSize.X.Offset + delta.X, 400, 1200)
            local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 300, 800)
            self.WindowFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

function Window:CreateTab(options)
    local tab = {}
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or Icons.house
    tab.Window = self
    tab.Content = Utility.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Visible = false,
        Parent = self.ContentFrame
    })
    
    -- Tab scrolling frame for content
    tab.ScrollingFrame = Utility.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Colors.Accent,
        Parent = tab.Content
    })
    tab.UIListLayout = Utility.Create("UIListLayout", {
        Padding = UDim.new(0,8),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.ScrollingFrame
    })
    
    -- Tab button
    tab.Button = Utility.Create("TextButton", {
        BackgroundTransparency = 1,
        BackgroundColor3 = self.Colors.Accent,
        Text = "",
        Size = UDim2.new(0,0,1,0),
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = self.TabContainer
    })
    local btnLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0,4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Button
    })
    tab.IconLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Icon,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Size = UDim2.new(0,18,0,18),
        Parent = tab.Button
    })
    tab.TitleLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Size = UDim2.new(0,0,1,0),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tab.Button
    })
    
    -- Tab selection underline
    tab.Underline = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.Accent,
        Size = UDim2.new(1,-10,0,2),
        Position = UDim2.new(0,5,1,0),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0,1),
        Parent = tab.Button
    })
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Tab methods
    function tab:CreateSection(title)
        local section = {}
        section.Title = title
        section.Container = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.SectionBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(0.95,0,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = self.ScrollingFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = section.Container })
        Utility.ApplyStroke(section.Container, self.Window.Colors.Stroke, 1)
        
        local titleLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.Window.Colors.SecondaryText,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-20,0,24),
            Position = UDim2.new(0,10,0,8),
            Parent = section.Container
        })
        
        section.InnerList = Utility.Create("UIListLayout", {
            Padding = UDim.new(0,6),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.Container
        })
        
        -- Space elements after title
        section.InnerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Container.Size = UDim2.new(0.95,0,0,section.InnerList.AbsoluteContentSize.Y + 30)
        end)
        
        function section:AddElement(elementFrame)
            elementFrame.Parent = section.Container
            elementFrame.Size = UDim2.new(0.9,0,0,36) -- default height for element row
        end
        
        tab.Sections = tab.Sections or {}
        table.insert(tab.Sections, section)
        return section
    end
    
    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local button = Utility.Create("TextButton", {
            BackgroundColor3 = style == "primary" and self.Window.Colors.ButtonPrimary or style == "danger" and self.Window.Colors.Danger or self.Window.Colors.ButtonSecondary,
            Text = text,
            TextColor3 = style == "secondary" and self.Window.Colors.Text or Color3.fromRGB(255,255,255),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            BorderSizePixel = 0,
            Size = UDim2.new(0.9,0,0,30),
            Parent = self.ScrollingFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = button })
        Utility.ApplyStroke(button, self.Window.Colors.Stroke, 1)
        button.MouseButton1Click:Connect(callback or function() end)
        return button
    end
    
    function tab:CreateToggle(options)
        local default = options.Default or false
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        local label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Toggle",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7,0,1,0),
            Parent = container
        })
        local switch = Utility.Create("Frame", {
            BackgroundColor3 = default and self.Window.Colors.ToggleTrackOn or self.Window.Colors.ToggleTrackOff,
            Size = UDim2.new(0,40,0,22),
            Position = UDim2.new(1,-40,0.5,-11),
            BorderSizePixel = 0,
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = switch })
        local knob = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0,18,0,18),
            Position = default and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BorderSizePixel = 0,
            Parent = switch
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })
        
        local enabled = default
        local function update()
            Utility.Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = enabled and self.Window.Colors.ToggleTrackOn or self.Window.Colors.ToggleTrackOff })
            Utility.Tween(knob, TweenInfo.new(0.2), { Position = enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9) })
            callback(enabled)
        end
        
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                update()
            end
        end)
        return { Set = function(val) enabled = val; update() end, Get = function() return enabled end }
    end
    
    function tab:CreateSlider(options)
        local min = options.Min or 0
        local max = options.Max or 100
        local default = options.Default or min
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        local label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Slider",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.4,0,1,0),
            Parent = container
        })
        local valueLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Size = UDim2.new(0,40,1,0),
            Position = UDim2.new(1,-40,0,0),
            Parent = container
        })
        local track = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.SliderTrack,
            Size = UDim2.new(1,-90,0,4),
            Position = UDim2.new(0,5,0.5,-2),
            BorderSizePixel = 0,
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })
        local fill = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.Accent,
            Size = UDim2.new((default-min)/(max-min),0,1,0),
            BorderSizePixel = 0,
            Parent = track
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })
        local thumb = Utility.Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0,14,0,14),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new((default-min)/(max-min),0,0.5,0),
            Text = "",
            BorderSizePixel = 0,
            Parent = track
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = thumb })
        
        local dragging = false
        thumb.MouseButton1Down:Connect(function()
            dragging = true
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = mousePos.X - track.AbsolutePosition.X
                local percent = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
                local val = min + (max-min)*percent
                valueLabel.Text = tostring(math.floor(val))
                fill.Size = UDim2.new(percent,0,1,0)
                thumb.Position = UDim2.new(percent,0,0.5,0)
                callback(val)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local relativeX = mousePos.X - track.AbsolutePosition.X
                local percent = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
                local val = min + (max-min)*percent
                valueLabel.Text = tostring(math.floor(val))
                fill.Size = UDim2.new(percent,0,1,0)
                thumb.Position = UDim2.new(percent,0,0.5,0)
                callback(val)
            end
        end)
        return {
            Set = function(val)
                local clamped = math.clamp(val, min, max)
                valueLabel.Text = tostring(math.floor(clamped))
                local percent = (clamped-min)/(max-min)
                fill.Size = UDim2.new(percent,0,1,0)
                thumb.Position = UDim2.new(percent,0,0.5,0)
            end
        }
    end
    
    function tab:CreateDropdown(options)
        local items = options.Items or {}
        local default = options.Default or items[1] or ""
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        local label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Dropdown",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.4,0,1,0),
            Parent = container
        })
        local selectedText = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = default,
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Size = UDim2.new(1,-100,1,0),
            Position = UDim2.new(0.4,0,0,0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container
        })
        local arrow = Utility.Create("TextButton", {
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Size = UDim2.new(0,20,1,0),
            Position = UDim2.new(1,-20,0,0),
            Parent = container
        })
        
        local dropdownFrame = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.DropdownList,
            Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(0,0,1,0),
            BorderSizePixel = 0,
            Visible = false,
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = dropdownFrame })
        Utility.ApplyStroke(dropdownFrame, self.Window.Colors.Stroke, 1)
        local listLayout = Utility.Create("UIListLayout", {
            Padding = UDim.new(0,2),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = dropdownFrame
        })
        
        local function populate()
            for _, existing in pairs(dropdownFrame:GetChildren()) do
                if existing:IsA("TextButton") then existing:Destroy() end
            end
            for _, item in ipairs(items) do
                local btn = Utility.Create("TextButton", {
                    BackgroundTransparency = 1,
                    Text = item,
                    TextColor3 = self.Window.Colors.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(0.95,0,0,24),
                    Parent = dropdownFrame
                })
                btn.MouseButton1Click:Connect(function()
                    selectedText.Text = item
                    dropdownFrame.Visible = false
                    callback(item)
                end)
            end
        end
        populate()
        
        local open = false
        arrow.MouseButton1Click:Connect(function()
            open = not open
            dropdownFrame.Visible = open
            if open then
                dropdownFrame.Size = UDim2.new(1,0,0,#items*26+10)
            end
        end)
        
        return {
            SetItems = function(newItems)
                items = newItems
                populate()
            end,
            GetValue = function() return selectedText.Text end
        }
    end
    
    function tab:CreateKeybind(options)
        local default = options.Default or nil
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        local label = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Keybind",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5,0,1,0),
            Parent = container
        })
        local boundKey = default
        local keyBtn = Utility.Create("TextButton", {
            BackgroundColor3 = self.Window.Colors.ButtonSecondary,
            Text = boundKey and boundKey.Name or "None",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0,
            Size = UDim2.new(0,70,0,24),
            Position = UDim2.new(1,-70,0.5,-12),
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,4), Parent = keyBtn })
        
        local listening = false
        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    boundKey = input.KeyCode
                    keyBtn.Text = input.KeyCode.Name
                    listening = false
                    conn:Disconnect()
                    callback(input.KeyCode)
                end
            end)
            -- timeout after 5 seconds
            delay(5, function()
                if listening then
                    listening = false
                    keyBtn.Text = boundKey and boundKey.Name or "None"
                    conn:Disconnect()
                end
            end)
        end)
        return {
            GetKey = function() return boundKey end,
            SetKey = function(key) boundKey = key; keyBtn.Text = key.Name end
        }
    end
    
    function tab:CreateColorPicker(options)
        local default = options.Default or Color3.fromRGB(255,255,255)
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9,0,0,100),
            Parent = self.ScrollingFrame
        })
        local titleLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = options.Title or "Color Picker",
            TextColor3 = self.Window.Colors.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5,0,0,20),
            Parent = container
        })
        -- Color preview
        local preview = Utility.Create("Frame", {
            BackgroundColor3 = default,
            Size = UDim2.new(0.8,0,0,30),
            Position = UDim2.new(0.1,0,0,25),
            BorderSizePixel = 0,
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = preview })
        Utility.ApplyStroke(preview, self.Window.Colors.Stroke, 1)
        
        -- Hue slider
        local hueSlider = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8,0,0,14),
            Position = UDim2.new(0.1,0,0,60),
            Parent = container
        })
        local hueTrack = Utility.Create("ImageLabel", {
            Image = "rbxassetid://9607867758", -- default Roblox gradient
            Size = UDim2.new(1,0,1,0),
            Parent = hueSlider
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueTrack })
        local hueThumb = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0,10,0,10),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0,0,0.5,0),
            BorderSizePixel = 0,
            Parent = hueTrack
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueThumb })
        
        local currentColor = default
        local h, s, v = Color3.toHSV(default)
        local function updateFromHSV()
            currentColor = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = currentColor
            hueThumb.Position = UDim2.new(h,0,0.5,0)
            callback(currentColor)
        end
        
        local draggingHue = false
        hueTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local relX = math.clamp((mousePos.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
                h = relX
                updateFromHSV()
            end
        end)
        
        -- Saturation/Brightness square (simple version: two sliders for S and V)
        local svContainer = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8,0,0,30),
            Position = UDim2.new(0.1,0,0,80),
            Parent = container
        })
        local satSlider = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(220,220,220),
            Size = UDim2.new(1,0,0,8),
            Position = UDim2.new(0,0,0,0),
            BorderSizePixel = 0,
            Parent = svContainer
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = satSlider })
        local satFill = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.Accent,
            Size = UDim2.new(s,0,1,0),
            Parent = satSlider
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = satFill })
        local satThumb = Utility.Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0,12,0,12),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(s,0,0.5,0),
            Text = "",
            BorderSizePixel = 0,
            Parent = satSlider
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = satThumb })
        
        local valSlider = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(220,220,220),
            Size = UDim2.new(1,0,0,8),
            Position = UDim2.new(0,0,0,18),
            BorderSizePixel = 0,
            Parent = svContainer
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = valSlider })
        local valFill = Utility.Create("Frame", {
            BackgroundColor3 = self.Window.Colors.Accent,
            Size = UDim2.new(v,0,1,0),
            Parent = valSlider
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = valFill })
        local valThumb = Utility.Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0,12,0,12),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(v,0,0.5,0),
            Text = "",
            BorderSizePixel = 0,
            Parent = valSlider
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = valThumb })
        
        -- Slider logic for saturation and value
        local function updateSaturation(percent)
            s = percent
            satFill.Size = UDim2.new(s,0,1,0)
            satThumb.Position = UDim2.new(s,0,0.5,0)
            updateFromHSV()
        end
        local function updateValue(percent)
            v = percent
            valFill.Size = UDim2.new(v,0,1,0)
            valThumb.Position = UDim2.new(v,0,0.5,0)
            updateFromHSV()
        end
        
        local satDragging = false
        satSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then satDragging = true end end)
        valSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then satDragging = true end end) -- reuse variable
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then satDragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if satDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                if satSlider.Visible then
                    local relX = math.clamp((mousePos.X - satSlider.AbsolutePosition.X) / satSlider.AbsoluteSize.X, 0, 1)
                    updateSaturation(relX)
                    local relY = math.clamp((mousePos.X - valSlider.AbsolutePosition.X) / valSlider.AbsoluteSize.X, 0, 1)
                    updateValue(relY)
                end
            end
        end)
        
        updateFromHSV()
        return {
            GetColor = function() return currentColor end,
            SetColor = function(col) currentColor = col; h,s,v = Color3.toHSV(col); updateFromHSV() end
        }
    end
    
    self.Tabs[tab] = tab -- store reference
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

function Window:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Underline.Visible = false
    end
    tab.Content.Visible = true
    tab.Underline.Visible = true
    self.ActiveTab = tab
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        self._originalSize = self.WindowFrame.Size
        self._originalPos = self.WindowFrame.Position
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0,200,0,40), Position = UDim2.new(0,10,1,-60) })
        self.WindowFrame.ClipsDescendants = true
    else
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = self._originalSize, Position = self._originalPos })
    end
end

function Window:ToggleMaximize()
    self.Maximized = not self.Maximized
    if self.Maximized then
        self._prevSize = self.WindowFrame.Size
        self._prevPos = self.WindowFrame.Position
        local screenSize = self.ScreenGui.AbsoluteSize
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0,screenSize.X,0,screenSize.Y-40), Position = UDim2.new(0,0,0,0) })
    else
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:Notification(options)
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 3
    
    local notif = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.Notification,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -240, 1, -80),
        Size = UDim2.new(0, 220, 0, 60),
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = notif })
    Utility.ApplyStroke(notif, self.Colors.Stroke, 1)
    
    local titleLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-16,0,18),
        Position = UDim2.new(0,8,0,8),
        Parent = notif
    })
    local descLabel = Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = self.Colors.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-16,0,14),
        Position = UDim2.new(0,8,0,30),
        Parent = notif
    })
    
    notif.Position = UDim2.new(1, 20, 1, -80)
    Utility.Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -240, 1, -80) })
    delay(duration, function()
        Utility.Tween(notif, TweenInfo.new(0.3), { Position = UDim2.new(1, 20, 1, -80) })
        delay(0.3, function() notif:Destroy() end)
    end)
end

function Window:Destroy()
    Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0,0,0,0) })
    delay(0.3, function() self.ScreenGui:Destroy() end)
    for i, w in ipairs(Library.Windows) do
        if w == self then table.remove(Library.Windows, i) break end
    end
end

-- Library create window function
function Library.CreateWindow(options)
    local win = Window.new(options)
    return win
end

-- Return the library
local Lib = Library

--===== EXAMPLE USAGE =====--
--[[
local macOSLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/cocooperos/macOS-GUI-Library/main/Library.lua'))()

local Window = macOSLib.CreateWindow({
    Title = "KreinUX",
    Subtitle = "Premium Roblox Script",
    Icon = "🏠", -- use any emoji
    Theme = "Dark" -- or "Light"
})

local MainTab = Window:CreateTab({
    Title = "Main",
    Icon = "⚙️"
})

local PlayerSection = MainTab:CreateSection("Player")
MainTab:CreateToggle({
    Title = "God Mode",
    Default = false,
    Callback = function(val) print("God Mode:", val) end
})
MainTab:CreateSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val) print("WalkSpeed:", val) end
})
MainTab:CreateSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(val) print("JumpPower:", val) end
})

local CombatTab = Window:CreateTab({
    Title = "Combat",
    Icon = "⚔️"
})
local CombatSection = CombatTab:CreateSection("Combat")
CombatTab:CreateToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(val) print("Auto Farm:", val) end
})
CombatTab:CreateSlider({
    Title = "Reach",
    Min = 5,
    Max = 30,
    Default = 5,
    Callback = function(val) print("Reach:", val) end
})
CombatTab:CreateToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(val) print("Auto Click:", val) end
})

local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "🎨"
})
local UISection = SettingsTab:CreateSection("UI")
SettingsTab:CreateDropdown({
    Title = "Theme",
    Items = {"Dark", "Light"},
    Default = "Dark",
    Callback = function(val) print("Theme changed to:", val) end
})
SettingsTab:CreateColorPicker({
    Title = "Accent Color",
    Default = Color3.fromRGB(0,122,255),
    Callback = function(col) print("Accent color:", col) end
})
SettingsTab:CreateKeybind({
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key) print("Keybind set to:", key) end
})

-- Example notification
Window:Notification({
    Title = "Welcome!",
    Description = "macOS GUI Library loaded successfully.",
    Duration = 3
})

-- Example of a button that triggers notification
MainTab:CreateButton("Notify", function()
    Window:Notification({
        Title = "Button Pressed",
        Description = "You clicked the button!",
        Duration = 2
    })
end, "primary")
--]]
