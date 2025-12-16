-- GEMINI HUB V2 (Fixed Rayfield Edition)
-- Features: Fly, Visuals (ESP), Theme Switcher, Key System

local function LoadScript(selectedTheme)
    -- 1. Load the Fixed Rayfield Library
    local success, library = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)

    if not success then
        warn("Rayfield failed to load!")
        return
    end

    -- 2. Create Window (Uses the selected theme)
    local Window = library:CreateWindow({
       Name = "Universal Script Hub V2",
       LoadingTitle = "Loading Gemini Hub...",
       LoadingSubtitle = "By Gemini",
       ConfigurationSaving = {
          Enabled = true,
          FolderName = "GeminiHub", 
          FileName = "BigHub"
       },
       Discord = {
          Enabled = true,
          Invite = "RCmMvZjC7m", 
          RememberJoins = true 
       },
       KeySystem = true, 
       KeySettings = {
          Title = "Access Required",
          Subtitle = "Key System",
          Note = "join discord for key https://discord.gg/RCmMvZjC7m",
          FileName = "HubKey",
          SaveKey = true, -- Saves key so you don't type it every time you change themes
          GrabKeyFromSite = false, 
          Key = {"test1"} 
       },
       Theme = selectedTheme or "Default" -- Default, Amber, Ocean, Light, Green, DarkBlue
    })

    -- 3. Create Tabs
    local MainTab = Window:CreateTab("Main", 4483362458)
    local VisualTab = Window:CreateTab("Visuals", 4483362458) -- NEW
    local TrollTab = Window:CreateTab("Troll", 4483362458)
    local SettingsTab = Window:CreateTab("Themes", 4483362458) -- NEW
    local MiscTab = Window:CreateTab("Misc", 4483362458)

    -- === MAIN TAB (Fly & Stats) ===
    MainTab:CreateSection("Movement")

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
             -- Start Flying
             bv = Instance.new("BodyVelocity", root)
             bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
             bv.Velocity = Vector3.new(0,0,0)
             
             bg = Instance.new("BodyGyro", root)
             bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
             bg.CFrame = root.CFrame
             
             -- Fly Loop
             task.spawn(function()
                while flying and char and hum.Health > 0 do
                   local cam = workspace.CurrentCamera
                   local move = hum.MoveDirection
                   -- Fly where camera looks
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
             -- Stop Flying
             if bv then bv:Destroy() end
             if bg then bg:Destroy() end
             if hum then hum.PlatformStand = false end
          end
       end,
    })

    MainTab:CreateSlider({
       Name = "Fly Speed",
       Range = {10, 200},
       Increment = 1,
       Suffix = "Speed",
       CurrentValue = 50,
       Callback = function(Value)
          flySpeed = Value
       end,
    })

    MainTab:CreateSection("Player Stats")
    MainTab:CreateSlider({
       Name = "WalkSpeed",
       Range = {16, 300},
       Increment = 1,
       Suffix = "Speed",
       CurrentValue = 16,
       Callback = function(Value)
          if game.Players.LocalPlayer.Character then
             game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
          end
       end,
    })

    -- === VISUALS TAB (ESP) ===
    VisualTab:CreateSection("ESP Settings")

    local espEnabled = false
    local function UpdateESP()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("GeminiHighlight")
                if espEnabled then
                    if not hl then
                        hl = Instance.new("Highlight", p.Character)
                        hl.Name = "GeminiHighlight"
                        hl.FillColor = Color3.fromRGB(255, 0, 0) -- Red Highlight
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                    end
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
          -- Connect to new players joining
          game.Players.PlayerAdded:Connect(function() task.wait(1) UpdateESP() end)
          -- Loop to ensure it stays
          task.spawn(function()
             while espEnabled do
                UpdateESP()
                task.wait(1)
             end
          end)
       end,
    })

    VisualTab:CreateToggle({
        Name = "Name Tags",
        CurrentValue = false,
        Callback = function(Value)
            -- Simple logic to add BillboardGui over heads would go here
            -- Keeping it simple for Rayfield stability:
            if Value then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Head") then
                        local bg = Instance.new("BillboardGui", p.Character.Head)
                        bg.Name = "NameTag"
                        bg.Size = UDim2.new(0,100,0,50); bg.StudsOffset=Vector3.new(0,2,0); bg.AlwaysOnTop=true
                        local t = Instance.new("TextLabel", bg); t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1
                        t.Text = p.Name; t.TextColor3=Color3.new(1,1,1)
                    end
                end
            else
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character.Head:FindFirstChild("NameTag") then
                        p.Character.Head.NameTag:Destroy()
                    end
                end
            end
        end
    })

    -- === TROLL TAB ===
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

    -- === THEMES TAB ===
    SettingsTab:CreateSection("Change UI Theme")
    SettingsTab:CreateLabel("Clicking a theme will reload the UI.")

    local function SwitchTheme(newTheme)
        library:Destroy() -- Close current window
        LoadScript(newTheme) -- Re-open with new color
    end

    SettingsTab:CreateButton({ Name = "Default Theme", Callback = function() SwitchTheme("Default") end })
    SettingsTab:CreateButton({ Name = "Amber Glow", Callback = function() SwitchTheme("Amber") end })
    SettingsTab:CreateButton({ Name = "Ocean Blue", Callback = function() SwitchTheme("Ocean") end })
    SettingsTab:CreateButton({ Name = "Light Mode", Callback = function() SwitchTheme("Light") end })
    SettingsTab:CreateButton({ Name = "Hacker Green", Callback = function() SwitchTheme("Green") end })

    -- === MISC TAB ===
    MiscTab:CreateSection("Utilities")
    MiscTab:CreateButton({
       Name = "Rejoin Server",
       Callback = function()
           game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
       end,
    })
    MiscTab:CreateButton({
       Name = "Destroy UI",
       Callback = function() library:Destroy() end,
    })

    library:Notify({
       Title = "Loaded!",
       Content = "V2 Script Ready",
       Duration = 5,
       Image = 4483362458,
    })
end

-- Initial Load (Starts with Default Theme)
LoadScript("Default")

