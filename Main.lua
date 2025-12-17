-- AQUA HUB V7 [VAPE EDITION]
-- Changelog: Added TriggerBot, AutoClicker, CFrame Fly, Smart TP System.

-- 1. CLEANUP
if getgenv().AquaUI then pcall(function() getgenv().AquaUI:Destroy() end) end

-- 2. VARIABLES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Global Settings
local Config = {
    Speed = 16,
    Fly = false,
    FlySpeed = 1,
    Noclip = false,
    InfJump = false,
    TriggerBot = false,
    AutoClicker = false,
    ClickDelay = 0.1,
    Esp = false,
    EspColor = Color3.fromRGB(255, 0, 0),
    Spectating = false,
    TargetPlr = nil
}

-- 3. LOAD LIBRARY
local success, library = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success then return warn("Lib Failed") end
getgenv().AquaUI = library

-- 4. WINDOW
local Window = library:CreateWindow({
   Name = "Aqua Hub V7 [Vape Mode]",
   LoadingTitle = "Loading V7...",
   LoadingSubtitle = "Universal Edition",
   ConfigurationSaving = { Enabled = true, FolderName = "AquaHubV7", FileName = "ConfigV7" },
   Discord = { Enabled = true, Invite = "RCmMvZjC7m", RememberJoins = true },
   KeySystem = true, 
   KeySettings = {
      Title = "Aqua Hub Login",
      Subtitle = "Key System",
      Note = "Key: test1",
      FileName = "AquaKeyV7",
      SaveKey = true,
      GrabKeyFromSite = false, 
      Key = {"test1"} 
   },
   Theme = "Ocean"
})

-- 5. TABS
local CombatTab = Window:CreateTab("Combat", 4483362458)
local BlatantTab = Window:CreateTab("Blatant", 4483362458) -- Movement
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)


-- ==============================
--        COMBAT TAB (Vape Style)
-- ==============================
CombatTab:CreateSection("Auto Assist")

-- TRIGGERBOT
CombatTab:CreateToggle({
    Name = "TriggerBot (Auto Shoot)",
    CurrentValue = false,
    Flag = "TriggerBot",
    Callback = function(Value)
        Config.TriggerBot = Value
        task.spawn(function()
            while Config.TriggerBot do
                local target = Mouse.Target
                if target and target.Parent then
                    local hum = target.Parent:FindFirstChild("Humanoid")
                    if hum then
                        mouse1click() -- Simulate Click
                        task.wait(0.1)
                    end
                end
                task.wait()
            end
        end)
    end
})

-- AUTOCLICKER
CombatTab:CreateToggle({
    Name = "AutoClicker (Universal)",
    CurrentValue = false,
    Flag = "AutoClicker",
    Callback = function(Value)
        Config.AutoClicker = Value
        task.spawn(function()
            while Config.AutoClicker do
                mouse1click()
                task.wait(Config.ClickDelay)
            end
        end)
    end
})

CombatTab:CreateSlider({
   Name = "Click Delay", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.1,
   Callback = function(Value) Config.ClickDelay = Value end,
})

-- HITBOX
local HeadSize = 1.2
local BigHead = false
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(Value) BigHead = Value end
})
CombatTab:CreateSlider({
    Name = "Size", Range = {2, 20}, Increment = 1, CurrentValue = 5,
    Callback = function(Value) HeadSize = Value end
})

RunService.RenderStepped:Connect(function()
    if BigHead then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                p.Character.Head.Transparency = 0.5
                p.Character.Head.CanCollide = false
            end
        end
    end
end)


-- ==============================
--       BLATANT TAB (Movement)
-- ==============================
BlatantTab:CreateSection("CFrame Movement (Bypasses Anti-Cheat)")

-- CFrame Speed
BlatantTab:CreateToggle({
    Name = "Speed Hack (CFrame)",
    CurrentValue = false,
    Callback = function(Value)
        local SpeedEnabled = Value
        RunService.Stepped:Connect(function()
            if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (LocalPlayer.Character.Humanoid.MoveDirection * Config.Speed/50)
                end
            end
        end)
    end
})
BlatantTab:CreateSlider({
    Name = "Speed Factor", Range = {1, 10}, Increment = 0.5, CurrentValue = 1,
    Callback = function(Value) Config.Speed = Value * 20 end
})

