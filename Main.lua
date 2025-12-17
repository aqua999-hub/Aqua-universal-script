-- AQUA HUB V12 [TRUE VAPE CLONE + SETTINGS]
-- Features: 3-Dot Settings Menu, Custom Sliders, Full Module List.

-- 1. CLEANUP
if getgenv().AquaVape then getgenv().AquaVape:Destroy() end

-- 2. SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 3. THEME & CONFIG
local Theme = {
    Main = Color3.fromRGB(23, 23, 23),
    Secondary = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(6, 215, 120), -- Vape Green
    Text = Color3.fromRGB(220, 220, 220),
    Placeholder = Color3.fromRGB(150, 150, 150)
}

-- Store Settings Values Globally
getgenv().VapeConfig = {
    Killaura = {Range = 18, Rotation = true},
    SilentAim = {FOV = 200, Headshot = true},
    Fly = {Speed = 50, Vertical = false},
    Speed = {Value = 30, Jump = false},
    Spider = {Speed = 30},
    ESP = {Red = 0, Green = 1, Blue = 0.5}, -- RGB 0-1
    Hitbox = {Size = 5}
}

-- 4. UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AquaVapeV12"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) then else ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
getgenv().AquaVape = ScreenGui

-- 5. HUD (Array List)
local ArrayFrame = Instance.new("Frame", ScreenGui)
ArrayFrame.Name = "ArrayList"; ArrayFrame.Size = UDim2.new(0, 200, 1, -20); ArrayFrame.Position = UDim2.new(1, -210, 0, 10); ArrayFrame.BackgroundTransparency = 1
local ArrayListLayout = Instance.new("UIListLayout", ArrayFrame)
ArrayListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ArrayListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right; ArrayListLayout.Padding = UDim.new(0, 2)
local ActiveModules = {}

