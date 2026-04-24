-- KreinGui Library v1.0 - Windows 11 Fluent Design for Roblox
-- Lead Software Architect: DeepSeek AI
-- Fully encapsulated, returns table via loadstring

local KreinGui = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = nil

-- Utility: get safe GUI container
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

-- Base component class with memory management
local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent.new(parent)
	local self = setmetatable({
		Parent = parent,
		Connections = {},
		Elements = {}
	}, BaseComponent)
	return self
end

function BaseComponent:Destroy()
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}
	if self.MainFrame then
		self.MainFrame:Destroy()
		self.MainFrame = nil
	end
	for _, elem in ipairs(self.Elements) do
		if elem.Destroy then elem:Destroy() end
	end
	self = nil
end

-- Utility to add connection tracking
function BaseComponent:AddConnection(signal, callback)
	local conn = signal:Connect(callback)
	table.insert(self.Connections, conn)
	return conn
end

-- Window class (main hub)
local Window = setmetatable({}, BaseComponent)
Window.__index = Window

function Window.new(options)
	local self = setmetatable(BaseComponent.new(nil), Window)
	local opts = options or {}
	self.Title = opts.Title or "KreinGui"
	self.Icon = opts.Icon or ""
	self.AccentColor = opts.AccentColor or Color3.fromRGB(0, 120, 212)
	self.GuiContainer = getGuiContainer()
	self.Tabs = {}
	self.CurrentTab = nil

	-- Main Frame
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 600, 0, 400)
	main.Position = UDim2.new(0.5, -300, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	main.BackgroundTransparency = 0.2
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = false
	main.Parent = self.GuiContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = main

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 50)
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = main

	self.MainFrame = main

	-- Header (drag handle)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundTransparency = 1
	header.Name = "Header"
	header.Parent = main

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = self.Title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
	titleLabel.TextSize = 16
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 50, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = header

	-- Optional icon
	if self.Icon ~= "" then
		local icon = Instance.new("ImageLabel")
		icon.Image = self.Icon
		icon.Size = UDim2.new(0, 24, 0, 24)
		icon.Position = UDim2.new(0, 12, 0.5, -12)
		icon.BackgroundTransparency = 1
		icon.Parent = header
	end

	-- Sidebar background
	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 180, 1, -40)
	sidebar.Position = UDim2.new(0, 0, 0, 40)
	sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	sidebar.BackgroundTransparency = 0.1
	sidebar.BorderSizePixel = 0
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)
	sidebar.Parent = main
	self.Sidebar = sidebar

	-- Tab button list
	local tabList = Instance.new("UIListLayout")
	tabList.Padding = UDim.new(0, 4)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Parent = sidebar

	-- Content area
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -180, 1, -40)
	contentFrame.Position = UDim2.new(0, 180, 0, 40)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.Name = "Content"
	contentFrame.Parent = main

	-- Make window draggable via header
	local dragStart, startPos
	self:AddConnection(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
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
		if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or
			input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Resize handle (bottom-right)
	local resizeHandle = Instance.new("TextButton")
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	resizeHandle.BackgroundTransparency = 0.5
	resizeHandle.Text = "⤢"
	resizeHandle.TextSize = 14
	resizeHandle.TextColor3 = Color3.fromRGB(255,255,255)
	resizeHandle.BorderSizePixel = 0
	Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)
	resizeHandle.Parent = main

	local resizeStart, startSize
	self:AddConnection(resizeHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
			resizeStart = input.Position
			startSize = main.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizeStart = nil
				end
			end)
		end
	end)
	self:AddConnection(resizeHandle.InputChanged, function(input)
		if resizeStart and (input.UserInputType == Enum.UserInputType.MouseMovement or
			input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			local newWidth = math.max(400, startSize.X.Offset + delta.X)
			local newHeight = math.max(300, startSize.Y.Offset + delta.Y)
			main.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)

	return self
end

-- Window:AddTab(name, icon)
function Window:AddTab(name, icon)
	local tabFrame = Instance.new("ScrollingFrame")
	tabFrame.Size = UDim2.new(1, 0, 1, 0)
	tabFrame.BackgroundTransparency = 1
	tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabFrame.ScrollBarThickness = 4
	tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabFrame.Visible = false
	tabFrame.Parent = self.MainFrame:FindFirstChild("Content")

	local sectionList = Instance.new("UIListLayout")
	sectionList.Padding = UDim.new(0, 10)
	sectionList.SortOrder = Enum.SortOrder.LayoutOrder
	sectionList.Parent = tabFrame

	local tab = setmetatable({
		Window = self,
		Frame = tabFrame,
		Sections = {},
		Name = name,
	}, {__index = BaseComponent})
	self.Tabs[name] = tab

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, 0, 0, 36)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Font = Enum.Font.Gotham
	tabBtn.TextSize = 14
	tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	tabBtn.Text = "  " .. (icon or "") .. "  " .. name
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.Parent = self.Sidebar
	tabBtn.Name = name .. "_TabBtn"

	self:AddConnection(tabBtn.MouseButton1Click, function()
		self:SwitchTab(name)
	end)

	if not self.CurrentTab then
		self:SwitchTab(name)
	end

	return tab
