Library = {}
SaveTheme = {}

local themes = {
	index = {'Dark', 'Amethyst'},
	Amethyst = {
		['Shadow'] = Color3.fromRGB(24, 24, 31),
		['Background'] = Color3.fromRGB(29, 28, 38),
		['Page'] = Color3.fromRGB(24, 24, 31),
		['Main'] = Color3.fromRGB(91, 68, 209),
		['Text & Icon'] = Color3.fromRGB(255, 255, 255),
		['Function'] = {
			['Toggle'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['True'] = {
					['Toggle Background'] = Color3.fromRGB(44, 34, 103),
					['Toggle Value'] = Color3.fromRGB(91, 68, 209),
				},
				['False'] = {
					['Toggle Background'] = Color3.fromRGB(36, 35, 48),
					['Toggle Value'] = Color3.fromRGB(44, 42, 62),
				}
			},
			['Label'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
			},
			['Dropdown'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Value Background'] = Color3.fromRGB(24, 24, 31),
				['Value Stroke'] = Color3.fromRGB(255, 255, 255),
				['Dropdown Select'] = {
					['Background'] = Color3.fromRGB(24, 24, 31),
					['Search'] = Color3.fromRGB(35, 35, 42),
					['Item Background'] = Color3.fromRGB(45, 45, 52),
				}
			},
			['Slider'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Value Background'] = Color3.fromRGB(24, 24, 31),
				['Value Stroke'] = Color3.fromRGB(255, 255, 255),
				['Slider Bar'] = Color3.fromRGB(44, 34, 103),
				['Slider Bar Value'] = Color3.fromRGB(91, 68, 209),
				['Circle Value'] = Color3.fromRGB(255, 255, 255)
			},
			['Code'] = {
				['Background'] = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 28, 38)), ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 28, 38))},
				['Background Code'] = Color3.fromRGB(51, 62, 68),
				['Background Code Value'] = Color3.fromRGB(38, 50, 56),
				['ScrollingFrame Code'] = Color3.fromRGB(216, 150, 179)
			},
			['Button'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Click'] = Color3.fromRGB(255, 255, 255)
			},
			['Textbox'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Value Background'] = Color3.fromRGB(24, 24, 31),
				['Value Stroke'] = Color3.fromRGB(255, 255, 255),
			},
			['Keybind'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Value Background'] = Color3.fromRGB(24, 24, 31),
				['Value Stroke'] = Color3.fromRGB(255, 255, 255),
				['True'] = {
					['Toggle Background'] = Color3.fromRGB(44, 34, 103),
					['Toggle Value'] = Color3.fromRGB(91, 68, 209),
				},
				['False'] = {
					['Toggle Background'] = Color3.fromRGB(36, 35, 48),
					['Toggle Value'] = Color3.fromRGB(44, 42, 62),
				}
			},
			['Color Picker'] = {
				['Background'] = Color3.fromRGB(29, 28, 38),
				['Color Select'] = {
					['Background'] = Color3.fromRGB(24, 24, 31),
					['UIStroke'] = Color3.fromRGB(255, 255, 255),
				}
			}
		}
	},
	Dark = {
		['Shadow'] = Color3.fromRGB(15, 15, 15),
		['Background'] = Color3.fromRGB(20, 20, 20),
		['Page'] = Color3.fromRGB(18, 18, 18),
		['Main'] = Color3.fromRGB(50, 50, 50),
		['Text & Icon'] = Color3.fromRGB(230, 230, 230),
		['Function'] = {
			['Toggle'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['True'] = {
					['Toggle Background'] = Color3.fromRGB(40, 40, 40),
					['Toggle Value'] = Color3.fromRGB(70, 130, 180),
				},
				['False'] = {
					['Toggle Background'] = Color3.fromRGB(30, 30, 30),
					['Toggle Value'] = Color3.fromRGB(40, 40, 40),
				}
			},
			['Label'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
			},
			['Dropdown'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Value Background'] = Color3.fromRGB(20, 20, 20),
				['Value Stroke'] = Color3.fromRGB(230, 230, 230),
				['Dropdown Select'] = {
					['Background'] = Color3.fromRGB(20, 20, 20),
					['Search'] = Color3.fromRGB(30, 30, 30),
					['Item Background'] = Color3.fromRGB(30, 30, 30),
				}
			},
			['Slider'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Value Background'] = Color3.fromRGB(20, 20, 20),
				['Value Stroke'] = Color3.fromRGB(230, 230, 230),
				['Slider Bar'] = Color3.fromRGB(40, 40, 40),
				['Slider Bar Value'] = Color3.fromRGB(70, 130, 180),
				['Circle Value'] = Color3.fromRGB(255, 255, 255)
			},
			['Code'] = {
				['Background'] = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))},
				['Background Code'] = Color3.fromRGB(35, 35, 35),
				['Background Code Value'] = Color3.fromRGB(28, 28, 28),
				['ScrollingFrame Code'] = Color3.fromRGB(150, 150, 150)
			},
			['Button'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Click'] = Color3.fromRGB(230, 230, 230)
			},
			['Textbox'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Value Background'] = Color3.fromRGB(20, 20, 20),
				['Value Stroke'] = Color3.fromRGB(230, 230, 230),
			},
			['Keybind'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Value Background'] = Color3.fromRGB(20, 20, 20),
				['Value Stroke'] = Color3.fromRGB(230, 230, 230),
				['True'] = {
					['Toggle Background'] = Color3.fromRGB(40, 40, 40),
					['Toggle Value'] = Color3.fromRGB(70, 130, 180),
				},
				['False'] = {
					['Toggle Background'] = Color3.fromRGB(30, 30, 30),
					['Toggle Value'] = Color3.fromRGB(40, 40, 40),
				}
			},
			['Color Picker'] = {
				['Background'] = Color3.fromRGB(25, 25, 25),
				['Color Select'] = {
					['Background'] = Color3.fromRGB(20, 20, 20),
					['UIStroke'] = Color3.fromRGB(230, 230, 230),
				}
			}
		}
	},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Dummy Kawaii"
ScreenGui.Parent = not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local U, Tw = game:GetService("UserInputService"), game:GetService("TweenService")