local function UpdateArray(name, enabled)
    if enabled then
        if not ActiveModules[name] then
            local T = Instance.new("TextLabel", ArrayFrame)
            T.Text = string.upper(name); T.Font = Enum.Font.GothamBold; T.TextSize = 20; T.TextColor3 = Theme.Accent; T.BackgroundTransparency = 1; T.Size = UDim2.new(0,0,0,25); T.AutomaticSize = Enum.AutomaticSize.X; T.TextXAlignment = Enum.TextXAlignment.Right
            ActiveModules[name] = T
            T.TextTransparency = 1; TweenService:Create(T, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end
    else
        if ActiveModules[name] then ActiveModules[name]:Destroy(); ActiveModules[name] = nil end
    end
end

-- 6. SETTINGS MENU GENERATOR
local SettingsFrame = nil -- Only one settings menu open at a time

local function OpenSettings(moduleName, configTable)
    if SettingsFrame then SettingsFrame:Destroy() end
    
    SettingsFrame = Instance.new("Frame", ScreenGui)
    SettingsFrame.Name = "Settings_" .. moduleName
    SettingsFrame.Size = UDim2.new(0, 200, 0, 0) -- Auto size Y
    SettingsFrame.Position = UDim2.new(0.5, -100, 0.5, -100) -- Center Screen
    SettingsFrame.BackgroundColor3 = Theme.Main
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.AutomaticSize = Enum.AutomaticSize.Y
    SettingsFrame.Active = true; SettingsFrame.Draggable = true
    
    Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 6)
    local List = Instance.new("UIListLayout", SettingsFrame); List.SortOrder = Enum.SortOrder.LayoutOrder; List.Padding = UDim.new(0, 5)
    local Pad = Instance.new("UIPadding", SettingsFrame); Pad.PaddingTop = UDim.new(0,10); Pad.PaddingBottom = UDim.new(0,10); Pad.PaddingLeft = UDim.new(0,10); Pad.PaddingRight = UDim.new(0,10)
    
    -- Header
    local Header = Instance.new("TextLabel", SettingsFrame)
    Header.Text = moduleName .. " Settings"
    Header.Font = Enum.Font.GothamBold; Header.TextSize = 18; Header.TextColor3 = Theme.Accent; Header.BackgroundTransparency = 1; Header.Size = UDim2.new(1,0,0,30)
    
    -- Close Button
    local Close = Instance.new("TextButton", SettingsFrame)
    Close.Text = "Close"; Close.Size = UDim2.new(1,0,0,30); Close.BackgroundColor3 = Theme.Secondary; Close.TextColor3 = Theme.Text
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0,4)
    Close.MouseButton1Click:Connect(function() SettingsFrame:Destroy(); SettingsFrame = nil end)

    -- GENERATE CONTROLS BASED ON CONFIG TABLE
    for key, val in pairs(configTable) do
        if type(val) == "number" then
            -- SLIDER
            local SFrame = Instance.new("Frame", SettingsFrame); SFrame.Size = UDim2.new(1,0,0,40); SFrame.BackgroundTransparency = 1
            local SLabel = Instance.new("TextLabel", SFrame); SLabel.Text = key .. ": " .. val; SLabel.TextColor3 = Theme.Text; SLabel.Size = UDim2.new(1,0,0,20); SLabel.BackgroundTransparency = 1
            
            local SliderBox = Instance.new("TextButton", SFrame); SliderBox.Text = ""; SliderBox.Size = UDim2.new(1,0,0,10); SliderBox.Position = UDim2.new(0,0,0,25); SliderBox.BackgroundColor3 = Theme.Secondary
            local Fill = Instance.new("Frame", SliderBox); Fill.Size = UDim2.new(math.clamp(val/100, 0, 1), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Fill.BorderSizePixel = 0
            
            -- Simple Slider Logic (Click to set)
            SliderBox.MouseButton1Click:Connect(function()
                 -- Increment for simplicity on mobile tap (Cycle 1-100)
                 local newVal = configTable[key] + 10
                 if newVal > 150 then newVal = 1 end
                 configTable[key] = newVal
                 Fill.Size = UDim2.new(math.clamp(newVal/100, 0, 1), 0, 1, 0)
                 SLabel.Text = key .. ": " .. newVal
            end)
            
        elseif type(val) == "boolean" then
            -- TOGGLE
            local TBtn = Instance.new("TextButton", SettingsFrame)
            TBtn.Size = UDim2.new(1,0,0,30); TBtn.BackgroundColor3 = val and Theme.Accent or Theme.Secondary
            TBtn.Text = key .. ": " .. (val and "ON" or "OFF")
            TBtn.TextColor3 = val and Color3.new(0,0,0) or Theme.Text
            Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0,4)
            
            TBtn.MouseButton1Click:Connect(function()
                configTable[key] = not configTable[key]
                local newVal = configTable[key]
                TBtn.BackgroundColor3 = newVal and Theme.Accent or Theme.Secondary
                TBtn.Text = key .. ": " .. (newVal and "ON" or "OFF")
                TBtn.TextColor3 = newVal and Color3.new(0,0,0) or Theme.Text
            end)
        end
    end
    
    Close.Parent = SettingsFrame -- Move close to bottom
end

-- 7. WINDOW & MODULE CREATOR
local function CreateWindow(name, x, y)
    local Win = Instance.new("Frame", ScreenGui)
    Win.Name = name; Win.Size = UDim2.new(0, 150, 0, 35); Win.Position = UDim2.new(0, x, 0, y); Win.BackgroundColor3 = Theme.Main; Win.Active = true; Win.Draggable = true
    local Title = Instance.new("TextLabel", Win); Title.Text = name; Title.Size = UDim2.new(1,-10,1,0); Title.Position = UDim2.new(0,10,0,0); Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = Enum.TextXAlignment.Left
    local Container = Instance.new("Frame", Win); Container.Size = UDim2.new(1,0,0,0); Container.Position = UDim2.new(0,0,1,0); Container.BackgroundColor3 = Theme.Secondary; Container.AutomaticSize = Enum.AutomaticSize.Y
    local Layout = Instance.new("UIListLayout", Container); Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Expand/Collapse
    local ExpBtn = Instance.new("TextButton", Win); ExpBtn.Text = "-"; ExpBtn.Size = UDim2.new(0,30,0,35); ExpBtn.Position = UDim2.new(1,-30,0,0); ExpBtn.BackgroundTransparency = 1; ExpBtn.TextColor3 = Theme.Accent; ExpBtn.TextSize = 20
    local Expanded = true
    ExpBtn.MouseButton1Click:Connect(function() Expanded = not Expanded; Container.Visible = Expanded; ExpBtn.Text = Expanded and "-" or "+" end)
    
    return Container
