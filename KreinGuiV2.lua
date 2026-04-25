-- macOS GUI Library for Roblox
-- KreinGuiV2

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Utility = {}
function Utility.Create(className, props)
    local inst = Instance.new(className)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end
function Utility.Tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end
function Utility.ApplyStroke(frame, color, thickness)
    local s = Utility.Create("UIStroke", {
        Color = color, Thickness = thickness, Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    s.Parent = frame
    return s
end
function Utility.AddBlur(parent, size)
    local b = Utility.Create("BlurEffect", { Size = size or 10 })
    b.Parent = parent
    return b
end

local Icons = {
    gear = "⚙️", house = "🏠", person = "👤", sparkles = "✨",
    keyboard = "⌨️", colorwheel = "🎨", slider = "🎚️",
    toggle = "🔘", dropdown = "📋", close = "✕",
    minimize = "─", maximize = "➕", search = "🔍"
}

local Themes = {
    Dark = {
        Background = Color3.fromRGB(30,30,30),
        WindowBackground = Color3.fromRGB(45,45,45),
        TitleBar = Color3.fromRGB(35,35,35),
        Text = Color3.fromRGB(220,220,220),
        SecondaryText = Color3.fromRGB(150,150,150),
        Accent = Color3.fromRGB(0,122,255),
        Danger = Color3.fromRGB(255,69,58),
        Success = Color3.fromRGB(48,209,88),
        Stroke = Color3.fromRGB(80,80,80),
        SectionBackground = Color3.fromRGB(55,55,55),
        ButtonPrimary = Color3.fromRGB(0,122,255),
        ButtonSecondary = Color3.fromRGB(70,70,70),
        ToggleTrackOff = Color3.fromRGB(70,70,70),
        ToggleTrackOn = Color3.fromRGB(48,209,88),
        SliderTrack = Color3.fromRGB(70,70,70),
        DropdownList = Color3.fromRGB(55,55,55),
        Notification = Color3.fromRGB(45,45,45)
    },
    Light = {
        Background = Color3.fromRGB(242,242,247),
        WindowBackground = Color3.fromRGB(255,255,255),
        TitleBar = Color3.fromRGB(240,240,245),
        Text = Color3.fromRGB(30,30,30),
        SecondaryText = Color3.fromRGB(100,100,100),
        Accent = Color3.fromRGB(0,122,255),
        Danger = Color3.fromRGB(255,69,58),
        Success = Color3.fromRGB(48,209,88),
        Stroke = Color3.fromRGB(200,200,200),
        SectionBackground = Color3.fromRGB(245,245,250),
        ButtonPrimary = Color3.fromRGB(0,122,255),
        ButtonSecondary = Color3.fromRGB(220,220,220),
        ToggleTrackOff = Color3.fromRGB(200,200,200),
        ToggleTrackOn = Color3.fromRGB(48,209,88),
        SliderTrack = Color3.fromRGB(220,220,220),
        DropdownList = Color3.fromRGB(245,245,250),
        Notification = Color3.fromRGB(255,255,255)
    }
}

local Library = {}
Library.Windows = {}

local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Title = options.Title or "Window"
    self.Subtitle = options.Subtitle or ""
    self.Icon = options.Icon or Icons.house
    self.Theme = options.Theme or "Dark"
    self.Colors = Themes[self.Theme]
    self.Tabs = {}
    self.ActiveTab = nil

    local parent = (syn and syn.protect_gui and CoreGui) or game.Players.LocalPlayer:FindFirstChild("PlayerGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui = Utility.Create("ScreenGui", { Name = "macOS_GUI", Parent = parent })

    self.BlurFrame = Utility.Create("Frame", {
        BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size = UDim2.new(1,0,1,0), Parent = self.ScreenGui
    })
    Utility.AddBlur(self.BlurFrame, 15)

    self.WindowFrame = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.WindowBackground, BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200), Size = UDim2.new(0,600,0,400),
        ClipsDescendants = true, Parent = self.ScreenGui
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = self.WindowFrame })
    Utility.ApplyStroke(self.WindowFrame, self.Colors.Stroke, 1)

    -- Title bar
    self.TitleBar = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.TitleBar, Size = UDim2.new(1,0,0,40),
        BorderSizePixel = 0, Parent = self.WindowFrame
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(12,0), Parent = self.TitleBar })

    local function makeTrafficBtn(color, pos, icon, callback)
        local btn = Utility.Create("TextButton", {
            BackgroundColor3 = color, Size = UDim2.new(0,12,0,12),
            Position = UDim2.new(0,pos,0.5,-6), Text = "", BorderSizePixel = 0,
            Parent = self.TitleBar
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = btn })
        btn.MouseEnter:Connect(function() btn.Text = icon end)
        btn.MouseLeave:Connect(function() btn.Text = "" end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    makeTrafficBtn(Color3.fromRGB(255,69,58), 12, Icons.close, function() self:Destroy() end)
    makeTrafficBtn(Color3.fromRGB(255,189,46), 30, Icons.minimize, function() self:ToggleMinimize() end)
    makeTrafficBtn(Color3.fromRGB(40,200,70), 48, Icons.maximize, function() self:ToggleMaximize() end)

    local titleCont = Utility.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,-120,1,0),
        Position = UDim2.new(0,70,0,0), Parent = self.TitleBar
    })
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = self.Icon, TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(0,5,0.5,-10), Parent = titleCont
    })
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = self.Title, TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,30,0,0), Parent = titleCont
    })
    if self.Subtitle ~= "" then
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = self.Subtitle, TextColor3 = self.Colors.SecondaryText,
            Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-30,0,14), Position = UDim2.new(0,30,0,22), Parent = titleCont
        })
    end

    self.TabContainer = Utility.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,-20,0,32),
        Position = UDim2.new(0,10,0,46), Parent = self.WindowFrame
    })
    Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4), Parent = self.TabContainer
    })

    self.ContentFrame = Utility.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,-20,1,-88),
        Position = UDim2.new(0,10,0,82), ClipsDescendants = true, Parent = self.WindowFrame
    })

    -- Drag
    local dragging, startPos, dragStart
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; startPos = self.WindowFrame.Position; dragStart = input.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    self.TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.WindowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Entrance animation
    self.WindowFrame.Size = UDim2.new(0,600,0,0)
    Utility.Tween(self.WindowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0,600,0,400) })

    table.insert(Library.Windows, self)
    return self