end

-- Window:SwitchTab(name)
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

-- Window:Notify(...)
function Window:Notify(data)
	local title = data.Title or ""
	local content = data.Content or ""
	local duration = data.Duration or 5

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 280, 0, 80)
	notif.Position = UDim2.new(1, -300, 1, -100)
	notif.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	notif.BackgroundTransparency = 0.1
	notif.BorderSizePixel = 0
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", notif).Color = Color3.fromRGB(50,50,50)
	notif.Parent = self.MainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = notif

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Text = content
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 12
	contentLabel.TextColor3 = Color3.fromRGB(200,200,200)
	contentLabel.Size = UDim2.new(1, -20, 1, -36)
	contentLabel.Position = UDim2.new(0, 10, 0, 28)
	contentLabel.BackgroundTransparency = 1
	contentLabel.TextWrapped = true
	contentLabel.Parent = notif

	task.delay(duration, function()
		notif:Destroy()
	end)
end

-- Window:ProgressBar(data)
function Window:ProgressBar(data)
	local text = data.Text or ""
	local percentage = data.Percentage or 0
	local barFrame = Instance.new("Frame")
	barFrame.Size = UDim2.new(0, 300, 0, 30)
	barFrame.Position = UDim2.new(0.5, -150, 0.5, -15)
	barFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
	barFrame.BackgroundTransparency = 0.2
	barFrame.BorderSizePixel = 0
	Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 6)
	barFrame.Parent = self.MainFrame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = self.AccentColor
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)
	fill.Parent = barFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Text = text .. " - " .. math.clamp(percentage, 0, 100) .. "%"
	label.Parent = barFrame

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(fill, tweenInfo, {Size = UDim2.new(percentage/100, 0, 1, 0)})
	tween:Play()
	task.delay(3, function() barFrame:Destroy() end)
end

-- Tab:AddSection(title)
function Window.Tab:AddSection(title)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, -20, 0, 0) -- Automatic size from content
	sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	sectionFrame.BackgroundTransparency = 0.2
	sectionFrame.BorderSizePixel = 0
	Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
	sectionFrame.Parent = self.Frame

	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Size = UDim2.new(1, 0, 0, 24)
	sectionTitle.Position = UDim2.new(0, 10, 0, 4)
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextSize = 12
	sectionTitle.TextColor3 = Color3.fromRGB(180,180,180)
	sectionTitle.Text = title
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = sectionFrame

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

	local section = setmetatable({
		Parent = self,
		Frame = sectionFrame,
		Holder = elementHolder,
	}, {__index = BaseComponent})
	table.insert(self.Sections, section)
	-- Adjust section height automatically
	elementHolder.Changed:Connect(function()
		sectionFrame.Size = UDim2.new(1, -20, 0, elementHolder.AbsoluteSize.Y + 34)
	end)
	return section
end

-- Generic element builder
local function createElement(parentHolder, sizeY, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, sizeY)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = parentHolder
	return frame
end

-- Local helper for minimum touch size
local MIN_TOUCH = 32

-- Button implementation
function Window.Section:AddButton(data)
	local frame = createElement(self.Holder, MIN_TOUCH, data.Callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.BackgroundTransparency = 0.4
	btn.BorderSizePixel = 0
	btn.Text = data.Text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(70,70,70)
	btn.Parent = frame

	local originalBg = btn.BackgroundColor3
	local originalTrans = btn.BackgroundTransparency
	self:AddConnection(btn.MouseEnter, function()
		TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = self.Parent.Window.AccentColor, BackgroundTransparency = 0.2}):Play()
	end)
	self:AddConnection(btn.MouseLeave, function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalBg, BackgroundTransparency = originalTrans}):Play()
	end)
	if data.Callback then
		self:AddConnection(btn.MouseButton1Click, data.Callback)
	end
	return { Destroy = function() frame:Destroy() end }