end

local function CreateModule(parent, name, callback, settingsTable)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,35); Btn.BackgroundColor3 = Theme.Secondary; Btn.Text = ""; Btn.BorderSizePixel = 0
    local Title = Instance.new("TextLabel", Btn); Title.Text = name; Title.Size = UDim2.new(1,-30,1,0); Title.Position = UDim2.new(0,10,0,0); Title.BackgroundTransparency = 1; Title.TextColor3 = Theme.Text; Title.Font = Enum.Font.Gotham; Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 3 Dots Button
    local Dots = Instance.new("TextButton", Btn)
    Dots.Text = "⋮"; Dots.Size = UDim2.new(0,30,1,0); Dots.Position = UDim2.new(1,-30,0,0); Dots.BackgroundTransparency = 1; Dots.TextColor3 = Theme.Placeholder; Dots.TextSize = 18
    
    local Enabled = false
    
    Btn.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Btn.BackgroundColor3 = Enabled and Theme.Main or Theme.Secondary
        Title.TextColor3 = Enabled and Theme.Accent or Theme.Text
        UpdateArray(name, Enabled)
        task.spawn(function() callback(Enabled) end)
    end)
    
    Dots.MouseButton1Click:Connect(function()
        if settingsTable then OpenSettings(name, settingsTable) else warn("No settings for " .. name) end
    end)
end

