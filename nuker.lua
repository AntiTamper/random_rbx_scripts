local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera
local function getRemote()
    local rs = game:GetService("ReplicatedStorage")
    local sys = rs and rs:FindFirstChild("RocketSystem")
    local ev = sys and sys:FindFirstChild("Events")
    return ev and ev:FindFirstChild("RocketHit")
end

local function getVehicle()
    local gs = workspace:FindFirstChild("Game Systems")
    local vw = gs and gs:FindFirstChild("Vehicle Workspace")
    return vw and vw:FindFirstChild("M142 HIMARS ATACMS")
end

local function getWeapon()
    local v = getVehicle()
    local m = v and v:FindFirstChild("Misc")
    local t = m and m:FindFirstChild("Turrets")
    local a = t and t:FindFirstChild("ATACMS Weapons")
    return a and a:FindFirstChild("TV Rockets")
end

local function canFire()
    return getRemote() and getVehicle() and getWeapon() and true or false
end

local sel, rep, mConn = nil, 1, nil
local freecamOn, fcConn, origCamType, origCamSubject = false, nil, nil, nil
local forceDefaultMouse = false
local mouseHookConn = nil

local function toVec(v) return vector.create(v.X, v.Y, v.Z) end

local function pdata(player)
    local c = player and player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return nil, nil end
    return toVec(r.Position), r
end

local function mdata()
    local t = Mouse.Target
    if not t then return nil, nil end
    return toVec(Mouse.Hit.Position), t
end

local function fire(p, hit)
    if not p or not hit or not canFire() then return end
    getRemote():FireServer({
        Normal=vector.zero, Player=LP, Label="",
        Vehicle=getVehicle(), Position=p, Weapon=getWeapon(), HitPart=hit
    })
end

local function fireN(p, hit, n)
    for _=1,n do fire(p, hit) end
end

local function names()
    local t = {}
    for _,v in ipairs(Players:GetPlayers()) do
        if v~=LP then t[#t+1]=v.Name end
    end
    return t
end

local function startFreecam(speed)
    speed = speed or 1
    if freecamOn then return end
    freecamOn = true
    origCamType = Cam.CameraType
    origCamSubject = Cam.CameraSubject
    Cam.CameraType = Enum.CameraType.Scriptable
    local cf = Cam.CFrame
    fcConn = RS.RenderStepped:Connect(function(dt)
        if not freecamOn then return end
        local dir = Vector3.zero
        local r = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.yAxis end
        local s = speed
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then s=s*3 end
        if dir.Magnitude>0 then
            cf = CFrame.new(cf.Position + dir.Unit * s * dt * 60) * (cf-cf.Position)
        end
        local delta = UIS:GetMouseDelta()
        if delta.Magnitude>0 then
            local rx = -delta.Y * 0.3
            local ry = -delta.X * 0.3
            cf = cf * CFrame.Angles(math.rad(rx), math.rad(ry), 0)
        end
        Cam.CFrame = cf
    end)
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function stopFreecam()
    if not freecamOn then return end
    freecamOn = false
    if fcConn then fcConn:Disconnect() fcConn=nil end
    Cam.CameraType = origCamType or Enum.CameraType.Custom
    Cam.CameraSubject = origCamSubject or LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid")
    UIS.MouseBehavior = Enum.MouseBehavior.Default
end

local function enableMouseOverride()
    if mouseHookConn then return end
    forceDefaultMouse = true
    Mouse.Icon = ""
    UIS.MouseIconEnabled = true
    mouseHookConn = RS.Heartbeat:Connect(function()
        if not forceDefaultMouse then return end
        if Mouse.Icon ~= "" then Mouse.Icon = "" end
        if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
        local pg = LP:FindFirstChildWhichIsA("PlayerGui")
        if pg then
            for _,g in ipairs(pg:GetDescendants()) do
                if g:IsA("ImageLabel") and g.Visible and g.Image ~= "" then
                    local n = g.Name:lower()
                    local pn = g.Parent and g.Parent.Name:lower() or ""
                    if n:find("cursor") or n:find("mouse") or n:find("crosshair")
                        or pn:find("cursor") or pn:find("mouse") then
                        g.Visible = false
                    end
                end
            end
        end
    end)
end

local function disableMouseOverride()
    forceDefaultMouse = false
    if mouseHookConn then mouseHookConn:Disconnect() mouseHookConn=nil end
end

local mt = getrawmetatable(game)
local oldNc = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(s, ...)
    if not checkcaller() then
        local m = getnamecallmethod()
        if m == "FireServer" or m == "InvokeServer" then
            if s.Name=="BulletHit" or s.Name=="RocketHit" or s.Name=="RegisterTurretHit" then
                return oldNc(s, ...)
            end
        end
    end
    return oldNc(s, ...)
end)
setreadonly(mt, true)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local W = Rayfield:CreateWindow({
    Name="Nuker",Icon=0,LoadingTitle="Nuker",LoadingSubtitle="ATACMS",
    Theme="Default",DisableRayfieldPrompts=true,DisableBuildWarnings=true,
    ConfigurationSaving={Enabled=false},KeySystem=false
})

