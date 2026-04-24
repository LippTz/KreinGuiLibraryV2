--[[
	KreinGui Library v1.0
	Modern, Scalable, Expert GUI Framework untuk Roblox
	Terinspirasi Windows 11: Acrylic transparency, rounded corners, drop shadows
	Full OOP, cross‑platform (PC/Mobile), mendukung theming dinamis
--]]

local KreinGui = {}
KreinGui.__index = KreinGui

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ================================
-- PROMPT 1: ARSITEKTUR INTI & THEMING
-- ================================

-- Palet warna Windows 11
local Themes = {
	Dark = {
		Background = Color3.fromRGB(32, 32, 32),
		Surface = Color3.fromRGB(45, 45, 45),
		SurfaceAlt = Color3.fromRGB(55, 55, 55),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(160, 160, 160),
		Accent = Color3.fromRGB(0, 120, 212),
		AccentHover = Color3.fromRGB(11, 135, 233),
		Stroke = Color3.fromRGB(90, 90, 90),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(100, 100, 100),
		ScrollBarBg = Color3.fromRGB(60, 60, 60),
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 240),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceAlt = Color3.fromRGB(245, 245, 245),
		Text = Color3.fromRGB(20, 20, 20),
		SubText = Color3.fromRGB(100, 100, 100),
		Accent = Color3.fromRGB(0, 103, 192),
		AccentHover = Color3.fromRGB(0, 124, 224),
		Stroke = Color3.fromRGB(210, 210, 210),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(200, 200, 200),
		ScrollBarBg = Color3.fromRGB(230, 230, 230),
	},
}

function KreinGui.new(themeMode)
	local self = setmetatable({}, KreinGui)
	self.Theme = Themes[themeMode or "Dark"]
	self.ActiveWindows = {}
	self.Platform = UserInputService.TouchEnabled and UserInputService.MouseEnabled == false and "Mobile" or "PC"

	-- Sistem responsif: skala ukuran berdasarkan platform
	if self.Platform == "Mobile" then
		self.ScaleFactor = 1.4	-- perbesar sentuhan
	else
		self.ScaleFactor = 1.0
	end

	return self
end

function KreinGui:SetTheme(mode)
	self.Theme = Themes[mode]
	-- Akan dipanggil ulang oleh komponen untuk update warna
	for _, win in pairs(self.ActiveWindows) do
		win:UpdateTheme(self.Theme)
	end
end

-- ================================
-- PROMPT 2: KOMPONEN DASAR (Window, Frame, Label, Button)
-- ================================

-- Helper untuk efek Acrylic (transparansi buram)
local function applyAcrylic(frame, theme)
	frame.BackgroundColor3 = theme.Surface
	frame.BackgroundTransparency = 0.3
	local glass = Instance.new("Frame")
	glass.Name = "AcrylicOverlay"
	glass.BackgroundColor3 = theme.Background
	glass.BackgroundTransparency = 0.85
	glass.BorderSizePixel = 0
	glass.Size = UDim2.new(1,0,1,0)
	glass.Parent = frame
end

-- Helper sudut membulat + bayangan
local function applyModernStyle(gui, theme, cornerRadius, hasShadow)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius or 8)
	corner.Parent = gui

	if hasShadow then
		local stroke = Instance.new("UIStroke")
		stroke.Color = theme.Shadow
		stroke.Transparency = 0.7
		stroke.Thickness = 1.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = gui
	end
end

-- Animasi tween
local function tweenProperty(object, property, target, duration, easingStyle, easingDir)
	local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDir or Enum.EasingDirection.Out)
	local tween = TweenService:Create(object, tweenInfo, {[property] = target})
	tween:Play()
	return tween
end