do
	function addToTheme(name, obj)
		if not SaveTheme[name] then
			SaveTheme[name] = {}
		end
		table.insert(SaveTheme[name], obj)
	end
	function getColorFromPath(tbl, path)
		local result = tbl
		for _, part in ipairs(string.split(path, ".")) do
			result = result and result[part]
		end
		return result
	end
	function Library:setTheme(st)
		for name, objs in pairs(SaveTheme) do
			local color = getColorFromPath(st, name)
			if color then
				for _, obj in pairs(objs) do
					if SaveTheme[name] then
						for _, obj in pairs(SaveTheme[name]) do
							if obj:IsA("Frame") or obj:IsA("CanvasGroup") then
								obj.BackgroundColor3 = color
							elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
								obj.TextColor3 = color
							elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
								obj.ImageColor3 = color
							elseif obj:IsA("ScrollingFrame") then
								obj.ScrollBarImageColor3 = color
							elseif obj:IsA("UIStroke") then
								obj.Color = color
							elseif obj:IsA("UIGradient") then
								obj.Color = color
							end
						end
					end
				end
			end
		end
	end

	local IconList = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Icon.lua'))()
	function gl(i)
		local iconData = IconList.Icons[i]
		if iconData then
			local spriteSheet = IconList.Spritesheets[tostring(iconData.Image)]
			if spriteSheet then
				return {
					Image = spriteSheet,
					ImageRectSize = iconData.ImageRectSize,
					ImageRectPosition = iconData.ImageRectPosition,
				}
			end
		end
		if type(i) == 'string' and not i:find('rbxassetid://') then
			return {
				Image = "rbxassetid://".. i,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectPosition = Vector2.new(0, 0),
			}
		elseif type(i) == 'number' then
			return {
				Image = "rbxassetid://".. i,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectPosition = Vector2.new(0, 0),
			}
		else
			return i
		end
	end
	function tw(info)
		return Tw:Create(info.v,TweenInfo.new(info.t, info.s, Enum.EasingDirection[info.d]),info.g)
	end
	function changecanvas(ScrollingFrame, UIListLayout, Plus)
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + Plus or 5)
		end)
	end
	function gs(side, pl, pr)
		if not side then
			return pl
		end

		local sideLower = string.lower(tostring(side))
		if sideLower == "r" or sideLower == "right" or side == 2 then
			return pr
		elseif sideLower == "l" or sideLower == "left" or side == 1 then
			return pl
		else
			return pl
		end
	end
	function jc(c, p)
		local Mouse = game.Players.LocalPlayer:GetMouse()

		local relativeX = Mouse.X - c.AbsolutePosition.X
		local relativeY = Mouse.Y - c.AbsolutePosition.Y

		if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
			return
		end

		local ClickButtonCircle = Instance.new("Frame")
		ClickButtonCircle.Parent = p
		ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClickButtonCircle.BackgroundTransparency = 0.7
		ClickButtonCircle.BorderSizePixel = 0
		ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
		ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
		ClickButtonCircle.ZIndex = 10

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = ClickButtonCircle

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local goal = {
			Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
			BackgroundTransparency = 1
		}

		local expandTween = game:GetService("TweenService"):Create(ClickButtonCircle, tweenInfo, goal)

		expandTween.Completed:Connect(function()
			ClickButtonCircle:Destroy()
		end)

		expandTween:Play()
	end
	function jcf(p, p2)
		local ClickButtonCircle = Instance.new("Frame")
		ClickButtonCircle.Parent = p
		ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClickButtonCircle.BackgroundTransparency = 0.7
		ClickButtonCircle.BorderSizePixel = 0
		ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		ClickButtonCircle.Position = UDim2.new(0, p2.AbsolutePosition.X - p.AbsolutePosition.X + p2.AbsoluteSize.X / 2, 
			0, p2.AbsolutePosition.Y - p.AbsolutePosition.Y + p2.AbsoluteSize.Y / 2)
		ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
		ClickButtonCircle.ZIndex = 10

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = ClickButtonCircle

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local goal = {
			Size = UDim2.new(0, p2.AbsoluteSize.X * 5, 0, p2.AbsoluteSize.X * 5),
			BackgroundTransparency = 1
		}

		local expandTween = game:GetService("TweenService"):Create(ClickButtonCircle, tweenInfo, goal)

		expandTween.Completed:Connect(function()
			ClickButtonCircle:Destroy()
		end)

		expandTween:Play()
	end
	function lak(t, o)
		local a, b, c, d
		local function u(i)
			local dt = i.Position - c
			tw({v = o, t = 0.05, s = Enum.EasingStyle.Linear, d = "InOut", g = {Position = UDim2.new(d.X.Scale, d.X.Offset + dt.X, d.Y.Scale, d.Y.Offset + dt.Y)}}):Play()
		end
		t.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then a = true c = i.Position d = o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then a = false end end) end end)
		t.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then b = i end end)
		U.InputChanged:Connect(function(i) if i == b and a then u(i) end end)
	end
	function click(p)
		local Click = Instance.new("TextButton")

		Click.Name = "Click"
		Click.Parent = p
		Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Click.BackgroundTransparency = 1.000
		Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Click.BorderSizePixel = 0
		Click.Size = UDim2.new(1, 0, 1, 0)
		Click.Font = Enum.Font.SourceSans
		Click.Text = ""
		Click.TextColor3 = Color3.fromRGB(0, 0, 0)
		Click.TextSize = 14.000

		return Click
	end
	function background(pl, t, d, i, ty)
		local RealBackground = Instance.new("Frame")
		local Background = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local T_1 = Instance.new("Frame")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local UIPadding_3 = Instance.new("UIPadding")
		local TextLabel_1 = Instance.new("TextLabel")
		local TextLabel_2 = Instance.new("TextLabel")

		RealBackground.Name = "Real Background"
		RealBackground.Parent = pl
		RealBackground.BackgroundTransparency = 1
		RealBackground.BorderColor3 = Color3.fromRGB(0,0,0)
		RealBackground.BorderSizePixel = 0
		RealBackground.Size = UDim2.new(1, 0,0, 35)
		RealBackground.ClipsDescendants = true

		Background.Name = "Background"
		Background.Parent = RealBackground
		Background.BackgroundColor3 = Color3.fromRGB(29,28,38)
		Background.BorderColor3 = Color3.fromRGB(0,0,0)
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, 0,1, 0)
		Background.ClipsDescendants = true

		addToTheme('Function.'..ty..'.Background', Background)

		UICorner_1.Parent = Background

		T_1.Name = "T"
		T_1.Parent = Background
		T_1.AnchorPoint = Vector2.new(0, 0.5)
		T_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		T_1.BackgroundTransparency = 1
		T_1.BorderColor3 = Color3.fromRGB(0,0,0)
		T_1.BorderSizePixel = 0
		T_1.Position = UDim2.new(0, 0,0.5, 0)
		T_1.Size = UDim2.new(1, 0,1, 0)

		UIListLayout_2.Parent = T_1
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_3.Parent = T_1
		UIPadding_3.PaddingLeft = UDim.new(0,13)
		UIPadding_3.PaddingRight = UDim.new(0,70)

		TextLabel_1.Parent = T_1
		TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.BackgroundTransparency = 1
		TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_1.BorderSizePixel = 0
		TextLabel_1.LayoutOrder = 1
		TextLabel_1.Size = UDim2.new(1, 0,0, 14)
		TextLabel_1.Font = Enum.Font.GothamBold
		TextLabel_1.RichText = true
		TextLabel_1.Text = tostring(d)
		TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.TextSize = 10
		TextLabel_1.TextTransparency = 0.699999988079071
		TextLabel_1.TextWrapped = true
		TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel_1.Visible = false
		TextLabel_1.AutomaticSize = Enum.AutomaticSize.Y
		TextLabel_1.Name = 'Desc'

		addToTheme('Text & Icon', TextLabel_1)

		TextLabel_2.Parent = T_1
		TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_2.BackgroundTransparency = 1
		TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_2.BorderSizePixel = 0
		TextLabel_2.Size = UDim2.new(1, 0,0, 14)
		TextLabel_2.Font = Enum.Font.GothamBold
		TextLabel_2.RichText = true
		TextLabel_2.Text = tostring(t)
		TextLabel_2.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabel_2.TextSize = 12
		TextLabel_2.TextWrapped = true
		TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel_2.AutomaticSize = Enum.AutomaticSize.Y
		TextLabel_2.Name = 'Title'

		addToTheme('Text & Icon', TextLabel_2)

		if d and d ~= "" then
			TextLabel_1.Visible = true
		end

		if i and i ~= "" then
			UIPadding_3.PaddingLeft = UDim.new(0, 50)
			local Image = Instance.new("Frame")
			local Icon_1 = Instance.new("ImageLabel")
			local Frame_1 = Instance.new("Frame")

			Image.Name = "Image"
			Image.Parent = Background
			Image.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Image.BackgroundTransparency = 1
			Image.BorderColor3 = Color3.fromRGB(0,0,0)
			Image.BorderSizePixel = 0
			Image.Size = UDim2.new(0, 40,1, 0)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Image
			Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Icon_1.Size = UDim2.new(0, 20,0, 20)
			Icon_1.Image = gl(i).Image
			Icon_1.ImageRectSize = gl(i).ImageRectSize
			Icon_1.ImageRectOffset = gl(i).ImageRectPosition
			Icon_1.ImageTransparency = 0.7

			Frame_1.Parent = Image
			Frame_1.AnchorPoint = Vector2.new(1, 0.5)
			Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_1.BackgroundTransparency = 0.8999999761581421
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Position = UDim2.new(1, 0,0.5, 0)
			Frame_1.Size = UDim2.new(0, 1,0.699999988, 0)

			addToTheme('Text & Icon', Icon_1)

			addToTheme('Text & Icon', Frame_1)
		end

		local function updateSize()
			task.defer(function()
				local newSize = UIListLayout_2.AbsoluteContentSize.Y + 21
				if RealBackground.Size.Y.Offset ~= newSize then
					RealBackground.Size = UDim2.new(1, 0, 0, newSize)
				end
			end)
		end

		delay(.1, updateSize)

		UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

		local f = {}

		function f:SetTextTransparencyTitle(vs)
			tw({v = TextLabel_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = vs}}):Play()
			if i and i ~= "" then
				tw({v = Background.Image.Icon, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = vs}}):Play()
			end
		end

		function f:SetSizeT(vs)
			UIPadding_3.PaddingRight = UDim.new(0, vs)
		end

		function f:SetTitle(vs)
			TextLabel_2.Text = tostring(vs)
		end

		function f:SetDesc(vs)
			TextLabel_1.Text = tostring(vs)
			if vs and vs ~= "" then
				TextLabel_1.Visible = true
			else
				TextLabel_1.Visible = false
			end
		end

		function f:SetVisibleDesc(vs)
			TextLabel_2.Visible = vs
		end

		return Background, f
	end
	function addDropdownSelect(p, p2, Multi, Callback, Value, List)
		local F = Instance.new("Frame")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_1 = Instance.new("UIPadding")
		local DropdownValue = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local UIStroke_1 = Instance.new("UIStroke")
		local TextLabelValue_1 = Instance.new("TextLabel")
		local UIPadding_2 = Instance.new("UIPadding")
		local ImageLabel_1 = Instance.new("ImageLabel")

		F.Name = "F"
		F.Parent = p
		F.AnchorPoint = Vector2.new(1, 0.5)
		F.BackgroundColor3 = Color3.fromRGB(255,255,255)
		F.BackgroundTransparency = 1
		F.BorderColor3 = Color3.fromRGB(0,0,0)
		F.BorderSizePixel = 0
		F.Position = UDim2.new(1, 0,0.5, 0)
		F.Size = UDim2.new(0, 120,0.800000012, 0)

		UIListLayout_1.Parent = F
		UIListLayout_1.Padding = UDim.new(0,15)
		UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_1.Parent = F
		UIPadding_1.PaddingRight = UDim.new(0,13)

		DropdownValue.Parent = F
		DropdownValue.BackgroundColor3 = Color3.fromRGB(24,24,31)
		DropdownValue.BorderColor3 = Color3.fromRGB(0,0,0)
		DropdownValue.BorderSizePixel = 0
		DropdownValue.Size = UDim2.new(0, 100,0, 20)

		addToTheme('Function.Dropdown.Value Background', DropdownValue)

		UICorner_1.Parent = DropdownValue
		UICorner_1.CornerRadius = UDim.new(0,4)

		UIStroke_1.Parent = DropdownValue
		UIStroke_1.Color = Color3.fromRGB(255,255,255)
		UIStroke_1.Thickness = 1
		UIStroke_1.Transparency = 0.95

		addToTheme('Function.Dropdown.Value Stroke', UIStroke_1)

		TextLabelValue_1.Parent = DropdownValue
		TextLabelValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabelValue_1.BackgroundTransparency = 1
		TextLabelValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabelValue_1.BorderSizePixel = 0
		TextLabelValue_1.Size = UDim2.new(0.8, 0,1, 0)
		TextLabelValue_1.Font = Enum.Font.GothamBold
		TextLabelValue_1.RichText = true
		TextLabelValue_1.Text = "--"
		TextLabelValue_1.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabelValue_1.TextSize = 10
		TextLabelValue_1.TextTransparency = 0.3
		TextLabelValue_1.TextXAlignment = Enum.TextXAlignment.Left
		TextLabelValue_1.TextTruncate = Enum.TextTruncate.AtEnd

		addToTheme('Text & Icon', TextLabelValue_1)

		UIPadding_2.Parent = DropdownValue
		UIPadding_2.PaddingLeft = UDim.new(0,5)
		UIPadding_2.PaddingRight = UDim.new(0,5)

		ImageLabel_1.Parent = DropdownValue
		ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
		ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_1.BackgroundTransparency = 1
		ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_1.BorderSizePixel = 0
		ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
		ImageLabel_1.Size = UDim2.new(0, 20,0, 20)
		ImageLabel_1.Image = "rbxassetid://14937709869"
		ImageLabel_1.ImageTransparency = 0.3

		addToTheme('Text & Icon', ImageLabel_1)

		local DropdownSelect = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local UIStrokeDropdown_1 = Instance.new("UIStroke")
		local UIPadding_1 = Instance.new("UIPadding")
		local Search_1 = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local TextBox_1 = Instance.new("TextBox")
		local Frame_1 = Instance.new("Frame")
		local Frame_2 = Instance.new("Frame")
		local Frame_3 = Instance.new("Frame")
		local UICorner_3 = Instance.new("UICorner")
		local ScrollingFrame_1 = Instance.new("ScrollingFrame")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_2 = Instance.new("UIPadding")
		local UIPadding_3 = Instance.new("UIPadding")
		local UIPadding_4 = Instance.new("UIPadding")

		DropdownSelect.Parent = ScreenGui
		DropdownSelect.BackgroundColor3 = Color3.fromRGB(24,24,31)
		DropdownSelect.BorderColor3 = Color3.fromRGB(0,0,0)
		DropdownSelect.BorderSizePixel = 0
		DropdownSelect.Size = UDim2.new(0, 150,0, 0)
		DropdownSelect.ClipsDescendants = true

		addToTheme('Function.Dropdown.Dropdown Select.Background', DropdownSelect)

		DropdownSelect.Position = UDim2.new(0, DropdownValue.AbsolutePosition.X - DropdownSelect.Parent.AbsolutePosition.X + DropdownValue.Size.X.Offset - 119, 0, DropdownValue.AbsolutePosition.Y - DropdownSelect.Parent.AbsolutePosition.Y + DropdownValue.Size.Y.Offset - 25)

		UICorner_1.Parent = DropdownSelect
		UICorner_1.CornerRadius = UDim.new(0,4)

		UIStrokeDropdown_1.Parent = DropdownSelect
		UIStrokeDropdown_1.Color = Color3.fromRGB(255,255,255)
		UIStrokeDropdown_1.Thickness = 1
		UIStrokeDropdown_1.Transparency = 1

		UIPadding_1.Parent = DropdownSelect
		UIPadding_1.PaddingBottom = UDim.new(0,5)
		UIPadding_1.PaddingLeft = UDim.new(0,5)
		UIPadding_1.PaddingRight = UDim.new(0,5)
		UIPadding_1.PaddingTop = UDim.new(0,5)

		Search_1.Name = "Search"
		Search_1.Parent = DropdownSelect
		Search_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Search_1.BackgroundTransparency = 0.949999988079071
		Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Search_1.BorderSizePixel = 0
		Search_1.Size = UDim2.new(1, 0,0, 20)

		addToTheme('Function.Dropdown.Dropdown Select.Search', Search_1)

		UICorner_2.Parent = Search_1
		UICorner_2.CornerRadius = UDim.new(0,4)

		TextBox_1.Parent = Search_1
		TextBox_1.Active = true
		TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextBox_1.BackgroundTransparency = 1
		TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TextBox_1.BorderSizePixel = 0
		TextBox_1.CursorPosition = -1
		TextBox_1.Size = UDim2.new(1, 0,1, 0)
		TextBox_1.Font = Enum.Font.Gotham
		TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
		TextBox_1.PlaceholderText = "Search . . ."
		TextBox_1.Text = ""
		TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
		TextBox_1.TextSize = 11

		addToTheme('Text & Icon', Search_1)

		addToTheme('Text & Icon', TextBox_1)

		Frame_1.Parent = Search_1
		Frame_1.AnchorPoint = Vector2.new(0, 1)
		Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_1.BackgroundTransparency = 0.8999999761581421
		Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_1.BorderSizePixel = 0
		Frame_1.Position = UDim2.new(0, 0,1, 0)
		Frame_1.Size = UDim2.new(1, 0,0, 2)

		Frame_2.Parent = DropdownSelect
		Frame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_2.BackgroundTransparency = 1
		Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_2.BorderSizePixel = 0
		Frame_2.Size = UDim2.new(1, 0,1, 0)

		Frame_3.Parent = Frame_2
		Frame_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_3.BackgroundTransparency = 0.949999988079071
		Frame_3.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_3.BorderSizePixel = 0
		Frame_3.Size = UDim2.new(1, 0,1, 0)

		UICorner_3.Parent = Frame_3
		UICorner_3.CornerRadius = UDim.new(0,4)

		ScrollingFrame_1.Name = "ScrollingFrame"
		ScrollingFrame_1.Parent = Frame_3
		ScrollingFrame_1.Active = true
		ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ScrollingFrame_1.BackgroundTransparency = 1
		ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ScrollingFrame_1.BorderSizePixel = 0
		ScrollingFrame_1.Size = UDim2.new(1, 0,1, 0)
		ScrollingFrame_1.ClipsDescendants = true
		ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
		ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(107,84,255)
		ScrollingFrame_1.ScrollBarImageTransparency = 0
		ScrollingFrame_1.ScrollBarThickness = 2
		ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
		ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_1.Parent = ScrollingFrame_1
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_1.Padding = UDim.new(0, 3)

		UIPadding_2.Parent = ScrollingFrame_1
		UIPadding_2.PaddingRight = UDim.new(0,5)

		UIPadding_3.Parent = Frame_3
		UIPadding_3.PaddingBottom = UDim.new(0,5)
		UIPadding_3.PaddingLeft = UDim.new(0,5)
		UIPadding_3.PaddingRight = UDim.new(0,3)
		UIPadding_3.PaddingTop = UDim.new(0,5)

		UIPadding_4.Parent = Frame_2
		UIPadding_4.PaddingTop = UDim.new(0,25)

		local Click = click(p2)

		local isopen = false

		local function updateDropdownSize()
			if not isopen then return end

			local visibleCount = 0
			for i, v in pairs(ScrollingFrame_1:GetChildren()) do
				if v:IsA("Frame") and v.Visible then
					visibleCount = visibleCount + 1
				end
			end

			local contentHeight = (UIListLayout_1.AbsoluteContentSize.Y + 54)
			if contentHeight > 200 then
				contentHeight = 200
			end

			tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 150, 0, contentHeight)}}):Play()
		end

		TextBox_1.Changed:Connect(function()
			local SearchT = string.lower(TextBox_1.Text)
			for i, v in pairs(ScrollingFrame_1:GetChildren()) do
				if v:IsA("Frame") then
					if SearchT ~= "" and v:FindFirstChild("TextLabel") then
						if string.find(string.lower(v.TextLabel.Text), SearchT) then
							v.Visible = true
						else
							v.Visible = false
						end
					else
						v.Visible = true
					end
				end
			end
			updateDropdownSize()
		end)

		local function open()
			if isopen then
				return
			end
			DropdownSelect.Visible = true
			local targetX = DropdownValue.AbsolutePosition.X - DropdownSelect.Parent.AbsolutePosition.X + DropdownValue.Size.X.Offset - 119
			local targetY = DropdownValue.AbsolutePosition.Y - DropdownSelect.Parent.AbsolutePosition.Y + DropdownValue.Size.Y.Offset - 25
			local contentHeight = UIListLayout_1.AbsoluteContentSize.Y + 54
			if contentHeight <= 200 then
				tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, 150, 0, contentHeight), Position = UDim2.new(0, targetX, 0, targetY)}}):Play()
			else
				tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, 150, 0, 200), Position = UDim2.new(0, targetX, 0, targetY)}}):Play()
			end
			tw({v = UIStrokeDropdown_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 0.95}}):Play()
			isopen = true
		end

		local function close()
			if not isopen then
				return
			end
			tw({v = UIStrokeDropdown_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 1}}):Play()
			local gf = tw({v = DropdownSelect, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, 150,0, 0)}})
			gf:Play()
			gf.Completed:Connect(function()
				DropdownSelect.Visible = false
				isopen = false
			end)
		end

		U.InputBegan:Connect(function(A)
			if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
				local B, C = DropdownSelect.AbsolutePosition, DropdownSelect.AbsoluteSize
				if game:GetService "Players".LocalPlayer:GetMouse().X < B.X or game:GetService "Players".LocalPlayer:GetMouse().X > B.X + C.X or game:GetService "Players".LocalPlayer:GetMouse().Y < (B.Y - 20 - 1) or game:GetService "Players".LocalPlayer:GetMouse().Y > B.Y + C.Y then
					close()
				end
			end
		end)

		Click.MouseButton1Click:Connect(function()
			if not isopen then
				open()
			else
				close()
			end
		end)

		local itemslist = {}
		local selectedValues = {}
		local selectedItem

		function itemslist:Clear(a)
			local function shouldClear(v)
				if a == nil then
					return true
				elseif type(a) == "string" then
					return v:FindFirstChild("TextLabel") and v.TextLabel.Text == a
				elseif type(a) == "table" then
					for _, name in ipairs(a) do
						if v:FindFirstChild("TextLabel") and v.TextLabel.Text == name then
							return true
						end
					end
				end
				return false
			end

			if Multi then
				selectedValues = {}
				TextLabelValue_1.Text = "--"
				pcall(Callback ,selectedValues)
			end

			for _, v in ipairs(ScrollingFrame_1:GetChildren()) do
				if v:IsA("Frame") and shouldClear(v) then
					if selectedItem and v:FindFirstChild("TextLabel") and v.TextLabel.Text == selectedItem then
						selectedItem = nil
						TextLabelValue_1.Text = "--"
						pcall(Callback, TextLabelValue_1.Text)
					end
					v:Destroy()
				end
			end

			if selectedItem == a or TextLabelValue_1.Text == a then
				selectedItem = nil
				TextLabelValue_1.Text = "--"
			end

			if a == nil then
				selectedItem = nil
				TextLabelValue_1.Text = "--"
			end

			Value = nil
		end

		function itemslist:Add(text)

			local Item_1 = Instance.new("Frame")
			local TextLabel_1 = Instance.new("TextLabel")

			Item_1.Name = "Item"
			Item_1.Parent = ScrollingFrame_1
			Item_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Item_1.BackgroundTransparency = 0.95
			Item_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Item_1.BorderSizePixel = 0
			Item_1.Size = UDim2.new(1, 0,0, 18)

			TextLabel_1.Parent = Item_1
			TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.BackgroundTransparency = 1
			TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_1.BorderSizePixel = 0
			TextLabel_1.Size = UDim2.new(1, 0,1, 0)
			TextLabel_1.Font = Enum.Font.GothamBold
			TextLabel_1.Text = text
			TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.TextSize = 12
			TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_1.TextTransparency = 0.8

			addToTheme('Function.Dropdown.Dropdown Select.Item Background', Item_1)
			addToTheme('Text & Icon', TextLabel_1)

			Instance.new("UICorner", Item_1).CornerRadius = UDim.new(0, 4)
			Instance.new("UIPadding", Item_1).PaddingLeft = UDim.new(0, 5)

			local ClickItem = click(Item_1)
			local function unselect()
				tw({v = TextLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.8}}):Play()
			end
			local function hasselect()
				tw({v = TextLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0}}):Play()
			end

			ClickItem.MouseButton1Click:Connect(function()
				if Multi then
					if selectedValues[text] then
						selectedValues[text] = nil
						unselect()
					else
						selectedValues[text] = true
						hasselect()
					end
					local selectedList = {}
					for i, v in pairs(selectedValues) do
						table.insert(selectedList, i)
					end
					if #selectedList > 0 then
						TextLabelValue_1.Text = table.concat(selectedList, ", ")
					else
						TextLabelValue_1.Text = "--"
					end
					pcall(Callback, selectedList)
				else
					for i,v in pairs(ScrollingFrame_1:GetChildren()) do
						if v:IsA("Frame") then
							tw({v = v.TextLabel, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {TextTransparency = 0.8}}):Play()
						end
					end
					hasselect()
					Value = text
					TextLabelValue_1.Text = text
					pcall(Callback, TextLabelValue_1.Text)
				end
			end)

			local function isValueInTable(val, tbl)
				if type(tbl) ~= "table" then
					return false
				end

				for _, v in pairs(tbl) do
					if v == val then
						return true
					end
				end
				return false
			end

			delay(0,function()
				if Multi then
					if isValueInTable(text, Value) then
						hasselect()
						selectedValues[text] = true
						local selectedList = {}
						for i, v in pairs(selectedValues) do
							table.insert(selectedList, i)
						end
						if #selectedList > 0 then
							TextLabelValue_1.Text = table.concat(selectedList, ", ")
						else
							TextLabelValue_1.Text = "--"
						end
						pcall(Callback,selectedList)
					end
				else
					if text == Value then
						hasselect()
						Value = text
						TextLabelValue_1.Text = text
						pcall(Callback,TextLabelValue_1.Text)
					end
				end
			end)
		end

		function itemslist:SetValue(value)
			if Multi then
				selectedValues = {}
				selectedValues[value] = true
				TextLabelValue_1.Text = value
				for _, v in ipairs(ScrollingFrame_1:GetChildren()) do
					if v:IsA("Frame") and v:FindFirstChild("TextLabel") then
						if v.TextLabel.Text == value then
							tw({v = v.TextLabel, t = 0.05, s = Enum.EasingStyle.Exponential, d = "Out", g = {TextTransparency = 0}}):Play()
						else
							tw({v = v.TextLabel, t = 0.05, s = Enum.EasingStyle.Exponential, d = "Out", g = {TextTransparency = 0.8}}):Play()
						end
					end
				end
				pcall(Callback, selectedValues)
			else
				Value = value
				TextLabelValue_1.Text = value
				for _, v in ipairs(ScrollingFrame_1:GetChildren()) do
					if v:IsA("Frame") and v:FindFirstChild("TextLabel") then
						if v.TextLabel.Text == value then
							tw({v = v.TextLabel, t = 0.05, s = Enum.EasingStyle.Exponential, d = "Out", g = {TextTransparency = 0}}):Play()
						else
							tw({v = v.TextLabel, t = 0.05, s = Enum.EasingStyle.Exponential, d = "Out", g = {TextTransparency = 0.8}}):Play()
						end
					end
				end
				pcall(Callback, value)
			end
		end

		for i, v in ipairs(List) do
			itemslist:Add(v, i)
		end

		changecanvas(ScrollingFrame_1, UIListLayout_1, 5)

		return itemslist
	end
end

