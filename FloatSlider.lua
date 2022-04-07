local UIS 		= game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local FloatSlider = {}
FloatSlider.__index = FloatSlider

function FloatSlider.new(parent : Instance, defaultValue, minValue, maxValue, currentValue, onChangeFunction)
	local raw = {}
	
	raw.OnChangeFunction = onChangeFunction
	raw.ScreenGui = parent:FindFirstAncestorOfClass("ScreenGui")
	raw.MinValue = minValue
	raw.MaxValue = maxValue
	raw.Parent = parent
	raw.DefaultValue = defaultValue
	raw.CurrentValue = defaultValue
	if currentValue then
		raw.CurrentValue = currentValue
	end
	
	raw = setmetatable(raw, FloatSlider)
	raw:Build()
	
	return setmetatable(raw, FloatSlider)
end

function FloatSlider:Build()
	local RootFrame = Instance.new("Frame")
	RootFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	RootFrame.BackgroundTransparency = 1
	RootFrame.Size = UDim2.new(1,0,0,60)
	RootFrame.ZIndex = 2
	self.RootFrame = RootFrame
	
	local DraggerFrame = Instance.new("Frame")
	DraggerFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	DraggerFrame.Size = UDim2.new(1,0,1,0)
	DraggerFrame.Style = Enum.FrameStyle.DropShadow
	DraggerFrame.ZIndex = 2
	DraggerFrame.Parent = RootFrame
	
	local ValueBox = Instance.new("TextBox")
	ValueBox.BackgroundColor3 = Color3.fromHSV(0,0,1)
	ValueBox.BackgroundTransparency = 0.8
	ValueBox.Position = UDim2.new(0.9,0,0.05,0)
	ValueBox.Size = UDim2.new(0.1,0,0.9,0)
	ValueBox.Font = Enum.Font.SourceSans
	ValueBox.Text = tostring(self.CurrentValue)
	ValueBox.TextColor3 = Color3.fromHSV(0,0,1)
	ValueBox.TextScaled = true
	ValueBox.TextSize = 14
	ValueBox.TextStrokeTransparency = 0
	ValueBox.TextWrapped = true
	ValueBox.ZIndex = 2
	ValueBox.Parent = DraggerFrame
	
	local MinValueBox = Instance.new("TextLabel")
	MinValueBox.BackgroundTransparency = 1
	MinValueBox.Position = UDim2.new(0,0,0.05,0)
	MinValueBox.Size = UDim2.new(0.1,0,0.9,0)
	MinValueBox.Text = tostring(self.MinValue)
	MinValueBox.TextColor3 = Color3.fromRGB(255,255,255)
	MinValueBox.TextScaled = true
	MinValueBox.TextXAlignment = Enum.TextXAlignment.Right
	MinValueBox.ZIndex = 2
	MinValueBox.Parent = DraggerFrame
	
	local MaxValueBox = Instance.new("TextLabel")
	MaxValueBox.BackgroundTransparency = 1
	MaxValueBox.Position = UDim2.new(0.8,0,0.05,0)
	MaxValueBox.Size = UDim2.new(0.1,0,0.9,0)
	MaxValueBox.Text = tostring(self.MaxValue)
	MaxValueBox.TextColor3 = Color3.fromRGB(255,255,255)
	MaxValueBox.TextScaled = true
	MaxValueBox.TextXAlignment = Enum.TextXAlignment.Left
	MaxValueBox.ZIndex = 2
	MaxValueBox.Parent = DraggerFrame
	
	local DraggerInternal = Instance.new("Frame")
	DraggerInternal.BackgroundColor3 = Color3.fromHSV(0,0,1)
	DraggerInternal.BackgroundTransparency = 1
	DraggerInternal.Position = UDim2.new(0.1,0,0.2,0)
	DraggerInternal.Size = UDim2.new(0.7,0,0.6,0)
	DraggerInternal.ZIndex = 2
	DraggerInternal.Parent = DraggerFrame
	
	local Max = Instance.new("Frame")
	Max.BackgroundColor3 = Color3.fromHSV(0,0,1)
	Max.BorderSizePixel = 0
	Max.Position = UDim2.new(0.98,-1,0,0)
	Max.Size = UDim2.new(0,2,1,0)
	Max.ZIndex = 2
	Max.Parent = DraggerInternal
	
	local LongFrame = Instance.new("Frame")
	LongFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	LongFrame.BorderSizePixel = 0
	LongFrame.Position = UDim2.new(0.02,0,0.5,-1)
	LongFrame.Size = UDim2.new(0.96,0,0,2)
	LongFrame.ZIndex = 2
	LongFrame.Parent = DraggerInternal
	
	local Min = Instance.new("Frame")
	Min.BackgroundColor3 = Color3.fromHSV(0,0,1)
	Min.BorderSizePixel = 0
	Min.Position = UDim2.new(0.02,-1,0,0)
	Min.Size = UDim2.new(0,2,1,0)
	Min.ZIndex = 2
	Min.Parent = DraggerInternal
	
	local Dragger = Instance.new("ImageButton")
	Dragger.BackgroundColor3 = Color3.fromHSV(0,0,1)
	Dragger.BackgroundTransparency = 1
	Dragger.Position = UDim2.new(0.49,0,0,0)
	Dragger.Size = UDim2.new(0.04,0,0.5,0)
	Dragger.Image = "rbxassetid://4081272446"
	Dragger.ScaleType = Enum.ScaleType.Fit
	Dragger.ZIndex = 2
	Dragger.Parent = DraggerInternal
	
	RootFrame.Parent = self.Parent
	
	local minX = Min.AbsolutePosition.X
	local maxX = Max.AbsolutePosition.X
	local draggerMid = Dragger.AbsoluteSize.X/2
	local differentiation = maxX - minX
	local dragging = false
	local checking = false
	
	local function update()
		self.OnChangeFunction(self.CurrentValue)
	end
	
	local function setDraggerPosition(xPos)
		if xPos <= minX then
			Dragger.Position = UDim2.new(0.02,-1 * draggerMid,0,0)
		elseif xPos >= maxX then
			Dragger.Position = UDim2.new(0.98,-1 * draggerMid,0,0)
		else
			Dragger.Position = UDim2.new(0.02,xPos - minX - draggerMid,0,0)
		end
	end
	
	local function setBox(value)
		ValueBox.Text = value
	end
	
	local function renderConnect()
		if dragging and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			if not checking then
				checking = true
				local mousePos = UIS:GetMouseLocation()
				
				local xPos = math.floor(mousePos.X)
				local difference
				if xPos < minX then
					difference = self.MinValue
					if xPos < 0 then
						dragging = false
					end
				elseif xPos > maxX then
					difference = self.MaxValue
					if xPos > self.ScreenGui.AbsoluteSize.X then
						dragging = false
					end
				else
					local dRaw = ((xPos - minX) / differentiation) * (self.MaxValue - self.MinValue)
					local strDif = tostring(dRaw)
					difference = string.sub(strDif, 1, 5)
				end
				setBox(tostring(difference))
				self.CurrentValue = tonumber(difference)
				setDraggerPosition(xPos)
				checking = false
			end
			checking = false
		elseif not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			if dragging then
				update()
			end
			dragging = false
		end
	end
	
	local function draggerMouseDown()
		if not dragging then
			dragging = true
		end
	end
	
	local function focusFunction()
		local text = ValueBox.Text
		local num
		local success, reason = pcall(function()
			num = tonumber(text)
		end)
		if not success or text == "" then
			setDraggerPosition(self.CurrentValue)
		else
			if num >= self.MaxValue then
				self.CurrentValue = self.MaxValue
			elseif num <= self.MinValue then
				self.CurrentValue = self.MinValue
			else
				self.CurrentValue = num
			end
			local xPos = minX + math.floor(differentiation * (self.CurrentValue/(self.MaxValue - self.MinValue)))
			setDraggerPosition(xPos)
			update()
		end
	end
	
	self.RunConnection = RunService.RenderStepped:Connect(renderConnect)
	self.DraggerConnection = Dragger.MouseButton1Down:Connect(draggerMouseDown)
	
	self.FocusConnection = ValueBox.FocusLost:Connect(focusFunction)
	
	setDraggerPosition(minX + math.floor(differentiation * (self.CurrentValue/(self.MaxValue - self.MinValue))))
end

function FloatSlider:Destroy()
	if self.RunConnection then
		self.RunConnection:Disconnect()
	end
	if self.DraggerConnection then
		self.DraggerConnection:Disconnect()
	end
	if self.FocusConnection then
		self.FocusConnection:Disconnect()
	end
	if self.RootFrame then
		self.RootFrame:Destroy()
	end
end

if not instantiated then
	instantiated = true
	return FloatSlider
end