function KreinGui:CreateWindow(title, width, height)
	local win = {}
	win.Gui = Instance.new("ScreenGui")
	win.Gui.Name = title
	win.Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, width or 400, 0, height or 300)
	mainFrame.Position = UDim2.new(0.5, -(width or 400)/2, 0.5, -(height or 300)/2)
	mainFrame.Parent = win.Gui
	win.MainFrame = mainFrame

	applyAcrylic(mainFrame, self.Theme)
	applyModernStyle(mainFrame, self.Theme, 10, true)

	-- Title bar (draggable nanti di Prompt 5)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1,0,0,30)
	titleBar.BackgroundTransparency = 1
	titleBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5,0,1,0)
	titleLabel.Position = UDim2.new(0,10,0,0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = self.Theme.Text
	titleLabel.TextSize = 14 * self.ScaleFactor
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Tombol window controls
	local closeBtn = self:CreateButton("X", 24, 24)
	closeBtn.Position = UDim2.new(1,-30,0,3)
	closeBtn.Parent = titleBar

	closeBtn.MouseButton1Click:Connect(function()
		win.Gui:Destroy()
		self.ActiveWindows[win] = nil
	end)

	win.TitleBar = titleBar
	win.CloseButton = closeBtn

	table.insert(self.ActiveWindows, win)
	return win
end

function KreinGui:CreateButton(text, width, height)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, width or 120, 0, height or 30)
	button.BackgroundColor3 = self.Theme.Accent
	button.Text = text
	button.TextColor3 = self.Theme.Text
	button.TextSize = 14 * self.ScaleFactor
	button.Font = Enum.Font.Gotham
	button.AutoButtonColor = false
	applyModernStyle(button, self.Theme, 4, false)

	-- Status hover/pressed dengan animasi
	button.MouseEnter:Connect(function()
		tweenProperty(button, "BackgroundColor3", self.Theme.AccentHover, 0.15)
	end)
	button.MouseLeave:Connect(function()
		tweenProperty(button, "BackgroundColor3", self.Theme.Accent, 0.15)
	end)
	button.MouseButton1Down:Connect(function()
		tweenProperty(button, "BackgroundColor3", self.Theme.AccentHover:Lerp(Color3.new(0,0,0),0.1), 0.05)
	end)
	button.MouseButton1Up:Connect(function()
		tweenProperty(button, "BackgroundColor3", self.Theme.AccentHover, 0.15)
	end)

	return button
end

function KreinGui:CreateLabel(text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Theme.Text
	label.TextSize = 14 * self.ScaleFactor
	label.Font = Enum.Font.Gotham
	label.TextWrapped = true
	return label
end

-- Frame polos
function KreinGui:CreateFrame(width, height)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, width, 0, height)
	frame.BackgroundColor3 = self.Theme.SurfaceAlt
	applyModernStyle(frame, self.Theme, 6, true)
	return frame
end

-- ================================
-- PROMPT 3: KOMPONEN LANJUT INTERAKTIF
-- ================================

function KreinGui:CreateSlider(minVal, maxVal, defaultVal, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 200, 0, 30)
	container.BackgroundTransparency = 1

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -50, 0, 10)
	frame.Position = UDim2.new(0, 0, 0.5, -5)
	frame.BackgroundColor3 = self.Theme.ScrollBarBg
	applyModernStyle(frame, self.Theme, 5, false)
	frame.Parent = container

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0.75,0,1,0) -- nanti di-update
	fill.BackgroundColor3 = self.Theme.Accent
	applyModernStyle(fill, self.Theme, 5, false)
	fill.Parent = frame

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 20, 0, 20)
	knob.Position = UDim2.new(0.75, -10, 0.5,-10)
	knob.BackgroundColor3 = self.Theme.Text
	knob.Text = ""
	applyModernStyle(knob, self.Theme, 10, false)
	knob.Parent = container

	local percentLabel = Instance.new("TextLabel")
	percentLabel.Size = UDim2.new(0, 40, 1, 0)
	percentLabel.Position = UDim2.new(1, -45, 0, 0)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Text = tostring(defaultVal).."%"
	percentLabel.TextColor3 = self.Theme.Text
	percentLabel.TextSize = 14 * self.ScaleFactor
	percentLabel.Font = Enum.Font.Gotham
	percentLabel.Parent = container

	local function updateValue(frac)
		local val = math.floor(minVal + (maxVal-minVal)*frac)
		fill.Size = UDim2.new(frac, 0, 1, 0)
		knob.Position = UDim2.new(frac, -10, 0.5, -10)
		percentLabel.Text = val.."%"
		if callback then callback(val) end
	end

	local val = (defaultVal or 50 - minVal)/(maxVal-minVal)
	updateValue(val)

	local dragging = false
	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation()
			local xRel = mousePos.X - frame.AbsolutePosition.X
			local frac = math.clamp(xRel / frame.AbsoluteSize.X, 0, 1)
			updateValue(frac)
		end
	end)
	-- Mobile: sentuh langsung di frame
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	return container
end