local T = W:CreateTab("Nuker","crosshair")
T:CreateSection("Target")

local dd = T:CreateDropdown({
    Name="Player",Options=names(),CurrentOption={},MultipleOptions=false,Flag="sp",
    Callback=function(o) sel=o[1] and Players:FindFirstChild(o[1]) end
})

Players.PlayerAdded:Connect(function() task.wait(1) dd:Refresh(names()) end)
Players.PlayerRemoving:Connect(function(p) if sel==p then sel=nil end task.wait(.5) dd:Refresh(names()) end)

T:CreateSection("Fire")

T:CreateInput({
    Name="Repeat",CurrentValue="1",PlaceholderText="1+",RemoveTextAfterFocusLost=false,Flag="rp",
    Callback=function(t) local n=tonumber(t) if n and n>=1 and n%1==0 then rep=n else rep=1 end end
})

T:CreateButton({Name="Fire Selected",Callback=function()
    if not sel then return end
    local p,h = pdata(sel)
    fireN(p, h, rep)
end})

T:CreateButton({Name="Fire ALL",Callback=function()
    for _,v in ipairs(Players:GetPlayers()) do
        if v~=LP then
            local p,h = pdata(v)
            if p then fireN(p, h, rep) end
        end
    end
end})

T:CreateSection("Mouse")

T:CreateToggle({Name="Fire on Click",CurrentValue=false,Flag="mc",Callback=function(v)
    if v then
        mConn=Mouse.Button1Down:Connect(function()
            local p,h = mdata()
            fireN(p, h, rep)
        end)
    else
        if mConn then mConn:Disconnect() mConn=nil end
    end
end})

T:CreateToggle({Name="Force Default Mouse",CurrentValue=false,Flag="fdm",Callback=function(v)
    if v then enableMouseOverride() else disableMouseOverride() end
end})

T:CreateSection("Freecam")

local fcSpeed = 1

T:CreateSlider({
    Name="Speed",Range={1,10},Increment=1,Suffix="x",CurrentValue=1,Flag="fcs",
    Callback=function(v) fcSpeed=v end
})

T:CreateToggle({Name="Freecam",CurrentValue=false,Flag="fc",Callback=function(v)
    if v then startFreecam(fcSpeed) else stopFreecam() end
end})

T:CreateSection("Danger")

T:CreateButton({Name="Self Destruct",Callback=function()
    if mConn then mConn:Disconnect() mConn=nil end
    disableMouseOverride()
    stopFreecam()
    local mt2 = getrawmetatable(game)
    setreadonly(mt2, false)
    mt2.__namecall = oldNc
    setreadonly(mt2, true)
    Rayfield:Destroy()
end})
