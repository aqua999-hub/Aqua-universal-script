-- AQUA HUB V3.1 (Fixed Rayfield Edition)
-- Added: 30s Ghost Mode Timer (Hides Name & Character), Fixed Visuals

local function LoadScript(selectedTheme)
    -- 1. Load the Fixed Rayfield Library
    local success, library = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)

    if not success then
        warn("Rayfield failed to load!")
        return
    end

    -- 2. Create Window
    local Window = library:CreateWindow({
       Name = "Aqua Hub",
       LoadingTitle = "Loading Aqua Hub...",
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
    local VisualTab = Window:CreateTab("Visuals", 4483362458)
    local TrollTab = Window:CreateTab("Troll", 4483362458)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    local MiscTab = Window:CreateTab("Misc", 4483362458)


    -- ==============================
    --        MAIN TAB
    -- ==============================
    MainTab:CreateSection("Movement Hacks")

    -- NOCLIP
    local noclip = false
    game:GetService("RunService").Stepped:Connect(function()
        if noclip then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    MainTab:CreateToggle({
        Name = "Noclip (Walk Through Walls)",
        CurrentValue = false,
        Flag = "Noclip",
        Callback = function(Value) noclip = Value end
    })

    -- INFINITE JUMP
    local infJump = false
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if infJump then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)

    MainTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfJump",
        Callback = function(Value) infJump = Value end
    })

    -- FLY
    local flying = false
    local flySpeed = 50
    local bv, bg
    MainTab:CreateToggle({
       Name = "Enable Fly (Mobile Friendly)",
       CurrentValue = false,
       Flag = "FlyToggle", 
       Callback = function(Value)
          flying = Value
          local plr = game.Players.LocalPlayer
          local char = plr.Character
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
                   else
                      bv.Velocity = Vector3.new(0,0,0)
                   end
                   bg.CFrame = cam.CFrame
                   task.wait()
                end
             end)
          else
             if bv then bv:Destroy() end; if bg then bg:Destroy() end; if hum then hum.PlatformStand = false end
          end
       end,
    })

    MainTab:CreateSlider({
       Name = "Fly Speed",
       Range = {10, 200}, Increment = 1, Suffix = "Speed", CurrentValue = 50,
       Callback = function(Value) flySpeed = Value end,
    })

    MainTab:CreateSection("Character Stats")
    MainTab:CreateSlider({
       Name = "WalkSpeed",
       Range = {16, 500}, Increment = 1, Suffix = "Speed", CurrentValue = 16,
       Callback = function(Value)
          if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end
       end,
    })
    MainTab:CreateSlider({
       Name = "JumpPower",
       Range = {50, 500}, Increment = 1, Suffix = "Power", CurrentValue = 50,
       Callback = function(Value)
          if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value end
       end,
    })


    -- ==============================
    --       VISUALS TAB
    -- ==============================
    VisualTab:CreateSection("ESP Settings")

    local espEnabled = false
    local espColor = Color3.fromRGB(255, 0, 0) 

    local function UpdateESP()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("GeminiHighlight")
                if espEnabled then
                    if not hl then
                        hl = Instance.new("Highlight", p.Character)
                        hl.Name = "GeminiHighlight"
                    end
                    hl.FillColor = espColor
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end

    VisualTab:CreateToggle({
       Name = "ESP (Wallhack)",
       CurrentValue = false,
       Callback = function(Value)
          espEnabled = Value
          UpdateESP()
          task.spawn(function()
             while espEnabled do UpdateESP(); task.wait(1) end
          end)
       end,
    })

    VisualTab:CreateColorPicker({
        Name = "ESP Color",
        Color = Color3.fromRGB(255, 0, 0),
        Flag = "ESPColor",
        Callback = function(Value)
            espColor = Value
            UpdateESP() 
        end
    })

    VisualTab:CreateSection("World Visuals")
    VisualTab:CreateToggle({
        Name = "Fullbright (See in Dark)",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                game.Lighting.Brightness = 2; game.Lighting.ClockTime = 14; game.Lighting.FogEnd = 100000; game.Lighting.GlobalShadows = false
            else
                game.Lighting.Brightness = 1; game.Lighting.GlobalShadows = true
            end
        end
    })
    VisualTab:CreateSlider({
        Name = "Field of View (FOV)",
        Range = {70, 120}, Increment = 1, Suffix = "FOV", CurrentValue = 70,
        Callback = function(Value) workspace.CurrentCamera.FieldOfView = Value end,
    })


    -- ==============================
    --      SETTINGS TAB
    -- ==============================
    SettingsTab:CreateSection("Ghost Mode")

    -- 30 Second Invisible Logic
    SettingsTab:CreateButton({
        Name = "Ghost Mode (30 Seconds)",
        Callback = function()
            local plr = game.Players.LocalPlayer
            local char = plr.Character
            if not char then return end
            
            local hum = char:FindFirstChild("Humanoid")
            if not hum then return end

            -- 1. Notify Start
            library:Notify({Title = "Ghost Mode Active", Content = "You are invisible for 30 seconds!", Duration = 3})

            -- 2. Hide Name Tag (So people can't see your name floating)
            local oldDisplay = hum.DisplayDistanceType
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

            -- 3. Make Parts Transparent
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if part.Name ~= "HumanoidRootPart" then -- Keep RootPart as is (usually invisible anyway)
                        part.Transparency = 1
                    end
                end
            end

            -- 4. Wait 30 Seconds
            task.wait(30)

            -- 5. Restore Visibility
            hum.DisplayDistanceType = oldDisplay -- Show Name Tag
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0 -- Reset to visible
                    end
                end
            end
            
            -- 6. Notify End
            library:Notify({Title = "Ghost Mode Ended", Content = "You are visible again.", Duration = 3})
        end
    })

    SettingsTab:CreateSection("Performance & Safety")
    SettingsTab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                local vu = game:GetService("VirtualUser")
                game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                end)
            end
        end
    })

    SettingsTab:CreateButton({
        Name = "FPS Boost (Removes Textures)",
        Callback = function()
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
                if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
            end
        end
    })
    
    SettingsTab:CreateSection("Theme Changer")
    SettingsTab:CreateDropdown({
        Name = "Select Theme",
        Options = {"Ocean", "DarkBlue", "Green", "Amber", "Light", "Default"},
        CurrentOption = "Ocean",
        Callback = function(Option)
            library:Destroy()
            LoadScript(Option)
        end
    })


    -- ==============================
    --         TROLL TAB
    -- ==============================
    TrollTab:CreateSection("Fun Functions")
    TrollTab:CreateButton({
       Name = "Spin Character",
       Callback = function()
          local plr = game.Players.LocalPlayer
          if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
             local spin = Instance.new("BodyAngularVelocity")
             spin.Parent = plr.Character.HumanoidRootPart
             spin.MaxTorque = Vector3.new(0, math.huge, 0)
             spin.AngularVelocity = Vector3.new(0, 100, 0)
             game:GetService("Debris"):AddItem(spin, 2)
          end
       end,
    })


    -- ==============================
    --         MISC TAB
    -- ==============================
    MiscTab:CreateSection("Utilities")
    MiscTab:CreateButton({
       Name = "Rejoin Server",
       Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end,
    })
    MiscTab:CreateButton({
       Name = "Destroy UI",
       Callback = function() library:Destroy() end,
    })

    library:Notify({ Title = "Aqua Hub Ready", Content = "V3.1 Loaded Successfully", Duration = 5, Image = 4483362458 })
end

-- Initial Load
LoadScript("Ocean")