function KreinGui:CreateToggleSwitch(default, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 44, 0, 22)
	container.BackgroundColor3 = default and self.Theme.Accent or self.Theme.ScrollBarBg
	applyModernStyle(container, self.Theme, 11, false)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
	knob.BackgroundColor3 = self.Theme.Text
	applyModernStyle(knob, self.Theme, 8, false)
	knob.Parent = container

	local state = default
	local function toggle()
		state = not state
		local targetColor = state and self.Theme.Accent or self.Theme.ScrollBarBg
		local targetPos = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
		tweenProperty(container, "BackgroundColor3", targetColor, 0.2)
		tweenProperty(knob, "Position", targetPos, 0.2)
		if callback then callback(state) end
	end

	container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggle()
		end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggle()
		end
	end)

	return container
end

function KreinGui:CreateDropdown(options, callback)
	local width = 160
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, width, 0, 30)
	container.BackgroundTransparency = 1

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1,0,1,0)
	header.BackgroundColor3 = self.Theme.SurfaceAlt
	header.Text = "  "..(options[1] or "")
	header.TextColor3 = self.Theme.Text
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Font = Enum.Font.Gotham
	header.TextSize = 14 * self.ScaleFactor
	applyModernStyle(header, self.Theme, 4, false)
	header.Parent = container

	local list = Instance.new("Frame")
	list.Size = UDim2.new(1,0,0, #options*25)
	list.Position = UDim2.new(0,0,1,2)
	list.BackgroundColor3 = self.Theme.Surface
	list.Visible = false
	list.BorderSizePixel = 0
	applyModernStyle(list, self.Theme, 4, true)
	applyAcrylic(list, self.Theme)
	list.Parent = container

	for i, opt in ipairs(options) do
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1,0,0,25)
		item.Position = UDim2.new(0,0,0, (i-1)*25)
		item.BackgroundTransparency = 1
		item.Text = opt
		item.TextColor3 = self.Theme.Text
		item.Font = Enum.Font.Gotham
		item.TextSize = 13 * self.ScaleFactor
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Parent = list
		item.MouseButton1Click:Connect(function()
			header.Text = "  "..opt
			list.Visible = false
			if callback then callback(opt) end
		end)
	end

	header.MouseButton1Click:Connect(function()
		list.Visible = not list.Visible
	end)

	return container
end

function KreinGui:CreateTextField(placeholder)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 30)
	frame.BackgroundColor3 = self.Theme.Surface
	applyModernStyle(frame, self.Theme, 4, false)

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -10, 1, 0)
	textBox.Position = UDim2.new(0, 5, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.PlaceholderText = placeholder or ""
	textBox.PlaceholderColor3 = self.Theme.SubText
	textBox.Text = ""
	textBox.TextColor3 = self.Theme.Text
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 14 * self.ScaleFactor
	textBox.Parent = frame

	-- outline fokus
	local outline = Instance.new("UIStroke")
	outline.Color = self.Theme.Accent
	outline.Thickness = 1.5
	outline.Transparency = 1
	outline.Parent = frame

	textBox.Focused:Connect(function()
		outline.Transparency = 0
	end)
	textBox.FocusLost:Connect(function()
		outline.Transparency = 1
	end)

	return frame
end

function KreinGui:CreateCheckBox(text, default, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 150, 0, 20)
	container.BackgroundTransparency = 1

	local box = Instance.new("TextButton")
	box.Size = UDim2.new(0, 18, 0, 18)
	box.Text = ""
	box.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Surface
	applyModernStyle(box, self.Theme, 3, false)
	box.Parent = container

	local label = self:CreateLabel("  "..text)
	label.Position = UDim2.new(0, 22, 0, 0)
	label.Size = UDim2.new(1, -22, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local state = default
	local function toggle()
		state = not state
		box.BackgroundColor3 = state and self.Theme.Accent or self.Theme.Surface
		if callback then callback(state) end
	end

	box.MouseButton1Click:Connect(toggle)
	return container
end

function KreinGui:CreateColorPicker(callback)
	local picker = Instance.new("Frame")
	picker.Size = UDim2.new(0, 180, 0, 150)
	picker.BackgroundColor3 = self.Theme.Surface
	applyModernStyle(picker, self.Theme, 6, true)

	local hueFrame = Instance.new("Frame")
	hueFrame.Size = UDim2.new(1, -10, 0, 20)
	hueFrame.Position = UDim2.new(0, 5, 1, -30)
	hueFrame.BackgroundColor3 = Color3.new(1,1,1)
	hueFrame.Parent = picker

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
	}
	hueGradient.Parent = hueFrame

	local sample = Instance.new("Frame")
	sample.Size = UDim2.new(1, -10, 0, 50)
	sample.Position = UDim2.new(0,5,0,10)
	sample.BackgroundColor3 = Color3.new(1,0,0)
	applyModernStyle(sample, self.Theme, 4, false)
	sample.Parent = picker

	-- Simulasi sederhana: click pada hue slider set warna
	hueFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mouseX = UserInputService:GetMouseLocation().X - hueFrame.AbsolutePosition.X
			local frac = math.clamp(mouseX / hueFrame.AbsoluteSize.X, 0, 1)
			local c = hueGradient.Color:GetColorSequenceAtValue(frac)
			sample.BackgroundColor3 = c
			if callback then callback(c) end
		end
	end)

	return picker
