local BooleanSlider = {}
BooleanSlider.__index = BooleanSlider

function BooleanSlider.new(parent : Instance, defaultValue : boolean, currentValue : boolean, trueValueName : string, falseValueName : string, onChangeFunction)
	local raw = {}
	
	raw.OnChangeFunction = onChangeFunction
	raw.CurrentValue = defaultValue
	if currentValue then
		raw.CurrentValue = currentValue
	end
	raw.TrueValueString = trueValueName
	raw.FalseValueString = falseValueName
	raw.Parent = parent
	raw.DefaultValue = defaultValue
	
	raw = setmetatable(raw, BooleanSlider)
	raw:Build()
	
	return raw
end

function BooleanSlider:Build()
	local RootFrame = Instance.new("Frame")
	RootFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	RootFrame.BackgroundTransparency = 1
	RootFrame.Size = UDim2.new(1,0,0,60)
	RootFrame.ZIndex = 2
	
	local ValueFrame = Instance.new("Frame")
	ValueFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	ValueFrame.Size = UDim2.new(1,0,1,0)
	ValueFrame.Style = Enum.FrameStyle.DropShadow
	ValueFrame.ZIndex = 2
	ValueFrame.Parent = RootFrame
	
	local SliderFrame = Instance.new("Frame")
	SliderFrame.BackgroundColor3 = Color3.fromHSV(0,0,1)
	SliderFrame.BackgroundTransparency = 1
	SliderFrame.Position = UDim2.new(0,0,0.01,0)
	SliderFrame.Size = UDim2.new(1,0,0.98,0)
	SliderFrame.ZIndex = 2
	SliderFrame.Parent = ValueFrame
	
	local OnLabel = Instance.new("TextLabel")
	OnLabel.BackgroundColor3 = Color3.fromHSV(0,0,1)
	OnLabel.BackgroundTransparency = 1
	OnLabel.Position = UDim2.new(0.75,0,0,0)
	OnLabel.Size = UDim2.new(0.25,0,1,0)
	OnLabel.Text = self.TrueValueString
	OnLabel.TextColor3 = Color3.fromHSV(0,0,1)
	OnLabel.TextScaled = true
	OnLabel.ZIndex = 2
	OnLabel.Parent = SliderFrame
	
	local OffLabel = Instance.new("TextLabel")
	OffLabel.BackgroundColor3 = Color3.fromHSV(0,0,1)
	OffLabel.BackgroundTransparency = 1
	OffLabel.Size = UDim2.new(0.25,0,1,0)
	OffLabel.Text = self.FalseValueString
	OffLabel.TextColor3 = Color3.fromHSV(0,0,1)
	OffLabel.TextScaled = true
	OffLabel.ZIndex = 2
	OffLabel.Parent = SliderFrame
	
	local SliderInternal = Instance.new("Frame")
	SliderInternal.BackgroundColor3 = Color3.fromHSV(0,0,1)
	SliderInternal.BackgroundTransparency = 0.9
	SliderInternal.BorderSizePixel = 0
	SliderInternal.Position = UDim2.new(0.25,0,0,0)
	SliderInternal.Size = UDim2.new(0.5,0,1,0)
	SliderInternal.ZIndex = 2
	SliderInternal.Parent = SliderFrame
	
	local SlideButton = Instance.new("TextButton")
	SlideButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	SlideButton.BorderSizePixel = 0
	SlideButton.Size = UDim2.new(0.5,0,1,0)
	SlideButton.ZIndex = 3
	SlideButton.Text = ""
	SlideButton.Parent = SliderInternal
	
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundColor3 = Color3.fromHSV(0,0,1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1,0,0.9,0)
	TextLabel.ZIndex = 3
	TextLabel.Text = " |  |  | "
	TextLabel.TextColor3 = Color3.fromRGB(214, 214, 214)
	TextLabel.TextScaled = true
	TextLabel.Parent = SlideButton
	
	local OnColor = Instance.new("Frame")
	OnColor.Name = "OnColor"
	OnColor.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	OnColor.BorderSizePixel = 0
	OnColor.Size = UDim2.new(0.5,0,1,0)
	OnColor.ZIndex = 2
	OnColor.Parent = SliderInternal
	
	local OffColor = Instance.new("Frame")
	OffColor.Name = "OffColor"
	OffColor.BackgroundColor3 = Color3.fromRGB(170,0,0)
	OffColor.BorderSizePixel = 0
	OffColor.Position = UDim2.new(0.5,0,0,0)
	OffColor.Size = UDim2.new(0.5,0,1,0)
	OffColor.ZIndex = 2
	OffColor.Parent = SliderInternal
	
	RootFrame.Parent = self.Parent
	
	local offPosition = UDim2.new(0,0,0,0)
	local onPosition = UDim2.new(0.5,0,0,0)
	local tweening = false
	
	local function update()
		self.OnChangeFunction(self.CurrentValue)
	end
	
	local function setValue()
		local endPos
		if self.CurrentValue then
			endPos = onPosition
		else
			endPos = offPosition
		end
		SlideButton:TweenPosition(endPos, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, false, function()
			tweening = false
		end)
	end
	
	self.ButtonListener = SlideButton.MouseButton1Click:Connect(function()
		if not tweening then
			tweening = true
			self.CurrentValue = not self.CurrentValue
			setValue()
			update()
		end
	end)
	
	setValue()
end

function BooleanSlider:Destroy()
	if self.ButtonListener then
		self.ButtonListener:Disconnect()
	end
	if self.RootFrame then
		self.RootFrame:Destroy()
	end
end

return BooleanSlider
