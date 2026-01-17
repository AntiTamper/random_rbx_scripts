local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local shipList = { "OrangeShip", "GreenShip" }
local cannonList = { "SmallCannon", "BigCannon", "Flat Cannon", "MainCannon2", "Mortar2" }

local shipSet = {}
for _, n in ipairs(shipList) do
	shipSet[n] = true
end

local cannonSet = {}
for _, n in ipairs(cannonList) do
	cannonSet[n] = true
end

local enabled = false
local cachedRemotes = {}
local args = { 7782023531 }

local function rebuildCache()
	local remotes = {}
	local seen = {}

	for _, inst in ipairs(workspace:GetDescendants()) do
		if cannonSet[inst.Name] then
			local fire = inst:FindFirstChild("FireCannon")
			if fire and fire:IsA("RemoteEvent") then
				local p = inst.Parent
				while p and p ~= workspace do
					if shipSet[p.Name] then
						if not seen[fire] then
							seen[fire] = true
							remotes[#remotes + 1] = fire
						end
						break
					end
					p = p.Parent
				end
			end
		end
	end

	cachedRemotes = remotes
end

local function pruneAndMaybeRebuild()
	local alive = {}
	for _, r in ipairs(cachedRemotes) do
		if r and r.Parent and r:IsDescendantOf(workspace) then
			alive[#alive + 1] = r
		end
	end
	cachedRemotes = alive
	if #cachedRemotes == 0 then
		rebuildCache()
	end
end

local function fireAll()
	pruneAndMaybeRebuild()
	for _, remote in ipairs(cachedRemotes) do
		if remote and remote.Parent and remote:IsDescendantOf(workspace) then
			pcall(function()
				remote:FireServer(unpack(args))
			end)
		end
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "test"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local btn = Instance.new("TextButton")
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

local dragging = false
local dragStart
local startPos

local function setEnabled(v)
	enabled = v
	btn.Text = v and "funny: ON" or "funny: OFF"
end

btn.Activated:Connect(function()
	setEnabled(not enabled)
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

rebuildCache()

task.spawn(function()
	while true do
		if enabled then
			fireAll()
		end
		task.wait(0.05)
	end
end)
