-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local HttpService = game:GetService("HttpService")

-- Data
local recordedPath = {}
local savedPaths = {}
local recording = false
local playback = false
local speedMultiplier = 1.0
local fileName = "AutoWalkPaths.json"

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Load file jika ada
if isfile(fileName) then
   local data = readfile(fileName)
   savedPaths = HttpService:JSONDecode(data)
end

-- Fungsi simpan file
local function saveToFile()
   writefile(fileName, HttpService:JSONEncode(savedPaths))
end

-- Window
local Window = Rayfield:CreateWindow({
   Name = "Auto Walk Recorder",
   LoadingTitle = "Recorder",
   LoadingSubtitle = "Rayfield UI",
   ConfigurationSaving = {
      Enabled = false,
   }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local SavesTab = Window:CreateTab("Saves", 4483362458)

-- Rekam tombol
MainTab:CreateButton({
   Name = "Start/Stop Record",
   Callback = function()
      recording = not recording
      if recording then
         recordedPath = {}
         Rayfield:Notify({
            Title = "Recording",
            Content = "Mulai merekam posisi...",
            Duration = 3
         })
      else
         Rayfield:Notify({
            Title = "Stopped",
            Content = "Rekaman selesai ("..#recordedPath.." titik)",
            Duration = 3
         })
      end
   end,
})

-- Playback
MainTab:CreateButton({
   Name = "Play Record",
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

-- Speed
MainTab:CreateSlider({
   Name = "Speed",
   Range = {0.5, 3},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1,
   Callback = function(Value)
      speedMultiplier = Value
   end,
})

-- Save record
MainTab:CreateButton({
   Name = "Save Current Path",
   Callback = function()
      if #recordedPath == 0 then return end
      local saveName = "Record_"..os.time()
      savedPaths[saveName] = recordedPath
      saveToFile()

      local section = SavesTab:CreateSection(saveName)

      -- Play
      SavesTab:CreateButton({
         Name = "Play "..saveName,
         Callback = function()
            local path = savedPaths[saveName]
            humanoid.WalkSpeed = 16 * speedMultiplier
            for _,pos in ipairs(path) do
               humanoid:MoveTo(pos)
               humanoid.MoveToFinished:Wait()
            end
            humanoid.WalkSpeed = 16
         end,
      })

      -- Rename
      SavesTab:CreateInput({
         Name = "Rename "..saveName,
         PlaceholderText = "Nama baru",
         RemoveTextAfterFocusLost = false,
         Callback = function(newName)
            if newName ~= "" and savedPaths[saveName] then
               savedPaths[newName] = savedPaths[saveName]
               savedPaths[saveName] = nil
               saveToFile()
               section:Set(newName)
               Rayfield:Notify({
                  Title = "Renamed",
                  Content = saveName.." → "..newName,
                  Duration = 3
               })
            end
         end,
      })

      -- Delete
      SavesTab:CreateButton({
         Name = "Delete "..saveName,
         Callback = function()
            savedPaths[saveName] = nil
            saveToFile()
            Rayfield:Notify({
               Title = "Deleted",
               Content = saveName.." dihapus",
               Duration = 3
            })
            -- Tidak ada API Rayfield untuk hapus UI, jadi biarkan tombol lama tidak aktif
         end,
      })

      Rayfield:Notify({
         Title = "Saved",
         Content = "Path tersimpan: "..saveName,
         Duration = 4
      })
   end,
})

-- Rekam posisi tiap 0.5 detik
task.spawn(function()
   while true do
      task.wait(0.5)
      if recording and root then
         table.insert(recordedPath, root.Position)
      end
   end
end)

-- Muat semua save dari file saat start
for name,path in pairs(savedPaths) do
   local section = SavesTab:CreateSection(name)

   SavesTab:CreateButton({
      Name = "Play "..name,
      Callback = function()
         humanoid.WalkSpeed = 16 * speedMultiplier
         for _,pos in ipairs(path) do
            humanoid:MoveTo(pos)
            humanoid.MoveToFinished:Wait()
         end
         humanoid.WalkSpeed = 16
      end,
   })

   SavesTab:CreateInput({
      Name = "Rename "..name,
      PlaceholderText = "Nama baru",
      RemoveTextAfterFocusLost = false,
      Callback = function(newName)
         if newName ~= "" and savedPaths[name] then
            savedPaths[newName] = savedPaths[name]
            savedPaths[name] = nil
            saveToFile()
            section:Set(newName)
         end
      end,
   })

   SavesTab:CreateButton({
      Name = "Delete "..name,
      Callback = function()
         savedPaths[name] = nil
         saveToFile()
         Rayfield:Notify({
            Title = "Deleted",
            Content = name.." dihapus",
            Duration = 3
         })
      end,
   })
end
