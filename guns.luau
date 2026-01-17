do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local SelfTeamOnly = true

	local shipList = { "OrangeShip", "GreenShip" }

	local cannonGroups = {
		C1 = {
			args = { 7782023531 },
			guns = {
				["SmallCannon"] = true,
				["BigCannon"] = true,
				["Flat Cannon"] = true,
				["MainCannon2"] = true,
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

	local shipSet = {}
	local cannonToGroup = {}
	local enabled = false
	local cached = {}
	local gui, btn

	local function aInit()
		iMakeGui()
		jHookButton()
		cBuildCannonMap()
		eRebuildCache()
		kLoop()

		if player:GetPropertyChangedSignal("Team") then
			player:GetPropertyChangedSignal("Team"):Connect(function()
				cached = {}
			end)
		end
	end

	local function bAllowedShipSet()
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
			set["OrangeShip"] = true
			set["GreenShip"] = true
		end

		return set
	end

	local function cBuildCannonMap()
		cannonToGroup = {}
		for groupKey, group in pairs(cannonGroups) do
			for cannonName, isOn in pairs(group.guns) do
				if isOn then
					cannonToGroup[cannonName] = groupKey
				end
			end
		end
	end

	local function dFindFireRemote(cannonInst)
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

	local function eRebuildCache()
		local list = {}
		local seen = {}
		shipSet = bAllowedShipSet()

		for _, inst in ipairs(workspace:GetDescendants()) do
			local groupKey = cannonToGroup[inst.Name]
			if groupKey then
				local fire = dFindFireRemote(inst)
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

	local function fPruneCache()
		local alive = {}
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				alive[#alive + 1] = item
			end
		end
		cached = alive
		if #cached == 0 then
			eRebuildCache()
		end
	end

	local function gFireAll()
		fPruneCache()
		for _, item in ipairs(cached) do
			local r = item.r
			if r and r.Parent and r:IsDescendantOf(workspace) then
				pcall(function()
					r:FireServer(unpack(item.a))
				end)
			end
		end
	end

	local function hSetEnabled(v)
		enabled = v
		btn.Text = v and "funny: ON" or "funny: OFF"
	end

	function iMakeGui()
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

	function jHookButton()
		local dragging = false
		local dragStart
		local startPos

		btn.Activated:Connect(function()
			hSetEnabled(not enabled)
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

	function kLoop()
		task.spawn(function()
			while true do
				if enabled then
					gFireAll()
				end
				task.wait(0.05)
			end
		end)
	end

	aInit()
end