end

-- Toggle
function Window.Section:AddToggle(data)
	local frame = createElement(self.Holder, MIN_TOUCH, data.Callback)
	local state = data.Default or false

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 44, 0, 22)
	bar.Position = UDim2.new(1, -54, 0.5, -11)
	bar.BackgroundColor3 = state and self.Parent.Window.AccentColor or Color3.fromRGB(60,60,60)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	bar.Parent = frame

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(0, state and 24 or 4, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	knob.Parent = bar

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = data.Text
	label.Parent = frame

	local function updateToggle(on)
		TweenService:Create(bar, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{BackgroundColor3 = on and self.Parent.Window.AccentColor or Color3.fromRGB(60,60,60)}):Play()
		TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, on and 24 or 4, 0.5, -8)}):Play()
	end

	self:AddConnection(btn.MouseButton1Click, function()
		state = not state
		updateToggle(state)
		if data.Callback then data.Callback(state) end
	end)

	return { Destroy = function() frame:Destroy() end, SetState = function(s) state = s; updateToggle(s) end }
end

-- Slider
function Window.Section:AddSlider(data)
	local frame = createElement(self.Holder, 36)
	local min = data.Min or 0
	local max = data.Max or 100
	local current = data.Default or 0
	local precise = data.Precise or false

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 0, 16)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(200,200,200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = data.Text
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 16)
	valueLabel.Position = UDim2.new(1, -60, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 12
	valueLabel.TextColor3 = Color3.fromRGB(200,200,200)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Text = precise and string.format("%.1f", current) or tostring(math.floor(current))
	valueLabel.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -20, 0, 8)
	barBg.Position = UDim2.new(0, 10, 0, 20)
	barBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
	barBg.BorderSizePixel = 0
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
	barBg.Parent = frame

	local barFill = Instance.new("Frame")
	local perc = math.clamp((current - min) / (max - min), 0, 1)
	barFill.Size = UDim2.new(perc, 0, 1, 0)
	barFill.BackgroundColor3 = self.Parent.Window.AccentColor
	barFill.BorderSizePixel = 0
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
	barFill.Parent = barBg

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(perc, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BackgroundTransparency = 0
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

	self:AddConnection(knob.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	self:AddConnection(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)
	self:AddConnection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return { Destroy = function() frame:Destroy() end }
end

-- Input field
function Window.Section:AddInput(data)
	local frame = createElement(self.Holder, 36)
	local placeholder = data.Placeholder or ""
	local callback = data.Callback

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 1, 0)
	box.Position = UDim2.new(0, 10, 0, 0)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.BackgroundTransparency = 0.2
	box.BorderSizePixel = 0
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.PlaceholderText = placeholder
	box.Text = ""
	box.ClearTextOnFocus = false
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", box)
	stroke.Color = Color3.fromRGB(70,70,70)
	stroke.Thickness = 1

	self:AddConnection(box.Focused, function()
		TweenService:Create(stroke, TweenInfo.new(0.3), {Color = self.Parent.Window.AccentColor}):Play()
	end)
	self:AddConnection(box.FocusLost, function()
		TweenService:Create(stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(70,70,70)}):Play()
		if callback then callback(box.Text) end
	end)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Position = UDim2.new(0, 10, 0, -18)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(200,200,200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = data.Text or ""
	label.Parent = frame

	return { Destroy = function() frame:Destroy() end }
end

-- Dropdown
function Window.Section:AddDropdown(data)
	local frame = createElement(self.Holder, 36)
	local options = data.Options or {}
	local default = data.Default or options[1]
	local searchable = data.Searchable or false
	local selected = default

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 1, 0)
	btn.Position = UDim2.new(0, 10, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = selected or "Select..."
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = frame

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1, -20, 0, 0)
	listFrame.Position = UDim2.new(0, 10, 1, 4)
	listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
		searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
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
			optBtn.TextColor3 = Color3.fromRGB(255,255,255)
			optBtn.TextXAlignment = Enum.TextXAlignment.Left
			optBtn.Text = opt
			optBtn.Parent = listFrame
			self:AddConnection(optBtn.MouseButton1Click, function()
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
		self:AddConnection(searchBox:GetPropertyChangedSignal("Text"), function()
			updateList(searchBox.Text)
		end)
	end

	self:AddConnection(btn.MouseButton1Click, function()
		listFrame.Visible = not listFrame.Visible
		if listFrame.Visible then
			updateList(searchable and searchBox.Text or nil)
		end
	end)

	updateList(nil) -- initial build
	return { Destroy = function() frame:Destroy() end }
end

-- Keybind
function Window.Section:AddKeybind(data)
	local frame = createElement(self.Holder, MIN_TOUCH)
	local default = data.Default or Enum.KeyCode.Unknown
	local currentKey = default.Name ~= "Unknown" and default.Name or "None"
	local listening = false

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = data.Text .. ": [" .. currentKey .. "]"
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(70,70,70)
	btn.Parent = frame

	self:AddConnection(btn.MouseButton1Click, function()
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
	end)

	return { Destroy = function() frame:Destroy() end }
end

-- ColorPicker (simplified: opens a popup)
function Window.Section:AddColorPicker(data)
	local frame = createElement(self.Holder, MIN_TOUCH)
	local defaultColor = data.Default or Color3.fromRGB(255,255,255)
	local currentColor = defaultColor

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = currentColor
	btn.BorderSizePixel = 0
	btn.Text = data.Text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	btn.BackgroundTransparency = 0.1
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = frame

	-- Color picker frame (popup)
	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 200, 0, 200)
	pickerFrame.Position = UDim2.new(0, 10, 1, 4)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	pickerFrame.BackgroundTransparency = 0.1
	pickerFrame.BorderSizePixel = 0
	pickerFrame.Visible = false
	pickerFrame.ZIndex = 10
	Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 6)
	pickerFrame.Parent = frame

	-- For simplicity, use native color picker via a TextButton (Roblox color picker is not scriptable easily)
	-- We'll add buttons to set specific colors.
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
		self:AddConnection(colorBtn.MouseButton1Click, function()
			currentColor = col
			btn.BackgroundColor3 = col
			if data.Callback then data.Callback(col) end
			pickerFrame.Visible = false
		end)
		colorBtn.Parent = pickerFrame
	end

	self:AddConnection(btn.MouseButton1Click, function()
		pickerFrame.Visible = not pickerFrame.Visible
	end)

	return { Destroy = function() frame:Destroy() end }
