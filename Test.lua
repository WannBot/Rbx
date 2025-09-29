-- Pastikan kamu sudah punya Rayfield UI Library di executor kamu
-- biasanya: local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local recordedPath = {}
local savedPaths = {}
local recording = false
local playback = false
local speedMultiplier = 1.0

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Window utama
local Window = Rayfield:CreateWindow({
   Name = "Auto Walk Recorder",
   LoadingTitle = "Recorder",
   LoadingSubtitle = "with Save/Load",
   ConfigurationSaving = {
      Enabled = false,
   }
})

-- Tab
local MainTab = Window:CreateTab("Main", 4483362458) -- ikon bebas
local SavesTab = Window:CreateTab("Saves", 4483362458)

-- Start/Stop Record
local recordButton = MainTab:CreateButton({
   Name = "Start Record",
   Callback = function()
      if not recording then
         recordedPath = {}
         recording = true
         recordButton:Set("Stop Record")
      else
         recording = false
         recordButton:Set("Start Record")
         Rayfield:Notify({
            Title = "Record Finished",
            Content = "Tersimpan sementara ("..#recordedPath.." titik)",
            Duration = 3
         })
      end
   end,
})

-- Playback
MainTab:CreateButton({
   Name = "Play Path",
   Callback = function()
      if #recordedPath == 0 then return end
      playback = true
      humanoid.WalkSpeed = 16 * speedMultiplier
      for _,pos in ipairs(recordedPath) do
         if not playback then break end
         humanoid:MoveTo(pos)
         humanoid.MoveToFinished:Wait()
      end
      humanoid.WalkSpeed = 16
      playback = false
   end,
})

-- Speed slider
MainTab:CreateSlider({
   Name = "Speed",
   Range = {0.5, 3},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "Speed",
   Callback = function(Value)
      speedMultiplier = Value
   end,
})

-- Save record
MainTab:CreateButton({
   Name = "Save Current Path",
   Callback = function()
      if #recordedPath == 0 then return end
      local defaultName = "Record_"..os.time()
      savedPaths[defaultName] = table.clone(recordedPath)

      -- Tambahkan ke SavesTab
      local section = SavesTab:CreateSection(defaultName)
      SavesTab:CreateButton({
         Name = "Play "..defaultName,
         Callback = function()
            local path = savedPaths[defaultName]
            if not path then return end
            humanoid.WalkSpeed = 16 * speedMultiplier
            for _,pos in ipairs(path) do
               humanoid:MoveTo(pos)
               humanoid.MoveToFinished:Wait()
            end
            humanoid.WalkSpeed = 16
         end,
      })
      SavesTab:CreateInput({
         Name = "Rename "..defaultName,
         PlaceholderText = "Nama baru",
         RemoveTextAfterFocusLost = false,
         Callback = function(newName)
            if newName ~= "" and savedPaths[defaultName] then
               savedPaths[newName] = savedPaths[defaultName]
               savedPaths[defaultName] = nil
               section:Set(newName)
            end
         end,
      })

      Rayfield:Notify({
         Title = "Saved",
         Content = "Path tersimpan dengan nama "..defaultName,
         Duration = 4
      })
   end,
})

-- Rekam posisi tiap detik
task.spawn(function()
   while true do
      task.wait(1)
      if recording and root then
         table.insert(recordedPath, root.Position)
      end
   end
end)
