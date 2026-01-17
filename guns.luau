do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local enabled = false
	local cached = {}
	local cannonToGroup = {}
	local gui, button

	local SelfTeamOnly = false

	local shipList = { "OrangeShip", "GreenShip" }

	local cannonGroups = {
		C1 = {
			args = { 7782023531 },
			guns = {
				["SmallCannon"] = false,
				["BigCannon"] = false,
				["Flat Cannon"] = false,
				["MainCannon2"] = false,
				["Mortar2"] = true,
				["MountedRocket"] = true
			}
		},
		C2 = {
			args = { true },
			guns = {
				["Turret"] = true,
				["Double Turret"] = true,
				["SmallTurret"] = true,
				["Single Deck Cannon"] = true,
				["Double Deck Cannon"] = true
			}
		}
	}

	local function a()
		local set = {}

		if not SelfTeamOnly then
			for _, n in ipairs(shipList) do
				set[n] = true
			end
			return set
		end

		local teamName = (player.Team and player.Team.Name) or ""
		if teamName == "Orange Team" then
			set["OrangeShip"] = true
		elseif teamName == "Green Team" then
			set["GreenShip"] = true
		elseif teamName == "Spectators" then
			set["OrangeShip"] = true
			set["GreenShip"] = true
		else
			for _, n in ipairs(shipList) do
				set[n] = true
			end
		end

		return set
	end

	local function b()
		local map = {}
		for groupKey, group in pairs(cannonGroups) do
			for cannonName, isOn in pairs(group.guns) do
				if isOn then
					map[cannonName] = groupKey
				end
			end
		end
		cannonToGroup = map
	end

	local function c(cannonInst)
		if not cannonInst or not cannonInst:IsDescendantOf(workspace) then
			return nil
		end

		local direct = cannonInst:FindFirstChild("FireCannon")
		if direct and direct:IsA("RemoteEvent") then
			return direct
		end

		local deep = cannonInst:FindFirstChild("FireCannon", true)
		if deep and deep:IsA("RemoteEvent") then
			return deep
		end

		return nil
	end

	local function d()
		gui = Instance.new("ScreenGui")
		gui.Name = "test"
		gui.ResetOnSpawn = false
		gui.Parent = playerGui

		button = Instance.new("TextButton")
		button.Name = "test"
		button.Size = UDim2.fromOffset(170, 52)
		button.Position = UDim2.new(0.06, 0, 0.55, 0)
		button.TextScaled = true
		button.BackgroundColor3 = Color3.new(0, 0, 0)
		button.BackgroundTransparency = 0.5
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Text = "funny: OFF"
		button.Parent = gui

		local corner = Instance.new("UICorner")
		corner.Name = "test"
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = button
	end

	local function e()
		local dragging = false
		local dragStart
		local startPos

		button.Activated:Connect(function()
			f(not enabled)
		end)

		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = button.Position
			end
		end)

		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
	end

	local function f(v)
		enabled = v
		if button then
			button.Text = v and "funny: ON" or "funny: OFF"
		end
	end

	local function g()
		local list = {}
		local seen = {}
		local shipSet = a()

		for _, inst in ipairs(workspace:GetDescendants()) do
			local groupKey = cannonToGroup[inst.Name]
			if groupKey then
				local fire = c(inst)
				if fire then
					local p = inst.Parent
					while p and p ~= workspace do
						if shipSet[p.Name] then
							if not seen[fire] then
								seen[fire] = true
								local group = cannonGroups[groupKey]
								if group and group.args then
									list[#list + 1] = { r = fire, a = group.args }
								end
							end
							break
						end
						p = p.Parent
					end
				end
			end
		end

		cached = list
	end

	local function h()
		local alive = {}
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				alive[#alive + 1] = item
			end
		end
		cached = alive
		if #cached == 0 then
			g()
		end
	end

	local function i()
		h()
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				pcall(function()
					r:FireServer(unpack(item.a))
				end)
			end
		end
	end

	local function j()
		task.spawn(function()
			while true do
				if enabled then
					i()
				end
				task.wait(0.05)
			end
		end)
	end

	local function k()
		b()
		d()
		e()
		g()
		j()

		player:GetPropertyChangedSignal("Team"):Connect(function()
			if SelfTeamOnly then
				cached = {}
			end
		end)
	end

	k()
end