function Library:Window(p)

	local Title = p.Title or 'null'
	local Desc = p.Desc or ''
	local Icon = p.Icon or 'door-open'
	local Theme = p.Theme or 'Dark'
	local Keybind = p.Config.Keybind or Enum.KeyCode.LeftControl
	local Size = p.Config.Size or UDim2.new(0, 530,0, 400)

	local R, HAA = false, false
	local HasChangeTheme = p.Theme
	local IsTheme = p.Theme

	local Shadow_1 = Instance.new("ImageLabel")
	local UIPadding_1 = Instance.new("UIPadding")
	local Background_1 = Instance.new("CanvasGroup")
	local UICorner_1 = Instance.new("UICorner")
	local Page_1 = Instance.new("Frame")
	local UIPadding_2 = Instance.new("UIPadding")

	Shadow_1.Name = "Shadow"
	Shadow_1.Parent = ScreenGui
	Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_1.BackgroundColor3 = Color3.fromRGB(163,162,165)
	Shadow_1.BackgroundTransparency = 1
	Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_1.Size = Size
	Shadow_1.Image = "rbxassetid://1316045217"
	Shadow_1.ImageColor3 = Color3.fromRGB(24, 24, 31)
	Shadow_1.ImageTransparency = 0.8
	Shadow_1.ScaleType = Enum.ScaleType.Slice
	Shadow_1.SliceCenter = Rect.new(10, 10, 118, 118)
	Shadow_1.Visible = false

	addToTheme('Shadow', Shadow_1)

	UIPadding_1.Parent = Shadow_1
	UIPadding_1.PaddingBottom = UDim.new(0,8)
	UIPadding_1.PaddingLeft = UDim.new(0,8)
	UIPadding_1.PaddingRight = UDim.new(0,8)
	UIPadding_1.PaddingTop = UDim.new(0,8)

	Background_1.Name = "Background"
	Background_1.Parent = Shadow_1
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(29, 28, 38)
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = UDim2.new(1, 0,1, 0)
	Background_1.ClipsDescendants = true
	Background_1.GroupTransparency = 1

	Shadow_1.Visible = true  
	local org = Background_1.Size
	Background_1.Size = org - UDim2.fromOffset(5, 5)
	tw({
		v = Background_1,
		t = 0.15,
		s = Enum.EasingStyle.Linear,
		d = "InOut",
		g = {
			GroupTransparency = 0,
			Size = org
		}
	}):Play()

	addToTheme('Background', Background_1)

	UICorner_1.Parent = Background_1
	UICorner_1.CornerRadius = UDim.new(0,17)

	Page_1.Name = "Page"
	Page_1.Parent = Background_1
	Page_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Page_1.BackgroundTransparency = 1
	Page_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Page_1.BorderSizePixel = 0
	Page_1.Size = UDim2.new(1, 0,1, 0)

	UIPadding_2.Parent = Page_1
	UIPadding_2.PaddingBottom = UDim.new(0,5)
	UIPadding_2.PaddingLeft = UDim.new(0,120)
	UIPadding_2.PaddingRight = UDim.new(0,5)
	UIPadding_2.PaddingTop = UDim.new(0,45)

	local Topbar_1 = Instance.new("Frame")
	local Frame_5 = Instance.new("Frame")
	local Ct_1 = Instance.new("Frame")
	local UIPadding_11 = Instance.new("UIPadding")
	local Minisize_1 = Instance.new("ImageButton")
	local UIListLayout_6 = Instance.new("UIListLayout")
	local Close_1 = Instance.new("ImageButton")
	local DropdownValue_1 = Instance.new("Frame")
	local Td_1 = Instance.new("Frame")
	local UIPadding_13 = Instance.new("UIPadding")
	local UIListLayout_7 = Instance.new("UIListLayout")
	local Icon_1 = Instance.new("ImageLabel")
	local Title_1 = Instance.new("Frame")
	local Desc_1 = Instance.new("TextLabel")
	local UIListLayout_8 = Instance.new("UIListLayout")
	local Title_2 = Instance.new("TextLabel")
	local ChSize_1 = Instance.new("ImageButton")

	Topbar_1.Name = "Topbar"
	Topbar_1.Parent = Background_1
	Topbar_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Topbar_1.BackgroundTransparency = 1
	Topbar_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Topbar_1.BorderSizePixel = 0
	Topbar_1.Size = UDim2.new(1, 0,0, 42)

	Frame_5.Parent = Topbar_1
	Frame_5.AnchorPoint = Vector2.new(0, 1)
	Frame_5.BackgroundColor3 = Color3.fromRGB(24,24,31)
	Frame_5.BorderColor3 = Color3.fromRGB(0,0,0)
	Frame_5.BorderSizePixel = 0
	Frame_5.Position = UDim2.new(0, 0,1, 0)
	Frame_5.Size = UDim2.new(1, 0,0, 2)

	addToTheme('Page', Frame_5)

	Ct_1.Name = "Ct"
	Ct_1.Parent = Topbar_1
	Ct_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Ct_1.BackgroundTransparency = 1
	Ct_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Ct_1.BorderSizePixel = 0
	Ct_1.Size = UDim2.new(1, 0,1, 0)

	UIPadding_11.Parent = Ct_1
	UIPadding_11.PaddingBottom = UDim.new(0,5)
	UIPadding_11.PaddingLeft = UDim.new(0,10)
	UIPadding_11.PaddingRight = UDim.new(0,10)
	UIPadding_11.PaddingTop = UDim.new(0,5)

	Minisize_1.Name = "Minisize"
	Minisize_1.Parent = Ct_1
	Minisize_1.Active = true
	Minisize_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Minisize_1.BackgroundTransparency = 1
	Minisize_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Minisize_1.BorderSizePixel = 0
	Minisize_1.LayoutOrder = 2
	Minisize_1.Size = UDim2.new(0, 16,0, 16)
	Minisize_1.Image = "rbxassetid://13857987062"
	Minisize_1.ImageTransparency = 0.5

	addToTheme('Text & Icon', Minisize_1)

	UIListLayout_6.Parent = Ct_1
	UIListLayout_6.Padding = UDim.new(0,10)
	UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_6.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center

	Close_1.Name = "Close"
	Close_1.Parent = Ct_1
	Close_1.Active = true
	Close_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Close_1.BackgroundTransparency = 1
	Close_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Close_1.BorderSizePixel = 0
	Close_1.LayoutOrder = 3
	Close_1.Size = UDim2.new(0, 16,0, 16)
	Close_1.Image = "rbxassetid://15082305656"

	ChSize_1.Name = "Size"
	ChSize_1.Parent = Ct_1
	ChSize_1.Active = true
	ChSize_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ChSize_1.BackgroundTransparency = 1
	ChSize_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ChSize_1.BorderSizePixel = 0
	ChSize_1.LayoutOrder = 1
	ChSize_1.Size = UDim2.new(0, 16,0, 16)
	ChSize_1.Image = "rbxassetid://15082210525"
	ChSize_1.ImageTransparency = 0.5

	DropdownValue_1.Name = "DropdownValue"
	DropdownValue_1.Parent = Ct_1
	DropdownValue_1.AnchorPoint = Vector2.new(1, 0.5)
	DropdownValue_1.BackgroundColor3 = Color3.fromRGB(24,24,31)
	DropdownValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
	DropdownValue_1.BorderSizePixel = 0
	DropdownValue_1.Position = UDim2.new(1, 0,0.5, 0)
	DropdownValue_1.Size = UDim2.new(0, 120,0, 20)
	DropdownValue_1.Transparency = 1

	Td_1.Name = "Td"
	Td_1.Parent = Topbar_1
	Td_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Td_1.BackgroundTransparency = 1
	Td_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Td_1.BorderSizePixel = 0
	Td_1.Size = UDim2.new(1, 0,1, 0)

	UIPadding_13.Parent = Td_1
	UIPadding_13.PaddingBottom = UDim.new(0,5)
	UIPadding_13.PaddingLeft = UDim.new(0,10)
	UIPadding_13.PaddingRight = UDim.new(0,10)
	UIPadding_13.PaddingTop = UDim.new(0,5)

	UIListLayout_7.Parent = Td_1
	UIListLayout_7.Padding = UDim.new(0,8)
	UIListLayout_7.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_7.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_7.VerticalAlignment = Enum.VerticalAlignment.Center

	Icon_1.Name = "Icon"
	Icon_1.Parent = Td_1
	Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Icon_1.BackgroundTransparency = 1
	Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Icon_1.BorderSizePixel = 0
	Icon_1.Size = UDim2.new(0, 30,0, 30)
	Icon_1.Image = gl(Icon).Image
	Icon_1.ImageRectSize = gl(Icon).ImageRectSize
	Icon_1.ImageRectOffset = gl(Icon).ImageRectPosition

	addToTheme('Text & Icon', Icon_1)

	Title_1.Name = "Title"
	Title_1.Parent = Td_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 4
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.LayoutOrder = 1
	Title_1.Size = UDim2.new(0, 100,1, 0)

	Desc_1.Name = "Desc"
	Desc_1.Parent = Title_1
	Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Desc_1.BackgroundTransparency = 1
	Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_1.BorderSizePixel = 0
	Desc_1.LayoutOrder = 1
	Desc_1.Size = UDim2.new(1, 0,0, 13)
	Desc_1.Font = Enum.Font.GothamBold
	Desc_1.Text = Desc
	Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
	Desc_1.TextSize = 10
	Desc_1.TextTransparency = 0.5
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left
	Desc_1.Visible = false

	addToTheme('Text & Icon', Desc_1)

	if Desc and Desc ~= '' then
		Desc_1.Visible = true
	end

	UIListLayout_8.Parent = Title_1
	UIListLayout_8.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_8.VerticalAlignment = Enum.VerticalAlignment.Center

	Title_2.Name = "Title"
	Title_2.Parent = Title_1
	Title_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_2.BackgroundTransparency = 1
	Title_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_2.BorderSizePixel = 0
	Title_2.Size = UDim2.new(1, 0,0, 13)
	Title_2.Font = Enum.Font.GothamBold
	Title_2.Text = Title
	Title_2.TextColor3 = Color3.fromRGB(255,255,255)
	Title_2.TextSize = 12
	Title_2.TextXAlignment = Enum.TextXAlignment.Left

	addToTheme('Text & Icon', Title_2)

	local TabP_1 = Instance.new("Frame")
	local Frame_6 = Instance.new("Frame")
	local ScrollingFrame_2 = Instance.new("ScrollingFrame")
	local TabList_1 = Instance.new("Frame")
	local Select_1 = Instance.new("Frame")
	local UICorner_10 = Instance.new("UICorner")
	local UIStroke_3 = Instance.new("UIStroke")
	local UIPadding_16 = Instance.new("UIPadding")
	local UIPadding_17 = Instance.new("UIPadding")
	local UIListLayout_10 = Instance.new("UIListLayout")

	TabP_1.Name = "TabP"
	TabP_1.Parent = Background_1
	TabP_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabP_1.BackgroundTransparency = 1
	TabP_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabP_1.BorderSizePixel = 0
	TabP_1.Size = UDim2.new(1, 0,1, 0)

	Frame_6.Parent = TabP_1
	Frame_6.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Frame_6.BackgroundTransparency = 1
	Frame_6.BorderColor3 = Color3.fromRGB(0,0,0)
	Frame_6.BorderSizePixel = 0
	Frame_6.Size = UDim2.new(0, 110,1, 0)

	ScrollingFrame_2.Name = "ScrollingFrame"
	ScrollingFrame_2.Parent = Frame_6
	ScrollingFrame_2.Active = true
	ScrollingFrame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ScrollingFrame_2.BackgroundTransparency = 1
	ScrollingFrame_2.BorderColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_2.BorderSizePixel = 0
	ScrollingFrame_2.Size = UDim2.new(1, 0,1, 0)
	ScrollingFrame_2.ClipsDescendants = true
	ScrollingFrame_2.AutomaticCanvasSize = Enum.AutomaticSize.None
	ScrollingFrame_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	ScrollingFrame_2.CanvasPosition = Vector2.new(0, 0)
	ScrollingFrame_2.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	ScrollingFrame_2.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame_2.ScrollBarImageColor3 = Color3.fromRGB(91,68,209)
	ScrollingFrame_2.ScrollBarImageTransparency = 0
	ScrollingFrame_2.ScrollBarThickness = 2
	ScrollingFrame_2.ScrollingDirection = Enum.ScrollingDirection.XY
	ScrollingFrame_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	ScrollingFrame_2.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_2.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

	addToTheme('Main', ScrollingFrame_2)

	TabList_1.Name = "TabList"
	TabList_1.Parent = ScrollingFrame_2
	TabList_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabList_1.BackgroundTransparency = 1
	TabList_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabList_1.BorderSizePixel = 0
	TabList_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_10.Parent = TabList_1
	UIListLayout_10.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_10.HorizontalAlignment = Enum.HorizontalAlignment.Center

	Select_1.Name = "Select"
	Select_1.Parent = ScrollingFrame_2
	Select_1.BackgroundColor3 = Color3.fromRGB(91,68,209)
	Select_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Select_1.BorderSizePixel = 0
	Select_1.Position = UDim2.new(0, 0,0, 5)
	Select_1.Size = UDim2.new(0, 3,0, 18)

	addToTheme('Main', Select_1)

	UICorner_10.Parent = Select_1
	UICorner_10.CornerRadius = UDim.new(1,0)

	UIStroke_3.Parent = Select_1
	UIStroke_3.Color = Color3.fromRGB(24,24,31)
	UIStroke_3.Thickness = 1
	UIStroke_3.Transparency = 0.9

	UIPadding_16.Parent = ScrollingFrame_2
	UIPadding_16.PaddingBottom = UDim.new(0,1)
	UIPadding_16.PaddingLeft = UDim.new(0,1)
	UIPadding_16.PaddingRight = UDim.new(0,1)
	UIPadding_16.PaddingTop = UDim.new(0,1)

	UIPadding_17.Parent = TabP_1
	UIPadding_17.PaddingBottom = UDim.new(0,5)
	UIPadding_17.PaddingLeft = UDim.new(0,3)
	UIPadding_17.PaddingTop = UDim.new(0,45)

	changecanvas(ScrollingFrame_2, UIListLayout_10, 5)

	local Tabs = {
		Value = false,
		List = {},
		DefaultIndex = 1
	}

	function Tabs:SelectTab(p)
		Tabs.DefaultIndex = p or 1
	end

	function Tabs:Line()
		local Frame = Instance.new("Frame")
		local Line = Instance.new("Frame")

		Frame.Parent = TabList_1
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1.000
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Size = UDim2.new(1, 0, 0, 5)
		Frame.Name = 'Line'

		Line.Name = "Line"
		Line.Parent = Frame
		Line.AnchorPoint = Vector2.new(0.5, 0.5)
		Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Line.BackgroundTransparency = 0.900
		Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0.5, 0, 0.5, 0)
		Line.Size = UDim2.new(0.85, 0, 0, 1)
	end

	function Tabs:Tab(p)
		local Title = p.Title or 'null'
		local Icon = p.Icon or 'house'
		local Tab_1 = Instance.new("Frame")
		local Title_3 = Instance.new("TextLabel")
		local UIListLayout_9 = Instance.new("UIListLayout")
		local ImageLabel_2 = Instance.new("ImageLabel")
		local UIPadding_14 = Instance.new("UIPadding")
		local UIStroke_2 = Instance.new("UIStroke")
		local Func = Instance.new("Frame")

		Tab_1.Name = "Tab"
		Tab_1.Parent = TabList_1
		Tab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Tab_1.BackgroundTransparency = 1
		Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Tab_1.BorderSizePixel = 0
		Tab_1.Size = UDim2.new(1, 0,0, 30)

		Func.Name = "Func"
		Func.Parent = Tab_1
		Func.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Func.BackgroundTransparency = 1.000
		Func.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Func.BorderSizePixel = 0
		Func.Size = UDim2.new(1, 0, 1, 0)

		Title_3.Name = "Title"
		Title_3.Parent = Func
		Title_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_3.BackgroundTransparency = 1
		Title_3.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_3.BorderSizePixel = 0
		Title_3.LayoutOrder = 1
		Title_3.Size = UDim2.new(1, 0,1, 0)
		Title_3.Font = Enum.Font.GothamBold
		Title_3.Text = tostring(Title)
		Title_3.TextColor3 = Color3.fromRGB(255,255,255)
		Title_3.TextSize = 11
		Title_3.TextTransparency = 0.7
		Title_3.TextWrapped = true
		Title_3.TextXAlignment = Enum.TextXAlignment.Left

		addToTheme('Text & Icon', Title_3)

		UIListLayout_9.Parent = Func
		UIListLayout_9.Padding = UDim.new(0,8)
		UIListLayout_9.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_9.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_9.VerticalAlignment = Enum.VerticalAlignment.Center

		ImageLabel_2.Parent = Func
		ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_2.BackgroundTransparency = 1
		ImageLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_2.BorderSizePixel = 0
		ImageLabel_2.Size = UDim2.new(0, 18,0, 18)
		ImageLabel_2.Image = gl(Icon).Image
		ImageLabel_2.ImageTransparency = 0.7
		ImageLabel_2.ImageRectSize = gl(Icon).ImageRectSize
		ImageLabel_2.ImageRectOffset = gl(Icon).ImageRectPosition

		addToTheme('Text & Icon', ImageLabel_2)

		UIPadding_14.Parent = Func
		UIPadding_14.PaddingLeft = UDim.new(0,8)

		UIStroke_2.Parent = Title_3
		UIStroke_2.Color = Color3.fromRGB(24,24,31)
		UIStroke_2.Thickness = 1
		UIStroke_2.Transparency = 0.95

		local InPage_1 = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local ScrollingFrame_1 = Instance.new("ScrollingFrame")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_10 = Instance.new("UIPadding")

		InPage_1.Name = "InPage"
		InPage_1.Parent = Page_1
		InPage_1.AnchorPoint = Vector2.new(0.5 ,0.5)
		InPage_1.BackgroundColor3 = Color3.fromRGB(24,24,31)
		InPage_1.BorderColor3 = Color3.fromRGB(0,0,0)
		InPage_1.BorderSizePixel = 0
		InPage_1.Size = UDim2.new(1, 0,1, 0)
		InPage_1.Position = UDim2.new(0.5, 0, 0.5, 0)
		InPage_1.Visible = false

		addToTheme('Page', InPage_1)

		UICorner_2.Parent = InPage_1
		UICorner_2.CornerRadius = UDim.new(0,17)

		ScrollingFrame_1.Name = "ScrollingFrame"
		ScrollingFrame_1.Parent = InPage_1
		ScrollingFrame_1.Active = true
		ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ScrollingFrame_1.BackgroundTransparency = 1
		ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ScrollingFrame_1.BorderSizePixel = 0
		ScrollingFrame_1.Size = UDim2.new(1, 0,1, 0)
		ScrollingFrame_1.ClipsDescendants = true
		ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
		ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		ScrollingFrame_1.ScrollBarImageTransparency = 0
		ScrollingFrame_1.ScrollBarThickness = 0
		ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
		ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_1.Parent = ScrollingFrame_1
		UIListLayout_1.Padding = UDim.new(0,5)
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

		UIPadding_10.Parent = InPage_1
		UIPadding_10.PaddingBottom = UDim.new(0,10)
		UIPadding_10.PaddingLeft = UDim.new(0,10)
		UIPadding_10.PaddingRight = UDim.new(0,10)
		UIPadding_10.PaddingTop = UDim.new(0,10)

		local Click = click(Tab_1)

		table.insert(self.List, {
			Page = InPage_1,
			Button = Tab_1
		})
		local MyIndex = #self.List

		local function twSelect()
			local scrollingFrame = Select_1.Parent
			local tabScrollingFrame = Tab_1.Parent

			local tabCenterY = Tab_1.AbsolutePosition.Y + (Tab_1.AbsoluteSize.Y / 2)
			local selectOffset = Select_1.AbsoluteSize.Y / 2
			local relativeY = tabCenterY - tabScrollingFrame.AbsolutePosition.Y
			local offset = scrollingFrame.AbsolutePosition.Y - Select_1.Parent.AbsolutePosition.Y

			local targetY = relativeY + offset - selectOffset

			local pos = UDim2.new(0, Select_1.Position.X.Offset, 0, targetY)

			tw({
				v = Select_1,
				t = 0.5,
				s = Enum.EasingStyle.Exponential,
				d = "Out",
				g = {
					Position = pos
				}
			}):Play()
		end

		local function chg()
			for i, v in pairs(self.List) do
				v.Page.Visible = false
				for i, v in pairs(ScrollingFrame_1:GetChildren()) do
					if v:IsA('Frame') and v:FindFirstChild('Background') then
						v.Background.Position = UDim2.new(0, 0, 0,0)
						v.Background.AnchorPoint = Vector2.new(1 ,0)
					end
				end
				task.spawn(function()
					for i, v in next, ScrollingFrame_1:GetChildren() do
						if v:IsA('Frame') and v:FindFirstChild('Background') then
							tw({
								v = v.Background,
								t = 0.3,
								s = Enum.EasingStyle.Exponential,
								d = "InOut",
								g = {AnchorPoint = Vector2.new(0 ,0)}
							}):Play()
							task.wait(.05)
						end
					end
				end)
				InPage_1.Visible = true
			end
			for i, v in pairs(TabList_1:GetChildren()) do
				if v:IsA('Frame') and v.Name ~= 'Line' then
					tw({
						v = v.Func.Title,
						t = 0.15,
						s = Enum.EasingStyle.Linear,
						d = "InOut",
						g = {TextTransparency = 0.7}
					}):Play()
					tw({
						v = v.Func.ImageLabel,
						t = 0.15,
						s = Enum.EasingStyle.Linear,
						d = "InOut",
						g = {ImageTransparency = 0.7}
					}):Play()
				end
			end
			tw({
				v = Title_3,
				t = 0.15,
				s = Enum.EasingStyle.Linear,
				d = "InOut",
				g = {TextTransparency = 0}
			}):Play()
			tw({
				v = ImageLabel_2,
				t = 0.15,
				s = Enum.EasingStyle.Linear,
				d = "InOut",
				g = {ImageTransparency = 0}
			}):Play()
			Page_1.Visible = true
			twSelect()
		end

		Click.MouseButton1Click:Connect(chg)

		changecanvas(ScrollingFrame_1, UIListLayout_1, 5)

		delay(.1, function()
			if not self.Value then
				local total = #self.List
				local index = self.DefaultIndex

				if type(index) ~= "number" or index < 1 or index > total then
					index = 1
				end

				if MyIndex == index then
					chg()
					self.Value = true
				end
			end
		end)

		local Func = {}

		function Func:Section(p)
			local Title = p.Title or 'null'
			local RealBackground = Instance.new("Frame")
			local Section = Instance.new("Frame")
			local Section_1 = Instance.new("TextLabel")
			local UIPadding_1 = Instance.new("UIPadding")

			RealBackground.Name = "Real Background"
			RealBackground.Parent = ScrollingFrame_1
			RealBackground.BackgroundTransparency = 1
			RealBackground.BorderColor3 = Color3.fromRGB(0,0,0)
			RealBackground.BorderSizePixel = 0
			RealBackground.Size = UDim2.new(1, 0,0, 20)
			RealBackground.ClipsDescendants = true

			Section.Name = "Background"
			Section.Parent = RealBackground
			Section.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Section.BackgroundTransparency = 1
			Section.BorderColor3 = Color3.fromRGB(0,0,0)
			Section.BorderSizePixel = 0
			Section.Size = UDim2.new(1, 0,0, 20)

			Section_1.Name = "Section"
			Section_1.Parent = Section
			Section_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Section_1.BackgroundTransparency = 1
			Section_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Section_1.BorderSizePixel = 0
			Section_1.Size = UDim2.new(1, 0,0, 20)
			Section_1.Font = Enum.Font.GothamBold
			Section_1.Text = Title
			Section_1.TextColor3 = Color3.fromRGB(255,255,255)
			Section_1.TextSize = 12
			Section_1.TextXAlignment = Enum.TextXAlignment.Left

			addToTheme('Text & Icon', Section_1)

			UIPadding_1.Parent = Section
			UIPadding_1.PaddingLeft = UDim.new(0,5)
			UIPadding_1.PaddingRight = UDim.new(0,5)

			local New = {}

			function New:SetTitle(t)
				Section_1.Text = t
			end

			return New
		end

		function Func:Toggle(p)
			local Value = p.Value or false
			local Image = p.Image or ''
			local Callback = p.Callback or function() end
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''

			local Toggle, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Toggle')

			local F_1 = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local UIPadding_1 = Instance.new("UIPadding")
			local Frame_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local Frame_2 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIPadding_2 = Instance.new("UIPadding")

			F_1.Name = "F"
			F_1.Parent = Toggle
			F_1.AnchorPoint = Vector2.new(1, 0.5)
			F_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			F_1.BackgroundTransparency = 1
			F_1.BorderColor3 = Color3.fromRGB(0,0,0)
			F_1.BorderSizePixel = 0
			F_1.Position = UDim2.new(1, 0,0.5, 0)
			F_1.Size = UDim2.new(0, 100,0.800000012, 0)

			UIListLayout_1.Parent = F_1
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			UIPadding_1.Parent = F_1
			UIPadding_1.PaddingRight = UDim.new(0,13)

			Frame_1.Parent = F_1
			Frame_1.BackgroundColor3 = Color3.fromRGB(36, 35, 48)
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Size = UDim2.new(0, 34,0, 17)

			UICorner_2.Parent = Frame_1
			UICorner_2.CornerRadius = UDim.new(1,0)

			Frame_2.Parent = Frame_1
			Frame_2.AnchorPoint = Vector2.new(0, 0.5)
			Frame_2.BackgroundColor3 = Color3.fromRGB(44, 42, 62)
			Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_2.BorderSizePixel = 0
			Frame_2.Position = UDim2.new(0, 0,0.5, 0)
			Frame_2.Size = UDim2.new(0, 13,0, 13)

			if Value then
				Frame_1.BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Background']
				Frame_2.BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Value']
			else
				Frame_1.BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Background']
				Frame_2.BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Value']
			end

			UICorner_3.Parent = Frame_2
			UICorner_3.CornerRadius = UDim.new(1,0)

			UIPadding_2.Parent = Frame_1
			UIPadding_2.PaddingLeft = UDim.new(0,2)
			UIPadding_2.PaddingRight = UDim.new(0,2)

			local Click = click(Toggle)

			Value = not Value

			local function change()
				Value = not Value
				if Value then
					Config:SetTextTransparencyTitle(0)
					tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Background']}}):Play()
					tw({v = Frame_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out",
						g = {
							BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Value'],
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0,0.5, 0)
						}}):Play()
				else
					Config:SetTextTransparencyTitle(0.7)
					tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Background']}}):Play()
					tw({v = Frame_2, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out",
						g = {
							BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Value'],
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0,0.5, 0)
						}}):Play()
				end
				pcall(Callback, Value)
			end

			Toggle:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				if Value then
					Frame_1.BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Background']
					Frame_2.BackgroundColor3 = themes[IsTheme].Function.Toggle.True['Toggle Value']
				else
					Frame_1.BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Background']
					Frame_2.BackgroundColor3 = themes[IsTheme].Function.Toggle.False['Toggle Value']
				end
			end)

			Click.MouseButton1Click:Connect(change)

			delay(0.1, change)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Toggle.Visible = t
			end

			function New:SetValue(t)
				Value = not t
				change()
			end

			return New
		end

		function Func:Label(p)
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''
			local Image = p.Image or ''

			local Label, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Label')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(0)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Label.Visible = t
			end

			return New
		end

		function Func:Button(p)
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local Callback = p.Callback or function() end

			local Button, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Button')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(50)

			Button.ClipsDescendants = true

			local F = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local UIPadding_1 = Instance.new("UIPadding")
			local Image_1 = Instance.new("ImageLabel")

			F.Name = "F"
			F.Parent = Button
			F.AnchorPoint = Vector2.new(1, 0.5)
			F.BackgroundColor3 = Color3.fromRGB(255,255,255)
			F.BackgroundTransparency = 1
			F.BorderColor3 = Color3.fromRGB(0,0,0)
			F.BorderSizePixel = 0
			F.Position = UDim2.new(1, 0,0.5, 0)
			F.Size = UDim2.new(0, 50,0.800000012, 0)

			UIListLayout_1.Parent = F
			UIListLayout_1.Padding = UDim.new(0,8)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			UIPadding_1.Parent = F
			UIPadding_1.PaddingRight = UDim.new(0,13)

			Image_1.Name = "Image"
			Image_1.Parent = F
			Image_1.AnchorPoint = Vector2.new(1, 0.5)
			Image_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Image_1.BackgroundTransparency = 1
			Image_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Image_1.BorderSizePixel = 0
			Image_1.Position = UDim2.new(1, 0,0.5, 0)
			Image_1.Size = UDim2.new(0, 20,0, 20)
			Image_1.Image = "rbxassetid://14923748517"
			Image_1.ImageTransparency = 0.3

			local Click = click(Button)
			Click.MouseButton1Click:Connect(function()
				Button.AnchorPoint = Vector2.new(0.5, 0.5)
				Button.Position = UDim2.new(0.5, 0, 0.5,0)
				jc(Click, Button)
				tw({v = Button, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {Size = UDim2.new(.9, 0,.9, 0)}}):Play()
				delay(.06, function()
					tw({v = Button, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {Size = UDim2.new(1, 0,1, 0)}}):Play()
				end)
				pcall(Callback)
			end)
		end

		function Func:Slider(p)
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local Min = p.Min or 0
			local Max = p.Max or 100
			local Value = p.Value or Min + 1
			local Rounding = p.Rounding or 2
			local Callback = p.Callback or function() end

			local Slider, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Slider')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(200)

			local F = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local UIPadding_1 = Instance.new("UIPadding")
			local FrameValueTextBox = Instance.new('Frame')
			local TextBox_1 = Instance.new("TextBox")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local Frame_1 = Instance.new("Frame")
			local Frame_2 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local Frame_3 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local Frame_4 = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local UIPadding_2 = Instance.new("UIPadding")

			F.Name = "F"
			F.Parent = Slider
			F.AnchorPoint = Vector2.new(1, 0.5)
			F.BackgroundColor3 = Color3.fromRGB(255,255,255)
			F.BackgroundTransparency = 1
			F.BorderColor3 = Color3.fromRGB(0,0,0)
			F.BorderSizePixel = 0
			F.Position = UDim2.new(1, 0,0.5, 0)
			F.Size = UDim2.new(0, 195,0.8, 0)

			UIListLayout_1.Parent = F
			UIListLayout_1.Padding = UDim.new(0,8)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			UIPadding_1.Parent = F
			UIPadding_1.PaddingRight = UDim.new(0,13)

			FrameValueTextBox.Parent = F
			FrameValueTextBox.Active = true
			FrameValueTextBox.BackgroundColor3 = Color3.fromRGB(24,24,31)
			FrameValueTextBox.BorderColor3 = Color3.fromRGB(0,0,0)
			FrameValueTextBox.BorderSizePixel = 0
			FrameValueTextBox.Size = UDim2.new(0, 50,0, 20)
			FrameValueTextBox.LayoutOrder = 1

			addToTheme('Function.Slider.Value Background', FrameValueTextBox)

			TextBox_1.Parent = FrameValueTextBox
			TextBox_1.Active = true
			TextBox_1.BackgroundTransparency = 1
			TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextBox_1.BorderSizePixel = 0
			TextBox_1.Size = UDim2.new(1, 0,1, 0)
			TextBox_1.Font = Enum.Font.Cartoon
			TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextBox_1.PlaceholderText = ""
			TextBox_1.Text = tonumber(Value)
			TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextBox_1.TextSize = 12

			addToTheme('Text & Icon', TextBox_1)

			UICorner_1.Parent = FrameValueTextBox
			UICorner_1.CornerRadius = UDim.new(0,4)

			UIStroke_1.Parent = FrameValueTextBox
			UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke_1.Color = Color3.fromRGB(255,255,255)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.95

			addToTheme('Function.Slider.Value Stroke', UIStroke_1)

			Frame_1.Parent = F
			Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_1.BackgroundTransparency = 1
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Size = UDim2.new(0, 120,0, 20)

			Frame_2.Parent = Frame_1
			Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame_2.BackgroundColor3 = Color3.fromRGB(44,34,103)
			Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_2.BorderSizePixel = 0
			Frame_2.Position = UDim2.new(0.5, 0,0.5, 0)
			Frame_2.Size = UDim2.new(1, 0,0, 10)

			addToTheme('Function.Slider.Slider Bar', Frame_2)

			UICorner_2.Parent = Frame_2
			UICorner_2.CornerRadius = UDim.new(1,0)

			Frame_3.Parent = Frame_2
			Frame_3.AnchorPoint = Vector2.new(0, 0.5)
			Frame_3.BackgroundColor3 = Color3.fromRGB(91,68,209)
			Frame_3.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_3.BorderSizePixel = 0
			Frame_3.Position = UDim2.new(0, 0,0.5, 0)
			Frame_3.Size = UDim2.new(0, 0,1, 0)

			addToTheme('Function.Slider.Slider Bar Value', Frame_3)

			UICorner_3.Parent = Frame_3
			UICorner_3.CornerRadius = UDim.new(1,0)

			Frame_4.Parent = Frame_3
			Frame_4.AnchorPoint = Vector2.new(1, 0.5)
			Frame_4.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_4.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_4.BorderSizePixel = 0
			Frame_4.Position = UDim2.new(1, 0,0.5, 0)
			Frame_4.Size = UDim2.new(0, 13,0, 13)

			addToTheme('Function.Slider.Circle Value', Frame_4)

			UICorner_4.Parent = Frame_4
			UICorner_4.CornerRadius = UDim.new(1,0)

			UIPadding_2.Parent = Frame_2
			UIPadding_2.PaddingBottom = UDim.new(0,2)
			UIPadding_2.PaddingLeft = UDim.new(0,2)
			UIPadding_2.PaddingRight = UDim.new(0,2)
			UIPadding_2.PaddingTop = UDim.new(0,2)

			local Click = click(Frame_1)

			local function roundToDecimal(value, decimals)
				local factor = 10 ^ decimals
				return math.floor(value * factor + 0.5) / factor
			end

			local function updateSlider(value)
				value = math.clamp(value, Min, Max)
				value = roundToDecimal(value, Rounding)
				Value = value
				local va = (value - Min) / (Max - Min)
				tw({v = Frame_3, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(math.clamp(va, 0.12, 1), 0, 1, 0)}}):Play()
				TextBox_1.Text = tostring(roundToDecimal(value, Rounding))
				pcall(Callback ,value)
			end

			updateSlider(Value or 0)

			TextBox_1.FocusLost:Connect(function()
				local value = tonumber(TextBox_1.Text) or Min
				updateSlider(value)
			end)

			local function move(input)
				local sliderBar = Frame_2
				local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
				local value = relativeX * (Max - Min) + Min
				updateSlider(value)
			end

			local dragging = false

			Click.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					move(input)
				end
			end)

			Click.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			U.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					move(input)
				end
			end)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Slider.Visible = t
			end

			function New:SetValue(t)
				updateSlider(t)
			end

			function New:SetMin(t)
				Min = t
				if Value < t then
					updateSlider(t)
				end
			end

			function New:SetMax(t)
				Max = t
				if Value > t then
					updateSlider(t)
				end
			end

			return New
		end

		function Func:Code(p)
			local Title = p.Title or 'null'
			local CodeText = p.Code or '-- print("Hello World")'

			local RealBackground = Instance.new("Frame")
			local Code = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local FF_1 = Instance.new("Frame")
			local UIPadding_1 = Instance.new("UIPadding")
			local F_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local Frame_1 = Instance.new("Frame")
			local UIPadding_2 = Instance.new("UIPadding")
			local Frame_2 = Instance.new("Frame")
			local UIPadding_3 = Instance.new("UIPadding")
			local TextBox_2 = Instance.new("TextLabel")
			local Top_1 = Instance.new("Frame")
			local Left_1 = Instance.new("Frame")
			local Whatisthis_1 = Instance.new("ImageLabel")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local Frame_3 = Instance.new("Frame")
			local Frame_4 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local UIPadding_4 = Instance.new("UIPadding")
			local TextLabel_1 = Instance.new("TextLabel")
			local Right_1 = Instance.new("Frame")
			local UIListLayout_3 = Instance.new("UIListLayout")
			local Frame_5 = Instance.new("Frame")
			local TextButton_1 = Instance.new("TextButton")
			local UIPadding_5 = Instance.new("UIPadding")
			local ImageLabel_1 = Instance.new("ImageLabel")
			local UIGradient_1 = Instance.new("UIGradient")

			RealBackground.Name = "Real Background"
			RealBackground.Parent = ScrollingFrame_1
			RealBackground.BackgroundTransparency = 1
			RealBackground.BorderColor3 = Color3.fromRGB(0,0,0)
			RealBackground.BorderSizePixel = 0
			RealBackground.Size = UDim2.new(1, 0,0, 120)
			RealBackground.ClipsDescendants = true

			Code.Name = "Background"
			Code.Parent = RealBackground
			Code.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Code.BorderColor3 = Color3.fromRGB(0,0,0)
			Code.BorderSizePixel = 0
			Code.Size = UDim2.new(1, 0,1, 0)
			Code.ClipsDescendants = true

			UICorner_1.Parent = Code

			FF_1.Name = "FF"
			FF_1.Parent = Code
			FF_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			FF_1.BackgroundTransparency = 1
			FF_1.BorderColor3 = Color3.fromRGB(0,0,0)
			FF_1.BorderSizePixel = 0
			FF_1.Size = UDim2.new(1, 0,1, 0)

			UIPadding_1.Parent = FF_1
			UIPadding_1.PaddingBottom = UDim.new(0,8)
			UIPadding_1.PaddingLeft = UDim.new(0,8)
			UIPadding_1.PaddingRight = UDim.new(0,8)
			UIPadding_1.PaddingTop = UDim.new(0,8)

			F_1.Name = "F"
			F_1.Parent = FF_1
			F_1.AnchorPoint = Vector2.new(0, 0.5)
			F_1.BackgroundColor3 = Color3.fromRGB(51,62,68)
			F_1.BorderColor3 = Color3.fromRGB(0,0,0)
			F_1.BorderSizePixel = 0
			F_1.Position = UDim2.new(0, 0,0.5, 0)
			F_1.Size = UDim2.new(1, 0,1, 0)
			F_1.ClipsDescendants = true

			addToTheme('Function.Code.Background Code', F_1)

			UICorner_2.Parent = F_1

			Frame_1.Parent = F_1
			Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_1.BackgroundTransparency = 1
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Size = UDim2.new(1, 0,1, 0)

			UIPadding_2.Parent = Frame_1
			UIPadding_2.PaddingTop = UDim.new(0,30)

			Frame_2.Parent = Frame_1
			Frame_2.BackgroundColor3 = Color3.fromRGB(38, 50, 56)
			Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_2.BorderSizePixel = 0
			Frame_2.Size = UDim2.new(1, 0,1, 0)

			addToTheme('Function.Code.Background Code Value', Frame_2)

			Instance.new('UICorner', Frame_2)

			UIPadding_3.Parent = Frame_2
			UIPadding_3.PaddingBottom = UDim.new(0,5)
			UIPadding_3.PaddingLeft = UDim.new(0,8)
			UIPadding_3.PaddingRight = UDim.new(0,8)
			UIPadding_3.PaddingTop = UDim.new(0,8)

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Parent = Frame_2
			ScrollingFrame.Active = true
			ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ScrollingFrame.BackgroundTransparency = 1.000
			ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
			ScrollingFrame.CanvasSize = UDim2.new(2, 0, 0, 0)
			ScrollingFrame.ScrollBarThickness = 4
			ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(216, 150, 179)

			addToTheme('Function.Code.ScrollingFrame Code', ScrollingFrame)

			local Code_1 = Instance.new("Frame")
			local UIPaddingCode_1 = Instance.new("UIPadding")

			Code_1.Name = "Code"
			Code_1.Parent = ScrollingFrame
			Code_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Code_1.BackgroundTransparency = 1
			Code_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Code_1.BorderSizePixel = 0
			Code_1.Size = UDim2.new(1, 0,1, 0)

			UIPaddingCode_1.Name = "UIPaddingCode"
			UIPaddingCode_1.Parent = Code_1
			UIPaddingCode_1.PaddingLeft = UDim.new(0,20)

			TextBox_2.Name = "TextBox"
			TextBox_2.Parent = Code_1
			TextBox_2.Active = true
			TextBox_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextBox_2.BackgroundTransparency = 1
			TextBox_2.BorderColor3 = Color3.fromRGB(0,0,0)
			TextBox_2.BorderSizePixel = 0
			TextBox_2.Size = UDim2.new(0, 0,0, 0)
			TextBox_2.Font = Enum.Font.Code
			TextBox_2.RichText = true
			TextBox_2.TextColor3 = Color3.fromRGB(255,255,255)
			TextBox_2.TextSize = 12
			TextBox_2.TextXAlignment = Enum.TextXAlignment.Left
			TextBox_2.TextYAlignment = Enum.TextYAlignment.Top
			TextBox_2.Text = CodeText
			TextBox_2.AutomaticSize = Enum.AutomaticSize.XY

			addToTheme('Text & Icon', TextBox_2)

			Top_1.Name = "Top"
			Top_1.Parent = F_1
			Top_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Top_1.BackgroundTransparency = 1
			Top_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Top_1.BorderSizePixel = 0
			Top_1.Size = UDim2.new(1, 0,0, 30)

			Left_1.Name = "Left"
			Left_1.Parent = Top_1
			Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Left_1.BackgroundTransparency = 1
			Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Left_1.BorderSizePixel = 0
			Left_1.Size = UDim2.new(1, 0,1, 0)

			Whatisthis_1.Name = "Whatisthis"
			Whatisthis_1.Parent = Left_1
			Whatisthis_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Whatisthis_1.BackgroundTransparency = 1
			Whatisthis_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Whatisthis_1.BorderSizePixel = 0
			Whatisthis_1.Size = UDim2.new(0, 50,0, 13)
			Whatisthis_1.Image = "rbxassetid://81518443444327"
			Whatisthis_1.ScaleType = Enum.ScaleType.Fit

			UIListLayout_1.Parent = Left_1
			UIListLayout_1.Padding = UDim.new(0,5)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Frame_3.Parent = Left_1
			Frame_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_3.BackgroundTransparency = 1
			Frame_3.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_3.BorderSizePixel = 0
			Frame_3.Size = UDim2.new(0, 100,0, 30)

			Frame_4.Parent = Frame_3
			Frame_4.BackgroundColor3 = Color3.fromRGB(37, 49, 55)
			Frame_4.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_4.BorderSizePixel = 0
			Frame_4.Position = UDim2.new(0, 0,0.15, 0)
			Frame_4.Size = UDim2.new(1, 0,0, 30)

			addToTheme('Function.Code.Background Code Value', Frame_4)

			addToTheme('Function.Code.Background Value', Frame_4)

			UICorner_3.Parent = Frame_4

			UIListLayout_2.Parent = Frame_4
			UIListLayout_2.Padding = UDim.new(0,5)
			UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

			UIPadding_4.Parent = Frame_4
			UIPadding_4.PaddingLeft = UDim.new(0,8)
			UIPadding_4.PaddingRight = UDim.new(0,8)

			TextLabel_1.Parent = Frame_4
			TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.BackgroundTransparency = 1
			TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_1.BorderSizePixel = 0
			TextLabel_1.Size = UDim2.new(1, 0,0, 25)
			TextLabel_1.Font = Enum.Font.GothamBold
			TextLabel_1.Text = tostring(Title)
			TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.TextSize = 11

			addToTheme('Text & Icon', TextLabel_1)

			Right_1.Name = "Right"
			Right_1.Parent = Top_1
			Right_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Right_1.BackgroundTransparency = 1
			Right_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Right_1.BorderSizePixel = 0
			Right_1.Size = UDim2.new(1, 0,1, 0)

			UIListLayout_3.Parent = Right_1
			UIListLayout_3.Padding = UDim.new(0,5)
			UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

			Frame_5.Parent = Right_1
			Frame_5.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_5.BackgroundTransparency = 1
			Frame_5.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_5.BorderSizePixel = 0
			Frame_5.Size = UDim2.new(0, 60,0, 30)

			TextButton_1.Parent = Frame_5
			TextButton_1.Active = true
			TextButton_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextButton_1.BackgroundTransparency = 1
			TextButton_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextButton_1.BorderSizePixel = 0
			TextButton_1.Size = UDim2.new(1, 0,1, 0)
			TextButton_1.Font = Enum.Font.GothamBold
			TextButton_1.Text = "Copy"
			TextButton_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextButton_1.TextSize = 11
			TextButton_1.TextTransparency = 0.5
			TextButton_1.TextXAlignment = Enum.TextXAlignment.Right

			UIPadding_5.Parent = Frame_5
			UIPadding_5.PaddingRight = UDim.new(0,10)

			ImageLabel_1.Parent = Frame_5
			ImageLabel_1.AnchorPoint = Vector2.new(0, 0.5)
			ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ImageLabel_1.BackgroundTransparency = 1
			ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ImageLabel_1.BorderSizePixel = 0
			ImageLabel_1.Position = UDim2.new(0, 0,0.5, 0)
			ImageLabel_1.Size = UDim2.new(0, 16,0, 16)
			ImageLabel_1.Image = "rbxassetid://13847222481"
			ImageLabel_1.ImageTransparency = 0.5

			UIGradient_1.Parent = Code
			--UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 150, 179)), ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 81, 164))}
			UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 28, 38)), ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 28, 38))}
			UIGradient_1.Rotation = 45

			addToTheme('Function.Code.Background', UIGradient_1)

			local Line = Instance.new("Frame")
			local LineText_1 = Instance.new("TextLabel")

			Line.Name = "Line"
			Line.Parent = ScrollingFrame
			Line.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line.BackgroundTransparency = 1
			Line.BorderColor3 = Color3.fromRGB(0,0,0)
			Line.BorderSizePixel = 0
			Line.Size = UDim2.new(1, 0,1, 0)

			LineText_1.Name = "LineText"
			LineText_1.Parent = Line
			LineText_1.Active = true
			LineText_1.AutomaticSize = Enum.AutomaticSize.XY
			LineText_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			LineText_1.BackgroundTransparency = 1
			LineText_1.BorderColor3 = Color3.fromRGB(0,0,0)
			LineText_1.BorderSizePixel = 0
			LineText_1.Size = UDim2.new(0, 0,0, 0)
			LineText_1.Font = Enum.Font.RobotoMono
			LineText_1.RichText = true
			LineText_1.Text = ''
			LineText_1.TextColor3 = Color3.fromRGB(255,255,255)
			LineText_1.TextSize = 12
			LineText_1.TextXAlignment = Enum.TextXAlignment.Left
			LineText_1.TextYAlignment = Enum.TextYAlignment.Top
			LineText_1.TextWrapped = true

			local highlighter = {}

			do
				local keywords = {
					lua = {
						"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
						"local", "return", "function", "export"
					},
					rbx = {
						"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
						"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
						"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
						"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
						"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
					},
					operators = {
						"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">",
					}
				}

				local colors = {
					numbers = Color3.fromHex("#79c0ff"),
					boolean = Color3.fromHex("#79c0ff"),
					operator = Color3.fromHex("#ff7b72"),
					lua = Color3.fromHex("#ff7b72"),
					rbx = Color3.fromHex("#7fcfef"), -- def
					str = Color3.fromHex("#a5d6ff"),
					comment = Color3.fromHex("#8b949e"),
					null = Color3.fromHex("#79c0ff"),
					call = Color3.fromHex("#d2a8ff"),    
					self_call = Color3.fromHex("#d2a8ff"),
					local_property = Color3.fromHex("#ff7b72"),
				}

				local function createKeywordSet(keywords)
					local keywordSet = {}
					for _, keyword in ipairs(keywords) do
						keywordSet[keyword] = true
					end
					return keywordSet
				end

				local luaSet = createKeywordSet(keywords.lua)
				local rbxSet = createKeywordSet(keywords.rbx)
				local operatorsSet = createKeywordSet(keywords.operators)

				local function getHighlight(tokens, index)
					local token = tokens[index]

					if colors[token .. "_color"] then
						return colors[token .. "_color"]
					end

					if tonumber(token) then
						return colors.numbers
					elseif token == "nil" then
						return colors.null
					elseif token:sub(1, 2) == "--" then
						return colors.comment
					elseif operatorsSet[token] then
						return colors.operator
					elseif luaSet[token] then
						return colors.lua
					elseif rbxSet[token] then
						return colors.rbx
					elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
						return colors.str
					elseif token == "true" or token == "false" then
						return colors.boolean
					else
					end

					if tokens[index + 1] == "(" then
						if tokens[index - 1] == ":" then
							return colors.self_call
						end

						return colors.call
					end

					if tokens[index - 1] == "." then
						if tokens[index - 2] == "Enum" then
							return colors.rbx
						end

						return colors.local_property
					end
				end

				function highlighter.run(source)
					local tokens = {}
					local multiStrings = {}
					local currentToken = ""

					local index = 1
					source = source:gsub("%[%[.-%]%]", function(str)
						local placeholder = "" .. index .. "__"
						multiStrings[placeholder] = str
						index = index + 1
						return placeholder
					end)

					local inString = false
					local inComment = false
					local commentPersist = false

					for i = 1, #source do
						local character = source:sub(i, i)

						if inComment then
							if character == "\n" and not commentPersist then
								table.insert(tokens, currentToken)
								table.insert(tokens, character)
								currentToken = ""
								inComment = false
							elseif source:sub(i - 1, i) == "]]" and commentPersist then
								currentToken = currentToken .. "]"
								table.insert(tokens, currentToken)
								currentToken = ""
								inComment = false
								commentPersist = false
							else
								currentToken = currentToken .. character
							end
						elseif inString then
							if character == inString and source:sub(i - 1, i - 1) ~= "\\" or character == "\n" then
								currentToken = currentToken .. character
								inString = false
							else
								currentToken = currentToken .. character
							end
						else
							local foundPlaceholder = source:sub(i):match("^__MULTISTR_%d+__")
							if foundPlaceholder then
								table.insert(tokens, foundPlaceholder)
								i = i + #foundPlaceholder - 1
							elseif source:sub(i, i + 1) == "--" then
								table.insert(tokens, currentToken)
								currentToken = "-"
								inComment = true
								commentPersist = source:sub(i + 2, i + 3) == "[["
							elseif character == "\"" or character == "\'" then
								table.insert(tokens, currentToken)
								currentToken = character
								inString = character
							elseif operatorsSet[character] then
								table.insert(tokens, currentToken)
								table.insert(tokens, character)
								currentToken = ""
							elseif character:match("[%w_]") then
								currentToken = currentToken .. character
							else
								table.insert(tokens, currentToken)
								table.insert(tokens, character)
								currentToken = ""
							end
						end
					end

					table.insert(tokens, currentToken)

					local highlighted = {}

					for i, token in ipairs(tokens) do
						if multiStrings[token] then
							local syntax = string.format(
								'<font color = "#%s">%s</font>',
								colors.str:ToHex(),
								multiStrings[token]:gsub("<", "&lt;"):gsub(">", "&gt;")
							)
							table.insert(highlighted, syntax)
						else
							local highlight = getHighlight(tokens, i)

							if highlight then
								local syntax = string.format(
									'<font color = "#%s">%s</font>',
									highlight:ToHex(),
									token:gsub("<", "&lt;"):gsub(">", "&gt;")
								)
								table.insert(highlighted, syntax)
							else
								table.insert(highlighted, token)
							end
						end
					end

					return table.concat(highlighted)
				end
			end

			local iscop = false

			TextButton_1.MouseButton1Click:Connect(function()
				if not iscop then
					setclipboard(CodeText)
					TextButton_1.Text = "Copied"
					ImageLabel_1.Image = "rbxassetid://14939475472"
					Frame_5.Size = UDim2.new(0, 65,0, 30)
					iscop = true
					delay(1, function()
						TextButton_1.Text = "Copy"
						ImageLabel_1.Image = "rbxassetid://13847222481"
						Frame_5.Size = UDim2.new(0, 58,0, 30)
						iscop = false
					end)
				end
			end)

			TextBox_2.Text = highlighter.run(TextBox_2.Text)

			TextBox_2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				ScrollingFrame.CanvasSize = UDim2.new(0, TextBox_2.AbsoluteSize.X + 20, 0, 0)
			end)

			local function updateLineNumbers()
				tw({v = RealBackground, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(1, 0,0, TextBox_2.TextBounds.Y + 65)}}):Play()
				tw({v = Frame_3, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, TextLabel_1.TextBounds.X + 30,0, 30)}}):Play()

				local count = #TextBox_2.Text:split("\n")

				local str = ""
				for i = 1, count do
					str = str .. i .. "\n"
				end
				LineText_1.Text = str
			end

			updateLineNumbers()
			TextBox_2:GetPropertyChangedSignal("Text"):Connect(updateLineNumbers)

			local New = {}

			function New:SetTitle(t)
				TextLabel_1.Text = tostring(t)
			end

			function New:SetCode(t)
				TextBox_2.Text = highlighter.run(t)
				CodeText = t
			end

			return New
		end

		function Func:Dropdown(p)
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local List = p.List or {}
			local Value = p.Value or List[1]
			local Multi = p.Multi or false
			local Callback = p.Callback or function() end

			local Dropdown, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Dropdown')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(125)

			local DropdownSelect = addDropdownSelect(Dropdown, Dropdown, Multi, Callback, Value, List)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Dropdown.Visible = t
			end

			function New:SetValue(t)
				DropdownSelect:SetValue(t)
			end

			function New:Add(t)
				DropdownSelect:Add(t)
			end

			function New:Clear(t)
				local n = t or nil
				DropdownSelect:Clear(n)
			end

			return New
		end

		function Func:Keybind(p)
			local Title = p.Title or 'null'
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local Value = p.Value or false
			local Key = p.Key or Enum.KeyCode.E
			local Callback = p.Callback or function() end

			local Keybind, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Keybind')

			Config:SetSizeT(100)

			local F = Instance.new("TextButton")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local UIPadding_1 = Instance.new("UIPadding")
			local ToggleValue_1 = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local Frame_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIPadding_2 = Instance.new("UIPadding")
			local KeybindValue_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local TextLabel_1 = Instance.new("TextLabel")
			local UIPadding_3 = Instance.new("UIPadding")

			F.Name = "F"
			F.Parent = Keybind
			F.AnchorPoint = Vector2.new(1, 0.5)
			F.BackgroundColor3 = Color3.fromRGB(255,255,255)
			F.BackgroundTransparency = 1
			F.BorderColor3 = Color3.fromRGB(0,0,0)
			F.BorderSizePixel = 0
			F.Position = UDim2.new(1, 0,0.5, 0)
			F.Size = UDim2.new(0, 100,0.800000012, 0)
			F.Text = ''

			UIListLayout_1.Parent = F
			UIListLayout_1.Padding = UDim.new(0,8)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			UIPadding_1.Parent = F
			UIPadding_1.PaddingRight = UDim.new(0,13)

			ToggleValue_1.Name = "ToggleValue"
			ToggleValue_1.Parent = F
			ToggleValue_1.BackgroundColor3 = Color3.fromRGB(44,34,103)
			ToggleValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ToggleValue_1.BorderSizePixel = 0
			ToggleValue_1.LayoutOrder = 1
			ToggleValue_1.Size = UDim2.new(0, 34,0, 17)

			UICorner_1.Parent = ToggleValue_1
			UICorner_1.CornerRadius = UDim.new(1,0)

			Frame_1.Parent = ToggleValue_1
			Frame_1.AnchorPoint = Vector2.new(1, 0.5)
			Frame_1.BackgroundColor3 = Color3.fromRGB(91,68,209)
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Position = UDim2.new(1, 0,0.5, 0)
			Frame_1.Size = UDim2.new(0, 13,0, 13)

			addToTheme('Main', Frame_1)

			UICorner_2.Parent = Frame_1
			UICorner_2.CornerRadius = UDim.new(1,0)

			UIPadding_2.Parent = ToggleValue_1
			UIPadding_2.PaddingLeft = UDim.new(0,2)
			UIPadding_2.PaddingRight = UDim.new(0,2)

			KeybindValue_1.Name = "KeybindValue"
			KeybindValue_1.Parent = F
			KeybindValue_1.BackgroundColor3 = Color3.fromRGB(24,24,31)
			KeybindValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
			KeybindValue_1.BorderSizePixel = 0
			KeybindValue_1.Size = UDim2.new(0, 30,0, 20)

			addToTheme('Function.Keybind.Value Background', KeybindValue_1)

			UICorner_3.Parent = KeybindValue_1
			UICorner_3.CornerRadius = UDim.new(0,4)

			UIStroke_1.Parent = KeybindValue_1
			UIStroke_1.Color = Color3.fromRGB(255,255,255)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.95

			addToTheme('Function.Keybind.Value Stroke', UIStroke_1)

			TextLabel_1.Parent = KeybindValue_1
			TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.BackgroundTransparency = 1
			TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_1.BorderSizePixel = 0
			TextLabel_1.Size = UDim2.new(1, 0,1, 0)
			TextLabel_1.Font = Enum.Font.GothamBold
			TextLabel_1.RichText = true
			TextLabel_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
			TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.TextSize = 10
			TextLabel_1.TextTransparency = 0.30000001192092896
			TextLabel_1.TextWrapped = true

			addToTheme('Text & Icon', TextLabel_1)

			UIPadding_3.Parent = KeybindValue_1
			UIPadding_3.PaddingLeft = UDim.new(0,5)
			UIPadding_3.PaddingRight = UDim.new(0,5)

			local Click = click(Keybind)
			KeybindValue_1.ZIndex = 2
			F.ZIndex = 2

			Value = not Value

			local function change()
				Value = not Value
				if Value then
					Config:SetTextTransparencyTitle(0)
					tw({v = ToggleValue_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundColor3 = themes[IsTheme].Function.Keybind.True['Toggle Background']}}):Play()
					tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out",
						g = {
							BackgroundColor3 = themes[IsTheme].Function.Keybind.True['Toggle Value'],
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0,0.5, 0)
						}}):Play()
				else
					Config:SetTextTransparencyTitle(0.7)
					tw({v = ToggleValue_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundColor3 = themes[IsTheme].Function.Keybind.False['Toggle Background']}}):Play()
					tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out",
						g = {
							BackgroundColor3 = themes[IsTheme].Function.Keybind.False['Toggle Value'],
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0,0.5, 0)
						}}):Play()
				end
			end

			Click.MouseButton1Click:Connect(change)

			delay(0.1, change)

			local changeing = false

			local function adjustBoxBindSize()
				local textSize = game:GetService("TextService"):GetTextSize(TextLabel_1.Text, TextLabel_1.TextSize, TextLabel_1.Font, Vector2.new(1000, 1000))
				tw({v = KeybindValue_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Size = UDim2.new(0, textSize.X + 20, 0, 20)}}):Play()
			end

			adjustBoxBindSize()

			local function changeKey()
				changeing = true
				TextLabel_1.Text = "..."
				local inputConnection
				inputConnection = U.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						Key = input.KeyCode
						TextLabel_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
						adjustBoxBindSize()
						inputConnection:Disconnect()
						pcall(Callback, Key, Value)
						task.wait(.1)
						changeing = false
					end
				end)
			end

			U.InputBegan:Connect(function(input, gameProcessed)
				if input.KeyCode == Key and not changeing then
					change()
					pcall(Callback, Key, Value)
				end
			end)

			delay(0, function()
				pcall(Callback, Key, Value)
			end)

			Keybind:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				if Value then
					ToggleValue_1.BackgroundColor3 = themes[IsTheme].Function.Keybind.True['Toggle Background']
					Frame_1.BackgroundColor3 = themes[IsTheme].Function.Keybind.True['Toggle Value']
				else
					ToggleValue_1.BackgroundColor3 = themes[IsTheme].Function.Keybind.False['Toggle Background']
					Frame_1.BackgroundColor3 = themes[IsTheme].Function.Keybind.False['Toggle Value']
				end
			end)

			F.MouseButton1Click:Connect(changeKey)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Keybind.Visible = t
			end

			function New:SetValue(t)
				Value = not t
				change()
			end

			function New:SetKey(t)
				Key = t
				TextLabel_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
				adjustBoxBindSize()
				pcall(Callback, Key, Value)
			end

			return New
		end

		function Func:ColorPicker(p)
			local Title = p.Title
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local Value = p.Value or Color3.fromRGB(255, 255, 255)
			local Callback = p.Callback or function() end

			local ColorPicker, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Color Picker')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(50)

			local ListFunctionColorPicker = Instance.new("Frame")
			local Picker_1 = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local GlowDot_1 = Instance.new("ImageLabel")
			local Picker_2 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIPadding_1 = Instance.new("UIPadding")

			ListFunctionColorPicker.Name = "ListFunctionColorPicker"
			ListFunctionColorPicker.Parent = ColorPicker
			ListFunctionColorPicker.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ListFunctionColorPicker.BackgroundTransparency = 1
			ListFunctionColorPicker.BorderColor3 = Color3.fromRGB(0,0,0)
			ListFunctionColorPicker.BorderSizePixel = 0
			ListFunctionColorPicker.Size = UDim2.new(1, 0,1, 0)

			Picker_1.Name = "Picker"
			Picker_1.Parent = ListFunctionColorPicker
			Picker_1.AnchorPoint = Vector2.new(1, 0.5)
			Picker_1.BackgroundColor3 = Value
			Picker_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Picker_1.BorderSizePixel = 0
			Picker_1.Position = UDim2.new(1, 0,0.5, 0)
			Picker_1.Size = UDim2.new(0, 20,0, 20)

			UICorner_1.Parent = Picker_1
			UICorner_1.CornerRadius = UDim.new(1,0)

			GlowDot_1.Name = "GlowDot"
			GlowDot_1.Parent = Picker_1
			GlowDot_1.AnchorPoint = Vector2.new(0.5, 0.5)
			GlowDot_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			GlowDot_1.BackgroundTransparency = 1
			GlowDot_1.BorderColor3 = Color3.fromRGB(0,0,0)
			GlowDot_1.BorderSizePixel = 0
			GlowDot_1.Position = UDim2.new(0.5, 0,0.5, 0)
			GlowDot_1.Size = UDim2.new(1.5, 0,1.5, 0)
			GlowDot_1.Image = "rbxassetid://105506802034513"
			GlowDot_1.ImageColor3 = Value
			GlowDot_1.ImageTransparency = 0.2

			Picker_2.Name = "Picker"
			Picker_2.Parent = GlowDot_1
			Picker_2.AnchorPoint = Vector2.new(0.5, 0.5)
			Picker_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Picker_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Picker_2.BorderSizePixel = 0
			Picker_2.Position = UDim2.new(0.5, 0,0.5, 0)
			Picker_2.Size = UDim2.new(0, 12,0, 12)

			UICorner_2.Parent = Picker_2
			UICorner_2.CornerRadius = UDim.new(1,0)

			UIPadding_1.Parent = ListFunctionColorPicker
			UIPadding_1.PaddingRight = UDim.new(0,10)

			local ColorpickBar = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local UIPadding_1 = Instance.new("UIPadding")
			local Color_1 = Instance.new("ImageLabel")
			local ColorCorner_1 = Instance.new("UICorner")
			local ColorSelection_1 = Instance.new("ImageLabel")
			local Hue_1 = Instance.new("ImageLabel")
			local HueCorner_1 = Instance.new("UICorner")
			local HueGradient_1 = Instance.new("UIGradient")
			local HueSelection_1 = Instance.new("ImageLabel")

			lak(ColorpickBar)

			ColorpickBar.Name = "ColorpickBar"
			ColorpickBar.Parent = ScreenGui
			ColorpickBar.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
			ColorpickBar.BorderColor3 = Color3.fromRGB(0,0,0)
			ColorpickBar.BorderSizePixel = 0
			ColorpickBar.Size = UDim2.new(0, 120,0, 0)
			ColorpickBar.ClipsDescendants = true
			local targetX = Picker_1.AbsolutePosition.X - ColorpickBar.Parent.AbsolutePosition.X + Picker_1.Size.X.Offset - 100
			local targetY = Picker_1.AbsolutePosition.Y - ColorpickBar.Parent.AbsolutePosition.Y + Picker_1.Size.Y.Offset - 20
			ColorpickBar.Position = UDim2.new(0, targetX, 0, targetY)

			addToTheme('Function.Color Picker.Color Select.Background', ColorpickBar)

			UICorner_1.Parent = ColorpickBar
			UICorner_1.CornerRadius = UDim.new(0, 6)

			UIStroke_1.Parent = ColorpickBar
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 1
			UIStroke_1.Color = Color3.fromRGB(255, 255, 255)
			UIStroke_1.Transparency = 0.95

			addToTheme('Function.Color Picker.Color Select.UIStroke', UIStroke_1)

			UIPadding_1.Parent = ColorpickBar
			UIPadding_1.PaddingBottom = UDim.new(0,5)
			UIPadding_1.PaddingLeft = UDim.new(0,10)
			UIPadding_1.PaddingRight = UDim.new(0,10)
			UIPadding_1.PaddingTop = UDim.new(0,5)

			Color_1.Name = "Color"
			Color_1.Parent = ColorpickBar
			Color_1.AnchorPoint = Vector2.new(0, 0)
			Color_1.BackgroundColor3 = Color3.fromRGB(39,39,39)
			Color_1.Position = UDim2.new(0, 0,0, 25)
			Color_1.Size = UDim2.new(0, 80,0, 80)
			Color_1.ZIndex = 10
			Color_1.Image = "rbxassetid://4155801252"

			ColorCorner_1.Name = "ColorCorner"
			ColorCorner_1.Parent = Color_1
			ColorCorner_1.CornerRadius = UDim.new(0,3)

			ColorSelection_1.Name = "ColorSelection"
			ColorSelection_1.Parent = Color_1
			ColorSelection_1.AnchorPoint = Vector2.new(0.5, 0.5)
			ColorSelection_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ColorSelection_1.BackgroundTransparency = 1
			ColorSelection_1.Size = UDim2.new(0, 12,0, 12)
			ColorSelection_1.Image = "http://www.roblox.com/asset/?id=4805639000"
			ColorSelection_1.ScaleType = Enum.ScaleType.Fit

			Hue_1.Name = "Hue"
			Hue_1.Parent = ColorpickBar
			Hue_1.AnchorPoint = Vector2.new(0, 0)
			Hue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Hue_1.Position = UDim2.new(0.47, 0,0, 25)
			Hue_1.Size = UDim2.new(0, 10,0, 80)

			HueCorner_1.Name = "HueCorner"
			HueCorner_1.Parent = Hue_1
			HueCorner_1.CornerRadius = UDim.new(1,0)

			HueGradient_1.Name = "HueGradient"
			HueGradient_1.Parent = Hue_1
			HueGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))}
			HueGradient_1.Rotation = 270

			HueSelection_1.Name = "HueSelection"
			HueSelection_1.Parent = Hue_1
			HueSelection_1.AnchorPoint = Vector2.new(0.5, 0.5)
			HueSelection_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			HueSelection_1.BackgroundTransparency = 1
			HueSelection_1.Position = UDim2.new(0.5, 0,1, 0)
			HueSelection_1.Size = UDim2.new(0, 12,0, 12)
			HueSelection_1.Image = "http://www.roblox.com/asset/?id=4805639000"

			local TitleColorPicker = Instance.new("TextLabel")

			TitleColorPicker.Name = "TitleColorPicker"
			TitleColorPicker.Parent = ColorpickBar
			TitleColorPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TitleColorPicker.BackgroundTransparency = 1.000
			TitleColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TitleColorPicker.BorderSizePixel = 0
			TitleColorPicker.Size = UDim2.new(1, 0, 0, 27)
			TitleColorPicker.Font = Enum.Font.GothamBold
			TitleColorPicker.Text = Title
			TitleColorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
			TitleColorPicker.TextSize = 12.000
			TitleColorPicker.TextXAlignment = Enum.TextXAlignment.Left
			TitleColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TitleColorPicker)

			local BoxColor = Instance.new("Frame")
			local Hax_1 = Instance.new("Frame")
			local BarValueHax_1 = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_11 = Instance.new("UIStroke")
			local TextLabel_1 = Instance.new("TextBox")
			local TextLabel_2 = Instance.new("TextLabel")
			local UIListLayoutBoxColor_1 = Instance.new("UIListLayout")
			local Red_1 = Instance.new("Frame")
			local BarValueRed_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIStroke_2 = Instance.new("UIStroke")
			local TextLabel_3 = Instance.new("TextBox")
			local TextLabel_4 = Instance.new("TextLabel")
			local Green_1 = Instance.new("Frame")
			local BarValueGreen_1 = Instance.new("Frame")
			local UICorner_3 = Instance.new("UICorner")
			local UIStroke_3 = Instance.new("UIStroke")
			local TextLabel_5 = Instance.new("TextBox")
			local TextLabel_6 = Instance.new("TextLabel")
			local Blue_1 = Instance.new("Frame")
			local BarValueBlue_1 = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local UIStroke_4 = Instance.new("UIStroke")
			local TextLabel_7 = Instance.new("TextBox")
			local TextLabel_8 = Instance.new("TextLabel")

			BoxColor.Name = "BoxColor"
			BoxColor.Parent = ColorpickBar
			BoxColor.AnchorPoint = Vector2.new(1, 0)
			BoxColor.BackgroundColor3 = Color3.fromRGB(255,255,255)
			BoxColor.BackgroundTransparency = 1
			BoxColor.BorderColor3 = Color3.fromRGB(0,0,0)
			BoxColor.BorderSizePixel = 0
			BoxColor.Position = UDim2.new(1, 0,0, 25)
			BoxColor.Size = UDim2.new(0, 80,0, 80)

			Hax_1.Name = "Hax"
			Hax_1.Parent = BoxColor
			Hax_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Hax_1.BackgroundTransparency = 1
			Hax_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Hax_1.BorderSizePixel = 0
			Hax_1.Size = UDim2.new(1, 0,0, 21)

			BarValueHax_1.Name = "BarValueHax"
			BarValueHax_1.Parent = Hax_1
			BarValueHax_1.AnchorPoint = Vector2.new(0, 0.5)
			BarValueHax_1.BackgroundColor3 = Color3.fromRGB(217,217,217)
			BarValueHax_1.BackgroundTransparency = 1
			BarValueHax_1.BorderColor3 = Color3.fromRGB(0,0,0)
			BarValueHax_1.BorderSizePixel = 0
			BarValueHax_1.Position = UDim2.new(0, 0,0.5, 0)
			BarValueHax_1.Size = UDim2.new(0.6, 0,0, 15)

			UICorner_1.Parent = BarValueHax_1
			UICorner_1.CornerRadius = UDim.new(1,0)

			UIStroke_11.Parent = BarValueHax_1
			UIStroke_11.Thickness = 1
			UIStroke_11.Color = Color3.fromRGB(255, 255, 255)
			UIStroke_11.Transparency = 0.95

			addToTheme('Function.Color Picker.Color Select.UIStroke', UIStroke_11)

			TextLabel_1.Name = "TextLabel"
			TextLabel_1.Parent = BarValueHax_1
			TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.BackgroundTransparency = 1
			TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_1.BorderSizePixel = 0
			TextLabel_1.Size = UDim2.new(1, 0,1, 0)
			TextLabel_1.Font = Enum.Font.Gotham
			TextLabel_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextLabel_1.PlaceholderText = "#FFFFFF"
			TextLabel_1.Text = "#FFFFFF"
			TextLabel_1.TextSize = 9
			TextLabel_1.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel_1.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_1)

			TextLabel_2.Parent = Hax_1
			TextLabel_2.AnchorPoint = Vector2.new(1, 0.5)
			TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_2.BackgroundTransparency = 1
			TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_2.BorderSizePixel = 0
			TextLabel_2.Position = UDim2.new(0.980000019, 0,0.5, 0)
			TextLabel_2.Size = UDim2.new(0, 20,0, 20)
			TextLabel_2.Font = Enum.Font.Gotham
			TextLabel_2.Text = "Hax"
			TextLabel_2.TextSize = 9
			TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_2)

			UIListLayoutBoxColor_1.Name = "UIListLayoutBoxColor"
			UIListLayoutBoxColor_1.Parent = BoxColor
			UIListLayoutBoxColor_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayoutBoxColor_1.VerticalAlignment = Enum.VerticalAlignment.Center

			Red_1.Name = "Red"
			Red_1.Parent = BoxColor
			Red_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Red_1.BackgroundTransparency = 1
			Red_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Red_1.BorderSizePixel = 0
			Red_1.LayoutOrder = 1
			Red_1.Size = UDim2.new(1, 0,0, 21)

			BarValueRed_1.Name = "BarValueRed"
			BarValueRed_1.Parent = Red_1
			BarValueRed_1.AnchorPoint = Vector2.new(0, 0.5)
			BarValueRed_1.BackgroundColor3 = Color3.fromRGB(217,217,217)
			BarValueRed_1.BackgroundTransparency = 1
			BarValueRed_1.BorderColor3 = Color3.fromRGB(0,0,0)
			BarValueRed_1.BorderSizePixel = 0
			BarValueRed_1.Position = UDim2.new(0, 0,0.5, 0)
			BarValueRed_1.Size = UDim2.new(0.600000024, 0,0, 15)

			UICorner_2.Parent = BarValueRed_1
			UICorner_2.CornerRadius = UDim.new(1,0)

			UIStroke_2.Parent = BarValueRed_1
			UIStroke_2.Thickness = 1
			UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
			UIStroke_2.Transparency = 0.95

			addToTheme('Function.Color Picker.Color Select.UIStroke', UIStroke_2)

			TextLabel_3.Name = "TextLabel"
			TextLabel_3.Parent = BarValueRed_1
			TextLabel_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_3.BackgroundTransparency = 1
			TextLabel_3.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_3.BorderSizePixel = 0
			TextLabel_3.Size = UDim2.new(1, 0,1, 0)
			TextLabel_3.Font = Enum.Font.Gotham
			TextLabel_3.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextLabel_3.PlaceholderText = "255"
			TextLabel_3.Text = "255"
			TextLabel_3.TextSize = 9
			TextLabel_3.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_3)

			TextLabel_4.Parent = Red_1
			TextLabel_4.AnchorPoint = Vector2.new(1, 0.5)
			TextLabel_4.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_4.BackgroundTransparency = 1
			TextLabel_4.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_4.BorderSizePixel = 0
			TextLabel_4.Position = UDim2.new(0.980000019, 0,0.5, 0)
			TextLabel_4.Size = UDim2.new(0, 20,0, 20)
			TextLabel_4.Font = Enum.Font.Gotham
			TextLabel_4.Text = "Red"
			TextLabel_4.TextSize = 9
			TextLabel_4.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_4.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_4)

			Green_1.Name = "Green"
			Green_1.Parent = BoxColor
			Green_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Green_1.BackgroundTransparency = 1
			Green_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Green_1.BorderSizePixel = 0
			Green_1.LayoutOrder = 2
			Green_1.Size = UDim2.new(1, 0,0, 21)

			BarValueGreen_1.Name = "BarValueGreen"
			BarValueGreen_1.Parent = Green_1
			BarValueGreen_1.AnchorPoint = Vector2.new(0, 0.5)
			BarValueGreen_1.BackgroundColor3 = Color3.fromRGB(217,217,217)
			BarValueGreen_1.BackgroundTransparency = 1
			BarValueGreen_1.BorderColor3 = Color3.fromRGB(0,0,0)
			BarValueGreen_1.BorderSizePixel = 0
			BarValueGreen_1.Position = UDim2.new(0, 0,0.5, 0)
			BarValueGreen_1.Size = UDim2.new(0.600000024, 0,0, 15)

			UICorner_3.Parent = BarValueGreen_1
			UICorner_3.CornerRadius = UDim.new(1,0)

			UIStroke_3.Parent = BarValueGreen_1
			UIStroke_3.Thickness = 1
			UIStroke_3.Color = Color3.fromRGB(255, 255, 255)
			UIStroke_3.Transparency = 0.95

			addToTheme('Function.Color Picker.Color Select.UIStroke', UIStroke_3)

			TextLabel_5.Name = "TextLabel"
			TextLabel_5.Parent = BarValueGreen_1
			TextLabel_5.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_5.BackgroundTransparency = 1
			TextLabel_5.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_5.BorderSizePixel = 0
			TextLabel_5.Size = UDim2.new(1, 0,1, 0)
			TextLabel_5.Font = Enum.Font.Gotham
			TextLabel_5.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextLabel_5.PlaceholderText = "255"
			TextLabel_5.Text = "255"
			TextLabel_5.TextSize = 9
			TextLabel_5.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel_5.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_5)

			TextLabel_6.Parent = Green_1
			TextLabel_6.AnchorPoint = Vector2.new(1, 0.5)
			TextLabel_6.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_6.BackgroundTransparency = 1
			TextLabel_6.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_6.BorderSizePixel = 0
			TextLabel_6.Position = UDim2.new(0.980000019, 0,0.5, 0)
			TextLabel_6.Size = UDim2.new(0, 20,0, 20)
			TextLabel_6.Font = Enum.Font.Gotham
			TextLabel_6.Text = "Green"
			TextLabel_6.TextSize = 9
			TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_6.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_6)

			Blue_1.Name = "Blue"
			Blue_1.Parent = BoxColor
			Blue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Blue_1.BackgroundTransparency = 1
			Blue_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Blue_1.BorderSizePixel = 0
			Blue_1.LayoutOrder = 3
			Blue_1.Size = UDim2.new(1, 0,0, 21)

			BarValueBlue_1.Name = "BarValueBlue"
			BarValueBlue_1.Parent = Blue_1
			BarValueBlue_1.AnchorPoint = Vector2.new(0, 0.5)
			BarValueBlue_1.BackgroundColor3 = Color3.fromRGB(217,217,217)
			BarValueBlue_1.BackgroundTransparency = 1
			BarValueBlue_1.BorderColor3 = Color3.fromRGB(0,0,0)
			BarValueBlue_1.BorderSizePixel = 0
			BarValueBlue_1.Position = UDim2.new(0, 0,0.5, 0)
			BarValueBlue_1.Size = UDim2.new(0.600000024, 0,0, 15)

			UICorner_4.Parent = BarValueBlue_1
			UICorner_4.CornerRadius = UDim.new(1,0)

			UIStroke_4.Parent = BarValueBlue_1
			UIStroke_4.Thickness = 1
			UIStroke_4.Color = Color3.fromRGB(255, 255, 255)
			UIStroke_4.Transparency = 0.95

			addToTheme('Function.Color Picker.Color Select.UIStroke', UIStroke_4)

			TextLabel_7.Name = "TextLabel"
			TextLabel_7.Parent = BarValueBlue_1
			TextLabel_7.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_7.BackgroundTransparency = 1
			TextLabel_7.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_7.BorderSizePixel = 0
			TextLabel_7.Size = UDim2.new(1, 0,1, 0)
			TextLabel_7.Font = Enum.Font.Gotham
			TextLabel_7.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextLabel_7.PlaceholderText = "255"
			TextLabel_7.Text = "255"
			TextLabel_7.TextSize = 9
			TextLabel_7.TextTruncate = Enum.TextTruncate.AtEnd
			TextLabel_7.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_7)

			TextLabel_8.Parent = Blue_1
			TextLabel_8.AnchorPoint = Vector2.new(1, 0.5)
			TextLabel_8.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_8.BackgroundTransparency = 1
			TextLabel_8.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_8.BorderSizePixel = 0
			TextLabel_8.Position = UDim2.new(0.980000019, 0,0.5, 0)
			TextLabel_8.Size = UDim2.new(0, 20,0, 20)
			TextLabel_8.Font = Enum.Font.Gotham
			TextLabel_8.Text = "Blue"
			TextLabel_8.TextSize = 9
			TextLabel_8.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_8.TextColor3 = Color3.fromRGB(255, 255, 255)

			addToTheme('Text & Icon', TextLabel_8)

			local Shower = Instance.new("Frame")
			local UICornerShow = Instance.new("UICorner")
			local GlowDotShow = Instance.new("ImageLabel")

			Shower.Name = "Shower"
			Shower.Parent = ColorpickBar
			Shower.AnchorPoint = Vector2.new(1, 0)
			Shower.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			Shower.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Shower.BorderSizePixel = 0
			Shower.Position = UDim2.new(1, 0, 0.0500000007, 0)
			Shower.Size = UDim2.new(0, 40, 0, 15)

			UICornerShow.CornerRadius = UDim.new(1, 0)
			UICornerShow.Name = "UICornerShow"
			UICornerShow.Parent = Shower

			GlowDotShow.Name = "GlowDotShow"
			GlowDotShow.Parent = Shower
			GlowDotShow.AnchorPoint = Vector2.new(0.5, 0.5)
			GlowDotShow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			GlowDotShow.BackgroundTransparency = 1.000
			GlowDotShow.BorderColor3 = Color3.fromRGB(0, 0, 0)
			GlowDotShow.BorderSizePixel = 0
			GlowDotShow.Position = UDim2.new(0.5, 0, 0.5, 0)
			GlowDotShow.Size = UDim2.new(1.25, 0, 1.5, 0)
			GlowDotShow.Image = "rbxassetid://105506802034513"
			GlowDotShow.ImageColor3 = Color3.fromRGB(255, 0, 0)
			GlowDotShow.ImageTransparency = 0.200

			local Click = click(ColorPicker)
			local ClickColor = click(Color_1)
			local ClickHue = click(Hue_1)
			local isopen = false

			local ColorH, ColorS, ColorV = 1, 1, 1
			local lastColorH = -1
			local ColorInput = nil
			local HueInput = nil
			local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local lastColor = nil
			local ColorInput = nil
			local HueInput = nil
			local isTouchDevice = U.TouchEnabled

			local function open()
				local targetX = Picker_1.AbsolutePosition.X - ColorpickBar.Parent.AbsolutePosition.X + Picker_1.Size.X.Offset - 145
				local targetY = Picker_1.AbsolutePosition.Y - ColorpickBar.Parent.AbsolutePosition.Y + Picker_1.Size.Y.Offset - 50
				tw({v = ColorpickBar, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 200,0, 125), Position = UDim2.new(0, targetX, 0, targetY)}}):Play()
				tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 0.95}}):Play()
			end
			local function close()
				isopen = false
				tw({v = ColorpickBar, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(0, 200,0, 0)}}):Play()
				tw({v = UIStroke_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {Transparency = 1}}):Play()
			end

			U.InputBegan:Connect(function(A)
				if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
					local B, C = ColorpickBar.AbsolutePosition, ColorpickBar.AbsoluteSize
					if game:GetService "Players".LocalPlayer:GetMouse().X < B.X or game:GetService "Players".LocalPlayer:GetMouse().X > B.X + C.X or game:GetService "Players".LocalPlayer:GetMouse().Y < (B.Y - 20 - 1) or game:GetService "Players".LocalPlayer:GetMouse().Y > B.Y + C.Y then
						close()
					end
				end
			end)

			Click.MouseButton1Click:Connect(function()
				isopen = not isopen
				if isopen then
					open()
				else
					close()
				end
			end)

			local function UpdateColorPicker(nope)
				Picker_1.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				GlowDot_1.ImageColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				Color_1.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)

				Shower.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				GlowDotShow.ImageColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)

				local r, g, b = Picker_1.BackgroundColor3.R * 255, Picker_1.BackgroundColor3.G * 255, Picker_1.BackgroundColor3.B * 255

				TextLabel_3.Text = tostring(math.floor(r))
				TextLabel_5.Text = tostring(math.floor(g))
				TextLabel_7.Text = tostring(math.floor(b))

				local hex = string.format("#%02X%02X%02X", math.floor(r), math.floor(g), math.floor(b))
				TextLabel_1.Text = hex

				ColorH, ColorS, ColorV = Color3.toHSV(Picker_1.BackgroundColor3)

				if ColorS ~= 0 and ColorV ~= 0 then
					tw({v = ColorSelection_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)}}):Play()
				end
				if lastColorH ~= ColorH and ColorS ~= 0 and ColorV ~= 0 and ColorS ~= 255 and ColorV ~= 255 then
					lastColorH = ColorH
					tw({v = HueSelection_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(0.5, 0, 1 - ColorH, 0)}}):Play()
				end

				if lastColor ~= Picker_1.BackgroundColor3 then
					lastColor = Picker_1.BackgroundColor3
					pcall(Callback, math.floor(r), math.floor(g), math.floor(b))
				end
			end

			local function HexToRGB(hex)
				if hex:sub(1, 1) == "#" then
					hex = hex:sub(2)
				end

				if #hex == 6 then
					local r = tonumber(hex:sub(1, 2), 16) / 255
					local g = tonumber(hex:sub(3, 4), 16) / 255
					local b = tonumber(hex:sub(5, 6), 16) / 255
					return r, g, b
				else
					return 0, 0, 0
				end
			end

			local function UpdateColorFromText()
				local hex = TextLabel_1.Text:match("^#[%x]+$")
				if hex then
					local r, g, b = HexToRGB(hex)
					r = math.clamp(r, 0, 1)
					g = math.clamp(g, 0, 1)
					b = math.clamp(b, 0, 1)

					local h, s, v = Color3.toHSV(Color3.new(r, g, b))
					ColorH, ColorS, ColorV = h, s, v
					UpdateColorPicker(true)
				else
					local r = tonumber(TextLabel_3.Text) or 0
					local g = tonumber(TextLabel_5.Text) or 0
					local b = tonumber(TextLabel_7.Text) or 0

					r = math.clamp(r, 0, 255) / 255
					g = math.clamp(g, 0, 255) / 255
					b = math.clamp(b, 0, 255) / 255

					local h, s, v = Color3.toHSV(Color3.new(r, g, b))
					ColorH, ColorS, ColorV = h, s, v
					UpdateColorPicker(true)
				end
			end

			TextLabel_3.FocusLost:Connect(UpdateColorFromText)
			TextLabel_5.FocusLost:Connect(UpdateColorFromText)
			TextLabel_7.FocusLost:Connect(UpdateColorFromText)
			TextLabel_1.FocusLost:Connect(UpdateColorFromText)


			ColorH = 1 - (math.clamp(HueSelection_1.AbsolutePosition.Y - Hue_1.AbsolutePosition.Y, 0, Hue_1.AbsoluteSize.Y) / Hue_1.AbsoluteSize.Y)
			ColorS = (math.clamp(ColorSelection_1.AbsolutePosition.X - Color_1.AbsolutePosition.X, 0, Color_1.AbsoluteSize.X) / Color_1.AbsoluteSize.X)
			ColorV = 1 - (math.clamp(ColorSelection_1.AbsolutePosition.Y - Color_1.AbsolutePosition.Y, 0, Color_1.AbsoluteSize.Y) / Color_1.AbsoluteSize.Y)

			Picker_1.BackgroundColor3 = Value
			Color_1.BackgroundColor3 = Value

			ClickColor.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if ColorInput then
						ColorInput:Disconnect()
					end

					ColorInput = game:GetService("RunService").RenderStepped:Connect(function()
						local ColorX = (math.clamp(Mouse.X - Color_1.AbsolutePosition.X, 0, Color_1.AbsoluteSize.X) /Color_1.AbsoluteSize.X)
						local ColorY = (math.clamp(Mouse.Y - Color_1.AbsolutePosition.Y, 0, Color_1.AbsoluteSize.Y) /Color_1.AbsoluteSize.Y)

						tw({v = ColorSelection_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(ColorX, 0, ColorY, 0)}}):Play()
						ColorS = ColorX
						ColorV = 1 - ColorY

						UpdateColorPicker(true)
					end)
				end
			end)

			ClickColor.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if ColorInput then
						ColorInput:Disconnect()
					end
				end
			end)

			ClickHue.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if HueInput then
						HueInput:Disconnect()
					end

					HueInput = game:GetService("RunService").RenderStepped:Connect(function()
						local HueY = (math.clamp(Mouse.Y - Hue_1.AbsolutePosition.Y, 0, Hue_1.AbsoluteSize.Y) /Hue_1.AbsoluteSize.Y)
						tw({v = HueSelection_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Position = UDim2.new(0.5, 0, HueY, 0)}}):Play()
						ColorH = 1 - HueY

						UpdateColorPicker(true)
					end)
				end
			end)

			ClickHue.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if HueInput then
						HueInput:Disconnect()
					end
				end
			end)

			if isTouchDevice then
				Color_1.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then
							ColorInput:Disconnect()
						end

						ColorInput = game:GetService("RunService").RenderStepped:Connect(function()
							local ColorX = (math.clamp(Mouse.X - Color_1.AbsolutePosition.X, 0, Color_1.AbsoluteSize.X) / Color_1.AbsoluteSize.X)
							local ColorY = (math.clamp(Mouse.Y - Color_1.AbsolutePosition.Y, 0, Color_1.AbsoluteSize.Y) / Color_1.AbsoluteSize.Y)

							ColorSelection_1.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY

							UpdateColorPicker(true)
						end)
					end
				end)

				Color_1.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						if ColorInput then
							ColorInput:Disconnect()
						end
					end
				end)

				Hue_1.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then
							HueInput:Disconnect()
						end

						HueInput = game:GetService("RunService").RenderStepped:Connect(function()
							local HueY = (math.clamp(Mouse.Y - Hue_1.AbsolutePosition.Y, 0, Hue_1.AbsoluteSize.Y) / Hue_1.AbsoluteSize.Y)

							HueSelection_1.Position = UDim2.new(0.48, 0, HueY, 0)
							ColorH = 1 - HueY

							UpdateColorPicker(true)
						end)
					end
				end)

				Hue_1.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						if HueInput then
							HueInput:Disconnect()
						end
					end
				end)
			end

			delay(0,function()
				ColorH, ColorS, ColorV = Color3.toHSV(Picker_1.BackgroundColor3)
				UpdateColorPicker(true)
				local r, g, b = Picker_1.BackgroundColor3.R * 255, Picker_1.BackgroundColor3.G * 255, Picker_1.BackgroundColor3.B * 255
				pcall(Callback, math.floor(r), math.floor(g), math.floor(b))
			end)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				ColorPicker.Visible = t
			end

			function New:SetValue(colorTable)
				local r = colorTable.R or Picker_1.BackgroundColor3.R * 255
				local g = colorTable.G or Picker_1.BackgroundColor3.G * 255
				local b = colorTable.B or Picker_1.BackgroundColor3.B * 255

				if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
					local newColor = Color3.fromRGB(r, g, b)

					Picker_1.BackgroundColor3 = newColor
					Color_1.BackgroundColor3 = newColor

					local h, s, v = Color3.toHSV(newColor)
					ColorH, ColorS, ColorV = h, s, v

					ColorSelection_1.Position = UDim2.new(s, 0, 1 - v, 0)
					HueSelection_1.Position = UDim2.new(0.48, 0, 1 - h, 0)
					pcall(Callback, r, g, b)
				end
			end

			return New
		end

		function Func:Textbox(p)
			local Title = p.Title
			local Desc = p.Desc or ''
			local Image = p.Image or ''
			local Value = p.Value or ''
			local Placeholder = p.Placeholder or 'Paste Your Text'
			local ClearText = p.ClearText or p.ClearTextOnFocus or false
			local Callback = p.Callback or function() end

			local Textbox, Config = background(ScrollingFrame_1, Title, Desc, Image, 'Textbox')

			Config:SetTextTransparencyTitle(0)
			Config:SetSizeT(145)

			local F = Instance.new("Frame")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local UIPadding_1 = Instance.new("UIPadding")
			local Frame_1 = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local UIPadding_2 = Instance.new("UIPadding")
			local ImageLabel_1 = Instance.new("ImageLabel")
			local TextLabel_1 = Instance.new("TextBox")
			local Frame_2 = Instance.new("Frame")

			F.Name = "F"
			F.Parent = Textbox
			F.AnchorPoint = Vector2.new(1, 0.5)
			F.BackgroundColor3 = Color3.fromRGB(255,255,255)
			F.BackgroundTransparency = 1
			F.BorderColor3 = Color3.fromRGB(0,0,0)
			F.BorderSizePixel = 0
			F.Position = UDim2.new(1, 0,0.5, 0)
			F.Size = UDim2.new(0, 150,0.800000012, 0)

			UIListLayout_1.Parent = F
			UIListLayout_1.Padding = UDim.new(0,15)
			UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

			UIPadding_1.Parent = F
			UIPadding_1.PaddingRight = UDim.new(0,13)

			Frame_1.Parent = F
			Frame_1.BackgroundColor3 = Color3.fromRGB(24,24,31)
			Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Size = UDim2.new(0, 130,0, 25)

			addToTheme('Function.Textbox.Value Background', Frame_1)

			UICorner_1.Parent = Frame_1
			UICorner_1.CornerRadius = UDim.new(0,4)

			UIStroke_1.Parent = Frame_1
			UIStroke_1.Color = Color3.fromRGB(255,255,255)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.95

			addToTheme('Function.Textbox.Value Stroke', UIStroke_1)

			UIPadding_2.Parent = Frame_1
			UIPadding_2.PaddingLeft = UDim.new(0,5)
			UIPadding_2.PaddingRight = UDim.new(0,5)

			ImageLabel_1.Parent = Frame_1
			ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
			ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			ImageLabel_1.BackgroundTransparency = 1
			ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			ImageLabel_1.BorderSizePixel = 0
			ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
			ImageLabel_1.Size = UDim2.new(0, 15,0, 15)
			ImageLabel_1.Image = "rbxassetid://13868675087"
			ImageLabel_1.ImageTransparency = 0.30000001192092896

			addToTheme('Text & Value', ImageLabel_1)

			TextLabel_1.Name = "TextLabel"
			TextLabel_1.Parent = Frame_1
			TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.BackgroundTransparency = 1
			TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
			TextLabel_1.BorderSizePixel = 0
			TextLabel_1.Size = UDim2.new(0.800000012, 0,1, 0)
			TextLabel_1.Font = Enum.Font.GothamBold
			TextLabel_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
			TextLabel_1.PlaceholderText = Placeholder
			TextLabel_1.RichText = true
			TextLabel_1.Text = Value
			TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
			TextLabel_1.TextSize = 10
			TextLabel_1.TextTransparency = 0.30000001192092896
			TextLabel_1.TextWrapped = true
			TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_1.ClearTextOnFocus = not ClearText

			addToTheme('Text & Value', TextLabel_1)

			Frame_2.Parent = Frame_1
			Frame_2.AnchorPoint = Vector2.new(0.5, 1)
			Frame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Frame_2.BackgroundTransparency = 0.949999988079071
			Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Frame_2.BorderSizePixel = 0
			Frame_2.Position = UDim2.new(0.5, 0,1, 0)
			Frame_2.Size = UDim2.new(1.05, 0,0, 2)

			local function o()
				if #TextLabel_1.Text > 0 then
					pcall(Callback, TextLabel_1.Text)
				end
			end

			TextLabel_1.FocusLost:Connect(o)

			delay(0, o)

			local New = {}

			function New:SetTitle(t)
				Config:SetTitle(t)
			end

			function New:SetDesc(t)
				Config:SetDesc(t)
			end

			function New:SetVisible(t)
				Textbox.Visible = t
			end

			function New:SetValue(t)
				TextLabel_1.Text = t
			end

			function New:SetClearTextOnFocus(t)
				TextLabel_1.ClearTextOnFocus = not t
			end

			function New:SetPlaceholderText(t)
				TextLabel_1.PlaceholderText = t
			end

			return New
		end

		function Func:Image()
			local ImageLogo = Instance.new("ImageLabel")
			local UICorner_1 = Instance.new("UICorner")
			ImageLogo.Name = "Im"
			ImageLogo.Parent = ScrollingFrame_1
			ImageLogo.AnchorPoint = Vector2.new(0.5,0.5)
			ImageLogo.Position = UDim2.new(0.5,0,0.5,0)
			ImageLogo.BackgroundTransparency = 1
			ImageLogo.Size = UDim2.new(1,0,180,0)
			ImageLogo.Image = 'rbxassetid://111362591084511'
			ImageLogo.ScaleType = Enum.ScaleType.Crop
			UICorner_1.Parent = ImageLogo
			UICorner_1.CornerRadius = UDim.new(0,3)
		end

		return Func
	end

	local Notification = Instance.new("Frame")
	local UIPaddingUIListLayoutNotification_1 = Instance.new("UIPadding")
	local UIListLayoutNotification_1 = Instance.new("UIListLayout")

	Notification.Name = "Notification"
	Notification.Parent = ScreenGui
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Notification.BackgroundTransparency = 1
	Notification.BorderColor3 = Color3.fromRGB(0,0,0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, 0,1, 0)
	Notification.Size = UDim2.new(0, 100,0, 100)

	UIPaddingUIListLayoutNotification_1.Parent = Notification
	UIPaddingUIListLayoutNotification_1.PaddingBottom = UDim.new(0,20)
	UIPaddingUIListLayoutNotification_1.PaddingRight = UDim.new(0,5)

	UIListLayoutNotification_1.Parent = Notification
	UIListLayoutNotification_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayoutNotification_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayoutNotification_1.VerticalAlignment = Enum.VerticalAlignment.Bottom

	function Tabs:Notify(p)
		local Title = p.Title or 'null'
		local Desc = p.Desc or ''
		local Time = p.Time or 5

		local Shadow = Instance.new("ImageLabel")
		local UIPadding_1 = Instance.new("UIPadding")
		local Background_1 = Instance.new("CanvasGroup")
		local UICorner_1 = Instance.new("UICorner")
		local Frame_1 = Instance.new("Frame")
		local Text_1 = Instance.new("Frame")
		local UIPadding_2 = Instance.new("UIPadding")
		local Title_1 = Instance.new("TextLabel")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local Description_1 = Instance.new("TextLabel")
		local Frame_2 = Instance.new("Frame")

		Shadow.Name = "Shadow"
		Shadow.Parent = Notification
		Shadow.BackgroundColor3 = Color3.fromRGB(163,162,165)
		Shadow.BackgroundTransparency = 1
		Shadow.Size = UDim2.new(0, 180,0, 0)
		Shadow.Image = "rbxassetid://1316045217"
		Shadow.ImageColor3 = themes[IsTheme].Shadow
		Shadow.ImageTransparency = 0.5
		Shadow.ScaleType = Enum.ScaleType.Slice
		Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

		addToTheme('Shadow', Shadow)

		UIPadding_1.Parent = Shadow
		UIPadding_1.PaddingBottom = UDim.new(0,5)
		UIPadding_1.PaddingLeft = UDim.new(0,5)
		UIPadding_1.PaddingRight = UDim.new(0,5)
		UIPadding_1.PaddingTop = UDim.new(0,5)

		Background_1.Name = "Background"
		Background_1.Parent = Shadow
		Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Background_1.BackgroundColor3 = themes[IsTheme].Background
		Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Background_1.BorderSizePixel = 0
		Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Background_1.Size = UDim2.new(1, 0,1, 0)
		Background_1.ClipsDescendants = true
		Background_1.GroupTransparency = 1

		addToTheme('Background', Background_1)

		UICorner_1.Parent = Background_1
		UICorner_1.CornerRadius = UDim.new(0,6)

		Frame_1.Parent = Background_1
		Frame_1.AnchorPoint = Vector2.new(0, 1)
		Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_1.BackgroundTransparency = 0.8999999761581421
		Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_1.BorderSizePixel = 0
		Frame_1.Position = UDim2.new(0, 0,1, 0)
		Frame_1.Size = UDim2.new(1, 0,0, 4)

		Text_1.Name = "Text"
		Text_1.Parent = Background_1
		Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Text_1.BackgroundTransparency = 1
		Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Text_1.BorderSizePixel = 0
		Text_1.Size = UDim2.new(1, 0,1, 0)

		UIPadding_2.Parent = Text_1
		UIPadding_2.PaddingBottom = UDim.new(0,5)
		UIPadding_2.PaddingLeft = UDim.new(0,5)
		UIPadding_2.PaddingRight = UDim.new(0,5)
		UIPadding_2.PaddingTop = UDim.new(0,5)

		Title_1.Name = "Title"
		Title_1.Parent = Text_1
		Title_1.AutomaticSize = Enum.AutomaticSize.Y
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.Size = UDim2.new(1, 0,0, 0)
		Title_1.Font = Enum.Font.GothamBold
		Title_1.Text = tostring(Title)
		Title_1.TextColor3 = themes[IsTheme]['Text & Icon']
		Title_1.TextSize = 12
		Title_1.TextWrapped = true
		Title_1.RichText = true
		Title_1.TextXAlignment = Enum.TextXAlignment.Left
		Title_1.TextYAlignment = Enum.TextYAlignment.Top

		addToTheme('Text & Icon', Title_1)

		UIListLayout_1.Parent = Text_1
		UIListLayout_1.Padding = UDim.new(0,3)
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

		Description_1.Name = "Description"
		Description_1.Parent = Text_1
		Description_1.AutomaticSize = Enum.AutomaticSize.Y
		Description_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Description_1.BackgroundTransparency = 1
		Description_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Description_1.BorderSizePixel = 0
		Description_1.LayoutOrder = 2
		Description_1.Size = UDim2.new(1, 0,0, 0)
		Description_1.Font = Enum.Font.GothamBold
		Description_1.Text = tostring(Desc)
		Description_1.TextColor3 = themes[IsTheme]['Text & Icon']
		Description_1.TextSize = 10
		Description_1.TextTransparency = 0.5
		Description_1.TextWrapped = true
		Description_1.RichText = true
		Description_1.TextXAlignment = Enum.TextXAlignment.Left
		Description_1.TextYAlignment = Enum.TextYAlignment.Top
		Description_1.Visible = false

		addToTheme('Text & Icon', Description_1)

		Frame_2.Parent = Text_1
		Frame_2.BackgroundColor3 = themes[IsTheme]['Text & Icon']
		Frame_2.BackgroundTransparency = 0.9
		Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_2.BorderSizePixel = 0
		Frame_2.LayoutOrder = 1
		Frame_2.Size = UDim2.new(1, 0,0, 1)
		Frame_2.Visible = false

		addToTheme('Text & Icon', Frame_2)

		Background_1.Size = UDim2.new(1, 0,1, 0) - UDim2.fromOffset(5, 5)

		if Desc and Desc ~= '' then
			Description_1.Visible = true
			Frame_2.Visible = true
		end

		local function updateSize()
			task.defer(function()
				local newSize = UIListLayout_1.AbsoluteContentSize.Y + 28
				if Shadow.Size.Y.Offset ~= newSize then
					Shadow.Size = UDim2.new(0, 180, 0, newSize)
				end
			end)
		end

		delay(.1, updateSize)

		UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

		local g = tw({
			v = Shadow,
			t = 0.15,
			s = Enum.EasingStyle.Exponential,
			d = "InOut",
			g = {
				Size = UDim2.new(0, 180,0, 55)
			}
		})
		g:Play()
		g.Completed:Wait()
		tw({
			v = Background_1,
			t = 0.15,
			s = Enum.EasingStyle.Linear,
			d = "InOut",
			g = {
				Size = UDim2.new(1, 0,1, 0),
				GroupTransparency = 0.3
			}
		}):Play()

		task.spawn(function()
			for i = Time, 1, -1 do
				tw({v = Frame_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = UDim2.new(i / Time, 0,0, 4)}}):Play()
				task.wait(1)
			end
			local f = tw({
				v = Background_1,
				t = 0.15,
				s = Enum.EasingStyle.Linear,
				d = "InOut",
				g = {
					Size = UDim2.new(1, 0,1, 0) - UDim2.fromOffset(5, 5),
					GroupTransparency = 1
				}
			})
			f:Play()
			f.Completed:Connect(function()
				Shadow.ImageTransparency = 1
				local g = tw({
					v = Shadow,
					t = 0.15,
					s = Enum.EasingStyle.Exponential,
					d = "InOut",
					g = {
						Size = UDim2.new(0, 180,0, 0)
					}
				})
				g:Play()
				g.Completed:Connect(function()
					Shadow:Destroy()
				end)
			end)
		end)
	end

	function Tabs:Dialog(p)
		if Shadow_1:FindFirstChild('Dialog') then
			return
		end
		local Button1 = p.Button1.Callback or function() end
		local Button2 = p.Button2.Callback or function() end
		local Title = p.Title or 'null'
		local TitleButton1 = p.Button1.Title or 'null'
		local TitleButton2 = p.Button2.Title or 'null'
		local Color1 = p.Button1.Color or Color3.fromRGB(0, 188, 0)
		local Color2 = p.Button2.Color or Color3.fromRGB(226, 39, 6)

		local Dialog = Instance.new("CanvasGroup")
		local UICorner_1 = Instance.new("UICorner")
		local Frame_1 = Instance.new("Frame")
		local TextLabel_1 = Instance.new("TextLabel")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local Frame_2 = Instance.new("Frame")
		local Button1_1 = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIGradient_1 = Instance.new("UIGradient")
		local UIStroke_1 = Instance.new("UIStroke")
		local UIGradient_2 = Instance.new("UIGradient")
		local TextLabel_2 = Instance.new("TextLabel")
		local UIStroke_2 = Instance.new("UIStroke")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local Button2_1 = Instance.new("Frame")
		local UICorner_3 = Instance.new("UICorner")
		local UIGradient_3 = Instance.new("UIGradient")
		local UIStroke_3 = Instance.new("UIStroke")
		local UIGradient_4 = Instance.new("UIGradient")
		local TextLabel_3 = Instance.new("TextLabel")
		local UIStroke_4 = Instance.new("UIStroke")

		Dialog.Name = "Dialog"
		Dialog.Parent = Shadow_1
		Dialog.BackgroundColor3 = Color3.fromRGB(0,0,0)
		Dialog.BackgroundTransparency = 0.3
		Dialog.BorderColor3 = Color3.fromRGB(0,0,0)
		Dialog.BorderSizePixel = 0
		Dialog.Size = UDim2.new(1, 0,1, 0)
		Dialog.GroupTransparency = 1

		UICorner_1.Parent = Dialog
		UICorner_1.CornerRadius = UDim.new(0,17)

		Frame_1.Parent = Dialog
		Frame_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_1.BackgroundTransparency = 1
		Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_1.BorderSizePixel = 0
		Frame_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Frame_1.Size = UDim2.new(0, 100,0, 100)

		TextLabel_1.Parent = Frame_1
		TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.BackgroundTransparency = 1
		TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_1.BorderSizePixel = 0
		TextLabel_1.Size = UDim2.new(0, 200,0, 30)
		TextLabel_1.Font = Enum.Font.GothamBold
		TextLabel_1.RichText = true
		TextLabel_1.Text = tostring(Title)
		TextLabel_1.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabel_1.TextSize = 20

		UIListLayout_1.Parent = Frame_1
		UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

		Frame_2.Parent = Frame_1
		Frame_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Frame_2.BackgroundTransparency = 1
		Frame_2.BorderColor3 = Color3.fromRGB(0,0,0)
		Frame_2.BorderSizePixel = 0
		Frame_2.LayoutOrder = 1
		Frame_2.Size = UDim2.new(0, 100,0, 50)

		Button1_1.Name = "Button1"
		Button1_1.Parent = Frame_2
		Button1_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Button1_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Button1_1.BorderSizePixel = 0
		Button1_1.Size = UDim2.new(0, 130,0, 40)

		UICorner_2.Parent = Button1_1
		UICorner_2.CornerRadius = UDim.new(1,0)

		UIGradient_1.Parent = Button1_1
		UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 124, 124))}

		UIStroke_1.Parent = Button1_1
		UIStroke_1.Color = Color3.fromRGB(255,255,255)
		UIStroke_1.Thickness = 2

		UIGradient_2.Parent = UIStroke_1
		UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 124, 124))}
		UIGradient_2.Rotation = 180

		TextLabel_2.Parent = Button1_1
		TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_2.BackgroundTransparency = 1
		TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_2.BorderSizePixel = 0
		TextLabel_2.Size = UDim2.new(1, 0,1, 0)
		TextLabel_2.Font = Enum.Font.GothamBold
		TextLabel_2.Text = TitleButton1
		TextLabel_2.TextColor3 = Color1
		TextLabel_2.TextSize = 16

		UIStroke_2.Parent = TextLabel_2
		UIStroke_2.Thickness = 1
		UIStroke_2.Transparency = 0.95

		UIListLayout_2.Parent = Frame_2
		UIListLayout_2.Padding = UDim.new(0,10)
		UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

		Button2_1.Name = "Button2"
		Button2_1.Parent = Frame_2
		Button2_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Button2_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Button2_1.BorderSizePixel = 0
		Button2_1.Size = UDim2.new(0, 130,0, 40)

		UICorner_3.Parent = Button2_1
		UICorner_3.CornerRadius = UDim.new(1,0)

		UIGradient_3.Parent = Button2_1
		UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 124, 124))}

		UIStroke_3.Parent = Button2_1
		UIStroke_3.Color = Color3.fromRGB(255,255,255)
		UIStroke_3.Thickness = 2

		UIGradient_4.Parent = UIStroke_3
		UIGradient_4.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 124, 124))}
		UIGradient_4.Rotation = 180

		TextLabel_3.Parent = Button2_1
		TextLabel_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_3.BackgroundTransparency = 1
		TextLabel_3.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_3.BorderSizePixel = 0
		TextLabel_3.Size = UDim2.new(1, 0,1, 0)
		TextLabel_3.Font = Enum.Font.GothamBold
		TextLabel_3.Text = TitleButton2
		TextLabel_3.TextColor3 = Color2
		TextLabel_3.TextSize = 16

		UIStroke_4.Parent = TextLabel_3
		UIStroke_4.Thickness = 1
		UIStroke_4.Transparency = 0.95

		tw({v = Dialog, t = 0.25, s = Enum.EasingStyle.Linear, d = "Out", g = {GroupTransparency = 0}}):Play()
		local Click1 = click(Button1_1)
		local Click2 = click(Button2_1)
		Click1.MouseButton1Click:Connect(function()
			pcall(Button1)
			tw({v = TextLabel_2, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = TextLabel_2.TextSize - 2}}):Play()
			delay(.06, function()
				tw({v = TextLabel_2, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = 16}}):Play()
			end)
			local f = tw({v = Dialog, t = 0.25, s = Enum.EasingStyle.Linear, d = "Out", g = {GroupTransparency = 1}})
			f:Play()
			f.Completed:Wait()
			Dialog:Destroy()
		end)

		Click2.MouseButton1Click:Connect(function()
			pcall(Button2)
			tw({v = TextLabel_3, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = TextLabel_3.TextSize - 2}}):Play()
			delay(.06, function()
				tw({v = TextLabel_3, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = 16}}):Play()
			end)
			local f = tw({v = Dialog, t = 0.25, s = Enum.EasingStyle.Linear, d = "Out", g = {GroupTransparency = 1}})
			f:Play()
			f.Completed:Wait()
			Dialog:Destroy()
		end)
	end

	do
		local Size_1 = Instance.new("TextButton")

		Size_1.Name = "Size"
		Size_1.Parent = Background_1
		Size_1.Active = true
		Size_1.AnchorPoint = Vector2.new(1, 1)
		Size_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Size_1.BackgroundTransparency = 1
		Size_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Size_1.BorderSizePixel = 0
		Size_1.Position = UDim2.new(1, 0,1, 0)
		Size_1.Size = UDim2.new(0, 20,0, 20)
		Size_1.Font = Enum.Font.SourceSans
		Size_1.Text = ""
		Size_1.TextSize = 14

		local SizeFrame = Instance.new("Frame")
		local ImageLabel_1 = Instance.new("ImageLabel")
		local UICorner_1 = Instance.new("UICorner")

		SizeFrame.Name = "SizeFrame"
		SizeFrame.Parent = Background_1
		SizeFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
		SizeFrame.BackgroundTransparency = 1
		SizeFrame.BorderColor3 = Color3.fromRGB(0,0,0)
		SizeFrame.BorderSizePixel = 0
		SizeFrame.Size = UDim2.new(1, 0,1, 0)

		ImageLabel_1.Parent = SizeFrame
		ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_1.BackgroundTransparency = 1
		ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_1.BorderSizePixel = 0
		ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
		ImageLabel_1.Size = UDim2.new(0, 100,0, 100)
		ImageLabel_1.Image = "rbxassetid://13857987062"
		ImageLabel_1.ImageTransparency = 1

		UICorner_1.Parent = SizeFrame
		UICorner_1.CornerRadius = UDim.new(0,17)

		Size_1.MouseButton1Down:Connect(function()
			R = true
		end)

		local isZ = false
		local originalSize, originalPosition

		Minisize_1.MouseButton1Click:Connect(function()
			if not isZ then
				originalSize = Shadow_1.Size
				originalPosition = Shadow_1.Position
				tw({v = Shadow_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0)
				}}):Play()
				Minisize_1.Image = "rbxassetid://13857981896"
			else
				Minisize_1.Image = "rbxassetid://13857987062"
				tw({v = Shadow_1, t = 0.15, s = Enum.EasingStyle.Exponential, d = "Out", g = {
					Size = originalSize,
					Position = originalPosition
				}}):Play()
			end
			isZ = not isZ
		end)

		if not HAA then
			local AP, PAZ = Shadow_1.AbsolutePosition, Shadow_1.Parent.AbsoluteSize
			local NP = UDim2.new((AP.X / PAZ.X),
				Shadow_1.Position.X.Offset,
				(AP.Y / PAZ.Y),
				Shadow_1.Position.Y.Offset)

			Shadow_1.AnchorPoint = Vector2.new(0, 0)
			Shadow_1.Position = NP
			HAA = true
		end

		U.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				R = false
				tw({v = SizeFrame, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 1}}):Play()
				tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 1}}):Play()
			end
		end)

		U.InputChanged:Connect(function(i)
			if not isZ and R and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local nW = math.max(450, i.Position.X - Shadow_1.AbsolutePosition.X)
				local nH = math.max(220, i.Position.Y - Shadow_1.AbsolutePosition.Y)
				local nZ = UDim2.new(0, nW, 0, nH)
				tw({v = Shadow_1, t = 0.05, s = Enum.EasingStyle.Exponential, d = "Out", g = {Size = nZ}}):Play()
				tw({v = SizeFrame, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0.6}}):Play()
				tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0}}):Play()
				ImageLabel_1.Image = 'rbxassetid://13857987062'	
			elseif isZ and R and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				tw({v = SizeFrame, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {BackgroundTransparency = 0.6}}):Play()
				tw({v = ImageLabel_1, t = 0.15, s = Enum.EasingStyle.Linear, d = "Out", g = {ImageTransparency = 0}}):Play()
				ImageLabel_1.Image = 'rbxassetid://14906268026'
			end
		end)

		lak(Topbar_1, Shadow_1)

		local isopen = false
		local firsttime = false
		local oSize
		local function closeui()
			isopen = not isopen
			if isopen then
				oSize = Background_1.Size
				local close = tw({
					v = Background_1,
					t = 0.15,
					s = Enum.EasingStyle.Linear,
					d = "InOut",
					g = {
						GroupTransparency = 1,
						Size = oSize - UDim2.fromOffset(5, 5)
					}
				})
				close:Play()
				close.Completed:Wait()
				Shadow_1.Visible = false
			else
				Shadow_1.Visible = true  
				local open = tw({
					v = Background_1,
					t = 0.15,
					s = Enum.EasingStyle.Linear,
					d = "InOut",
					g = {
						GroupTransparency = 0,
						Size = oSize
					}
				})
				open:Play()
			end

			if not firsttime then
				firsttime = true
				Tabs:Notify({
					Title = 'Dummy Kawaii',
					Desc = 'Press the <font color="#FF77A5" size="14">('..tostring(Keybind):gsub("Enum.KeyCode.", "")..')</font> button to hide and show the UI',
					Time = 10
				})
			end
		end

		ChSize_1.MouseButton1Click:Connect(closeui)

		U.InputBegan:Connect(function(i)
			if i.KeyCode == Keybind then
				local focusedTextBox = U:GetFocusedTextBox()
				if not focusedTextBox then
					closeui()
				end
			end
		end)

		local CallTheme = function(v)
			IsTheme = v
			local t = themes[v]
			Library:setTheme({
				['Shadow'] = t.Shadow,
				['Background'] = t.Background,
				['Page'] = t.Page,
				['Main'] = t.Main,
				['Text & Icon'] = t['Text & Icon'],
				['Function'] = {
					['Toggle'] = {
						['Background'] = t.Function.Toggle.Background,
						['True'] = {
							['Toggle Background'] = t.Function.Toggle.True['Toggle Background'],
							['Toggle Value'] = t.Function.Toggle.True['Toggle Value'],
						},
						['False'] = {
							['Toggle Background'] = t.Function.Toggle.False['Toggle Background'],
							['Toggle Value'] = t.Function.Toggle.False['Toggle Value'],
						}
					},
					['Label'] = {
						['Background'] = t.Function.Label.Background,
					},
					['Dropdown'] = {
						['Background'] = t.Function.Dropdown.Background,
						['Value Background'] = t.Function.Dropdown['Value Background'],
						['Value Stroke'] = t.Function.Dropdown['Value Stroke'],
						['Dropdown Select'] = {
							['Background'] = t.Function.Dropdown['Dropdown Select'].Background,
							['Search'] = t.Function.Dropdown['Dropdown Select'].Search,
							['Item Background'] = t.Function.Dropdown['Dropdown Select']['Item Background'],
						}
					},
					['Slider'] = {
						['Background'] = t.Function.Slider.Background,
						['Value Background'] = t.Function.Slider['Value Background'],
						['Value Stroke'] = t.Function.Slider['Value Stroke'],
						['Slider Bar'] = t.Function.Slider['Slider Bar'],
						['Slider Bar Value'] = t.Function.Slider['Slider Bar Value'],
						['Circle Value'] = t.Function.Slider['Circle Value'],
					},
					['Code'] = {
						['Background'] = t.Function.Code.Background,
						['Background Code'] = t.Function.Code['Background Code'],
						['Background Code Value'] = t.Function.Code['Background Code Value'],
						['ScrollingFrame Code'] = t.Function.Code['ScrollingFrame Code'],
					},
					['Button'] = {
						['Background'] = t.Function.Button.Background,
						['Click'] = t.Function.Button.Click,
					},
					['Textbox'] = {
						['Background'] = t.Function.Textbox.Background,
						['Value Background'] = t.Function.Textbox['Value Background'],
						['Value Stroke'] = t.Function.Textbox['Value Stroke'],
					},
					['Keybind'] = {
						['Background'] = t.Function.Keybind.Background,
						['Value Background'] = t.Function.Keybind['Value Background'],
						['Value Stroke'] = t.Function.Keybind['Value Stroke'],
						['True'] = {
							['Toggle Background'] = t.Function.Keybind.True['Toggle Background'],
							['Toggle Value'] = t.Function.Keybind.True['Toggle Value'],
						},
						['False'] = {
							['Toggle Background'] = t.Function.Keybind.False['Toggle Background'],
							['Toggle Value'] = t.Function.Keybind.False['Toggle Value'],
						}
					},
					['Color Picker'] = {
						['Background'] = t.Function['Color Picker'].Background,
						['Color Select'] = {
							['Background'] = t.Function['Color Picker']['Color Select'].Background,
							['UIStroke'] = t.Function['Color Picker']['Color Select'].UIStroke,
						}
					}
				}
			})
		end
		local ThemeDrop = addDropdownSelect(DropdownValue_1, DropdownValue_1, false, CallTheme, Theme, themes.index)

		Close_1.MouseButton1Click:Connect(function()
			Tabs:Dialog({
				Title = "Do you want to <font color='#FF0000'>close</font> the ui?",
				Button1 = {
					Title = 'Confirm',
					Color = Color3.fromRGB(0, 188, 0),
					Callback = function()
						ScreenGui:Destroy()
					end,
				},
				Button2 = {
					Title = 'Cancel',
					Color = Color3.fromRGB(226, 39, 6),
				}
			})
		end)

		do
			local CloseUI = p.CloseUIButton
			local CloseUIShadow = Instance.new("ImageLabel")
			local UIPaddingCloseUI_1 = Instance.new("UIPadding")
			local BackgroundCloseUI_1 = Instance.new("Frame")
			local UICornerCloseUI_1 = Instance.new("UICorner")
			local FrameCloseUI_1 = Instance.new("Frame")
			local Title_1 = Instance.new("TextLabel")

			CloseUIShadow.Name = "CloseUIShadow"
			CloseUIShadow.Parent = ScreenGui
			CloseUIShadow.BackgroundColor3 = Color3.fromRGB(163,162,165)
			CloseUIShadow.BackgroundTransparency = 1
			CloseUIShadow.Position = UDim2.new(0, 0,0.200000003, 0)
			CloseUIShadow.Size = UDim2.new(0, 70,0, 40)
			CloseUIShadow.Image = "rbxassetid://1316045217"
			CloseUIShadow.ImageColor3 = Color3.fromRGB(24,24,31)
			CloseUIShadow.ImageTransparency = 0.5
			CloseUIShadow.ScaleType = Enum.ScaleType.Slice
			CloseUIShadow.SliceCenter = Rect.new(10, 10, 118, 118)
			CloseUIShadow.Visible = CloseUI.Enabled

			addToTheme('Shadow', CloseUIShadow)

			UIPaddingCloseUI_1.Name = "UIPaddingCloseUI"
			UIPaddingCloseUI_1.Parent = CloseUIShadow
			UIPaddingCloseUI_1.PaddingBottom = UDim.new(0,5)
			UIPaddingCloseUI_1.PaddingLeft = UDim.new(0,5)
			UIPaddingCloseUI_1.PaddingRight = UDim.new(0,5)
			UIPaddingCloseUI_1.PaddingTop = UDim.new(0,5)

			BackgroundCloseUI_1.Name = "BackgroundCloseUI"
			BackgroundCloseUI_1.Parent = CloseUIShadow
			BackgroundCloseUI_1.AnchorPoint = Vector2.new(0.5, 0.5)
			BackgroundCloseUI_1.BackgroundColor3 = Color3.fromRGB(29,28,38)
			BackgroundCloseUI_1.BorderColor3 = Color3.fromRGB(0,0,0)
			BackgroundCloseUI_1.BorderSizePixel = 0
			BackgroundCloseUI_1.Position = UDim2.new(0.5, 0,0.5, 0)
			BackgroundCloseUI_1.Size = UDim2.new(1, 0,1, 0)
			BackgroundCloseUI_1.ClipsDescendants = true

			addToTheme('Background', BackgroundCloseUI_1)

			UICornerCloseUI_1.Name = "UICornerCloseUI"
			UICornerCloseUI_1.Parent = BackgroundCloseUI_1
			UICornerCloseUI_1.CornerRadius = UDim.new(0,6)

			FrameCloseUI_1.Name = "FrameCloseUI"
			FrameCloseUI_1.Parent = BackgroundCloseUI_1
			FrameCloseUI_1.AnchorPoint = Vector2.new(0, 1)
			FrameCloseUI_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			FrameCloseUI_1.BackgroundTransparency = 0.8999999761581421
			FrameCloseUI_1.BorderColor3 = Color3.fromRGB(0,0,0)
			FrameCloseUI_1.BorderSizePixel = 0
			FrameCloseUI_1.Position = UDim2.new(0, 0,1, 0)
			FrameCloseUI_1.Size = UDim2.new(1, 0,0, 4)

			Title_1.Name = "Title"
			Title_1.Parent = BackgroundCloseUI_1
			Title_1.AutomaticSize = Enum.AutomaticSize.Y
			Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_1.BackgroundTransparency = 1
			Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_1.BorderSizePixel = 0
			Title_1.Size = UDim2.new(1, 0,1, 0)
			Title_1.Font = Enum.Font.GothamBold
			Title_1.Text = CloseUI.Text
			Title_1.TextColor3 = Color3.fromRGB(255,255,255)
			Title_1.TextSize = 12

			addToTheme('Text & Icon', Title_1)

			CloseUIShadow.Size = UDim2.new(0, Title_1.TextBounds.X + 40,0, 40)

			local Click = click(CloseUIShadow)
			lak(Click, CloseUIShadow)
			Click.MouseButton1Click:Connect(function()
				tw({v = Title_1, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = Title_1.TextSize - 2}}):Play()
				delay(.06, function()
					tw({v = Title_1, t = 0.15, s = Enum.EasingStyle.Back, d = "Out", g = {TextSize = 12}}):Play()
				end)
				pcall(closeui)
			end)
		end
	end

	return Tabs
end

return Library