end

-- Label
function Window.Section:AddLabel(text)
	local frame = createElement(self.Holder, 20)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(200,200,200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = frame
	return { Destroy = function() frame:Destroy() end }
end

-- Paragraph
function Window.Section:AddParagraph(text)
	local frame = createElement(self.Holder, 40)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(200,200,200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Parent = frame
	return { Destroy = function() frame:Destroy() end }
end

-- Clipboard button
function Window.Section:AddClipboardButton(text, content)
	local frame = createElement(self.Holder, MIN_TOUCH)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.BackgroundTransparency = 0.4
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(70,70,70)
	btn.Parent = frame
	self:AddConnection(btn.MouseButton1Click, function()
		if setclipboard then
			setclipboard(content)
		end
		-- Optional: show temporary success hint
		btn.Text = "Copied!"
		task.delay(1, function() btn.Text = text end)
	end)
	return { Destroy = function() frame:Destroy() end }
end

-- GridList
function Window.Section:AddGridList(data)
	local items = data.Items or {}
	local itemSize = data.ItemSize or 60
	local frame = createElement(self.Holder, 100) -- height auto adjusted
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, itemSize, 0, itemSize)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
	grid.VerticalAlignment = Enum.VerticalAlignment.Top
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = frame

	for _, item in ipairs(items) do
		local itemFrame = Instance.new("ImageButton")
		itemFrame.Size = UDim2.new(0, itemSize, 0, itemSize)
		itemFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
		itemFrame.BorderSizePixel = 0
		Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
		itemFrame.Image = item.Image or ""
		itemFrame.ImageTransparency = 0.5
		itemFrame.Parent = frame
		if item.Callback then
			self:AddConnection(itemFrame.MouseButton1Click, item.Callback)
		end
	end

	frame.Size = UDim2.new(1, 0, 0, math.ceil(#items / math.max(1, math.floor(frame.AbsoluteSize.X / (itemSize+grid.Padding.Offset)))) * (itemSize+grid.Padding.Offset) + 10)
	return { Destroy = function() frame:Destroy() end }
end

-- Library entry point
function KreinGui.new(options)
	return Window.new(options)
end

return KreinGui