-- 8. V4 TOGGLE BUTTON
local V4Btn = Instance.new("TextButton", ScreenGui); V4Btn.Text = "V4"; V4Btn.Size = UDim2.new(0,50,0,50); V4Btn.Position = UDim2.new(0,10,0,10); V4Btn.BackgroundColor3 = Theme.Main; V4Btn.TextColor3 = Theme.Accent; V4Btn.Font = Enum.Font.Sarpanch; V4Btn.TextSize = 24
Instance.new("UICorner", V4Btn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", V4Btn).Color = Theme.Accent; Instance.new("UIStroke", V4Btn).Thickness = 2
local UIOn = true
V4Btn.MouseButton1Click:Connect(function() UIOn = not UIOn; for _,v in pairs(ScreenGui:GetChildren()) do if v.Name~="VapeToggle" and v~=V4Btn and v~=ArrayFrame then v.Visible = UIOn end end end)


-- ==============================
--         MODULES
-- ==============================

local Combat = CreateWindow("Combat", 50, 70)
local Blatant = CreateWindow("Blatant", 220, 70)
local Render = CreateWindow("Render", 390, 70)
local Utility = CreateWindow("Utility", 560, 70)

-- [[ COMBAT ]]
CreateModule(Combat, "Killaura", function(state)
    while state and ActiveModules["Killaura"] do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local range = getgenv().VapeConfig.Killaura.Range or 18
                if (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < range then
                    if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                        LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                    end
                end
            end
        end
        task.wait(0.1)
    end
end, getgenv().VapeConfig.Killaura)

CreateModule(Combat, "SilentAim", function(state)
    local Run = RunService.RenderStepped:Connect(function()
        if state and ActiveModules["SilentAim"] then
            local fov = getgenv().VapeConfig.SilentAim.FOV
            local closest, max = nil, fov
            local m = UserInputService:GetMouseLocation()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToScreenPoint(p.Character.Head.Position)
                    if vis then
                        local d = (Vector2.new(m.X,m.Y) - Vector2.new(pos.X,pos.Y)).Magnitude
                        if d < max then max = d; closest = p.Character.Head end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        else
            -- Break connection if module off is handled by checking activemodules
        end
    end)
    -- Cleanup logic simplified for demo
end, getgenv().VapeConfig.SilentAim)

CreateModule(Combat, "Hitboxes", function(state)
    while state and ActiveModules["Hitboxes"] do
        local sz = getgenv().VapeConfig.Hitbox.Size
        for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(sz,sz,sz); p.Character.Head.Transparency = 0.5; p.Character.Head.CanCollide = false
            end
        end
        task.wait(1)
    end
end, getgenv().VapeConfig.Hitbox)


-- [[ BLATANT ]]
CreateModule(Blatant, "Fly", function(state)
    local bv, bg
    if state then
        local root = LocalPlayer.Character.HumanoidRootPart
        bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        while state and ActiveModules["Fly"] do
            if not LocalPlayer.Character then break end
            local spd = getgenv().VapeConfig.Fly.Speed
            local cam = Camera.CFrame
            local move = LocalPlayer.Character.Humanoid.MoveDirection
            bv.Velocity = (move * spd) + Vector3.new(0, cam.LookVector.Y * spd, 0)
            bg.CFrame = Camera.CFrame
            task.wait()
        end
        bv:Destroy(); bg:Destroy()
    end
end, getgenv().VapeConfig.Fly)

CreateModule(Blatant, "Speed", function(state)
    while state and ActiveModules["Speed"] do
        local hum = LocalPlayer.Character.Humanoid
        local root = LocalPlayer.Character.HumanoidRootPart
        local spd = getgenv().VapeConfig.Speed.Value
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (spd/50))
        end
        task.wait()
    end
end, getgenv().VapeConfig.Speed)

CreateModule(Blatant, "Spider", function(state)
    while state and ActiveModules["Spider"] do
        local char = LocalPlayer.Character
        local ray = Ray.new(char.Head.Position, char.Head.CFrame.LookVector * 2)
        if Workspace:FindPartOnRay(ray, char) then
            char.HumanoidRootPart.Velocity = Vector3.new(0, getgenv().VapeConfig.Spider.Speed, 0)
        end
        task.wait()
    end
end, getgenv().VapeConfig.Spider)

CreateModule(Blatant, "Phase", function(state) -- Noclip
    while state and ActiveModules["Phase"] do
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        task.wait()
    end
end, nil)


-- [[ RENDER ]]
CreateModule(Render, "ESP", function(state)
    while state and ActiveModules["ESP"] do
        local col = Color3.new(getgenv().VapeConfig.ESP.Red, getgenv().VapeConfig.ESP.Green, getgenv().VapeConfig.ESP.Blue)
        for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("VapeESP") then
                    local h = Instance.new("Highlight", p.Character); h.Name="VapeESP"; h.FillTransparency=0.5
                end
                p.Character.VapeESP.FillColor = col
            end
        end
        task.wait(1)
    end
    -- Cleanup
    if not state then
        for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("VapeESP") then p.Character.VapeESP:Destroy() end end
    end
end, getgenv().VapeConfig.ESP)

CreateModule(Render, "Fullbright", function(state)
    game.Lighting.Brightness = state and 2 or 1
    game.Lighting.ClockTime = state and 14 or 12
    game.Lighting.GlobalShadows = not state
end, nil)

-- [[ UTILITY ]]
CreateModule(Utility, "AntiVoid", function(state)
    if state then
        local p = Instance.new("Part", Workspace); p.Name="AV"; p.Size=Vector3.new(2000,1,2000); p.Anchored=true; p.Position=Vector3.new(0,-100,0)
        while state and ActiveModules["AntiVoid"] and p.Parent do
            p.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -100, LocalPlayer.Character.HumanoidRootPart.Position.Z)
            task.wait(0.1)
        end
        p:Destroy()
    end
end, nil)

CreateModule(Utility, "SpinBot", function(state)
    if state then
        local s = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); s.Name="Spin"; s.MaxTorque=Vector3.new(0,math.huge,0); s.AngularVelocity=Vector3.new(0,50,0)
    else
        if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Spin") then LocalPlayer.Character.HumanoidRootPart.Spin:Destroy() end
    end
end, nil)

