-- AQUA HUB V10 [RAYFIELD VAPE EDITION]
-- The "Good Old Rayfield" UI with Vape V4 Features inside.

-- 1. CLEANUP
if getgenv().AquaUI then
    pcall(function() getgenv().AquaUI:Destroy() end)
end

-- 2. LOAD FUNCTION (For Theme Switching)
local function LoadAquaHub(selectedTheme)
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- 3. LOAD RAYFIELD
    local success, library = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)

    if not success then return warn("Rayfield Failed to Load") end
    getgenv().AquaUI = library

    -- 4. CREATE WINDOW
    local Window = library:CreateWindow({
       Name = "Aqua Hub V10",
       LoadingTitle = "Loading Vape Modules...",
       LoadingSubtitle = "By Gemini",
       ConfigurationSaving = { Enabled = true, FolderName = "AquaHubV10", FileName = "ConfigV10" },
       Discord = { Enabled = true, Invite = "RCmMvZjC7m", RememberJoins = true },
       KeySystem = true, 
       KeySettings = {
          Title = "Aqua Hub Login",
          Subtitle = "Key System",
          Note = "Key: test1",
          FileName = "AquaKeyV10",
          SaveKey = true,
          GrabKeyFromSite = false, 
          Key = {"test1"} 
       },
       Theme = selectedTheme or "Green" -- Default to Vape Green
    })

    -- 5. TABS
    local CombatTab = Window:CreateTab("Combat", 4483362458)
    local BlatantTab = Window:CreateTab("Blatant", 4483362458)
    local VisualTab = Window:CreateTab("Visuals", 4483362458)
    local WorldTab = Window:CreateTab("World", 4483362458)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)


    -- ==============================
    --        COMBAT TAB
    -- ==============================
    CombatTab:CreateSection("Aim Assistance")

    local aimbot = false
    local aimDist = 200

    CombatTab:CreateToggle({
        Name = "Silent Aim (Camera Lock)",
        CurrentValue = false,
        Flag = "SilentAim",
        Callback = function(Value) aimbot = Value end
    })

    CombatTab:CreateSlider({
        Name = "Aim Range", Range = {50, 1000}, Increment = 10, CurrentValue = 200,
        Callback = function(Value) aimDist = Value end
    })

    RunService.RenderStepped:Connect(function()
        if aimbot then
            local closest = nil
            local maxDist = aimDist
            local mousePos = UserInputService:GetMouseLocation()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToScreenPoint(p.Character.Head.Position)
                    if vis then
                        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = p.Character.Head
                        end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        end
    end)

    CombatTab:CreateSection("Hitbox")
    local bigHead = false
    CombatTab:CreateToggle({
        Name = "Hitbox Expander (Big Head)",
        CurrentValue = false,
        Callback = function(Value)
            bigHead = Value
            if not Value then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Head") then
                        p.Character.Head.Size = Vector3.new(1.2, 1, 1); p.Character.Head.Transparency = 0
                    end
                end
            end
        end
    })
    
    RunService.RenderStepped:Connect(function()
        if bigHead then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = Vector3.new(5, 5, 5)
                    p.Character.Head.Transparency = 0.5
                    p.Character.Head.CanCollide = false
                end
            end
        end
    end)


    -- ==============================
    --       BLATANT TAB
    -- ==============================
    BlatantTab:CreateSection("Movement")

    -- SPEED
    local speedEnabled = false
    local speedVal = 25
    BlatantTab:CreateToggle({
        Name = "Speed (CFrame)",
        CurrentValue = false,
        Callback = function(Value) speedEnabled = Value end
    })
    BlatantTab:CreateSlider({ Name = "Speed Value", Range = {16, 100}, Increment = 1, CurrentValue = 25, Callback = function(V) speedVal = V end })
    
    RunService.Stepped:Connect(function()
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (LocalPlayer.Character.Humanoid.MoveDirection * speedVal/50)
            end
        end
    end)

    -- FLY
    local flyEnabled = false
    local flySpeed = 50
    local bv, bg
    BlatantTab:CreateToggle({
        Name = "Fly (Velocity)",
        CurrentValue = false,
        Callback = function(Value)
            flyEnabled = Value
            local char = LocalPlayer.Character
            if flyEnabled and char and char:FindFirstChild("HumanoidRootPart") then
                bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge); bv.Velocity = Vector3.new(0,0,0)
                bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.CFrame = char.HumanoidRootPart.CFrame
                task.spawn(function()
                    while flyEnabled and char:FindFirstChild("Humanoid") do
                        local cam = Camera.CFrame
                        local move = char.Humanoid.MoveDirection
                        if move.Magnitude > 0 then
                            bv.Velocity = (move * flySpeed) + Vector3.new(0, cam.LookVector.Y * flySpeed, 0)
                        else bv.Velocity = Vector3.new(0,0,0) end
                        bg.CFrame = Camera.CFrame
                        task.wait()
                    end
                    if bv then bv:Destroy() end; if bg then bg:Destroy() end
                end)
            else
                if bv then bv:Destroy() end; if bg then bg:Destroy() end
            end
        end
    })
    BlatantTab:CreateSlider({ Name = "Fly Speed", Range = {20, 150}, Increment = 5, CurrentValue = 50, Callback = function(V) flySpeed = V end })

    -- SPIDER
    local spider = false
    BlatantTab:CreateToggle({
        Name = "Spider (Climb Walls)",
        CurrentValue = false,
        Callback = function(Value) spider = Value end
    })
    RunService.Stepped:Connect(function()
        if spider and LocalPlayer.Character then
            local head = LocalPlayer.Character:FindFirstChild("Head")
            if head then
                local ray = Ray.new(head.Position, head.CFrame.LookVector * 2)
                local hit, _ = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hit then LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 30, 0) end
            end
        end
    end)
    
    -- NOFALL
    local nofall = false
    BlatantTab:CreateToggle({
        Name = "NoFall",
        CurrentValue = false,
        Callback = function(Value) nofall = Value end
    })
    RunService.Stepped:Connect(function()
        if nofall and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character.HumanoidRootPart.Velocity.Y < -50 then
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Velocity.X, 0, LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
            end
        end
    end)


    -- ==============================
    --       VISUALS TAB
    -- ==============================
    VisualTab:CreateSection("Render")

    local esp = false
    local chams = false
    local espColor = Color3.fromRGB(13, 255, 120)

    VisualTab:CreateToggle({
        Name = "Chams / ESP",
        CurrentValue = false,
        Callback = function(Value)
            esp = Value
            if not Value then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("VapeGlow") then p.Character.VapeGlow:Destroy() end
                end
            end
        end
    })

    VisualTab:CreateColorPicker({
        Name = "ESP Color", Color = Color3.fromRGB(13, 255, 120),
        Callback = function(Value) espColor = Value end
    })

    -- Visual Loop
    task.spawn(function()
        while true do
            task.wait(0.5)
            if esp then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        if not p.Character:FindFirstChild("VapeGlow") then
                            local hl = Instance.new("Highlight", p.Character)
                            hl.Name = "VapeGlow"
                            hl.FillColor = espColor
                            hl.OutlineColor = Color3.new(1,1,1)
                            hl.FillTransparency = 0.5
                        else
                            p.Character.VapeGlow.FillColor = espColor
                        end
                    end
                end
            end
        end
    end)


    -- ==============================
    --        WORLD TAB
    -- ==============================
    WorldTab:CreateSection("Server")

    WorldTab:CreateToggle({
        Name = "Anti-Void",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                local p = Instance.new("Part", Workspace); p.Name = "AntiVoid"; p.Size = Vector3.new(2048, 1, 2048); p.Position = Vector3.new(0, -100, 0); p.Anchored = true; p.Transparency = 0.5; p.Color = espColor
                task.spawn(function()
                    while p.Parent do
                        if LocalPlayer.Character then p.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -100, LocalPlayer.Character.HumanoidRootPart.Position.Z) end
                        task.wait(0.1)
                    end
                end)
            else
                if Workspace:FindFirstChild("AntiVoid") then Workspace.AntiVoid:Destroy() end
            end
        end
    })


    -- ==============================
    --       SETTINGS TAB
    -- ==============================
    SettingsTab:CreateSection("Themes")
    
    local themes = {"Green", "Ocean", "DarkBlue", "Amber", "Light", "Default"}
    SettingsTab:CreateDropdown({
        Name = "Select Theme",
        Options = themes,
        CurrentOption = selectedTheme or "Green",
        Callback = function(Option)
            library:Destroy()
            LoadAquaHub(Option)
        end
    })
    
    SettingsTab:CreateButton({Name = "Unload UI", Callback = function() library:Destroy() end})
    
    library:Notify({Title="Aqua Hub V10", Content="Vape Features Loaded in Rayfield", Duration=5, Image=4483362458})
end

-- Start
LoadAquaHub("Green")