end

-- ================================
-- PROMPT 4: KOMPONEN UTILITAS
-- ================================

function KreinGui:CreateScrollingFrame(width, height)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(0, width, 0, height)
	sf.BackgroundColor3 = self.Theme.SurfaceAlt
	sf.CanvasSize = UDim2.new(0,0,0,0)
	sf.ScrollBarThickness = 6
	sf.ScrollBarImageColor3 = self.Theme.ScrollBar
	sf.ScrollingDirection = Enum.ScrollingDirection.Y
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	applyModernStyle(sf, self.Theme, 6, true)

	-- bilah gulir kustom tipis
	local scrollbar = Instance.new("Frame")
	scrollbar.Size = UDim2.new(0, 6, 1, 0)
	scrollbar.Position = UDim2.new(1, -6, 0, 0)
	scrollbar.BackgroundColor3 = self.Theme.ScrollBarBg
	scrollbar.BorderSizePixel = 0
	scrollbar.Parent = sf

	return sf
end

function KreinGui:CreateProgressBar(width, percent)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, width, 0, 12)
	container.BackgroundColor3 = self.Theme.ScrollBarBg
	applyModernStyle(container, self.Theme, 6, false)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(percent/100, 0, 1, 0)
	fill.BackgroundColor3 = self.Theme.Accent
	applyModernStyle(fill, self.Theme, 6, false)
	fill.Parent = container

	local label = self:CreateLabel(percent.."%")
	label.Position = UDim2.new(0, 5, 0, 0)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	return container
end

function KreinGui:CreateTabControl(tabs, width, height)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, width, 0, height)
	container.BackgroundTransparency = 1

	local buttons = {}
	local pages = {}

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, 0, 0, 28)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = container

	for i, tabName in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1/#tabs, -4, 1, 0)
		btn.Position = UDim2.new((i-1)/#tabs, 2, 0, 0)
		btn.BackgroundColor3 = i==1 and self.Theme.Accent or self.Theme.SurfaceAlt
		btn.Text = tabName
		btn.TextColor3 = self.Theme.Text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13 * self.ScaleFactor
		applyModernStyle(btn, self.Theme, 4, false)
		btn.Parent = buttonContainer

		local page = Instance.new("Frame")
		page.Size = UDim2.new(1, 0, 1, -32)
		page.Position = UDim2.new(0, 0, 0, 32)
		page.BackgroundColor3 = self.Theme.Surface
		page.Visible = (i == 1)
		applyModernStyle(page, self.Theme, 4, true)
		page.Parent = container

		btn.MouseButton1Click:Connect(function()
			for j, b in ipairs(buttons) do
				b.BackgroundColor3 = self.Theme.SurfaceAlt
				pages[j].Visible = false
			end
			btn.BackgroundColor3 = self.Theme.Accent
			page.Visible = true
		end)

		table.insert(buttons, btn)
		table.insert(pages, page)
	end

	container.Pages = pages
	return container
end

function KreinGui:CreateGridList(itemSize, spacing, itemsPerRow)
	local grid = Instance.new("Frame")
	grid.Size = UDim2.new(0, itemSize*itemsPerRow + spacing*(itemsPerRow+1), 0, 200)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0

	-- Fungsi untuk menambahkan item
	function grid:AddItem(content)
		local item = Instance.new("Frame")
		item.Size = UDim2.new(0, itemSize, 0, itemSize)
		local idx = #grid:GetChildren()
		local col = (idx-1) % itemsPerRow
		local row = math.floor((idx-1) / itemsPerRow)
		item.Position = UDim2.new(0, spacing + col*(itemSize+spacing), 0, spacing + row*(itemSize+spacing))
		item.BackgroundColor3 = self.Theme.SurfaceAlt
		applyModernStyle(item, self.Theme, 4, true)
		item.Parent = grid

		if typeof(content) == "Instance" then
			content.Parent = item
		end
		return item
	end

	return grid
end

-- ================================
-- PROMPT 5: FITUR EXPERT (Drag, Resize, Integrasi)
-- ================================

function KreinGui:EnableWindowDrag(windowObj)
	local titleBar = windowObj.TitleBar
	local frame = windowObj.MainFrame
	local dragging, dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Tombol resize (sudut kanan bawah)
function KreinGui:EnableWindowResize(windowObj, minWidth, minHeight)
	local frame = windowObj.MainFrame
	local grip = Instance.new("TextButton")
	grip.Size = UDim2.new(0, 16, 0, 16)
	grip.Position = UDim2.new(1, -16, 1, -16)
	grip.BackgroundTransparency = 1
	grip.Text = "◢"
	grip.TextSize = 14
	grip.TextColor3 = self.Theme.SubText
	grip.Parent = frame

	local resizing, startPos, startSize

	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startPos = input.Position
			startSize = frame.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	grip.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			local newWidth = math.max(minWidth or 300, startSize.X + delta.X)
			local newHeight = math.max(minHeight or 200, startSize.Y + delta.Y)
			frame.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)
