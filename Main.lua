-- AQUA HUB V5 (Fixed Rayfield Edition)
-- Changelog: Advanced Teleport, Spectate, Click TP, Server Hop, Chat Spam

-- Global variable to prevent multiple UIs running at once
if getgenv().AquaHubLoaded then
    warn("Aqua Hub is already running!")
    return
end

local function LoadAquaHub(selectedTheme)
    -- Unload old instance if it exists to fix theme bugs
    if getgenv().AquaUI then
        getgenv().AquaUI:Destroy()
    end

    -- 1. Load Rayfield Library
    local success, library = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)

    if not success then
        warn("Failed to load library. Check internet.")
        return
    end
    
    getgenv().AquaUI = library

    -- 2. Create Window
    local Window = library:CreateWindow({
       Name = "Aqua Hub V5",
       LoadingTitle = "Loading V5...",
       LoadingSubtitle = "By Gemini",
       ConfigurationSaving = {
          Enabled = true,
          FolderName = "AquaHub", 
          FileName = "AquaConfig"
       },
       Discord = {
          Enabled = true,
          Invite = "RCmMvZjC7m", 
          RememberJoins = true 
       },
       KeySystem = true, 
       KeySettings = {
          Title = "Aqua Hub Login",
          Subtitle = "Key System",
          Note = "join discord for key https://discord.gg/RCmMvZjC7m",
          FileName = "AquaKey",
          SaveKey = true,
          GrabKeyFromSite = false, 
          Key = {"test1"} 
       },
       Theme = selectedTheme or "Ocean"
    })

    -- 3. Create Tabs
    local MainTab = Window:CreateTab("Main", 4483362458)
    local CombatTab = Window:CreateTab("Combat", 4483362458) 
    local VisualTab = Window:CreateTab("Visuals", 4483362458)
    local TrollTab = Window:CreateTab("Troll", 4483362458)
    local MiscTab = Window:CreateTab("Misc", 4483362458)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    -- ==============================
    --        MAIN TAB
    -- ==============================
    MainTab:CreateSection("Movement")

    MainTab:CreateSlider({
       Name = "WalkSpeed",
       Range = {16, 500}, Increment = 1, Suffix = "Speed", CurrentValue = 16,
       Callback = function(Value)
          if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = Value end
       end,
    })
    
    MainTab:CreateSlider({
       Name = "JumpPower",
       Range = {50, 500}, Increment = 1, Suffix = "Power", CurrentValue = 50,
       Callback = function(Value)
          if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = Value end
       end,
    })

    -- CLICK TP (Tool)
    MainTab:CreateButton({
        Name = "Give Click TP Tool",
        Callback = function()
            local tool = Instance.new("Tool")
            tool.Name = "Click TP"
            tool.RequiresHandle = false
            tool.Parent = LocalPlayer.Backpack
            
            tool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                if mouse.Target then
                    local pos = mouse.Hit.Position
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    end
                end
            end)
            library:Notify({Title="Success", Content="Check your backpack!", Duration=3})
        end
    })

    -- NOCLIP & FLY (Standard)
    local noclip = false
    RunService.Stepped:Connect(function()
        if noclip and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    MainTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "Noclip",
        Callback = function(Value) noclip = Value end
    })

    local flying, flySpeed, bv, bg = false, 50, nil, nil
    MainTab:CreateToggle({
       Name = "Fly (Mobile Optimized)",
       CurrentValue = false,
       Flag = "FlyToggle", 
       Callback = function(Value)
          flying = Value
          local char = LocalPlayer.Character
          local root = char and char:FindFirstChild("HumanoidRootPart")
          local hum = char and char:FindFirstChild("Humanoid")
          if flying and root and hum then
             bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0,0,0)
             bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.CFrame = root.CFrame
             task.spawn(function()
                while flying and char and hum.Health > 0 do
                   local cam = workspace.CurrentCamera
                   local move = hum.MoveDirection
                   if move.Magnitude > 0 then
                      bv.Velocity = (move * flySpeed) + Vector3.new(0, cam.CFrame.LookVector.Y * flySpeed, 0)
                   else bv.Velocity = Vector3.new(0,0,0) end
                   bg.CFrame = cam.CFrame
                   task.wait()
                end
             end)
          else
             if bv then bv:Destroy() end; if bg then bg:Destroy() end; if hum then hum.PlatformStand = false end
          end
       end,
    })


    -- ==============================
    --       COMBAT TAB
    -- ==============================
    CombatTab:CreateSection("PVP Advantage")

    local bigHead = false
    local headSize = 5
    local function UpdateHitbox()
        if not bigHead then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(headSize, headSize, headSize)
                p.Character.Head.Transparency = 0.5; p.Character.Head.CanCollide = false
            end
        end
    end
    RunService.RenderStepped:Connect(UpdateHitbox)

    CombatTab:CreateToggle({
        Name = "Hitbox Expander (Big Head)",
        CurrentValue = false,
        Callback = function(Value)
            bigHead = Value
            if not Value then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        p.Character.Head.Size = Vector3.new(1.2, 1, 1); p.Character.Head.Transparency = 0
                    end
                end
            end
        end
    })
    
    local aimbot = false
    CombatTab:CreateToggle({
        Name = "Camera Aimbot (Lock)",
        CurrentValue = false,
        Callback = function(Value) aimbot = Value end
    })
    
    RunService.RenderStepped:Connect(function()
        if aimbot then
            local cam = workspace.CurrentCamera
            local closest = nil
            local maxDist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, visible = cam:WorldToScreenPoint(p.Character.Head.Position)
                    if visible then
                        local dist = (Vector2.new(game.UserInputService:GetMouseLocation().X, game.UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < maxDist then maxDist = dist; closest = p.Character.Head end
                    end
                end
            end
            if closest then cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Position) end
        end
    end)


    -- ==============================
    --       VISUALS TAB
    -- ==============================
    VisualTab:CreateSection("ESP Settings")

    local espEnabled, tracersEnabled, espColor = false, false, Color3.fromRGB(255, 0, 0)

    local function UpdateESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("AquaHighlight")
                if espEnabled then
                    if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "AquaHighlight" end
                    hl.FillColor = espColor; hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.FillTransparency = 0.5
                else if hl then hl:Destroy() end end
                
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if tracersEnabled and hrp then
                    local beam = hrp:FindFirstChild("AquaBeam")
                    if not beam then
                        local a1 = Instance.new("Attachment", hrp)
                        local a2 = Instance.new("Attachment", LocalPlayer.Character:WaitForChild("HumanoidRootPart"))
                        beam = Instance.new("Beam", hrp); beam.Name = "AquaBeam"; beam.Attachment0 = a1; beam.Attachment1 = a2
                        beam.Width0 = 0.1; beam.Width1 = 0.1; beam.Color = ColorSequence.new(espColor)
                    end
                else if hrp and hrp:FindFirstChild("AquaBeam") then hrp.AquaBeam:Destroy() end end
            end
        end
    end
    RunService.RenderStepped:Connect(function() if espEnabled or tracersEnabled then UpdateESP() end end)

    VisualTab:CreateToggle({Name = "ESP (Wallhack)", CurrentValue = false, Callback = function(V) espEnabled = V; UpdateESP() end})
    VisualTab:CreateToggle({Name = "Tracers", CurrentValue = false, Callback = function(V) tracersEnabled = V; UpdateESP() end})
    VisualTab:CreateColorPicker({Name = "Visuals Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(V) espColor = V; UpdateESP() end})
    
    VisualTab:CreateSection("HUD")
    VisualTab:CreateToggle({
        Name = "Crosshair",
        CurrentValue = false,
        Callback = function(Value)
            local gui = LocalPlayer.PlayerGui:FindFirstChild("AquaCrosshair")
            if Value then
                if not gui then
                    gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui); gui.Name = "AquaCrosshair"
                    local box = Instance.new("Frame", gui); box.Size = UDim2.new(0, 6, 0, 6); box.Position = UDim2.new(0.5, -3, 0.5, -3)
                    box.BackgroundColor3 = Color3.fromRGB(0, 255, 0); Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
                end
            else
                if gui then gui:Destroy() end
            end
        end
    })


    -- ==============================
    --         TROLL TAB
    -- ==============================
    TrollTab:CreateSection("Teleport System")
    
    local selectedPlr = nil
    local spectating = false
    local plrList = {}

    -- Helper to get names
    local function GetNames()
        local t = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        return t
    end
    
    local PlrDropdown = TrollTab:CreateDropdown({
        Name = "Select Player",
        Options = GetNames(),
        CurrentOption = "",
        Callback = function(Option)
            selectedPlr = Players:FindFirstChild(Option)
        end
    })

    TrollTab:CreateButton({
        Name = "Refresh List 🔄",
        Callback = function()
            PlrDropdown:Refresh(GetNames(), true)
        end
    })

    TrollTab:CreateButton({
        Name = "Teleport to Player 🚀",
        Callback = function()
            if selectedPlr and selectedPlr.Character and selectedPlr.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlr.Character.HumanoidRootPart.CFrame
                library:Notify({Title="Teleported", Content="Whoosh!", Duration=2})
            else
                library:Notify({Title="Error", Content="Player not found/dead.", Duration=3})
            end
        end
    })

    TrollTab:CreateToggle({
        Name = "Spectate Player 👁️",
        CurrentValue = false,
        Callback = function(Value)
            spectating = Value
            if spectating then
                if selectedPlr then
                    workspace.CurrentCamera.CameraSubject = selectedPlr.Character.Humanoid
                else
                    library:Notify({Title="Error", Content="Select a player first!", Duration=2})
                end
            else
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    })
    
    TrollTab:CreateSection("Chat Trolling")
    local spamming = false
    local spamMsg = "Aqua Hub on Top!"
    
    TrollTab:CreateInput({
        Name = "Spam Message",
        PlaceholderText = "Type message here...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text) spamMsg = Text end
    })

    TrollTab:CreateToggle({
        Name = "Enable Chat Spam",
        CurrentValue = false,
        Callback = function(Value)
            spamming = Value
            task.spawn(function()
                while spamming do
                    local args = {[1] = spamMsg, [2] = "All"}
                    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack(args))
                    task.wait(2)
                end
            end)
        end
    })


    -- ==============================
    --      SETTINGS & MISC
    -- ==============================
    SettingsTab:CreateSection("Ghost Mode")
    SettingsTab:CreateButton({
        Name = "Ghost Mode (30s Invisible)",
        Callback = function()
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChild("Humanoid"); local oldDisplay = hum.DisplayDistanceType
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            for _, v in pairs(char:GetDescendants()) do
                if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then v.Transparency = 1 end
            end
            library:Notify({Title="Ghost Mode", Content="Invisible for 30s...", Duration=3})
            task.wait(30)
            hum.DisplayDistanceType = oldDisplay
            for _, v in pairs(char:GetDescendants()) do
                if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
            end
            library:Notify({Title="Ghost Mode", Content="Visible again.", Duration=3})
        end
    })

    SettingsTab:CreateSection("Themes")
    SettingsTab:CreateDropdown({
        Name = "Choose Theme",
        Options = {"Ocean", "DarkBlue", "Green", "Amber", "Light", "Default"},
        CurrentOption = "Ocean",
        Callback = function(Option) library:Destroy(); LoadAquaHub(Option) end
    })
    
    MiscTab:CreateSection("Server Tools")
    MiscTab:CreateButton({
       Name = "Server Hop (Join New Server)",
       Callback = function()
           local PlaceID = game.PlaceId
           local AllIDs = {}
           local found = false
           local function Teleport()
               local site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
               for i, v in pairs(site.data) do
                   if v.playing ~= v.maxPlayers then
                       table.insert(AllIDs, v.id)
                   end
               end
               if #AllIDs > 0 then
                   game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, AllIDs[math.random(1, #AllIDs)], LocalPlayer)
                   found = true
               end
           end
           if not found then Teleport() end
       end
    })
    MiscTab:CreateButton({ Name = "Unload Script", Callback = function() library:Destroy() end })

    library:Notify({ Title = "Aqua Hub V5", Content = "Loaded! Check Troll Tab.", Duration = 5, Image = 4483362458 })
end

LoadAquaHub("Ocean")
