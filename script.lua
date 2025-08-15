local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpectreHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")


local Tabs = {} 



local function createTab(name)
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0,400,0,500)
    frame.Position = UDim2.new(0.5,-200,0.5,-250)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Visible = false
    Tabs[name] = frame
    return frame
end

local function createToggle(tab,text,callback)
    local btn = Instance.new("TextButton", tab)
    btn.Size = UDim2.new(0,150,0,30)
    btn.Text = text.." [OFF]"
    btn.Position = UDim2.new(0,10,#tab:GetChildren()*35)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." ["..(state and "ON" or "OFF").."]"
        callback(state)
    end)
end

local function createButton(tab,text,callback)
    local btn = Instance.new("TextButton", tab)
    btn.Size = UDim2.new(0,150,0,30)
    btn.Text = text
    btn.Position = UDim2.new(0,10,#tab:GetChildren()*35)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(callback)
end

local function createDropdown(tab,text,options,callback)
    local dd = Instance.new("TextButton",tab)
    dd.Size = UDim2.new(0,150,0,30)
    dd.Text = text
    dd.Position = UDim2.new(0,10,#tab:GetChildren()*35)
    dd.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dd.TextColor3 = Color3.fromRGB(255,255,255)
    dd.MouseButton1Click:Connect(function()
        if #options>0 then
            callback(options[1])
        end
    end)
end

local function createTextBox(tab,text,callback)
    local tb = Instance.new("TextBox",tab)
    tb.Size = UDim2.new(0,150,0,30)
    tb.Text = text
    tb.Position = UDim2.new(0,10,#tab:GetChildren()*35)
    tb.BackgroundColor3 = Color3.fromRGB(40,40,40)
    tb.TextColor3 = Color3.fromRGB(255,255,255)
    tb.FocusLost:Connect(function()
        callback(tb.Text)
    end)
end

local function createIncrementer(tab,text,initial,step,callback)
    local value = initial
    local label = Instance.new("TextLabel",tab)
    label.Size = UDim2.new(0,150,0,30)
    label.Position = UDim2.new(0,10,#tab:GetChildren()*35)
    label.Text = text..": "..value
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local btnAdd = Instance.new("TextButton",tab)
    btnAdd.Size = UDim2.new(0,30,0,30)
    btnAdd.Position = UDim2.new(0,170,#tab:GetChildren()*35)
    btnAdd.Text = "+"
    btnAdd.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btnAdd.TextColor3 = Color3.fromRGB(255,255,255)

    local btnSub = Instance.new("TextButton",tab)
    btnSub.Size = UDim2.new(0,30,0,30)
    btnSub.Position = UDim2.new(0,210,#tab:GetChildren()*35)
    btnSub.Text = "-"
    btnSub.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btnSub.TextColor3 = Color3.fromRGB(255,255,255)

    btnAdd.MouseButton1Click:Connect(function()
        value = value + step
        label.Text = text..": "..value
        callback(value)
    end)

    btnSub.MouseButton1Click:Connect(function()
        value = value - step
        label.Text = text..": "..value
        callback(value)
    end)
end


local TabsNames = {"Visual","Combate","Movimento","Utilidades","Remote Spy"}
for _,name in pairs(TabsNames) do
    createTab(name)
end


local SilentAimEnabled, TriggerBotEnabled, RapidFireEnabled, NoRecoilEnabled = false,false,false,false
local LockBone = "Head"
local BunnyHopEnabled, StrafeEnabled, AutoCrouchEnabled, WallClimbEnabled, TeleportDashEnabled = false,false,false,false,false
local DashDistance = 20
local BoneESPEnabled, RadarEnabled, CrosshairEnabled, HitMarkerEnabled = false,false,true,false
local ChatSpamEnabled, AutoFarmEnabled, AntiAFKEnabled = false,false,false
local ChatMessage = "GG WP!"
local AutoFarmDelay = 2
local RemoteSpyEnabled = false
local RemoteLogs = {}

local Crosshair = Drawing.new("Line")
Crosshair.Color = Color3.fromRGB(255,255,255)
Crosshair.Thickness = 2
Crosshair.Visible = CrosshairEnabled

RunService.RenderStepped:Connect(function()
    if CrosshairEnabled then
        local cx,cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
        Crosshair.From = Vector2.new(cx-10,cy)
        Crosshair.To = Vector2.new(cx+10,cy)
        Crosshair.Visible = true
    else
        Crosshair.Visible = false
    end
end)


local function drawBone(player)
    if not player.Character then return end
    local char = player.Character
    local bones = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","RightUpperArm","RightLowerArm","LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}
    local lines = {}
    for i=1,#bones-1 do
        local partA = char:FindFirstChild(bones[i])
        local partB = char:FindFirstChild(bones[i+1])
        if partA and partB then
            local line = Drawing.new("Line")
            line.Color = (player.Team==LocalPlayer.Team) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
            line.Thickness = 1
            table.insert(lines,line)
        end
    end
    return lines
end

local BoneLines = {}
RunService.RenderStepped:Connect(function()
    if BoneESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not BoneLines[player] then
                    BoneLines[player] = drawBone(player)
                end
                local lines = BoneLines[player]
                local char = player.Character
                local bones = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","RightUpperArm","RightLowerArm","LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}
                for i=1,#lines do
                    local partA = char:FindFirstChild(bones[i])
                    local partB = char:FindFirstChild(bones[i+1])
                    if partA and partB then
                        local a,b = Camera:WorldToViewportPoint(partA.Position), Camera:WorldToViewportPoint(partB.Position)
                        lines[i].From = Vector2.new(a.X,a.Y)
                        lines[i].To = Vector2.new(b.X,b.Y)
                        lines[i].Visible = true
                    else
                        lines[i].Visible = false
                    end
                end
            end
        end
    else
        for _, lines in pairs(BoneLines) do
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
    end
end)

local ESPBoxes = {}
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                if not ESPBoxes[player] then
                    ESPBoxes[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Health = Drawing.new("Text")
                    }
                    ESPBoxes[player].Box.Color = Color3.fromRGB(255,0,0)
                    ESPBoxes[player].Box.Thickness = 1
                    ESPBoxes[player].Box.Filled = false

                    ESPBoxes[player].Name.Color = Color3.fromRGB(255,255,255)
                    ESPBoxes[player].Name.Size = 16
                    ESPBoxes[player].Name.Center = true

                    ESPBoxes[player].Health.Color = Color3.fromRGB(0,255,0)
                    ESPBoxes[player].Health.Size = 14
                    ESPBoxes[player].Health.Center = true
                end
                local box = ESPBoxes[player].Box
                local nameTxt = ESPBoxes[player].Name
                local healthTxt = ESPBoxes[player].Health

                local size = Vector2.new(50, 100)
                box.Size = size
                box.Position = Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                box.Visible = true

                nameTxt.Position = Vector2.new(pos.X,pos.Y-size.Y/2-10)
                nameTxt.Text = player.Name
                nameTxt.Visible = true

                healthTxt.Position = Vector2.new(pos.X,pos.Y+size.Y/2+5)
                healthTxt.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                healthTxt.Visible = true
            elseif ESPBoxes[player] then
                ESPBoxes[player].Box.Visible = false
                ESPBoxes[player].Name.Visible = false
                ESPBoxes[player].Health.Visible = false
            end
        end
    end
end)

-- Radar simples
local Radar = Drawing.new("Circle")
Radar.Color = Color3.fromRGB(0,255,0)
Radar.Thickness = 1
Radar.NumSides = 30
Radar.Radius = 50
Radar.Filled = false
Radar.Position = Vector2.new(100,100)
Radar.Visible = RadarEnabled

RunService.RenderStepped:Connect(function()
    Radar.Visible = RadarEnabled
end)

local function getTargetFOV(fov)
    local closestPlayer = nil
    local shortestDist = fov
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlayer = hrp
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Silent Aim
local SilentAimFOV = 200
RunService.RenderStepped:Connect(function()
    if SilentAimEnabled then
        local target = getTargetFOV(SilentAimFOV)
        if target then
            for _,remote in pairs(getgc(true)) do
                if type(remote)=="table" then
                    for k,v in pairs(remote) do
                        if typeof(v)=="Instance" and v:IsA("RemoteEvent") then
                            pcall(function()
                                v:FireServer(target.Position)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Trigger Bot
local TriggerFOV = 50
RunService.RenderStepped:Connect(function()
    if TriggerBotEnabled then
        local target = getTargetFOV(TriggerFOV)
        if target then
            for _,remote in pairs(getgc(true)) do
                if type(remote)=="table" then
                    for k,v in pairs(remote) do
                        if typeof(v)=="Instance" and v:IsA("RemoteEvent") then
                            pcall(function()
                                v:FireServer(target.Position)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Rapid Fire
UserInputService.InputBegan:Connect(function(input)
    if RapidFireEnabled and input.UserInputType==Enum.UserInputType.MouseButton1 then
        spawn(function()
            while RapidFireEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local target = getTargetFOV(SilentAimFOV)
                if target then
                    for _,remote in pairs(getgc(true)) do
                        if type(remote)=="table" then
                            for k,v in pairs(remote) do
                                if typeof(v)=="Instance" and v:IsA("RemoteEvent") then
                                    pcall(function()
                                        v:FireServer(target.Position)
                                    end)
                                end
                            end
                        end
                    end
                end
                wait(0.05)
            end
        end)
    end
end)

-- No Recoil (Hook genérico)
local function hookRecoil()
    for _,v in pairs(getgc(true)) do
        if type(v)=="function" and tostring(v):find("Recoil") then
            pcall(function()
                hookfunction(v,function(...) return end)
            end)
        end
    end
end

if NoRecoilEnabled then hookRecoil() end

-- Cycle FOV (para Silent Aim visual)
local CycleFOVEnabled = false
local CycleFOVValue = 200
local CycleFOVMin, CycleFOVMax = 100,300
local CycleFOVSpeed = 1

RunService.RenderStepped:Connect(function(dt)
    if CycleFOVEnabled then
        CycleFOVValue = CycleFOVValue + CycleFOVSpeed
        if CycleFOVValue > CycleFOVMax or CycleFOVValue < CycleFOVMin then
            CycleFOVSpeed = -CycleFOVSpeed
        end
    end
end)

-- Long Range Kill (ataque à distância, ignorando linha de visão)
local LongRangeKillEnabled = false
local function executeLongRangeKill()
    if LongRangeKillEnabled then
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,remote in pairs(getgc(true)) do
                        if type(remote)=="table" then
                            for k,v in pairs(remote) do
                                if typeof(v)=="Instance" and v:IsA("RemoteEvent") then
                                    pcall(function()
                                        v:FireServer(hrp.Position)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if BunnyHopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
end)

-- Strafe Hack
UserInputService.InputBegan:Connect(function(input)
    if StrafeEnabled and input.UserInputType==Enum.UserInputType.Keyboard then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if input.KeyCode==Enum.KeyCode.A then hum:Move(Vector3.new(-1,0,0),true)
            elseif input.KeyCode==Enum.KeyCode.D then hum:Move(Vector3.new(1,0,0),true) end
        end
    end
end)

-- Auto Crouch/Slide
RunService.RenderStepped:Connect(function()
    if AutoCrouchEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.WalkSpeed = 24
        end
    end
end)

-- Wall Climb
UserInputService.InputBegan:Connect(function(input)
    if WallClimbEnabled and input.KeyCode==Enum.KeyCode.Space and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0) end
    end
end)

-- Teleport Dash
UserInputService.InputBegan:Connect(function(input)
    if TeleportDashEnabled and input.KeyCode==Enum.KeyCode.LeftShift and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * DashDistance end
    end
end)


local FlyEnabled = false
local FlySpeed = 50

-- GUI Fly
local FlyFrame = Instance.new("Frame", ScreenGui)
FlyFrame.Size = UDim2.new(0,200,0,100)
FlyFrame.Position = UDim2.new(1,-210,0.5,-50)
FlyFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
FlyFrame.Visible = false

local FlyLabel = Instance.new("TextLabel", FlyFrame)
FlyLabel.Text = "Fly Speed: "..FlySpeed
FlyLabel.Size = UDim2.new(1,0,0,30)
FlyLabel.TextColor3 = Color3.fromRGB(255,255,255)

local BtnIncrease = Instance.new("TextButton", FlyFrame)
BtnIncrease.Text = "+"
BtnIncrease.Size = UDim2.new(0,30,0,30)
BtnIncrease.Position = UDim2.new(0.5,20,0,35)
BtnIncrease.MouseButton1Click:Connect(function()
    FlySpeed = FlySpeed + 5
    FlyLabel.Text = "Fly Speed: "..FlySpeed
end)

local BtnDecrease = Instance.new("TextButton", FlyFrame)
BtnDecrease.Text = "-"
BtnDecrease.Size = UDim2.new(0,30,0,30)
BtnDecrease.Position = UDim2.new(0.5,-50,0,35)
BtnDecrease.MouseButton1Click:Connect(function()
    FlySpeed = FlySpeed - 5
    FlyLabel.Text = "Fly Speed: "..FlySpeed
end)

-- Ativar/Desativar Fly
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode==Enum.KeyCode.F then
        FlyEnabled = not FlyEnabled
        FlyFrame.Visible = FlyEnabled
    end
end)

-- Movimento Fly
RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = Camera.CFrame
        local moveVector = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0,1,0) end
        hrp.CFrame = hrp.CFrame + moveVector.Unit * FlySpeed * RunService.RenderStepped:Wait()
    end
end)

local AutoFarmDelay = 2
local AutoFarmEnabled = false

spawn(function()
    while true do
        if AutoFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and obj.Name=="Coin" then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                    wait(AutoFarmDelay)
                end
            end
        end
        wait(0.1)
    end
end)

-- Remote Spy GUI
local RemoteSpyEnabled = false
local RemoteLogs = {}

local RemoteSpyFrame = Instance.new("Frame", ScreenGui)
RemoteSpyFrame.Size = UDim2.new(0,300,0,400)
RemoteSpyFrame.Position = UDim2.new(0,50,0,50)
RemoteSpyFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
RemoteSpyFrame.Visible = false

local RemoteList = Instance.new("ScrollingFrame", RemoteSpyFrame)
RemoteList.Size = UDim2.new(1,-10,1,-50)
RemoteList.Position = UDim2.new(0,5,0,5)
RemoteList.CanvasSize = UDim2.new(0,0,0,0)
RemoteList.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Função adicionar log
local function addRemoteLog(remoteName, action, args)
    local label = Instance.new("TextLabel", RemoteList)
    label.Size = UDim2.new(1,0,0,20)
    label.Text = remoteName.." | "..action.." | "..tostring(args)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    RemoteList.CanvasSize = UDim2.new(0,0,0,#RemoteList:GetChildren()*20)
end

-- Hook automático para Remote Spy
for _,remote in pairs(getgc(true)) do
    if type(remote)=="table" then
        for k,v in pairs(remote) do
            if typeof(v)=="Instance" and v:IsA("RemoteEvent") then
                local old = v.FireServer
                v.FireServer = function(...)
                    if RemoteSpyEnabled then addRemoteLog(v.Name,"FireServer",{...}) end
                    return old(...)
                end
            elseif typeof(v)=="Instance" and v:IsA("RemoteFunction") then
                local old = v.InvokeServer
                v.InvokeServer = function(...)
                    if RemoteSpyEnabled then addRemoteLog(v.Name,"InvokeServer",{...}) end
                    return old(...)
                end
            end
        end
    end
end

-- Teleport para jogador
local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHRP then
            hrp.CFrame = targetHRP.CFrame + Vector3.new(0,5,0)
        end
    end
end

-- Teleport para posição
local function teleportToPosition(pos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Server Hop / Rejoin
local function serverHop()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Skin Changer
local function changeSkin(id)
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("MeshPart") or part:IsA("Accessory") then
                part.TextureID = id
            end
        end
    end
end

-- Save / Load Config
local ConfigFolder = "SpectreHubConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder.."/config.json"

local function saveConfig(data) writefile(ConfigFile,HttpService:JSONEncode(data)) end
local function loadConfig()
    if isfile(ConfigFile) then
        return HttpService:JSONDecode(readfile(ConfigFile))
    else
        return {}
    end
end


createToggle(Tabs.Utilidades,"Auto Farm",function(state) AutoFarmEnabled=state end)
createIncrementer(Tabs.Utilidades,"Auto Farm Delay",AutoFarmDelay,0.1,function(val) AutoFarmDelay=val end)
createButton(Tabs.Utilidades,"Server Hop / Rejoin",function() serverHop() end)
createTextBox(Tabs.Utilidades,"Skin Changer (ID)",function(txt) changeSkin(txt) end)
createButton(Tabs.Utilidades,"Salvar Config",function()
    saveConfig({
        BunnyHop=BunnyHopEnabled, Strafe=StrafeEnabled, AutoCrouch=AutoCrouchEnabled,
        WallClimb=WallClimbEnabled, TeleportDash=TeleportDashEnabled, DashDistance=DashDistance,
        SilentAim=SilentAimEnabled, TriggerBot=TriggerBotEnabled, RapidFire=RapidFireEnabled, NoRecoil=NoRecoilEnabled, LockBone=LockBone,
        BoneESP=BoneESPEnabled, Radar=RadarEnabled, Crosshair=CrosshairEnabled, HitMarker=HitMarkerEnabled
    })
end)
createButton(Tabs.Utilidades,"Carregar Config",function()
    local cfg=loadConfig()
    -- Aplicar valores carregados
    BunnyHopEnabled=cfg.BunnyHop or BunnyHopEnabled
    StrafeEnabled=cfg.Strafe or StrafeEnabled
    AutoCrouchEnabled=cfg.AutoCrouch or AutoCrouchEnabled
    WallClimbEnabled=cfg.WallClimb or WallClimbEnabled
    TeleportDashEnabled=cfg.TeleportDash or TeleportDashEnabled
    DashDistance=cfg.DashDistance or DashDistance
    SilentAimEnabled=cfg.SilentAim or SilentAimEnabled
    TriggerBotEnabled=cfg.TriggerBot or TriggerBotEnabled
    RapidFireEnabled=cfg.RapidFire or RapidFireEnabled
    NoRecoilEnabled=cfg.NoRecoil or NoRecoilEnabled
    LockBone=cfg.LockBone or LockBone
    BoneESPEnabled=cfg.BoneESP or BoneESPEnabled
    RadarEnabled=cfg.Radar or RadarEnabled
    CrosshairEnabled=cfg.Crosshair or CrosshairEnabled
    HitMarkerEnabled=cfg.HitMarker or HitMarkerEnabled
end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0,255,0)
FOVCircle.Radius = 100
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = true

local FOVEnabled = true
local FOVRadius = 100

RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Incrementer GUI para FOV
createIncrementer(Tabs.Combate,"FOV Radius",FOVRadius,10,function(val) FOVRadius=val end)
createToggle(Tabs.Combate,"Enable FOV",function(state) FOVEnabled=state end)

-- Teleport atrás do jogador e kill
local function teleportBehindAndKill(targetPlayer)
    if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            -- Teleporta atrás
            myHRP.CFrame = targetHRP.CFrame - targetHRP.CFrame.LookVector*3
            wait(0.05)
            -- Atira / FireServer (TriggerBot simulado)
            for _,remote in pairs(RemoteEvents) do
                remote:FireServer(targetHRP.Position)
            end
        end
    end
end

createDropdown(Tabs.Combate,"Teleport & Kill",Players:GetPlayers(),function(selected)
    teleportBehindAndKill(selected)
end)

-- Aimbot avançado (só mira em inimigos vivos)
local AimbotEnabled = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- botão direito
        AimbotEnabled = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getTarget()
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(hrp.Position, target.Position)
        end
    end
end)

-- Rapid Kill (long distance)
local RapidKillEnabled = false
createToggle(Tabs.Combate,"Rapid Kill (LD)",function(state) RapidKillEnabled=state end)

RunService.RenderStepped:Connect(function()
    if RapidKillEnabled then
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,remote in pairs(RemoteEvents) do
                        remote:FireServer(hrp.Position)
                    end
                end
            end
        end
    end
end)

-- Gui Toggle para Extras
createToggle(Tabs.Combate,"Enable Aimbot",function(state) AimbotEnabled=state end)
createIncrementer(Tabs.Combate,"Teleport Dash Distance",DashDistance,5,function(val) DashDistance=val end)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI base
local DexGui = Instance.new("Frame", ScreenGui)
DexGui.Size = UDim2.new(0,450,0,500)
DexGui.Position = UDim2.new(1,-460,0,50)
DexGui.BackgroundColor3 = Color3.fromRGB(30,30,30)
DexGui.Visible = false
DexGui.Name = "SpectreDex"

-- Título
local DexTitle = Instance.new("TextLabel", DexGui)
DexTitle.Size = UDim2.new(1,0,0,30)
DexTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
DexTitle.Text = "Spectre Dex Explorer"
DexTitle.TextColor3 = Color3.fromRGB(255,255,255)
DexTitle.Font = Enum.Font.SourceSansBold
DexTitle.TextSize = 18

-- Scrolling Frame principal
local DexScroll = Instance.new("ScrollingFrame", DexGui)
DexScroll.Size = UDim2.new(1,-10,1,-40)
DexScroll.Position = UDim2.new(0,5,0,35)
DexScroll.CanvasSize = UDim2.new(0,0,0,0)
DexScroll.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Função criar item de Dex
local function createDexItem(parent,text,callback)
    local btn = Instance.new("TextButton",parent)
    btn.Size = UDim2.new(1,0,0,25)
    btn.Position = UDim2.new(0,0,#parent:GetChildren()*25)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(callback)
    DexScroll.CanvasSize = UDim2.new(0, 0, 0, #DexScroll:GetChildren() * 25)
    return btn
end

local function listWorkspaceObjects()
    -- Limpar itens antigos (exceto UIListLayout)
    for _, child in pairs(DexScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    -- Aqui você colocaria a lógica para listar objetos do workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then
            createDexItem(DexScroll, obj.Name, function()
                print("Selecionou: "..obj:GetFullName())
            end)
        end
    end
end

-- Função para listar jogadores
local function listPlayers()
    DexScroll:ClearAllChildren()
    for _,plr in pairs(Players:GetPlayers()) do
        createDexItem(DexScroll,plr.Name,function()
            print("Selecionou Player: "..plr.Name)
            -- Ações: teleport, remote spy, kill etc
        end)
    end
end

-- Função para Remote Spy Dex
local function listRemotes()
    DexScroll:ClearAllChildren()
    for _,remote in pairs(RemoteEvents) do
        createDexItem(DexScroll,"[Event] "..remote.Name,function()
            print("Selecionou Remote Event: "..remote.Name)
        end)
    end
    for _,remote in pairs(RemoteFunctions) do
        createDexItem(DexScroll,"[Function] "..remote.Name,function()
            print("Selecionou Remote Function: "..remote.Name)
        end)
    end
end

-- Botões superiores para mudar categorias
local btnWorkspace = Instance.new("TextButton",DexGui)
btnWorkspace.Size = UDim2.new(0,100,0,25)
btnWorkspace.Position = UDim2.new(0,5,0,0)
btnWorkspace.Text = "Workspace"
btnWorkspace.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnWorkspace.TextColor3 = Color3.fromRGB(255,255,255)
btnWorkspace.MouseButton1Click:Connect(listWorkspaceObjects)

local btnPlayers = Instance.new("TextButton",DexGui)
btnPlayers.Size = UDim2.new(0,100,0,25)
btnPlayers.Position = UDim2.new(0,110,0,0)
btnPlayers.Text = "Players"
btnPlayers.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnPlayers.TextColor3 = Color3.fromRGB(255,255,255)
btnPlayers.MouseButton1Click:Connect(listPlayers)

local btnRemotes = Instance.new("TextButton",DexGui)
btnRemotes.Size = UDim2.new(0,100,0,25)
btnRemotes.Position = UDim2.new(0,215,0,0)
btnRemotes.Text = "Remotes"
btnRemotes.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnRemotes.TextColor3 = Color3.fromRGB(255,255,255)
btnRemotes.MouseButton1Click:Connect(listRemotes)

-- Copiar e executar Remote
local function executeRemote(remote,args)
    if remote:IsA("RemoteEvent") then
        remote:FireServer(unpack(args))
    elseif remote:IsA("RemoteFunction") then
        remote:InvokeServer(unpack(args))
    end
end

local function copyRemote(remote)
    local txt = ""
    if remote:IsA("RemoteEvent") then
        txt = "RemoteEvent: "..remote.Name
    elseif remote:IsA("RemoteFunction") then
        txt = "RemoteFunction: "..remote.Name
    end
    setclipboard(txt)
end

-- Bloquear Remote (desativa temporariamente)
local BlockedRemotes = {}
local function blockRemote(remote)
    if not table.find(BlockedRemotes,remote) then
        table.insert(BlockedRemotes,remote)
        if remote:IsA("RemoteEvent") then
            local old = remote.FireServer
            remote.FireServer = function(...) end
        elseif remote:IsA("RemoteFunction") then
            local old = remote.InvokeServer
            remote.InvokeServer = function(...) end
        end
    end
end

-- Atualizar lista de Remotes com ações
local function listRemotesAdvanced()
    DexScroll:ClearAllChildren()
    for _,remote in pairs(RemoteEvents) do
        createDexItem(DexScroll,remote.Name,function()
            copyRemote(remote)
            executeRemote(remote,{})
            blockRemote(remote)
        end)
    end
    for _,remote in pairs(RemoteFunctions) do
        createDexItem(DexScroll,remote.Name,function()
            copyRemote(remote)
            executeRemote(remote,{})
            blockRemote(remote)
        end)
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Hooks avançados
local HookedRemotes = {}

-- Função para hook de RemoteEvents
local function hookRemoteEvent(remote)
    if HookedRemotes[remote] then return end
    local oldFire = remote.FireServer
    remote.FireServer = function(...)
        local args = {...}

        -- Silent Aim / TriggerBot
        if SilentAimEnabled or TriggerBotEnabled then
            local target = getTarget()
            if target then
                args[1] = target.Position -- substitui posição do tiro
            end
        end

        -- Rapid Fire
        if RapidFireEnabled then
            args[1] = args[1] or Vector3.new() -- garante argumento
        end

        return oldFire(unpack(args))
    end
    HookedRemotes[remote] = true
end

-- Função para hook de RemoteFunctions
local function hookRemoteFunction(remote)
    if HookedRemotes[remote] then return end
    local oldInvoke = remote.InvokeServer
    remote.InvokeServer = function(...)
        local args = {...}
        -- Aqui podemos manipular args se necessário
        return oldInvoke(unpack(args))
    end
    HookedRemotes[remote] = true
end

-- Hook automático de todos os Remotes atuais e futuros
for _,remote in pairs(RemoteEvents) do
    hookRemoteEvent(remote)
end
for _,remote in pairs(RemoteFunctions) do
    hookRemoteFunction(remote)
end

-- Captura de novos remotes
RunService.Stepped:Connect(function()
    for _,v in pairs(getgc(true)) do
        if type(v)=="table" then
            for k,b in pairs(v) do
                if typeof(b)=="Instance" and (b:IsA("RemoteEvent") or b:IsA("RemoteFunction")) then
                    if b:IsA("RemoteEvent") then
                        hookRemoteEvent(b)
                    else
                        hookRemoteFunction(b)
                    end
                end
            end
        end
    end
end)

local function teleportToPlayer(target)
    if LocalPlayer.Character and target.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = targetHrp.CFrame + Vector3.new(0,3,0)
        end
    end
end

-- Teleport atrás do jogador
local function teleportBehindPlayer(target, distance)
    if LocalPlayer.Character and target.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            local behind = targetHrp.CFrame * CFrame.new(0,0,-distance)
            --hrp.CFrame = behind
            hrp.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0,3,0) - targetHRP.CFrame.LookVector*distance)
        end
    end
end

-- Mata a longa distância (Hit Kill)
local function longDistanceKill(target)
    if LocalPlayer.Character and target.Character then
        for _,remote in pairs(RemoteEvents) do
            remote:FireServer(target.HumanoidRootPart.Position)
        end
    end
end

-- Hook de funções internas do jogador
local function hookPlayerFunctions()
    for _,v in pairs(getgc(true)) do
        if type(v)=="function" and tostring(v):find("Recoil") then
            hookfunction(v,function(...) return end)
        end
    end
end
hookPlayerFunctions()

-- Fly avançado
local FlyEnabled = false
local FlySpeed = 50

local function toggleFly(state)
    FlyEnabled = state
end

local function setFlySpeed(speed)
    FlySpeed = speed
end

RunService.RenderStepped:Connect(function(delta)
    if FlyEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if move.Magnitude > 0 then
                hrp.Velocity = move.Unit * FlySpeed
            else
                hrp.Velocity = Vector3.new()
            end
            hrp.Anchored = true

        end
    elseif LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end
end)

-- GUI Fly
local FlyTab = Tabs.Movimento
createToggle(FlyTab,"Fly",function(state) toggleFly(state) end)
createIncrementer(FlyTab,"Fly Speed",FlySpeed,5,function(val) setFlySpeed(val) end)


local function remoteSpy(remote)
    if not RemoteLogs[remote] then RemoteLogs[remote] = {} end
    table.insert(RemoteLogs[remote], args)
    if #RemoteLogs[remote] > 100 then table.remove(RemoteLogs[remote], 1) end
    local oldFire = remote.FireServer
    remote.FireServer = function(...)
        local args = {...}
        table.insert(RemoteLogs[remote],args)
        print("Remote Fired:",remote.Name,unpack(args))
        return oldFire(...)
    end
end

local function setupRemoteSpy()
    for _,remote in pairs(RemoteEvents) do
        remoteSpy(remote)
    end
end
setupRemoteSpy()

-- GUI Remote Spy
local UtilTab = Tabs.Utilidades
createButton(UtilTab,"Abrir Remote Logs",function()
    DexGui.Visible = true
    listRemotesAdvanced()
end)


local CombateTab = Tabs.Combate
createButton(CombateTab,"TP + Kill",function()
    local target = getTarget()
    if target then
        teleportBehindPlayer(target,2)
        longDistanceKill(target)
    end
end)

-- Status final hooks
print("[Spectre Hub] Parte 8 carregada: Hooks automáticos, Fly, Remote Spy e TP+Kill prontos!")


local RandomTPEnabled = false
local RandomTPDelay = 5 -- segundos

-- Função para pegar inimigo aleatório
local function getRandomEnemy()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(enemies, player)
            end
        end
    end
    if #enemies > 0 then
        local index = math.random(1,#enemies)
        return enemies[index]
    else
        return nil
    end
end


local function randomTeleportEnemy()
    local enemy = getRandomEnemy()
    if enemy and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local enemyHrp = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
        if hrp and enemyHrp then
            local offset = Vector3.new(math.random(-10,10),0,math.random(-10,10))
            enemyHrp.CFrame = hrp.CFrame + offset
        end
    end
end

-- Loop para teleportar aleatoriamente
spawn(function()
    while true do
        if (enemyHrp.Position - hrp.Position).Magnitude > 5 then
            enemyHrp.CFrame = hrp.CFrame + offset
        end

    end
end)

-- GUI
local UtilTab = Tabs.Utilidades
createToggle(UtilTab,"Random TP Enemy",function(state)
    RandomTPEnabled = state
end)
createIncrementer(UtilTab,"TP Delay",RandomTPDelay,0.5,function(val)
    RandomTPDelay = val
end)

print("[Spectre Hub] Parte 9 carregada: Random TP Enemy pronto!")


local TeamAimEnabled = false
local TeamAimFOV = 100 -- pixels de distância no FOV
local TeamAimBone = "Head"

-- Função para pegar o alvo mais próximo dentro do FOV, incluindo aliados
local function getClosestPlayerAllTeams()
    local closestPlayer = nil
    local shortestDist = TeamAimFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlayer = hrp
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Hook para Silent Aim / Team Aim
RunService.RenderStepped:Connect(function()
    if TeamAimEnabled then
        local target = getClosestPlayerAllTeams()
        if target then
            for _,remote in pairs(RemoteEvents) do
                -- Fire para posição do bone selecionado
                pcall(function()
                    remote:FireServer(target.Position)
                end)

            end
        end
    end
end)

-- GUI
local CombatTab = Tabs.Combate
createToggle(CombatTab,"Team Aim (All Players)",function(state)
    TeamAimEnabled = state
end)
createIncrementer(CombatTab,"Team Aim FOV",TeamAimFOV,10,function(val)
    TeamAimFOV = val
end)
createDropdown(CombatTab,"Team Aim Bone",{"Head","Chest","HumanoidRootPart"},function(selected)
    TeamAimBone = selected
end)

print("[Spectre Hub] Parte 10 carregada: Team-Aware Aimbot pronto!")
