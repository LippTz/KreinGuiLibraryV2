-- KreinGui Library v2.0 - Windows 11 Fluent Design
-- Dibuat untuk dipanggil via loadstring
-- Kembalikan tabel KreinGui agar bisa dipakai setelah loadstring

local KreinGui = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Container safe GUI
local function getGuiContainer()
    local success, result
    if gethui and type(gethui) == "function" then
        success, result = pcall(gethui)
        if success and result then return result end
    end
    success, result = pcall(function() return game:GetService("CoreGui") end)
    if success and result then return result end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Base class untuk memory management
local Base = {}
Base.__index = Base

function Base.new()
    local self = setmetatable({ Connections = {} }, Base)
    return self
end

function Base:AddConnection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(self.Connections, conn)
    return conn
end

function Base:Destroy()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    if self.Instance then
        self.Instance:Destroy()
    end
end

-- ====================== WINDOW ======================
local Window = setmetatable({}, Base)
Window.__index = Window

function Window.new(options)
    local self = setmetatable(Base.new(), Window)
    local opt = options or {}

    self.Title = opt.Title or "KreinGui"
    self.AccentColor = opt.AccentColor or Color3.fromRGB(0, 120, 212)
    self.Gui = getGuiContainer()
    self.Tabs = {}
    self.CurrentTab = nil

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    main.Parent = self.Gui
    self.Instance = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main

    -- Header (drag area)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Name = "Header"
    header.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = self.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 50, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = header

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    sidebar.BackgroundTransparency = 0.1
    sidebar.BorderSizePixel = 0
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)
    sidebar.Parent = main
    self.Sidebar = sidebar

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 4)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = sidebar

    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -180, 1, -40)
    content.Position = UDim2.new(0, 180, 0, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Name = "Content"
    content.Parent = main
    self.Content = content

    ---- Drag functionality ----
    local dragStart, startPos
    self:AddConnection(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    self:AddConnection(header.InputChanged, function(input)
        if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    ---- Resize handle ----
    local resize = Instance.new("TextButton")
    resize.Size = UDim2.new(0, 20, 0, 20)
    resize.Position = UDim2.new(1, -20, 1, -20)
    resize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    resize.BackgroundTransparency = 0.5
    resize.Text = "⤢"
    resize.TextSize = 14
    resize.TextColor3 = Color3.fromRGB(255, 255, 255)
    resize.BorderSizePixel = 0
    Instance.new("UICorner", resize).CornerRadius = UDim.new(0, 4)
    resize.Parent = main

    local resizeStart, startSize
    self:AddConnection(resize.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizeStart = input.Position
            startSize = main.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizeStart = nil
                end
            end)
        end
    end)
    self:AddConnection(resize.InputChanged, function(input)
        if resizeStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local w = math.max(400, startSize.X.Offset + delta.X)
            local h = math.max(300, startSize.Y.Offset + delta.Y)
            main.Size = UDim2.new(0, w, 0, h)
        end
    end)

    return self
end

-- AddTab
function Window:AddTab(name, icon)
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.ScrollBarThickness = 4
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.Visible = false
    tabFrame.Parent = self.Content

    local sectionList = Instance.new("UIListLayout")
    sectionList.Padding = UDim.new(0, 10)
    sectionList.SortOrder = Enum.SortOrder.LayoutOrder
    sectionList.Parent = tabFrame

    -- Objek Tab
    local tab = {
        Window = self,
        Frame = tabFrame,
        Sections = {},
        Name = name
    }

    -- Method AddSection
    function tab:AddSection(title)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1, -20, 0, 0)
        sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        sectionFrame.BackgroundTransparency = 0.2
        sectionFrame.BorderSizePixel = 0
        Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
        sectionFrame.Parent = self.Frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 24)
        titleLabel.Position = UDim2.new(0, 10, 0, 4)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 12
        titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        titleLabel.Text = title
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = sectionFrame

        local elementHolder = Instance.new("Frame")
        elementHolder.Size = UDim2.new(1, -20, 0, 0)
        elementHolder.Position = UDim2.new(0, 10, 0, 30)
        elementHolder.BackgroundTransparency = 1
        elementHolder.BorderSizePixel = 0
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = elementHolder
        elementHolder.Parent = sectionFrame

        -- Objek Section
        local section = {
            Parent = self,
            Frame = sectionFrame,
            Holder = elementHolder
        }

        -- Daftar method Section (Button, Toggle, dll.) akan didefinisikan di bawah
        -- (untuk efisiensi, kita inject method dari luar setelah definisi lengkap)

        section.AddButton = function(data) return CreateButton(section, data) end
        section.AddToggle = function(data) return CreateToggle(section, data) end
        section.AddSlider = function(data) return CreateSlider(section, data) end
        section.AddInput = function(data) return CreateInput(section, data) end
        section.AddDropdown = function(data) return CreateDropdown(section, data) end
        section.AddKeybind = function(data) return CreateKeybind(section, data) end
        section.AddColorPicker = function(data) return CreateColorPicker(section, data) end
        section.AddLabel = function(text) return CreateLabel(section, text) end
        section.AddParagraph = function(text) return CreateParagraph(section, text) end
        section.AddClipboardButton = function(text, content) return CreateClipboardButton(section, text, content) end
        section.AddGridList = function(data) return CreateGridList(section, data) end

        elementHolder.Changed:Connect(function()
            sectionFrame.Size = UDim2.new(1, -20, 0, elementHolder.AbsoluteSize.Y + 34)
        end)

        table.insert(self.Sections, section)
        return section
    end

    self.Tabs[name] = tab

    -- Tombol Tab di sidebar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 14
    tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    tabBtn.Text = "  " .. (icon or "") .. "  " .. name
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = self.Sidebar

    tabBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)

    if not self.CurrentTab then
        self:SwitchTab(name)
    end

    return tab
