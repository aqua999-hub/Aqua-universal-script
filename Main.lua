-- AQUA HUB V6 [PRO EDITION]
-- Changelog: Rewritten TP System, Robust Spectate, Universal Tools, Safe Theme Reload

-- 1. CLEANUP (Fixes Theme Switching Crashes)
if getgenv().AquaUI then
    pcall(function() getgenv().AquaUI:Destroy() end)
end

-- 2. VARIABLES & SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global State
local Settings = {
    Spectating = false,
    SpectateTarget = nil,
    EspEnabled = false,
    TracersEnabled = false,
    EspColor = Color3.fromRGB(255, 0, 0),
    Noclip = false,
    InfJump = false,
    Fly = false,
    FlySpeed = 50
}

-- 3. LOAD LIBRARY (Safe Mode)
local success, library = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success then return warn("Lib Failed") end
getgenv().AquaUI = library -- Store for cleanup

-- 4. CREATE WINDOW
local Window = library:CreateWindow({
   Name = "Aqua Hub V6 [Pro]",
   LoadingTitle = "Initializing Pro Engine...",
   LoadingSubtitle = "Universal Script",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AquaHubPro", 
      FileName = "V6Config"
   },
   Discord = { Enabled = true, Invite = "RCmMvZjC7m", RememberJoins = true },
   KeySystem = true, 
   KeySettings = {
      Title = "Aqua Hub Login",
      Subtitle = "Pro Access",
      Note = "Key: test1 | Discord: .gg/RCmMvZjC7m",
      FileName = "AquaProKey",
      SaveKey = true,
      GrabKeyFromSite = false, 
      Key = {"test1"} 
   },
   Theme = getgenv().SelectedTheme or "Ocean" -- Persist theme across reloads
})

-- 5. TABS
local MainTab = Window:CreateTab("Movement", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Players", 4483362458) -- TP & Spectate
local WorldTab = Window:CreateTab("World", 4483362458) -- Universal
local SettingsTab = Window:CreateTab("Settings", 4483362458)


-- ==============================
--        MOVEMENT TAB
-- ==============================
MainTab:CreateSection("Character Control")

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

MainTab:CreateToggle({
    Name = "Noclip (Walk Through Walls)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value) Settings.Noclip = Value end
})

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value) Settings.InfJump = Value end
})

-- Inf Jump Logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Mobile Fly Logic
local bv, bg
MainTab:CreateToggle({
   Name = "Fly (Mobile Optimized)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Fly = Value
      local char = LocalPlayer.Character
      local root = char and char:FindFirstChild("HumanoidRootPart")
      local hum = char and char:FindFirstChild("Humanoid")
      
      if Settings.Fly and root and hum then
         bv = Instance.new("BodyVelocity", root)
         bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0,0,0)
         bg = Instance.new("BodyGyro", root)
         bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.CFrame = root.CFrame
         
         task.spawn(function()
            while Settings.Fly and char and hum.Health > 0 do
               local cam = Camera.CFrame
               local move = hum.MoveDirection
               if move.Magnitude > 0 then
                  bv.Velocity = (move * Settings.FlySpeed) + Vector3.new(0, cam.LookVector.Y * Settings.FlySpeed, 0)
               else
                  bv.Velocity = Vector3.new(0,0,0)
               end
               bg.CFrame = Camera.CFrame
               task.wait()
            end
         end)
      else
         if bv then bv:Destroy() end
         if bg then bg:Destroy() end
         if hum then hum.PlatformStand = false end
      end
   end,
})

MainTab:CreateSlider({
   Name = "Fly Speed", Range = {10, 300}, Increment = 1, CurrentValue = 50,
   Callback = function(Value) Settings.FlySpeed = Value end,
})


-- ==============================
--   PLAYERS TAB (FIXED TP/SPECTATE)
-- ==============================
PlayerTab:CreateSection("Target Selector")

local SelectedPlayerName = nil

-- 1. Dynamic Dropdown Population
local function GetPlayerNames()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local PlayerDropdown = PlayerTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    CurrentOption = "",
    Callback = function(Option)
        SelectedPlayerName = Option
    end
})

PlayerTab:CreateButton({
    Name = "Refresh List 🔄",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerNames(), true)
    end
})

PlayerTab:CreateSection("Actions")

-- 2. FIXED TELEPORT LOGIC
PlayerTab:CreateButton({
    Name = "Teleport to Target 🚀",
    Callback = function()
        if not SelectedPlayerName then return library:Notify({Title="Error", Content="Select a player first!", Duration=2}) end
        
        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                library:Notify({Title="Success", Content="Teleported to " .. SelectedPlayerName, Duration=2})
            end
        else
            library:Notify({Title="Failed", Content="Target not found or dead.", Duration=2})
        end
    end
})

-- 3. FIXED SPECTATE LOGIC
PlayerTab:CreateToggle({
    Name = "Spectate Target 👁️",
    CurrentValue = false,
    Callback = function(Value)
        Settings.Spectating = Value
        if not Value then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        else
            if not SelectedPlayerName then 
                Settings.Spectating = false
                return library:Notify({Title="Error", Content="Select a player first!", Duration=2}) 
            end
        end
    end
})