end

-- ================================
-- CONTOH INTEGRASI LENGKAP (Dashboard seperti gambar)
-- ================================

function KreinGui:CreateDashboardExample()
	local gui = KreinGui.new("Dark")
	local win = gui:CreateWindow("KreinGui Library v1.0", 750, 520)
	local main = win.MainFrame

	-- Title bawah titlebar
	local titleLabel = gui:CreateLabel("Dashboard")
	titleLabel.Position = UDim2.new(0.02, 0, 0, 35)
	titleLabel.TextSize = 20 * gui.ScaleFactor
	titleLabel.Parent = main

	local subtitle = gui:CreateLabel("Welcome to KreinGui - Modern, Scalable, Expert")
	subtitle.Position = UDim2.new(0.02, 0, 0, 60)
	subtitle.TextColor3 = gui.Theme.SubText
	subtitle.Parent = main

	-- Panel kiri: UI Elements
	local leftPanel = gui:CreateFrame(150, 400)
	leftPanel.Position = UDim2.new(0.02, 0, 0, 95)
	leftPanel.Parent = main

	local leftList = gui:CreateScrollingFrame(130, 370)
	leftList.Position = UDim2.new(0, 10, 0, 10)
	leftList.Parent = leftPanel

	local elements = {"Core Components", "Scrolling Frame", "Primary Button", "Checker", "Input Field", "User Profile",
					"Settings", "Secondary Button", "Radio", "Header Text", "Username...",
					"Inventory", "Button", "Contact", "BodyText", "Achievements"}
	for _, elem in pairs(elements) do
		local lbl = gui:CreateLabel(elem)
		lbl.Size = UDim2.new(1, 0, 0, 20)
		lbl.TextSize = 12 * gui.ScaleFactor
		lbl.Parent = leftList
	end

	-- Area kanan: Advanced Elements
	local rightPanel = gui:CreateFrame(540, 400)
	rightPanel.Position = UDim2.new(0.25, 10, 0, 95)
	rightPanel.Parent = main

	-- GridList contoh
	local grid = gui:CreateGridList(100, 8, 4)
	grid.Position = UDim2.new(0, 10, 0, 10)
	grid.Parent = rightPanel

	-- Isi grid
	local slider = gui:CreateSlider(0, 100, 75)
	slider.Parent = grid:AddItem(nil)
	local toggle = gui:CreateToggleSwitch(true)
	toggle.Parent = grid:AddItem(nil)
	local dropdown = gui:CreateDropdown({"Option1","Option2","Option3"})
	dropdown.Parent = grid:AddItem(nil)
	local colorPicker = gui:CreateColorPicker()
	colorPicker.Parent = grid:AddItem(nil)
	local progress = gui:CreateProgressBar(100, 60)
	progress.Parent = grid:AddItem(nil)

	-- Enable drag & resize
	gui:EnableWindowDrag(win)
	gui:EnableWindowResize(win, 600, 400)

	-- Set ke ActiveWindows agar bisa dikelola
	gui.ActiveWindows[win] = win

	print("KreinGui Dashboard loaded!")
	return gui
end

return KreinGui