end

function Window:SwitchTab(name)
    if self.CurrentTab then
        self.CurrentTab.Frame.Visible = false
    end
    local tab = self.Tabs[name]
    if tab then
        tab.Frame.Visible = true
        self.CurrentTab = tab
    end
end

function Window:Notify(data)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 80)
    notif.Position = UDim2.new(1, -300, 1, -100)
    notif.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", notif).Color = Color3.fromRGB(50, 50, 50)
    notif.Parent = self.Instance

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = data.Title or ""
    title.Parent = notif

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -20, 1, -36)
    content.Position = UDim2.new(0, 10, 0, 28)
    content.BackgroundTransparency = 1
    content.Font = Enum.Font.Gotham
    content.TextSize = 12
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextWrapped = true
    content.Text = data.Content or ""
    content.Parent = notif

    task.delay(data.Duration or 5, function() notif:Destroy() end)
end

function Window:ProgressBar(data)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 300, 0, 30)
    bar.Position = UDim2.new(0.5, -150, 0.5, -15)
    bar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    bar.BackgroundTransparency = 0.2
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
    bar.Parent = self.Instance

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(data.Percentage / 100, 0, 1, 0)
    fill.BackgroundColor3 = self.AccentColor
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
    fill.Parent = bar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = (data.Text or "") .. " " .. math.clamp(data.Percentage, 0, 100) .. "%"
    label.Parent = bar

    TweenService:Create(fill, TweenInfo.new(0.5), { Size = UDim2.new(data.Percentage / 100, 0, 1, 0) }):Play()
    task.delay(3, function() bar:Destroy() end)
end

-- ====================== COMPONENT BUILDERS ======================
local MIN_TOUCH = 32

function CreateButton(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, MIN_TOUCH)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundTransparency = 0.4
    btn.BorderSizePixel = 0
    btn.Text = data.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(70, 70, 70)
    btn.Parent = frame

    local hoverIn = btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = section.Parent.Window.AccentColor, BackgroundTransparency = 0.2 }):Play()
    end)
    local hoverOut = btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(50, 50, 50), BackgroundTransparency = 0.4 }):Play()
    end)
    local click = nil
    if data.Callback then
        click = btn.MouseButton1Click:Connect(data.Callback)
    end
    return { Destroy = function() hoverIn:Disconnect() hoverOut:Disconnect() if click then click:Disconnect() end frame:Destroy() end }
