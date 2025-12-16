-- FIXED RAYFIELD LOADSTRING (Uses Raw GitHub to prevent 404s)
local success, library = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success then
    warn("Rayfield failed to load. Try Option 2 (Custom UI) instead.")
    return
end

local Window = library:CreateWindow({
   Name = "Universal Script Hub",
   LoadingTitle = "Loading Interface...",
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
      SaveKey = true,
      GrabKeyFromSite = false, 
      Key = {"test1"} 
   }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local TrollTab = Window:CreateTab("Troll", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- === MAIN TAB ===
MainTab:CreateSection("Player Stats")

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider", 
   Callback = function(Value)
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 400},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider", 
   Callback = function(Value)
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

-- === TROLL TAB ===
TrollTab:CreateSection("Fun Functions")

TrollTab:CreateButton({
   Name = "Spin Character (Local)",
   Callback = function()
      local plr = game.Players.LocalPlayer
      if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local spin = Instance.new("BodyAngularVelocity")
         spin.Name = "Spinner"
         spin.Parent = plr.Character.HumanoidRootPart
         spin.MaxTorque = Vector3.new(0, math.huge, 0)
         spin.AngularVelocity = Vector3.new(0, 100, 0)
         game:GetService("Debris"):AddItem(spin, 2)
      end
   end,
})

TrollTab:CreateButton({
   Name = "Print Fake Error",
   Callback = function()
      warn("CRITICAL ERROR: SYSTEM FAILURE... just kidding.")
   end,
})

-- === MISC TAB ===
MiscTab:CreateSection("Utilities")

MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
       game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
   end,
})

MiscTab:CreateButton({
   Name = "Unload UI",
   Callback = function()
      library:Destroy()
   end,
})
