--// Pastikan sudah punya Rayfield UI Library
-- Contoh: loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Teleport",
    LoadingTitle = "Teleport System",
    LoadingSubtitle = "by Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TeleportCFG",
        FileName = "AutoTP"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local MainSection = MainTab:CreateSection("Teleport Settings")

-- Variabel utama
local autoTP = false
local delayTime = 3 -- default 3 detik

-- Tombol toggle auto teleport
local Toggle = MainTab:CreateToggle({
    Name = "Auto Teleport",
    CurrentValue = false,
    Flag = "AutoTP",
    Callback = function(Value)
        autoTP = Value
    end,
})

-- Slider pengaturan delay
local Slider = MainTab:CreateSlider({
    Name = "Delay Teleport (detik)",
    Range = {1, 20},
    Increment = 1,
    Suffix = "Detik",
    CurrentValue = 3,
    Flag = "Delay",
    Callback = function(Value)
        delayTime = Value
    end,
})

-- Fungsi teleport
local function teleportTo(pos)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Loop utama auto teleport
task.spawn(function()
    while task.wait() do
        if autoTP then
            -- Teleport ke titik pertama
            teleportTo(Vector3.new(3055, 7878, 1034))
            task.wait(delayTime)

            -- Teleport ke titik kedua
            teleportTo(Vector3.new(-244, 122, 203))
            task.wait(delayTime)
        end
    end
end)