end

function CreateToggle(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, MIN_TOUCH)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local state = data.Default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 44, 0, 22)
    bar.Position = UDim2.new(1, -54, 0.5, -11)
    bar.BackgroundColor3 = state and section.Parent.Window.AccentColor or Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    bar.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, state and 24 or 4, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Parent = bar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = data.Text
    label.Parent = frame

    local function updateToggle(on)
        TweenService:Create(bar, TweenInfo.new(0.25), { BackgroundColor3 = on and section.Parent.Window.AccentColor or Color3.fromRGB(60, 60, 60) }):Play()
        TweenService:Create(knob, TweenInfo.new(0.25), { Position = UDim2.new(0, on and 24 or 4, 0.5, -8) }):Play()
    end

    local click = btn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle(state)
        if data.Callback then data.Callback(state) end
    end)

    return { Destroy = function() click:Disconnect() frame:Destroy() end, SetState = function(s) state = s updateToggle(s) end }
end

function CreateSlider(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local min, max, current = data.Min or 0, data.Max or 100, data.Default or 0
    local precise = data.Precise or false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 16)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = data.Text
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 16)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = precise and string.format("%.1f", current) or tostring(math.floor(current))
    valueLabel.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 8)
    barBg.Position = UDim2.new(0, 10, 0, 20)
    barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
    barBg.Parent = frame

    local barFill = Instance.new("Frame")
    local perc = math.clamp((current - min) / (max - min), 0, 1)
    barFill.Size = UDim2.new(perc, 0, 1, 0)
    barFill.BackgroundColor3 = section.Parent.Window.AccentColor
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
    barFill.Parent = barBg

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(perc, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Parent = barBg

    local dragging = false
    local function updateSlider(input)
        local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        local val = min + (max - min) * rel
        if not precise then val = math.floor(val) end
        current = val
        valueLabel.Text = precise and string.format("%.1f", val) or tostring(val)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        if data.Callback then data.Callback(val) end
    end

    local inputBegan = knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    local inputChanged = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    local inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Destroy = function() inputBegan:Disconnect() inputChanged:Disconnect() inputEnded:Disconnect() frame:Destroy() end }
end

function CreateInput(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = data.Placeholder or ""
    box.Text = ""
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 1

    local focused = box.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.3), { Color = section.Parent.Window.AccentColor }):Play()
    end)
    local focusLost = box.FocusLost:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(70, 70, 70) }):Play()
        if data.Callback then data.Callback(box.Text) end
    end)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Position = UDim2.new(0, 10, 0, -18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = data.Text or ""
    label.Parent = frame

    return { Destroy = function() focused:Disconnect() focusLost:Disconnect() frame:Destroy() end }
end

function CreateDropdown(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local options = data.Options or {}
    local default = data.Default or options[1]
    local searchable = data.Searchable or false
    local selected = default

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 1, 0)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = selected or "Select..."
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = frame

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -20, 0, 0)
    listFrame.Position = UDim2.new(0, 10, 1, 4)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    listFrame.BackgroundTransparency = 0.1
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 10
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    listFrame.Parent = frame

    local searchBox
    if searchable then
        searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, -10, 0, 24)
        searchBox.Position = UDim2.new(0, 5, 0, 5)
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextSize = 14
        searchBox.PlaceholderText = "Search..."
        searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        searchBox.BackgroundTransparency = 0.3
        searchBox.BorderSizePixel = 0
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
        searchBox.Parent = listFrame
    end

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local function updateList(searchTerm)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local filtered = options
        if searchTerm and searchTerm ~= "" then
            filtered = {}
            for _, opt in ipairs(options) do
                if string.find(string.lower(opt), string.lower(searchTerm)) then
                    table.insert(filtered, opt)
                end
            end
        end
        for _, opt in ipairs(filtered) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -10, 0, 24)
            optBtn.Position = UDim2.new(0, 5, 0, 0)
            optBtn.BackgroundTransparency = 1
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 14
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.Text = opt
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                btn.Text = opt
                listFrame.Visible = false
                if data.Callback then data.Callback(opt) end
            end)
        end
        local totalHeight = (searchable and 28 or 0) + (#filtered * 26)
        listFrame.Size = UDim2.new(1, -20, 0, math.min(150, totalHeight))
    end

    if searchable then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            updateList(searchBox.Text)
        end)
    end

    local click = btn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            updateList(searchable and searchBox.Text or nil)
        end
    end)

    updateList(nil)
    return { Destroy = function() click:Disconnect() frame:Destroy() end }