end

function Window:CreateTab(options)
    local tab = { Title = options.Title, Icon = options.Icon or Icons.house, Window = self }
    tab.Content = Utility.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Visible = false,
        Parent = self.ContentFrame
    })
    tab.ScrollingFrame = Utility.Create("ScrollingFrame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 3, ScrollBarImageColor3 = self.Colors.Accent, Parent = tab.Content
    })
    Utility.Create("UIListLayout", {
        Padding = UDim.new(0,8), FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.ScrollingFrame
    })

    tab.Button = Utility.Create("TextButton", {
        BackgroundTransparency = 1, Text = "", Size = UDim2.new(0,0,1,0),
        AutomaticSize = Enum.AutomaticSize.X, Parent = self.TabContainer
    })
    local btnLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Button
    })
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = tab.Icon, TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham, TextSize = 14, Size = UDim2.new(0,18,0,18), Parent = tab.Button
    })
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = tab.Title, TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham, TextSize = 13, Size = UDim2.new(0,0,1,0),
        AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Left, Parent = tab.Button
    })
    tab.Underline = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.Accent, Size = UDim2.new(1,-10,0,2),
        Position = UDim2.new(0,5,1,0), BorderSizePixel = 0, Visible = false,
        AnchorPoint = Vector2.new(0,1), Parent = tab.Button
    })

    tab.Button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    function tab:CreateSection(title)
        local section = { Title = title, Window = self }
        section.Container = Utility.Create("Frame", {
            BackgroundColor3 = self.Colors.SectionBackground, BorderSizePixel = 0,
            Size = UDim2.new(0.95,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
            Parent = self.ScrollingFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = section.Container })
        Utility.ApplyStroke(section.Container, self.Colors.Stroke, 1)
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = title, TextColor3 = self.Colors.SecondaryText,
            Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,-20,0,24), Position = UDim2.new(0,10,0,8), Parent = section.Container
        })
        section.InnerList = Utility.Create("UIListLayout", {
            Padding = UDim.new(0,6), FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.Container
        })
        section.InnerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Container.Size = UDim2.new(0.95,0,0,section.InnerList.AbsoluteContentSize.Y + 30)
        end)
        function section:AddElement(frame)
            frame.Parent = self.ScrollingFrame
            frame.Size = UDim2.new(0.9,0,0,36)
        end
        table.insert(self.Sections or {}, section)
        return section
    end

    function tab:CreateButton(text, callback, style)
        style = style or "primary"
        local color = style == "primary" and self.Colors.ButtonPrimary or style == "danger" and self.Colors.Danger or self.Colors.ButtonSecondary
        local textColor = style == "secondary" and self.Colors.Text or Color3.fromRGB(255,255,255)
        local btn = Utility.Create("TextButton", {
            BackgroundColor3 = color, Text = text, TextColor3 = textColor,
            Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
            Size = UDim2.new(0.9,0,0,30), Parent = self.ScrollingFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = btn })
        Utility.ApplyStroke(btn, self.Colors.Stroke, 1)
        btn.MouseButton1Click:Connect(callback or function() end)
        return btn
    end

    function tab:CreateToggle(options)
        local default = options.Default or false
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = options.Title or "Toggle",
            TextColor3 = self.Colors.Text, Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.7,0,1,0),
            Parent = container
        })
        local switch = Utility.Create("Frame", {
            BackgroundColor3 = default and self.Colors.ToggleTrackOn or self.Colors.ToggleTrackOff,
            Size = UDim2.new(0,40,0,22), Position = UDim2.new(1,-40,0.5,-11),
            BorderSizePixel = 0, Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = switch })
        local knob = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(0,18,0,18),
            Position = default and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BorderSizePixel = 0, Parent = switch
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })
        local enabled = default
        local function update()
            Utility.Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = enabled and self.Colors.ToggleTrackOn or self.Colors.ToggleTrackOff })
            Utility.Tween(knob, TweenInfo.new(0.2), { Position = enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9) })
            callback(enabled)
        end
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled; update()
            end
        end)
        return { Set = function(v) enabled = v; update() end, Get = function() return enabled end }
    end

    function tab:CreateSlider(options)
        local min, max, default = options.Min or 0, options.Max or 100, options.Default or options.Min
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = options.Title or "Slider",
            TextColor3 = self.Colors.Text, Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.4,0,1,0),
            Parent = container
        })
        local valLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = tostring(default),
            TextColor3 = self.Colors.Text, Font = Enum.Font.GothamBold, TextSize = 13,
            Size = UDim2.new(0,40,1,0), Position = UDim2.new(1,-40,0,0),
            Parent = container
        })
        local track = Utility.Create("Frame", {
            BackgroundColor3 = self.Colors.SliderTrack, Size = UDim2.new(1,-90,0,4),
            Position = UDim2.new(0,5,0.5,-2), BorderSizePixel = 0, Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })
        local fill = Utility.Create("Frame", {
            BackgroundColor3 = self.Colors.Accent, Size = UDim2.new((default-min)/(max-min),0,1,0),
            BorderSizePixel = 0, Parent = track
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })
        local thumb = Utility.Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(0,14,0,14),
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new((default-min)/(max-min),0,0.5,0),
            Text = "", BorderSizePixel = 0, Parent = track
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = thumb })

        local dragging = false
        local function setPercent(p)
            local val = min + (max-min)*p
            valLabel.Text = tostring(math.floor(val))
            fill.Size = UDim2.new(p,0,1,0)
            thumb.Position = UDim2.new(p,0,0.5,0)
            callback(val)
        end
        thumb.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                local relX = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                setPercent(relX)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                setPercent(relX)
            end
        end)
        return { Set = function(v) setPercent(math.clamp((v-min)/(max-min),0,1)) end }
    end

    function tab:CreateDropdown(options)
        local items = options.Items or {}
        local default = options.Default or items[1] or ""
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = options.Title or "Dropdown",
            TextColor3 = self.Colors.Text, Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.4,0,1,0),
            Parent = container
        })
        local selectedText = Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = default, TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold, TextSize = 13, Size = UDim2.new(1,-100,1,0),
            Position = UDim2.new(0.4,0,0,0), TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container
        })
        local arrow = Utility.Create("TextButton", {
            BackgroundTransparency = 1, Text = "▼", TextColor3 = self.Colors.Text,
            Font = Enum.Font.GothamBold, TextSize = 10, Size = UDim2.new(0,20,1,0),
            Position = UDim2.new(1,-20,0,0), Parent = container
        })
        local dropdownFrame = Utility.Create("Frame", {
            BackgroundColor3 = self.Colors.DropdownList, Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(0,0,1,0), BorderSizePixel = 0, Visible = false,
            Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = dropdownFrame })
        Utility.ApplyStroke(dropdownFrame, self.Colors.Stroke, 1)
        local listLayout = Utility.Create("UIListLayout", {
            Padding = UDim.new(0,2), FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = dropdownFrame
        })
        local function populate()
            for _, v in pairs(dropdownFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, item in ipairs(items) do
                local btn = Utility.Create("TextButton", {
                    BackgroundTransparency = 1, Text = item, TextColor3 = self.Colors.Text,
                    Font = Enum.Font.Gotham, TextSize = 12, Size = UDim2.new(0.95,0,0,24),
                    Parent = dropdownFrame
                })
                btn.MouseButton1Click:Connect(function()
                    selectedText.Text = item; dropdownFrame.Visible = false; callback(item)
                end)
            end
        end
        populate()
        local open = false
        arrow.MouseButton1Click:Connect(function()
            open = not open; dropdownFrame.Visible = open
            if open then dropdownFrame.Size = UDim2.new(1,0,0,#items*26+10) end
        end)
        return {
            SetItems = function(new) items = new; populate() end,
            GetValue = function() return selectedText.Text end
        }
    end

    function tab:CreateKeybind(options)
        local default = options.Default
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,36),
            Parent = self.ScrollingFrame
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = options.Title or "Keybind",
            TextColor3 = self.Colors.Text, Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.5,0,1,0),
            Parent = container
        })
        local boundKey = default
        local keyBtn = Utility.Create("TextButton", {
            BackgroundColor3 = self.Colors.ButtonSecondary, Text = boundKey and boundKey.Name or "None",
            TextColor3 = self.Colors.Text, Font = Enum.Font.GothamBold, TextSize = 12,
            BorderSizePixel = 0, Size = UDim2.new(0,70,0,24),
            Position = UDim2.new(1,-70,0.5,-12), Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,4), Parent = keyBtn })
        local listening = false
        keyBtn.MouseButton1Click:Connect(function()
            listening = true; keyBtn.Text = "..."
            local conn; conn = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    boundKey = input.KeyCode; keyBtn.Text = input.KeyCode.Name
                    listening = false; conn:Disconnect(); callback(input.KeyCode)
                end
            end)
            delay(5, function() if listening then listening = false; keyBtn.Text = boundKey and boundKey.Name or "None"; conn:Disconnect() end end)
        end)
        return { GetKey = function() return boundKey end, SetKey = function(k) boundKey = k; keyBtn.Text = k.Name end }
    end

    function tab:CreateColorPicker(options)
        local default = options.Default or Color3.fromRGB(255,255,255)
        local callback = options.Callback or function() end
        local container = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,100),
            Parent = self.ScrollingFrame
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1, Text = options.Title or "Color Picker",
            TextColor3 = self.Colors.Text, Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.5,0,0,20),
            Parent = container
        })
        local preview = Utility.Create("Frame", {
            BackgroundColor3 = default, Size = UDim2.new(0.8,0,0,30),
            Position = UDim2.new(0.1,0,0,25), BorderSizePixel = 0, Parent = container
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = preview })
        Utility.ApplyStroke(preview, self.Colors.Stroke, 1)

        local h, s, v = Color3.toHSV(default)
        local currentColor = default
        local function updateFromHSV()
            currentColor = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = currentColor
            callback(currentColor)
        end

        -- Hue slider
        local hueFrame = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.8,0,0,14),
            Position = UDim2.new(0.1,0,0,60), Parent = container
        })
        local hueTrack = Utility.Create("ImageLabel", {
            Image = "rbxassetid://9607867758", Size = UDim2.new(1,0,1,0), Parent = hueFrame
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueTrack })
        local hueThumb = Utility.Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(0,10,0,10),
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(h,0,0.5,0),
            BorderSizePixel = 0, Parent = hueTrack
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueThumb })

        local draggingHue = false
        hueTrack.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end end)
        UserInputService.InputChanged:Connect(function(inp)
            if draggingHue and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp((UserInputService:GetMouseLocation().X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
                h = relX; hueThumb.Position = UDim2.new(h,0,0.5,0); updateFromHSV()
            end
        end)

        -- Sat/Val sliders
        local svCont = Utility.Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.8,0,0,30),
            Position = UDim2.new(0.1,0,0,80), Parent = container
        })
        local function makeSVSlider(yPos, initial, setFunc)
            local slider = Utility.Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(220,220,220), Size = UDim2.new(1,0,0,8),
                Position = UDim2.new(0,0,0,yPos), BorderSizePixel = 0, Parent = svCont
            })
            Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = slider })
            local fill = Utility.Create("Frame", {
                BackgroundColor3 = self.Colors.Accent, Size = UDim2.new(initial,0,1,0), Parent = slider
            })
            Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })
            local thumb = Utility.Create("TextButton", {
                BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(0,12,0,12),
                AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(initial,0,0.5,0),
                Text = "", BorderSizePixel = 0, Parent = slider
            })
            Utility.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = thumb })
            return fill, thumb, slider
        end
        local satFill, satThumb, satSlider = makeSVSlider(0, s, nil)
        local valFill, valThumb, valSlider = makeSVSlider(18, v, nil)

        local satDragging, valDragging = false, false
        satSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then satDragging = true end end)
        valSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then valDragging = true end end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then satDragging = false; valDragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                if satDragging then
                    local relX = math.clamp((mousePos.X - satSlider.AbsolutePosition.X) / satSlider.AbsoluteSize.X, 0, 1)
                    s = relX; satFill.Size = UDim2.new(relX,0,1,0); satThumb.Position = UDim2.new(relX,0,0.5,0); updateFromHSV()
                elseif valDragging then
                    local relX = math.clamp((mousePos.X - valSlider.AbsolutePosition.X) / valSlider.AbsoluteSize.X, 0, 1)
                    v = relX; valFill.Size = UDim2.new(relX,0,1,0); valThumb.Position = UDim2.new(relX,0,0.5,0); updateFromHSV()
                end
            end
        end)

        updateFromHSV()
        return {
            GetColor = function() return currentColor end,
            SetColor = function(col) currentColor = col; h,s,v = Color3.toHSV(col); updateFromHSV() end
        }
    end

    self.Tabs[tab] = tab
    if not self.ActiveTab then self:SelectTab(tab) end
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
    else
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = self._originalSize, Position = self._originalPos })
    end