-- CFrame Fly
local FlyEnabled = false
BlatantTab:CreateToggle({
    Name = "Fly (CFrame)",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if FlyEnabled then
            local bp = Instance.new("BodyPosition", LocalPlayer.Character.HumanoidRootPart)
            bp.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            bp.Position = LocalPlayer.Character.HumanoidRootPart.Position
            local bg = Instance.new("BodyGyro", LocalPlayer.Character.HumanoidRootPart)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bg.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            task.spawn(function()
                while FlyEnabled do
                    if not LocalPlayer.Character then break end
                    bp.Position = LocalPlayer.Character.HumanoidRootPart.Position + ((Camera.CFrame.LookVector * (Config.FlySpeed * 5)) + (Camera.CFrame.RightVector * 0) + (Camera.CFrame.UpVector * 0))
                    bg.CFrame = Camera.CFrame
                    task.wait()
                end
                bp:Destroy()
                bg:Destroy()
            end)
        end
    end
})
BlatantTab:CreateSlider({
    Name = "Fly Speed", Range = {1, 10}, Increment = 1, CurrentValue = 1,
    Callback = function(Value) Config.FlySpeed = Value end
})


-- ==============================
--        PLAYER TAB (Fixed)
-- ==============================
PlayerTab:CreateSection("Smart Target System")

local TargetNameInput = ""

-- HELPER: Find Player by Partial Name
local function GetPlayer(String)
    if not String or String == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if string.lower(p.Name):sub(1, #String) == string.lower(String) or 
           string.lower(p.DisplayName):sub(1, #String) == string.lower(String) then
            return p
        end
    end
    return nil
end

PlayerTab:CreateInput({
    Name = "Target Player (Type partial name)",
    PlaceholderText = "e.g. 'Build' for BuilderMan",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        TargetNameInput = Text
    end
})

PlayerTab:CreateButton({
    Name = "Teleport to Target 🚀",
    Callback = function()
        local t = GetPlayer(TargetNameInput)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame
            library:Notify({Title="Success", Content="Teleported to "..t.Name, Duration=3})
        else
            library:Notify({Title="Error", Content="Player not found.", Duration=3})
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Spectate Target 👁️",
    CurrentValue = false,
    Callback = function(Value)
        Config.Spectating = Value
        if not Value then Camera.CameraSubject = LocalPlayer.Character.Humanoid end
    end
})

RunService.RenderStepped:Connect(function()
    if Config.Spectating then
        local t = GetPlayer(TargetNameInput)
        if t and t.Character and t.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = t.Character.Humanoid
        end
    end
end)


-- ==============================
--        VISUALS TAB
-- ==============================
VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        Config.Esp = Value
        while Config.Esp do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("AquaHighlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "AquaHighlight"
                        h.FillColor = Config.EspColor
                        h.OutlineColor = Color3.new(1,1,1)
                        h.FillTransparency = 0.5
                    end
                end
            end
            task.wait(1)
            -- Cleanup if disabled
            if not Config.Esp then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("AquaHighlight") then
                        p.Character.AquaHighlight:Destroy()
                    end
                end
            end
        end
    end
})
VisualTab:CreateColorPicker({
    Name = "ESP Color", Color = Color3.fromRGB(255,0,0),
    Callback = function(Value) Config.EspColor = Value end
})


-- ==============================
--        WORLD TAB
-- ==============================
WorldTab:CreateSection("Server")

WorldTab:CreateToggle({
    Name = "Anti-Void (Platform)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            local p = Instance.new("Part", Workspace)
            p.Name = "AntiVoid"
            p.Size = Vector3.new(2048, 1, 2048)
            p.Position = Vector3.new(0, -100, 0)
            p.Anchored = true
            p.Transparency = 0.5
            task.spawn(function()
                while p.Parent do
                    if LocalPlayer.Character then
                        p.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -100, LocalPlayer.Character.HumanoidRootPart.Position.Z)
                    end
                    task.wait(0.1)
                end
            end)
        else
            if Workspace:FindFirstChild("AntiVoid") then Workspace.AntiVoid:Destroy() end
        end
    end
})

WorldTab:CreateSlider({
    Name = "Gravity", Range = {0, 196}, Increment = 10, CurrentValue = 196,
    Callback = function(Value) Workspace.Gravity = Value end
})


-- ==============================
--        SETTINGS TAB
-- ==============================
SettingsTab:CreateButton({Name = "Unload UI", Callback = function() library:Destroy() end})

library:Notify({Title="Aqua Hub V7", Content="Vape Mode Loaded", Duration=5, Image=4483362458})