end

function CreateKeybind(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, MIN_TOUCH)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local default = data.Default or Enum.KeyCode.Unknown
    local currentKey = default.Name ~= "Unknown" and default.Name or "None"
    local listening = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = data.Text .. ": [" .. currentKey .. "]"
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(70, 70, 70)
    btn.Parent = frame

    local function startListening()
        if listening then return end
        listening = true
        btn.Text = data.Text .. ": [Press a key]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode.Name
                btn.Text = data.Text .. ": [" .. currentKey .. "]"
                listening = false
                if data.Callback then data.Callback(input.KeyCode) end
                conn:Disconnect()
            end
        end)
        task.delay(5, function()
            if listening then
                listening = false
                btn.Text = data.Text .. ": [" .. currentKey .. "]"
                conn:Disconnect()
            end
        end)
    end

    local click = btn.MouseButton1Click:Connect(startListening)
    return { Destroy = function() click:Disconnect() frame:Destroy() end }
end

function CreateColorPicker(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, MIN_TOUCH)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder

    local currentColor = data.Default or Color3.fromRGB(255, 255, 255)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = currentColor
    btn.BorderSizePixel = 0
    btn.Text = data.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = frame

    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 160, 0, 80)
    pickerFrame.Position = UDim2.new(0, 10, 1, 4)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    pickerFrame.BackgroundTransparency = 0.1
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 10
    Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 6)
    pickerFrame.Parent = frame

    local colors = {
        Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
        Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(255,0,255),
        Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0)
    }
    for i, col in ipairs(colors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 30, 0, 30)
        colorBtn.Position = UDim2.new(0, ((i-1)%4)*35 + 10, 0, math.floor((i-1)/4)*35 + 10)
        colorBtn.BackgroundColor3 = col
        colorBtn.BorderSizePixel = 0
        colorBtn.Text = ""
        Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 4)
        colorBtn.MouseButton1Click:Connect(function()
            currentColor = col
            btn.BackgroundColor3 = col
            if data.Callback then data.Callback(col) end
            pickerFrame.Visible = false
        end)
        colorBtn.Parent = pickerFrame
    end

    local click = btn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = not pickerFrame.Visible
    end)

    return { Destroy = function() click:Disconnect() frame:Destroy() end }
end

function CreateLabel(section, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 20)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = frame
    return { Destroy = function() frame:Destroy() end }
end

function CreateParagraph(section, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Text = text
    label.Parent = frame
    return { Destroy = function() frame:Destroy() end }
end

function CreateClipboardButton(section, text, content)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, MIN_TOUCH)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundTransparency = 0.4
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(70, 70, 70)
    btn.Parent = frame
    local click = btn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(content) end
        btn.Text = "Copied!"
        task.delay(1, function() btn.Text = text end)
    end)
    return { Destroy = function() click:Disconnect() frame:Destroy() end }
end

function CreateGridList(section, data)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 100)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Holder
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, data.ItemSize or 60, 0, data.ItemSize or 60)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.VerticalAlignment = Enum.VerticalAlignment.Top
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = frame

    for _, item in ipairs(data.Items or {}) do
        local itemFrame = Instance.new("ImageButton")
        itemFrame.Size = UDim2.new(0, data.ItemSize or 60, 0, data.ItemSize or 60)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        itemFrame.BorderSizePixel = 0
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
        itemFrame.Image = item.Image or ""
        itemFrame.ImageTransparency = 0.5
        itemFrame.Parent = frame
        if item.Callback then
            itemFrame.MouseButton1Click:Connect(item.Callback)
        end
    end
    return { Destroy = function() frame:Destroy() end }
end

-- Entry point
function KreinGui.new(options)
    return Window.new(options)
end

return KreinGui
