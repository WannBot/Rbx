-- LocalScript / Script untuk Auto Teleport
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Teleport",
    LoadingTitle = "Teleport System",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TeleportCFG",
        FileName = "AutoTP7"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Teleport", 4483362458)
local Section = Tab:CreateSection("Pengaturan Auto Teleport")

-- Toggle status
local autoTP = false
Tab:CreateToggle({
    Name = "Auto Teleport 7 Titik",
    CurrentValue = false,
    Callback = function(Value)
        autoTP = Value
        print("AutoTP:", autoTP)
    end,
})

-- === Daftar koordinat ===
-- index 0 = Basecamp
local coords = {
    [0] = Vector3.new(251, 14, -992),     -- Basecamp
    [1] = Vector3.new(388, 310, -185), 
    [2] = Vector3.new(99, 412, 615),
    [3] = Vector3.new(10, 601, 998),
    [4] = Vector3.new(871, 865, 583),
    [5] = Vector3.new(1622, 1080, 157), 
    [6] = Vector3.new(2969, 1528, 708), 
    [7] = Vector3.new(1803, 1982, 2169), 
}

-- Fungsi teleport
local function teleportTo(pos)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Fungsi respawn
local function respawnPlayer()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").Health = 0
    end
end

-- Loop utama
task.spawn(function()
    while task.wait() do
        if autoTP then
            -- start dari basecamp (0) -> 1
            teleportTo(coords[1])
            print("Teleport Basecamp -> 1")
            task.wait(30)

            -- 1 -> 2 (30 detik juga)
            teleportTo(coords[2])
            print("Teleport 1 -> 2")
            task.wait(30)

            -- sisanya 10 detik per langkah
            for i = 3, 7 do
                teleportTo(coords[i])
                print("Teleport ke titik", i)
                if i < 7 then
                    task.wait(10)
                end
            end

            -- setelah titik 7 respawn
            respawnPlayer()
            print("Respawn setelah titik 7")

            -- tunggu respawn aman
            task.wait(5)
        end
    end
end)