-- Spectate Loop (Ensures camera stays locked)
RunService.RenderStepped:Connect(function()
    if Settings.Spectating and SelectedPlayerName then
        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
        else
            -- If target leaves/dies, revert or wait
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)


-- ==============================
--        COMBAT TAB
-- ==============================
CombatTab:CreateSection("Hitbox Manipulation")

local bigHead = false
local headSize = 5

CombatTab:CreateToggle({
    Name = "Hitbox Expander (Big Head)",
    CurrentValue = false,
    Callback = function(Value)
        bigHead = Value
        if not Value then
            -- Reset
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = Vector3.new(1.2, 1, 1); p.Character.Head.Transparency = 0
                end
            end
        end
    end
})

CombatTab:CreateSlider({
   Name = "Hitbox Size", Range = {2, 25}, Increment = 1, CurrentValue = 5,
   Callback = function(Value) headSize = Value end,
})

RunService.RenderStepped:Connect(function()
    if bigHead then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(headSize, headSize, headSize)
                p.Character.Head.CanCollide = false
                p.Character.Head.Transparency = 0.6
            end
        end
    end
end)


-- ==============================
--      VISUALS TAB (PRO)
-- ==============================
VisualTab:CreateSection("ESP Configuration")

VisualTab:CreateToggle({
    Name = "Box ESP + Highlights",
    CurrentValue = false,
    Callback = function(Value) Settings.EspEnabled = Value end
})

VisualTab:CreateColorPicker({
    Name = "ESP Color", Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) Settings.EspColor = Value end
})

-- Visuals Loop
task.spawn(function()
    while true do
        task.wait(1) -- Update every second to save performance
        if Settings.EspEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    -- Highlight
                    if not p.Character:FindFirstChild("AquaESPHighlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "AquaESPHighlight"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.FillColor = Settings.EspColor
                        hl.OutlineColor = Color3.new(1,1,1)
                    else
                        p.Character.AquaESPHighlight.FillColor = Settings.EspColor
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AquaESPHighlight") then
                    p.Character.AquaESPHighlight:Destroy()
                end
            end
        end
    end
end)

VisualTab:CreateSection("Customization")
VisualTab:CreateToggle({
    Name = "Fullbright (No Darkness)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        end
    end
})


-- ==============================
--      WORLD TAB (UNIVERSAL)
-- ==============================
WorldTab:CreateSection("Server Tools")

WorldTab:CreateButton({
    Name = "BTools (Client Side)",
    Callback = function()
        local backpack = LocalPlayer.Backpack
        Instance.new("HopperBin", backpack).BinType = Enum.BinType.Hammer
        Instance.new("HopperBin", backpack).BinType = Enum.BinType.Clone
        Instance.new("HopperBin", backpack).BinType = Enum.BinType.Grab
        library:Notify({Title="Success", Content="Building Tools added to backpack.", Duration=3})
    end
})

WorldTab:CreateSlider({
    Name = "Gravity Control",
    Range = {0, 300}, Increment = 10, CurrentValue = 196,
    Callback = function(Value)
        Workspace.Gravity = Value
    end
})

WorldTab:CreateToggle({
    Name = "Anti-Void (Don't Fall)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            local part = Instance.new("Part", Workspace)
            part.Name = "AquaAntiVoid"
            part.Size = Vector3.new(2000, 1, 2000)
            part.Position = Vector3.new(0, -50, 0) -- Below map
            part.Anchored = true; part.Transparency = 0.5; part.Color = Color3.new(0,1,1)
            
            -- Keep part below player
            task.spawn(function()
                while part and part.Parent do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        part.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -50, LocalPlayer.Character.HumanoidRootPart.Position.Z)
                    end
                    task.wait(0.1)
                end
            end)
        else
            if Workspace:FindFirstChild("AquaAntiVoid") then Workspace.AquaAntiVoid:Destroy() end
        end
    end
})


-- ==============================
--        SETTINGS TAB
-- ==============================
SettingsTab:CreateSection("Theme Manager")

local function SwitchTheme(theme)
    getgenv().SelectedTheme = theme -- Save choice
    library:Destroy() -- Clean kill
    -- Re-run the script automatically is hard without loadstring variable
    -- Instead, we notify user to re-execute for now to prevent crashing
    library:Notify({Title="Theme Changed", Content="Please Re-Execute Script to apply " .. theme, Duration=5})
end

SettingsTab:CreateDropdown({
    Name = "Select Theme",
    Options = {"Ocean", "DarkBlue", "Green", "Amber", "Light", "Default"},
    CurrentOption = getgenv().SelectedTheme or "Ocean",
    Callback = function(Option)
        SwitchTheme(Option)
    end
})

SettingsTab:CreateButton({
    Name = "Unload UI",
    Callback = function() library:Destroy() end
})

library:Notify({ Title = "Aqua Hub Pro", Content = "V6 Loaded Successfully", Duration = 5, Image = 4483362458 })
