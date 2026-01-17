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
		C2 = "0.05",
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
				["Single  Deck Cannon"] = true,
				["MountedRocket"] = true
			},
			remotes = {
				FireCannon = { args = { "7782023531" } },
				MoveCannon = {
					args1 = { "left", "right", "up", "down" },
					args2 = { true, false }
				}
			}
		},
		C2 = {
			guns = {
				["Turret"] = true,
				["Double Turret"] = true,
				["SmallTurret"] = true,
				["Single  Deck Cannon"] = true,
				["Double Deck Cannon"] = true,
				["DoubleMG"] = true
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
		if ad and (ad:IsA("RemoteEvent") or ad:IsA("UnreliableRemoteEvent")) then return ad end
		local ae = ab:FindFirstChild(ac, true)
		if ae and (ae:IsA("RemoteEvent") or ae:IsA("UnreliableRemoteEvent")) then return ae end
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
		local af = r.C1.remotes.FireCannon.args
		for _, ag in ipairs(ad()) do
			if ag.group == "C1" and ag.fire then
				pcall(function() ag.fire:FireServer(u(af[1])) end)
			end
		end
	end

	local function af()
		local ag = r.C2.remotes.FireCannon.args
		for _, ah in ipairs(ad()) do
			if ah.group == "C2" and ah.fire then
				pcall(function() ah.fire:FireServer(u(ag[1])) end)
			end
		end
	end

	local function ag()
		local cfg = r.C1.remotes.MoveCannon
		for _, ah in ipairs(ad()) do
			if ah.group == "C1" and ah.move then
				local dir = cfg.args1[math.random(#cfg.args1)]
				local bool = cfg.args2[math.random(#cfg.args2)]
				pcall(function() ah.move:FireServer(dir, bool) end)
			end
		end
	end

	local function ah()
		local ai = y()
		for aj in pairs(ai) do
			local ak = workspace:FindFirstChild(aj)
			if ak then
				local al = ak:FindFirstChild("Pieces")
				if al then
					local am = al:FindFirstChild("StopControl")
					if am then
						local an = am:FindFirstChildOfClass("ClickDetector")
						if an then pcall(function() Log(an) end) end
					end
				end
			end
		end
	end

	local function ai()
		if l then l.BackgroundColor3 = e and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,70,70) end
		if m then m.BackgroundColor3 = f and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,70,70) end
		if n then n.BackgroundColor3 = g and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,70,70) end
	end

	local function aj()
		j = Instance.new("ScreenGui")
		j.ResetOnSpawn = false
		j.Parent = d

		k = Instance.new("Frame")
		k.Size = UDim2.fromOffset(150, 120)
		k.Position = UDim2.new(0.06, 0, 0.55, 0)
		k.BackgroundColor3 = Color3.fromRGB(0,0,0)
		k.BackgroundTransparency = 0.25
		k.Parent = j
		Instance.new("UICorner", k).CornerRadius = UDim.new(0,14)

		local st = Instance.new("UIStroke", k)
		st.Color = Color3.fromRGB(0,255,255)
		st.Thickness = 1.5
		st.Transparency = 0.3

		local lay = Instance.new("UIListLayout", k)
		lay.Padding = UDim.new(0,8)
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
		lay.VerticalAlignment = Enum.VerticalAlignment.Center

		local pad = Instance.new("UIPadding", k)
		pad.PaddingTop = UDim.new(0,10)
		pad.PaddingBottom = UDim.new(0,10)
		pad.PaddingLeft = UDim.new(0,10)
		pad.PaddingRight = UDim.new(0,10)

		local function mk(txt)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1,0,0,28)
			btn.Text = txt
			btn.TextScaled = true
			btn.Font = Enum.Font.GothamBold
			btn.TextColor3 = Color3.new(1,1,1)
			btn.BackgroundTransparency = 0.15
			btn.BackgroundColor3 = Color3.fromRGB(255,70,70)
			btn.Parent = k
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
			local s2 = Instance.new("UIStroke", btn)
			s2.Color = Color3.fromRGB(0,255,255)
			s2.Transparency = 0.4
			return btn
		end

		l = mk("test1")
		m = mk("test2")
		n = mk("test3")
	end

	local function ak()
		l.Activated:Connect(function() e = not e ai() end)
		m.Activated:Connect(function() f = not f ai() end)
		n.Activated:Connect(function() g = not g ai() end)
	end

	local function al()
		task.spawn(function() while true do if e then ae() end task.wait(q.C1) end end)
		task.spawn(function() while true do if e then af() end task.wait(q.C2) end end)
		task.spawn(function() while true do if f then ag() end task.wait(q.C1Move) end end)
		task.spawn(function() while true do if g then ah() end task.wait(q.F3) end end)
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
