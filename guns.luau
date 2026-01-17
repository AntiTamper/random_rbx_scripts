do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local shipList = { "OrangeShip", "GreenShip" }

	local cannonGroups = {
		C1 = { names = { "SmallCannon", "BigCannon", "Flat Cannon", "MainCannon2", "Mortar2", "MountedRocket" }, args = { 7782023531 } },
		C2 = { names = { "Turret", "Double Turret", "SmallTurret", "Single Deck Cannon" }, args = { true } }
	}

	local shipSet = {}
	local cannonToGroup = {}
	local enabled = false
	local cached = {}

	local function aInitMaps()
		shipSet = {}
		cannonToGroup = {}

		for _, n in ipairs(shipList) do
			shipSet[n] = true
		end

		for groupKey, group in pairs(cannonGroups) do
			for _, cannonName in ipairs(group.names) do
				cannonToGroup[cannonName] = groupKey
			end
		end
	end

	local function bFindFireRemote(cannonInst)
		if not cannonInst or not cannonInst:IsDescendantOf(workspace) then
			return nil
		end

		local direct = cannonInst:FindFirstChild("FireCannon")
		if direct and direct:IsA("RemoteEvent") then
			return direct
		end

		local found = cannonInst:FindFirstChild("FireCannon", true)
		if found and found:IsA("RemoteEvent") then
			return found
		end

		return nil
	end

	local function cRebuildCache()
		local list = {}
		local seen = {}

		for _, inst in ipairs(workspace:GetDescendants()) do
			local groupKey = cannonToGroup[inst.Name]
			if groupKey then
				local fire = bFindFireRemote(inst)
				if fire then
					local p = inst.Parent
					while p and p ~= workspace do
						if shipSet[p.Name] then
							if not seen[fire] then
								seen[fire] = true
								list[#list + 1] = { r = fire, a = cannonGroups[groupKey].args }
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

	local function dPruneCache()
		local alive = {}
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				alive[#alive + 1] = item
			end
		end
		cached = alive
		if #cached == 0 then
			cRebuildCache()
		end
	end

	local function eFireAll()
		dPruneCache()
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				pcall(function()
					r:FireServer(unpack(item.a))
				end)
			end
		end
	end

	local gui, btn

	local function fSetEnabled(v)
		enabled = v
		btn.Text = v and "funny: ON" or "funny: OFF"
	end

	local function gMakeGui()
		gui = Instance.new("ScreenGui")
		gui.Name = "test"
		gui.ResetOnSpawn = false
		gui.Parent = playerGui

		btn = Instance.new("TextButton")
		btn.Name = "test"
		btn.Size = UDim2.fromOffset(170, 52)
		btn.Position = UDim2.new(0.06, 0, 0.55, 0)
		btn.TextScaled = true
		btn.BackgroundColor3 = Color3.new(0, 0, 0)
		btn.BackgroundTransparency = 0.5
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = "funny: OFF"
		btn.Parent = gui

		local corner = Instance.new("UICorner")
		corner.Name = "test"
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = btn
	end

	local function hHookButton()
		local dragging = false
		local dragStart
		local startPos

		btn.Activated:Connect(function()
			fSetEnabled(not enabled)
		end)

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = btn.Position
			end
		end)

		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
	end

	local function iLoop()
		task.spawn(function()
			while true do
				if enabled then
					eFireAll()
				end
				task.wait(0.05)
			end
		end)
	end

	aInitMaps()
	gMakeGui()
	hHookButton()
	cRebuildCache()
	iLoop()
end