end

function Window:ToggleMaximize()
    self.Maximized = not self.Maximized
    if self.Maximized then
        self._prevSize = self.WindowFrame.Size
        self._prevPos = self.WindowFrame.Position
        local s = self.ScreenGui.AbsoluteSize
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0,s.X,0,s.Y-40), Position = UDim2.new(0,0,0,0) })
    else
        Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = self._prevSize, Position = self._prevPos })
    end
end

function Window:Notification(options)
    local title = options.Title or ""
    local desc = options.Description or ""
    local dur = options.Duration or 3
    local notif = Utility.Create("Frame", {
        BackgroundColor3 = self.Colors.Notification, BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 1, -80), Size = UDim2.new(0,220,0,60),
        Parent = self.ScreenGui
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = notif })
    Utility.ApplyStroke(notif, self.Colors.Stroke, 1)
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = title, TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-16,0,18), Position = UDim2.new(0,8,0,8), Parent = notif
    })
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1, Text = desc, TextColor3 = self.Colors.SecondaryText,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,-16,0,14), Position = UDim2.new(0,8,0,30), Parent = notif
    })
    Utility.Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -240, 1, -80) })
    delay(dur, function()
        Utility.Tween(notif, TweenInfo.new(0.3), { Position = UDim2.new(1, 20, 1, -80) })
        delay(0.3, function() notif:Destroy() end)
    end)
end

function Window:Destroy()
    Utility.Tween(self.WindowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0,0,0,0) })
    delay(0.3, function() self.ScreenGui:Destroy() end)
    for i,w in ipairs(Library.Windows) do if w == self then table.remove(Library.Windows, i); break end end
end

Library.CreateWindow = function(options) return Window.new(options) end

-- WAJIB! Mengembalikan object Library
return Library
