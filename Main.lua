-- AQUA HUB V13 [VOIDWARE EDITION]
-- UI: Rayfield (Stable)
-- Theme: Voidware Purple
-- Features: Full Vape V4 Logic

-- 1. CLEANUP
if getgenv().AquaUI then
    pcall(function() getgenv().AquaUI:Destroy() end)
end

-- 2. SERVICES
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

if not success then return warn("Failed to load Rayfield") end
getgenv().AquaUI = library

-- 4. CREATE WINDOW (Voidware Theme)
local Window = library:CreateWindow({
   Name = "Aqua Hub [Voidware]",
   LoadingTitle = "Injecting Voidware...",
   LoadingSubtitle = "Vape V4 Modules",
   ConfigurationSaving = { Enabled = true, FolderName = "AquaVoid", FileName = "VoidConfig" },
   Discord = { Enabled = true, Invite = "RCmMvZjC7m", RememberJoins = true },
   KeySystem = true, 
   KeySettings = {
      Title = "Voidware Login",
      Subtitle = "Key System",
      Note = "Key: test1",
      FileName = "VoidKey",
      SaveKey = true,
      GrabKeyFromSite = false, 
      Key = {"test1"} 
   },
   Theme = "Default" -- We will force custom colors below if needed, but Rayfield Default is Dark
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
CombatTab:CreateSection("PVP Modules")

-- KILLAURA
local Aura = false
local AuraRange = 18
CombatTab:CreateToggle({
   Name = "Killaura (Legit)",
   CurrentValue = false,
   Flag = "Killaura",
   Callback = function(Value)
      Aura = Value
      task.spawn(function()
         while Aura do
            for _, p in pairs(Players:GetPlayers()) do
               if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                  local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                  if dist < AuraRange then
                      if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                          LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                      end
                  end
               end
            end
            task.wait(0.1)
         end
      end)
   end,
})
CombatTab:CreateSlider({ Name = "Aura Range", Range = {10, 50}, Increment = 1, CurrentValue = 18, Callback = function(V) AuraRange = V end})

-- SILENT AIM
local SilentAim = false
local FOV = 200
CombatTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Callback = function(Value) SilentAim = Value end,
})
RunService.RenderStepped:Connect(function()
    if SilentAim then
        local closest = nil
        local maxDist = FOV
        local mouse = UserInputService:GetMouseLocation()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToScreenPoint(p.Character.Head.Position)
                if vis then
                    local d = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if d < maxDist then
                        maxDist = d
                        closest = p.Character.Head
                    end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end
end)

-- HITBOX
local BigHead = false
local HeadSize = 5
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(Value)
        BigHead = Value
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
--       BLATANT TAB
-- ==============================
BlatantTab:CreateSection("Movement")

-- FLY
local Fly = false
local FlySpeed = 50
local bv, bg
BlatantTab:CreateToggle({
   Name = "Fly (Velocity)",
   CurrentValue = false,
   Callback = function(Value)
      Fly = Value
      local char = LocalPlayer.Character
      if Fly and char and char:FindFirstChild("HumanoidRootPart") then
         bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge); bv.Velocity = Vector3.new(0,0,0)
         bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.CFrame = char.HumanoidRootPart.CFrame
         task.spawn(function()
             while Fly and char:FindFirstChild("Humanoid") do
                 local cam = Camera.CFrame
                 local move = char.Humanoid.MoveDirection
                 if move.Magnitude > 0 then
                     bv.Velocity = (move * FlySpeed) + Vector3.new(0, cam.LookVector.Y * FlySpeed, 0)
                 else bv.Velocity = Vector3.new(0,0,0) end
                 bg.CFrame = Camera.CFrame
                 task.wait()
             end
             if bv then bv:Destroy() end; if bg then bg:Destroy() end
         end)
      else
         if bv then bv:Destroy() end; if bg then bg:Destroy() end
      end
   end,
})
BlatantTab:CreateSlider({ Name = "Fly Speed", Range = {20, 150}, Increment = 1, CurrentValue = 50, Callback = function(V) FlySpeed = V end})

-- SPEED
local Speed = false
local SpeedVal = 25
BlatantTab:CreateToggle({
    Name = "Speed (CFrame)",
    CurrentValue = false,
    Callback = function(Value) Speed = Value end
})
RunService.Stepped:Connect(function()
    if Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (LocalPlayer.Character.Humanoid.MoveDirection * (SpeedVal/50))
        end
    end
end)

-- SPIDER
local Spider = false
BlatantTab:CreateToggle({
    Name = "Spider",
    CurrentValue = false,
    Callback = function(Value) Spider = Value end
})
RunService.Stepped:Connect(function()
    if Spider and LocalPlayer.Character then
        local ray = Ray.new(LocalPlayer.Character.Head.Position, LocalPlayer.Character.Head.CFrame.LookVector * 2)
        if Workspace:FindPartOnRay(ray, LocalPlayer.Character) then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 30, 0)
        end
    end
end)


-- ==============================
--       VISUALS TAB
-- ==============================
VisualTab:CreateSection("Render")

local ESP = false
local ESPColor = Color3.fromRGB(170, 0, 255) -- Voidware Purple

VisualTab:CreateToggle({
    Name = "Voidware ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("VoidHighlight") then p.Character.VoidHighlight:Destroy() end
            end
        end
    end
})
VisualTab:CreateColorPicker({
    Name = "ESP Color", Color = Color3.fromRGB(170, 0, 255),
    Callback = function(V) ESPColor = V end
})

task.spawn(function()
    while true do
        task.wait(1)
        if ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("VoidHighlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "VoidHighlight"
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.FillColor = ESPColor
                        h.OutlineColor = Color3.new(1,1,1)
                    else
                        p.Character.VoidHighlight.FillColor = ESPColor
                    end
                end
            end
        end
    end
end)

VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            game.Lighting.Brightness = 2; game.Lighting.ClockTime = 14; game.Lighting.GlobalShadows = false
        else
            game.Lighting.Brightness = 1; game.Lighting.GlobalShadows = true
        end
    end
})


-- ==============================
--       WORLD TAB
-- ==============================
WorldTab:CreateSection("Utility")

WorldTab:CreateToggle({
    Name = "Anti-Void",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            local p = Instance.new("Part", Workspace); p.Name="VoidFloor"; p.Size=Vector3.new(2000,1,2000); p.Anchored=true; p.Position=Vector3.new(0,-100,0); p.Transparency=0.5; p.Color=Color3.fromRGB(170,0,255)
            task.spawn(function()
                while p.Parent do
                    if LocalPlayer.Character then p.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, -100, LocalPlayer.Character.HumanoidRootPart.Position.Z) end
                    task.wait(0.1)
                end
            end)
        else
            if Workspace:FindFirstChild("VoidFloor") then Workspace.VoidFloor:Destroy() end
        end
    end
})

WorldTab:CreateButton({
    Name = "Unload Script",
    Callback = function() library:Destroy() end
})

library:Notify({Title="Voidware Injected", Content="Welcome to V13", Duration=5, Image=4483362458})

