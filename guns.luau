do
	local a = game:GetService("Players")
	local b = game:GetService("UserInputService")

	local c = a.LocalPlayer
	local d = c:WaitForChild("PlayerGui")

	local e, f, g = false, false, false
	local h = {}
	local i = {}

	local j, k, l, m, n

	local o = false
	local p = { "OrangeShip", "GreenShip" }

	local q = {
		C1 = "0.1",
		C2 = "0",
		C1Move = "0.1",
		F3 = "0.5"
	}

	local r = {
		C1 = {
			guns = {
				["SmallCannon"] = true,
				["BigCannon"] = true,
				["Flat Cannon"] = true,
				["MainCannon2"] = true,
				["Mortar2"] = true,
				["MountedRocket"] = true
			},
			remotes = {
				FireCannon = { args = { "7782023531" } },
				MoveCannon = { args = { "left", "right", "up", "down" } }
			}
		},
		C2 = {
			guns = {
				["Turret"] = true,
				["Double Turret"] = true,
				["SmallTurret"] = true,
				["Single  Deck Cannon"] = true,
				["Double Deck Cannon"] = true
			},
			remotes = {
				FireCannon = { args = { "true" } }
			}
		}
	}

	local s = 0
	local t = 2

	local function u(v)
		if typeof(v) ~= "string" then return v end
		local w = string.lower(v)
		if w == "true" then return true end
		if w == "false" then return false end
		local x = tonumber(v)
		if x ~= nil then return x end
		return v
	end

	local function y()
		local z = {}
		if not o then
			for _, aa in ipairs(p) do z[aa] = true end
			return z
		end
		local ab = (c.Team and c.Team.Name) or ""
		if ab == "Orange Team" then
			z["OrangeShip"] = true
		elseif ab == "Green Team" then
			z["GreenShip"] = true
		elseif ab == "Spectators" then
			z["OrangeShip"] = true
			z["GreenShip"] = true
		else
			for _, aa in ipairs(p) do z[aa] = true end
		end
		return z
	end

	local function z()
		local aa = {}
		for ab, ac in pairs(r) do
			for ad, ae in pairs(ac.guns) do
				if ae then aa[ad] = ab end
			end
		end
		i = aa
	end

	local function aa(ab, ac)
		if not ab or not ab:IsDescendantOf(workspace) then return nil end
		local ad = ab:FindFirstChild(ac)
		if ad and (ad:IsA("RemoteEvent") or ad:IsA("UnreliableRemoteEvent")) then
			return ad
		end
		local ae = ab:FindFirstChild(ac, true)
		if ae and (ae:IsA("RemoteEvent") or ae:IsA("UnreliableRemoteEvent")) then
			return ae
		end
		return nil
	end

	local function ab()
		local ac = {}
		local ad = y()
		for _, ae in ipairs(workspace:GetDescendants()) do
			local af = i[ae.Name]
			if af then
				local ag = ae.Parent
				local ah = false
				while ag and ag ~= workspace do
					if ad[ag.Name] then ah = true break end
					ag = ag.Parent
				end
				if ah then
					local ai = aa(ae, "FireCannon")
					local aj = aa(ae, "MoveCannon")
					if ai or aj then
						ac[#ac + 1] = { group = af, fire = ai, move = aj }
					end
				end
			end
		end
		h = ac
		s = os.clock()
	end

	local function ac()
		local ad = {}
		for _, ae in ipairs(h) do
			if (ae.fire and ae.fire:IsDescendantOf(workspace)) or (ae.move and ae.move:IsDescendantOf(workspace)) then
				ad[#ad + 1] = ae
			end
		end
		h = ad
		if #h == 0 or (os.clock() - s) >= t then ab() end
	end

	local function ad()
		ac()
		return h
	end

	local function ae()
		local af = r.C1.remotes.FireCannon
		local ag = {}
		for ah, ai in ipairs(af.args) do ag[ah] = u(ai) end
		for _, aj in ipairs(ad()) do
			if aj.group == "C1" and aj.fire then
				pcall(function() aj.fire:FireServer(unpack(ag)) end)
			end
		end
	end

	local function af()
		local ag = r.C2.remotes.FireCannon
		local ah = {}
		for ai, aj in ipairs(ag.args) do ah[ai] = u(aj) end
		for _, ak in ipairs(ad()) do
			if ak.group == "C2" and ak.fire then
				pcall(function() ak.fire:FireServer(unpack(ah)) end)
			end
		end
	end

	local function ag()
		local ah = r.C1.remotes.MoveCannon.args
		for _, ai in ipairs(ad()) do
			if ai.group == "C1" and ai.move then
				local aj = ah[math.random(1, #ah)]
				pcall(function()
					ai.move:FireServer(aj, false)
				end)
			end
		end
	end

	local function ah()
		local ai = y()
		for aj in pairs(ai) do
			local ak = workspace:FindFirstChild(aj)
			if ak and ak:IsDescendantOf(workspace) then
				local al = ak:FindFirstChild("Pieces")
				if al then
					local am = al:FindFirstChild("StopControl")
					if am then
						local an = am:FindFirstChildOfClass("ClickDetector")
						if an then pcall(function() fireclickdetector(an) end) end
					end
				end
			end
		end
	end

	local function ai()
		if l then l.Text = e and "test1: ON" or "test1: OFF" end
		if m then m.Text = f and "test2: ON" or "test2: OFF" end
		if n then n.Text = g and "test3: ON" or "test3: OFF" end
	end

	local function aj()
		j = Instance.new("ScreenGui")
		j.ResetOnSpawn = false
		j.Parent = d

		k = Instance.new("Frame")
		k.Size = UDim2.fromOffset(140, 108)
		k.Position = UDim2.new(0.06, 0, 0.55, 0)
		k.BackgroundColor3 = Color3.new(0, 0, 0)
		k.BackgroundTransparency = 0.5
		k.Parent = j
		Instance.new("UICorner", k).CornerRadius = UDim.new(0, 12)

		local ak = Instance.new("UIListLayout", k)
		ak.Padding = UDim.new(0, 6)
		ak.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ak.VerticalAlignment = Enum.VerticalAlignment.Center

		local al = Instance.new("UIPadding", k)
		al.PaddingTop = UDim.new(0, 7)
		al.PaddingBottom = UDim.new(0, 7)
		al.PaddingLeft = UDim.new(0, 7)
		al.PaddingRight = UDim.new(0, 7)

		local function am(an)
			local ao = Instance.new("TextButton")
			ao.Size = UDim2.new(1, 0, 0, 26)
			ao.BackgroundColor3 = Color3.new(0, 0, 0)
			ao.BackgroundTransparency = 0.35
			ao.TextColor3 = Color3.new(1, 1, 1)
			ao.TextScaled = true
			ao.Text = an
			ao.Parent = k
			Instance.new("UICorner", ao).CornerRadius = UDim.new(0, 10)
			return ao
		end

		l = am("test1: OFF")
		m = am("test2: OFF")
		n = am("test3: OFF")
	end

	local function ak()
		l.Activated:Connect(function() e = not e ai() end)
		m.Activated:Connect(function() f = not f ai() end)
		n.Activated:Connect(function() g = not g ai() end)

		local al, am, an = false, nil, nil

		k.InputBegan:Connect(function(ao)
			if ao.UserInputType == Enum.UserInputType.MouseButton1 or ao.UserInputType == Enum.UserInputType.Touch then
				al = true
				am = ao.Position
				an = k.Position
			end
		end)

		k.InputEnded:Connect(function(ao)
			if ao.UserInputType == Enum.UserInputType.MouseButton1 or ao.UserInputType == Enum.UserInputType.Touch then
				al = false
			end
		end)

		b.InputChanged:Connect(function(ao)
			if not al then return end
			if ao.UserInputType ~= Enum.UserInputType.MouseMovement and ao.UserInputType ~= Enum.UserInputType.Touch then return end
			local ap = ao.Position - am
			k.Position = UDim2.new(an.X.Scale, an.X.Offset + ap.X, an.Y.Scale, an.Y.Offset + ap.Y)
		end)
	end

	local function al()
		task.spawn(function()
			while true do
				if e then ae() end
				task.wait(q.C1)
			end
		end)

		task.spawn(function()
			while true do
				if e then af() end
				task.wait(q.C2)
			end
		end)

		task.spawn(function()
			while true do
				if f then ag() end
				task.wait(q.C1Move)
			end
		end)

		task.spawn(function()
			while true do
				if g then ah() end
				task.wait(q.F3)
			end
		end)
	end

	local function am()
		math.randomseed(os.clock() * 1e6)
		for an, ao in pairs(q) do q[an] = u(ao) end
		z()
		aj()
		ak()
		ab()
		ai()
		al()
	end

	am()
end
